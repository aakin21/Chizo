-- Geçici çözüm: RLS'yi kapat (SADECE TEST İÇİN!)

-- user_photos tablosunda RLS'yi geçici olarak kapat
ALTER TABLE user_photos DISABLE ROW LEVEL SECURITY;

-- UYARI: Bu güvenlik açığı yaratır! Sadece test için kullan!
-- Gerçek uygulamada mutlaka RLS politikalarını ekle!
