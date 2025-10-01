import 'package:supabase_flutter/supabase_flutter.dart';

class StreakService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Günlük giriş streak'ini kontrol et ve ödül ver
  static Future<Map<String, dynamic>> checkAndUpdateStreak() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        return {'success': false, 'message': 'Kullanıcı giriş yapmamış'};
      }

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Kullanıcı bilgilerini al
      final userResponse = await _client
          .from('users')
          .select('*')
          .eq('auth_id', authUser.id)
          .single();

      if (userResponse.isEmpty) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      final currentStreak = (userResponse['current_streak'] ?? 0) as int;
      final lastLoginDate = userResponse['last_login_date'];
      final totalStreakDays = (userResponse['total_streak_days'] ?? 0) as int;

      // Son giriş tarihini kontrol et
      DateTime? lastLogin;
      if (lastLoginDate != null) {
        lastLogin = DateTime.parse(lastLoginDate);
        lastLogin = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      }

      int newStreak = currentStreak;
      int rewardCoins = 0;
      String message = '';

      if (lastLogin == null || lastLogin.isBefore(todayDate)) {
        // İlk giriş veya yeni gün
        if (lastLogin == null) {
          // İlk giriş
          newStreak = 1;
          rewardCoins = 50;
          message = '🎉 İlk girişiniz! 50 coin kazandınız!';
        } else {
          final daysDifference = todayDate.difference(lastLogin).inDays;
          
          if (daysDifference == 1) {
            // Ardışık gün - streak devam ediyor
            newStreak = currentStreak + 1;
            
            // Streak ödülü hesapla (maksimum 7 gün, 100 coin)
            if (newStreak <= 7) {
              rewardCoins = 50 + ((newStreak - 1) * 10);
            } else {
              rewardCoins = 100; // 7 günden sonra sabit 100 coin
            }
            
            message = '🔥 $newStreak günlük streak! $rewardCoins coin kazandınız!';
          } else if (daysDifference > 1) {
            // Streak kırıldı - sıfırla
            newStreak = 1;
            rewardCoins = 50;
            message = '💔 Streak kırıldı! Yeni başlangıç: 50 coin kazandınız!';
          }
        }

        // Kullanıcı bilgilerini güncelle
        await _client
            .from('users')
            .update({
              'current_streak': newStreak,
              'last_login_date': todayDate.toIso8601String().split('T')[0],
              'total_streak_days': totalStreakDays + 1,
              'coins': (userResponse['coins'] ?? 0) + rewardCoins,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('auth_id', authUser.id);

        // Coin transaction kaydet
        await _client.from('coin_transactions').insert({
          'user_id': userResponse['id'],
          'amount': rewardCoins,
          'type': 'earned',
          'description': 'Günlük streak ödülü ($newStreak gün)',
          'created_at': DateTime.now().toIso8601String(),
        });

        return {
          'success': true,
          'streak': newStreak,
          'reward_coins': rewardCoins,
          'message': message,
          'is_new_streak': true,
        };
      } else {
        // Bugün zaten giriş yapılmış
        return {
          'success': true,
          'streak': currentStreak,
          'reward_coins': 0,
          'message': 'Bugün zaten giriş yaptınız!',
          'is_new_streak': false,
        };
      }
    } catch (e) {
      // print('Error checking streak: $e');
      return {'success': false, 'message': 'Streak kontrolünde hata oluştu'};
    }
  }

  // Kullanıcının streak bilgilerini al
  static Future<Map<String, dynamic>> getUserStreakInfo() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        return {'success': false, 'message': 'Kullanıcı giriş yapmamış'};
      }

      final userResponse = await _client
          .from('users')
          .select('current_streak, last_login_date, total_streak_days')
          .eq('auth_id', authUser.id)
          .single();

      if (userResponse.isEmpty) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      final currentStreak = (userResponse['current_streak'] ?? 0) as int;
      final lastLoginDate = userResponse['last_login_date'];
      final totalStreakDays = (userResponse['total_streak_days'] ?? 0) as int;

      // Sonraki ödülü hesapla
      int nextReward = 0;
      if (currentStreak < 7) {
        nextReward = 50 + (currentStreak * 10);
      } else {
        nextReward = 100;
      }

      return {
        'success': true,
        'current_streak': currentStreak,
        'last_login_date': lastLoginDate,
        'total_streak_days': totalStreakDays,
        'next_reward': nextReward,
        'max_streak_reached': currentStreak >= 7,
      };
    } catch (e) {
      // print('Error getting streak info: $e');
      return {'success': false, 'message': 'Streak bilgisi alınamadı'};
    }
  }

  // Streak ödül tablosu
  static List<Map<String, dynamic>> getStreakRewards() {
    return [
      {'day': 1, 'coins': 50, 'emoji': '🎉'},
      {'day': 2, 'coins': 60, 'emoji': '🔥'},
      {'day': 3, 'coins': 70, 'emoji': '⚡'},
      {'day': 4, 'coins': 80, 'emoji': '💎'},
      {'day': 5, 'coins': 90, 'emoji': '👑'},
      {'day': 6, 'coins': 100, 'emoji': '🏆'},
      {'day': 7, 'coins': 100, 'emoji': '🌟'},
      {'day': 8, 'coins': 100, 'emoji': '🌟'},
    ];
  }
}
