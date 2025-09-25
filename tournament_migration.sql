-- Tournament tablosu için migration
-- Mevcut tournaments tablosuna yeni kolonlar ekle

-- Gender kolonu ekle
ALTER TABLE tournaments 
ADD COLUMN IF NOT EXISTS gender VARCHAR(10) DEFAULT 'Erkek';

-- Yeni alanlar ekle
ALTER TABLE tournaments 
ADD COLUMN IF NOT EXISTS registration_start_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS second_place_id UUID,
ADD COLUMN IF NOT EXISTS third_place_id UUID;

-- Tournament participants tablosuna tournament_photo_url ekle
ALTER TABLE tournament_participants 
ADD COLUMN IF NOT EXISTS tournament_photo_url TEXT;

-- Tournament votes tablosu oluştur (eğer yoksa)
CREATE TABLE IF NOT EXISTS tournament_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    loser_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tournament votes için indexler
CREATE INDEX IF NOT EXISTS idx_tournament_votes_tournament_id ON tournament_votes(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_votes_voter_id ON tournament_votes(voter_id);
CREATE INDEX IF NOT EXISTS idx_tournament_votes_winner_id ON tournament_votes(winner_id);

-- Tournament participants tablosuna score kolonu ekle (eğer yoksa)
ALTER TABLE tournament_participants 
ADD COLUMN IF NOT EXISTS score INTEGER DEFAULT 0;

-- Tournament participants için indexler
CREATE INDEX IF NOT EXISTS idx_tournament_participants_tournament_id ON tournament_participants(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_user_id ON tournament_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_score ON tournament_participants(tournament_id, score DESC);

-- RPC fonksiyonları oluştur
CREATE OR REPLACE FUNCTION increment_tournament_participants(tournament_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE tournaments 
    SET current_participants = current_participants + 1,
        updated_at = NOW()
    WHERE id = tournament_id;
END;
$$ LANGUAGE plpgsql;

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

-- Storage bucket oluştur (tournament photos için)
INSERT INTO storage.buckets (id, name, public)
VALUES ('tournament-photos', 'tournament-photos', true)
ON CONFLICT (id) DO NOTHING;

-- RLS policies
ALTER TABLE tournament_votes ENABLE ROW LEVEL SECURITY;

-- Tournament votes için RLS policies
CREATE POLICY "Users can insert tournament votes" ON tournament_votes
    FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id::uuid FROM users WHERE id = voter_id));

CREATE POLICY "Users can view tournament votes" ON tournament_votes
    FOR SELECT USING (true);

-- Tournament participants için RLS policies (eğer yoksa)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tournament_participants' AND policyname = 'Users can view tournament participants') THEN
        CREATE POLICY "Users can view tournament participants" ON tournament_participants
            FOR SELECT USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tournament_participants' AND policyname = 'Users can insert tournament participants') THEN
        CREATE POLICY "Users can insert tournament participants" ON tournament_participants
            FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id::uuid FROM users WHERE id = user_id));
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tournament_participants' AND policyname = 'Users can update own tournament participation') THEN
        CREATE POLICY "Users can update own tournament participation" ON tournament_participants
            FOR UPDATE USING (auth.uid() = (SELECT auth_id::uuid FROM users WHERE id = user_id));
    END IF;
END $$;

-- Tournaments tablosu için RLS policies (eğer yoksa)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'tournaments' AND policyname = 'Users can view tournaments') THEN
        CREATE POLICY "Users can view tournaments" ON tournaments
            FOR SELECT USING (true);
    END IF;
END $$;
