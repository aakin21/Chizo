import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';

class MatchHistoryService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Kullanıcının son 5 match'ini getir
  static Future<List<Map<String, dynamic>>> getUserMatchHistory(String userId) async {
    try {
      // Kullanıcının katıldığı match'leri getir (kazanan veya kaybeden olarak)
      final response = await _client
          .from('matches')
          .select('''
            *,
            user1:users!matches_user1_id_fkey(*),
            user2:users!matches_user2_id_fkey(*)
          ''')
          .eq('is_completed', true)
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('completed_at', ascending: false)
          .limit(50);

      List<Map<String, dynamic>> matchHistory = [];

      for (var match in response) {
        final user1 = match['user1'];
        final user2 = match['user2'];
        final winnerId = match['winner_id'];
        
        // Rakip kullanıcıyı belirle (fotoğraflar olmadan)
        UserModel? opponent;
        bool isWinner = false;
        
        if (userId == user1['id']) {
          opponent = UserModel.fromJson(user2);
          isWinner = winnerId == userId;
        } else {
          opponent = UserModel.fromJson(user1);
          isWinner = winnerId == userId;
        }

        // Fotoğrafları şimdilik yükleme - lazy loading yapacağız
        print('👤 Added opponent: ${opponent.username} (photos will be loaded on demand)');

        matchHistory.add({
          'match': MatchModel.fromJson(match),
          'opponent': opponent,
          'is_winner': isWinner,
          'completed_at': match['completed_at'],
        });
      }

      return matchHistory;
    } catch (e) {
      // print('Error getting match history: $e');
      return [];
    }
  }

  // Kullanıcının match istatistiklerini hesapla
  static Future<Map<String, dynamic>> getUserMatchStats(String userId) async {
    try {
      final matchHistory = await getUserMatchHistory(userId);
      
      int totalMatches = matchHistory.length;
      int wins = matchHistory.where((match) => match['is_winner'] == true).length;
      int losses = totalMatches - wins;
      
      // Son 5 match'teki kazanma oranı
      double winRate = totalMatches > 0 ? (wins / totalMatches) * 100 : 0.0;
      
      // En çok karşılaştığı rakip
      Map<String, int> opponentCounts = {};
      for (var match in matchHistory) {
        String opponentId = match['opponent'].id;
        opponentCounts[opponentId] = (opponentCounts[opponentId] ?? 0) + 1;
      }
      
      String? mostFrequentOpponent;
      int maxCount = 0;
      opponentCounts.forEach((opponentId, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentOpponent = opponentId;
        }
      });

      return {
        'total_matches': totalMatches,
        'wins': wins,
        'losses': losses,
        'win_rate': winRate,
        'most_frequent_opponent': mostFrequentOpponent,
        'most_frequent_count': maxCount,
      };
    } catch (e) {
      // print('Error getting match stats: $e');
      return {
        'total_matches': 0,
        'wins': 0,
        'losses': 0,
        'win_rate': 0.0,
        'most_frequent_opponent': null,
        'most_frequent_count': 0,
      };
    }
  }

  /// Load photos for a specific user (lazy loading)
  static Future<UserModel?> loadUserPhotos(UserModel user) async {
    try {
      print('🔍 Lazy loading photos for: ${user.id}');
      
      final photosResponse = await _client
          .from('user_photos')
          .select('*')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('photo_order');
      
      if (photosResponse.isNotEmpty) {
        // UserModel'i fotoğraflarla birlikte yeniden oluştur
        final userData = user.toJson();
        userData['match_photos'] = photosResponse;
        final updatedUser = UserModel.fromJson(userData);
        print('✅ Lazy loaded ${photosResponse.length} photos for ${user.username}');
        return updatedUser;
      } else {
        print('❌ No photos found for ${user.username}');
        return user;
      }
    } catch (e) {
      print('❌ Error lazy loading photos: $e');
      return user;
    }
  }

}
