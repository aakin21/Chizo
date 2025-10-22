-- ========================================
-- CHIZO DATABASE - AŞAMA 1: KRİTİK DÜZELTMELER (FINAL VERSION)
-- ========================================
-- Tarih: 2025-10-21
-- Kritiklik: 🔴 YÜKSEK
--
-- Bu versiyon orphaned records'ları otomatik temizler
--
-- ========================================

-- ===========================================
-- 0. ESKİ FONKSİYONLARI TEMİZLE
-- ===========================================

DROP FUNCTION IF EXISTS update_user_coins(UUID, INTEGER, VARCHAR, TEXT) CASCADE;
DROP FUNCTION IF EXISTS update_user_stats(UUID, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS join_tournament(UUID, UUID, UUID) CASCADE;

-- ===========================================
-- 1. ATOMIC COIN UPDATE FUNCTION
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
  UPDATE users
  SET coins = coins + p_amount, updated_at = NOW()
  WHERE id = p_user_id
  RETURNING coins INTO v_new_amount;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  IF v_new_amount < 0 THEN
    RAISE EXCEPTION 'Insufficient coins. Current: %, Requested: %', v_new_amount - p_amount, p_amount;
  END IF;

  INSERT INTO coin_transactions (user_id, amount, type, description, created_at)
  VALUES (p_user_id, p_amount, p_transaction_type, p_description, NOW())
  RETURNING id INTO v_transaction_id;

  RETURN QUERY SELECT v_new_amount, v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- 2. ATOMIC USER STATS UPDATE FUNCTION
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
  UPDATE users
  SET
    total_matches = total_matches + 1,
    wins = CASE WHEN p_is_winner THEN wins + 1 ELSE wins END,
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING total_matches, wins INTO v_total_matches, v_wins;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  IF v_total_matches > 0 THEN
    v_win_rate := (v_wins::DECIMAL / v_total_matches) * 100;
  ELSE
    v_win_rate := 0;
  END IF;

  RETURN QUERY SELECT v_total_matches, v_wins, v_win_rate;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- 3. ATOMIC TOURNAMENT JOIN FUNCTION
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
  SELECT max_participants, current_participants, entry_fee, status
  INTO v_max_participants, v_current_participants, v_entry_fee, v_status
  FROM tournaments
  WHERE id = p_tournament_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Tournament not found', 0;
    RETURN;
  END IF;

  IF v_status != 'registration' AND v_status != 'active' THEN
    RETURN QUERY SELECT false, 'Tournament is not open for registration', v_current_participants;
    RETURN;
  END IF;

  IF v_current_participants >= v_max_participants THEN
    RETURN QUERY SELECT false, 'Tournament is full', v_current_participants;
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1 FROM tournament_participants
    WHERE tournament_id = p_tournament_id AND user_id = p_user_id
  ) THEN
    RETURN QUERY SELECT false, 'User already joined this tournament', v_current_participants;
    RETURN;
  END IF;

  SELECT coins INTO v_user_coins FROM users WHERE id = p_user_id;
  IF v_user_coins < v_entry_fee THEN
    RETURN QUERY SELECT false, 'Insufficient coins', v_current_participants;
    RETURN;
  END IF;

  IF v_entry_fee > 0 THEN
    UPDATE users SET coins = coins - v_entry_fee, updated_at = NOW() WHERE id = p_user_id;
    INSERT INTO coin_transactions (user_id, amount, type, description, created_at)
    VALUES (p_user_id, -v_entry_fee, 'spent', 'Tournament entry fee', NOW());
  END IF;

  INSERT INTO tournament_participants (tournament_id, user_id, photo_id, score, joined_at)
  VALUES (p_tournament_id, p_user_id, p_photo_id, 0, NOW());

  UPDATE tournaments
  SET current_participants = current_participants + 1, updated_at = NOW()
  WHERE id = p_tournament_id
  RETURNING current_participants INTO v_current_participants;

  RETURN QUERY SELECT true, 'Successfully joined tournament', v_current_participants;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- 4. ORPHANED RECORDS TEMİZLİĞİ (ÖNEMLİ!)
-- ===========================================

DO $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  RAISE NOTICE 'Cleaning orphaned records...';

  -- notifications
  DELETE FROM notifications WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned notifications', v_deleted_count;

  -- coin_transactions
  DELETE FROM coin_transactions WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned coin_transactions', v_deleted_count;

  -- votes
  DELETE FROM votes WHERE voter_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned votes', v_deleted_count;

  -- reports (reporter_id)
  DELETE FROM reports WHERE reporter_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned reports (reporter)', v_deleted_count;

  -- reports (reported_user_id)
  DELETE FROM reports WHERE reported_user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned reports (reported user)', v_deleted_count;

  -- tournament_participants
  DELETE FROM tournament_participants WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned tournament_participants', v_deleted_count;

  -- user_photos
  DELETE FROM user_photos WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned user_photos', v_deleted_count;

  -- winrate_predictions (ÖNEMLİ!)
  DELETE FROM winrate_predictions WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned winrate_predictions', v_deleted_count;

  -- private_tournament_votes
  DELETE FROM private_tournament_votes WHERE voter_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned private_tournament_votes', v_deleted_count;

  -- tournament_votes
  DELETE FROM tournament_votes WHERE voter_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned tournament_votes', v_deleted_count;

  -- user_country_stats
  DELETE FROM user_country_stats WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned user_country_stats', v_deleted_count;

  -- user_tokens
  DELETE FROM user_tokens WHERE user_id NOT IN (SELECT id FROM users);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % orphaned user_tokens', v_deleted_count;

  RAISE NOTICE 'Orphaned records cleanup completed!';
END $$;

-- ===========================================
-- 5. FOREIGN KEY: notifications.user_id
-- ===========================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'notifications_user_id_fkey' AND table_name = 'notifications'
  ) THEN
    ALTER TABLE notifications
    ADD CONSTRAINT notifications_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    RAISE NOTICE 'Added notifications_user_id_fkey';
  ELSE
    -- Mevcut constraint'i CASCADE ile güncelle
    ALTER TABLE notifications DROP CONSTRAINT notifications_user_id_fkey;
    ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_fkey
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    RAISE NOTICE 'Updated notifications_user_id_fkey with CASCADE';
  END IF;
END $$;

-- ===========================================
-- 6. UNIQUE CONSTRAINT: user_photos
-- ===========================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'user_photos_user_photo_order_unique'
  ) THEN
    -- Duplicate temizle
    WITH duplicates AS (
      SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id, photo_order ORDER BY created_at DESC) AS rn
      FROM user_photos
    )
    DELETE FROM user_photos WHERE id IN (SELECT id FROM duplicates WHERE rn > 1);

    ALTER TABLE user_photos ADD CONSTRAINT user_photos_user_photo_order_unique UNIQUE (user_id, photo_order);
    RAISE NOTICE 'Added user_photos_user_photo_order_unique';
  ELSE
    RAISE NOTICE 'user_photos_user_photo_order_unique already exists';
  END IF;
END $$;

-- ===========================================
-- 7. CASCADE DELETE DÜZELTMELERI
-- ===========================================

-- coin_transactions
ALTER TABLE coin_transactions DROP CONSTRAINT IF EXISTS coin_transactions_user_id_fkey;
ALTER TABLE coin_transactions ADD CONSTRAINT coin_transactions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- votes
ALTER TABLE votes DROP CONSTRAINT IF EXISTS votes_voter_id_fkey;
ALTER TABLE votes ADD CONSTRAINT votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- reports (reporter)
ALTER TABLE reports DROP CONSTRAINT IF EXISTS reports_reporter_id_fkey;
ALTER TABLE reports ADD CONSTRAINT reports_reporter_id_fkey
  FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE;

-- reports (reported user)
ALTER TABLE reports DROP CONSTRAINT IF EXISTS reports_reported_user_id_fkey;
ALTER TABLE reports ADD CONSTRAINT reports_reported_user_id_fkey
  FOREIGN KEY (reported_user_id) REFERENCES users(id) ON DELETE CASCADE;

-- tournament_participants
ALTER TABLE tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_user_id_fkey;
ALTER TABLE tournament_participants ADD CONSTRAINT tournament_participants_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- user_photos
ALTER TABLE user_photos DROP CONSTRAINT IF EXISTS user_photos_user_id_fkey;
ALTER TABLE user_photos ADD CONSTRAINT user_photos_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- winrate_predictions
ALTER TABLE winrate_predictions DROP CONSTRAINT IF EXISTS winrate_predictions_user_id_fkey;
ALTER TABLE winrate_predictions ADD CONSTRAINT winrate_predictions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- private_tournament_votes
ALTER TABLE private_tournament_votes DROP CONSTRAINT IF EXISTS private_tournament_votes_voter_id_fkey;
ALTER TABLE private_tournament_votes ADD CONSTRAINT private_tournament_votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- tournament_votes
ALTER TABLE tournament_votes DROP CONSTRAINT IF EXISTS tournament_votes_voter_id_fkey;
ALTER TABLE tournament_votes ADD CONSTRAINT tournament_votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- user_country_stats
ALTER TABLE user_country_stats DROP CONSTRAINT IF EXISTS user_country_stats_user_id_fkey;
ALTER TABLE user_country_stats ADD CONSTRAINT user_country_stats_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- user_tokens
ALTER TABLE user_tokens DROP CONSTRAINT IF EXISTS user_tokens_user_id_fkey;
ALTER TABLE user_tokens ADD CONSTRAINT user_tokens_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- ===========================================
-- 8. PHOTO_STATS MİGRASYON
-- ===========================================

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'photo_stats') THEN
    UPDATE user_photos up
    SET
      wins = GREATEST(COALESCE(up.wins, 0), COALESCE(ps.wins, 0)),
      total_matches = GREATEST(COALESCE(up.total_matches, 0), COALESCE(ps.total_matches, 0)),
      updated_at = NOW()
    FROM photo_stats ps
    WHERE up.id = ps.photo_id;

    DROP TABLE photo_stats CASCADE;
    RAISE NOTICE 'photo_stats migrated and dropped';
  ELSE
    RAISE NOTICE 'photo_stats already deleted';
  END IF;
END $$;

-- ===========================================
-- DOĞRULAMA
-- ===========================================

SELECT '✅ AŞAMA 1 TAMAMLANDI' AS status;

-- Functions
SELECT 'Functions' AS check_type, COUNT(*) AS count
FROM pg_proc WHERE proname IN ('update_user_coins', 'update_user_stats', 'join_tournament');

-- CASCADE DELETE foreign keys
SELECT 'CASCADE DELETE FKs' AS check_type, COUNT(*) AS count
FROM information_schema.referential_constraints
WHERE delete_rule = 'CASCADE';

-- Unique constraint
SELECT 'Unique Constraints' AS check_type, COUNT(*) AS count
FROM information_schema.table_constraints
WHERE constraint_name = 'user_photos_user_photo_order_unique';

-- photo_stats check
SELECT 'photo_stats Deleted' AS check_type,
  CASE WHEN COUNT(*) = 0 THEN '✅ SUCCESS' ELSE '❌ FAILED' END AS status
FROM information_schema.tables WHERE table_name = 'photo_stats';
