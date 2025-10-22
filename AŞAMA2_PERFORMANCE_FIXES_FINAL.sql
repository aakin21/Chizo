-- ========================================
-- CHIZO DATABASE - AŞAMA 2: PERFORMANS İYİLEŞTİRMELERİ (FINAL)
-- ========================================
-- Tarih: 2025-10-21
-- Süre: ~2 saat
-- Kritiklik: 🟡 ORTA
--
-- Önkoşul: AŞAMA1_KRITIK_FIXES_FINAL.sql başarıyla çalıştırılmış olmalı
--
-- ========================================

-- ===========================================
-- 0. SORUNLU KAYITLARI TEMİZLE
-- ===========================================

DO $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  RAISE NOTICE 'Cleaning invalid records...';

  -- amount = 0 olan coin_transactions kayıtlarını sil
  DELETE FROM coin_transactions WHERE amount = 0;
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % coin_transactions with amount = 0', v_deleted_count;

  -- Negatif coins olan kullanıcıları düzelt
  UPDATE users SET coins = 0 WHERE coins < 0;
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Fixed % users with negative coins', v_deleted_count;

  -- age > 99 veya age < 18 olanları NULL yap
  UPDATE users SET age = NULL WHERE age IS NOT NULL AND (age < 18 OR age > 99);
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Fixed % users with invalid age', v_deleted_count;

  -- Negatif score olan tournament_participants düzelt
  UPDATE tournament_participants SET score = 0 WHERE score < 0;
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Fixed % tournament_participants with negative score', v_deleted_count;

  -- Negatif coins olan payments düzelt
  UPDATE payments SET coins = 1 WHERE coins <= 0;
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE 'Fixed % payments with non-positive coins', v_deleted_count;

  RAISE NOTICE 'Invalid records cleanup completed!';
END $$;

-- ===========================================
-- 1. MISSING INDEXES
-- ===========================================

-- 1.1. REPORTS TABLOSU
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported_user_id ON reports(reported_user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- 1.2. VOTES TABLOSU
CREATE INDEX IF NOT EXISTS idx_votes_winner_id ON votes(winner_id);

-- 1.3. TOURNAMENTS TABLOSU
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_gender ON tournaments(gender);
CREATE INDEX IF NOT EXISTS idx_tournaments_creator_id ON tournaments(creator_id);
CREATE INDEX IF NOT EXISTS idx_tournaments_is_private ON tournaments(is_private);
CREATE INDEX IF NOT EXISTS idx_tournaments_start_date ON tournaments(start_date);
CREATE INDEX IF NOT EXISTS idx_tournaments_end_date ON tournaments(end_date);

-- 1.4. MATCHES TABLOSU
CREATE INDEX IF NOT EXISTS idx_matches_is_completed ON matches(is_completed);
CREATE INDEX IF NOT EXISTS idx_matches_created_at ON matches(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_matches_completed_at ON matches(completed_at DESC);

-- 1.5. PAYMENTS TABLOSU
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at DESC);

-- 1.6. DUPLICATE INDEX TEMİZLİĞİ
DROP INDEX IF EXISTS idx_notifications_read;

-- ===========================================
-- 2. CHECK CONSTRAINTS
-- ===========================================

-- 2.1. USERS TABLOSU
DO $$
BEGIN
  -- Age validation
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_user_age' AND table_name = 'users'
  ) THEN
    ALTER TABLE users ADD CONSTRAINT check_user_age
      CHECK (age IS NULL OR (age >= 18 AND age <= 99));
    RAISE NOTICE 'Added check_user_age';
  END IF;

  -- Coins non-negative
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_user_coins' AND table_name = 'users'
  ) THEN
    ALTER TABLE users ADD CONSTRAINT check_user_coins CHECK (coins >= 0);
    RAISE NOTICE 'Added check_user_coins';
  END IF;

  -- Username length
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_username_length' AND table_name = 'users'
  ) THEN
    ALTER TABLE users ADD CONSTRAINT check_username_length
      CHECK (length(username) >= 3 AND length(username) <= 20);
    RAISE NOTICE 'Added check_username_length';
  END IF;
END $$;

-- 2.2. COIN_TRANSACTIONS TABLOSU
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_amount_not_zero' AND table_name = 'coin_transactions'
  ) THEN
    ALTER TABLE coin_transactions ADD CONSTRAINT check_amount_not_zero CHECK (amount != 0);
    RAISE NOTICE 'Added check_amount_not_zero';
  END IF;
END $$;

-- 2.3. TOURNAMENTS TABLOSU
DO $$
BEGIN
  -- End date > start date
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_tournament_dates' AND table_name = 'tournaments'
  ) THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_tournament_dates CHECK (end_date > start_date);
    RAISE NOTICE 'Added check_tournament_dates';
  END IF;

  -- Entry fee non-negative
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_entry_fee' AND table_name = 'tournaments'
  ) THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_entry_fee CHECK (entry_fee >= 0);
    RAISE NOTICE 'Added check_entry_fee';
  END IF;

  -- Max participants positive
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_max_participants' AND table_name = 'tournaments'
  ) THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_max_participants CHECK (max_participants > 0);
    RAISE NOTICE 'Added check_max_participants';
  END IF;

  -- Current participants <= max
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_current_participants_limit' AND table_name = 'tournaments'
  ) THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_current_participants_limit
      CHECK (current_participants <= max_participants);
    RAISE NOTICE 'Added check_current_participants_limit';
  END IF;
END $$;

-- 2.4. TOURNAMENT_PARTICIPANTS TABLOSU
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_score_positive' AND table_name = 'tournament_participants'
  ) THEN
    ALTER TABLE tournament_participants ADD CONSTRAINT check_score_positive CHECK (score >= 0);
    RAISE NOTICE 'Added check_score_positive';
  END IF;
END $$;

-- 2.5. PAYMENTS TABLOSU
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'check_coins_positive' AND table_name = 'payments'
  ) THEN
    ALTER TABLE payments ADD CONSTRAINT check_coins_positive CHECK (coins > 0);
    RAISE NOTICE 'Added check_coins_positive';
  END IF;
END $$;

-- ===========================================
-- 3. user_photos.photo_order NULL FIX
-- ===========================================

DO $$
BEGIN
  -- NULL değerleri düzelt
  UPDATE user_photos SET photo_order = 1 WHERE photo_order IS NULL;

  -- NOT NULL constraint ekle
  ALTER TABLE user_photos ALTER COLUMN photo_order SET NOT NULL;

  -- Default value ekle
  ALTER TABLE user_photos ALTER COLUMN photo_order SET DEFAULT 1;

  RAISE NOTICE 'user_photos.photo_order NULL fix completed';
END $$;

-- ===========================================
-- 4. COUNTRY NORMALIZATION
-- ===========================================

DO $$
BEGIN
  -- Eğer country kolonu varsa ve country_code yoksa
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_country_stats' AND column_name = 'country'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_country_stats' AND column_name = 'country_code'
  ) THEN
    -- country_code kolonu ekle
    ALTER TABLE user_country_stats ADD COLUMN country_code TEXT;

    -- Mevcut country değerlerini kopyala
    UPDATE user_country_stats SET country_code = country;

    -- Eski country kolonunu sil
    ALTER TABLE user_country_stats DROP COLUMN country;

    -- Foreign key ekle
    ALTER TABLE user_country_stats ADD CONSTRAINT user_country_stats_country_fkey
      FOREIGN KEY (country_code) REFERENCES countries(code);

    -- NOT NULL
    ALTER TABLE user_country_stats ALTER COLUMN country_code SET NOT NULL;

    -- Index ekle
    CREATE INDEX idx_user_country_stats_country ON user_country_stats(country_code);

    RAISE NOTICE 'Country normalization completed';
  ELSE
    RAISE NOTICE 'Country already normalized or already has country_code';
  END IF;
END $$;

-- ===========================================
-- 5. COMPOSITE INDEXES (Partial)
-- ===========================================

-- 5.1. Completed matches by date
CREATE INDEX IF NOT EXISTS idx_matches_completed_date
ON matches(is_completed, created_at DESC)
WHERE is_completed = true;

-- 5.2. Active tournaments by gender
CREATE INDEX IF NOT EXISTS idx_tournaments_active_gender
ON tournaments(status, gender, start_date)
WHERE status = 'active';

-- 5.3. Unread notifications
CREATE INDEX IF NOT EXISTS idx_notifications_unread_user
ON notifications(user_id, created_at DESC)
WHERE is_read = false;

-- 5.4. User voting history
CREATE INDEX IF NOT EXISTS idx_votes_voter_created
ON votes(voter_id, created_at DESC);

-- 5.5. Active user photos
CREATE INDEX IF NOT EXISTS idx_user_photos_active
ON user_photos(user_id, photo_order)
WHERE is_active = true;

-- ===========================================
-- 6. ANALYZE (Performans için)
-- ===========================================

ANALYZE users;
ANALYZE coin_transactions;
ANALYZE tournaments;
ANALYZE tournament_participants;
ANALYZE matches;
ANALYZE votes;
ANALYZE reports;
ANALYZE payments;
ANALYZE notifications;
ANALYZE user_photos;
ANALYZE user_country_stats;

-- ===========================================
-- DOĞRULAMA
-- ===========================================

SELECT '✅ AŞAMA 2 TAMAMLANDI' AS status;

-- Indexes
SELECT 'Total Indexes' AS check_type, COUNT(*) AS count
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('reports', 'votes', 'tournaments', 'matches', 'payments', 'notifications', 'user_photos');

-- Check constraints
SELECT 'Check Constraints' AS check_type, COUNT(*) AS count
FROM information_schema.table_constraints
WHERE constraint_type = 'CHECK'
  AND table_name IN ('users', 'coin_transactions', 'tournaments', 'tournament_participants', 'payments');

-- photo_order NULL check
SELECT 'photo_order NOT NULL' AS check_type,
  CASE WHEN is_nullable = 'NO' THEN '✅ SUCCESS' ELSE '❌ FAILED' END AS status
FROM information_schema.columns
WHERE table_name = 'user_photos' AND column_name = 'photo_order';

-- Country normalization
SELECT 'Country Normalization' AS check_type,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_country_stats' AND column_name = 'country_code'
  ) THEN '✅ SUCCESS' ELSE '❌ FAILED' END AS status;

-- ========================================
-- AŞAMA 2 TAMAMLANDI ✅
-- ========================================
