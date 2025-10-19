import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';
// TODO: Uncomment after adding in_app_purchase package
// import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentService {
  static final SupabaseClient _client = Supabase.instance.client;

  // TODO: Uncomment after adding in_app_purchase package
  // static final InAppPurchase _iap = InAppPurchase.instance;
  // static bool _available = true;

  // Coin paketleri - Bu ID'ler App Store Connect ve Google Play Console'da tanımlanmalı
  static const Map<String, Map<String, dynamic>> coinPackages = {
    'small': {
      'coins': 100,
      'price': 0.99,
      'description': '100 Coin',
      'productId': 'com.chizo.coins.small', // App Store/Play Store product ID
    },
    'medium': {
      'coins': 250,
      'price': 1.99,
      'description': '250 Coin',
      'productId': 'com.chizo.coins.medium',
    },
    'large': {
      'coins': 500,
      'price': 3.49,
      'description': '500 Coin',
      'productId': 'com.chizo.coins.large',
    },
    'xlarge': {
      'coins': 1000,
      'price': 5.99,
      'description': '1000 Coin',
      'productId': 'com.chizo.coins.xlarge',
    },
  };

  // TODO: IN-APP PURCHASE İÇİN GEREKLİ ADIMLAR:
  //
  // 1. pubspec.yaml'a ekle:
  //    in_app_purchase: ^3.1.13
  //
  // 2. App Store Connect'te ürün tanımla:
  //    - com.chizo.coins.small ($0.99)
  //    - com.chizo.coins.medium ($1.99)
  //    - com.chizo.coins.large ($3.49)
  //    - com.chizo.coins.xlarge ($5.99)
  //
  // 3. Google Play Console'da aynı ürünleri tanımla
  //
  // 4. Bu fonksiyonu uncomment et ve kullan

  /* GERÇEK IN-APP PURCHASE KOD ÖRNEĞİ (şimdilik comment):

  static Future<bool> purchaseCoins(String packageId) async {
    try {
      final package = coinPackages[packageId];
      if (package == null) return false;

      final String productId = package['productId'] as String;

      // 1. Ürün bilgilerini al
      final ProductDetailsResponse productResponse =
          await _iap.queryProductDetails({productId});

      if (productResponse.productDetails.isEmpty) {
        print('Product not found: $productId');
        return false;
      }

      final ProductDetails productDetails = productResponse.productDetails.first;

      // 2. Satın alma işlemini başlat
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      return await _iap.buyConsumable(purchaseParam: purchaseParam);

    } catch (e) {
      print('Error purchasing coins: $e');
      return false;
    }
  }

  // Purchase listener - uygulama başlangıcında çağrılmalı
  static void initializePurchaseListener() {
    final Stream<List<PurchaseDetails>> purchaseUpdates = _iap.purchaseStream;

    purchaseUpdates.listen((purchases) async {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          // Satın alma başarılı - coin'leri ver
          await _deliverCoins(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          // Hata - kullanıcıya bildir
          print('Purchase error: ${purchase.error}');
        }

        // Purchase'ı tamamlandı olarak işaretle
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    });
  }

  static Future<void> _deliverCoins(PurchaseDetails purchase) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      // Product ID'den package bilgisini bul
      final package = coinPackages.entries.firstWhere(
        (entry) => entry.value['productId'] == purchase.productID,
        orElse: () => throw Exception('Package not found'),
      );

      // Coin'leri kullanıcıya ekle
      await UserService.updateCoins(
        package.value['coins'] as int,
        'purchased',
        'Coin satın alma - ${package.value['description']}',
      );

      // Ödeme kaydını ekle
      await _client.from('payments').insert({
        'user_id': currentUser.id,
        'package_id': package.key,
        'amount': package.value['price'],
        'coins': package.value['coins'],
        'payment_method': 'in_app_purchase',
        'transaction_id': purchase.purchaseID,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      print('Error delivering coins: $e');
    }
  }
  */

  // ŞİMDİLİK SADECE TEST İÇİN - PRODUCTION'DA KALDIRILACAK!
  static Future<bool> purchaseCoins(String packageId, String paymentMethod) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      final package = coinPackages[packageId];
      if (package == null) return false;

      // ⚠️ TEST MODU - Gerçek para alınmıyor!
      print('⚠️ TEST MODE: Simulating purchase for ${package['description']}');
      await Future.delayed(const Duration(seconds: 1));

      // Coin'leri kullanıcıya ekle
      await UserService.updateCoins(
        package['coins']!,
        'purchased',
        'TEST - Coin satın alma - ${package['description']}'
      );

      // Ödeme kaydını ekle
      await _client.from('payments').insert({
        'user_id': currentUser.id,
        'package_id': packageId,
        'amount': package['price'],
        'coins': package['coins'],
        'payment_method': 'TEST_MODE',
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error purchasing coins: $e');
      return false;
    }
  }

  // Ödeme geçmişini getir
  static Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _client
          .from('payments')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      // print('Error getting payment history: $e');
      return [];
    }
  }

}



