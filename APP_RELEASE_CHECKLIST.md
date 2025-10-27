# 🚀 CHIZO APP RELEASE CHECKLIST

Bu dosya, Chizo uygulamasını Google Play Store'a yayınlamak için gereken TÜM adımları içerir.
Her başlık altındaki bilgileri tek tek copy-paste yaparak Claude'a ver, birlikte tamamlayalım.

---

## ✅ ADIM 1: UYGULAMA BİLGİLERİ

### 1.1 Temel Bilgiler
```yaml
# Buraya bilgileri doldur ve Claude'a gönder

APP_NAME: "Chizo"
PACKAGE_NAME: "com.chizo.app"
VERSION_CODE: 1
VERSION_NAME: "1.0.0"

# Uygulama Kategorisi (seç)
CATEGORY: "Social" veya "Dating" veya "Lifestyle"

# Hedef Yaş Grubu
TARGET_AGE: "18+"

# Desteklenen Diller
LANGUAGES:
  - Türkçe
  - English
  - (diğer diller varsa ekle)
```

### 1.2 Uygulama Açıklaması
```
# Kısa Açıklama (80 karakter max) - Google Play'de görünür
SHORT_DESCRIPTION: |
  (Buraya kısa açıklama yaz)

# Uzun Açıklama (4000 karakter max)
LONG_DESCRIPTION: |
  (Buraya detaylı açıklama yaz - özellikler, nasıl çalışır, vs.)

# Yenilikler (Bu versiyonda neler var)
WHATS_NEW: |
  (İlk versiyon ise "İlk sürüm" yaz)
```

---

## ✅ ADIM 2: GÖRSELLER VE İKONLAR

### 2.1 Kontrol Et
```bash
# Bu dosyalar var mı kontrol et (Claude'a bu komutu çalıştırt)

REQUIRED_IMAGES:
  - App Icon (512x512 PNG):
    Dosya yolu: _______________

  - Feature Graphic (1024x500 PNG):
    Dosya yolu: _______________

  - Screenshots (En az 2, max 8):
    Phone: 320-3840px genişlik
    Tablet: (opsiyonel)
    Dosya yolu: _______________

# Eğer yoksa, Claude'dan hazırlamasını iste!
```

### 2.2 App Icon Boyutları
```yaml
# Android için gerekli icon boyutları:
android/app/src/main/res/
  - mipmap-mdpi/ic_launcher.png (48x48)
  - mipmap-hdpi/ic_launcher.png (72x72)
  - mipmap-xhdpi/ic_launcher.png (96x96)
  - mipmap-xxhdpi/ic_launcher.png (144x144)
  - mipmap-xxxhdpi/ic_launcher.png (192x192)

# Bu dosyalar var mı? (Evet/Hayır)
STATUS: _______________
```

---

## ✅ ADIM 3: FİREBASE PRODUCTION AYARLARI

### 3.1 Firebase Projesi
```yaml
# Firebase Console'dan al ve Claude'a ver

PROJECT_ID: _______________
API_KEY: _______________
APP_ID: _______________
MESSAGING_SENDER_ID: _______________

# google-services.json dosyası güncel mi?
GOOGLE_SERVICES_JSON_STATUS: (Evet/Hayır)

# Firebase Services aktif mi?
SERVICES:
  - Authentication: (Evet/Hayır)
  - Cloud Messaging: (Evet/Hayır)
  - (Diğer servisler varsa ekle)
```

### 3.2 Supabase Ayarları
```yaml
# .env dosyasındaki bilgiler

SUPABASE_URL: _______________
SUPABASE_ANON_KEY: _______________

# Production için bu bilgiler doğru mu?
PRODUCTION_READY: (Evet/Hayır)
```

---

## ✅ ADIM 4: GİZLİLİK VE GÜVENLİK

### 4.1 Privacy Policy (Gizlilik Politikası)
```yaml
# Gizlilik politikası URL'i (ZORUNLU)
PRIVACY_POLICY_URL: _______________

# Yoksa Claude'dan hazırlamasını iste
# GitHub Pages veya başka bir public URL'de host edilmeli
```

### 4.2 Güvenlik Kontrolleri
```yaml
# Bu dosyalar .gitignore'da mı?
SECURITY_CHECK:
  - key.properties: [ ] Evet [ ] Hayır
  - .env: [ ] Evet [ ] Hayır
  - google-services.json: [ ] Hayır olmalı (repo'da olmalı)

# Debug kod kaldırıldı mı?
DEBUG_REMOVED:
  - print() statements: [ ] Temizlendi
  - Test API keys: [ ] Kaldırıldı
  - Debug logs: [ ] Production'da kapalı
```

---

## ✅ ADIM 5: KEYSTORE OLUŞTURMA

### 5.1 Keystore Var mı?
```yaml
# Daha önce oluşturulmuş keystore var mı?
EXISTING_KEYSTORE: (Evet/Hayır)

# Evet ise:
KEYSTORE_PATH: _______________
KEY_ALIAS: _______________
STORE_PASSWORD: _______________
KEY_PASSWORD: _______________

# Hayır ise, Claude keystore oluşturacak
```

### 5.2 key.properties Dosyası
```
# android/key.properties içeriği:
# (Eğer yoksa Claude'a oluşturmasını söyle)

STATUS: (Var/Yok)
```

---

## ✅ ADIM 6: VERSİYON KONTROLÜ

### 6.1 pubspec.yaml
```yaml
# Şu anki version bilgisi:
CURRENT_VERSION: _______________

# Doğru mu? (1.0.0+1 formatında olmalı)
VERSION_CORRECT: (Evet/Hayır)
```

### 6.2 AndroidManifest.xml
```yaml
# Permissions doğru mu?
PERMISSIONS_CHECK:
  - INTERNET: [ ] Var
  - ACCESS_NETWORK_STATE: [ ] Var
  - CAMERA: [ ] Var (gerekiyorsa)
  - READ_EXTERNAL_STORAGE: [ ] Var (gerekiyorsa)
  - (Diğer permissions)

# Gereksiz permission var mı?
UNNECESSARY_PERMISSIONS: _______________
```

---

## ✅ ADIM 7: TEST CHECKLIST

### 7.1 Fonksiyonel Testler
```yaml
TESTS:
  - [ ] Uygulama açılıyor
  - [ ] Login/Register çalışıyor
  - [ ] Ana özellikler çalışıyor (voting, predictions, etc.)
  - [ ] Firebase notifications alınıyor
  - [ ] Profil güncelleme çalışıyor
  - [ ] Fotoğraf yükleme çalışıyor
  - [ ] Navigation sorunsuz
  - [ ] Back button çalışıyor
  - [ ] App minimalize/restore çalışıyor
  - [ ] Ağ hatası durumunda uygun mesaj gösteriliyor
```

### 7.2 Farklı Cihazlarda Test
```yaml
TESTED_DEVICES:
  - [ ] Emulator (Android 9+)
  - [ ] Gerçek cihaz 1: _______________
  - [ ] Gerçek cihaz 2: _______________
  - [ ] Tablet (opsiyonel)
```

### 7.3 Release Build Test
```bash
# Release build çalıştırıldı mı?
RELEASE_BUILD_TEST: (Evet/Hayır)

# Hata var mı?
ERRORS: _______________
```

---

## ✅ ADIM 8: GOOGLE PLAY CONSOLE AYARLARI

### 8.1 Developer Account
```yaml
# Google Play Developer hesabı var mı?
DEVELOPER_ACCOUNT: (Evet/Hayır)

# Kayıt ücreti ödendi mi? ($25 one-time)
REGISTRATION_FEE: (Ödendi/Ödenmedi)
```

### 8.2 App Listing Bilgileri
```yaml
# Google Play Console'da doldurulacak:

STORE_LISTING:
  - App Name: _______________
  - Short Description: _______________
  - Full Description: _______________
  - Contact Email: _______________
  - Phone: _______________ (opsiyonel)
  - Website: _______________ (opsiyonel)
```

### 8.3 Content Rating
```yaml
# İçerik derecelendirmesi yapıldı mı?
CONTENT_RATING: (Evet/Hayır)

# Uygulama şunları içeriyor mu?
CONTENT:
  - Violence: (Evet/Hayır)
  - Sexual Content: (Evet/Hayır)
  - User Generated Content: (Evet/Hayır)
  - Social Features: (Evet/Hayır)
  - Personal Info Collection: (Evet/Hayır)
```

### 8.4 Target Audience
```yaml
# Hedef kitle:
TARGET_AUDIENCE:
  - Age Range: _______________
  - Countries: _______________
```

---

## ✅ ADIM 9: BUILD HAZIRLIĞI

### 9.1 Son Kontroller
```yaml
FINAL_CHECKS:
  - [ ] Tüm merge conflicts çözüldü
  - [ ] Flutter analyze temiz
  - [ ] Testler geçiyor
  - [ ] Gereksiz dosyalar silindi
  - [ ] Commit'ler temiz
  - [ ] Git push yapıldı
```

### 9.2 Build Ayarları
```yaml
# build.gradle.kts ayarları doğru mu?

BUILD_CONFIG:
  - minSdk: _______________ (minimum 21 olmalı)
  - targetSdk: _______________ (en yeni API level)
  - Proguard enabled: [ ] Evet [ ] Hayır
  - Signing config: [ ] Release [ ] Debug
```

---

## ✅ ADIM 10: BUILD VE YAYINLAMA

### 10.1 Build Komutları
```bash
# Bu komutları sırayla çalıştıracağız:

1. flutter clean
2. flutter pub get
3. flutter build appbundle --release

# Claude bu komutları çalıştıracak
```

### 10.2 Upload
```yaml
# AAB dosyası nerede:
AAB_PATH: build/app/outputs/bundle/release/app-release.aab

# Dosya boyutu:
AAB_SIZE: _______________

# Google Play Console'a yüklendi mi?
UPLOADED: (Evet/Hayır)
```

---

## ✅ ADIM 11: YAYINLAMA SONRASI

### 11.1 Test Track
```yaml
# Hangi track'e yüklenecek?
TRACK:
  - [ ] Internal Testing
  - [ ] Closed Testing
  - [ ] Open Testing
  - [ ] Production

# İlk yayın için Internal/Closed Testing önerilir
```

### 11.2 Monitoring
```yaml
# Crash raporlama aktif mi?
CRASH_REPORTING:
  - Firebase Crashlytics: (Evet/Hayır)
  - Google Play Console: (Otomatik aktif)

# Analytics aktif mi?
ANALYTICS:
  - Firebase Analytics: (Evet/Hayır)
  - Google Analytics: (Evet/Hayır)
```

---

## 📋 ÖZET CHECKLIST

```yaml
READY_TO_RELEASE:
  [ ] 1. Uygulama bilgileri tamamlandı
  [ ] 2. Görseller ve ikonlar hazır
  [ ] 3. Firebase production ayarları yapıldı
  [ ] 4. Privacy policy hazır
  [ ] 5. Keystore oluşturuldu
  [ ] 6. Version bilgileri doğru
  [ ] 7. Testler başarılı
  [ ] 8. Google Play Console hazır
  [ ] 9. Build ayarları doğru
  [ ] 10. AAB oluşturuldu
  [ ] 11. Upload yapıldı
```

---

## 🚨 ÖNEMLİ NOTLAR

1. **Keystore'u KAYBETMEYİN!**
   - Keystore kaybedilirse uygulamayı güncelleyemezsiniz
   - Güvenli bir yerde backup alın
   - Şifreleri kaydedin

2. **Test, Test, Test!**
   - Release build mutlaka test edin
   - Farklı cihazlarda deneyin
   - İlk yayında Internal Testing kullanın

3. **Privacy Policy ZORUNLU**
   - Google Play olmadan yayınlamaz
   - Detaylı ve güncel olmalı
   - Public URL'de erişilebilir olmalı

4. **Review Süresi**
   - İlk yayın: 1-7 gün sürebilir
   - Güncellemeler: Genellikle 1-2 gün
   - Red yeme durumunda düzeltip tekrar gönderin

---

## 📞 YARDIM

Herhangi bir adımda takıldıysan:
1. O adımın altındaki bilgileri Claude'a copy-paste et
2. "Bu adımı tamamlamama yardım et" de
3. Claude adım adım yardımcı olacak

**Haydi başlayalım! Hangi adımdan başlamak istersin?**
