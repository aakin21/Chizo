# Release Build Setup Guide

Bu dokümantasyon, Chizo uygulamasını Google Play Store'a yüklemek için gerekli release signing işlemlerini açıklar.

## 1. Keystore Oluşturma

### Keystore dosyası oluştur:
```bash
keytool -genkey -v -keystore chizo-release-key.keystore -alias chizo -keyalg RSA -keysize 2048 -validity 10000
```

**Önemli:**
- Keystore şifresini ve alias şifresini güvenli bir yerde sakla
- Bu bilgiler kaybolursa uygulamayı güncelleyemezsin!

### Keystore'u güvenli bir yere taşı:
```bash
mkdir -p ~/.android
mv chizo-release-key.keystore ~/.android/
```

## 2. Key Properties Dosyası Oluştur

`android/key.properties` dosyası oluştur:

```properties
storePassword=KEYSTORE_SIFRENIZ
keyPassword=KEY_SIFRENIZ
keyAlias=chizo
storeFile=/Users/KULLANICI_ADINIZ/.android/chizo-release-key.keystore
```

**Güvenlik:** `.gitignore` dosyasına `key.properties` eklenmiş olmalı!

## 3. build.gradle.kts Güncelleme

`android/app/build.gradle.kts` dosyasını aç ve signing config'i güncelle:

### Dosyanın en üstüne ekle:
```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

### `android` bloğu içinde `signingConfigs` ekle (defaultConfig'den önce):
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

### `buildTypes.release` içindeki signing config'i güncelle:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        // ... diğer ayarlar
    }
}
```

## 4. Import Ekle

`android/app/build.gradle.kts` dosyasının en üstüne:
```kotlin
import java.util.Properties
import java.io.FileInputStream
```

## 5. Release APK/AAB Build

### APK Build:
```bash
flutter build apk --release
```

### AAB Build (Google Play için önerilen):
```bash
flutter build appbundle --release
```

**Çıktı:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 6. Google Play Store Yükleme

1. [Google Play Console](https://play.google.com/console)'a git
2. Yeni uygulama oluştur
3. AAB dosyasını yükle
4. Store listing bilgilerini doldur
5. İçerik derecelendirmesi yap
6. Gizlilik politikası ekle
7. Uygulamayı yayınla

## Güvenlik Kontrol Listesi

- [ ] `key.properties` `.gitignore`'da
- [ ] Keystore dosyası git repo'suna eklenmemiş
- [ ] Keystore şifresi güvenli yerde saklanmış
- [ ] `.env` dosyası `.gitignore`'da
- [ ] Production API keys `.env` dosyasında
- [ ] Debug logging production'da kapalı

## Sorun Giderme

### "Keystore file not found" hatası:
- `key.properties` dosyasındaki `storeFile` yolunu kontrol et
- Keystore dosyasının doğru konumda olduğunu doğrula

### "Wrong password" hatası:
- `key.properties` dosyasındaki şifreleri kontrol et
- Şifrelerde özel karakter varsa tırnak içinde yaz

### APK boyutu çok büyük:
- Proguard/R8 aktif mi kontrol et (build.gradle.kts'de `isMinifyEnabled = true`)
- Split APK kullanmayı düşün
- Asset'leri optimize et

## App Signing by Google Play

Google Play App Signing kullanıyorsan:
1. Upload keystore'u Google Play Console'a yükle
2. Google kendi release key'ini yönetir
3. Sadece upload key ile APK/AAB imzalaman yeterli

Daha fazla bilgi: https://support.google.com/googleplay/android-developer/answer/9842756
