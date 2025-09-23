-- user_photos tablosunu oluştur (eğer yoksa)

CREATE TABLE IF NOT EXISTS user_photos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    photo_url TEXT NOT NULL,
    photo_order INTEGER NOT NULL CHECK (photo_order >= 1 AND photo_order <= 5),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Her kullanıcı için aynı photo_order'da sadece bir aktif fotoğraf olabilir
    UNIQUE(user_id, photo_order) WHERE is_active = true
);

-- Index'ler
CREATE INDEX IF NOT EXISTS idx_user_photos_user_id ON user_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_user_photos_active ON user_photos(is_active);
CREATE INDEX IF NOT EXISTS idx_user_photos_order ON user_photos(photo_order);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_photos_updated_at 
    BEFORE UPDATE ON user_photos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- RLS'yi etkinleştir
ALTER TABLE user_photos ENABLE ROW LEVEL SECURITY;

-- RLS Politikaları

-- Policy 1: Users can view their own photos
CREATE POLICY "Users can view their own photos" ON user_photos
    FOR SELECT USING (auth.uid()::text = user_id);

-- Policy 2: Users can insert their own photos
CREATE POLICY "Users can insert their own photos" ON user_photos
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- Policy 3: Users can update their own photos
CREATE POLICY "Users can update their own photos" ON user_photos
    FOR UPDATE USING (auth.uid()::text = user_id);

-- Policy 4: Users can delete their own photos
CREATE POLICY "Users can delete their own photos" ON user_photos
    FOR DELETE USING (auth.uid()::text = user_id);

-- Policy 5: Users can view other users' active photos (for profile viewing)
CREATE POLICY "Users can view other users' active photos" ON user_photos
    FOR SELECT USING (is_active = true);
