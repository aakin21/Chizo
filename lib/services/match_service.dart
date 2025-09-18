import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class MatchService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Yeni match oluştur
  static Future<MatchModel?> createMatch(String user1Id, String user2Id) async {
    try {
      final response = await _client.from('matches').insert({
        'user1_id': user1Id,
        'user2_id': user2Id,
        'created_at': DateTime.now().toIso8601String(),
        'is_completed': false,
      }).select().single();

      return MatchModel.fromJson(response);
    } catch (e) {
      print('Error creating match: $e');
      return null;
    }
  }

  // Random iki kullanıcı seç (aynı cinsiyet)
  static Future<List<UserModel>> getRandomUsersForMatch(String currentUserId, {int limit = 2}) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null || currentUser.gender == null) return [];

      // Aynı cinsiyetten, görünür olan, kendisi olmayan kullanıcıları getir
      final response = await _client
          .from('users')
          .select()
          .eq('gender', currentUser.gender!)
          .eq('is_visible', true)
          .neq('id', currentUserId)
          .not('profile_image_url', 'is', null)
          .limit(limit);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting random users: $e');
      return [];
    }
  }

  // Match'i tamamla (kazanan belirle)
  static Future<bool> completeMatch(String matchId, String winnerId) async {
    try {
      await _client
          .from('matches')
          .update({
            'winner_id': winnerId,
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', matchId);

      // Kazanan kullanıcıya 1 coin ver
      await UserService.updateCoins(1, 'earned', 'Match kazandı');

      return true;
    } catch (e) {
      print('Error completing match: $e');
      return false;
    }
  }

  // Kullanıcının oylama yapabileceği match'leri getir
  static Future<List<MatchModel>> getVotableMatches() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      // Henüz tamamlanmamış match'leri getir
      final response = await _client
          .from('matches')
          .select('''
            *,
            user1:users!matches_user1_id_fkey(*),
            user2:users!matches_user2_id_fkey(*)
          ''')
          .eq('is_completed', false)
          .neq('user1_id', user.id)
          .neq('user2_id', user.id)
          .limit(10);

      return (response as List)
          .map((json) => MatchModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting votable matches: $e');
      return [];
    }
  }

  // Oylama yap
  static Future<bool> voteForMatch(String matchId, String winnerId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Önce bu kullanıcının bu match için oy verip vermediğini kontrol et
      final existingVote = await _client
          .from('votes')
          .select('id')
          .eq('match_id', matchId)
          .eq('voter_id', user.id)
          .maybeSingle();

      if (existingVote != null) {
        return false; // Zaten oy vermiş
      }

      // Oy kaydını ekle
      await _client.from('votes').insert({
        'match_id': matchId,
        'voter_id': user.id,
        'winner_id': winnerId,
        'is_correct': false, // Başlangıçta false, match tamamlandığında güncellenecek
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error voting for match: $e');
      return false;
    }
  }

  // Match tamamlandığında oyları kontrol et ve coin ver
  static Future<void> checkVotesAndReward(String matchId, String actualWinnerId) async {
    try {
      // Bu match için verilen oyları getir
      final votes = await _client
          .from('votes')
          .select()
          .eq('match_id', matchId);

      for (var vote in votes) {
        final isCorrect = vote['winner_id'] == actualWinnerId;
        
        // Oyu güncelle
        await _client
            .from('votes')
            .update({'is_correct': isCorrect})
            .eq('id', vote['id']);

        // Doğru tahmin edenlere coin ver
        if (isCorrect) {
          await UserService.updateCoins(1, 'earned', 'Doğru tahmin');
        }
      }
    } catch (e) {
      print('Error checking votes: $e');
    }
  }

  // Match'teki kullanıcıları getir
  static Future<List<UserModel>> getMatchUsers(String user1Id, String user2Id) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .inFilter('id', [user1Id, user2Id]);
      
      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting match users: $e');
      return [];
    }
  }
}
