import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class PremiumService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Instagram hesabını görme
  static Future<String?> viewInstagramHandle(String targetUserId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      // Kullanıcının coin kontrolü
      final user = await UserService.getCurrentUser();
      if (user == null || user.coins < 10) {
        return null; // Yetersiz coin
      }

      // Hedef kullanıcının Instagram hesabını getir
      final response = await _client
          .from('users')
          .select('instagram_handle')
          .eq('id', targetUserId)
          .single();

      final instagramHandle = response['instagram_handle'];
      if (instagramHandle == null) return null;

      // Coin düş
      await UserService.updateCoins(-10, 'spent', 'Instagram hesabı görme');

      return instagramHandle;
    } catch (e) {
      print('Error viewing Instagram handle: $e');
      return null;
    }
  }

  // Meslek bilgisini görme
  static Future<String?> viewProfession(String targetUserId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      // Kullanıcının coin kontrolü
      final user = await UserService.getCurrentUser();
      if (user == null || user.coins < 5) {
        return null; // Yetersiz coin
      }

      // Hedef kullanıcının meslek bilgisini getir
      final response = await _client
          .from('users')
          .select('profession')
          .eq('id', targetUserId)
          .single();

      final profession = response['profession'];
      if (profession == null) return null;

      // Coin düş
      await UserService.updateCoins(-5, 'spent', 'Meslek bilgisi görme');

      return profession;
    } catch (e) {
      print('Error viewing profession: $e');
      return null;
    }
  }

  // Kullanıcının beğeni istatistiklerini görme
  static Future<Map<String, dynamic>?> viewUserStats(String targetUserId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      // Kullanıcının coin kontrolü
      final user = await UserService.getCurrentUser();
      if (user == null || user.coins < 3) {
        return null; // Yetersiz coin
      }

      // Hedef kullanıcının istatistiklerini getir
      final winsResponse = await _client
          .from('matches')
          .select('id')
          .eq('winner_id', targetUserId)
          .eq('is_completed', true);

      final totalMatchesResponse = await _client
          .from('matches')
          .select('id')
          .or('user1_id.eq.$targetUserId,user2_id.eq.$targetUserId')
          .eq('is_completed', true);

      final wins = (winsResponse as List).length;
      final totalMatches = (totalMatchesResponse as List).length;
      final winRate = totalMatches > 0 ? ((wins / totalMatches) * 100).round() : 0;

      // Coin düş
      await UserService.updateCoins(-3, 'spent', 'Kullanıcı istatistikleri görme');

      return {
        'wins': wins,
        'totalMatches': totalMatches,
        'winRate': winRate,
      };
    } catch (e) {
      print('Error viewing user stats: $e');
      return null;
    }
  }

  // Filtreleme seçenekleri
  static Future<bool> updateVisibilitySettings({
    String? country,
    int? minAge,
    int? maxAge,
    String? gender,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (country != null) updateData['country'] = country;
      if (minAge != null) updateData['min_age'] = minAge;
      if (maxAge != null) updateData['max_age'] = maxAge;
      if (gender != null) updateData['gender'] = gender;

      await _client
          .from('users')
          .update(updateData)
          .eq('id', currentUser.id);

      return true;
    } catch (e) {
      print('Error updating visibility settings: $e');
      return false;
    }
  }

  // Filtrelenmiş kullanıcıları getir
  static Future<List<UserModel>> getFilteredUsers({
    String? country,
    int? minAge,
    int? maxAge,
    String? gender,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .not('profile_image_url', 'is', null);

      if (country != null) {
        query = query.eq('country', country);
      }

      if (minAge != null) {
        query = query.gte('age', minAge);
      }

      if (maxAge != null) {
        query = query.lte('age', maxAge);
      }

      if (gender != null) {
        query = query.eq('gender', gender);
      }

      final response = await query.limit(limit);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting filtered users: $e');
      return [];
    }
  }
}



