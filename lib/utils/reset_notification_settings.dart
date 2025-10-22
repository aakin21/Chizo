import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim ayarlarını sıfırlama utility
class ResetNotificationSettings {
  /// Tüm bildirim ayarlarını açık konuma getir
  static Future<void> resetAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tüm bildirim tiplerini true yap
      final notificationTypes = [
        'coin_purchase',
        'coin_spent',
        'coin_reward',
        'coin_earned',
        'hotstreak_reward',
        'hotstreak_broken',
        'hotstreak_active',
        'daily_login',
        'match_win',
        'match_loss',
        'match_draw',
        'tournament_start',
        'tournament_end',
        'tournament_win',
        'elimination_start',
        'prediction_won',
        'prediction_lost',
        'voting_reminder',
        'system_announcement',
      ];

      for (final type in notificationTypes) {
        await prefs.setBool('notification_$type', true);
        print('✅ notification_$type = true');
      }

      print('🔔 Tüm bildirim ayarları açıldı!');
    } catch (e) {
      print('❌ Bildirim ayarları sıfırlanamadı: $e');
    }
  }

  /// Mevcut bildirim ayarlarını göster
  static Future<void> showCurrentSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final notificationTypes = [
        'coin_purchase',
        'coin_spent',
        'coin_reward',
        'hotstreak_reward',
        'match_win',
        'tournament_start',
      ];

      print('📊 Mevcut Bildirim Ayarları:');
      for (final type in notificationTypes) {
        final isEnabled = prefs.getBool('notification_$type') ?? true;
        print('  $type: ${isEnabled ? "✅ Açık" : "❌ Kapalı"}');
      }
    } catch (e) {
      print('❌ Ayarlar gösterilemedi: $e');
    }
  }
}
