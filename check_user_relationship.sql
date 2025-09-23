-- users tablosundaki auth_id ve id ilişkisini kontrol et

-- Mevcut kullanıcının auth_id ve id'sini göster
SELECT 
    id,
    auth_id,
    email,
    username
FROM users 
WHERE auth_id = '60ad40f3-b677-4845-bf4a-78cd091fde88';

-- user_photos tablosundaki user_id değerlerini kontrol et
SELECT 
    up.user_id,
    u.auth_id,
    u.email
FROM user_photos up
LEFT JOIN users u ON up.user_id = u.id
LIMIT 5;
