import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';

class UserService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Supabase client'ı public yap
  static SupabaseClient get client => _client;

  // Kullanıcı bilgilerini getir (basit ve temiz)
  static Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        print('No authenticated user');
        return null;
      }

      print('Getting current user - Auth ID: ${authUser.id}, Email: ${authUser.email}');

      // Auth ID ile kullanıcıyı bul
      final response = await _client
          .from('users')
          .select()
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (response == null) {
        print('User not found, creating new user record');
        // Yeni kullanıcı oluştur
        final newUserData = {
          'auth_id': authUser.id,
          'email': authUser.email!,
          'username': authUser.email!.split('@')[0],
          'coins': 100,
          'is_visible': true,
          'total_matches': 0,
          'wins': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final insertResponse = await _client
            .from('users')
            .insert(newUserData)
            .select()
            .single();
        
        print('New user created with ID: ${insertResponse['id']}');
        return UserModel.fromJson(insertResponse);
      }

      print('User found - ID: ${response['id']}, Matches: ${response['total_matches']}, Wins: ${response['wins']}');
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
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

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
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Coin ekle/çıkar
  static Future<bool> updateCoins(int amount, String type, String description) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      // Kullanıcının mevcut coin sayısını al
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      final newCoinAmount = currentUser.coins + amount;
      if (newCoinAmount < 0) return false; // Yetersiz coin

      // Coin miktarını güncelle
      await _client
          .from('users')
          .update({'coins': newCoinAmount})
          .eq('auth_id', authUser.id);

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

  // Kullanıcı istatistiklerini güncelle (oy verdikten sonra)
  static Future<void> updateUserStats(String userId, bool isWinner) async {
    try {
      print('Updating stats for user: $userId, isWinner: $isWinner');
      
      // Mevcut istatistikleri al
      final currentUserResponse = await _client
          .from('users')
          .select('total_matches, wins')
          .eq('id', userId)
          .single();
      
      final currentMatches = currentUserResponse['total_matches'] ?? 0;
      final currentWins = currentUserResponse['wins'] ?? 0;
      
      print('Current user data: {total_matches: $currentMatches, wins: $currentWins}');
      
      // Yeni istatistikleri hesapla
      final newMatches = currentMatches + 1;
      final newWins = isWinner ? currentWins + 1 : currentWins;
      
      print('Current matches: $currentMatches, current wins: $currentWins');
      print('Updating with data: {total_matches: $newMatches, wins: $newWins, updated_at: ${DateTime.now().toIso8601String()}}');
      
      // İstatistikleri güncelle
      final updateResult = await _client
          .from('users')
          .update({
            'total_matches': newMatches,
            'wins': newWins,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      
      print('Update result: $updateResult');
      print('User stats updated: $userId, matches: $newMatches, wins: $newWins');
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }
}
