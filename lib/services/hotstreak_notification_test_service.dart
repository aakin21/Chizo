import 'hot_streak_notification_service.dart';
import 'notification_service.dart';

class HotstreakNotificationTestService {
  /// Test hotstreak reward notification
  static Future<void> testHotStreakRewardNotification() async {
    try {
      print('🧪 Testing hotstreak reward notification...');
      
      await HotStreakNotificationService.sendHotStreakRewardNotification(
        streakDays: 3,
        coinReward: 80,
      );
      
      print('✅ Hotstreak reward notification test completed');
    } catch (e) {
      print('❌ Hotstreak reward notification test failed: $e');
    }
  }

  /// Test hotstreak reminder notification
  static Future<void> testHotStreakReminderNotification() async {
    try {
      print('🧪 Testing hotstreak reminder notification...');
      
      await HotStreakNotificationService.sendHotStreakReminder(5);
      
      print('✅ Hotstreak reminder notification test completed');
    } catch (e) {
      print('❌ Hotstreak reminder notification test failed: $e');
    }
  }

  /// Test all hotstreak notifications
  static Future<void> testAllHotStreakNotifications() async {
    try {
      print('🧪 Testing all hotstreak notifications...');
      
      // Test reward notification
      await testHotStreakRewardNotification();
      
      // Wait a bit
      await Future.delayed(Duration(seconds: 2));
      
      // Test reminder notification
      await testHotStreakReminderNotification();
      
      print('✅ All hotstreak notification tests completed');
    } catch (e) {
      print('❌ Hotstreak notification tests failed: $e');
    }
  }

  /// Test localized notification directly
  static Future<void> testLocalizedHotStreakNotification() async {
    try {
      print('🧪 Testing localized hotstreak notification...');
      
      await NotificationService.sendLocalizedNotification(
        type: 'hotstreak_reward',
        data: {
          'streak_days': 7,
          'coin_reward': 100,
        },
      );
      
      print('✅ Localized hotstreak notification test completed');
    } catch (e) {
      print('❌ Localized hotstreak notification test failed: $e');
    }
  }
}
