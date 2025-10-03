# Bildirim Sistemi Kullanım Kılavuzu

## Yapılan Düzeltmeler

### 1. Firebase Yapılandırması ✅
- `android/app/google-services.json` dosyası eklendi
- Firebase messaging servisleri AndroidManifest.xml'e eklendi
- Gerekli izinler eklendi:
  - POST_NOTIFICATIONS
  - USE_FULL_SCREEN_INTENT
  - SYSTEM_ALERT_WINDOW

### 2. Notification Channels ✅
- **chizo_notifications**: Genel bildirimler için (Yüksek öncelik)
- **chizo_high_priority**: Önemli bildirimler için (Maksimum öncelik)
- Her iki channel da vibrasyon, ses ve LED desteğine sahip

### 3. İzin Sistemi ✅
- Firebase messaging izinleri otomatik talep ediliyor
- Android 13+ için POST_NOTIFICATIONS izni talep ediliyor
- iOS için kritik bildirim izinleri dahil

### 4. Test Servisleri ✅
- **NotificationTestService**: Tüm bildirim tiplerini test etme
- **NotificationDebugService**: Bildirim sistemini debug etme
- **NotificationIntegrationService**: Entegrasyon testleri

### 5. Gelişmiş Logging ✅
- Her adımda detaylı loglar
- Hata durumlarında açıklayıcı mesajlar
- Debug için kullanışlı emoji'ler

## Bildirim Sistemi Nasıl Test Edilir?

### 1. Hızlı Test
Uygulama içinde "Bildirimler" sekmesine gidin ve şu butonlara tıklayın:
- **Test Bildirimi**: Tek bir test bildirimi gönderir
- **Tüm Testler**: Tüm bildirim tiplerini test eder

### 2. Debug Testi
```dart
import 'services/notification_debug_service.dart';

// Sistem durumunu kontrol et
await NotificationDebugService.debugNotificationSystem();

// İzinleri kontrol et
await NotificationDebugService.checkNotificationPermissions();

// Ayarları sıfırla
await NotificationDebugService.resetNotificationSettings();

// Tüm tipleri test et
await NotificationDebugService.testAllNotificationTypes();
```

### 3. Manuel Test
```dart
import 'services/notification_service.dart';

// Basit bir bildirim gönder
await NotificationService.sendLocalNotification(
  title: 'Test Başlığı',
  body: 'Test mesajı',
  type: 'system_announcement',
  data: {'key': 'value'},
);
```

## Bildirim Tipleri

1. **system_announcement**: Sistem duyuruları
2. **tournament_update**: Turnuva güncellemeleri
3. **voting_result**: Oylama sonuçları
4. **coin_reward**: Coin ödülleri
5. **match_won**: Maç kazanma bildirimleri
6. **photo_milestone**: Fotoğraf başarıları
7. **total_milestone**: Toplam başarılar
8. **streak_daily_reminder**: Günlük hatırlatmalar

## Sık Karşılaşılan Sorunlar ve Çözümler

### Sorun 1: Bildirimler Gelmiyor
**Çözüm:**
1. Uygulama izinlerini kontrol edin (Ayarlar > Uygulamalar > Chizo > İzinler)
2. Bildirim ayarlarının açık olduğundan emin olun
3. Debug testini çalıştırın: `NotificationDebugService.debugNotificationSystem()`

### Sorun 2: Firebase Hatası
**Çözüm:**
1. `google-services.json` dosyasının doğru konumda olduğundan emin olun
2. Firebase console'da projenin doğru yapılandırıldığından emin olun
3. Uygulamayı yeniden başlatın

### Sorun 3: İzinler Verilmiyor
**Çözüm:**
1. Android 13+ kullanıyorsanız POST_NOTIFICATIONS izni gerekli
2. Uygulama ayarlarından manuel olarak izinleri açın
3. Uygulamayı kaldırıp yeniden yükleyin

### Sorun 4: Bildirimler Veritabanına Kaydedilmiyor
**Çözüm:**
1. Kullanıcının giriş yapmış olduğundan emin olun
2. Supabase bağlantısını kontrol edin
3. `notifications` tablosunun mevcut olduğundan emin olun

## Bildirim Ayarları

Bildirimler iki seviyede kontrol edilir:

1. **Uygulama İçi Ayarlar**: Bildirimler sekmesinden
   - Tüm bildirimler aç/kapa
   - Turnuva bildirimleri
   - Kazanç kutlamaları
   - Hot streak hatırlatmaları

2. **Sistem Ayarları**: Android/iOS ayarlarından
   - Bildirim izinleri
   - Bildirim sesleri
   - Titreşim ayarları

## Gelecek Güncellemeler

- [ ] Scheduled notifications (Zamanlanmış bildirimler)
- [ ] Rich notifications (Resimli bildirimler)
- [ ] Action buttons (Aksiyon butonları)
- [ ] Notification grouping (Bildirim gruplama)
- [ ] Do Not Disturb mode (Rahatsız Etme modu)

## Notlar

- Bildirimler her zaman uygulama içinde görünür (ayarlar kapalı olsa bile)
- Telefon bildirimleri ayarlarla kontrol edilir
- Firebase Cloud Messaging (FCM) uzak bildirimler için kullanılır
- Local notifications anlık bildirimler için kullanılır

## Destek

Sorun yaşarsanız:
1. Konsol loglarını kontrol edin
2. Debug servisleri ile test yapın
3. Bildirim geçmişini kontrol edin

