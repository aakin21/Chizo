import 'package:supabase_flutter/supabase_flutter.dart';

class CountryRankingService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Kullanıcının ülkelere göre istatistiklerini getirir
  /// Bu, diğer ülkelerden gelen oylar ile kazanma oranını gösterir
  static Future<List<Map<String, dynamic>>> getUserCountryStats(String authUserId) async {
    try {
      print('🔍 Getting country stats for auth user: $authUserId');
      
      // Önce auth ID'den user ID'yi al
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', authUserId)
          .single();
      
      final userId = userResponse['id'];
      print('🔍 Found user ID: $userId');
      
      // Yeni tablodan direkt verileri al (çok daha hızlı!)
      final statsResponse = await _supabase
          .from('user_country_stats')
          .select('country, wins, losses, total_matches, win_rate')
          .eq('user_id', userId)
          .gt('total_matches', 0) // Sadece maçı olan ülkeleri getir
          .order('win_rate', ascending: false);

      print('📊 Found ${statsResponse.length} country stats');
      print('📊 Stats data: $statsResponse');

      if (statsResponse.isEmpty) {
        print('❌ No country stats found for user');
        return [];
      }

      // Veriyi uygulama formatına çevir
      List<Map<String, dynamic>> result = [];
      for (var stat in statsResponse) {
        result.add({
          'country': stat['country'],
          'wins': stat['wins'],
          'losses': stat['losses'],
          'totalMatches': stat['total_matches'],
          'winRate': (stat['win_rate'] as num).toDouble(),
        });
      }

      print('✅ Final result: $result');
      return result;
    } catch (e) {
      print('Error fetching country stats: $e');
      return [];
    }
  }
}
