import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tournament_model.dart';
import 'user_service.dart';

class TournamentService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Aktif turnuvaları getir
  static Future<List<TournamentModel>> getActiveTournaments() async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .inFilter('status', ['upcoming', 'active'])
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => TournamentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting active tournaments: $e');
      return [];
    }
  }

  // Turnuvaya katıl
  static Future<bool> joinTournament(String tournamentId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Turnuva bilgilerini al
      final tournament = await _client
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .single();

      // Kullanıcının coin kontrolü
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null || currentUser.coins < tournament['entry_fee']) {
        return false; // Yetersiz coin
      }

      // Zaten katılmış mı kontrol et
      final existingParticipation = await _client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingParticipation != null) {
        return false; // Zaten katılmış
      }

      // Turnuvaya katıl
      await _client.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_eliminated': false,
        'score': 0,
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

      return true;
    } catch (e) {
      print('Error joining tournament: $e');
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

  // Turnuva kazananını belirle ve ödülü ver
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
}
