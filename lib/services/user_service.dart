import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';

class UserService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Kullanıcı bilgilerini getir
  static Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // ID ile kullanıcıyı bul (daha güvenli)
      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Kullanıcı profilini güncelle
  static Future<bool> updateProfile({
    String? username,
    int? age,
    String? country,
    String? gender,
    String? instagramHandle,
    String? profession,
    String? profileImageUrl,
    bool? isVisible,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (age != null) updateData['age'] = age;
      if (country != null) updateData['country'] = country;
      if (gender != null) updateData['gender'] = gender;
      if (instagramHandle != null) updateData['instagram_handle'] = instagramHandle;
      if (profession != null) updateData['profession'] = profession;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;
      if (isVisible != null) updateData['is_visible'] = isVisible;

      await _client
          .from('users')
          .update(updateData)
          .eq('id', user.id);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Coin ekle/çıkar
  static Future<bool> updateCoins(int amount, String type, String description) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Kullanıcının mevcut coin sayısını al
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      final newCoinAmount = currentUser.coins + amount;
      if (newCoinAmount < 0) return false; // Yetersiz coin

      // Coin miktarını güncelle
      await _client
          .from('users')
          .update({'coins': newCoinAmount})
          .eq('email', user.email!);

      // Coin transaction kaydı ekle
      await _client.from('coin_transactions').insert({
        'user_id': currentUser.id,
        'amount': amount,
        'type': type,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error updating coins: $e');
      return false;
    }
  }

  // Kullanıcının coin transaction geçmişini getir
  static Future<List<CoinTransactionModel>> getCoinTransactions() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return [];

      final response = await _client
          .from('coin_transactions')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CoinTransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting coin transactions: $e');
      return [];
    }
  }

  // Kullanıcının beğeni istatistiklerini getir
  static Future<Map<String, int>> getUserStats() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return {};

      // Kazandığı match sayısı
      final winsResponse = await _client
          .from('matches')
          .select('id')
          .eq('winner_id', currentUser.id)
          .eq('is_completed', true);

      // Toplam match sayısı
      final totalMatchesResponse = await _client
          .from('matches')
          .select('id')
          .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}')
          .eq('is_completed', true);

      final wins = (winsResponse as List).length;
      final totalMatches = (totalMatchesResponse as List).length;

      return {
        'wins': wins,
        'totalMatches': totalMatches,
        'winRate': totalMatches > 0 ? ((wins / totalMatches) * 100).round() : 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

}
