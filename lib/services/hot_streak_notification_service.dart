import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'milestone_notification_service.dart';

class HotStreakNotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Hot streak hatırlatması gönder
  static Future<void> sendHotStreakReminder(int currentStreak) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      // Günlük hatırlatma bildirimi
      await _createNotification(
        type: NotificationTypes.streakDailyReminder,
        title: 'Hot Streak Hatırlatması 🔥',
        body: 'Bu gün $currentStreak. gün hot streakini kaçırma!',
      );

      // Ödül hatırlatma bildirimi
      await _createNotification(
        type: NotificationTypes.streakRewardReminder,
        title: 'Giriş Ödülü Hatırlatması 🎁',
        body: 'Bu gün $currentStreak. gün giriş ödülünü toplamayı unutma!',
      );

    } catch (e) {
      print('❌ Failed to send hot streak reminder: $e');
    }
  }

  // Hot streak ödül bildirimi gönder
  static Future<void> sendHotStreakRewardNotification({
    required int streakDays,
    required int coinReward,
  }) async {
    try {
      await MilestoneNotificationService.sendHotStreakRewardNotification(
        streakDays: streakDays,
        coinReward: coinReward,
      );
    } catch (e) {
      print('❌ Failed to send hot streak reward notification: $e');
    }
  }

  // Günlük giriş ödül bildirimi gönder
  static Future<void> sendDailyLoginRewardNotification({
    required int coinReward,
    required int streakDays,
  }) async {
    try {
      await MilestoneNotificationService.sendDailyLoginRewardNotification(
        coinReward: coinReward,
        streakDays: streakDays,
      );
    } catch (e) {
      print('❌ Failed to send daily login reward notification: $e');
    }
  }

  // 12 saat sonra hot streak hatırlatması planla
  static Future<void> scheduleHotStreakReminder({
    required int currentStreak,
    required DateTime lastLoginTime,
  }) async {
    try {
      await NotificationService.scheduleHotStreakReminder(
        currentStreak: currentStreak,
        lastLoginTime: lastLoginTime,
      );
    } catch (e) {
      print('❌ Failed to schedule hot streak reminder: $e');
    }
  }

  // Bildirim oluştur
  static Future<void> _createNotification({
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client.from('notifications').insert({
        'user_id': user.id,
        'type': type,
        'title': title,
        'body': body,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Hot streak notification created: $title');
    } catch (e) {
      print('❌ Failed to create notification: $e');
    }
  }

  // Günlük hot streak hatırlatmalarını kontrol et ve gönder
  static Future<void> checkAndSendDailyReminders() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      // Kullanıcının hot streak bilgisini al
      final response = await _client
          .from('users')
          .select('hot_streak, last_login_date')
          .eq('id', user.id)
          .single();

      final currentStreak = response['hot_streak'] ?? 0;
      final lastLoginDate = response['last_login_date'] as String?;
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Eğer bugün giriş yapmamışsa hatırlatma gönder
      if (lastLoginDate != today) {
        await sendHotStreakReminder(currentStreak);
      }

    } catch (e) {
      print('❌ Failed to check daily reminders: $e');
    }
  }

  // Hot streak bildirimlerini temizle (eski bildirimleri sil)
  static Future<void> cleanupOldStreakNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      // 7 günden eski hot streak bildirimlerini sil
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', user.id)
          .inFilter('type', [
            NotificationTypes.streakDailyReminder,
            NotificationTypes.streakRewardReminder,
          ])
          .lt('created_at', sevenDaysAgo.toIso8601String());

      print('✅ Old hot streak notifications cleaned up');
    } catch (e) {
      print('❌ Failed to cleanup old notifications: $e');
    }
  }
}
