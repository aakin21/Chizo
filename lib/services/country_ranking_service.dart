import 'package:supabase_flutter/supabase_flutter.dart';

class CountryRankingService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Kullanıcının ülkelere göre istatistiklerini getirir
  /// Bu, diğer ülkelerden gelen oylar ile kazanma oranını gösterir
  static Future<List<Map<String, dynamic>>> getUserCountryStats(String authUserId) async {
    try {
      // Önce auth ID'den user ID'yi al
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', authUserId)
          .single();

      if (!userResponse.containsKey('id')) {
        return [];
      }
      final userId = userResponse['id'];

      // Yeni tablodan direkt verileri al (çok daha hızlı!)
      final statsResponse = await _supabase
          .from('user_country_stats')
          .select('country, wins, losses, total_matches, win_rate')
          .eq('user_id', userId)
          .gt('total_matches', 0) // Sadece maçı olan ülkeleri getir
          .order('win_rate', ascending: false);

      if (statsResponse.isEmpty) {
        return [];
      }

      // Veriyi uygulama formatına çevir
      List<Map<String, dynamic>> result = [];
      for (final item in statsResponse) {
        final country = item['country'];
        final wins = item['wins'];
        final losses = item['losses'];
        final totalMatches = item['total_matches'];
        final winRate = item['win_rate'];

        if (country != null && wins != null && losses != null && totalMatches != null && winRate != null) {
          result.add({
            'country': country,
            'wins': (wins as num).toInt(),
            'losses': (losses as num).toInt(),
            'totalMatches': (totalMatches as num).toInt(),
            'winRate': (winRate as num).toDouble(),
          });
        }
      }

      return result;
    } catch (e) {
      // debugPrint('Error fetching country stats: $e');
      return [];
    }
  }
}
