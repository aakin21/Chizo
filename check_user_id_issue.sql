-- Kullanıcı ID sorununu kontrol et

-- Mevcut kullanıcının bilgilerini göster
SELECT 
    id,
    auth_id,
    email,
    username
FROM users 
WHERE auth_id = '60ad40f3-b677-4845-bf4a-78cd091fde88';

-- user_photos tablosundaki mevcut kayıtları göster
SELECT 
    up.user_id,
    u.auth_id,
    u.email,
    u.id as users_table_id
FROM user_photos up
LEFT JOIN users u ON up.user_id = u.id
LIMIT 5;
