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
          
          // Basit sorgu - oluşturan, katılımcı veya key ile katılan
          var privateQuery = _client
              .from('tournaments')
              .select()
              .inFilter('status', ['upcoming', 'active'])
              .eq('is_private', true);
          
          if (allAccessIds.isNotEmpty) {
            // Oluşturan, katılımcı veya key ile katılan kontrolü
            privateQuery = privateQuery.or('creator_id.eq.${currentUser.id},id.in.(${allAccessIds.join(',')})');
          } else {
            // Sadece oluşturan kontrolü
            privateQuery = privateQuery.eq('creator_id', currentUser.id);
          }
          
          privateTournaments = await privateQuery.order('entry_fee', ascending: true);
        } catch (e) {
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
      
      // // print('Test tournaments cleaned up!');
    } catch (e) {
      // // print('Error cleaning up test tournaments: $e');
    }
  }

  // Eski turnuvaları temizle - sadece eski haftalık turnuvaları sil
  static Future<void> _cleanupOldTournaments() async {
    try {
      // Sadece eski haftalık turnuvaları sil (geçen hafta ve öncesi)
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      
      await _client
          .from('tournaments')
          .delete()
          .lt('registration_start_date', lastWeek.toIso8601String())
          .like('name', '%Haftalık%');
      
      // // print('Old weekly tournaments cleaned up!');
    } catch (e) {
      // // print('Error cleaning up old tournaments: $e');
    }
  }

  // Otomatik haftalık turnuva sistemi - düzeltilmiş zamanlama
  static Future<void> createWeeklyTournaments() async {
    try {
      final now = DateTime.now();
      
      // Bu haftanın Pazartesi gününü bul (00:01'de kayıt başlar)
      final thisWeekMonday = _getThisWeekMonday(now);
      // Çarşamba 00:01'de kayıt kapanır, turnuva başlar
      final thisWeekWednesday = thisWeekMonday.add(const Duration(days: 2));
      // Cuma 00:01'de çeyrek final
      final thisWeekFriday = thisWeekMonday.add(const Duration(days: 4));
      // Cumartesi 00:01'de yarı final
      final thisWeekSaturday = thisWeekMonday.add(const Duration(days: 5));
      // Pazar 00:01'de final
      final thisWeekSunday = thisWeekMonday.add(const Duration(days: 6));
      
      // Bu hafta için sistem turnuvaları var mı kontrol et
      print('🗓️ DEBUG: createWeeklyTournaments başladı');
      print('📅 DEBUG: Bu hafta Pazartesi: $thisWeekMonday');
      
      final existingTournaments = await _client
          .from('tournaments')
          .select('id, name, status')
          .gte('registration_start_date', thisWeekMonday.toIso8601String())
          .lt('registration_start_date', thisWeekMonday.add(const Duration(days: 7)).toIso8601String())
          .eq('is_private', false)
          .eq('is_system_tournament', true); // Sadece sistem turnuvaları
      
      print('🔍 DEBUG: Mevcut turnuvalar: ${(existingTournaments as List).length} adet');
      for (var tournament in existingTournaments) {
        print('  - ${tournament['name']} (${tournament['status']})');
      }
      
      // Eğer bu hafta için sistem turnuvası yoksa oluştur
      if ((existingTournaments as List).isEmpty) {
        print('➕ DEBUG: Yeni haftalık turnuvalar oluşturuluyor...');
        await _cleanupOldTournaments();
        
        // Ortak sistem turnuvaları oluştur (dil farkı yok, sadece metin farkı)
        await _createSystemTournaments(
          thisWeekMonday,        // Pazartesi 00:01 - Kayıt başlar
          thisWeekWednesday,     // Çarşamba 00:01 - Kayıt kapanır, turnuva başlar
          thisWeekWednesday,     // Çarşamba 00:01 - Oylama başlar
          thisWeekFriday,        // Cuma 00:01 - Oylama biter
          thisWeekFriday,        // Cuma 00:01 - Çeyrek final
          thisWeekSaturday,      // Cumartesi 00:01 - Yarı final
          thisWeekSunday,        // Pazar 00:01 - Final
        );

        print('✅ DEBUG: Haftalık turnuvalar oluşturuldu');
      } else {
        print('ℹ️ DEBUG: Bu hafta için turnuvalar zaten mevcut');
      }
    } catch (e) {
      print('❌ DEBUG: createWeeklyTournaments hatası: $e');
    }
  }

  // Ortak sistem turnuvaları oluştur (dil farkı yok)
  static Future<void> _createSystemTournaments(
    DateTime registrationStartDate,
    DateTime startDate,
    DateTime votingStartDate,
    DateTime votingEndDate,
    DateTime quarterFinalDate,
    DateTime semiFinalDate,
    DateTime finalDate,
  ) async {
    // Sistem turnuvaları - tüm diller için ortak
    final systemTournaments = [
      {
        'name_key': 'weeklyMaleTournament1000',
        'description_key': 'weeklyMaleTournament1000Description',
        'entryFee': 1000,
        'maxParticipants': 300,
        'gender': 'Erkek',
      },
      {
        'name_key': 'weeklyMaleTournament10000',
        'description_key': 'weeklyMaleTournament10000Description',
        'entryFee': 10000,
        'maxParticipants': 100,
        'gender': 'Erkek',
      },
      {
        'name_key': 'weeklyFemaleTournament1000',
        'description_key': 'weeklyFemaleTournament1000Description',
        'entryFee': 1000,
        'maxParticipants': 300,
        'gender': 'Kadın',
      },
      {
        'name_key': 'weeklyFemaleTournament10000',
        'description_key': 'weeklyFemaleTournament10000Description',
        'entryFee': 10000,
        'maxParticipants': 100,
        'gender': 'Kadın',
      },
    ];

    // Her sistem turnuvası için ortak turnuva oluştur
    for (var tournament in systemTournaments) {
      await _createSystemTournament(
        nameKey: tournament['name_key'] as String,
        descriptionKey: tournament['description_key'] as String,
        entryFee: tournament['entryFee'] as int,
        maxParticipants: tournament['maxParticipants'] as int,
        gender: tournament['gender'] as String,
        registrationStartDate: registrationStartDate,
        startDate: startDate,
        votingStartDate: votingStartDate,
        votingEndDate: votingEndDate,
        quarterFinalDate: quarterFinalDate,
        semiFinalDate: semiFinalDate,
        finalDate: finalDate,
      );
    }
  }

  // Sistem turnuvası oluştur (dil-agnostic)
  static Future<void> _createSystemTournament({
    required String nameKey,
    required String descriptionKey,
    required int entryFee,
    required int maxParticipants,
    required String gender,
    required DateTime registrationStartDate,
    required DateTime startDate,
    required DateTime votingStartDate,
    required DateTime votingEndDate,
    required DateTime quarterFinalDate,
    required DateTime semiFinalDate,
    required DateTime finalDate,
  }) async {
    try {
      final tournamentId = const Uuid().v4();
      
      await _client.from('tournaments').insert({
        'id': tournamentId,
        'name_key': nameKey, // Localization key
        'description_key': descriptionKey, // Localization key
        'entry_fee': entryFee,
        'prize_pool': entryFee * maxParticipants,
        'max_participants': maxParticipants,
        'current_participants': 0,
        'start_date': startDate.toIso8601String(),
        'end_date': finalDate.toIso8601String(),
        'status': 'upcoming',
        'gender': gender,
        'current_phase': 'registration',
        'registration_start_date': registrationStartDate.toIso8601String(),
        'voting_start_date': votingStartDate.toIso8601String(),
        'voting_end_date': votingEndDate.toIso8601String(),
        'quarter_final_date': quarterFinalDate.toIso8601String(),
        'semi_final_date': semiFinalDate.toIso8601String(),
        'final_date': finalDate.toIso8601String(),
        'is_private': false,
        'is_system_tournament': true, // Sistem turnuvası işareti
        'tournament_format': 'hybrid',
        'language': 'system', // Sistem turnuvası için özel dil
        'created_at': DateTime.now().toIso8601String(),
      });

      // // print('System tournament created: $nameKey');
    } catch (e) {
      // // print('Error creating system tournament: $e');
    }
  }



  // Bu haftanın Pazartesi gününü hesapla
  static DateTime _getThisWeekMonday(DateTime now) {
    final daysFromMonday = now.weekday - 1;
    final monday = now.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day, 12, 0, 0);
  }



  // Turnuvaya katıl (yeni sistem)
  static Future<bool> joinTournament(String tournamentId) async {
    try {
      // // print('🎯 JOIN TOURNAMENT: Starting join process for tournament $tournamentId');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        // // print('❌ JOIN TOURNAMENT: No authenticated user');
        return false;
      }
      // // print('✅ JOIN TOURNAMENT: User authenticated: ${user.id}');

      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        // // print('❌ JOIN TOURNAMENT: Current user not found in database');
        return false;
      }
      // // print('✅ JOIN TOURNAMENT: Current user found: ${currentUser.username}, coins: ${currentUser.coins}');

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();
      // // print('✅ JOIN TOURNAMENT: Tournament found: ${tournament['name']}, status: ${tournament['status']}, entry_fee: ${tournament['entry_fee']}');

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
          // // print('❌ JOIN TOURNAMENT: Gender mismatch. User: ${currentUser.genderCode}, Required: $tournamentGender');
          return false; // Cinsiyet uyumsuzluğu
        }
      }
      // // print('✅ JOIN TOURNAMENT: Gender check passed');

      // Turnuva durumu kontrolü
      if (tournament['status'] != 'upcoming' && tournament['status'] != 'active') {
        // // print('❌ JOIN TOURNAMENT: Tournament status is ${tournament['status']}, not joinable');
        return false; // Kayıt kapalı
      }
      
      // Private turnuvalar için start date kontrolü
      if (tournament['is_private'] && tournament['status'] == 'upcoming') {
        final startDate = DateTime.parse(tournament['start_date']);
        if (DateTime.now().isAfter(startDate)) {
          // // print('❌ JOIN TOURNAMENT: Private tournament start date has passed');
          return false; // Start date geçmiş, kayıt kapalı
        }
      }
      // // print('✅ JOIN TOURNAMENT: Tournament status is valid');

      // Sistem turnuvaları için coin kontrolü
      if (!tournament['is_private'] && currentUser.coins < tournament['entry_fee']) {
        // // print('❌ JOIN TOURNAMENT: Insufficient coins. User has ${currentUser.coins}, needs ${tournament['entry_fee']}');
        return false; // Yetersiz coin
      }
      // // print('✅ JOIN TOURNAMENT: User has sufficient coins');

      // Turnuva dolu mu kontrol et
      if (tournament['current_participants'] >= tournament['max_participants']) {
        // // print('❌ JOIN TOURNAMENT: Tournament is full. Current: ${tournament['current_participants']}, Max: ${tournament['max_participants']}');
        return false; // Turnuva dolu
      }
      // // print('✅ JOIN TOURNAMENT: Tournament has space');

      // Zaten katılmış mı kontrol et
      final existingParticipation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingParticipation != null) {
        // // print('❌ JOIN TOURNAMENT: User already participating');
        return false; // Zaten katılmış
      }
      // // print('✅ JOIN TOURNAMENT: User not already participating');

      // Turnuvaya katıl
      // // print('🎯 JOIN TOURNAMENT: Inserting into tournament_participants...');
      await _client.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': currentUser.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_eliminated': false,
        'score': 0,
        'tournament_photo_url': null, // Turnuva fotoğrafı henüz yüklenmedi
        // 'photo_uploaded': false, // Bu kolon veritabanında yok, kaldırıldı
      });
      // // print('✅ JOIN TOURNAMENT: Successfully inserted into tournament_participants');

      // Entry fee'yi düş (sadece sistem turnuvaları için)
      if (!tournament['is_private']) {
        // // print('🎯 JOIN TOURNAMENT: Updating user coins...');
        await UserService.updateCoins(
          -tournament['entry_fee'], 
          'spent', 
          'Turnuva katılım ücreti'
        );
        // // print('✅ JOIN TOURNAMENT: User coins updated');
      }

      // Turnuva katılımcı sayısını güncelle
      // // print('🎯 JOIN TOURNAMENT: Updating tournament participant count...');
      try {
        await _client.rpc('increment_tournament_participants', params: {
          'tournament_id': tournamentId,
        });
        // // print('✅ JOIN TOURNAMENT: Tournament participant count updated via RPC');
      } catch (rpcError) {
        // // print('⚠️ JOIN TOURNAMENT: RPC failed, trying manual update: $rpcError');
        // RPC başarısız olursa manuel güncelleme yap
        await _client
            .from('tournaments')
            .update({'current_participants': tournament['current_participants'] + 1})
            .eq('id', tournamentId);
        // // print('✅ JOIN TOURNAMENT: Tournament participant count updated manually');
      }

      // Turnuva başlatma mantığı - YENİ SİSTEM:
      // Çarşamba 00:01'de otomatik olarak başlar (zamanlama sistemi ile)
      // Manuel başlatma kaldırıldı - sadece zamanlama sistemi çalışacak

      // // print('✅ JOIN TOURNAMENT: Successfully joined tournament!');
      return true;
    } catch (e) {
      // // print('❌ JOIN TOURNAMENT ERROR: $e');
      // // print('❌ JOIN TOURNAMENT ERROR TYPE: ${e.runtimeType}');
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
      // // print('Error getting user tournaments: $e');
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
      // // print('Error getting tournament details: $e');
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
      // // print('Error getting tournament participants: $e');
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
            photo_uploaded,
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
          'photo_uploaded': item['photo_uploaded'],
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
      // // print('Error voting in tournament: $e');
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
      // // print('Error processing quarter finals: $e');
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
      // // print('Error advancing to quarter finals: $e');
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
      // // print('Error processing semi finals: $e');
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
      // // print('Error advancing to semi finals: $e');
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
      // // print('Error processing finals: $e');
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
      // // print('Error advancing to finals: $e');
    }
  }

  // Turnuva katılımını iptal et ve coin iadesi yap
  static Future<bool> refundTournamentEntry(String tournamentId) async {
    try {
      // // print('🔄 REFUND: Starting refund process for tournament $tournamentId');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        // // print('❌ REFUND: No authenticated user');
        return false;
      }

      // Kullanıcı bilgilerini al
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        // // print('❌ REFUND: Current user not found');
        return false;
      }
      // // print('✅ REFUND: Current user found: ${currentUser.username}, coins: ${currentUser.coins}');

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select('entry_fee')
          .eq('id', tournamentId)
          .single();
      // // print('✅ REFUND: Tournament found, entry_fee: ${tournament['entry_fee']}');

      // Turnuva katılımını sil
      // // print('🔄 REFUND: Deleting tournament participation...');
      await _client
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser.id);
      // // print('✅ REFUND: Tournament participation deleted');

      // Coin iadesi yap
      final newCoinAmount = currentUser.coins + tournament['entry_fee'];
      // // print('🔄 REFUND: Refunding ${tournament['entry_fee']} coins, new total: $newCoinAmount');
      await _client
          .from('users')
          .update({
            'coins': newCoinAmount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser.id);
      // // print('✅ REFUND: Coins updated in database');

      // Turnuva katılımcı sayısını manuel olarak güncelle (RPC yerine)
      // // print('🔄 REFUND: Updating tournament participant count...');
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
      // // print('✅ REFUND: Tournament participant count updated to $newCount');

      // // print('✅ REFUND: Tournament entry refunded successfully');
      return true;
    } catch (e) {
      // // print('❌ REFUND ERROR: $e');
      return false;
    }
  }

  // Turnuva fotoğrafı yükle
  static Future<bool> uploadTournamentPhoto(String tournamentId, String photoUrl) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Kullanıcının users tablosundaki ID'sini al (auth_id -> users.id)
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (currentUserRecord == null) return false;
      final currentUserId = currentUserRecord['id'];

      // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
      final participation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (participation == null) return false;

      // Turnuva fotoğrafını güncelle
      await _client
          .from('tournament_participants')
          .update({
            'tournament_photo_url': photoUrl,
          })
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUserId);

      return true;
    } catch (e) {
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
      // // print('Error getting tournament matches for voting: $e');
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

      // Eşit dağılım için her katılımcının aynı sayıda match'e çıkmasını sağla
      final matches = <Map<String, dynamic>>[];
      final shuffledParticipants = List<Map<String, dynamic>>.from(participants);
      
      // Her katılımcının match sayısını takip et
      final participantMatchCount = <String, int>{};
      for (var participant in participants) {
        participantMatchCount[participant['user_id']] = 0;
      }
      
      // Her katılımcı için eşit sayıda match oluştur (minimum 3)
      final targetMatchesPerParticipant = 3;
      
      // Tüm olası kombinasyonları oluştur
      final allCombinations = <List<Map<String, dynamic>>>[];
      for (int i = 0; i < shuffledParticipants.length; i++) {
        for (int j = i + 1; j < shuffledParticipants.length; j++) {
          allCombinations.add([shuffledParticipants[i], shuffledParticipants[j]]);
        }
      }
      
      // Kombinasyonları karıştır
      allCombinations.shuffle(Random());
      
      // Her katılımcının eşit sayıda match'e çıkmasını sağla
      for (var combination in allCombinations) {
        final participant1 = combination[0];
        final participant2 = combination[1];
        final userId1 = participant1['user_id'];
        final userId2 = participant2['user_id'];
        
        // Her iki katılımcı da hedef match sayısına ulaşmadıysa match oluştur
        if ((participantMatchCount[userId1] ?? 0) < targetMatchesPerParticipant &&
            (participantMatchCount[userId2] ?? 0) < targetMatchesPerParticipant) {
          
          matches.add({
            'user1': {
              'id': participant1['user_id'],
              'username': participant1['users']['username'],
              'tournament_photo_url': participant1['tournament_photo_url'],
              'age': participant1['users']['age'],
              'country': participant1['users']['country'],
              'gender': participant1['users']['gender'],
            },
            'user2': {
              'id': participant2['user_id'],
              'username': participant2['users']['username'],
              'tournament_photo_url': participant2['tournament_photo_url'],
              'age': participant2['users']['age'],
              'country': participant2['users']['country'],
              'gender': participant2['users']['gender'],
            },
          });
          
          // Match sayılarını artır
          participantMatchCount[userId1] = (participantMatchCount[userId1] ?? 0) + 1;
          participantMatchCount[userId2] = (participantMatchCount[userId2] ?? 0) + 1;
        }
        
        // Tüm katılımcılar hedef match sayısına ulaştıysa dur
        if (participantMatchCount.values.every((count) => count >= targetMatchesPerParticipant)) {
          break;
        }
      }
      
      // Eğer yeterli match oluşmadıysa, kalan kombinasyonlardan ekle
      if (matches.length < 3) {
        for (var combination in allCombinations.take(3 - matches.length)) {
          final participant1 = combination[0];
          final participant2 = combination[1];
          
          matches.add({
            'user1': {
              'id': participant1['user_id'],
              'username': participant1['users']['username'],
              'tournament_photo_url': participant1['tournament_photo_url'],
              'age': participant1['users']['age'],
              'country': participant1['users']['country'],
              'gender': participant1['users']['gender'],
            },
            'user2': {
              'id': participant2['user_id'],
              'username': participant2['users']['username'],
              'tournament_photo_url': participant2['tournament_photo_url'],
              'age': participant2['users']['age'],
              'country': participant2['users']['country'],
              'gender': participant2['users']['gender'],
            },
          });
        }
      }

      return matches;
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

      // Oy kaydını ekle (loser_id kolonu yoksa sadece winner_id ile kaydet)
      try {
        await _client.from('private_tournament_votes').insert({
          'tournament_id': tournamentId,
          'voter_id': currentUserId,
          'winner_id': winnerId,
          'created_at': DateTime.now().toIso8601String(),
        });
        print('✅ PRIVATE VOTE: Vote record inserted successfully');
      } catch (voteError) {
        print('⚠️ PRIVATE VOTE: Vote record insert failed: $voteError');
        // Oy kaydı başarısız olsa bile devam et - sadece wins_count güncellemesi yeterli
      }

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
      // // print('Error voting for tournament match: $e');
      return false;
    }
  }

  // Haftalık turnuva fazlarını güncelle - DÜZELTİLMİŞ SİSTEM
  static Future<void> updateTournamentPhases() async {
    try {
      final now = DateTime.now();
      final dayOfWeek = now.weekday;
      final hour = now.hour;

      // Çarşamba 00:01'de kayıt kapanır, turnuva başlar
      if (dayOfWeek == 3 && hour == 0) {
        await _startWeeklyTournaments();
      }
      // Cuma 00:01'de çeyrek final
      else if (dayOfWeek == 5 && hour == 0) {
        await _advanceAllToQuarterFinals();
      }
      // Cumartesi 00:01'de yarı final
      else if (dayOfWeek == 6 && hour == 0) {
        await _advanceAllToSemiFinals();
      }
      // Pazar 00:01'de final
      else if (dayOfWeek == 7 && hour == 0) {
        await _completeTournament();
      }
      
      // Private turnuvaları start date'e göre başlat (sürekli kontrol)
      await _startPrivateTournamentsByStartDate();
      
      // Private turnuvaları end date'e göre tamamla (sürekli kontrol)
      await _completePrivateTournamentsByEndDate();
      
      // Haftalık turnuvaları çarşamba sonrası başlat (sürekli kontrol)
      await _startWeeklyTournamentsByDate();
      
    } catch (e) {
      // Error updating tournament phases
    }
  }

  // Çarşamba 00:01'de turnuvaları başlat
  static Future<void> _startWeeklyTournaments() async {
    try {
      // Bu haftanın turnuvalarını getir
      final thisWeekMonday = _getThisWeekMonday(DateTime.now());
      final thisWeekSunday = thisWeekMonday.add(const Duration(days: 6));
      
      final tournaments = await _client
          .from('tournaments')
          .select('id, name, current_participants')
          .gte('registration_start_date', thisWeekMonday.toIso8601String())
          .lte('registration_start_date', thisWeekSunday.toIso8601String())
          .eq('status', 'upcoming')
          .eq('is_system_tournament', true);

      for (var tournament in tournaments) {
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
        }
      }
    } catch (e) {
      // // print('Error starting weekly tournaments: $e');
    }
  }

  // Haftalık turnuvaları çarşamba sonrası başlat (sürekli kontrol)
  static Future<void> _startWeeklyTournamentsByDate() async {
    try {
      final now = DateTime.now();
      
      // Çarşamba sonrası upcoming durumundaki sistem turnuvalarını getir
      final tournaments = await _client
          .from('tournaments')
          .select('id, name, current_participants, registration_start_date')
          .eq('status', 'upcoming')
          .eq('is_system_tournament', true)
          .eq('is_private', false);
      
      for (var tournament in tournaments) {
        final registrationStartDate = DateTime.parse(tournament['registration_start_date']);
        final wednesday = registrationStartDate.add(const Duration(days: 2)); // Pazartesi + 2 = Çarşamba
        
        // Çarşamba geçmişse turnuvayı başlat (katılımcı kontrolü yok)
        if (now.isAfter(wednesday)) {
          await _client
              .from('tournaments')
              .update({
                'status': 'active',
                'current_phase': 'qualifying',
                'current_round': 1,
                'phase_start_date': DateTime.now().toIso8601String(),
              })
              .eq('id', tournament['id']);
        }
      }
    } catch (e) {
      // Error starting weekly tournaments by date
    }
  }

  // Tüm aktif turnuvaları çeyrek finale geçir
  static Future<void> _advanceAllToQuarterFinals() async {
    try {
      final tournaments = await _client
          .from('tournaments')
          .select('id')
          .eq('status', 'active')
          .eq('current_phase', 'qualifying');
      
      for (var tournament in tournaments) {
        await _advanceToQuarterFinals(tournament['id']);
      }
    } catch (e) {
      // // print('Error advancing all to quarter finals: $e');
    }
  }

  // Tüm aktif turnuvaları yarı finale geçir
  static Future<void> _advanceAllToSemiFinals() async {
    try {
      final tournaments = await _client
          .from('tournaments')
          .select('id')
          .eq('status', 'active')
          .eq('current_phase', 'quarter_finals');
      
      for (var tournament in tournaments) {
        await _advanceToSemiFinals(tournament['id']);
      }
    } catch (e) {
      // // print('Error advancing all to semi finals: $e');
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

        // // print('Tournament ${tournament['id']} completed: 1st=${winner['user_id']}, 2nd=${runnerUp['user_id']}, 3rd=${thirdPlace['user_id']}');
      }
    } catch (e) {
      // // print('Error completing tournament: $e');
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
          // Yeterli katılımcı yoksa turnuvayı iptal et
          await _client
              .from('tournaments')
              .update({
                'status': 'cancelled',
                'current_phase': 'cancelled',
              })
              .eq('id', tournament['id']);
          
          print('❌ DEBUG: Private tournament ${tournament['name']} cancelled due to insufficient participants');
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
        
        // // print('Private tournament ${tournament['name']} completed by end date');
      }
    } catch (e) {
      // // print('Error completing private tournaments by end date: $e');
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
      // // print('Error completing tournament: $e');
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
      // // print('Error creating private tournament: $e');
      // // print('Error details: ${e.toString()}');
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
      // // print('📊 Tournament status: ${tournament['status']}');
      if (tournament['status'] != 'upcoming') {
        // // print('❌ Tournament status is not upcoming: ${tournament['status']}');
        return {'success': false, 'message': 'Kayıt kapalı'};
      }
      
      // Start date kontrolü
      final startDate = DateTime.parse(tournament['start_date']);
      if (DateTime.now().isAfter(startDate)) {
        return {'success': false, 'message': 'Turnuva başlangıç tarihi geçmiş'};
      }

      // Dolu mu kontrol et
      // // print('👥 Current participants: ${tournament['current_participants']}/${tournament['max_participants']}');
      if (tournament['current_participants'] >= tournament['max_participants']) {
        // // print('❌ Tournament is full');
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
          'message': 'Turnuvaya erişim sağlandı. Katılmak için "Katıl" butonuna basın.',
          'tournament_name': tournament['name']
        };
      }

      return {
        'success': true,
        'message': 'Turnuvaya erişim sağlandı. Katılmak için "Katıl" butonuna basın.',
        'tournament_name': tournament['name']
      };
    } catch (e) {
      // // print('Error joining private tournament: $e');
      return {'success': false, 'message': 'Katılım başarısız: $e'};
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
          .select('creator_id, is_private, status')
          .eq('id', tournamentId)
          .single();

      // Sadece private turnuva ve creator olabilir
      if (!tournament['is_private'] || tournament['creator_id'] != currentUser.id) {
        return false;
      }

      // Sadece upcoming durumundaki turnuvalar silinebilir
      if (tournament['status'] != 'upcoming') {
        return false;
      }

      // Önce katılımcıları sil
      await _client
          .from('tournament_participants')
          .delete()
          .eq('tournament_id', tournamentId);

      // Sonra turnuvayı sil
      await _client
          .from('tournaments')
          .delete()
          .eq('id', tournamentId);

      return true;
    } catch (e) {
      print('❌ DEBUG: deletePrivateTournament hatası: $e');
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
      // // print('Error getting my private tournaments: $e');
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
      // // print('Error sending tournament start notification: $e');
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
      // // print('Error sending tournament end notification: $e');
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
      // // print('Error sending tournament join notification: $e');
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
      // // print('Error sending notification to user: $e');
    }
  }
}
