-- user_photos tablosundaki foreign key constraint'i kaldır

-- Foreign key constraint'i kaldır
ALTER TABLE user_photos DROP CONSTRAINT IF EXISTS user_photos_user_id_fkey;

-- RLS'yi de kapat (geçici)
ALTER TABLE user_photos DISABLE ROW LEVEL SECURITY;
