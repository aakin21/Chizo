# 💰 IN-APP PURCHASE (IAP) UYGULAMA REHBERİ

## Genel Bakış
Chizo uygulaması şu anda **TEST MODUNDA** çalışıyor. App Store ve Google Play'e yayınlamadan önce gerçek in-app purchase entegrasyonu yapılmalı.

---

## 🎯 MEVCUT DURUM

### Tanımlı Coin Paketleri:

| Paket | Coin | Fiyat | Product ID |
|-------|------|-------|------------|
| Small | 100 | $0.99 | `com.chizo.coins.small` |
| Medium | 250 | $1.99 | `com.chizo.coins.medium` |
| Large | 500 | $3.49 | `com.chizo.coins.large` |
| XLarge | 1000 | $5.99 | `com.chizo.coins.xlarge` |

**Not:** Bu Product ID'ler App Store Connect ve Google Play Console'da tanımlanmalı.

---

## 📋 ADIM ADIM UYGULAMA

### 1️⃣ PUBSPEC.YAML'A PAKET EKLE

```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

Sonra çalıştır:
```bash
flutter pub get
```

---

### 2️⃣ APP STORE CONNECT KURULUMU (iOS)

#### a) App Store Connect'e Giriş
1. https://appstoreconnect.apple.com adresine git
2. "My Apps" → Chizo uygulamanı seç
3. "Features" → "In-App Purchases" sekmesine git

#### b) Her Coin Paketi İçin Ürün Oluştur

**Small Package ($0.99):**
- Product ID: `com.chizo.coins.small`
- Reference Name: `100 Coins Package`
- Type: **Consumable** (tekrar tekrar satın alınabilir)
- Price: $0.99 (Tier 1)
- Localized Information:
  - Display Name (TR): `100 Coin`
  - Display Name (EN): `100 Coins`
  - Description: `Get 100 coins for Chizo tournaments`

**Aynı şekilde diğer paketler için:**
- `com.chizo.coins.medium` → $1.99
- `com.chizo.coins.large` → $3.49
- `com.chizo.coins.xlarge` → $5.99

#### c) Tax Category
- "Digital Products and Services" seç

#### d) Review Information
- Screenshot ekle (coin satın alma ekranının)
- Review notes yaz

---

### 3️⃣ GOOGLE PLAY CONSOLE KURULUMU (Android)

#### a) Google Play Console'e Giriş
1. https://play.google.com/console adresine git
2. Chizo uygulamanı seç
3. "Monetize" → "Products" → "In-app products" sekmesine git

#### b) Her Coin Paketi İçin Ürün Oluştur

**Product Details:**
- Product ID: `com.chizo.coins.small` (iOS ile aynı!)
- Name: `100 Coins`
- Description: `Get 100 coins for Chizo tournaments`
- Status: **Active**

**Pricing:**
- Set base plan: `$0.99 USD`
- Auto-convert to other currencies ✓

**Aynı şekilde diğer paketleri ekle**

---

### 4️⃣ KOD DEĞİŞİKLİKLERİ

#### a) payment_service.dart'taki Comment'leri Aç

**Dosya:** `lib/services/payment_service.dart`

1. Satır 3-4'teki import'u uncomment et:
```dart
import 'package:in_app_purchase/in_app_purchase.dart';
```

2. Satır 10-11'deki instance'ları uncomment et:
```dart
static final InAppPurchase _iap = InAppPurchase.instance;
static bool _available = true;
```

3. Satır 56-145'teki gerçek IAP kodunu uncomment et

4. Satır 147-183'teki TEST modunu **sil** veya comment yap

#### b) main.dart'a Purchase Listener Ekle

**Dosya:** `lib/main.dart`

`main()` fonksiyonuna ekle:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... Firebase ve Supabase init ...

  // In-App Purchase listener'ı başlat
  PaymentService.initializePurchaseListener();

  runApp(const MyApp());
}
```

#### c) coin_purchase_screen.dart'ı Güncelle

**Dosya:** `lib/screens/coin_purchase_screen.dart`

Satın alma çağrısını güncelle (satır ~50):
```dart
// ESKİ (TEST):
final success = await PaymentService.purchaseCoins(packageId, 'simulated');

// YENİ (GERÇEK IAP):
final success = await PaymentService.purchaseCoins(packageId);
```

---

### 5️⃣ iOS ÖZEL AYARLARI

#### a) Info.plist Güncelle

**Dosya:** `ios/Runner/Info.plist`

Ekle:
```xml
<key>SKPaymentTransactionObserver</key>
<string>PaymentService</string>
```

#### b) StoreKit Configuration (Test İçin)

1. Xcode'da projeyi aç
2. File → New → File → StoreKit Configuration File
3. `Products.storekit` adıyla kaydet
4. Test ürünlerini ekle (aynı Product ID'lerle)

---

### 6️⃣ ANDROID ÖZEL AYARLARI

#### a) build.gradle Güncellemesi

**Dosya:** `android/app/build.gradle`

Zaten yapılandırılmış olmalı, kontrol et:
```gradle
android {
    defaultConfig {
        // ...
        minSdkVersion 21  // En az 21 olmalı
    }
}
```

#### b) ProGuard Kuralları

**Dosya:** `android/app/proguard-rules.pro`

Ekle:
```
-keep class com.android.vending.billing.**
```

---

### 7️⃣ TEST ETME

#### iOS'ta Test:
1. Xcode'da StoreKit Configuration File kullan
2. Veya TestFlight'ta Sandbox test kullanıcısı oluştur
3. Settings → App Store → Sandbox Account

#### Android'de Test:
1. Google Play Console → "License Testing"
2. Test email adresi ekle
3. Internal Testing track'e yükle

---

## ⚠️ ÖNEMLİ NOTLAR

### Güvenlik
1. **Server-Side Validation:**
   - Satın almaları mutlaka server'da doğrula
   - Supabase Edge Function kullanarak receipt verification yap
   - Sahte satın almaları engellemek için gerekli!

2. **Transaction ID Kontrolü:**
   - Aynı transaction ID ile birden fazla coin verilmesin
   - `payments` tablosuna `transaction_id` kolonu ekle (UNIQUE constraint ile)

### Apple Review
- App Store Review için gerçekten satın alınabilir olmalı
- Test mode kalmamalı
- Screenshots hazır olmalı

### Google Play Review
- En az 1 saat test süresine ihtiyaç var
- Internal Testing'de test et
- Production'a almadan önce tüm paketleri test et

---

## 🚨 YAYIN ÖNCESİ KONTROL LİSTESİ

- [ ] `in_app_purchase` paketi eklendi
- [ ] App Store Connect'te 4 ürün tanımlandı ve **Ready to Submit**
- [ ] Google Play Console'da 4 ürün tanımlandı ve **Active**
- [ ] payment_service.dart'taki comment'ler açıldı
- [ ] TEST modu kodu silindi veya comment yapıldı
- [ ] main.dart'a `initializePurchaseListener()` eklendi
- [ ] iOS'ta StoreKit test'leri başarılı
- [ ] Android'de Internal Testing başarılı
- [ ] Server-side receipt validation eklendi (Supabase Edge Function)
- [ ] Transaction ID duplicate kontrolü eklendi
- [ ] Privacy Policy'de IAP bildirildi

---

## 📞 SORUN GİDERME

### "Product not found" Hatası
- Product ID'ler App Store/Play Console ile tamamen aynı mı?
- Ürünler "Ready to Submit" (iOS) veya "Active" (Android) durumunda mı?
- Bundle ID doğru mu?

### "Cannot connect to App Store" Hatası
- Test kullanıcısı doğru mu?
- StoreKit configuration doğru mu?
- Internet bağlantısı var mı?

### Satın Alma Tamamlanmıyor
- `completePurchase()` çağrılıyor mu?
- Purchase listener düzgün dinliyor mu?
- Callback fonksiyonu çalışıyor mu?

---

## 🔗 KAYNAKLAR

- [Official Flutter IAP Plugin](https://pub.dev/packages/in_app_purchase)
- [Apple IAP Docs](https://developer.apple.com/in-app-purchase/)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [RevenueCat (Alternatif)](https://www.revenuecat.com/) - Daha kolay entegrasyon

---

**Hazırlayan:** Claude Code (AI Assistant)
**Tarih:** 2025-10-19
**Versiyon:** 1.0
