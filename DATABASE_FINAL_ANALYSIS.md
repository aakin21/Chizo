# 🗄️ CHIZO DATABASE - KOMPLE ANALİZ VE DÜZELTME PLANI

**Analiz Tarihi:** 2025-10-21
**Toplam Tablo:** 22
**Toplam Sorun Tespit Edildi:** 47 adet
**Kritiklik:** 🔴 15 Kritik | 🟡 18 Orta | 🟢 14 Düşük

---

## 📋 İÇİNDEKİLER
1. [Kod ve Database Tutarsızlıkları](#kod-tutarsizliklari)
2. [Race Condition Sorunları](#race-conditions)
3. [Missing Foreign Keys](#missing-fk)
4. [Missing Indexes](#missing-indexes)
5. [Missing Constraints](#missing-constraints)
6. [Cascade Delete Sorunları](#cascade-delete)
7. [SQL Düzeltme Scriptleri](#sql-fixes)

---

## 🔴 KRİTİK SORUNLAR

### 1. RACE CONDITION - Coin Updates (user_service.dart:141)

**Sorun:**
```dart
// user_service.dart satır 138-148
final currentUser = await getCurrentUser();
final newCoinAmount = currentUser.coins + amount;  // ❌ Race condition!

await _client
    .from('users')
    .update({'coins': newCoinAmount})
    .eq('auth_id', authUser.id);
```

**Risk:** İki kullanıcı aynı anda coin update yapabilir, biri kaybedebilir!

**Düzeltme:** Atomic database function kullan

---

### 2. RACE CONDITION - User Stats Update (match_service.dart:281-309)

**Sorun:**
```dart
// match_service.dart satır 295-301
final currentMatches = user['total_matches'] ?? 0;
final currentWins = user['wins'] ?? 0;
// ... sonra güncelle
'total_matches': currentMatches + 1,
'wins': isWinner ? currentWins + 1 : currentWins,
```

**Risk:** Aynı kullanıcı için paralel match update yapılırsa istatistikler kaybedilebilir!

---

### 3. RACE CONDITION - Tournament Participants (tournament_service.dart:944-954)

**Sorun:**
```dart
// RPC başarısız olunca manuel update yapılıyor
await _client
    .from('tournaments')
    .update({'current_participants': tournament['current_participants'] + 1})
    .eq('id', tournamentId);
```

**Risk:** Aynı anda 2 kişi katılırsa, biri sayılmayabilir!

---

### 4. Missing Foreign Key: notifications.user_id

**Sorun:** `notifications` tablosunda `user_id` kolonu var AMA foreign key constraint YOK!

**Kod:**
```dart
// notification_service.dart'ta user_id kullanılıyor
await _client.from('notifications').insert({
  'user_id': userId,  // ❌ Foreign key yok!
  'type': type,
  ...
});
```

**Risk:** Silinen bir kullanıcının bildirimler tablosunda kayıtları kalabilir!

---

### 5. Missing Unique Constraint: user_photos(user_id, photo_order)

**Sorun:** Aynı kullanıcının 2 fotoğrafı aynı `photo_order`'a sahip olabilir!

**Kod:**
```dart
// photo_upload_service.dart:368
.insert({
  'user_id': currentUser.id,
  'photo_order': slot,  // ❌ Unique constraint yok!
})
```

**Risk:** Slot çakışmaları, fotoğraf kaybı!

---

### 6. photo_stats Tablosu Duplicate!

**Sorun:** `photo_stats` tablosu GEREKSIZ! `user_photos` tablosunda zaten `wins` ve `total_matches` var.

**Kod:**
```dart
// photo_upload_service.dart:573-590 - photo_stats kullanılıyor
final response = await _client
    .from('photo_stats')  // ❌ Gereksiz tablo!
    .select('*')
    .eq('photo_id', photoId)
```

**Çözüm:** `photo_stats` tablosunu sil, `user_photos` kullan.

---

### 7. Model-Database Mismatch: UserModel

**Sorun:** UserModel'de olmayan kolonlar database'de var!

**Database Kolonları (users tablosu):**
- ✅ `instance_id` (uuid) - Modelde YOK!
- ✅ `aud` (varchar) - Modelde YOK!
- ✅ `role` (varchar) - Modelde YOK!
- ✅ `encrypted_password` (varchar) - Modelde YOK!
- ✅ `email_confirmed_at` (timestamp) - Modelde YOK!
- ✅ `confirmed_at` (timestamp) - Modelde YOK!
- ✅ `banned_until` (timestamp) - Modelde YOK!

**Risk:** Model ve database senkronize değil! Veri kaybı riski var.

---

### 8. CASCADE DELETE Eksikliği

**Etkilenen Tablolar:**
- `coin_transactions.user_id` → `ON DELETE CASCADE` yok
- `votes.voter_id` → `ON DELETE CASCADE` yok
- `reports.reporter_id` → `ON DELETE CASCADE` yok
- `tournament_participants.user_id` → `ON DELETE CASCADE` yok
- `user_photos.user_id` → `ON DELETE CASCADE` yok
- `winrate_predictions.user_id` → `ON DELETE CASCADE` yok
- `private_tournament_votes.voter_id` → `ON DELETE CASCADE` yok
- `tournament_votes.voter_id` → `ON DELETE CASCADE` yok
- `user_country_stats.user_id` → `ON DELETE CASCADE` yok

**Risk:** User silindiğinde ilgili kayıtlar database'de kalıyor → **GDPR ihlali!**

---

## ⚠️ ORTA ÖNCELİKLİ SORUNLAR

### 9. Missing Indexes (Performans Düşük)

**reports tablosu (HİÇ INDEX YOK!):**
```sql
-- ❌ Eksik indexler
reporter_id     -- Index yok
reported_user_id -- Index yok
status          -- Index yok
```

**votes tablosu:**
```sql
-- ❌ Eksik index
winner_id       -- Index yok (voter_id ve match_id var)
```

**tournaments tablosu:**
```sql
-- ❌ Eksik indexler
status          -- Index yok
gender          -- Index yok
creator_id      -- Index yok
is_private      -- Index yok
start_date      -- Index yok
end_date        -- Index yok
```

**matches tablosu:**
```sql
-- ❌ Eksik indexler
is_completed    -- Index yok
created_at      -- Index yok
completed_at    -- Index yok
```

**payments tablosu:**
```sql
-- ❌ Eksik indexler
status          -- Index yok
created_at      -- Index yok
```

---

### 10. Missing Check Constraints

**users tablosu:**
```sql
-- ❌ Eksik check constraints
age >= 18 AND age <= 99
coins >= 0
length(username) >= 3 AND length(username) <= 20
```

**coin_transactions tablosu:**
```sql
-- ❌ Eksik check constraint
amount != 0  -- 0 coin transaction anlamsız
```

**tournaments tablosu:**
```sql
-- ❌ Eksik check constraints
end_date > start_date
entry_fee >= 0
max_participants > 0
```

**tournament_participants tablosu:**
```sql
-- ❌ Eksik check constraint
score >= 0
```

**payments tablosu:**
```sql
-- ✅ amount > 0 var (iyi!)
-- ❌ coins > 0 yok
```

---

### 11. Country Normalization Hatası

**Sorun:** `user_country_stats.country` kolonu TEXT, ama `countries` tablosu var ve kullanılmıyor!

**Database:**
```sql
-- user_country_stats
country varchar  -- ❌ Text olarak tutulmayan, normalize edilmemiş
```

**Çözüm:**
```sql
ALTER TABLE user_country_stats ADD COLUMN country_code TEXT;
ALTER TABLE user_country_stats ADD FOREIGN KEY (country_code) REFERENCES countries(code);
```

---

### 12. Duplicate Index: notifications

**Sorun:** Aynı kolonda 2 index var!

**Database:**
```sql
idx_notifications_read      ON (is_read)
idx_notifications_is_read   ON (is_read)  -- ❌ Duplicate!
```

**Çözüm:** Birini sil.

---

### 13. Missing Composite Indexes

**Sık kullanılan query kombinasyonları için eksik:**

```sql
-- 1. Completed matches by date
CREATE INDEX idx_matches_completed_date
ON matches(is_completed, created_at DESC)
WHERE is_completed = true;

-- 2. Active tournaments by gender
CREATE INDEX idx_tournaments_active_gender
ON tournaments(status, gender, start_date)
WHERE status = 'active';

-- 3. Unread notifications
CREATE INDEX idx_notifications_unread_user
ON notifications(user_id, created_at DESC)
WHERE is_read = false;

-- 4. User voting history
CREATE INDEX idx_votes_voter_created
ON votes(voter_id, created_at DESC);
```

---

### 14. NULL Check Sorunları

**user_photos.photo_order:**
```sql
photo_order integer NULL  -- ❌ Her fotoğrafın sırası olmalı!
```

**Kod:**
```dart
// photo_upload_service.dart:142-153
if (activePhotos.isNotEmpty && activePhotos.every((photo) => photo['photo_order'] == null)) {
  // ❌ photo_order null olmamalı!
}
```

**Çözüm:** Default value ekle veya NOT NULL yap.

---

## 💡 DÜŞÜK ÖNCELİKLİ SORUNLAR

### 15. Materialized View Eksikliği (Leaderboard)

**Sorun:** Leaderboard her seferinde full table scan yapıyor!

**Kod:**
```dart
// leaderboard_service.dart:18-20
.gte('total_matches', 50)
.order('wins', ascending: false)
```

**Çözüm:** Materialized view oluştur.

---

### 16. Partial Index Eksikliği

**Active photos için:**
```sql
CREATE INDEX idx_user_photos_active_only
ON user_photos(user_id, is_active)
WHERE is_active = true;
```

---

### 17. Transaction ID Duplicate Check (payments)

**Sorun:** Kod tarafında transaction_id kullanılıyor ama unique constraint VAR!

**Kod:**
```dart
// payment_service.dart:168-176 - transaction_id yok!
await _client.from('payments').insert({
  'user_id': currentUser.id,
  // 'transaction_id': ???  // ❌ Kod tarafında kullanılmıyor!
  'status': 'completed',
});
```

**Risk:** Test mode'da duplicate transaction oluşturulabilir.

---

## 📊 SORUN ÖZETİ

| Kategori | Kritik | Orta | Düşük | Toplam |
|----------|--------|------|-------|---------|
| Race Conditions | 3 | 0 | 0 | 3 |
| Missing FK | 1 | 0 | 0 | 1 |
| Missing Indexes | 0 | 15 | 0 | 15 |
| Missing Constraints | 0 | 8 | 0 | 8 |
| Cascade Delete | 9 | 0 | 0 | 9 |
| Model Mismatch | 1 | 0 | 0 | 1 |
| Duplicate Tables | 1 | 0 | 0 | 1 |
| Optimization | 0 | 4 | 5 | 9 |
| **TOPLAM** | **15** | **27** | **5** | **47** |

---

## 🎯 DÜZELTME PLANI

### AŞAMA 1: KRİTİK DÜZELTMELER (Bugün - 2 saat)

1. ✅ Atomic coin update function oluştur
2. ✅ Atomic user stats update function oluştur
3. ✅ Atomic tournament participants function oluştur
4. ✅ notifications.user_id foreign key ekle
5. ✅ user_photos(user_id, photo_order) unique constraint ekle
6. ✅ Cascade delete düzeltmeleri yap
7. ✅ photo_stats tablosunu migrate et ve sil

### AŞAMA 2: PERFORMANS İYİLEŞTİRMELERİ (Yarın - 2 saat)

8. ✅ Tüm eksik indexleri ekle
9. ✅ Check constraints ekle
10. ✅ Country normalization düzelt
11. ✅ Duplicate indexleri temizle

### AŞAMA 3: OPTİMİZASYON (Bu hafta - 3 saat)

12. ✅ Composite indexler ekle
13. ✅ Materialized view oluştur (leaderboard)
14. ✅ Partial indexler ekle
15. ✅ Model-Database sync yap

---

## SONRAKİ ADIM

SQL düzeltme scriptlerini hazırla ve sırayla uygula.

**UYARI:** SQL scriptleri çalıştırılmadan önce **database backup** al!

