# 🍎 iOS Release için Gerekli Adımlar

## ⚠️ ÖNEMLİ: Android tamamlandıktan sonra iOS'a geç!

### 1. Apple Developer Account
- Apple Developer hesabı gerekli ($99/yıl)
- https://developer.apple.com

### 2. Firebase iOS Config
1. Firebase Console > Proje Ayarları
2. "Add app" > iOS seç
3. **Bundle ID:** `com.chizo.app` (Android ile aynı)
4. **GoogleService-Info.plist** indir
5. `ios/Runner/` klasörüne kopyala

### 3. Xcode Setup
```bash
# Xcode'u aç
open ios/Runner.xcworkspace

# Signing & Capabilities:
# - Team seç
# - Bundle Identifier: com.chizo.app
# - Automatically manage signing: ✓
```

### 4. App Icons
- 1024x1024 app icon gerekli
- Konum: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 5. Build & Archive
```bash
flutter clean
flutter pub get
flutter build ios --release

# Xcode'da:
# Product > Archive
# Validate > Distribute to App Store
```

### 6. App Store Connect
- App oluştur
- Screenshots hazırla
- Privacy Policy URL: (web/privacy-policy.html'i host et)
- Submit for Review

---

**Not:** iOS için hazır olduğunda adım adım ilerleriz!
