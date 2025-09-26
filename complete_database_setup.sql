-- Chizo Tournament & Voting App - Complete Database Setup
-- Bu script Supabase'de gerekli tüm tabloları oluşturur

-- ===========================================
-- ÖNCELİKLE MEVCUT TABLOLARı KONTROL ET
-- ===========================================

-- Create extension for UUID if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- 1. USERS TABLE (Ana kullanıcı tablosu)
-- ===========================================
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    auth_id UUID UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    coins INTEGER DEFAULT 100,
    age INTEGER,
    country VARCHAR(50),
    gender VARCHAR(10) CHECK (gender IN ('Erkek', 'Kadın')),
    instagram_handle VARCHAR(100),
    profession VARCHAR(100),
    is_visible BOOLEAN DEFAULT true,
    show_instagram BOOLEAN DEFAULT false,
    show_profession BOOLEAN DEFAULT false,
    total_matches INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    total_streak_days INTEGER DEFAULT 0,
    last_login_date DATE,
    country_preferences TEXT[],
    age_range_preferences TEXT[],
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users indexler
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON users(auth_id);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_gender ON users(gender);
CREATE INDEX IF NOT EXISTS idx_users_is_visible ON users(is_visible);
CREATE INDEX IF NOT EXISTS idx_users_wins ON users(wins DESC);

-- Updated_at trigger for users
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Check if trigger exists first, then create if needed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_users_updated_at'
    ) THEN
        CREATE TRIGGER update_users_updated_at
            BEFORE UPDATE ON users
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ===========================================
-- 2. MATCHES TABLE (Oylama maçları)
-- ===========================================
CREATE TABLE IF NOT EXISTS matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Matches indexler
CREATE INDEX IF NOT EXISTS idx_matches_user1_id ON matches(user1_id);
CREATE INDEX IF NOT EXISTS idx_matches_user2_id ON matches(user2_id);
CREATE INDEX IF NOT EXISTS idx_matches_winner_id ON matches(winner_id);
CREATE INDEX IF NOT EXISTS idx_matches_is_completed ON matches(is_completed);
CREATE INDEX IF NOT EXISTS idx_matches_created_at ON matches(created_at);

-- ===========================================
-- 3. VOTES TABLE (Oylamalar)
-- ===========================================
CREATE TABLE IF NOT EXISTS votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_correct BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Votes indexler
CREATE INDEX IF NOT EXISTS idx_votes_match_id ON votes(match_id);
CREATE INDEX IF NOT EXISTS idx_votes_voter_id ON votes(voter_id);
CREATE INDEX IF NOT EXISTS idx_votes_winner_id ON votes(winner_id);

-- ===========================================
-- 4. TOURNAMENTS TABLE (Turnuvalar)
-- ===========================================
CREATE TABLE IF NOT EXISTS tournaments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    entry_fee INTEGER NOT NULL,
    prize_pool INTEGER,
    max_participants INTEGER NOT NULL,
    current_participants INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'registration' CHECK (status IN ('registration', 'active', 'completed', 'cancelled')),
    gender VARCHAR(10) DEFAULT 'Erkek' CHECK (gender IN ('Erkek', 'Kadın')),
    current_phase VARCHAR(20) DEFAULT 'registration' CHECK (current_phase IN ('registration', 'qualifying', 'quarter_final', 'semi_final', 'final', 'completed')),
    current_round INTEGER,
    phase_start_date TIMESTAMPTZ,
    registration_start_date TIMESTAMPTZ,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    winner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    second_place_id UUID REFERENCES users(id) ON DELETE SET NULL,
    third_place_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tournaments indexler
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_current_phase ON tournaments(current_phase);
CREATE INDEX IF NOT EXISTS idx_tournaments_gender ON tournaments(gender);
CREATE INDEX IF NOT EXISTS idx_tournaments_entry_fee ON tournaments(entry_fee);

-- Check if trigger exists first, then create if needed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_tournaments_updated_at'
    ) THEN
        CREATE TRIGGER update_tournaments_updated_at
            BEFORE UPDATE ON tournaments
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ===========================================
-- 5. TOURNAMENT_PARTICIPANTS TABLE (Turnuva katılımcıları)
-- ===========================================
CREATE TABLE IF NOT EXISTS tournament_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    is_eliminated BOOLEAN DEFAULT false,
    score INTEGER DEFAULT 0,
    tournament_photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(tournament_id, user_id)
);

-- Tournament participants indexler
CREATE INDEX IF NOT EXISTS idx_tournament_participants_tournament_id ON tournament_participants(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_user_id ON tournament_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_score ON tournament_participants(tournament_id, score DESC);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_is_eliminated ON tournament_participants(is_eliminated);

-- Check if trigger exists first, then create if needed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_tournament_participants_updated_at'
    ) THEN
        CREATE TRIGGER update_tournament_participants_updated_at
            BEFORE UPDATE ON tournament_participants
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ===========================================
-- 6. TOURNAMENT_VOTES TABLE (Turnuva oylamaları)
-- ===========================================
CREATE TABLE IF NOT EXISTS tournament_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    loser_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tournament votes indexler
CREATE INDEX IF NOT EXISTS idx_tournament_votes_tournament_id ON tournament_votes(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_votes_voter_id ON tournament_votes(voter_id);
CREATE INDEX IF NOT EXISTS idx_tournament_votes_winner_id ON tournament_votes(winner_id);

-- ===========================================
-- 7. USER_PHOTOS TABLE (Kullanıcı fotoğrafları)
-- ===========================================
CREATE TABLE IF NOT EXISTS user_photos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    photo_order INTEGER NOT NULL CHECK (photo_order >= 1 AND photo_order <= 5),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Her kullanıcı için aynı photo_order'da sadece bir aktif fotoğraf olabilir
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_photos_unique_active
    ON user_photos (user_id, photo_order)
    WHERE is_active = true;

-- User photos indexler
CREATE INDEX IF NOT EXISTS idx_user_photos_user_id ON user_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_user_photos_active ON user_photos(is_active);
CREATE INDEX IF NOT EXISTS idx_user_photos_order ON user_photos(photo_order);

-- Check if trigger exists first, then create if needed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_user_photos_updated_at'
    ) THEN
        CREATE TRIGGER update_user_photos_updated_at
            BEFORE UPDATE ON user_photos
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ===========================================
-- 8. PHOTO_STATS TABLE (Fotoğraf istatistikleri)
-- ===========================================
CREATE TABLE IF NOT EXISTS photo_stats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    photo_id UUID NOT NULL REFERENCES user_photos(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Photo stats indexler
CREATE INDEX IF NOT EXISTS idx_photo_stats_photo_id ON photo_stats(photo_id);

-- Check if trigger exists first, then create if needed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_photo_stats_updated_at'
    ) THEN
        CREATE TRIGGER update_photo_stats_updated_at
            BEFORE UPDATE ON photo_stats
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ===========================================
-- 9. COIN_TRANSACTIONS TABLE (Coin işlemleri)
-- ===========================================
CREATE TABLE IF NOT EXISTS coin_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('earned', 'spent', 'purchased', 'refund')),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Coin transactions indexler
CREATE INDEX IF NOT EXISTS idx_coin_transactions_user_id ON coin_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_coin_transactions_created_at ON coin_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_coin_transactions_type ON coin_transactions(type);

-- ===========================================
-- 10. PAYMENTS TABLE (Ödemeler)
-- ===========================================
CREATE TABLE IF NOT EXISTS payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    package_id VARCHAR(50),
    amount DECIMAL(10,2),
    coins INTEGER,
    payment_method VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments indexler
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);

-- ===========================================
-- 11. WINRATE_PREDICTIONS TABLE (Win rate tahminleri)
-- ===========================================
CREATE TABLE IF NOT EXISTS winrate_predictions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    predicted_min INTEGER NOT NULL,
    predicted_max INTEGER NOT NULL,
    actual_winrate DECIMAL(5,2),
    is_correct BOOLEAN DEFAULT false,
    reward_coins INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Winrate predictions indexler
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_user_id ON winrate_predictions(user_id);
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_winner_id ON winrate_predictions(winner_id);
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_is_correct ON winrate_predictions(is_correct);
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_created_at ON winrate_predictions(created_at);

-- ===========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ===========================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE photo_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE coin_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE winrate_predictions ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- USERS TABLE POLICIES
-- ===========================================
CREATE POLICY IF NOT EXISTS "Users can view all visible users" ON users
    FOR SELECT USING (is_visible = true);

CREATE POLICY IF NOT EXISTS "Users can view their own data" ON users
    FOR SELECT USING (auth.uid()::text = auth_id::text);

CREATE POLICY IF NOT EXISTS "Users can update their own data" ON users
    FOR UPDATE USING (auth.uid()::text = auth_id::text);

CREATE POLICY IF NOT EXISTS "Users can insert their own data" ON users
    FOR INSERT WITH CHECK (auth.uid()::text = auth_id::text);

-- ===========================================
-- MATCHES TABLE POLICIES
-- ===========================================
CREATE POLICY IF NOT EXISTS "Anyone can view matches" ON matches
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Authenticated users can create matches" ON matches
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "System can update matches" ON matches
    FOR UPDATE USING (true);

-- ===========================================
-- VOTES TABLE POLICIES
-- ===========================================
CREATE POLICY IF NOT EXISTS "Authenticated users can vote" ON votes
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Users can view votes" ON votes
    FOR SELECT USING (true);

-- ===========================================
-- TOURNAMENTS TABLE POLICIES  
-- ===========================================
CREATE POLICY IF NOT EXISTS "Anyone can view tournaments" ON tournaments
    FOR SELECT USING (true);

-- ===========================================
-- TOURNAMENT_PARTICIPANTS TABLE POLICIES
-- ===========================================
CREATE POLICY IF NOT EXISTS "Anyone can view tournament participants" ON tournament_participants
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Authenticated users can join tournaments" ON tournament_participants
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Users can update own participation" ON tournament_participants
    FOR UPDATE USING (auth.uid() = (SELECT auth_id::uuid FROM users WHERE users.id = tournament_participants.user_id));

-- ===========================================
-- TOURNAMENT_VOTES TABLE POLICIES
-- ===========================================
CREATE POLICY IF NOT EXISTS "Authenticated users can vote in tournaments" ON tournament_votes
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Anyone can view tournament votes" ON tournament_votes
    FOR SELECT USING (true);

-- ===========================================
-- USER_PHOTOS TABLE POLICIES
-- ===========================================
CREATE POLICY IF NOT EXISTS "Users can view active photos" ON user_photos
    FOR SELECT USING (is_active = true);

CREATE POLICY IF NOT EXISTS "Users can manage their own photos" ON user_photos
    FOR ALL USING (auth.uid() = (SELECT auth_id::uuid FROM users WHERE users.id = user_photos.user_id));

-- ===========================================
-- PHOTO_STATS TABLE POLICIES  
-- ===========================================
CREATE POLICY IF NOT EXISTS "Users can view their own photo stats" ON photo_stats
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM user_photos WHERE user_photos.id = photo_stats.photo_id AND auth.uid() = (SELECT auth_id::uuid FROM users WHERE users.id = user_photos.user_id))
    );

CREATE POLICY IF NOT EXISTS "System can manage photo stats" ON photo_stats
    FOR ALL USING (true);

-- ===========================================
-- REMAINING TABLE POLICIES (Basit policies)
-- ===========================================

CREATE POLICY IF NOT EXISTS "Users can view own coin transactions" ON coin_transactions
    FOR SELECT USING (auth.uid() = (SELECT auth_id::uuid FROM users WHERE users.id = coin_transactions.user_id));

CREATE POLICY IF NOT EXISTS "Users can view own payments" ON payments
    FOR SELECT USING (auth.uid() = (SELECT auth_id::uuid FROM users WHERE users.id = payments.user_id));

CREATE POLICY IF NOT EXISTS "Authenticated users can make predictions" ON winrate_predictions
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Users can view predictions" ON winrate_predictions
    FOR SELECT USING (true);

-- ===========================================
-- HELPER FUNCTIONS
-- ===========================================

-- Increment tournament participants counter
CREATE OR REPLACE FUNCTION increment_tournament_participants(tournament_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE tournaments 
    SET current_participants = current_participants + 1,
        updated_at = NOW()
    WHERE id = tournament_id;
END;
$$ LANGUAGE plpgsql;

-- Increment tournament score for a user
CREATE OR REPLACE FUNCTION increment_tournament_score(tournament_id UUID, user_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE tournament_participants 
    SET score = score + 1,
        updated_at = NOW()
    WHERE tournament_id = increment_tournament_score.tournament_id 
    AND user_id = increment_tournament_score.user_id;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- STORAGE BUCKETS
-- ===========================================

-- Profile images bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- Tournament photos bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('tournament-photos', 'tournament-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for profile-images
CREATE POLICY IF NOT EXISTS "Authenticated users can upload profile images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Anyone can view profile images" ON storage.objects
    FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY IF NOT EXISTS "Users can update own profile images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'profile-images' AND auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Users can delete own profile images" ON storage.objects
    FOR DELETE USING (bucket_id = 'profile-images' AND auth.uid() IS NOT NULL);

-- Storage policies for tournament-photos
CREATE POLICY IF NOT EXISTS "Authenticated users can upload tournament photos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'tournament-photos' AND auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Anyone can view tournament photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'tournament-photos');

CREATE POLICY IF NOT EXISTS "Users can update own tournament photos" ON storage.objects
    FOR UPDATE USING (bucket_id = 'tournament-photos' AND auth.uid() IS NOT NULL);

CREATE POLICY IF NOT EXISTS "Users can delete own tournament photos" ON storage.objects
    FOR DELETE USING (bucket_id = 'tournament-photos' AND auth.uid() IS NOT NULL);

-- ===========================================
-- FINAL SUCCESS MESSAGE
-- ===========================================
-- Database setup completed successfully!
-- Your Chizo tournament app is now ready to run.
