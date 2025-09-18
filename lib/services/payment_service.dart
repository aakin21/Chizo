import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';

class PaymentService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Coin paketleri
  static const Map<String, Map<String, dynamic>> coinPackages = {
    'small': {
      'coins': 100,
      'price': 9.99,
      'description': '100 Coin',
    },
    'medium': {
      'coins': 250,
      'price': 19.99,
      'description': '250 Coin',
    },
    'large': {
      'coins': 500,
      'price': 34.99,
      'description': '500 Coin',
    },
    'xlarge': {
      'coins': 1000,
      'price': 59.99,
      'description': '1000 Coin',
    },
  };

  // Coin satın alma işlemi
  static Future<bool> purchaseCoins(String packageId, String paymentMethod) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      final package = coinPackages[packageId];
      if (package == null) return false;

      // Gerçek ödeme entegrasyonu burada yapılacak
      // Şimdilik simüle ediyoruz
      final success = await _simulatePayment(package['price']!, paymentMethod);
      
      if (success) {
        // Coin'leri kullanıcıya ekle
        await UserService.updateCoins(
          package['coins']!, 
          'purchased', 
          'Coin satın alma - ${package['description']}'
        );

        // Ödeme kaydını ekle
        await _client.from('payments').insert({
          'user_id': currentUser.id,
          'package_id': packageId,
          'amount': package['price'],
          'coins': package['coins'],
          'payment_method': paymentMethod,
          'status': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        });

        return true;
      }

      return false;
    } catch (e) {
      print('Error purchasing coins: $e');
      return false;
    }
  }

  // Ödeme simülasyonu (gerçek uygulamada bu kaldırılacak)
  static Future<bool> _simulatePayment(double amount, String paymentMethod) async {
    // Gerçek ödeme entegrasyonu için burada Stripe, PayPal vb. kullanılacak
    await Future.delayed(const Duration(seconds: 2)); // Simüle edilmiş gecikme
    
    // Şimdilik her zaman başarılı döndürüyoruz
    return true;
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
      print('Error getting payment history: $e');
      return [];
    }
  }

  // Stripe entegrasyonu için (gelecekte eklenebilir)
  static Future<bool> processStripePayment(String packageId, String stripeToken) async {
    try {
      final package = coinPackages[packageId];
      if (package == null) return false;

      // Stripe API çağrısı burada yapılacak
      // Şimdilik simüle ediyoruz
      return await _simulatePayment(package['price']!, 'stripe');
    } catch (e) {
      print('Error processing Stripe payment: $e');
      return false;
    }
  }

  // PayPal entegrasyonu için (gelecekte eklenebilir)
  static Future<bool> processPayPalPayment(String packageId, String paypalOrderId) async {
    try {
      final package = coinPackages[packageId];
      if (package == null) return false;

      // PayPal API çağrısı burada yapılacak
      // Şimdilik simüle ediyoruz
      return await _simulatePayment(package['price']!, 'paypal');
    } catch (e) {
      print('Error processing PayPal payment: $e');
      return false;
    }
  }
}



