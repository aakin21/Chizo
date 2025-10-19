# 📊 SUPABASE BİLGİLERİNİ NASIL EXPORT EDERİM?

## Yöntem 1: SQL Schema Export (En Detaylı)

### Adım 1: Supabase Dashboard'a Git
1. https://supabase.com/dashboard
2. Projenizi seçin (rsuptwsgnpgsvlqigitq)

### Adım 2: SQL Editor'ı Aç
1. Sol menüden **"SQL Editor"** sekmesine tıkla
2. Yeni bir query açmak için **"New query"** butonuna tıkla

### Adım 3: Schema Export SQL'i Çalıştır

**Option A - Temel Schema (Tables only):**
```sql
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM
    information_schema.columns
WHERE
    table_schema = 'public'
ORDER BY
    table_name, ordinal_position;
```

**Option B - Detaylı Schema (Tables + Constraints + Indexes):**
```sql
-- Tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

-- Columns
SELECT
    table_name,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Primary Keys
SELECT
    tc.table_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_schema = 'public';

-- Foreign Keys
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public';

-- Indexes
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public';
```

### Adım 4: Sonucu Kopyala
1. Query çalıştır (Run butonu)
2. Sonuçları seç (Ctrl+A)
3. Kopyala (Ctrl+C)
4. Bir text file'a yapıştır ve bana gönder

---

## Yöntem 2: RLS Policies Export

### SQL Editor'da Çalıştır:
```sql
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
WHERE schemaname = 'public';
```

---

## Yöntem 3: Database Ayarları (UI'dan)

### Table Editor'dan:
1. Sol menüden **"Table Editor"** aç
2. Her table için:
   - Table'a tıkla
   - Sağ üstteki **"..."** menüsüne tıkla
   - **"View table definition"** seç
   - SQL'i kopyala

### Authentication Policies:
1. Sol menüden **"Authentication"** → **"Policies"**
2. Her table'ın RLS policy'lerini not al

### Storage Buckets:
1. Sol menüden **"Storage"**
2. Her bucket için:
   - Bucket'a tıkla
   - **"Policies"** tab'ına git
   - Policy detaylarını kopyala

---

## Yöntem 4: pg_dump (En Profesyonel)

### Eğer Database Connection String'in varsa:

1. **Connection String'i Bul:**
   - Supabase Dashboard → Settings → Database
   - "Connection string" altında "URI" seçeneğini kopyala

2. **pg_dump Çalıştır (Terminal):**
```bash
pg_dump -h db.rsuptwsgnpgsvlqigitq.supabase.co \
        -U postgres \
        -d postgres \
        --schema-only \
        > supabase_schema.sql
```

3. `supabase_schema.sql` dosyasını aç ve bana gönder

---

## Yöntem 5: Basit Manuel Liste (En Hızlı)

Eğer yukarıdakiler çok teknikse, sadece şunları yaz:

### Tables:
```
- users
  - id (uuid, primary key)
  - auth_id (uuid)
  - username (text)
  - email (text)
  - coins (int)
  - ... (diğer kolonlar)

- matches
  - id (uuid, primary key)
  - user1_id (uuid, foreign key -> users)
  - user2_id (uuid, foreign key -> users)
  - ... (diğer kolonlar)

... (diğer tablolar)
```

### RLS Policies:
```
users table:
- Policy 1: Users can read their own data
- Policy 2: Users can update their own data
...
```

### Storage Buckets:
```
- user-photos
  - Public: Yes/No
  - File size limit: ?
  - Allowed types: image/*
...
```

---

## 🎯 Bana Ne Göndermeliyim?

### Minimum (Hızlı analiz için):
- [ ] Table isimleri ve kolonları
- [ ] Primary/Foreign key ilişkileri
- [ ] RLS policy'leri (varsa)

### İdeal (Detaylı analiz için):
- [ ] Tam SQL schema (Yöntem 1, Option B)
- [ ] RLS policies (Yöntem 2)
- [ ] Storage bucket policies
- [ ] Indexes

### Premium (Mükemmel analiz için):
- [ ] pg_dump output (Yöntem 4)
- [ ] Table row counts
- [ ] Frequently used queries

---

## ❓ NASIL GÖNDERECEKSİN?

### Seçenek 1: Chat'te Paylaş
Direkt buraya yapıştır (güvenli, loglanmıyor)

### Seçenek 2: Text Dosyası Olarak
```
1. SQL sonuçlarını .txt veya .sql dosyasına kaydet
2. Dosyayı chat'e sürükle-bırak
```

### Seçenek 3: Screenshot
- Table Editor ekran görüntüleri
- RLS policies ekran görüntüleri

---

## 🔒 GÜVENLİK NOTU

**PAYLAŞMA:**
- ❌ API keys (zaten main.dart'ta var, onu kullanırım)
- ❌ Şifreler
- ❌ Kişisel veriler (user email, username vs)

**PAYLAŞMALISIN:**
- ✅ Table yapıları
- ✅ Column tipleri
- ✅ RLS policies
- ✅ Index tanımları
- ✅ Foreign key ilişkileri

---

## 💡 ÖNERİM

**En kolay ve hızlı:** Yöntem 1, Option B kullan
1. SQL Editor aç
2. SQL'i kopyala-yapıştır
3. Çalıştır
4. Sonucu bana gönder

**Tahmini süre:** 5-10 dakika

Hazır mısın? Hangi yöntemi tercih edersin? 😊
