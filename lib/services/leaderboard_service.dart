import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class LeaderboardService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Genel en çok kazanan kullanıcılar (top 10)
  static Future<List<UserModel>> getTopWinners({int limit = 10}) async {
    try {
      print('🔍 Getting top winners with limit: $limit');
      
      final response = await _client
          .from('users')
          .select('''
            *,
            user_photos(photo_url, created_at)
          ''')
          .eq('is_visible', true)
          .gte('total_matches', 50)
          .order('wins', ascending: false)
          .limit(limit);

      print('📊 Query response count: ${(response as List).length}');
      
      final users = (response as List)
          .map((json) {
            print('👤 User: ${json['username']}, wins: ${json['wins']}, photos: ${json['user_photos']?.length ?? 0}');
            return UserModel.fromJson(json);
          })
          .toList();
          
      print('✅ Returning ${users.length} users for top winners');
      return users;
    } catch (e) {
      print('Error getting top winners: $e');
      return [];
    }
  }

  // En yüksek kazanma oranına sahip kullanıcılar (top 10)
  static Future<List<UserModel>> getTopWinRate({int limit = 10}) async {
    try {
      print('🔍 Getting top win rate with limit: $limit');
      
      final response = await _client
          .from('users')
          .select('''
            *,
            user_photos(photo_url, created_at)
          ''')
          .eq('is_visible', true)
          .gte('total_matches', 50)
          .gt('total_matches', 0) // En az 1 maç yapmış olmalı
          .limit(limit * 2); // Daha fazla alıp kazanma oranına göre sıralayacağız

      print('📊 Query response count: ${(response as List).length}');

      final users = (response as List)
          .map((json) {
            print('👤 User: ${json['username']}, wins: ${json['wins']}, photos: ${json['user_photos']?.length ?? 0}');
            return UserModel.fromJson(json);
          })
          .toList();

      // Kazanma oranına göre sırala
      users.sort((a, b) => b.winRate.compareTo(a.winRate));
      
      final topUsers = users.take(limit).toList();
      print('✅ Returning ${topUsers.length} users for top win rate');
      return topUsers;
    } catch (e) {
      print('❌ Error getting top win rate: $e');
      return [];
    }
  }


  // Kullanıcının sıralamasını al
  static Future<Map<String, int>> getUserRankings(String userId) async {
    try {
      // Genel wins sıralaması
      final allUsers = await _client
          .from('users')
          .select('id, wins')
          .eq('is_visible', true)
          .order('wins', ascending: false);

      int winsRank = 1;
      for (int i = 0; i < allUsers.length; i++) {
        if (allUsers[i]['id'] == userId) {
          winsRank = i + 1;
          break;
        }
      }

      // Kazanma oranı sıralaması
      final allWinRateUsers = await _client
          .from('users')
          .select('id, wins, total_matches')
          .eq('is_visible', true)
          .gt('total_matches', 0);

      final winRateUsers = (allWinRateUsers as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      // Kazanma oranına göre sırala
      winRateUsers.sort((a, b) => b.winRate.compareTo(a.winRate));

      int winRateRank = 1;
      for (int i = 0; i < winRateUsers.length; i++) {
        if (winRateUsers[i].id == userId) {
          winRateRank = i + 1;
          break;
        }
      }

      return {
        'wins_rank': winsRank,
        'winrate_rank': winRateRank,
      };
    } catch (e) {
      print('Error getting user rankings: $e');
      return {'wins_rank': 0, 'winrate_rank': 0};
    }
  }

}
