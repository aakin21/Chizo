-- user_photos tablosu için Row Level Security politikaları

-- Önce RLS'yi etkinleştir
ALTER TABLE user_photos ENABLE ROW LEVEL SECURITY;

-- Kullanıcılar kendi fotoğraflarını görebilir
CREATE POLICY "Users can view their own photos" ON user_photos
    FOR SELECT USING (auth.uid()::text = user_id);

-- Kullanıcılar kendi fotoğraflarını ekleyebilir
CREATE POLICY "Users can insert their own photos" ON user_photos
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- Kullanıcılar kendi fotoğraflarını güncelleyebilir
CREATE POLICY "Users can update their own photos" ON user_photos
    FOR UPDATE USING (auth.uid()::text = user_id);

-- Kullanıcılar kendi fotoğraflarını silebilir (soft delete için update)
CREATE POLICY "Users can delete their own photos" ON user_photos
    FOR DELETE USING (auth.uid()::text = user_id);

-- Tüm kullanıcılar diğer kullanıcıların aktif fotoğraflarını görebilir (profil görüntüleme için)
CREATE POLICY "Users can view other users' active photos" ON user_photos
    FOR SELECT USING (is_active = true);

-- user_photos tablosunun yapısını kontrol et
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'user_photos' 
ORDER BY ordinal_position;
