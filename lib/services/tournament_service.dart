import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/tournament_model.dart';
import 'user_service.dart';

class TournamentService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Aktif turnuvaları getir (yeni sistem)
  static Future<List<TournamentModel>> getActiveTournaments() async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .inFilter('status', ['registration', 'active'])
          .order('entry_fee', ascending: true);

      return (response as List)
          .map((json) => TournamentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting active tournaments: $e');
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
      
      print('Test tournaments cleaned up!');
    } catch (e) {
      print('Error cleaning up test tournaments: $e');
    }
  }

  // Eski turnuvaları temizle
  static Future<void> _cleanupOldTournaments() async {
    try {
      // Eski haftalık turnuvaları sil
      await _client
          .from('tournaments')
          .delete()
          .like('name', '%Haftalık%');
      
      print('Old weekly tournaments cleaned up!');
    } catch (e) {
      print('Error cleaning up old tournaments: $e');
    }
  }

  // Otomatik haftalık turnuva sistemi
  static Future<void> createWeeklyTournaments() async {
    try {
      final now = DateTime.now();
      
      // Bu haftanın Pazartesi gününü bul
      final thisWeekMonday = _getThisWeekMonday(now);
      final thisWeekWednesday = thisWeekMonday.add(const Duration(days: 2));
      final thisWeekThursday = thisWeekMonday.add(const Duration(days: 3));
      final thisWeekFriday = thisWeekMonday.add(const Duration(days: 4));
      final thisWeekSaturday = thisWeekMonday.add(const Duration(days: 5));
      final thisWeekSunday = thisWeekMonday.add(const Duration(days: 6));
      
      // Pazartesi'den itibaren çalışacak sistem
      if (now.weekday == 1) { // Pazartesi günü
        await _cleanupOldTournaments();
        
        // Erkek turnuvaları
        await _createTournament(
          name: 'Haftalık Erkek Turnuvası (1000 Coin)',
          description: 'Her hafta düzenlenen erkek turnuvası - 300 kişi kapasiteli',
          entryFee: 1000,
          maxParticipants: 300,
          gender: 'Erkek',
          registrationStartDate: thisWeekMonday,
          startDate: thisWeekWednesday,
          votingStartDate: thisWeekWednesday,
          votingEndDate: thisWeekThursday,
          quarterFinalDate: thisWeekFriday,
          semiFinalDate: thisWeekSaturday,
          finalDate: thisWeekSunday,
        );

        await _createTournament(
          name: 'Haftalık Erkek Turnuvası (10000 Coin)',
          description: 'Premium erkek turnuvası - 100 kişi kapasiteli',
          entryFee: 10000,
          maxParticipants: 100,
          gender: 'Erkek',
          registrationStartDate: thisWeekMonday,
          startDate: thisWeekWednesday,
          votingStartDate: thisWeekWednesday,
          votingEndDate: thisWeekThursday,
          quarterFinalDate: thisWeekFriday,
          semiFinalDate: thisWeekSaturday,
          finalDate: thisWeekSunday,
        );

        // Kadın turnuvaları
        await _createTournament(
          name: 'Haftalık Kadın Turnuvası (1000 Coin)',
          description: 'Her hafta düzenlenen kadın turnuvası - 300 kişi kapasiteli',
          entryFee: 1000,
          maxParticipants: 300,
          gender: 'Kadın',
          registrationStartDate: thisWeekMonday,
          startDate: thisWeekWednesday,
          votingStartDate: thisWeekWednesday,
          votingEndDate: thisWeekThursday,
          quarterFinalDate: thisWeekFriday,
          semiFinalDate: thisWeekSaturday,
          finalDate: thisWeekSunday,
        );

        await _createTournament(
          name: 'Haftalık Kadın Turnuvası (10000 Coin)',
          description: 'Premium kadın turnuvası - 100 kişi kapasiteli',
          entryFee: 10000,
          maxParticipants: 100,
          gender: 'Kadın',
          registrationStartDate: thisWeekMonday,
          startDate: thisWeekWednesday,
          votingStartDate: thisWeekWednesday,
          votingEndDate: thisWeekThursday,
          quarterFinalDate: thisWeekFriday,
          semiFinalDate: thisWeekSaturday,
          finalDate: thisWeekSunday,
        );

        print('Weekly tournaments created successfully');
      }
    } catch (e) {
      print('Error creating weekly tournaments: $e');
    }
  }

  // Bu haftanın Pazartesi gününü hesapla
  static DateTime _getThisWeekMonday(DateTime now) {
    final daysFromMonday = now.weekday - 1;
    final monday = now.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day, 12, 0, 0);
  }


  // Turnuva oluştur
  static Future<void> _createTournament({
    required String name,
    required String description,
    required int entryFee,
    required int maxParticipants,
    required String gender,
    required DateTime registrationStartDate,
    required DateTime startDate,
    DateTime? votingStartDate,
    DateTime? votingEndDate,
    DateTime? quarterFinalDate,
    DateTime? semiFinalDate,
    DateTime? finalDate,
  }) async {
    final endDate = finalDate ?? startDate.add(const Duration(days: 7));
    final prizePool = entryFee * maxParticipants; // Ödül havuzu = giriş ücreti * max katılımcı

    await _client.from('tournaments').insert({
      'name': name,
      'description': description,
      'entry_fee': entryFee,
      'prize_pool': prizePool,
      'max_participants': maxParticipants,
      'current_participants': 0,
      'registration_start_date': registrationStartDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'voting_start_date': votingStartDate?.toIso8601String(),
      'voting_end_date': votingEndDate?.toIso8601String(),
      'quarter_final_date': quarterFinalDate?.toIso8601String(),
      'semi_final_date': semiFinalDate?.toIso8601String(),
      'final_date': finalDate?.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'registration',
      'gender': gender,
      'current_phase': 'registration',
      'current_round': null,
      'phase_start_date': registrationStartDate.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Turnuvaya katıl (yeni sistem)
  static Future<bool> joinTournament(String tournamentId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return false;

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      // Cinsiyet kontrolü kaldırıldı - herkes tüm turnuvalara katılabilir

      // Turnuva durumu kontrolü - registration veya active olabilir
      if (tournament['status'] != 'registration' && tournament['status'] != 'active') {
        return false; // Kayıt kapalı
      }

      // Kullanıcının coin kontrolü
      if (currentUser.coins < tournament['entry_fee']) {
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

      // Turnuvaya katıl
      await _client.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': currentUser.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_eliminated': false,
        'score': 0,
        'tournament_photo_url': null, // Turnuva fotoğrafı henüz yüklenmedi
        'photo_uploaded': false, // Fotoğraf yüklenme durumu
      });

      // Entry fee'yi düş
      await UserService.updateCoins(
        -tournament['entry_fee'], 
        'spent', 
        'Turnuva katılım ücreti'
      );

      // Turnuva katılımcı sayısını güncelle
      await _client.rpc('increment_tournament_participants', params: {
        'tournament_id': tournamentId,
      });

      // Turnuva başlatma mantığı:
      // - 100 kişi turnuvaları: 100 kişi dolunca otomatik başlar
      // - 300 kişi turnuvaları: Belirlenen tarihte başlar
      if (tournament['max_participants'] == 100 && 
          tournament['current_participants'] + 1 >= tournament['max_participants']) {
        // 100 kişi turnuvaları dolunca otomatik başlat
        await _startTournament(tournamentId);
      } else if (tournament['max_participants'] == 300) {
        // 300 kişi turnuvaları için özel kontrol
        final now = DateTime.now();
        final startDate = DateTime.parse(tournament['start_date']);
        
        // Eğer başlangıç tarihi gelmişse ve yeterli katılımcı varsa başlat
        if (now.isAfter(startDate) && tournament['current_participants'] + 1 >= 100) {
          await _startTournament(tournamentId);
        }
      }

      return true;
    } catch (e) {
      print('Error joining tournament: $e');
      return false;
    }
  }

  // Turnuvayı başlat (10000 coin turnuvaları için)
  static Future<void> _startTournament(String tournamentId) async {
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
      
      print('Tournament $tournamentId started');
    } catch (e) {
      print('Error starting tournament: $e');
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
      print('Error getting user tournaments: $e');
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
      print('Error getting tournament details: $e');
      return null;
    }
  }

  // Turnuva katılımcılarını getir
  static Future<List<Map<String, dynamic>>> getTournamentParticipants(String tournamentId) async {
    try {
      final response = await _client
          .from('tournament_participants')
          .select('''
            *,
            user:users(username, profile_image_url, coins)
          ''')
          .eq('tournament_id', tournamentId)
          .order('score', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting tournament participants: $e');
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
            photo_uploaded,
            joined_at,
            profiles!inner(
              username,
              profile_photo_url
            )
          ''')
          .eq('tournament_id', tournamentId)
          .order('score', ascending: false)
          .order('joined_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
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
      print('Error voting in tournament: $e');
      return false;
    }
  }

  // Playoff sistemi - Cuma 00:00'da çeyrek final
  static Future<void> processQuarterFinals() async {
    try {
      final now = DateTime.now();
      
      // Cuma günü 00:00'da çalışacak
      if (now.weekday == 5 && now.hour == 0) {
        final tournaments = await _client
            .from('tournaments')
            .select('id, name, current_participants')
            .eq('status', 'active')
            .eq('current_phase', 'voting');
        
        for (var tournament in tournaments) {
          // En yüksek skorlu 8 kişiyi çeyrek finale al
          await _advanceToQuarterFinals(tournament['id']);
        }
      }
    } catch (e) {
      print('Error processing quarter finals: $e');
    }
  }

  // Çeyrek finale geçiş
  static Future<void> _advanceToQuarterFinals(String tournamentId) async {
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
        
        // Turnuva fazını güncelle
        await _client
            .from('tournaments')
            .update({
              'current_phase': 'quarter_finals',
              'current_round': 'quarter_finals',
              'phase_start_date': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);
      }
    } catch (e) {
      print('Error advancing to quarter finals: $e');
    }
  }

  // Yarı final - Cumartesi 00:00
  static Future<void> processSemiFinals() async {
    try {
      final now = DateTime.now();
      
      if (now.weekday == 6 && now.hour == 0) {
        final tournaments = await _client
            .from('tournaments')
            .select('id')
            .eq('status', 'active')
            .eq('current_phase', 'quarter_finals');
        
        for (var tournament in tournaments) {
          await _advanceToSemiFinals(tournament['id']);
        }
      }
    } catch (e) {
      print('Error processing semi finals: $e');
    }
  }

  // Yarı finale geçiş
  static Future<void> _advanceToSemiFinals(String tournamentId) async {
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
        
        // Turnuva fazını güncelle
        await _client
            .from('tournaments')
            .update({
              'current_phase': 'semi_finals',
              'current_round': 'semi_finals',
              'phase_start_date': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);
      }
    } catch (e) {
      print('Error advancing to semi finals: $e');
    }
  }

  // Final - Pazar 00:00
  static Future<void> processFinals() async {
    try {
      final now = DateTime.now();
      
      if (now.weekday == 7 && now.hour == 0) {
        final tournaments = await _client
            .from('tournaments')
            .select('id')
            .eq('status', 'active')
            .eq('current_phase', 'semi_finals');
        
        for (var tournament in tournaments) {
          await _advanceToFinals(tournament['id']);
        }
      }
    } catch (e) {
      print('Error processing finals: $e');
    }
  }

  // Finale geçiş
  static Future<void> _advanceToFinals(String tournamentId) async {
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
        
        // Turnuva fazını güncelle
        await _client
            .from('tournaments')
            .update({
              'current_phase': 'finals',
              'current_round': 'finals',
              'phase_start_date': DateTime.now().toIso8601String(),
            })
            .eq('id', tournamentId);
      }
    } catch (e) {
      print('Error advancing to finals: $e');
    }
  }

  // Turnuva fotoğrafı yükle
  static Future<bool> uploadTournamentPhoto(String tournamentId, String photoUrl) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
      final participation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (participation == null) return false;

      // Turnuva fotoğrafını güncelle
      await _client
          .from('tournament_participants')
          .update({
            'tournament_photo_url': photoUrl,
            'photo_uploaded': true, // Fotoğraf yüklendi olarak işaretle
          })
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      print('Error uploading tournament photo: $e');
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

      // Aktif turnuvaları getir (cinsiyet kontrolü yok - herkes herkesi oylayabilir)
      final tournaments = await _client
          .from('tournaments')
          .select('id, gender')
          .eq('status', 'active')
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

      // Kendisinin katıldığı turnuvaları filtrele (cinsiyet kontrolü yok)
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
      print('Error getting tournament matches for voting: $e');
      return [];
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
      print('Error voting for tournament match: $e');
      return false;
    }
  }

  // Haftalık turnuva fazlarını güncelle
  static Future<void> updateTournamentPhases() async {
    try {
      final now = DateTime.now();
      final dayOfWeek = now.weekday;

      // Aktif turnuvaları getir
      final tournaments = await _client
          .from('tournaments')
          .select('id')
          .eq('status', 'active');

      for (var tournament in tournaments) {
        // Cuma günü (5) - Qualifying'den Quarter Final'e geç
        if (dayOfWeek == 5) {
          await _advanceToQuarterFinals(tournament['id']);
        }
        // Cumartesi günü (6) - Quarter Final'den Semi Final'e geç
        else if (dayOfWeek == 6) {
          await _advanceToSemiFinals(tournament['id']);
        }
        // Pazar günü (7) - Semi Final'den Final'e geç, 3.lük maçı ve kazananı belirle
        else if (dayOfWeek == 7) {
          await _completeTournament();
        }
      }
    } catch (e) {
      print('Error updating tournament phases: $e');
    }
  }



  // Turnuvayı tamamla (Final + 3.lük maçı)
  static Future<void> _completeTournament() async {
    try {
      // Semi Final turnuvalarını getir
      final tournaments = await _client
          .from('tournaments')
          .select('id, prize_pool')
          .eq('status', 'active')
          .eq('current_phase', 'semi_final');

      for (var tournament in tournaments) {
        // İlk 4'ü getir (final için 2, 3.lük için 2)
        final topParticipants = await _client
            .from('tournament_participants')
            .select('user_id, score')
            .eq('tournament_id', tournament['id'])
            .eq('is_eliminated', false)
            .order('score', ascending: false)
            .limit(4);

        if (topParticipants.length < 4) continue;

        // Final için ilk 2 (1. ve 2. sıradakiler)
        final finalists = topParticipants.take(2).toList();
        final winner = finalists[0]; // 1. sıradaki kazanan
        final runnerUp = finalists[1]; // 2. sıradaki ikinci
        
        // 3.lük maçı için 3. ve 4. sıradakiler
        final thirdPlaceContestants = topParticipants.skip(2).take(2).toList();
        final thirdPlace = thirdPlaceContestants[0]; // 3. sıradaki üçüncü

        // Ödülleri hesapla
        final totalPrizePool = tournament['prize_pool'] as int;
        final firstPrize = (totalPrizePool * 0.6).round(); // %60
        final secondPrize = (totalPrizePool * 0.3).round(); // %30
        final thirdPrize = (totalPrizePool * 0.1).round(); // %10

        // Ödülleri ver
        await UserService.updateCoins(firstPrize, 'earned', 'Turnuva 1.lik');
        await UserService.updateCoins(secondPrize, 'earned', 'Turnuva 2.lik');
        await UserService.updateCoins(thirdPrize, 'earned', 'Turnuva 3.lük');

        // Diğerlerini elen
        final eliminatedIds = topParticipants.skip(4).map((p) => p['user_id']).toList();
        if (eliminatedIds.isNotEmpty) {
          await _client
              .from('tournament_participants')
              .update({'is_eliminated': true})
              .eq('tournament_id', tournament['id'])
              .inFilter('user_id', eliminatedIds);
        }

        // Turnuvayı tamamla
        await _client
            .from('tournaments')
            .update({
              'status': 'completed',
              'current_phase': 'completed',
              'current_round': 4,
              'winner_id': winner['user_id'],
              'second_place_id': runnerUp['user_id'],
              'third_place_id': thirdPlace['user_id'],
            })
            .eq('id', tournament['id']);

        print('Tournament ${tournament['id']} completed: 1st=${winner['user_id']}, 2nd=${runnerUp['user_id']}, 3rd=${thirdPlace['user_id']}');
      }
    } catch (e) {
      print('Error completing tournament: $e');
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
      print('Error completing tournament: $e');
      return false;
    }
  }

  // Private turnuva oluştur
  static Future<Map<String, dynamic>> createPrivateTournament({
    required String name,
    required String description,
    required int entryFee,
    required int maxParticipants,
    required DateTime startDate,
    required DateTime endDate,
    required String tournamentFormat,
    String? customRules,
    String gender = 'Erkek',
  }) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      // Coin kontrolü
      if (currentUser.coins < entryFee) {
        return {'success': false, 'message': 'Yetersiz coin'};
      }

      // Private key oluştur
      final privateKey = _generatePrivateKey();

      // Turnuva oluştur
      final tournamentId = const Uuid().v4();
      await _client.from('tournaments').insert({
        'id': tournamentId,
        'name': name,
        'description': description,
        'entry_fee': entryFee,
        'prize_pool': entryFee * maxParticipants, // Entry fee * katılımcı sayısı
        'max_participants': maxParticipants,
        'current_participants': 0,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'registration',
        'gender': gender,
        'current_phase': 'registration',
        'registration_start_date': DateTime.now().toIso8601String(),
        'is_private': true,
        'private_key': privateKey,
        'tournament_format': tournamentFormat,
        'custom_rules': customRules,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Creator'ı otomatik katılımcı yap
      await _client.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': currentUser.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Turnuva oluşturma ücretini düş
      await UserService.updateCoins(
        -entryFee,
        'spent',
        'Private turnuva oluşturma ücreti'
      );

      // Current participants'ı güncelle
      await _client
          .from('tournaments')
          .update({'current_participants': 1})
          .eq('id', tournamentId);

      return {
        'success': true,
        'tournament_id': tournamentId,
        'private_key': privateKey,
        'message': 'Private turnuva başarıyla oluşturuldu'
      };
    } catch (e) {
      print('Error creating private tournament: $e');
      print('Error details: ${e.toString()}');
      return {'success': false, 'message': 'Turnuva oluşturulamadı: ${e.toString()}'};
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
      if (tournament['status'] != 'registration') {
        return {'success': false, 'message': 'Kayıt kapalı'};
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

      // Coin kontrolü
      if (currentUser.coins < tournament['entry_fee']) {
        return {'success': false, 'message': 'Yetersiz coin'};
      }

      // Turnuvaya katıl
      await _client.from('tournament_participants').insert({
        'tournament_id': tournament['id'],
        'user_id': currentUser.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Entry fee düş
      await UserService.updateCoins(
        -tournament['entry_fee'],
        'spent',
        'Private turnuva katılım ücreti'
      );

      // Current participants'ı güncelle
      await _client
          .from('tournaments')
          .update({'current_participants': tournament['current_participants'] + 1})
          .eq('id', tournament['id']);

      return {
        'success': true,
        'message': 'Turnuvaya başarıyla katıldınız',
        'tournament_name': tournament['name']
      };
    } catch (e) {
      print('Error joining private tournament: $e');
      return {'success': false, 'message': 'Katılım başarısız: $e'};
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
      print('Error getting my private tournaments: $e');
      return [];
    }
  }
}
