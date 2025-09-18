import 'dart:math';
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

      // Tüm tamamlanmamış match'leri getir (kendisi dahil değil)
      final response = await _client
          .from('matches')
          .select('''
            *,
            user1:users!matches_user1_id_fkey(*),
            user2:users!matches_user2_id_fkey(*)
          ''')
          .eq('is_completed', false)
          .neq('user1_id', user.id)  // Kendisi user1 değil
          .neq('user2_id', user.id)  // Kendisi user2 değil
          .limit(10);

      print('Total matches found: ${response.length}');
      for (var match in response) {
        print('Match ID: ${match['id']}');
        print('User1: ${match['user1']?['username'] ?? 'NULL'}');
        print('User2: ${match['user2']?['username'] ?? 'NULL'}');
      }

      // Sadece her iki kullanıcısı da mevcut olan match'leri filtrele
      final validMatches = <MatchModel>[];
      final invalidMatchIds = <String>[];
      
      for (var matchData in response) {
        if (matchData['user1'] != null && 
            matchData['user2'] != null &&
            matchData['user1']['is_visible'] == true &&
            matchData['user2']['is_visible'] == true &&
            matchData['user1']['profile_image_url'] != null &&
            matchData['user2']['profile_image_url'] != null) {
          validMatches.add(MatchModel.fromJson(matchData));
        } else {
          // Geçersiz match'i işaretle
          invalidMatchIds.add(matchData['id']);
        }
      }

      // Geçersiz match'leri sil
      for (var matchId in invalidMatchIds) {
        await _client
            .from('matches')
            .delete()
            .eq('id', matchId);
        print('Invalid match deleted: $matchId');
      }

      return validMatches;
    } catch (e) {
      print('Error getting votable matches: $e');
      return [];
    }
  }

  // TÜM match'leri sil (nuclear option)
  static Future<void> deleteAllMatches() async {
    try {
      await _client
          .from('matches')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'); // Tüm match'leri sil
      print('All matches deleted!');
    } catch (e) {
      print('Error deleting all matches: $e');
    }
  }

  // akin123 ve alpcakin kullanıcılarını sil
  static Future<void> deleteProblematicUsers() async {
    try {
      await _client
          .from('users')
          .delete()
          .inFilter('username', ['akin123', 'alpcakin']);
      print('Problematic users deleted!');
    } catch (e) {
      print('Error deleting problematic users: $e');
    }
  }

  // Silinmiş kullanıcıların match'lerini temizle
  static Future<void> cleanupInvalidMatches() async {
    try {
      // Tüm tamamlanmamış match'leri getir
      final allMatches = await _client
          .from('matches')
          .select('''
            *,
            user1:users!matches_user1_id_fkey(*),
            user2:users!matches_user2_id_fkey(*)
          ''')
          .eq('is_completed', false);

      // Silinmiş kullanıcıların match'lerini bul ve sil
      for (var match in allMatches) {
        if (match['user1'] == null || match['user2'] == null) {
          await _client
              .from('matches')
              .delete()
              .eq('id', match['id']);
          print('Invalid match deleted: ${match['id']}');
        }
      }
    } catch (e) {
      print('Error cleaning up invalid matches: $e');
    }
  }

  // Oylama yap
  static Future<bool> voteForMatch(String matchId, String winnerId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Önce kullanıcının users tablosunda olup olmadığını kontrol et
      final userExists = await _client
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (userExists == null) {
        print('User not found in users table: ${user.id}');
        // Kullanıcıyı users tablosuna ekle (sadece temel bilgiler)
        await _client.from('users').insert({
          'id': user.id,
          'email': user.email!,
          'username': user.email!.split('@')[0], // Email'den username oluştur
          'coins': 100, // Yeni kullanıcılara 100 coin hediye
          'is_visible': true, // Varsayılan olarak görünür yap
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('User added to users table: ${user.id}');
      }

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
        'is_correct': true, // Oy veren kazananı belirliyor
        'created_at': DateTime.now().toIso8601String(),
      });

      // Match'i tamamla
      await completeMatch(matchId, winnerId);

      // Kazanan kullanıcının istatistiklerini güncelle
      await _updateUserStats(winnerId, true);

      // Kaybeden kullanıcının istatistiklerini güncelle
      final match = await _client
          .from('matches')
          .select('user1_id, user2_id')
          .eq('id', matchId)
          .single();
      
      final loserId = match['user1_id'] == winnerId ? match['user2_id'] : match['user1_id'];
      await _updateUserStats(loserId, false);

      return true;
    } catch (e) {
      print('Error voting for match: $e');
      return false;
    }
  }

  // Kullanıcı istatistiklerini güncelle
  static Future<void> _updateUserStats(String userId, bool isWinner) async {
    try {
      // Kullanıcının mevcut istatistiklerini al
      final user = await _client
          .from('users')
          .select('total_matches, wins')
          .eq('id', userId)
          .single();

      final currentMatches = user['total_matches'] ?? 0;
      final currentWins = user['wins'] ?? 0;

      // İstatistikleri güncelle
      await _client
          .from('users')
          .update({
            'total_matches': currentMatches + 1,
            'wins': isWinner ? currentWins + 1 : currentWins,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('User stats updated: $userId, matches: ${currentMatches + 1}, wins: ${isWinner ? currentWins + 1 : currentWins}');
    } catch (e) {
      print('Error updating user stats: $e');
      // Eğer total_matches veya wins kolonları yoksa, sadece updated_at'i güncelle
      try {
        await _client
            .from('users')
            .update({
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
        print('User updated_at updated: $userId');
      } catch (e2) {
        print('Error updating user updated_at: $e2');
      }
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

  // Random match generation algorithm
  static Future<List<MatchModel>> generateRandomMatches({int matchCount = 5}) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      // Get all visible users with profile pictures, grouped by gender (excluding current user)
      final maleUsers = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .eq('gender', 'Erkek')
          .not('profile_image_url', 'is', null)
          .neq('id', currentUser.id); // Exclude current user

      final femaleUsers = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .eq('gender', 'Kadın')
          .not('profile_image_url', 'is', null)
          .neq('id', currentUser.id); // Exclude current user

      print('Male users with is_visible=true: ${maleUsers.length}');
      print('Female users with is_visible=true: ${femaleUsers.length}');
      
      // Debug: Tüm kullanıcıları göster
      final allUsers = await _client.from('users').select();
      print('Total users in database: ${allUsers.length}');
      for (var user in allUsers) {
        print('User: ${user['username']}, is_visible: ${user['is_visible']}, gender: ${user['gender']}, has_image: ${user['profile_image_url'] != null}');
      }


      List<MatchModel> createdMatches = [];

      // Create matches for male users
      if (maleUsers.length >= 2) {
        final maleMatches = _createMatchesFromUsers(maleUsers, (maleUsers.length / 2).floor());
        for (var match in maleMatches) {
          final user1Id = match['user1_id'];
          final user2Id = match['user2_id'];
          if (user1Id != null && user2Id != null) {
            final createdMatch = await createMatch(user1Id, user2Id);
            if (createdMatch != null) {
              createdMatches.add(createdMatch);
            }
          }
        }
      }

      // Create matches for female users
      if (femaleUsers.length >= 2) {
        final femaleMatches = _createMatchesFromUsers(femaleUsers, (femaleUsers.length / 2).floor());
        for (var match in femaleMatches) {
          final user1Id = match['user1_id'];
          final user2Id = match['user2_id'];
          if (user1Id != null && user2Id != null) {
            final createdMatch = await createMatch(user1Id, user2Id);
            if (createdMatch != null) {
              createdMatches.add(createdMatch);
            }
          }
        }
      }

      print('Generated ${createdMatches.length} random matches');
      return createdMatches;
    } catch (e) {
      print('Error generating random matches: $e');
      return [];
    }
  }

      // Helper function to create matches from a list of users
      static List<Map<String, String>> _createMatchesFromUsers(List users, int maxMatches) {
        List<Map<String, String>> matches = [];
        List availableUsers = List.from(users);
        
        // Multiple shuffle for better randomness
        for (int i = 0; i < 3; i++) {
          availableUsers.shuffle();
        }
        
        int matchesCreated = 0;
        while (availableUsers.length >= 2 && matchesCreated < maxMatches) {
          // Randomly select two users
          final random = Random();
          final index1 = random.nextInt(availableUsers.length);
          final user1 = availableUsers.removeAt(index1);
          
          final index2 = random.nextInt(availableUsers.length);
          final user2 = availableUsers.removeAt(index2);
          
          matches.add({
            'user1_id': user1['id'],
            'user2_id': user2['id'],
          });
          
          matchesCreated++;
        }
        
        return matches;
      }

}
