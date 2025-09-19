import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class LeaderboardService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Genel en çok kazanan kullanıcılar (top 10)
  static Future<List<UserModel>> getTopWinners({int limit = 10}) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .not('profile_image_url', 'is', null)
          .order('wins', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting top winners: $e');
      return [];
    }
  }

  // En yüksek kazanma oranına sahip kullanıcılar (top 10)
  static Future<List<UserModel>> getTopWinRate({int limit = 10}) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .not('profile_image_url', 'is', null)
          .gt('total_matches', 0) // En az 1 maç yapmış olmalı
          .limit(limit * 2); // Daha fazla alıp kazanma oranına göre sıralayacağız

      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      // Kazanma oranına göre sırala
      users.sort((a, b) => b.winRate.compareTo(a.winRate));

      return users.take(limit).toList();
    } catch (e) {
      print('Error getting top win rate: $e');
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
