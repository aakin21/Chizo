import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/match_service.dart';

class MatchGeneratorService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Otomatik match oluşturma sistemi
  static Future<void> generateMatches() async {
    try {
      // Tüm aktif kullanıcıları getir (profil fotoğrafı olan, görünür olan)
      final users = await _client
          .from('users')
          .select()
          .eq('is_visible', true)
          .not('profile_image_url', 'is', null)
          .not('gender', 'is', null);

      if (users.length < 2) return;

      // Kullanıcıları cinsiyete göre grupla
      final Map<String, List<UserModel>> usersByGender = {};
      
      for (var userData in users) {
        final user = UserModel.fromJson(userData);
        final gender = user.gender!;
        
        if (!usersByGender.containsKey(gender)) {
          usersByGender[gender] = [];
        }
        usersByGender[gender]!.add(user);
      }

      // Her cinsiyet grubu için match'ler oluştur
      for (var gender in usersByGender.keys) {
        final genderUsers = usersByGender[gender]!;
        
        if (genderUsers.length < 2) continue;

        // Kullanıcıları karıştır
        genderUsers.shuffle();

        // İkili gruplar oluştur
        for (int i = 0; i < genderUsers.length - 1; i += 2) {
          final user1 = genderUsers[i];
          final user2 = genderUsers[i + 1];

          // Bu iki kullanıcı arasında zaten match var mı kontrol et
          final existingMatch = await _client
              .from('matches')
              .select('id')
              .or('and(user1_id.eq.${user1.id},user2_id.eq.${user2.id}),and(user1_id.eq.${user2.id},user2_id.eq.${user1.id})')
              .eq('is_completed', false)
              .maybeSingle();

          if (existingMatch == null) {
            // Yeni match oluştur
            await MatchService.createMatch(user1.id, user2.id);
          }
        }
      }
    } catch (e) {
      print('Error generating matches: $e');
    }
  }

  // Belirli bir kullanıcı için match oluştur
  static Future<void> generateMatchesForUser(String userId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null || currentUser.gender == null) return;

      // Aynı cinsiyetten, görünür olan, kendisi olmayan kullanıcıları getir
      final users = await _client
          .from('users')
          .select()
          .eq('gender', currentUser.gender!)
          .eq('is_visible', true)
          .neq('id', userId)
          .not('profile_image_url', 'is', null);

      if (users.length == 0) return;

      // Rastgele bir kullanıcı seç
      final randomUser = users[DateTime.now().millisecondsSinceEpoch % users.length];
      final selectedUser = UserModel.fromJson(randomUser);

      // Bu iki kullanıcı arasında zaten match var mı kontrol et
      final existingMatch = await _client
          .from('matches')
          .select('id')
          .or('and(user1_id.eq.$userId,user2_id.eq.${selectedUser.id}),and(user1_id.eq.${selectedUser.id},user2_id.eq.$userId)')
          .eq('is_completed', false)
          .maybeSingle();

      if (existingMatch == null) {
        // Yeni match oluştur
        await MatchService.createMatch(userId, selectedUser.id);
      }
    } catch (e) {
      print('Error generating matches for user: $e');
    }
  }

  // Eski tamamlanmamış match'leri temizle
  static Future<void> cleanupOldMatches() async {
    try {
      // 7 günden eski, tamamlanmamış match'leri sil
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      await _client
          .from('matches')
          .delete()
          .eq('is_completed', false)
          .lt('created_at', sevenDaysAgo.toIso8601String());
    } catch (e) {
      print('Error cleaning up old matches: $e');
    }
  }
}
