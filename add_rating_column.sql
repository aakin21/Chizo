-- Add rating column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS rating INTEGER DEFAULT 1000;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_users_rating ON users(rating DESC);
CREATE INDEX IF NOT EXISTS idx_users_wins ON users(wins DESC);
CREATE INDEX IF NOT EXISTS idx_users_total_matches ON users(total_matches DESC);
