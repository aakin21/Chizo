import 'notification_service.dart';
import 'milestone_notification_service.dart';
import 'tournament_notification_service.dart';
import 'hot_streak_notification_service.dart';
import 'notification_test_service.dart';
import 'notification_settings_service.dart';

class NotificationIntegrationService {
  /// Initialize all notification services
  static Future<void> initializeAll() async {
    try {
      print('🔔 Initializing notification services...');
      
      // Initialize main notification service
      await NotificationService.initialize();
      
      // Initialize notification settings
      await NotificationSettingsService.resetToDefaults();
      
      print('✅ All notification services initialized');
    } catch (e) {
      print('❌ Failed to initialize notification services: $e');
    }
  }

  /// Test notification system
  static Future<void> testNotificationSystem() async {
    try {
      print('🧪 Testing notification system...');

      // Run comprehensive test
      await NotificationTestService.runComprehensiveTest();
      
      print('✅ Notification system test completed');
    } catch (e) {
      print('❌ Notification system test failed: $e');
    }
  }

  /// Quick test notification system
  static Future<void> quickTestNotificationSystem() async {
    try {
      print('🧪 Quick testing notification system...');

      // Test basic notification
      await NotificationService.sendLocalNotification(
        title: '🔔 Hızlı Test',
        body: 'Bildirim sistemi çalışıyor!',
        type: 'system_announcement',
        data: {'test': true, 'quick': true},
      );

      print('✅ Quick notification test completed');
    } catch (e) {
      print('❌ Quick notification test failed: $e');
    }
  }

  /// Schedule test notifications
  static Future<void> scheduleTestNotifications() async {
    try {
      print('⏰ Scheduling test notifications...');

      final now = DateTime.now();
      final startTime = now.add(Duration(minutes: 2));
      final endTime = now.add(Duration(minutes: 4));

      // Schedule tournament notifications
      await TournamentNotificationService.scheduleTournamentNotifications(
        tournamentId: 'test-tournament-1',
        startTime: startTime,
        endTime: endTime,
        tournamentName: 'Test Turnuvası',
      );

      // Schedule elimination notifications
      await TournamentNotificationService.scheduleEliminationNotifications(
        eliminationId: 'test-elimination-1',
        startTime: startTime,
        endTime: endTime,
        eliminationName: 'Test Eleme Turu',
      );

      // Schedule hot streak reminder
      await HotStreakNotificationService.scheduleHotStreakReminder(
        currentStreak: 3,
        lastLoginTime: now,
      );

      print('✅ Test notifications scheduled');
    } catch (e) {
      print('❌ Failed to schedule test notifications: $e');
    }
  }
}

