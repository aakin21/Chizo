-- ========================================
-- CHIZO DATABASE - AŞAMA 1: KRİTİK DÜZELTMELER (SAFE VERSION)
-- ========================================
-- Tarih: 2025-10-21
-- Süre: ~2 saat
-- Kritiklik: 🔴 YÜKSEK
--
-- ⚠️ UYARI: Bu script çalıştırılmadan önce DATABASE BACKUP ALIN!
--
-- Bu versiyon "already exists" hatalarını önler
--
-- ========================================

-- ===========================================
-- 0. ESKİ FONKSİYONLARI VE CONSTRAINT'LERİ TEMİZLE
-- ===========================================

-- Eski fonksiyonları sil (varsa)
DROP FUNCTION IF EXISTS update_user_coins(UUID, INTEGER, VARCHAR, TEXT) CASCADE;
DROP FUNCTION IF EXISTS update_user_stats(UUID, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS join_tournament(UUID, UUID, UUID) CASCADE;

-- ===========================================
-- 1. ATOMIC COIN UPDATE FUNCTION (Race Condition Fix)
-- ===========================================

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

COMMENT ON FUNCTION update_user_coins IS 'Atomically updates user coins and creates transaction record. Prevents race conditions.';

-- ===========================================
-- 2. ATOMIC USER STATS UPDATE FUNCTION (Race Condition Fix)
-- ===========================================

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

COMMENT ON FUNCTION update_user_stats IS 'Atomically updates user match statistics. Prevents race conditions.';

-- ===========================================
-- 3. ATOMIC TOURNAMENT JOIN FUNCTION (Race Condition Fix)
-- ===========================================

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

COMMENT ON FUNCTION join_tournament IS 'Atomically handles tournament join with validation. Prevents overbooking.';

-- ===========================================
-- 4. ADD FOREIGN KEY: notifications.user_id (SAFE)
-- ===========================================

-- Önce constraint var mı kontrol et
DO $$
BEGIN
  -- Constraint yoksa ekle
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'notifications_user_id_fkey'
    AND table_name = 'notifications'
  ) THEN
    -- Önce orphaned records'ları temizle
    DELETE FROM notifications
    WHERE user_id NOT IN (SELECT id FROM users);

    -- Foreign key ekle
    ALTER TABLE notifications
    ADD CONSTRAINT notifications_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

    RAISE NOTICE 'notifications_user_id_fkey constraint added';
  ELSE
    RAISE NOTICE 'notifications_user_id_fkey constraint already exists';
  END IF;
END $$;

-- ===========================================
-- 5. ADD UNIQUE CONSTRAINT: user_photos(user_id, photo_order) (SAFE)
-- ===========================================

DO $$
BEGIN
  -- Constraint yoksa ekle
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'user_photos_user_photo_order_unique'
    AND table_name = 'user_photos'
  ) THEN
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

    RAISE NOTICE 'user_photos_user_photo_order_unique constraint added';
  ELSE
    RAISE NOTICE 'user_photos_user_photo_order_unique constraint already exists';
  END IF;
END $$;

-- ===========================================
-- 6. CASCADE DELETE DÜZELTMELERI (SAFE)
-- ===========================================

-- Helper function: Constraint'i güvenli şekilde değiştir
CREATE OR REPLACE FUNCTION update_fk_cascade(
  p_table_name TEXT,
  p_constraint_name TEXT,
  p_column_name TEXT,
  p_referenced_table TEXT
) RETURNS VOID AS $$
BEGIN
  -- Eski constraint'i sil (varsa)
  EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I', p_table_name, p_constraint_name);

  -- Yeni constraint'i CASCADE ile ekle
  EXECUTE format(
    'ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I(id) ON DELETE CASCADE',
    p_table_name, p_constraint_name, p_column_name, p_referenced_table
  );

  RAISE NOTICE 'Updated constraint: %', p_constraint_name;
END;
$$ LANGUAGE plpgsql;

-- 6.1. coin_transactions.user_id
SELECT update_fk_cascade('coin_transactions', 'coin_transactions_user_id_fkey', 'user_id', 'users');

-- 6.2. votes.voter_id
SELECT update_fk_cascade('votes', 'votes_voter_id_fkey', 'voter_id', 'users');

-- 6.3. reports.reporter_id
SELECT update_fk_cascade('reports', 'reports_reporter_id_fkey', 'reporter_id', 'users');

-- 6.4. reports.reported_user_id
SELECT update_fk_cascade('reports', 'reports_reported_user_id_fkey', 'reported_user_id', 'users');

-- 6.5. tournament_participants.user_id
SELECT update_fk_cascade('tournament_participants', 'tournament_participants_user_id_fkey', 'user_id', 'users');

-- 6.6. user_photos.user_id
SELECT update_fk_cascade('user_photos', 'user_photos_user_id_fkey', 'user_id', 'users');

-- 6.7. winrate_predictions.user_id
SELECT update_fk_cascade('winrate_predictions', 'winrate_predictions_user_id_fkey', 'user_id', 'users');

-- 6.8. private_tournament_votes.voter_id
SELECT update_fk_cascade('private_tournament_votes', 'private_tournament_votes_voter_id_fkey', 'voter_id', 'users');

-- 6.9. tournament_votes.voter_id
SELECT update_fk_cascade('tournament_votes', 'tournament_votes_voter_id_fkey', 'voter_id', 'users');

-- 6.10. user_country_stats.user_id
SELECT update_fk_cascade('user_country_stats', 'user_country_stats_user_id_fkey', 'user_id', 'users');

-- 6.11. user_tokens.user_id
SELECT update_fk_cascade('user_tokens', 'user_tokens_user_id_fkey', 'user_id', 'users');

-- Helper function'ı temizle
DROP FUNCTION IF EXISTS update_fk_cascade(TEXT, TEXT, TEXT, TEXT);

-- ===========================================
-- 7. PHOTO_STATS TABLOSU MİGRASYON VE SİLME (SAFE)
-- ===========================================

DO $$
BEGIN
  -- photo_stats tablosu varsa migrate et ve sil
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'photo_stats'
  ) THEN
    -- Önce user_photos'daki eksik verileri photo_stats'tan güncelle
    UPDATE user_photos up
    SET
      wins = GREATEST(COALESCE(up.wins, 0), COALESCE(ps.wins, 0)),
      total_matches = GREATEST(COALESCE(up.total_matches, 0), COALESCE(ps.total_matches, 0)),
      updated_at = NOW()
    FROM photo_stats ps
    WHERE up.id = ps.photo_id;

    -- photo_stats tablosunu sil
    DROP TABLE photo_stats CASCADE;

    RAISE NOTICE 'photo_stats table migrated and dropped';
  ELSE
    RAISE NOTICE 'photo_stats table does not exist (already deleted or never existed)';
  END IF;
END $$;

-- ===========================================
-- AŞAMA 1 TAMAMLANDI - DOĞRULAMA
-- ===========================================

SELECT 'Phase 1: Critical Fixes' AS phase, 'COMPLETED' AS status;

-- Function'ları kontrol et
SELECT 'Functions Created' AS check_type, COUNT(*) AS count
FROM pg_proc
WHERE proname IN ('update_user_coins', 'update_user_stats', 'join_tournament');

-- Foreign key'leri kontrol et (CASCADE DELETE olanlar)
SELECT
  'Foreign Keys with CASCADE DELETE' AS check_type,
  tc.table_name,
  tc.constraint_name,
  rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.referential_constraints rc
  ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND rc.delete_rule = 'CASCADE'
  AND tc.table_name IN (
    'coin_transactions', 'votes', 'reports', 'tournament_participants',
    'user_photos', 'user_tokens', 'winrate_predictions',
    'private_tournament_votes', 'tournament_votes', 'user_country_stats', 'notifications'
  )
ORDER BY tc.table_name;

-- Unique constraint kontrol et
SELECT 'Unique Constraints' AS check_type, COUNT(*) AS count
FROM information_schema.table_constraints
WHERE constraint_type = 'UNIQUE'
  AND constraint_name = 'user_photos_user_photo_order_unique';

-- photo_stats silinmiş mi?
SELECT 'photo_stats Deleted' AS check_type,
  CASE WHEN COUNT(*) = 0 THEN 'SUCCESS - Table does not exist' ELSE 'FAILED - Table still exists' END AS status
FROM information_schema.tables
WHERE table_name = 'photo_stats';

-- ========================================
-- AŞAMA 1 TAMAMLANDI ✅
-- ========================================
-- Sonraki adım: AŞAMA2_PERFORMANCE_FIXES.sql
-- ========================================
