-- Test turnuvaları oluştur
-- Pazartesi kayıt açılışı, Çarşamba başlangıç

INSERT INTO tournaments (
    id,
    name,
    description,
    entry_fee,
    prize_pool,
    max_participants,
    current_participants,
    registration_start_date,
    start_date,
    end_date,
    status,
    gender,
    current_phase,
    current_round,
    phase_start_date,
    created_at,
    updated_at
) VALUES 
-- Erkek 1000 Coin Turnuvası
(
    gen_random_uuid(),
    'Haftalık Erkek Turnuvası (1000 Coin)',
    'Her hafta düzenlenen erkek turnuvası - 300 kişi kapasiteli',
    1000,
    300000, -- 1000 * 300
    300,
    0,
    '2025-01-27 12:00:00+00', -- Pazartesi kayıt açılışı
    '2025-01-29 12:00:00+00', -- Çarşamba başlangıç
    '2025-02-05 12:00:00+00', -- 1 hafta sonra
    'active',
    'Erkek',
    'active',
    NULL,
    '2025-01-27 12:00:00+00',
    NOW(),
    NOW()
),
-- Erkek 10000 Coin Turnuvası
(
    gen_random_uuid(),
    'Haftalık Erkek Turnuvası (10000 Coin)',
    'Premium erkek turnuvası - 100 kişi kapasiteli',
    10000,
    1000000, -- 10000 * 100
    100,
    0,
    '2025-01-27 12:00:00+00', -- Pazartesi kayıt açılışı
    '2025-01-29 12:00:00+00', -- Çarşamba başlangıç
    '2025-02-05 12:00:00+00', -- 1 hafta sonra
    'active',
    'Erkek',
    'active',
    NULL,
    '2025-01-27 12:00:00+00',
    NOW(),
    NOW()
),
-- Kadın 1000 Coin Turnuvası
(
    gen_random_uuid(),
    'Haftalık Kadın Turnuvası (1000 Coin)',
    'Her hafta düzenlenen kadın turnuvası - 300 kişi kapasiteli',
    1000,
    300000, -- 1000 * 300
    300,
    0,
    '2025-01-27 12:00:00+00', -- Pazartesi kayıt açılışı
    '2025-01-29 12:00:00+00', -- Çarşamba başlangıç
    '2025-02-05 12:00:00+00', -- 1 hafta sonra
    'active',
    'Kadın',
    'active',
    NULL,
    '2025-01-27 12:00:00+00',
    NOW(),
    NOW()
),
-- Kadın 10000 Coin Turnuvası
(
    gen_random_uuid(),
    'Haftalık Kadın Turnuvası (10000 Coin)',
    'Premium kadın turnuvası - 100 kişi kapasiteli',
    10000,
    1000000, -- 10000 * 100
    100,
    0,
    '2025-01-27 12:00:00+00', -- Pazartesi kayıt açılışı
    '2025-01-29 12:00:00+00', -- Çarşamba başlangıç
    '2025-02-05 12:00:00+00', -- 1 hafta sonra
    'active',
    'Kadın',
    'active',
    NULL,
    '2025-01-27 12:00:00+00',
    NOW(),
    NOW()
);
