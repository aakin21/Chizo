import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';

class UserService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Supabase client'ı public yap
  static SupabaseClient get client => _client;

  // Kullanıcı bilgilerini getir
  static Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return null;
      }

      print('Getting current user with ID: ${user.id}');

      // ID ile kullanıcıyı bul
      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('User not found in users table, creating new user record');
        // Kullanıcıyı users tablosuna ekle
        final newUserData = {
          'id': user.id,
          'email': user.email!,
          'username': user.email!.split('@')[0], // Email'den username oluştur
          'coins': 100, // Yeni kullanıcılara 100 coin hediye
          'is_visible': true, // Varsayılan olarak görünür yap
          'total_matches': 0,
          'wins': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await _client.from('users').insert(newUserData);
        print('User created in users table: ${user.id}');
        
        // Yeni oluşturulan kullanıcıyı döndür
        final userModel = UserModel.fromJson(newUserData);
        print('User model created - totalMatches: ${userModel.totalMatches}, wins: ${userModel.wins}');
        return userModel;
      }

      print('User data from database: $response');
      
      // Eski kullanıcıların istatistiklerini kontrol et ve güncelle
      final userModel = UserModel.fromJson(response);
      
      // Eğer total_matches veya wins null ise, gerçek istatistikleri hesapla
      if (userModel.totalMatches == 0 && userModel.wins == 0) {
        print('User has zero stats, calculating real stats from matches...');
        await _recalculateUserStats(user.id);
        
        // Güncellenmiş veriyi tekrar çek
        final updatedResponse = await _client
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        
        if (updatedResponse != null) {
          final updatedUserModel = UserModel.fromJson(updatedResponse);
          print('User stats recalculated - totalMatches: ${updatedUserModel.totalMatches}, wins: ${updatedUserModel.wins}');
          return updatedUserModel;
        }
      }
      
      print('User model created - totalMatches: ${userModel.totalMatches}, wins: ${userModel.wins}');
      return userModel;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Kullanıcının gerçek istatistiklerini hesapla ve güncelle
  static Future<void> _recalculateUserStats(String userId) async {
    try {
      // Toplam match sayısı (bu kullanıcının katıldığı tamamlanmış match'ler)
      final totalMatchesResponse = await _client
          .from('matches')
          .select('id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('is_completed', true);

      // Kazandığı match sayısı
      final winsResponse = await _client
          .from('matches')
          .select('id')
          .eq('winner_id', userId)
          .eq('is_completed', true);

      final totalMatches = (totalMatchesResponse as List).length;
      final wins = (winsResponse as List).length;

      print('Recalculated stats for user $userId: totalMatches=$totalMatches, wins=$wins');

      // İstatistikleri güncelle
      await _client
          .from('users')
          .update({
            'total_matches': totalMatches,
            'wins': wins,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('User stats updated in database');
    } catch (e) {
      print('Error recalculating user stats: $e');
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
