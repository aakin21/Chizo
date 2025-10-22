# 📊 Chizo - Bildirim Tipleri Analizi

## Mevcut Bildirim Servisleri:

1. **coin_transaction_notification_service.dart** - Coin işlemleri
2. **hot_streak_notification_service.dart** - Hot streak (günlük giriş serisi)
3. **tournament_notification_service.dart** - Turnuva bildirimleri
4. **milestone_notification_service.dart** - Başarı/milestone bildirimleri
5. **notification_service.dart** - Ana bildirim servisi

---

## 📱 BİLDİRİM TİPLERİ

### 1. COIN TRANSACTION BİLDİRİMLERİ (Çok Fazla!)

#### Coin Kazanma:
- `coin_reward` - Coin ödülü kazandı
- `coin_earned` - Coin kazandı (genel)
- Prediction'dan coin kazandı
- Match kazanarak coin aldı
- Tournament kazanarak coin aldı
- Voting'den coin kazandı
- Referral'dan coin kazandı
- Achievement'ten coin kazandı
- Bonus'tan coin kazandı
- Special event'ten coin kazandı
- Daily login'den coin kazandı
- Hot streak'ten coin kazandı
- Reklamdan coin kazandı

#### Coin Harcama:
- `coin_spent` - Coin harcadı
- `coin_purchase` - Coin satın aldı (gerçek para ile)

**Toplam: ~15 farklı coin bildirimi**

---

### 2. HOT STREAK BİLDİRİMLERİ (Önemli!)

- `hotstreak_reward` - Hot streak ödülü aldı
- `hotstreak_broken` - Hot streak kırıldı ⚠️
- `hotstreak_active` - Hot streak aktif
- Hot streak reminder - Hatırlatma
- Milestone achieved - X günlük streak tamamlandı

**Toplam: ~5 hot streak bildirimi**

---

### 3. MATCH BİLDİRİMLERİ (Orta Önemli)

- `match_win` - Match kazandı
- `match_loss` - Match kaybetti
- `match_draw` - Match berabere
- Match invite - Match daveti
- Match result - Match sonucu

**Toplam: ~5 match bildirimi**

---

### 4. TOURNAMENT BİLDİRİMLERİ (Önemli!)

- `tournament_start` - Turnuva başladı 🔔
- `tournament_end` - Turnuva bitti
- `tournament_win` - Turnuva kazandı 🏆
- `elimination_start` - Eleme turu başladı
- Tournament reminder - Turnuva hatırlatması
- Tournament joined - Turnuvaya katıldı

**Toplam: ~6 tournament bildirimi**

---

### 5. PREDICTION/VOTING BİLDİRİMLERİ (Orta)

- `prediction_won` - Tahmin tuttu
- `prediction_lost` - Tahmin tutmadı
- `voting_reminder` - Oylama hatırlatması

**Toplam: ~3 prediction bildirimi**

---

### 6. SİSTEM BİLDİRİMLERİ (Önemli!)

- `system_announcement` - Sistem duyurusu 📢
- App update available - Uygulama güncellemesi
- Maintenance notification - Bakım bildirimi

**Toplam: ~3 sistem bildirimi**

---

## 🎯 ÖNERİLEN AYARLAR

### 📱 TELEFONA GİTMELİ (Push Notification):

1. **Hot Streak - KRİTİK:**
   - ❗ `hotstreak_broken` - Hot streak kırıldı (kullanıcı uygulamaya girmeli!)
   - ⏰ Hot streak reminder - Gün bitmeden hatırlat
   - 🎉 Milestone achieved (7 gün, 30 gün, 100 gün)

2. **Tournament - ÖNEM LI:**
   - 🏁 `tournament_start` - Turnuva başladı
   - ⏰ `elimination_start` - Eleme turu başladı
   - 🏆 `tournament_win` - Turnuva kazandın!

3. **Match - ÖNEMLI:**
   - 📨 Match invite - Match daveti
   - 🏆 `match_win` - Match kazandın (sadece önemli matchler)

4. **Sistem:**
   - 📢 `system_announcement` - Sistem duyurusu
   - 🔄 App update available
   - ⚠️ Maintenance notification

**Toplam: ~10 tip telefona gitmeli**

---

### 📋 SADECE UYGULAMA İÇİ LİSTEDE GÖRÜNMELİ:

1. **Tüm Coin İşlemleri** (15 tip):
   - Coin kazandı (tüm kaynaklar)
   - Coin harcadı
   - Coin satın aldı

2. **Diğer Match Bildirimleri:**
   - Match loss
   - Match draw
   - Match result

3. **Diğer Prediction:**
   - Prediction won
   - Prediction lost

4. **Diğer Tournament:**
   - Tournament end
   - Tournament joined

**Toplam: ~25 tip sadece app içi**

---

## 📊 ÖZET:

| Kategori | Telefona | Sadece App İçi | Toplam |
|----------|----------|----------------|---------|
| Coin | 0 | 15 | 15 |
| Hot Streak | 3 | 2 | 5 |
| Match | 1 | 4 | 5 |
| Tournament | 3 | 3 | 6 |
| Prediction | 0 | 3 | 3 |
| Sistem | 3 | 0 | 3 |
| **TOPLAM** | **10** | **27** | **37** |

---

## 🔧 İMPLEMENTASYON PLANI:

### 1. Notification Kategorileri Oluştur:

```dart
enum NotificationChannel {
  // Push to phone + Save to DB
  CRITICAL,      // Hot streak kırıldı, sistem duyurusu
  IMPORTANT,     // Tournament başladı, match invite

  // Only save to DB (no push)
  INFO,          // Coin işlemleri, match sonuçları
  LOG,           // Tüm coin transaction logları
}
```

### 2. Her Bildirim Tipine Kanal Ata:

```dart
final notificationChannels = {
  'hotstreak_broken': NotificationChannel.CRITICAL,
  'tournament_start': NotificationChannel.IMPORTANT,
  'coin_spent': NotificationChannel.LOG,
  'coin_reward': NotificationChannel.LOG,
  // ...
};
```

### 3. sendNotification Fonksiyonunu Güncelle:

```dart
Future<void> sendNotification({
  required String type,
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) async {
  // HER ZAMAN database'e kaydet
  await _saveToDatabase(type, title, body, data);

  // Sadece belirli tipler telefona gitsin
  final channel = notificationChannels[type];
  if (channel == NotificationChannel.CRITICAL ||
      channel == NotificationChannel.IMPORTANT) {
    await _sendPushNotification(title, body, data);
  }
}
```

---

## ✅ SONRAKİ ADIMLAR:

1. ✅ Firebase düzeltildi - bildirimler telefona gidiyor
2. ⏳ Bildirim tiplerini kategorize et
3. ⏳ sendNotification fonksiyonunu güncelle
4. ⏳ Test et - coin harcadığında sadece app içinde görünsün
5. ⏳ Test et - hot streak kırıldığında telefona gitsin

---

**Onayını bekliyorum! Bu listeyi beğendin mi? Değişiklik yapmak ister misin?**
