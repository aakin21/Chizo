-- Fotoğraf istatistikleri tablosu oluştur
CREATE TABLE IF NOT EXISTS photo_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    photo_id UUID NOT NULL REFERENCES user_photos(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index ekle
CREATE INDEX IF NOT EXISTS idx_photo_stats_photo_id ON photo_stats(photo_id);

-- RLS aktif et
ALTER TABLE photo_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policy'leri oluştur
-- Kullanıcılar kendi fotoğraflarının istatistiklerini görebilir
CREATE POLICY "Users can view their own photo stats" ON photo_stats
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_photos 
            WHERE user_photos.id = photo_stats.photo_id 
            AND user_photos.user_id = auth.uid()
        )
    );

-- Kullanıcılar kendi fotoğraflarının istatistiklerini güncelleyebilir
CREATE POLICY "Users can update their own photo stats" ON photo_stats
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_photos 
            WHERE user_photos.id = photo_stats.photo_id 
            AND user_photos.user_id = auth.uid()
        )
    );

-- Sistem fotoğraf istatistiklerini ekleyebilir/güncelleyebilir
CREATE POLICY "System can insert photo stats" ON photo_stats
    FOR INSERT WITH CHECK (true);

-- Trigger: updated_at otomatik güncelleme
CREATE OR REPLACE FUNCTION update_photo_stats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_photo_stats_updated_at
    BEFORE UPDATE ON photo_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_photo_stats_updated_at();
