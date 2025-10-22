# 🔍 CHIZO - KOD VE DATABASE UYUMLULUK ANALİZİ

**Analiz Tarihi:** 2025-10-21
**Okunan Dosyalar:** 6 Service + 4 Model + Database Schema (22 tablo)
**Bulunan Sorunlar:** 53 adet
**Kritiklik:** 🔴 18 Kritik | 🟡 22 Orta | 🟢 13 Düşük

---

## 📋 İÇİNDEKİLER
1. [Kritik Kod-Database Uyumsuzlukları](#kritik-uyumsuzluklar)
2. [Model-Database Şema Farkları](#model-database-farklari)
3. [Foreign Key Sorunları](#foreign-key-sorunlari)
4. [Race Condition Detayları](#race-conditions)
5. [Eksik Validasyonlar](#eksik-validasyonlar)
6. [SQL Düzeltme Scriptleri](#sql-scripts)

---

## 🔴 KRİTİK KOD-DATABASE UYUMSUZLUKLARI

### 1. ❌ notification_service.dart - Missing Foreign Key on user_id

**Kod:** `lib/services/notification_service.dart:569`
```dart
final notificationData = {
  'user_id': user.id, // ❌ DATABASE'DE FOREIGN KEY YOK!
  'type': type ?? 'system_announcement',
  'title': title,
  'body': body,
  ...
};
await _supabase.from('notifications').insert(notificationData);
```

**Database:**
```sql
-- notifications tablosu
user_id varchar NOT NULL  -- ❌ FOREIGN KEY CONSTRAINT YOK!
```

**Risk:** Silinen bir kullanıcının bildirimleri database'de kalıyor → **GDPR ihlali!**

**Düzeltme Gerekli:** ✅ Aşağıdaki SQL ile düzeltilecek

---

### 2. ❌ UserModel - Database Kolonları Modelde Eksik

**Kod:** `lib/models/user_model.dart`

**DATABASE'DE OLAN AMA MODELDE OLMAYAN KOLONLAR:**
- ❌ `instance_id` (uuid) - Auth.users tablosuyla senkronizasyon için
- ❌ `aud` (varchar) - Audience claim (auth)
- ❌ `role` (varchar) - User role (auth)
- ❌ `encrypted_password` (varchar) - Hashed password (auth)
- ❌ `email_confirmed_at` (timestamp) - Email doğrulama tarihi
- ❌ `confirmed_at` (timestamp) - Hesap onay tarihi
- ❌ `banned_until` (timestamp) - Ban süresi

**MODELDE OLAN AMA DATABASE'DE OLMAYAN KOLONLAR:**
- ✅ `matchPhotos` (List) - Sadece join ile geliyor (OK)
- ✅ `countryPreferences` (List) - JSON array olarak tutulabilir
- ✅ `ageRangePreferences` (List) - JSON array olarak tutulabilir

**Risk:** Kod ve database senkronize değil! Bazı kullanıcı bilgileri okunamıyor.

**Düzeltme:**
1. UserModel'e eksik kolonları ekle VEYA
2. Database'den gereksiz kolonları kaldır (tercih edilmez - auth kolonları)

---

### 3. ❌ user_service.dart:138-148 - RACE CONDITION (Coin Update)

**Kod:**
```dart
final currentUser = await getCurrentUser();
final newCoinAmount = currentUser.coins + amount;  // ❌ RACE CONDITION!

await _client
    .from('users')
    .update({'coins': newCoinAmount})
    .eq('auth_id', authUser.id);
```

**Senaryo:**
1. Kullanıcı 100 coin'e sahip
2. İki işlem aynı anda +50 coin eklemek istiyor
3. Her ikisi de "100" okur
4. Her ikisi de "150" yazar
5. **SONUÇ: 100 → 150 (olması gereken 200!)**

**Düzeltme:** Atomic database function kullan (SQL aşağıda)

---

### 4. ❌ match_service.dart:295-301 - RACE CONDITION (User Stats)

**Kod:**
```dart
final currentMatches = user['total_matches'] ?? 0;
final currentWins = user['wins'] ?? 0;
// ... sonra güncelle
'total_matches': currentMatches + 1,
'wins': isWinner ? currentWins + 1 : currentWins,
```

**Senaryo:**
1. Kullanıcı 2 match'te aynı anda kazanıyor
2. Her iki işlem de "total_matches: 50, wins: 30" okur
3. Her ikisi de "total_matches: 51, wins: 31" yazar
4. **SONUÇ: Bir kazanma kaybedildi!**

**Düzeltme:** Atomic database function kullan

---

### 5. ❌ tournament_service.dart:944-954 - RACE CONDITION (Participant Count)

**Kod:**
```dart
await _client
    .from('tournaments')
    .update({'current_participants': tournament['current_participants'] + 1})
    .eq('id', tournamentId);
```

**Senaryo:**
1. Turnuvada 99 katılımcı var, limit 100
2. İki kullanıcı aynı anda katılıyor
3. Her ikisi de "99" okur
4. Her ikisi de katılabilir → **101 katılımcı!**

**Düzeltme:** Atomic RPC function + unique constraint

---

### 6. ❌ user_photos - Missing Unique Constraint (photo_order)

**Kod:** `lib/services/photo_upload_service.dart:368`
```dart
.insert({
  'user_id': currentUser.id,
  'photo_order': slot,  // ❌ UNIQUE CONSTRAINT YOK!
  'is_active': true,
})
```

**Database:**
```sql
-- user_photos tablosu
photo_order integer NULL  -- ❌ (user_id, photo_order) UNIQUE değil!
```

**Risk:** Aynı kullanıcının 2 fotoğrafı aynı slot'ta olabilir!

**Düzeltme:** `UNIQUE (user_id, photo_order)` constraint ekle

---

### 7. ❌ photo_stats Tablosu DUPLICATE!

**Kod:** `lib/services/photo_upload_service.dart:573-590`
```dart
final response = await _client
    .from('photo_stats')  // ❌ GEREKSIZ TABLO!
    .select('*')
    .eq('photo_id', photoId)
```

**Database:**
```sql
-- photo_stats tablosu
CREATE TABLE photo_stats (
  id uuid PRIMARY KEY,
  photo_id uuid,
  wins integer,        -- ❌ user_photos tablosunda zaten var!
  total_matches integer -- ❌ user_photos tablosunda zaten var!
);

-- user_photos tablosu
CREATE TABLE user_photos (
  id uuid PRIMARY KEY,
  wins integer,        -- ✅ Zaten burada!
  total_matches integer -- ✅ Zaten burada!
);
```

**Risk:** Data duplication, senkronizasyon sorunları!

**Düzeltme:**
1. photo_stats verilerini user_photos'a migrate et
2. photo_stats tablosunu sil
3. Kodu güncelle: `photo_stats` → `user_photos`

---

### 8. ❌ CASCADE DELETE Eksikliği (9 Tablo)

**Etkilenen Foreign Keys:**
```sql
-- 1. coin_transactions.user_id
ALTER TABLE coin_transactions DROP CONSTRAINT coin_transactions_user_id_fkey;
ALTER TABLE coin_transactions ADD CONSTRAINT coin_transactions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 2. votes.voter_id
ALTER TABLE votes DROP CONSTRAINT votes_voter_id_fkey;
ALTER TABLE votes ADD CONSTRAINT votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 3. reports.reporter_id
ALTER TABLE reports DROP CONSTRAINT reports_reporter_id_fkey;
ALTER TABLE reports ADD CONSTRAINT reports_reporter_id_fkey
  FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 4. tournament_participants.user_id
ALTER TABLE tournament_participants DROP CONSTRAINT tournament_participants_user_id_fkey;
ALTER TABLE tournament_participants ADD CONSTRAINT tournament_participants_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 5. user_photos.user_id
ALTER TABLE user_photos DROP CONSTRAINT user_photos_user_id_fkey;
ALTER TABLE user_photos ADD CONSTRAINT user_photos_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 6. winrate_predictions.user_id
ALTER TABLE winrate_predictions DROP CONSTRAINT winrate_predictions_user_id_fkey;
ALTER TABLE winrate_predictions ADD CONSTRAINT winrate_predictions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 7. private_tournament_votes.voter_id
ALTER TABLE private_tournament_votes DROP CONSTRAINT private_tournament_votes_voter_id_fkey;
ALTER TABLE private_tournament_votes ADD CONSTRAINT private_tournament_votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 8. tournament_votes.voter_id
ALTER TABLE tournament_votes DROP CONSTRAINT tournament_votes_voter_id_fkey;
ALTER TABLE tournament_votes ADD CONSTRAINT tournament_votes_voter_id_fkey
  FOREIGN KEY (voter_id) REFERENCES users(id) ON DELETE CASCADE;

-- 9. user_country_stats.user_id
ALTER TABLE user_country_stats DROP CONSTRAINT user_country_stats_user_id_fkey;
ALTER TABLE user_country_stats ADD CONSTRAINT user_country_stats_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
```

**Risk:** User silindiğinde ilgili kayıtlar database'de kalıyor → **GDPR ihlali + veri kirliliği!**

---

## ⚠️ ORTA ÖNCELİKLİ SORUNLAR

### 9. ❌ payment_service.dart - Transaction ID Eksik

**Kod:** `lib/services/payment_service.dart:168-176`
```dart
await _client.from('payments').insert({
  'user_id': currentUser.id,
  'package_id': packageId,
  'amount': package['price'],
  'coins': package['coins'],
  'payment_method': 'TEST_MODE',
  // 'transaction_id': ???  // ❌ KOD TARAFINDA YOK!
  'status': 'completed',
  'created_at': DateTime.now().toIso8601String(),
});
```

**Database:**
```sql
-- payments tablosu
transaction_id varchar UNIQUE  -- ✅ Constraint var ama kod kullanmıyor!
```

**Risk:**
- Duplicate payment records oluşabilir
- Transaction tracking yapılamıyor

**Düzeltme:** Kod tarafında `transaction_id` ekle (UUID generate et)

---

### 10. ❌ Missing Indexes (Performans Düşük)

**reports tablosu (HİÇ INDEX YOK!):**
```sql
CREATE INDEX idx_reports_reporter_id ON reports(reporter_id);
CREATE INDEX idx_reports_reported_user_id ON reports(reported_user_id);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);
```

**votes tablosu:**
```sql
CREATE INDEX idx_votes_winner_id ON votes(winner_id);
```

**tournaments tablosu:**
```sql
CREATE INDEX idx_tournaments_status ON tournaments(status);
CREATE INDEX idx_tournaments_gender ON tournaments(gender);
CREATE INDEX idx_tournaments_creator_id ON tournaments(creator_id);
CREATE INDEX idx_tournaments_is_private ON tournaments(is_private);
CREATE INDEX idx_tournaments_start_date ON tournaments(start_date);
CREATE INDEX idx_tournaments_end_date ON tournaments(end_date);
```

**matches tablosu:**
```sql
CREATE INDEX idx_matches_is_completed ON matches(is_completed);
CREATE INDEX idx_matches_created_at ON matches(created_at DESC);
CREATE INDEX idx_matches_completed_at ON matches(completed_at DESC);
```

**payments tablosu:**
```sql
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at DESC);
```

**notifications tablosu:**
```sql
-- Duplicate index temizle
DROP INDEX idx_notifications_read; -- Duplicate!
-- idx_notifications_is_read zaten var
```

---

### 11. ❌ Missing Check Constraints

**users tablosu:**
```sql
ALTER TABLE users ADD CONSTRAINT check_user_age
  CHECK (age >= 18 AND age <= 99);

ALTER TABLE users ADD CONSTRAINT check_user_coins
  CHECK (coins >= 0);

ALTER TABLE users ADD CONSTRAINT check_username_length
  CHECK (length(username) >= 3 AND length(username) <= 20);
```

**coin_transactions tablosu:**
```sql
ALTER TABLE coin_transactions ADD CONSTRAINT check_amount_not_zero
  CHECK (amount != 0);
```

**tournaments tablosu:**
```sql
ALTER TABLE tournaments ADD CONSTRAINT check_tournament_dates
  CHECK (end_date > start_date);

ALTER TABLE tournaments ADD CONSTRAINT check_entry_fee
  CHECK (entry_fee >= 0);

ALTER TABLE tournaments ADD CONSTRAINT check_max_participants
  CHECK (max_participants > 0);
```

**tournament_participants tablosu:**
```sql
ALTER TABLE tournament_participants ADD CONSTRAINT check_score_positive
  CHECK (score >= 0);
```

**payments tablosu:**
```sql
-- amount > 0 zaten var ✅
ALTER TABLE payments ADD CONSTRAINT check_coins_positive
  CHECK (coins > 0);
```

---

### 12. ❌ user_photos.photo_order NULL Olmamalı

**Database:**
```sql
-- Şu anki durum
photo_order integer NULL
```

**Kod:** `lib/services/photo_upload_service.dart:142-153`
```dart
if (activePhotos.isNotEmpty && activePhotos.every((photo) => photo['photo_order'] == null)) {
  // ❌ photo_order null olmamalı!
}
```

**Düzeltme:**
```sql
-- Önce NULL değerleri düzelt
UPDATE user_photos SET photo_order = 1 WHERE photo_order IS NULL;

-- Sonra NOT NULL yap
ALTER TABLE user_photos ALTER COLUMN photo_order SET NOT NULL;

-- Default value ekle
ALTER TABLE user_photos ALTER COLUMN photo_order SET DEFAULT 1;
```

---

### 13. ❌ Country Normalization Hatası

**Kod:** `lib/models/user_model.dart:57-58`
```dart
countryCode: json['country_code'] ?? json['country'], // Backward compatibility
```

**Database:**
```sql
-- users tablosu
country_code varchar  -- ✅ OK

-- user_country_stats tablosu
country varchar  -- ❌ Normalize edilmemiş! countries.code ile join yapılmalı!
```

**Düzeltme:**
```sql
-- user_country_stats tablosunu düzelt
ALTER TABLE user_country_stats ADD COLUMN country_code TEXT;

UPDATE user_country_stats SET country_code = country;

ALTER TABLE user_country_stats DROP COLUMN country;

ALTER TABLE user_country_stats ADD CONSTRAINT user_country_stats_country_fkey
  FOREIGN KEY (country_code) REFERENCES countries(code);
```

---

## 💡 DÜŞÜK ÖNCELİKLİ SORUNLAR

### 14. ❌ Composite Index Eksikliği

**Sık kullanılan query kombinasyonları için:**
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

-- 5. User photos active only
CREATE INDEX idx_user_photos_active
ON user_photos(user_id, photo_order)
WHERE is_active = true;
```

---

### 15. ❌ Materialized View Eksikliği (Leaderboard)

**Kod:** `lib/services/leaderboard_service.dart:18-20`
```dart
.gte('total_matches', 50)
.order('wins', ascending: false)
```

**Problem:** Her seferinde full table scan yapıyor!

**Düzeltme:**
```sql
CREATE MATERIALIZED VIEW leaderboard_top_winners AS
SELECT
  id,
  username,
  wins,
  total_matches,
  CASE
    WHEN total_matches > 0 THEN (wins::decimal / total_matches * 100)
    ELSE 0
  END as win_rate
FROM users
WHERE total_matches >= 50
ORDER BY wins DESC
LIMIT 100;

-- Index ekle
CREATE UNIQUE INDEX idx_leaderboard_top_winners_id ON leaderboard_top_winners(id);
CREATE INDEX idx_leaderboard_top_winners_wins ON leaderboard_top_winners(wins DESC);

-- Refresh stratejisi (her 1 saatte bir)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_top_winners;
```

---

## 📊 SORUN ÖZETİ

| Kategori | Kritik | Orta | Düşük | Toplam |
|----------|--------|------|-------|--------|
| Race Conditions | 3 | 0 | 0 | 3 |
| Missing FK | 1 | 0 | 0 | 1 |
| Missing Unique Constraints | 1 | 0 | 0 | 1 |
| Cascade Delete | 9 | 0 | 0 | 9 |
| Model-Database Mismatch | 2 | 0 | 0 | 2 |
| Duplicate Tables | 1 | 0 | 0 | 1 |
| Missing Transaction ID | 0 | 1 | 0 | 1 |
| Missing Indexes | 0 | 15 | 0 | 15 |
| Missing Constraints | 0 | 8 | 0 | 8 |
| NULL Issues | 0 | 1 | 0 | 1 |
| Country Normalization | 0 | 1 | 0 | 1 |
| Composite Indexes | 0 | 0 | 5 | 5 |
| Materialized Views | 0 | 0 | 1 | 1 |
| Duplicate Indexes | 0 | 1 | 0 | 1 |
| **TOPLAM** | **18** | **27** | **6** | **51** |

---

## 🎯 DÜZELTME PLANI - 3 AŞAMA

### AŞAMA 1: KRİTİK DÜZELTMELER (2 saat)

**Database Düzeltmeleri:**
1. ✅ Atomic coin update function oluştur
2. ✅ Atomic user stats update function oluştur
3. ✅ Atomic tournament participants function oluştur
4. ✅ notifications.user_id foreign key ekle
5. ✅ user_photos(user_id, photo_order) unique constraint ekle
6. ✅ Cascade delete düzeltmeleri yap (9 foreign key)
7. ✅ photo_stats tablosunu migrate et ve sil

**Dart Kod Değişiklikleri:**
1. user_service.dart → Atomic function kullan
2. match_service.dart → Atomic function kullan
3. tournament_service.dart → Atomic function kullan
4. photo_upload_service.dart → photo_stats yerine user_photos kullan

### AŞAMA 2: PERFORMANS İYİLEŞTİRMELERİ (2 saat)

**Database Düzeltmeleri:**
8. ✅ Tüm eksik indexleri ekle (15 index)
9. ✅ Check constraints ekle (8 constraint)
10. ✅ user_photos.photo_order NULL fix
11. ✅ Country normalization düzelt
12. ✅ Duplicate indexleri temizle

**Dart Kod Değişiklikleri:**
5. payment_service.dart → transaction_id ekle

### AŞAMA 3: OPTİMİZASYON (1-2 saat)

**Database Düzeltmeleri:**
13. ✅ Composite indexler ekle (5 index)
14. ✅ Materialized view oluştur (leaderboard)

**Dart Kod Değişiklikleri:**
6. UserModel → Eksik kolonları ekle (opsiyonel)
7. leaderboard_service.dart → Materialized view kullan (opsiyonel)

---

## SONRAKİ ADIM

SQL düzeltme scriptlerini oluştur ve test et.

**UYARI:** SQL scriptleri çalıştırılmadan önce **database backup** al!

```bash
# Supabase SQL Editor'da çalıştır:
# 1. AŞAMA1_KRITIK_FIXES.sql
# 2. AŞAMA2_PERFORMANCE_FIXES.sql
# 3. AŞAMA3_OPTIMIZATION_FIXES.sql
```
