-- Supabase projesi durumunu kontrol et
-- Bu komutları Supabase SQL Editor'da çalıştır

-- 1. Turnuvalar tablosunun varlığını ve yapısını kontrol et
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'tournaments'
ORDER BY ordinal_position;

-- 2. Turnuvalar tablosundaki veri sayısını kontrol et
SELECT COUNT(*) as tournament_count FROM tournaments;

-- 3. Aktif turnuvaları kontrol et
SELECT 
    id,
    name,
    status,
    entry_fee,
    max_participants,
    current_participants,
    created_at
FROM tournaments 
WHERE status IN ('registration', 'active')
ORDER BY entry_fee;

-- 4. RLS (Row Level Security) politikalarını kontrol et
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
WHERE tablename = 'tournaments';

-- 5. Supabase auth tablosunu kontrol et (kullanıcı sayısı)
SELECT COUNT(*) as user_count FROM auth.users;

-- 6. Users tablosunu kontrol et
SELECT COUNT(*) as users_count FROM users;

-- 7. Tournament participants tablosunu kontrol et
SELECT COUNT(*) as participants_count FROM tournament_participants;

-- 8. Supabase projesinin genel durumunu kontrol et
SELECT 
    current_database() as database_name,
    current_user as current_user,
    version() as postgres_version;
