import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'photo_upload_service.dart';

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
      return null;
    }
  }

  // Random iki kullanıcı seç (aynı cinsiyet) - çoklu fotoğraf desteği ile
  static Future<List<UserModel>> getRandomUsersForMatch(String currentUserId, {int limit = 2}) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null || currentUser.genderCode == null) return [];

      // Aynı cinsiyetten, görünür olan, kendisi olmayan kullanıcıları getir
      // Ülke filtreleme burada yapılmaz - bu fonksiyon sadece match oluşturmak için kullanılır
      final response = await _client
          .from('users')
          .select()
          .eq('gender_code', currentUser.genderCode!)
          .eq('is_visible', true)
          .neq('id', currentUserId)
          .limit(limit);

      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      // Her kullanıcı için çoklu fotoğrafları yükle
      for (int i = 0; i < users.length; i++) {
        final user = users[i];
        final photos = await PhotoUploadService.getUserPhotos(user.id);
        
        // Tüm fotoğrafları kullan (artık profil fotoğrafı yok)
        final allPhotos = List<Map<String, dynamic>>.from(photos);
        
        // UserModel'e çoklu fotoğrafları ekle
        users[i] = UserModel(
          id: user.id,
          username: user.username,
          email: user.email,
          coins: user.coins,
          age: user.age,
          countryCode: user.countryCode,
          genderCode: user.genderCode,
          instagramHandle: user.instagramHandle,
          profession: user.profession,
          isVisible: user.isVisible,
          showInstagram: user.showInstagram,
          showProfession: user.showProfession,
          totalMatches: user.totalMatches,
          wins: user.wins,
          currentStreak: user.currentStreak,
          totalStreakDays: user.totalStreakDays,
          lastLoginDate: user.lastLoginDate,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          matchPhotos: allPhotos,
        );
      }

      return users;
    } catch (e) {
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

      // NOT: Kazanan kullanıcıya artık direkt coin verilmiyor
      // Coin kazanmak için win rate prediction sistemi kullanılıyor

      return true;
    } catch (e) {
      return false;
    }
  }

  // Kullanıcının oylama yapabileceği match'leri getir
  static Future<List<MatchModel>> getVotableMatches() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      // Önce kullanıcının users tablosundaki ID'sini al
      final currentUserRecord = await _client
          .from('users')
          .select('id, country')
          .eq('auth_id', user.id)
          .maybeSingle();
      
      if (currentUserRecord == null) {
        return [];
      }
      
      final currentUserId = currentUserRecord['id'];
      final currentUserCountry = currentUserRecord['country'];

      // Tüm tamamlanmamış match'leri getir (kendisi dahil değil)
      final response = await _client
          .from('matches')
          .select('''
            *,
            user1:users!matches_user1_id_fkey(*),
            user2:users!matches_user2_id_fkey(*)
          ''')
          .eq('is_completed', false)
          .neq('user1_id', currentUserId)  // Kendisi user1 değil
          .neq('user2_id', currentUserId)  // Kendisi user2 değil
          .limit(10);


      // Sadece her iki kullanıcısı da mevcut olan VE ülke tercihlerine uygun match'leri filtrele
      final validMatches = <MatchModel>[];
      final invalidMatchIds = <String>[];
      
      for (var matchData in response) {
        if (matchData['user1'] != null && 
            matchData['user2'] != null &&
            matchData['user1']['is_visible'] == true &&
            matchData['user2']['is_visible'] == true) {
          
          // Ülke filtreleme kontrolü
          // Match'teki kullanıcıların ülke tercihleri, mevcut kullanıcının ülkesini içeriyorsa match'i dahil et
          List<String>? user1CountryPreferences = matchData['user1']['country_preferences'] != null 
              ? List<String>.from(matchData['user1']['country_preferences'])
              : null;
          List<String>? user2CountryPreferences = matchData['user2']['country_preferences'] != null 
              ? List<String>.from(matchData['user2']['country_preferences'])
              : null;
          
          // Eğer kullanıcıların ülke tercihi yoksa, tüm ülkelerden oylanabilir
          bool user1AllowsCurrentUser = user1CountryPreferences == null || 
              user1CountryPreferences.isEmpty || 
              currentUserCountry == null ||
              user1CountryPreferences.contains(currentUserCountry);
          bool user2AllowsCurrentUser = user2CountryPreferences == null || 
              user2CountryPreferences.isEmpty || 
              currentUserCountry == null ||
              user2CountryPreferences.contains(currentUserCountry);
          
          if (user1AllowsCurrentUser && user2AllowsCurrentUser) {
            validMatches.add(MatchModel.fromJson(matchData));
          } else {
          }
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
      }

      return validMatches;
    } catch (e) {
      return [];
    }
  }


  // Oylama yap
  static Future<bool> voteForMatch(String matchId, String winnerId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Önce kullanıcının users tablosunda olup olmadığını kontrol et
      var userExists = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userExists == null) {
        // Kullanıcıyı users tablosuna ekle (sadece temel bilgiler)
        await _client.from('users').insert({
          'auth_id': user.id,
          'email': user.email!,
          'username': user.email!.split('@')[0], // Email'den username oluştur
          'coins': 100, // Yeni kullanıcılara 100 coin hediye
          'is_visible': true, // Varsayılan olarak görünür yap
          'show_instagram': false,
          'show_profession': false,
          'total_matches': 0,
          'wins': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        // Yeni oluşturulan kullanıcının ID'sini al
        userExists = await _client
            .from('users')
            .select('id')
            .eq('auth_id', user.id)
            .single();
      }

      // Önce bu kullanıcının bu match için oy verip vermediğini kontrol et
      final existingVote = await _client
          .from('votes')
          .select('id')
          .eq('match_id', matchId)
          .eq('voter_id', userExists['id']) // users tablosundaki id'yi kullan
          .maybeSingle();

      if (existingVote != null) {
        return false; // Zaten oy vermiş
      }

      // Oy kaydını ekle
      await _client.from('votes').insert({
        'match_id': matchId,
        'voter_id': userExists['id'], // users tablosundaki id'yi kullan
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
          .maybeSingle();
      
      if (match != null) {
        final loserId = match['user1_id'] == winnerId ? match['user2_id'] : match['user1_id'];
        await _updateUserStats(loserId, false);
      }

      // NOT: Artık oy veren kullanıcıya direkt coin verilmiyor
      // Coin kazanmak için win rate prediction yapması gerekiyor

      return true;
    } catch (e) {
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
          .maybeSingle();

      if (user == null) {
        return;
      }

      final currentMatches = user['total_matches'] ?? 0;
      final currentWins = user['wins'] ?? 0;

      // İstatistikleri güncelle
      final updateData = {
        'total_matches': currentMatches + 1,
        'wins': isWinner ? currentWins + 1 : currentWins,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      
      await _client
          .from('users')
          .update(updateData)
          .eq('id', userId);

    } catch (e) {
      // Eğer total_matches veya wins kolonları yoksa, sadece updated_at'i güncelle
      try {
        await _client
            .from('users')
            .update({
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      } catch (e2) {
      }
    }
  }

  // Match tamamlandığında oyları kontrol et (coin verme kaldırıldı)
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

        // NOT: Artık doğru tahmin edenlere direkt coin verilmiyor
        // Coin kazanmak için win rate prediction sistemi kullanılıyor
      }
    } catch (e) {
      print('Error: $e');
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
      return [];
    }
  }


  // Random match generation algorithm
  static Future<List<MatchModel>> generateRandomMatches({int matchCount = 5}) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      // Duplicate cleanup'ı sadece gerektiğinde manuel olarak çağır
      // await cleanupDuplicateUsers();

      // Önce kullanıcının users tablosundaki ID'sini al
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();
      
      if (currentUserRecord == null) {
        return [];
      }
      
      final currentUserId = currentUserRecord['id'];

      // Get all visible users with photos, grouped by gender (excluding current user)
      // Ülke filtreleme burada yapılmaz - match oluştururken tüm kullanıcılar kullanılır
      final maleUsers = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .eq('gender', 'Erkek')
          .neq('id', currentUserId); // Exclude current user

      final femaleUsers = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .eq('gender', 'Kadın')
          .neq('id', currentUserId); // Exclude current user

      
      // Debug: Tüm kullanıcıları göster
      // final allUsers = await _client.from('users').select();
      // for (var user in allUsers) {
      //   // // print('User: ${user['username']}, is_visible: ${user['is_visible']}, gender: ${user['gender']}, country: ${user['country']}');
      // }


      List<MatchModel> createdMatches = [];

      // Create matches for male users - COMPLETELY NEW ALGORITHM
      if (maleUsers.length >= 2) {
        // Filter users who have photos
        final maleUsersWithPhotos = <Map<String, dynamic>>[];
        for (var user in maleUsers) {
          final photos = await PhotoUploadService.getUserPhotos(user['id']);
          if (photos.isNotEmpty) {
            maleUsersWithPhotos.add(user);
          }
        }
        
        
        if (maleUsersWithPhotos.length >= 2) {
          // Convert to UserModel list for better handling
          final maleUserModels = maleUsersWithPhotos.map((user) => UserModel.fromJson(user)).toList();
        
        // Create matches with maximum diversity
        for (int i = 0; i < matchCount && maleUserModels.length >= 2; i++) {
          // Create a completely new random seed each time
          final random = Random(DateTime.now().millisecondsSinceEpoch + i * 1000 + Random().nextInt(10000));
          
          // Shuffle the entire list
          maleUserModels.shuffle(random);
          
          // Pick two random users from the shuffled list
          final randomIndex1 = random.nextInt(maleUserModels.length);
          final user1 = maleUserModels[randomIndex1];
          
          // Remove user1 temporarily to avoid self-match
          final tempUser1 = maleUserModels.removeAt(randomIndex1);
          
          // Pick second user from remaining list
          final randomIndex2 = random.nextInt(maleUserModels.length);
          final user2 = maleUserModels[randomIndex2];
          
          // Add user1 back to the list
          maleUserModels.insert(randomIndex1, tempUser1);
          
          final createdMatch = await createMatch(user1.id, user2.id);
          if (createdMatch != null) {
            createdMatches.add(createdMatch);
          }
          
          // If we have less than 2 users left, break
          if (maleUserModels.length < 2) break;
        }
        }
      }

      // Create matches for female users - COMPLETELY NEW ALGORITHM
      if (femaleUsers.length >= 2) {
        // Filter users who have photos
        final femaleUsersWithPhotos = <Map<String, dynamic>>[];
        for (var user in femaleUsers) {
          final photos = await PhotoUploadService.getUserPhotos(user['id']);
          if (photos.isNotEmpty) {
            femaleUsersWithPhotos.add(user);
          }
        }
        
        
        if (femaleUsersWithPhotos.length >= 2) {
          // Convert to UserModel list for better handling
          final femaleUserModels = femaleUsersWithPhotos.map((user) => UserModel.fromJson(user)).toList();
        
        // Create matches with maximum diversity
        for (int i = 0; i < matchCount && femaleUserModels.length >= 2; i++) {
          // Create a completely new random seed each time
          final random = Random(DateTime.now().millisecondsSinceEpoch + i * 2000 + Random().nextInt(10000));
          
          // Shuffle the entire list
          femaleUserModels.shuffle(random);
          
          // Pick two random users from the shuffled list
          final randomIndex1 = random.nextInt(femaleUserModels.length);
          final user1 = femaleUserModels[randomIndex1];
          
          // Remove user1 temporarily to avoid self-match
          final tempUser1 = femaleUserModels.removeAt(randomIndex1);
          
          // Pick second user from remaining list
          final randomIndex2 = random.nextInt(femaleUserModels.length);
          final user2 = femaleUserModels[randomIndex2];
          
          // Add user1 back to the list
          femaleUserModels.insert(randomIndex1, tempUser1);
          
          final createdMatch = await createMatch(user1.id, user2.id);
          if (createdMatch != null) {
            createdMatches.add(createdMatch);
          }
          
          // If we have less than 2 users left, break
          if (femaleUserModels.length < 2) break;
        }
        }
      }


      return createdMatches;
    } catch (e) {
      return [];
    }
  }


}
