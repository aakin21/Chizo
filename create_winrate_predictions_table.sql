-- Win rate predictions tablosu oluştur
CREATE TABLE IF NOT EXISTS winrate_predictions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    winner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    predicted_min INTEGER NOT NULL,
    predicted_max INTEGER NOT NULL,
    actual_winrate DECIMAL(5,2) NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    reward_coins INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index'ler ekle
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_user_id ON winrate_predictions(user_id);
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_winner_id ON winrate_predictions(winner_id);
CREATE INDEX IF NOT EXISTS idx_winrate_predictions_created_at ON winrate_predictions(created_at);

-- RLS (Row Level Security) etkinleştir
ALTER TABLE winrate_predictions ENABLE ROW LEVEL SECURITY;

-- RLS policy'leri ekle
CREATE POLICY "Users can view their own predictions" ON winrate_predictions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own predictions" ON winrate_predictions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Updated_at trigger'ı ekle
CREATE OR REPLACE FUNCTION update_winrate_predictions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_winrate_predictions_updated_at
    BEFORE UPDATE ON winrate_predictions
    FOR EACH ROW
    EXECUTE FUNCTION update_winrate_predictions_updated_at();
