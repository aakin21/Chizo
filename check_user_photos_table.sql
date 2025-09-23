-- user_photos tablosunun yapısını kontrol et

-- Tablo yapısını göster
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_photos' 
ORDER BY ordinal_position;

-- Mevcut RLS politikalarını kontrol et
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual, 
    with_check
FROM pg_policies 
WHERE tablename = 'user_photos';

-- RLS'nin aktif olup olmadığını kontrol et
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'user_photos';
