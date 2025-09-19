-- Basit temizleme scripti
-- Bu scripti Supabase SQL Editor'de çalıştır

-- 1. Tüm foreign key constraint'leri kaldır
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_user1_id_fkey;
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_user2_id_fkey;
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_winner_id_fkey;
ALTER TABLE coin_transactions DROP CONSTRAINT IF EXISTS coin_transactions_user_id_fkey;
ALTER TABLE tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_user_id_fkey;
ALTER TABLE votes DROP CONSTRAINT IF EXISTS votes_user_id_fkey;

-- 2. Tüm tabloları temizle
TRUNCATE TABLE matches CASCADE;
TRUNCATE TABLE coin_transactions CASCADE;
TRUNCATE TABLE tournament_participants CASCADE;
TRUNCATE TABLE votes CASCADE;
TRUNCATE TABLE users CASCADE;

-- 3. Users tablosunu yeniden oluştur
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id UUID UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  username TEXT NOT NULL,
  coins INTEGER DEFAULT 100,
  age INTEGER,
  country TEXT,
  gender TEXT,
  instagram_handle TEXT,
  profession TEXT,
  profile_image_url TEXT,
  is_visible BOOLEAN DEFAULT true,
  total_matches INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Foreign key constraint'leri yeniden ekle
ALTER TABLE matches ADD CONSTRAINT matches_user1_id_fkey 
  FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE matches ADD CONSTRAINT matches_user2_id_fkey 
  FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE matches ADD CONSTRAINT matches_winner_id_fkey 
  FOREIGN KEY (winner_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE coin_transactions ADD CONSTRAINT coin_transactions_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE tournament_participants ADD CONSTRAINT tournament_participants_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE votes ADD CONSTRAINT votes_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 5. Index'ler ekle
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON users(auth_id);
CREATE INDEX IF NOT EXISTS idx_matches_user1_id ON matches(user1_id);
CREATE INDEX IF NOT EXISTS idx_matches_user2_id ON matches(user2_id);
CREATE INDEX IF NOT EXISTS idx_matches_winner_id ON matches(winner_id);
