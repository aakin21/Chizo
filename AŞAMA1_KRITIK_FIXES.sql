-- ========================================
-- CHIZO DATABASE - AŞAMA 1: KRİTİK DÜZELTMELER
-- ========================================
-- Tarih: 2025-10-21
-- Süre: ~2 saat
-- Kritiklik: 🔴 YÜKSEK
--
-- ⚠️ UYARI: Bu script çalıştırılmadan önce DATABASE BACKUP ALIN!
--
-- Backup komutu (Supabase Dashboard → Settings → Database → Download backup)
--
-- ========================================

-- ===========================================
-- 1. ATOMIC COIN UPDATE FUNCTION (Race Condition Fix)
-- ===========================================
-- Sorun: user_service.dart:138-148 - Coin updates race condition'a açık
-- Çözüm: Database-level atomic function

CREATE OR REPLACE FUNCTION update_user_coins(
  p_user_id UUID,
  p_amount INTEGER,
  p_transaction_type VARCHAR,
  p_description TEXT
)
RETURNS TABLE(new_coin_amount INTEGER, transaction_id UUID) AS $$
DECLARE
  v_new_amount INTEGER;
  v_transaction_id UUID;
BEGIN
  -- Atomic olarak coin'leri güncelle
  UPDATE users
  SET
    coins = coins + p_amount,
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING coins INTO v_new_amount;

  -- Check if user exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  -- Check for negative coins
  IF v_new_amount < 0 THEN
    RAISE EXCEPTION 'Insufficient coins. Current: %, Requested: %', v_new_amount - p_amount, p_amount;
  END IF;

  -- Transaction kaydı oluştur
  INSERT INTO coin_transactions (
    user_id,
    amount,
    type,
    description,
    created_at
  ) VALUES (
    p_user_id,
    p_amount,
    p_transaction_type,
    p_description,
    NOW()
  ) RETURNING id INTO v_transaction_id;

  -- Sonucu döndür
  RETURN QUERY SELECT v_new_amount, v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- Test:
-- SELECT * FROM update_user_coins(
--   'USER_UUID_HERE'::UUID,
--   50,
--   'earned',
--   'Test coin update'
-- );

COMMENT ON FUNCTION update_user_coins IS 'Atomically updates user coins and creates transaction record. Prevents race conditions.';

-- ===========================================
-- 2. ATOMIC USER STATS UPDATE FUNCTION (Race Condition Fix)
-- ===========================================
-- Sorun: match_service.dart:295-301 - User stats updates race condition'a açık
-- Çözüm: Database-level atomic function

CREATE OR REPLACE FUNCTION update_user_stats(
  p_user_id UUID,
  p_is_winner BOOLEAN
)
RETURNS TABLE(
  new_total_matches INTEGER,
  new_wins INTEGER,
  new_win_rate DECIMAL
) AS $$
DECLARE
  v_total_matches INTEGER;
  v_wins INTEGER;
  v_win_rate DECIMAL;
BEGIN
  -- Atomic olarak stats'ları güncelle
  UPDATE users
  SET
    total_matches = total_matches + 1,
    wins = CASE WHEN p_is_winner THEN wins + 1 ELSE wins END,
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING total_matches, wins INTO v_total_matches, v_wins;

  -- Check if user exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  -- Calculate win rate
  IF v_total_matches > 0 THEN
    v_win_rate := (v_wins::DECIMAL / v_total_matches) * 100;
  ELSE
    v_win_rate := 0;
  END IF;

  -- Sonucu döndür
  RETURN QUERY SELECT v_total_matches, v_wins, v_win_rate;
END;
$$ LANGUAGE plpgsql;

-- Test:
-- SELECT * FROM update_user_stats('USER_UUID_HERE'::UUID, true);

COMMENT ON FUNCTION update_user_stats IS 'Atomically updates user match statistics. Prevents race conditions when multiple matches complete simultaneously.';

-- ===========================================
-- 3. ATOMIC TOURNAMENT JOIN FUNCTION (Race Condition Fix)
-- ===========================================
-- Sorun: tournament_service.dart:944-954 - Tournament join race condition'a açık
-- Çözüm: Database-level atomic function with validation

CREATE OR REPLACE FUNCTION join_tournament(
  p_tournament_id UUID,
  p_user_id UUID,
  p_photo_id UUID
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  current_participants INTEGER
) AS $$
DECLARE
  v_max_participants INTEGER;
  v_current_participants INTEGER;
  v_entry_fee INTEGER;
  v_user_coins INTEGER;
  v_status VARCHAR;
BEGIN
  -- Tournament bilgilerini al (FOR UPDATE ile lock'la)
  SELECT max_participants, current_participants, entry_fee, status
  INTO v_max_participants, v_current_participants, v_entry_fee, v_status
  FROM tournaments
  WHERE id = p_tournament_id
  FOR UPDATE;

  -- Check if tournament exists
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Tournament not found', 0;
    RETURN;
  END IF;

  -- Check tournament status
  IF v_status != 'registration' AND v_status != 'active' THEN
    RETURN QUERY SELECT false, 'Tournament is not open for registration', v_current_participants;
    RETURN;
  END IF;

  -- Check if tournament is full
  IF v_current_participants >= v_max_participants THEN
    RETURN QUERY SELECT false, 'Tournament is full', v_current_participants;
    RETURN;
  END IF;

  -- Check if user already joined
  IF EXISTS (
    SELECT 1 FROM tournament_participants
    WHERE tournament_id = p_tournament_id AND user_id = p_user_id
  ) THEN
    RETURN QUERY SELECT false, 'User already joined this tournament', v_current_participants;
    RETURN;
  END IF;

  -- Check user coins
  SELECT coins INTO v_user_coins FROM users WHERE id = p_user_id;
  IF v_user_coins < v_entry_fee THEN
    RETURN QUERY SELECT false, 'Insufficient coins', v_current_participants;
    RETURN;
  END IF;

  -- Coin'leri düşür (eğer entry fee varsa)
  IF v_entry_fee > 0 THEN
    UPDATE users
    SET coins = coins - v_entry_fee, updated_at = NOW()
    WHERE id = p_user_id;

    -- Transaction kaydı oluştur
    INSERT INTO coin_transactions (user_id, amount, type, description, created_at)
    VALUES (p_user_id, -v_entry_fee, 'spent', 'Tournament entry fee', NOW());
  END IF;

  -- Katılımcı ekle
  INSERT INTO tournament_participants (
    tournament_id,
    user_id,
    photo_id,
    score,
    joined_at
  ) VALUES (
    p_tournament_id,
    p_user_id,
    p_photo_id,
    0,
    NOW()
  );

  -- Participant count'u artır
  UPDATE tournaments
  SET current_participants = current_participants + 1, updated_at = NOW()
  WHERE id = p_tournament_id
  RETURNING current_participants INTO v_current_participants;

  -- Başarılı sonuç döndür
  RETURN QUERY SELECT true, 'Successfully joined tournament', v_current_participants;
END;
$$ LANGUAGE plpgsql;

-- Test:
-- SELECT * FROM join_tournament(
--   'TOURNAMENT_UUID_HERE'::UUID,
--   'USER_UUID_HERE'::UUID,
--   'PHOTO_UUID_HERE'::UUID
-- );

COMMENT ON FUNCTION join_tournament IS 'Atomically handles tournament join with validation. Prevents overbooking and race conditions.';

-- ===========================================
-- 4. ADD FOREIGN KEY: notifications.user_id
-- ===========================================
-- Sorun: notification_service.dart:569 - user_id foreign key yok
-- Risk: Silinen kullanıcıların bildirimleri kalıyor (GDPR ihlali)

-- Önce orphaned records'ları temizle
DELETE FROM notifications
WHERE user_id NOT IN (SELECT id FROM users);

-- Foreign key ekle
ALTER TABLE notifications
ADD CONSTRAINT notifications_user_id_fkey
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

COMMENT ON CONSTRAINT notifications_user_id_fkey ON notifications IS 'User silindi mi bildirimler de silinsin (GDPR compliance)';

-- ===========================================
-- 5. ADD UNIQUE CONSTRAINT: user_photos(user_id, photo_order)
-- ===========================================
-- Sorun: photo_upload_service.dart:368 - Aynı kullanıcının 2 fotoğrafı aynı slot'ta olabilir
-- Risk: Photo slot çakışmaları

-- Önce duplicate records'ları temizle
WITH duplicates AS (
  SELECT id, ROW_NUMBER() OVER (
    PARTITION BY user_id, photo_order
    ORDER BY created_at DESC
  ) AS rn
  FROM user_photos
)
DELETE FROM user_photos
WHERE id IN (
  SELECT id FROM duplicates WHERE rn > 1
);

-- Unique constraint ekle
ALTER TABLE user_photos
ADD CONSTRAINT user_photos_user_photo_order_unique
UNIQUE (user_id, photo_order);

COMMENT ON CONSTRAINT user_photos_user_photo_order_unique ON user_photos IS 'Her kullanıcının her slot\'unda sadece 1 fotoğraf olabilir';

-- ===========================================
-- 6. CASCADE DELETE DÜZELTMELERI (9 Foreign Key)
-- ===========================================
-- Sorun: User silindiğinde ilgili kayıtlar database'de kalıyor (GDPR ihlali)

-- 6.1. coin_transactions.user_id
ALTER TABLE coin_transactions DROP CONSTRAINT IF EXISTS coin_transactions_user_id_fkey;
ALTER TABLE coin_transactions ADD CONSTRAINT coin_transactions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.2. votes.voter_id
ALTER TABLE votes DROP CONSTRAINT IF EXISTS votes_voter_id_fkey;
ALTER TABLE votes ADD CONSTRAINT votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.3. reports.reporter_id
ALTER TABLE reports DROP CONSTRAINT IF EXISTS reports_reporter_id_fkey;
ALTER TABLE reports ADD CONSTRAINT reports_reporter_id_fkey
  FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.4. reports.reported_user_id
ALTER TABLE reports DROP CONSTRAINT IF EXISTS reports_reported_user_id_fkey;
ALTER TABLE reports ADD CONSTRAINT reports_reported_user_id_fkey
  FOREIGN KEY (reported_user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.5. tournament_participants.user_id
ALTER TABLE tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_user_id_fkey;
ALTER TABLE tournament_participants ADD CONSTRAINT tournament_participants_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.6. user_photos.user_id
ALTER TABLE user_photos DROP CONSTRAINT IF EXISTS user_photos_user_id_fkey;
ALTER TABLE user_photos ADD CONSTRAINT user_photos_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.7. winrate_predictions.user_id
ALTER TABLE winrate_predictions DROP CONSTRAINT IF EXISTS winrate_predictions_user_id_fkey;
ALTER TABLE winrate_predictions ADD CONSTRAINT winrate_predictions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.8. private_tournament_votes.voter_id
ALTER TABLE private_tournament_votes DROP CONSTRAINT IF EXISTS private_tournament_votes_voter_id_fkey;
ALTER TABLE private_tournament_votes ADD CONSTRAINT private_tournament_votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.9. tournament_votes.voter_id
ALTER TABLE tournament_votes DROP CONSTRAINT IF EXISTS tournament_votes_voter_id_fkey;
ALTER TABLE tournament_votes ADD CONSTRAINT tournament_votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.10. user_country_stats.user_id
ALTER TABLE user_country_stats DROP CONSTRAINT IF EXISTS user_country_stats_user_id_fkey;
ALTER TABLE user_country_stats ADD CONSTRAINT user_country_stats_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6.11. user_tokens.user_id
ALTER TABLE user_tokens DROP CONSTRAINT IF EXISTS user_tokens_user_id_fkey;
ALTER TABLE user_tokens ADD CONSTRAINT user_tokens_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

COMMENT ON TABLE coin_transactions IS 'CASCADE DELETE enabled - GDPR compliant';
COMMENT ON TABLE votes IS 'CASCADE DELETE enabled - GDPR compliant';
COMMENT ON TABLE reports IS 'CASCADE DELETE enabled - GDPR compliant';
COMMENT ON TABLE tournament_participants IS 'CASCADE DELETE enabled - GDPR compliant';
COMMENT ON TABLE user_photos IS 'CASCADE DELETE enabled - GDPR compliant';
COMMENT ON TABLE user_tokens IS 'CASCADE DELETE enabled - GDPR compliant';

-- ===========================================
-- 7. PHOTO_STATS TABLOSU MİGRASYON VE SİLME
-- ===========================================
-- Sorun: photo_stats duplicate tablo, user_photos zaten aynı verilere sahip
-- Çözüm: Verileri birleştir ve photo_stats tablosunu sil

-- Önce user_photos'daki eksik verileri photo_stats'tan güncelle
UPDATE user_photos up
SET
  wins = COALESCE(ps.wins, up.wins),
  total_matches = COALESCE(ps.total_matches, up.total_matches),
  updated_at = NOW()
FROM photo_stats ps
WHERE up.id = ps.photo_id
  AND (up.wins IS NULL OR up.total_matches IS NULL OR ps.wins > up.wins OR ps.total_matches > up.total_matches);

-- Eğer farklılık varsa max değeri al (safety)
UPDATE user_photos up
SET
  wins = GREATEST(up.wins, ps.wins),
  total_matches = GREATEST(up.total_matches, ps.total_matches),
  updated_at = NOW()
FROM photo_stats ps
WHERE up.id = ps.photo_id;

-- photo_stats tablosunu sil
DROP TABLE IF EXISTS photo_stats CASCADE;

-- ===========================================
-- AŞAMA 1 TAMAMLANDI - DOĞRULAMA
-- ===========================================

-- Doğrulama sorguları:
SELECT 'Phase 1: Critical Fixes' AS phase, 'COMPLETED' AS status;

-- Function'ları kontrol et
SELECT 'Functions Created' AS check_type, COUNT(*) AS count
FROM pg_proc
WHERE proname IN ('update_user_coins', 'update_user_stats', 'join_tournament');

-- Foreign key'leri kontrol et
SELECT 'Foreign Keys' AS check_type, COUNT(*) AS count
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
  AND constraint_name LIKE '%_user_id_fkey';

-- Unique constraint kontrol et
SELECT 'Unique Constraints' AS check_type, COUNT(*) AS count
FROM information_schema.table_constraints
WHERE constraint_type = 'UNIQUE'
  AND constraint_name = 'user_photos_user_photo_order_unique';

-- photo_stats silinmiş mi?
SELECT 'photo_stats Deleted' AS check_type,
  CASE WHEN COUNT(*) = 0 THEN 'SUCCESS' ELSE 'FAILED' END AS status
FROM information_schema.tables
WHERE table_name = 'photo_stats';

-- ========================================
-- AŞAMA 1 TAMAMLANDI ✅
-- ========================================
-- Sonraki adım: AŞAMA2_PERFORMANCE_FIXES.sql
-- ========================================
