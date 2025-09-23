-- user_photos tablosu için RLS politikaları (DÜZELTİLMİŞ)

-- Önce RLS'yi etkinleştir
ALTER TABLE user_photos ENABLE ROW LEVEL SECURITY;

-- Mevcut politikaları sil (varsa)
DROP POLICY IF EXISTS "Users can view their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can insert their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can update their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can delete their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can view other users' active photos" ON user_photos;

-- Yeni politikaları ekle (UUID tipine uygun)
CREATE POLICY "Users can view their own photos" ON user_photos
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can insert their own photos" ON user_photos
    FOR INSERT WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update their own photos" ON user_photos
    FOR UPDATE USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can delete their own photos" ON user_photos
    FOR DELETE USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can view other users' active photos" ON user_photos
    FOR SELECT USING (is_active = true);
