import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/tournament_model.dart';
import 'user_service.dart';

class TournamentService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Client getter'ı ekle
  static SupabaseClient get client => _client;

  // Supabase client'ın API anahtarını test et
  static Future<void> testSupabaseConnection() async {
    try {
      // Testing Supabase connection...
      // Supabase URL: https://rsuptwsgnpgsvlqigitq.supabase.co
      // Supabase Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
      
      // Basit bir test sorgusu
      await _client
          .from('tournaments')
          .select('count')
          .limit(1);
      
    } catch (e) {
      // Supabase connection test failed: $e
      if (e.toString().contains('apikey')) {
        // API Key issue detected in connection test
      }
    }
  }

  // Aktif turnuvaları getir (yeni sistem) - private turnuva kontrolü ile
  static Future<List<TournamentModel>> getActiveTournaments({String? language}) async {
    try {
      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      
      // Basit sorgu ile başla - sadece sistem turnuvaları
      var query = _client
          .from('tournaments')
          .select()
          .inFilter('status', ['upcoming', 'active'])
          .eq('is_private', false);
      
      final systemTournaments = await query.order('entry_fee', ascending: true);
      
      // Private turnuvaları sadece kullanıcı varsa getir
      List<dynamic> privateTournaments = [];
      if (currentUser != null) {
        try {
          // Önce katılım ID'lerini al
          final participatedIds = await _getUserParticipatedTournamentIds(currentUser.id);
          
          // Key ile katılan turnuva ID'lerini al
          final viewedIds = await _getUserViewedTournamentIds(currentUser.id);
          
          // Tüm erişim ID'lerini birleştir
          final allAccessIds = [...participatedIds, ...viewedIds];
          
          // Güvenli sorgu - SQL injection'dan korunmak için iki ayrı sorgu
          List<dynamic> creatorTournaments = [];
          List<dynamic> accessTournaments = [];

          // 1. Kullanıcının oluşturduğu turnuvalar
          creatorTournaments = await _client
              .from('tournaments')
              .select()
              .inFilter('status', ['upcoming', 'active'])
              .eq('is_private', true)
              .eq('creator_id', currentUser.id)
              .order('entry_fee', ascending: true);

          // 2. Erişim hakları olan turnuvalar (katılımcı veya key ile)
          if (allAccessIds.isNotEmpty) {
            accessTournaments = await _client
                .from('tournaments')
                .select()
                .inFilter('status', ['upcoming', 'active'])
                .eq('is_private', true)
                .inFilter('id', allAccessIds)
                .order('entry_fee', ascending: true);
          }

          // Birleştir ve duplicate'leri kaldır
          final seenIds = <int>{};
          privateTournaments = [...creatorTournaments, ...accessTournaments]
              .where((tournament) => seenIds.add(tournament['id'] as int))
              .toList();
        } catch (e) {
          print('Error: $e');
      // Private turnuva sorgusu hatası
        }
      }
      
      // Tüm turnuvaları birleştir
      final allTournaments = [...systemTournaments, ...privateTournaments];
      
      final tournaments = allTournaments
          .map((json) => TournamentModel.fromJson(json))
          .toList();
      
      return tournaments;
    } catch (e) {
      return [];
    }
  }

  // Kullanıcının katıldığı private turnuva ID'lerini getir
  static Future<List<String>> _getUserParticipatedTournamentIds(String userId) async {
    try {
      final participations = await _client
          .from('tournament_participants')
          .select('tournament_id')
          .eq('user_id', userId);
      
      if (participations.isEmpty) {
        return [];
      }
      
      final ids = participations.map((p) => p['tournament_id'] as String).toList();
      
      return ids;
    } catch (e) {
      return [];
    }
  }

  // Kullanıcının key ile katıldığı private turnuva ID'lerini getir
  static Future<List<String>> _getUserViewedTournamentIds(String userId) async {
    try {
      final views = await _client
          .from('tournament_viewers')
          .select('tournament_id')
          .eq('user_id', userId);
      
      if (views.isEmpty) {
        return [];
      }
      
      final ids = views.map((v) => v['tournament_id'] as String).toList();
      
      return ids;
    } catch (e) {
      // Tablo yoksa veya hata varsa boş liste döndür
      print('Error getting user viewed tournaments: $e');
      return [];
    }
  }


  // Test turnuvalarını temizle
  static Future<void> cleanupTestTournaments() async {
    try {
      // Test turnuvalarını sil
      await _client
          .from('tournaments')
          .delete()
          .like('name', '%Test%');
      
      // Test turnuva katılımcılarını sil
      await _client
          .from('tournament_participants')
          .delete()
          .inFilter('tournament_id', 
            await _client
                .from('tournaments')
                .select('id')
                .like('name', '%Test%')
                .then((result) => (result as List).map((t) => t['id']).toList())
          );
      
    } catch (e) {
      print('Error: $e');
    }
  }



  // Otomatik haftalık turnuva sistemi - sadece 5000 coinlik turnuvalar
  static Future<void> createWeeklyTournaments() async {
    try {
      await create5000CoinTournaments();
    } catch (e) {
      print('Error: $e');
      // Error creating weekly tournaments
    }
  }





  // 5000 coinlik turnuvaları oluştur (100 kişi dolduğunda başlayan)
  static Future<void> create5000CoinTournaments() async {
    try {
      final existingTournaments = await _client
          .from('tournaments')
          .select('id, name, status, current_participants')
          .eq('entry_fee', 5000)
          .eq('is_private', false)
          .eq('is_system_tournament', true)
          .inFilter('status', ['upcoming', 'active']);

      if ((existingTournaments as List).isEmpty) {
        await _create5000CoinTournament('Erkek');
        await _create5000CoinTournament('Kadın');
      }
    } catch (e) {
      print('Error: $e');
      // Error creating 5000 coin tournaments
    }
  }

  // 5000 coinlik turnuva oluştur
  static Future<void> _create5000CoinTournament(String gender) async {
    try {
      final tournamentId = const Uuid().v4();
      final nameKey = gender == 'Erkek' ? 'instantMaleTournament5000' : 'instantFemaleTournament5000';
      final descriptionKey = gender == 'Erkek' ? 'instantMaleTournament5000Description' : 'instantFemaleTournament5000Description';
      
      await _client.from('tournaments').insert({
        'id': tournamentId,
        'name_key': nameKey,
        'description_key': descriptionKey,
        'entry_fee': 5000,
        'prize_pool': 5000 * 100,
        'max_participants': 100,
        'current_participants': 0,
        'start_date': null,
        'end_date': null,
        'status': 'upcoming',
        'gender': gender,
        'current_phase': 'registration',
        'registration_start_date': DateTime.now().toIso8601String(),
        'voting_start_date': null,
        'voting_end_date': null,
        'quarter_final_date': null,
        'semi_final_date': null,
        'final_date': null,
        'is_private': false,
        'is_system_tournament': true,
        'tournament_format': 'hybrid',
        'language': 'system',
        'created_at': DateTime.now().toIso8601String(),
        'countdown_start_date': null,
      });
    } catch (e) {
      print('Error: $e');
      // Error creating 5000 coin tournament
    }
  }

  // Debug: Mevcut turnuvaların name_key durumunu kontrol et
  static Future<void> debugTournamentNameKeys() async {
    try {
      final tournaments = await _client
          .from('tournaments')
          .select('id, name, name_key, entry_fee, gender, is_system_tournament')
          .eq('entry_fee', 5000)
          .eq('is_system_tournament', true);
      
      print('🔍 DEBUG: 5000 coin turnuvalar:');
      for (var tournament in tournaments) {
        print('  - ID: ${tournament['id']}');
        print('    Name: ${tournament['name']}');
        print('    Name Key: ${tournament['name_key']}');
        print('    Gender: ${tournament['gender']}');
        print('    ---');
      }
    } catch (e) {
      print('❌ DEBUG: Error checking tournament name keys: $e');
    }
  }

  // Mevcut turnuvaların name_key alanlarını güncelle
  static Future<void> updateExistingTournamentNameKeys() async {
    try {
      final tournaments = await _client
          .from('tournaments')
          .select('id, name_key, entry_fee, gender, is_system_tournament')
          .eq('entry_fee', 5000)
          .eq('is_system_tournament', true);
      
      for (var tournament in tournaments) {
        final tournamentId = tournament['id'];
        final gender = tournament['gender'];
        final currentNameKey = tournament['name_key'];
        
        // Eğer name_key yoksa veya yanlışsa güncelle
        String? newNameKey;
        String? newDescriptionKey;
        
        if (gender == 'Erkek') {
          newNameKey = 'instantMaleTournament5000';
          newDescriptionKey = 'instantMaleTournament5000Description';
        } else if (gender == 'Kadın') {
          newNameKey = 'instantFemaleTournament5000';
          newDescriptionKey = 'instantFemaleTournament5000Description';
        }
        
        if (newNameKey != null && currentNameKey != newNameKey) {
          print('🔄 DEBUG: Updating tournament $tournamentId name_key to $newNameKey');
          await _client
              .from('tournaments')
              .update({
                'name_key': newNameKey,
                'description_key': newDescriptionKey,
              })
              .eq('id', tournamentId);
        }
      }
    } catch (e) {
      print('❌ DEBUG: Error updating tournament name keys: $e');
    }
  }

  // 5000 coinlik turnuvaları kontrol et ve gerekirse başlat
  static Future<void> checkAndStart5000CoinTournaments() async {
    try {
      final readyTournaments = await _client
          .from('tournaments')
          .select('id, name, current_participants, countdown_start_date')
          .eq('entry_fee', 5000)
          .eq('status', 'upcoming')
          .eq('is_system_tournament', true)
          .gte('current_participants', 100);

      for (var tournament in readyTournaments) {
        final countdownStartDate = tournament['countdown_start_date'];
        
        if (countdownStartDate == null) {
          final now = DateTime.now();
          final startTime = now.add(const Duration(hours: 1));
          
          await _client
              .from('tournaments')
              .update({
                'countdown_start_date': now.toIso8601String(),
                'start_date': startTime.toIso8601String(),
                'voting_start_date': startTime.toIso8601String(),
                'voting_end_date': startTime.add(const Duration(days: 3)).toIso8601String(),
                'quarter_final_date': startTime.add(const Duration(days: 4)).toIso8601String(),
                'semi_final_date': startTime.add(const Duration(days: 5)).toIso8601String(),
                'final_date': startTime.add(const Duration(days: 6)).toIso8601String(),
                'end_date': startTime.add(const Duration(days: 6)).toIso8601String(),
              })
              .eq('id', tournament['id']);
        } else {
          final countdownStart = DateTime.parse(countdownStartDate);
          final now = DateTime.now();
          
          if (now.isAfter(countdownStart.add(const Duration(hours: 1)))) {
            await _start5000CoinTournament(tournament['id']);
          }
        }
      }
    } catch (e) {
      print('Error: $e');
      // Error checking 5000 coin tournaments
    }
  }

  // 5000 coinlik turnuvayı başlat
  static Future<void> _start5000CoinTournament(String tournamentId) async {
    try {
      await _client
          .from('tournaments')
          .update({
            'status': 'active',
            'current_phase': 'qualifying',
            'current_round': 1,
            'phase_start_date': DateTime.now().toIso8601String(),
          })
          .eq('id', tournamentId);
          
    } catch (e) {
      print('Error: $e');
      // Error starting 5000 coin tournament
    }
  }

  // 5000 coinlik turnuvaların fazlarını güncelle
  static Future<void> _update5000CoinTournamentPhases() async {
    try {
      final now = DateTime.now();
      
      // Aktif 5000 coinlik turnuvaları getir
      final activeTournaments = await _client
          .from('tournaments')
          .select('id, name, current_phase, start_date, quarter_final_date, semi_final_date, final_date')
          .eq('entry_fee', 5000)
          .eq('status', 'active')
          .eq('is_system_tournament', true);

      for (var tournament in activeTournaments) {
        final quarterFinalDate = DateTime.parse(tournament['quarter_final_date']);
        final semiFinalDate = DateTime.parse(tournament['semi_final_date']);
        final finalDate = DateTime.parse(tournament['final_date']);
        
        // 4. gün: Çeyrek final
        if (now.isAfter(quarterFinalDate) && tournament['current_phase'] == 'qualifying') {
          await _advance5000CoinToQuarterFinals(tournament['id']);
        }
        // 5. gün: Yarı final
        else if (now.isAfter(semiFinalDate) && tournament['current_phase'] == 'quarter_finals') {
          await _advance5000CoinToSemiFinals(tournament['id']);
        }
        // 6. gün: Final
        else if (now.isAfter(finalDate) && tournament['current_phase'] == 'semi_final') {
          await _complete5000CoinTournament(tournament['id']);
        }
      }
    } catch (e) {
      print('Error: $e');
      // Error updating 5000 coin tournament phases
    }
  }

  // 5000 coinlik turnuvayı çeyrek finale geçir
  static Future<void> _advance5000CoinToQuarterFinals(String tournamentId) async {
    try {
      // En yüksek skorlu 8 kişiyi al
      final top8 = await _client
          .from('tournament_participants')
          .select('id, user_id, score')
          .eq('tournament_id', tournamentId)
          .eq('is_eliminated', false)
          .order('score', ascending: false)
          .limit(8);
      
      if (top8.length >= 8) {
        // Diğerlerini ele
        await _client
            .from('tournament_participants')
            .update({'is_eliminated': true})
            .eq('tournament_id', tournamentId)
            .not('id', 'in', top8.map((p) => p['id']).toList());
        
        // Çeyrek final match'lerini oluştur (herkes aynı matchleri görecek)
        await _create5000CoinQuarterFinalMatches(tournamentId, top8);
        
        // Turnuva fazını güncelle
        await _client
            .from('tournaments')
            .update({
              'current_phase': 'quarter_finals',
              'current_round': 4,
              'phase_start_date': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);
      }
          
    } catch (e) {
      print('Error: $e');
      // Error advancing 5000 coin tournament to quarter finals
    }
  }

  // 5000 coinlik turnuvayı yarı finale geçir
  static Future<void> _advance5000CoinToSemiFinals(String tournamentId) async {
    try {
      // En yüksek skorlu 4 kişiyi al
      final top4 = await _client
          .from('tournament_participants')
          .select('id, user_id, score')
          .eq('tournament_id', tournamentId)
          .eq('is_eliminated', false)
          .order('score', ascending: false)
          .limit(4);
      
      if (top4.length >= 4) {
        // Diğerlerini ele
        await _client
            .from('tournament_participants')
            .update({'is_eliminated': true})
            .eq('tournament_id', tournamentId)
            .not('id', 'in', top4.map((p) => p['id']).toList());
        
        // Yarı final match'lerini oluştur (herkes aynı matchleri görecek)
        await _create5000CoinSemiFinalMatches(tournamentId, top4);
        
        // Turnuva fazını güncelle
        await _client
            .from('tournaments')
            .update({
              'current_phase': 'semi_final',
              'current_round': 5,
              'phase_start_date': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);
      }
          
    } catch (e) {
      print('Error: $e');
      // Error advancing 5000 coin tournament to semi finals
    }
  }

  // 5000 coinlik turnuvayı tamamla
  static Future<void> _complete5000CoinTournament(String tournamentId) async {
    try {
      // En yüksek skorlu 2 kişiyi al
      final top2 = await _client
          .from('tournament_participants')
          .select('id, user_id, score')
          .eq('tournament_id', tournamentId)
          .eq('is_eliminated', false)
          .order('score', ascending: false)
          .limit(2);
      
      if (top2.length >= 2) {
        // Diğerlerini ele
        await _client
            .from('tournament_participants')
            .update({'is_eliminated': true})
            .eq('tournament_id', tournamentId)
            .not('id', 'in', top2.map((p) => p['id']).toList());
        
        // Final match'ini oluştur (herkes aynı matchi görecek)
        await _create5000CoinFinalMatch(tournamentId, top2);
        
        // Turnuva fazını güncelle
        await _client
            .from('tournaments')
            .update({
              'current_phase': 'final',
              'current_round': 6,
              'phase_start_date': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);
      }

      // İlk 4'ü getir (final için 2, 3.lük için 2)
      final topParticipants = await _client
          .from('tournament_participants')
          .select('user_id, score')
          .eq('tournament_id', tournamentId)
          .eq('is_eliminated', false)
          .order('score', ascending: false)
          .limit(4);

      if (topParticipants.length < 4) return;

      // Final için ilk 2 (1. ve 2. sıradakiler)
      final finalists = topParticipants.take(2).toList();
      final winner = finalists[0]; // 1. sıradaki kazanan
      final runnerUp = finalists[1]; // 2. sıradaki ikinci
      
      // 3.lük maçı için 3. ve 4. sıradakiler
      final thirdPlaceContestants = topParticipants.skip(2).take(2).toList();
      final thirdPlace = thirdPlaceContestants[0]; // 3. sıradaki üçüncü

      // Ödülleri hesapla
      const firstPrize = 600000; // 600.000 coin
      const secondPrize = 300000; // 300.000 coin
      const thirdPrize = 50000; // 100.000 coin

      // Şampiyonların detaylı bilgilerini al
      final winnerDetails = await _getUserDetails(winner['user_id']);
      final runnerUpDetails = await _getUserDetails(runnerUp['user_id']);
      final thirdPlaceDetails = await _getUserDetails(thirdPlace['user_id']);

      // Turnuva bilgilerini al
      final tournamentDetails = await _client
          .from('tournaments')
          .select('name, gender')
          .eq('id', tournamentId)
          .single();

      // Ödülleri ver
      await UserService.updateCoins(firstPrize, 'earned', '5000 Coinlik Turnuva 1.lik');
      await UserService.updateCoins(secondPrize, 'earned', '5000 Coinlik Turnuva 2.lik');
      await UserService.updateCoins(thirdPrize, 'earned', '5000 Coinlik Turnuva 3.lük');

      // Turnuvayı tamamla
      await _client
          .from('tournaments')
          .update({
            'status': 'completed',
            'current_phase': 'completed',
            'winner_id': winner['user_id'],
            'second_place_id': runnerUp['user_id'],
            'third_place_id': thirdPlace['user_id'],
            'phase_start_date': DateTime.now().toIso8601String(),
          })
          .eq('id', tournamentId);

      // Şampiyonları kaydet
      await saveTournamentWinners(
        tournamentId: tournamentId,
        tournamentName: tournamentDetails['name'] ?? '5000 Coinlik Turnuva',
        tournamentType: 'instant_5000',
        tournamentGender: tournamentDetails['gender'] ?? 'Erkek',
        firstPlaceUserId: winner['user_id'],
        firstPlaceUsername: winnerDetails['username'] ?? 'Bilinmeyen',
        firstPlacePhotoUrl: winnerDetails['tournament_photo_url'],
        firstPlacePrize: firstPrize,
        secondPlaceUserId: runnerUp['user_id'],
        secondPlaceUsername: runnerUpDetails['username'] ?? 'Bilinmeyen',
        secondPlacePhotoUrl: runnerUpDetails['tournament_photo_url'],
        secondPlacePrize: secondPrize,
        thirdPlaceUserId: thirdPlace['user_id'],
        thirdPlaceUsername: thirdPlaceDetails['username'] ?? 'Bilinmeyen',
        thirdPlacePhotoUrl: thirdPlaceDetails['tournament_photo_url'],
        thirdPlacePrize: thirdPrize,
      );

      // Yeni 5000 coinlik turnuva oluştur
      await create5000CoinTournaments();
    } catch (e) {
      print('Error: $e');
      // Error completing 5000 coin tournament
    }
  }

  // 5000 coinlik turnuva çeyrek final match'lerini oluştur
  static Future<void> _create5000CoinQuarterFinalMatches(String tournamentId, List<Map<String, dynamic>> top8) async {
    try {
      // 4 çeyrek final match'i oluştur
      final matches = [
        [top8[0], top8[7]], // 1. vs 8.
        [top8[1], top8[6]], // 2. vs 7.
        [top8[2], top8[5]], // 3. vs 6.
        [top8[3], top8[4]], // 4. vs 5.
      ];

      for (int i = 0; i < matches.length; i++) {
        final match = matches[i];
        await _client.from('tournament_matches').insert({
          'id': const Uuid().v4(),
          'tournament_id': tournamentId,
          'phase': 'quarter_finals',
          'match_number': i + 1,
          'user1_id': match[0]['user_id'],
          'user2_id': match[1]['user_id'],
          'is_completed': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
    } catch (e) {
      print('Error: $e');
      // Error creating 5000 coin quarter final matches
    }
  }

  // 5000 coinlik turnuva yarı final match'lerini oluştur
  static Future<void> _create5000CoinSemiFinalMatches(String tournamentId, List<Map<String, dynamic>> top4) async {
    try {
      // 2 yarı final match'i oluştur
      final matches = [
        [top4[0], top4[3]], // 1. vs 4.
        [top4[1], top4[2]], // 2. vs 3.
      ];

      for (int i = 0; i < matches.length; i++) {
        final match = matches[i];
        await _client.from('tournament_matches').insert({
          'id': const Uuid().v4(),
          'tournament_id': tournamentId,
          'phase': 'semi_finals',
          'match_number': i + 1,
          'user1_id': match[0]['user_id'],
          'user2_id': match[1]['user_id'],
          'is_completed': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
    } catch (e) {
      print('Error: $e');
      // Error creating 5000 coin semi final matches
    }
  }

  // 5000 coinlik turnuva final match'ini oluştur
  static Future<void> _create5000CoinFinalMatch(String tournamentId, List<Map<String, dynamic>> top2) async {
    try {
      // 1 final match'i oluştur
      await _client.from('tournament_matches').insert({
        'id': const Uuid().v4(),
        'tournament_id': tournamentId,
        'phase': 'final',
        'match_number': 1,
        'user1_id': top2[0]['user_id'],
        'user2_id': top2[1]['user_id'],
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      print('Error: $e');
      // Error creating 5000 coin final match
    }
  }

  // 5000 coinlik turnuva match'lerini getir (herkes aynı matchleri görür)
  static Future<List<Map<String, dynamic>>> get5000CoinTournamentMatches(String tournamentId) async {
    try {
      final matches = await _client
          .from('tournament_matches')
          .select('''
            id,
            phase,
            match_number,
            user1_id,
            user2_id,
            is_completed,
            user1:users!tournament_matches_user1_id_fkey(
              id,
              username,
              profile_image_url,
              age,
              country,
              gender
            ),
            user2:users!tournament_matches_user2_id_fkey(
              id,
              username,
              profile_image_url,
              age,
              country,
              gender
            )
          ''')
          .eq('tournament_id', tournamentId)
          .eq('is_completed', false)
          .order('phase', ascending: true)
          .order('match_number', ascending: true);

      return matches.map((match) => {
        'match_id': match['id'],
        'phase': match['phase'],
        'match_number': match['match_number'],
        'user1': {
          'id': match['user1']['id'],
          'username': match['user1']['username'],
          'profile_image_url': match['user1']['profile_image_url'],
          'age': match['user1']['age'],
          'country': match['user1']['country'],
          'gender': match['user1']['gender'],
        },
        'user2': {
          'id': match['user2']['id'],
          'username': match['user2']['username'],
          'profile_image_url': match['user2']['profile_image_url'],
          'age': match['user2']['age'],
          'country': match['user2']['country'],
          'gender': match['user2']['gender'],
        },
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Turnuva şampiyonlarını getir
  static Future<List<Map<String, dynamic>>> getTournamentWinners() async {
    try {
      final response = await _client
          .from('tournament_winners')
          .select('*')
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Kullanıcı detaylarını getir
  static Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    try {
      final response = await _client
          .from('tournament_participants')
          .select('''
            users!tournament_participants_user_id_fkey(
              username,
              profile_image_url
            ),
            tournament_photo_url
          ''')
          .eq('user_id', userId)
          .single();

      return {
        'username': response['users']['username'],
        'profile_image_url': response['users']['profile_image_url'],
        'tournament_photo_url': response['tournament_photo_url'],
      };
    } catch (e) {
      return {
        'username': 'Bilinmeyen',
        'profile_image_url': null,
        'tournament_photo_url': null,
      };
    }
  }

  // Turnuva şampiyonlarını kaydet
  static Future<void> saveTournamentWinners({
    required String tournamentId,
    required String tournamentName,
    required String tournamentType,
    required String tournamentGender,
    required String firstPlaceUserId,
    required String firstPlaceUsername,
    required String? firstPlacePhotoUrl,
    required int firstPlacePrize,
    required String secondPlaceUserId,
    required String secondPlaceUsername,
    required String? secondPlacePhotoUrl,
    required int secondPlacePrize,
    required String thirdPlaceUserId,
    required String thirdPlaceUsername,
    required String? thirdPlacePhotoUrl,
    required int thirdPlacePrize,
  }) async {
    try {
      await _client.from('tournament_winners').insert({
        'tournament_id': tournamentId,
        'tournament_name': tournamentName,
        'tournament_type': tournamentType,
        'tournament_gender': tournamentGender,
        'completed_at': DateTime.now().toIso8601String(),
        'first_place_user_id': firstPlaceUserId,
        'first_place_username': firstPlaceUsername,
        'first_place_photo_url': firstPlacePhotoUrl,
        'first_place_prize': firstPlacePrize,
        'second_place_user_id': secondPlaceUserId,
        'second_place_username': secondPlaceUsername,
        'second_place_photo_url': secondPlacePhotoUrl,
        'second_place_prize': secondPlacePrize,
        'third_place_user_id': thirdPlaceUserId,
        'third_place_username': thirdPlaceUsername,
        'third_place_photo_url': thirdPlacePhotoUrl,
        'third_place_prize': thirdPlacePrize,
      });
      
    } catch (e) {
      print('Error: $e');
      // Error saving tournament winners
    }
  }




  // Turnuvaya katıl (yeni sistem)
  static Future<bool> joinTournament(String tournamentId) async {
    try {
      
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      // Cinsiyet kontrolü - M/F ile Erkek/Kadın karşılaştırması
      final tournamentGender = tournament['gender'];
      if (tournamentGender != null && tournamentGender != 'all') {
        bool canJoin = false;
        if (currentUser.genderCode == 'M' && tournamentGender == 'Erkek') {
          canJoin = true;
        } else if (currentUser.genderCode == 'F' && tournamentGender == 'Kadın') {
          canJoin = true;
        }
        
        if (!canJoin) {
          return false; // Cinsiyet uyumsuzluğu
        }
      }

      // Turnuva durumu kontrolü
      if (tournament['status'] != 'upcoming' && tournament['status'] != 'active') {
        return false; // Kayıt kapalı
      }
      
      // Private turnuvalar için start date kontrolü
      if (tournament['is_private'] && tournament['status'] == 'upcoming') {
        final startDate = DateTime.parse(tournament['start_date']);
        if (DateTime.now().isAfter(startDate)) {
          return false; // Start date geçmiş, kayıt kapalı
        }
      }

      // Sistem turnuvaları için coin kontrolü
      if (!tournament['is_private'] && currentUser.coins < tournament['entry_fee']) {
        return false; // Yetersiz coin
      }

      // Turnuva dolu mu kontrol et
      if (tournament['current_participants'] >= tournament['max_participants']) {
        return false; // Turnuva dolu
      }

      // Zaten katılmış mı kontrol et
      final existingParticipation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingParticipation != null) {
        return false; // Zaten katılmış
      }

      // Atomic tournament join (race condition önlendi)
      final result = await _client.rpc('join_tournament', params: {
        'p_tournament_id': tournamentId,
        'p_user_id': currentUser.id,
        'p_photo_id': currentUser.id, // photo_id yerine user_id kullan (geçici)
      });

      if (result == null || result.isEmpty || result[0]['success'] != true) {
        return false;
      }

      // Turnuva başlatma mantığı - YENİ SİSTEM:
      // Çarşamba 00:01'de otomatik olarak başlar (zamanlama sistemi ile)
      // Manuel başlatma kaldırıldı - sadece zamanlama sistemi çalışacak

      return true;
    } catch (e) {
      return false;
    }
  }


  // Kullanıcının katıldığı turnuvaları getir
  static Future<List<TournamentModel>> getUserTournaments() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('tournament_participants')
          .select('''
            tournament:tournaments(*)
          ''')
          .eq('user_id', user.id)
          .eq('is_eliminated', false);

      return (response as List)
          .map((json) => TournamentModel.fromJson(json['tournament']))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Turnuva detaylarını getir
  static Future<TournamentModel?> getTournamentDetails(String tournamentId) async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      return TournamentModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Turnuva katılımcılarını getir
  static Future<List<Map<String, dynamic>>> getTournamentParticipants(String tournamentId) async {
    try {
      // Turnuva creator bilgisini al (admin işaretlemek için)
      final tournamentRow = await _client
          .from('tournaments')
          .select('creator_id, is_private')
          .eq('id', tournamentId)
          .maybeSingle();

      final String? creatorId = tournamentRow != null ? tournamentRow['creator_id'] as String? : null;

      final response = await _client
          .from('tournament_participants')
          .select('''
            id,
            user_id,
            joined_at,
            is_eliminated,
            score,
            tournament_photo_url,
            user:users!inner(
              id,
              username,
              profile_image_url,
              coins
            )
          ''')
          .eq('tournament_id', tournamentId)
          .order('joined_at', ascending: true);

      // Katılımcıları alfabetik sırala (username'e göre)
      final participants = List<Map<String, dynamic>>.from(response);
      participants.sort((a, b) {
        final usernameA = a['user']['username']?.toString().toLowerCase() ?? '';
        final usernameB = b['user']['username']?.toString().toLowerCase() ?? '';
        return usernameA.compareTo(usernameB);
      });

      // Creator katıldıysa, onu admin olarak işaretle (private koşulu aramadan)
      for (final participant in participants) {
        final participantUserId = participant['user_id'] as String?;
        participant['is_admin'] = (creatorId != null && participantUserId != null && participantUserId == creatorId);
      }

      return participants;
    } catch (e) {
      return [];
    }
  }


  // Private turnuva sıralamasını getir (match kazanma sayısına göre)
  static Future<List<Map<String, dynamic>>> getPrivateTournamentLeaderboard(String tournamentId) async {
    try {
      final response = await _client
          .from('tournament_participants')
          .select('''
            id,
            user_id,
            wins_count,
            is_eliminated,
            tournament_photo_url,
            joined_at,
            users!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('tournament_id', tournamentId)
          .order('wins_count', ascending: false)
          .order('joined_at', ascending: true);

      // Response'u düzenle - users tablosundan gelen veriyi profiles olarak map et
      final List<Map<String, dynamic>> result = [];
      for (var item in response) {
        result.add({
          'id': item['id'],
          'user_id': item['user_id'],
          'wins_count': item['wins_count'],
          'is_eliminated': item['is_eliminated'],
          'tournament_photo_url': item['tournament_photo_url'],
          'joined_at': item['joined_at'],
          'profiles': {
            'username': item['users']['username'],
            'profile_photo_url': item['users']['profile_image_url'],
          }
        });
      }

      return result;
    } catch (e) {
      print('Error getting private tournament leaderboard: $e');
      return [];
    }
  }

  // Turnuva sıralamasını getir
  static Future<List<Map<String, dynamic>>> getTournamentLeaderboard(String tournamentId) async {
    try {
      final response = await _client
          .from('tournament_participants')
          .select('''
            id,
            user_id,
            score,
            is_eliminated,
            tournament_photo_url,
            joined_at,
            users!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('tournament_id', tournamentId)
          .order('score', ascending: false)
          .order('joined_at', ascending: true);

      // Response'u düzenle - users tablosundan gelen veriyi profiles olarak map et
      final List<Map<String, dynamic>> participants = [];
      for (var item in response) {
        participants.add({
          'id': item['id'],
          'user_id': item['user_id'],
          'score': item['score'],
          'is_eliminated': item['is_eliminated'],
          'tournament_photo_url': item['tournament_photo_url'],
          'joined_at': item['joined_at'],
          'profiles': {
            'username': item['users']['username'],
            'profile_photo_url': item['users']['profile_image_url'],
          }
        });
      }

      // Katılımcıları alfabetik sırala (username'e göre)
      participants.sort((a, b) {
        final usernameA = a['profiles']['username']?.toString().toLowerCase() ?? '';
        final usernameB = b['profiles']['username']?.toString().toLowerCase() ?? '';
        return usernameA.compareTo(usernameB);
      });

      return participants;
    } catch (e) {
      print('Error getting tournament leaderboard: $e');
      return [];
    }
  }

  // Turnuva oylaması yap
  static Future<bool> voteInTournament(String tournamentId, String participantId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Kullanıcının daha önce oy verip vermediğini kontrol et
      final existingVote = await _client
          .from('tournament_votes')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('voter_id', user.id)
          .eq('participant_id', participantId)
          .maybeSingle();

      if (existingVote != null) return false; // Zaten oy vermiş

      // Oy ver
      await _client.from('tournament_votes').insert({
        'tournament_id': tournamentId,
        'voter_id': user.id,
        'participant_id': participantId,
        'voted_at': DateTime.now().toIso8601String(),
      });

      // Katılımcının skorunu artır
      await _client
          .from('tournament_participants')
          .update({'score': 'score + 1'})
          .eq('id', participantId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Bu fonksiyonlar artık kullanılmıyor - 1000 coinlik haftalık turnuvalar kaldırıldı

  // Bu fonksiyonlar artık kullanılmıyor - 1000 coinlik haftalık turnuvalar kaldırıldı

  // Turnuva katılımını iptal et ve coin iadesi yap
  static Future<bool> refundTournamentEntry(String tournamentId) async {
    try {
      
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select('entry_fee')
          .eq('id', tournamentId)
          .single();

      // Turnuva katılımını sil
      await _client
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser.id);

      // Coin iadesi yap
      final newCoinAmount = currentUser.coins + tournament['entry_fee'];
      await _client
          .from('users')
          .update({
            'coins': newCoinAmount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser.id);

      // Turnuva katılımcı sayısını manuel olarak güncelle (RPC yerine)
      final currentCount = await _client
          .from('tournaments')
          .select('current_participants')
          .eq('id', tournamentId)
          .single();
      
      final newCount = (currentCount['current_participants'] as int) - 1;
      await _client
          .from('tournaments')
          .update({'current_participants': newCount})
          .eq('id', tournamentId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Turnuva fotoğrafı yükle
  static Future<bool> uploadTournamentPhoto(String tournamentId, String photoUrl) async {
    try {
      print('🎯 UPLOAD DEBUG: Starting photo upload for tournament $tournamentId');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ UPLOAD DEBUG: No authenticated user');
        return false;
      }
      print('✅ UPLOAD DEBUG: User authenticated: ${user.id}');

      // Kullanıcının users tablosundaki ID'sini al (auth_id -> users.id)
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (currentUserRecord == null) {
        print('❌ UPLOAD DEBUG: Current user record not found');
        return false;
      }
      final currentUserId = currentUserRecord['id'];
      print('✅ UPLOAD DEBUG: Current user ID: $currentUserId');

      // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
      print('🎯 UPLOAD DEBUG: Checking participation...');
      final participation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (participation == null) {
        print('❌ UPLOAD DEBUG: User not participating in tournament');
        return false;
      }
      print('✅ UPLOAD DEBUG: User is participating, participation ID: ${participation['id']}');

      // Turnuva fotoğrafını güncelle
      print('🎯 UPLOAD DEBUG: Updating tournament photo...');
      await _client
          .from('tournament_participants')
          .update({
            'tournament_photo_url': photoUrl,
          })
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUserId);

      print('✅ UPLOAD DEBUG: Photo upload successful');
      return true;
    } catch (e) {
      print('❌ UPLOAD DEBUG: Error uploading photo: $e');
      return false;
    }
  }

  // Turnuva oylaması için match'leri getir
  static Future<List<Map<String, dynamic>>> getTournamentMatchesForVoting() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      // Kullanıcının users tablosundaki ID'sini al
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();
      
      if (currentUserRecord == null) return [];

      final currentUserId = currentUserRecord['id'];

      // Aktif haftalık turnuvaları getir (sadece sistem turnuvaları)
      final tournaments = await _client
          .from('tournaments')
          .select('id, gender')
          .eq('status', 'active')
          .eq('is_private', false)  // Sadece haftalık turnuvalar
          .inFilter('current_phase', ['qualifying', 'quarter_final', 'semi_final', 'final']);

      if (tournaments.isEmpty) return [];

      // Kullanıcının katıldığı turnuvaları kontrol et
      final userParticipations = await _client
          .from('tournament_participants')
          .select('tournament_id')
          .eq('user_id', currentUserId)
          .eq('is_eliminated', false);

      final userTournamentIds = userParticipations
          .map((p) => p['tournament_id'] as String)
          .toList();

      // Kendisinin katıldığı turnuvaları filtrele (sadece katıldığı turnuvalardan oylayamaz)
      final votableTournaments = tournaments
          .where((t) => !userTournamentIds.contains(t['id']))
          .toList();

      if (votableTournaments.isEmpty) return [];

      // Random turnuva seç
      final randomTournament = votableTournaments[Random().nextInt(votableTournaments.length)];
      
      // Bu turnuvadan random 2 katılımcı seç
      final participants = await _client
          .from('tournament_participants')
          .select('''
            user_id,
            tournament_photo_url,
            users!tournament_participants_user_id_fkey(username, profile_image_url, age, country, gender)
          ''')
          .eq('tournament_id', randomTournament['id'])
          .eq('is_eliminated', false)
          .not('tournament_photo_url', 'is', null);

      if (participants.length < 2) return [];

      // Random 2 katılımcı seç
      participants.shuffle(Random());
      final selectedParticipants = participants.take(2).toList();

      return [{
        'tournament_id': randomTournament['id'],
        'tournament_name': 'Turnuva Oylaması',
        'is_tournament': true,
        'user1': {
          'id': selectedParticipants[0]['user_id'],
          'username': selectedParticipants[0]['users']['username'],
          'profile_image_url': selectedParticipants[0]['tournament_photo_url'],
          'age': selectedParticipants[0]['users']['age'],
          'country': selectedParticipants[0]['users']['country'],
          'gender': selectedParticipants[0]['users']['gender'],
        },
        'user2': {
          'id': selectedParticipants[1]['user_id'],
          'username': selectedParticipants[1]['users']['username'],
          'profile_image_url': selectedParticipants[1]['tournament_photo_url'],
          'age': selectedParticipants[1]['users']['age'],
          'country': selectedParticipants[1]['users']['country'],
          'gender': selectedParticipants[1]['users']['gender'],
        },
      }];
    } catch (e) {
      return [];
    }
  }

  // Private turnuva match'leri için oylama
  static Future<List<Map<String, dynamic>>> getPrivateTournamentMatchesForVoting(String tournamentId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      // Kullanıcının users tablosundaki ID'sini al
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();
      
      if (currentUserRecord == null) return [];

      final currentUserId = currentUserRecord['id'];

      // Kullanıcının daha önce oyladığı match'leri al
      final votedMatches = await _client
          .from('private_tournament_votes')
          .select('user1_id, user2_id')
          .eq('tournament_id', tournamentId)
          .eq('voter_id', currentUserId);

      // Oylanan match'lerin set'ini oluştur
      final votedMatchSet = <String>{};
      for (var vote in votedMatches) {
        final user1Id = vote['user1_id'] as String;
        final user2Id = vote['user2_id'] as String;
        votedMatchSet.add('$user1Id-$user2Id');
        votedMatchSet.add('$user2Id-$user1Id'); // Ters kombinasyon da ekle
      }

      // Private turnuva katılımcılarını getir (turnuva fotoğrafı olanlar)
      final participants = await _client
          .from('tournament_participants')
          .select('''
            user_id,
            tournament_photo_url,
            users!tournament_participants_user_id_fkey(username, profile_image_url, age, country, gender)
          ''')
          .eq('tournament_id', tournamentId)
          .eq('is_eliminated', false)
          .not('tournament_photo_url', 'is', null);

      if (participants.length < 2) return [];

      // Tüm olası kombinasyonları oluştur
      final allCombinations = <List<Map<String, dynamic>>>[];
      for (int i = 0; i < participants.length; i++) {
        for (int j = i + 1; j < participants.length; j++) {
          allCombinations.add([participants[i], participants[j]]);
        }
      }
      
      // Oylanmamış match'leri filtrele
      final unvotedMatches = <Map<String, dynamic>>[];
      for (var combination in allCombinations) {
        final user1Id = combination[0]['user_id'] as String;
        final user2Id = combination[1]['user_id'] as String;
        final matchKey = '$user1Id-$user2Id';
        
        if (!votedMatchSet.contains(matchKey)) {
          unvotedMatches.add({
            'user1': {
              'id': combination[0]['user_id'],
              'username': combination[0]['users']['username'],
              'tournament_photo_url': combination[0]['tournament_photo_url'],
              'age': combination[0]['users']['age'],
              'country': combination[0]['users']['country'],
              'gender': combination[0]['users']['gender'],
            },
            'user2': {
              'id': combination[1]['user_id'],
              'username': combination[1]['users']['username'],
              'tournament_photo_url': combination[1]['tournament_photo_url'],
              'age': combination[1]['users']['age'],
              'country': combination[1]['users']['country'],
              'gender': combination[1]['users']['gender'],
            },
          });
        }
      }

      // Oylanmamış match'leri karıştır ve döndür
      unvotedMatches.shuffle(Random());
      return unvotedMatches;
    } catch (e) {
      print('Error getting private tournament matches for voting: $e');
      return [];
    }
  }

  // Private turnuva oylaması yap
  static Future<bool> voteForPrivateTournamentMatch(String tournamentId, String winnerId, String loserId) async {
    try {
      print('🎯 PRIVATE VOTE: Starting vote for tournament $tournamentId, winner: $winnerId, loser: $loserId');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ PRIVATE VOTE: No authenticated user');
        return false;
      }

      // Kullanıcının users tablosundaki ID'sini al
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();
      
      if (currentUserRecord == null) {
        print('❌ PRIVATE VOTE: Current user record not found');
        return false;
      }

      final currentUserId = currentUserRecord['id'];
      print('✅ PRIVATE VOTE: Current user ID: $currentUserId');

      // Bu match için daha önce oy verilmiş mi kontrol et
      final existingVote = await _client
          .from('private_tournament_votes')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('voter_id', currentUserId)
          .eq('user1_id', winnerId)
          .eq('user2_id', loserId)
          .maybeSingle();

      if (existingVote != null) {
        print('❌ PRIVATE VOTE: User already voted for this match');
        return false;
      }

      // Ters kombinasyonu da kontrol et
      final existingVoteReverse = await _client
          .from('private_tournament_votes')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('voter_id', currentUserId)
          .eq('user1_id', loserId)
          .eq('user2_id', winnerId)
          .maybeSingle();

      if (existingVoteReverse != null) {
        print('❌ PRIVATE VOTE: User already voted for this match (reverse)');
        return false;
      }

      // Oy kaydını ekle
      await _client.from('private_tournament_votes').insert({
        'tournament_id': tournamentId,
        'voter_id': currentUserId,
        'user1_id': winnerId,
        'user2_id': loserId,
        'winner_id': winnerId,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ PRIVATE VOTE: Vote recorded successfully');

      // Kazananın skorunu artır (match kazanma sayısı) - Manuel güncelleme
      print('🎯 PRIVATE VOTE: Updating wins count for winner: $winnerId');
      
      try {
        await _client.rpc('increment_private_tournament_wins', params: {
          'tournament_id': tournamentId,
          'user_id': winnerId,
        });
        print('✅ PRIVATE VOTE: RPC call successful');
      } catch (rpcError) {
        // RPC başarısız olursa manuel güncelleme yap
        print('⚠️ PRIVATE VOTE: RPC failed, trying manual update: $rpcError');
        
        // Mevcut wins_count'u al
        final currentRecord = await _client
            .from('tournament_participants')
            .select('wins_count')
            .eq('tournament_id', tournamentId)
            .eq('user_id', winnerId)
            .maybeSingle();
        
        final currentWins = currentRecord?['wins_count'] ?? 0;
        print('📊 PRIVATE VOTE: Current wins for user $winnerId: $currentWins');
        
        // Wins count'u artır
        await _client
            .from('tournament_participants')
            .update({'wins_count': currentWins + 1})
            .eq('tournament_id', tournamentId)
            .eq('user_id', winnerId);
        
        print('✅ PRIVATE VOTE: Wins count updated to ${currentWins + 1}');
      }

      return true;
    } catch (e) {
      print('Error voting for private tournament match: $e');
      return false;
    }
  }

  // Turnuva oylaması yap
  static Future<bool> voteForTournamentMatch(String tournamentId, String winnerId, String loserId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Kullanıcının users tablosundaki ID'sini al
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();
      
      if (currentUserRecord == null) return false;

      final currentUserId = currentUserRecord['id'];

      // Oy kaydını ekle
      await _client.from('tournament_votes').insert({
        'tournament_id': tournamentId,
        'voter_id': currentUserId,
        'winner_id': winnerId,
        'loser_id': loserId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Kazananın skorunu artır
      await _client.rpc('increment_tournament_score', params: {
        'tournament_id': tournamentId,
        'user_id': winnerId,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Turnuva fazlarını güncelle - sadece 5000 coinlik ve private turnuvalar
  static Future<void> updateTournamentPhases() async {
    try {
      // 1000 coinlik haftalık turnuvalar kaldırıldı
      // Artık sadece 5000 coinlik ve private turnuvalar var
      
      // 5000 coinlik turnuvaları kontrol et ve gerekirse başlat (sürekli kontrol)
      await checkAndStart5000CoinTournaments();
      
      // 5000 coinlik turnuvaların fazlarını güncelle (sürekli kontrol)
      await _update5000CoinTournamentPhases();
      
      // Private turnuvaları start date'e göre başlat (sürekli kontrol)
      await _startPrivateTournamentsByStartDate();
      
      // Private turnuvaları end date'e göre tamamla (sürekli kontrol)
      await _completePrivateTournamentsByEndDate();
      
    } catch (e) {
      print('Error: $e');
      // Error updating tournament phases
    }
  }






  // Private turnuvaları start date'e göre başlat
  static Future<void> _startPrivateTournamentsByStartDate() async {
    try {
      final now = DateTime.now();
      print('🔍 DEBUG: Private turnuva start date kontrolü - Şimdi: $now');
      
      // Start date'i gelmiş private turnuvaları getir
      final readyTournaments = await _client
          .from('tournaments')
          .select('id, name, start_date, current_participants')
          .eq('is_private', true)
          .eq('status', 'upcoming')
          .lte('start_date', now.toIso8601String());
      
      print('🔍 DEBUG: Sorgu: start_date <= $now');
      print('🔍 DEBUG: ISO String: ${now.toIso8601String()}');
      
      // Manuel test - tüm private turnuvaları getir
      final allPrivateTournaments = await _client
          .from('tournaments')
          .select('id, name, start_date, current_participants, status')
          .eq('is_private', true);
      
      print('🔍 DEBUG: Tüm private turnuvalar: ${allPrivateTournaments.length} adet');
      for (var tournament in allPrivateTournaments) {
        print('  - ${tournament['name']} - Start: ${tournament['start_date']}, Status: ${tournament['status']}');
      }
      
      print('📋 DEBUG: Start date geçmiş private turnuvalar: ${readyTournaments.length} adet');
      
      for (var tournament in readyTournaments) {
        print('🔍 DEBUG: ${tournament['name']} - Start: ${tournament['start_date']}, Katılımcı: ${tournament['current_participants']}');
        // En az 2 katılımcı varsa turnuvayı başlat
        if (tournament['current_participants'] >= 2) {
          await _client
              .from('tournaments')
              .update({
                'status': 'active',
                'current_phase': 'qualifying',
                'current_round': 1,
                'phase_start_date': DateTime.now().toIso8601String(),
              })
              .eq('id', tournament['id']);
          
          print('✅ DEBUG: Private tournament ${tournament['name']} started by start date');
        } else {
          // Yeterli katılımcı yoksa turnuvayı tamamla
          await _client
              .from('tournaments')
              .update({
                'status': 'completed',
                'current_phase': 'completed',
              })
              .eq('id', tournament['id']);
          
          print('❌ DEBUG: Private tournament ${tournament['name']} completed due to insufficient participants');
        }
      }
    } catch (e) {
      print('❌ DEBUG: Error starting private tournaments by start date: $e');
    }
  }

  // Private turnuvaları end date'e göre tamamla
  static Future<void> _completePrivateTournamentsByEndDate() async {
    try {
      final now = DateTime.now();
      
      // End date'i geçmiş private turnuvaları getir
      final expiredTournaments = await _client
          .from('tournaments')
          .select('id, name, end_date, current_phase')
          .eq('is_private', true)
          .eq('status', 'active')
          .lt('end_date', now.toIso8601String());
      
      for (var tournament in expiredTournaments) {
        // Turnuvayı tamamla
        await _client
            .from('tournaments')
            .update({
              'status': 'completed',
              'current_phase': 'completed',
            })
            .eq('id', tournament['id']);
        
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Turnuva kazananını belirle ve ödülü ver (eski fonksiyon - artık kullanılmıyor)
  static Future<bool> completeTournament(String tournamentId, String winnerId) async {
    try {
      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      // Kazanana ödülü ver
      await UserService.updateCoins(
        tournament['prize_pool'], 
        'earned', 
        'Turnuva kazandı'
      );

      // Turnuvayı tamamla
      await _client
          .from('tournaments')
          .update({
            'status': 'completed',
            'winner_id': winnerId,
          })
          .eq('id', tournamentId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Private turnuva oluştur
  static Future<Map<String, dynamic>> createPrivateTournament({
    required String name,
    required String description,
    required int maxParticipants,
    required DateTime startDate,
    required DateTime endDate,
    required String tournamentFormat,
    String gender = 'Erkek',
    String language = 'tr',
  }) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      // 5000 coin oluşturma ücreti kontrolü
      const creationFee = 5000;
      if (currentUser.coins < creationFee) {
        return {'success': false, 'message': 'Turnuva oluşturmak için 5000 coin gerekli'};
      }

      // Private key oluştur
      final privateKey = _generatePrivateKey();

      // Turnuva oluştur
      final tournamentId = const Uuid().v4();
      await _client.from('tournaments').insert({
        'id': tournamentId,
        'name': name,
        'description': description,
        'entry_fee': 0, // Entry fee kaldırıldı
        'prize_pool': 0, // Prize pool kaldırıldı
        'max_participants': maxParticipants,
        'current_participants': 0,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'upcoming',
        'gender': gender,
        'current_phase': 'registration',
        'registration_start_date': DateTime.now().toIso8601String(),
        'is_private': true,
        'private_key': privateKey,
        'creator_id': currentUser.id, // Creator ID'yi ekle
        'tournament_format': tournamentFormat,
        'language': language,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Turnuva oluşturma ücretini düş (5000 coin)
      await UserService.updateCoins(
        -creationFee,
        'spent',
        'Private turnuva oluşturma ücreti'
      );

      // Creator otomatik katılımcı olmuyor, current_participants 0 olarak başlıyor

      return {
        'success': true,
        'tournament_id': tournamentId,
        'private_key': privateKey,
        'message': 'Private turnuva başarıyla oluşturuldu'
      };
    } catch (e) {
      return {'success': false, 'message': 'Turnuva oluşturulamadı: ${e.toString()}'};
    }
  }

  // Private turnuva tarihlerini güncelle (sadece admin)
  static Future<Map<String, dynamic>> updatePrivateTournamentDates({
    required String tournamentId,
    required DateTime newStartDate,
    required DateTime newEndDate,
  }) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select('creator_id, status, is_private')
          .eq('id', tournamentId)
          .single();

      // Admin kontrolü
      if (tournament['creator_id'] != currentUser.id) {
        return {'success': false, 'message': 'Bu işlem için yetkiniz yok'};
      }

      // Private turnuva kontrolü
      if (!tournament['is_private']) {
        return {'success': false, 'message': 'Sadece private turnuvalar için geçerli'};
      }

      // Turnuva durumu kontrolü - sadece upcoming turnuvalar için
      if (tournament['status'] != 'upcoming') {
        return {'success': false, 'message': 'Sadece başlamamış turnuvalar için tarih değiştirilebilir'};
      }

      // Tarih validasyonu
      if (newStartDate.isBefore(DateTime.now())) {
        return {'success': false, 'message': 'Başlangıç tarihi geçmiş olamaz'};
      }

      if (newEndDate.isBefore(newStartDate)) {
        return {'success': false, 'message': 'Bitiş tarihi başlangıç tarihinden önce olamaz'};
      }

      // Tarihleri güncelle
      await _client
          .from('tournaments')
          .update({
            'start_date': newStartDate.toIso8601String(),
            'end_date': newEndDate.toIso8601String(),
          })
          .eq('id', tournamentId);

      return {
        'success': true,
        'message': 'Turnuva tarihleri başarıyla güncellendi'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tarih güncelleme hatası: ${e.toString()}'};
    }
  }

  // Private key ile turnuvaya katıl
  static Future<Map<String, dynamic>> joinPrivateTournament(String privateKey) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      // Private key ile turnuva bul
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('private_key', privateKey)
          .eq('is_private', true)
          .maybeSingle();

      if (tournament == null) {
        return {'success': false, 'message': 'Geçersiz private key'};
      }

      // Turnuva durumu kontrolü
      if (tournament['status'] != 'upcoming') {
        return {'success': false, 'message': 'Kayıt kapalı'};
      }
      
      // Start date kontrolü
      final startDate = DateTime.parse(tournament['start_date']);
      if (DateTime.now().isAfter(startDate)) {
        return {'success': false, 'message': 'Turnuva başlangıç tarihi geçmiş'};
      }

      // Dolu mu kontrol et
      if (tournament['current_participants'] >= tournament['max_participants']) {
        return {'success': false, 'message': 'Turnuva dolu'};
      }

      // Zaten katılmış mı kontrol et
      final existingParticipation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournament['id'])
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingParticipation != null) {
        return {'success': false, 'message': 'Zaten katılmışsınız'};
      }

      // Private turnuvalar için entry fee yok

      // Key ile katılan kişileri "tournament_viewers" tablosuna ekle (sadece görme hakkı)
      try {
        await _client.from('tournament_viewers').insert({
          'tournament_id': tournament['id'],
          'user_id': currentUser.id,
          'joined_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Eğer tablo yoksa veya başka hata varsa, sadece mesaj döndür
        print('Error inserting into tournament_viewers: $e');
        return {
          'success': true,
          'message': 'Tournament access granted. Press the "Join" button to participate.',
          'tournament_name': tournament['name']
        };
      }

      return {
        'success': true,
        'message': 'Turnuvaya erişim sağlandı. Katılmak için "Katıl" butonuna basın.',
        'tournament_name': tournament['name']
      };
    } catch (e) {
      return {'success': false, 'message': 'Join failed: $e'};
    }
  }

  // Private turnuva için özel join fonksiyonu
  static Future<bool> joinPrivateTournamentById(String tournamentId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .eq('is_private', true)
          .single();

      // Turnuva durumu kontrolü
      if (tournament['status'] != 'upcoming') {
        return false; // Kayıt kapalı
      }
      
      // Private turnuvalar için start date kontrolü
      final startDate = DateTime.parse(tournament['start_date']);
      if (DateTime.now().isAfter(startDate)) {
        return false; // Start date geçmiş, kayıt kapalı
      }

      // Turnuva dolu mu kontrol et
      if (tournament['current_participants'] >= tournament['max_participants']) {
        return false; // Turnuva dolu
      }

      // Zaten katılmış mı kontrol et
      final existingParticipation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingParticipation != null) {
        return false; // Zaten katılmış
      }

      // Turnuvaya katıl
      await _client.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': currentUser.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_eliminated': false,
        'score': 0,
        'tournament_photo_url': null,
      });

      // Private turnuvalar için entry fee yok

      // Turnuva katılımcı sayısını güncelle
      try {
        await _client.rpc('increment_tournament_participants', params: {
          'tournament_id': tournamentId,
        });
      } catch (rpcError) {
        // RPC başarısız olursa manuel güncelleme yap
        await _client
            .from('tournaments')
            .update({'current_participants': tournament['current_participants'] + 1})
            .eq('id', tournamentId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Turnuvadan ayrılma fonksiyonu
  static Future<bool> leaveTournament(String tournamentId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select('id, name, is_private, status, entry_fee, current_participants')
          .eq('id', tournamentId)
          .single();

      // Sadece upcoming ve active turnuvalardan ayrılabilir
      if (tournament['status'] != 'upcoming' && tournament['status'] != 'active') {
        return false;
      }

      // Katılımcı kaydını sil
      await _client
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser.id);

      // Turnuva katılımcı sayısını güncelle
      final newCount = (tournament['current_participants'] as int) - 1;
      await _client
          .from('tournaments')
          .update({'current_participants': newCount})
          .eq('id', tournamentId);

      // Sistem turnuvaları için entry fee iadesi
      if (!tournament['is_private'] && tournament['entry_fee'] > 0) {
        await UserService.updateCoins(
          tournament['entry_fee'], 
          'earned', 
          'Turnuva ayrılım iadesi'
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Private turnuvadan ayrılma (admin dahil herkes)
  static Future<bool> leavePrivateTournament(String tournamentId) async {
    return await leaveTournament(tournamentId);
  }

  // Private turnuva silme fonksiyonu
  static Future<bool> deletePrivateTournament(String tournamentId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Turnuva bilgilerini al ve creator kontrolü yap
      final tournament = await _client
          .from('tournaments')
          .select('creator_id, is_private, status, name')
          .eq('id', tournamentId)
          .maybeSingle();

      if (tournament == null) {
        return false;
      }

      // Sadece private turnuva ve creator olabilir
      if (!tournament['is_private']) {
        return false;
      }
      
      if (tournament['creator_id'] != currentUser.id) {
        return false;
      }

      // Sadece upcoming ve active durumundaki turnuvalar silinebilir
      if (tournament['status'] != 'upcoming' && tournament['status'] != 'active') {
        return false;
      }

      // Önce katılımcıları sil
      await _client
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId);

      // Private tournament votes'ları da sil
      await _client
          .from('private_tournament_votes')
          .delete()
          .eq('tournament_id', tournamentId);

      // Sonra turnuvayı sil
      await _client
          .from('tournaments')
          .delete()
          .eq('id', tournamentId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Private key oluştur
  static String _generatePrivateKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Kullanıcının oluşturduğu private turnuvaları getir
  static Future<List<TournamentModel>> getMyPrivateTournaments() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return [];

      // Private turnuvaları getir - şimdilik tüm private turnuvaları getir
      final response = await _client
          .from('tournaments')
          .select()
          .eq('is_private', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TournamentModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Turnuva bildirimleri
  static Future<void> sendTournamentStartNotification(String tournamentId, String tournamentName) async {
    try {
      // Turnuva katılımcılarını getir
      final participants = await _client
          .from('tournament_participants')
          .select('user_id')
          .eq('tournament_id', tournamentId);

      // Her katılımcıya bildirim gönder
      for (var participant in participants) {
        await _sendNotificationToUser(
          participant['user_id'],
          'tournament_update',
          '🏆 Turnuva Başladı!',
          '$tournamentName turnuvası başladı. Hemen oylamaya katıl!',
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> sendTournamentEndNotification(String tournamentId, String tournamentName, String winnerName) async {
    try {
      // Turnuva katılımcılarını getir
      final participants = await _client
          .from('tournament_participants')
          .select('user_id')
          .eq('tournament_id', tournamentId);

      // Her katılımcıya bildirim gönder
      for (var participant in participants) {
        await _sendNotificationToUser(
          participant['user_id'],
          'tournament_update',
          '🏆 Turnuva Bitti!',
          '$tournamentName turnuvası bitti. Kazanan: $winnerName',
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> sendTournamentJoinNotification(String tournamentId, String tournamentName) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return;

      await _sendNotificationToUser(
        currentUser.id,
        'tournament_update',
        '✅ Turnuvaya Katıldınız',
        '$tournamentName turnuvasına başarıyla katıldınız!',
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> _sendNotificationToUser(String userId, String type, String title, String body) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Katılımcıyı turnuvadan at
  static Future<bool> kickParticipant(String tournamentId, String userId) async {
    try {
      print('🎯 KICK DEBUG: Starting kick participant for tournament $tournamentId, user $userId');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ KICK DEBUG: No authenticated user');
        return false;
      }
      print('✅ KICK DEBUG: User authenticated: ${user.id}');

      // Kullanıcının users tablosundaki ID'sini al (auth_id -> users.id)
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (currentUserRecord == null) {
        print('❌ KICK DEBUG: Current user record not found');
        return false;
      }
      final currentUserId = currentUserRecord['id'];
      print('✅ KICK DEBUG: Current user ID: $currentUserId');

      // Turnuva bilgilerini al ve admin kontrolü yap
      final tournament = await _client
          .from('tournaments')
          .select('creator_id')
          .eq('id', tournamentId)
          .single();

      if (tournament['creator_id'] != currentUserId) {
        print('❌ KICK DEBUG: User is not admin of tournament');
        return false;
      }
      print('✅ KICK DEBUG: User is admin, proceeding with kick');

      // Katılımcıyı turnuvadan çıkar
      await _client
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('user_id', userId);

      print('✅ KICK DEBUG: Participant kicked successfully');
      return true;
    } catch (e) {
      print('❌ KICK DEBUG: Error kicking participant: $e');
      return false;
    }
  }
}
