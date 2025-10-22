-- AŞAMA 2: PERFORMANS - FINAL
-- NULL photo_order kayıtlarını SİL (5 slot sınırı var)

-- 0. Temizlik
DELETE FROM coin_transactions WHERE amount = 0;
UPDATE users SET coins = 0 WHERE coins < 0;
UPDATE users SET age = NULL WHERE age < 18 OR age > 99;
UPDATE tournament_participants SET score = 0 WHERE score < 0;
UPDATE payments SET coins = 1 WHERE coins <= 0;

-- NULL photo_order kayıtlarını SİL
DELETE FROM user_photos WHERE photo_order IS NULL;

-- 1. Indexes
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported_user_id ON reports(reported_user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_votes_winner_id ON votes(winner_id);
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_gender ON tournaments(gender);
CREATE INDEX IF NOT EXISTS idx_tournaments_creator_id ON tournaments(creator_id);
CREATE INDEX IF NOT EXISTS idx_tournaments_is_private ON tournaments(is_private);
CREATE INDEX IF NOT EXISTS idx_tournaments_start_date ON tournaments(start_date);
CREATE INDEX IF NOT EXISTS idx_tournaments_end_date ON tournaments(end_date);
CREATE INDEX IF NOT EXISTS idx_matches_is_completed ON matches(is_completed);
CREATE INDEX IF NOT EXISTS idx_matches_created_at ON matches(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_matches_completed_at ON matches(completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at DESC);
DROP INDEX IF EXISTS idx_notifications_read;

-- 2. Check Constraints
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_user_age') THEN
    ALTER TABLE users ADD CONSTRAINT check_user_age CHECK (age IS NULL OR (age >= 18 AND age <= 99));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_user_coins') THEN
    ALTER TABLE users ADD CONSTRAINT check_user_coins CHECK (coins >= 0);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_username_length') THEN
    ALTER TABLE users ADD CONSTRAINT check_username_length CHECK (length(username) >= 3 AND length(username) <= 20);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_amount_not_zero') THEN
    ALTER TABLE coin_transactions ADD CONSTRAINT check_amount_not_zero CHECK (amount != 0);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_tournament_dates') THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_tournament_dates CHECK (end_date > start_date);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_entry_fee') THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_entry_fee CHECK (entry_fee >= 0);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_max_participants') THEN
    ALTER TABLE tournaments ADD CONSTRAINT check_max_participants CHECK (max_participants > 0);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_score_positive') THEN
    ALTER TABLE tournament_participants ADD CONSTRAINT check_score_positive CHECK (score >= 0);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_coins_positive') THEN
    ALTER TABLE payments ADD CONSTRAINT check_coins_positive CHECK (coins > 0);
  END IF;
END $$;

-- 3. photo_order NOT NULL
ALTER TABLE user_photos ALTER COLUMN photo_order SET NOT NULL;
ALTER TABLE user_photos ALTER COLUMN photo_order SET DEFAULT 1;

-- 4. Composite Indexes
CREATE INDEX IF NOT EXISTS idx_matches_completed_date ON matches(is_completed, created_at DESC) WHERE is_completed = true;
CREATE INDEX IF NOT EXISTS idx_tournaments_active_gender ON tournaments(status, gender, start_date) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_notifications_unread_user ON notifications(user_id, created_at DESC) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_votes_voter_created ON votes(voter_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_photos_active ON user_photos(user_id, photo_order) WHERE is_active = true;

ANALYZE;

SELECT 'AŞAMA 2 TAMAMLANDI' AS status;
