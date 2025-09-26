-- ===========================================
-- CHIZO DATABASE UPDATE SCRIPT
-- Safe version for existing tournament database
-- ===========================================

-- This script adds only missing components instead of recreating everything

-- Create extension for UUID if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- HELPER FUNCTION FOR TRIGGERS (If not exists)
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- TABLE STRUCTURE CHECKS & UPDATES
-- ===========================================

-- Check if tables exist and add missing columns if needed

-- Users table enhancements
DO $$ 
BEGIN
    -- Add missing columns to users table if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='age') THEN
        ALTER TABLE users ADD COLUMN age INTEGER;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='country') THEN
        ALTER TABLE users ADD COLUMN country VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='gender') THEN
        ALTER TABLE users ADD COLUMN gender VARCHAR(10) CHECK (gender IN ('Erkek', 'Kadın'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='instagram_handle') THEN
        ALTER TABLE users ADD COLUMN instagram_handle VARCHAR(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='profession') THEN
        ALTER TABLE users ADD COLUMN profession VARCHAR(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='is_visible') THEN
        ALTER TABLE users ADD COLUMN is_visible BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='show_instagram') THEN
        ALTER TABLE users ADD COLUMN show_instagram BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='show_profession') THEN
        ALTER TABLE users ADD COLUMN show_profession BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='total_matches') THEN
        ALTER TABLE users ADD COLUMN total_matches INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='wins') THEN
        ALTER TABLE users ADD COLUMN wins INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='current_streak') THEN
        ALTER TABLE users ADD COLUMN current_streak INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='total_streak_days') THEN
        ALTER TABLE users ADD COLUMN total_streak_days INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='last_login_date') THEN
        ALTER TABLE users ADD COLUMN last_login_date DATE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='country_preferences') THEN
        ALTER TABLE users ADD COLUMN country_preferences TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='age_range_preferences') THEN
        ALTER TABLE users ADD COLUMN age_range_preferences TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='profile_image_url') THEN
        ALTER TABLE users ADD COLUMN profile_image_url TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='updated_at') THEN
        ALTER TABLE users ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- ===========================================
-- CREATE MISSING TABLES
-- ===========================================

-- Create matches table if not exists
CREATE TABLE IF NOT EXISTS matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Create votes table if not exists
CREATE TABLE IF NOT EXISTS votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_correct BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create tournaments table if not exists (check columns)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tournaments' AND column_name='entry_fee') THEN
        ALTER TABLE tournaments ADD COLUMN entry_fee INTEGER NOT NULL DEFAULT 50;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tournaments' AND column_name='prize_pool') THEN
        ALTER TABLE tournaments ADD COLUMN prize_pool INTEGER;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tournaments' AND column_name='current_participants') THEN
        ALTER TABLE tournaments ADD COLUMN current_participants INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tournaments' AND column_name='gender') THEN
        ALTER TABLE tournaments ADD COLUMN gender VARCHAR(10) DEFAULT 'Erkek' CHECK (gender IN ('Erkek', 'Kadın'));
    END IF;
END $$;

-- Create other missing tables
CREATE TABLE IF NOT EXISTS tournament_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    loser_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_photos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    photo_order INTEGER NOT NULL CHECK (photo_order >= 1 AND photo_order <= 5),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a unique constraint with WHERE clause properly
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_photos_unique_active
    ON user_photos (user_id, photo_order)
    WHERE is_active = true;

CREATE TABLE IF NOT EXISTS photo_stats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    photo_id UUID NOT NULL REFERENCES user_photos(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS coin_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('earned', 'spent', 'purchased', 'refund')),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

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

-- ===========================================
-- SAFE INDEX CREATION
-- ===========================================

-- Create indexes only if they don't exist
DO $$ 
BEGIN
    -- Users indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_auth_id') THEN
        CREATE INDEX idx_users_auth_id ON users(auth_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_username') THEN
        CREATE INDEX idx_users_username ON users(username);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_gender') THEN
        CREATE INDEX idx_users_gender ON users(gender);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_wins') THEN
        CREATE INDEX idx_users_wins ON users(wins DESC);
    END IF;
END $$;

-- ===========================================
-- FIXED TRIGGERS
-- ===========================================

-- Safe trigger creation for users
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

-- Safe trigger creation for other tables
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

-- Safe triggers for remaining tables
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_user_photos_updated_at') THEN
        CREATE TRIGGER update_user_photos_updated_at
            BEFORE UPDATE ON user_photos
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_photo_stats_updated_at') THEN
        CREATE TRIGGER update_photo_stats_updated_at
            BEFORE UPDATE ON photo_stats
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ===========================================
-- SAFE RLS POLICIES
-- ===========================================

-- Enable RLS only if not already enabled
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'users' AND relrowsecurity) THEN
        ALTER TABLE users ENABLE ROW LEVEL SECURITY;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'matches' AND relrowsecurity) THEN
        ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'votes' AND relrowsecurity) THEN
        ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Create RLS policies safely (drop first, then create)
DO $$
BEGIN
    -- Drop existing policy if exists
    DROP POLICY IF EXISTS "Users can view all visible users" ON users;
    
    -- Create the policy
    CREATE POLICY "Users can view all visible users" ON users
        FOR SELECT USING (is_visible = true);
END $$;

-- ===========================================
-- STORAGE SETUP
-- ===========================================

-- Create storage buckets safely
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true),
       ('tournament-photos', 'tournament-photos', true)
ON CONFLICT (id) DO NOTHING;

-- ===========================================
-- NOTIFICATION SYSTEM TABLES
-- ===========================================

-- Add FCM token to users table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='fcm_token') THEN
        ALTER TABLE users ADD COLUMN fcm_token TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='notifications_enabled') THEN
        ALTER TABLE users ADD COLUMN notifications_enabled BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='tournament_notifications') THEN
        ALTER TABLE users ADD COLUMN tournament_notifications BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='vote_reminder_notifications') THEN
        ALTER TABLE users ADD COLUMN vote_reminder_notifications BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='win_celebration_notifications') THEN
        ALTER TABLE users ADD COLUMN win_celebration_notifications BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='streak_reminder_notifications') THEN
        ALTER TABLE users ADD COLUMN streak_reminder_notifications BOOLEAN DEFAULT true;
    END IF;
END $$;

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

-- Updated_at trigger for notifications
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_notifications_updated_at') THEN
        CREATE TRIGGER update_notifications_updated_at
            BEFORE UPDATE ON notifications
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Enable RLS for notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Notifications policies (with safe creation)
DO $$ 
BEGIN
    -- Drop existing policies first to avoid conflicts
    DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
    DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
    
    -- Create policies (simplified for Supabase compatibility)
    CREATE POLICY "Users can view own notifications" ON notifications
        FOR SELECT USING (auth.uid()::text = (SELECT auth_id FROM users WHERE users.id = notifications.user_id)::text);

    CREATE POLICY "Users can update own notifications" ON notifications
        FOR UPDATE USING (auth.uid()::text = (SELECT auth_id FROM users WHERE users.id = notifications.user_id)::text);
END $$;

-- ===========================================
-- CHAT SYSTEM TABLES  
-- ===========================================

-- Tournament chat rooms
CREATE TABLE IF NOT EXISTS tournament_chat_rooms (
    tournament_id UUID PRIMARY KEY REFERENCES tournaments(id) ON DELETE CASCADE,
    tournament_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tournament messages
CREATE TABLE IF NOT EXISTS tournament_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_username VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'user_message' CHECK (message_type IN ('system', 'user_message', 'user_join', 'user_leave')),
    reply_to_message_id UUID REFERENCES tournament_messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat read status
CREATE TABLE IF NOT EXISTS tournament_chat_read_status (
    tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    last_read_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (tournament_id, user_id)
);

-- Chat table indexes
CREATE INDEX IF NOT EXISTS idx_tournament_messages_tournament_id ON tournament_messages(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_messages_created_at ON tournament_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tournament_messages_sender_id ON tournament_messages(sender_id);

-- Updated_at triggers
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_tournament_chat_rooms_updated_at') THEN
        CREATE TRIGGER update_tournament_chat_rooms_updated_at
            BEFORE UPDATE ON tournament_chat_rooms
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_tournament_messages_updated_at') THEN
        CREATE TRIGGER update_tournament_messages_updated_at
            BEFORE UPDATE ON tournament_messages
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- RLS for chat tables
ALTER TABLE tournament_chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_chat_read_status ENABLE ROW LEVEL SECURITY;

-- Chat table policies (with safe creation)
DO $$ 
BEGIN
    -- Drop existing policies first to avoid conflicts
    DROP POLICY IF EXISTS "Tournament participants can read chat" ON tournament_chat_rooms;
    DROP POLICY IF EXISTS "Tournament participants can send messages" ON tournament_messages;
    DROP POLICY IF EXISTS "Tournament participants can read messages" ON tournament_messages;
    DROP POLICY IF EXISTS "Users can manage own read status" ON tournament_chat_read_status;
    
    -- Create policies
    CREATE POLICY "Tournament participants can read chat" ON tournament_chat_rooms
        FOR SELECT USING (
            EXISTS (
                SELECT 1 FROM tournament_participants 
                WHERE tournament_id = tournament_chat_rooms.tournament_id 
                AND user_id = (SELECT id FROM users WHERE auth_id::text = auth.uid()::text)
            )
        );

    CREATE POLICY "Tournament participants can send messages" ON tournament_messages
        FOR INSERT WITH CHECK (
            EXISTS (
                SELECT 1 FROM tournament_participants 
                WHERE tournament_id = tournament_messages.tournament_id 
                AND user_id = (SELECT id FROM users WHERE auth_id::text = auth.uid()::text)
            )
        );

    CREATE POLICY "Tournament participants can read messages" ON tournament_messages
        FOR SELECT USING (
            EXISTS (
                SELECT 1 FROM tournament_participants 
                WHERE tournament_id = tournament_messages.tournament_id 
                AND user_id = (SELECT id FROM users WHERE auth_id::text = auth.uid()::text)
            )
        );

    CREATE POLICY "Users can manage own read status" ON tournament_chat_read_status
        FOR ALL USING (user_id = (SELECT id FROM users WHERE auth_id::text = auth.uid()::text));
END $$;

-- Function to get user chat rooms with last message info
CREATE OR REPLACE FUNCTION get_user_chat_rooms(user_id UUID)
RETURNS TABLE(
    tournament_id UUID,
    tournament_name VARCHAR,
    participants TEXT[],
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    last_message_type VARCHAR,
    last_message TEXT,
    last_message_time TIMESTAMPTZ,
    unread_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.tournament_id,
        tc.tournament_name,
        ARRAY_AGG(u.username),
        tc.is_active,
        tc.created_at,
        tm.message_type,
        tm.content,
        tm.created_at,
        COUNT(CASE WHEN tm.created_at > COALESCE(r.last_read_at, '1970-01-01'::timestamptz) THEN 1 END)::INTEGER as unread_count
    FROM tournament_chat_rooms tc
    JOIN tournament_participants tp ON tc.tournament_id = tp.tournament_id
    JOIN users u ON tp.user_id = u.id
    LEFT JOIN tournament_messages tm ON tc.tournament_id = tm.tournament_id
    LEFT JOIN tournament_chat_read_status r ON r.tournament_id = tc.tournament_id AND r.user_id = user_id
    WHERE tp.user_id = get_user_chat_rooms.user_id
    GROUP BY tc.tournament_id, tc.tournament_name, tc.is_active, tc.created_at, tm.message_type, tm.content, tm.created_at, r.last_read_at
    ORDER BY tm.created_at DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- COMPLETION MESSAGE
-- ===========================================
-- Database update completed successfully!
-- Tournament database is now fully compatible with Chizo app.
-- Notification and Chat systems are now ready!
