import 'notification_service.dart';
import 'tournament_notification_service.dart';
import 'hot_streak_notification_service.dart';
import 'notification_settings_service.dart';

class NotificationTestService {
  /// Test all notification types
  static Future<void> testAllNotifications() async {
    try {
      print('🧪 Testing all notification types...');

      // Test basic local notification
      await NotificationService.sendLocalNotification(
        title: '🔔 Test Bildirimi',
        body: 'Bu bir test bildirimidir - sistem çalışıyor!',
        type: 'system_announcement',
        data: {'test': true, 'timestamp': DateTime.now().toIso8601String()},
      );

      // Test tournament notification
      await TournamentNotificationService.sendTournamentUpdateNotification(
        tournamentName: 'Test Turnuvası',
        message: 'Test mesajı - turnuva güncellemesi',
      );

      // Test milestone notification
      await NotificationService.sendPhotoMilestoneNotification(
        photoId: 1,
        winCount: 100,
        photoName: 'Test Foto',
      );

      // Test hot streak notification
      await HotStreakNotificationService.sendHotStreakRewardNotification(
        streakDays: 5,
        coinReward: 50,
      );

      // Test coin reward notification
      await NotificationService.sendLocalNotification(
        title: '💰 Coin Ödülü!',
        body: 'Tebrikler! 50 coin kazandınız!',
        type: 'coin_reward',
        data: {'coins': 50, 'reason': 'test_reward'},
      );

      // Test match won notification
      await NotificationService.sendLocalNotification(
        title: '🎉 Maç Kazandınız!',
        body: 'Harika! Bir maç daha kazandınız!',
        type: 'match_won',
        data: {'match_id': 'test_match', 'points': 10},
      );

      print('✅ All notification tests completed');
    } catch (e) {
      print('❌ Notification test failed: $e');
    }
  }

  /// Test scheduled notifications
  static Future<void> testScheduledNotifications() async {
    try {
      print('🧪 Testing scheduled notifications...');

      final now = DateTime.now();
      final startTime = now.add(Duration(hours: 2));
      final endTime = now.add(Duration(hours: 4));

      // Test tournament scheduling
      await TournamentNotificationService.scheduleTournamentNotifications(
        tournamentId: 'test-tournament-1',
        startTime: startTime,
        endTime: endTime,
        tournamentName: 'Test Turnuvası',
      );

      // Test elimination scheduling
      await TournamentNotificationService.scheduleEliminationNotifications(
        eliminationId: 'test-elimination-1',
        startTime: startTime,
        endTime: endTime,
        eliminationName: 'Test Eleme Turu',
      );

      // Test hot streak reminder
      await HotStreakNotificationService.scheduleHotStreakReminder(
        currentStreak: 3,
        lastLoginTime: now,
      );

      print('✅ Scheduled notification tests completed');
    } catch (e) {
      print('❌ Scheduled notification test failed: $e');
    }
  }

  /// Test notification permissions
  static Future<void> testNotificationPermissions() async {
    try {
      print('🧪 Testing notification permissions...');

      // Check if notifications are enabled
      final isEnabled = await NotificationSettingsService.isNotificationEnabled('system_announcement');
      print('🔔 System announcements enabled: $isEnabled');

      // Test all notification settings
      final allSettings = await NotificationSettingsService.getAllNotificationSettings();
      print('🔔 All notification settings: $allSettings');

      // Test if notification should be sent
      final shouldSend = await NotificationSettingsService.shouldSendNotification('system_announcement');
      print('🔔 Should send system announcement: $shouldSend');

      print('✅ Permission tests completed');
    } catch (e) {
      print('❌ Permission test failed: $e');
    }
  }

  /// Test notification database operations
  static Future<void> testNotificationDatabase() async {
    try {
      print('🧪 Testing notification database operations...');

      // Get user notifications
      final notifications = await NotificationService.getUserNotifications(limit: 10);
      print('📱 User notifications count: ${notifications.length}');

      // Get unread count
      final unreadCount = await NotificationService.getUnreadCount();
      print('📱 Unread notifications count: $unreadCount');

      // Test marking as read
      if (notifications.isNotEmpty) {
        final firstNotification = notifications.first;
        final success = await NotificationService.markAsRead(firstNotification.id);
        print('📱 Mark as read success: $success');
      }

      print('✅ Database tests completed');
    } catch (e) {
      print('❌ Database test failed: $e');
    }
  }

  /// Comprehensive notification system test
  static Future<void> runComprehensiveTest() async {
    try {
      print('🧪 Running comprehensive notification system test...');
      
      // Test 1: Permissions
      await testNotificationPermissions();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 2: Basic notifications
      await testAllNotifications();
      await Future.delayed(Duration(seconds: 2));
      
      // Test 3: Database operations
      await testNotificationDatabase();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 4: Scheduled notifications
      await testScheduledNotifications();
      
      print('✅ Comprehensive notification test completed');
    } catch (e) {
      print('❌ Comprehensive test failed: $e');
    }
  }

  /// Test notification with different priorities
  static Future<void> testNotificationPriorities() async {
    try {
      print('🧪 Testing notification priorities...');

      // High priority notification
      await NotificationService.sendLocalNotification(
        title: '🚨 Yüksek Öncelik',
        body: 'Bu yüksek öncelikli bir bildirimdir',
        type: 'system_announcement',
        data: {'priority': 'high'},
      );

      // Normal priority notification
      await NotificationService.sendLocalNotification(
        title: '📢 Normal Öncelik',
        body: 'Bu normal öncelikli bir bildirimdir',
        type: 'tournament_update',
        data: {'priority': 'normal'},
      );

      // Low priority notification
      await NotificationService.sendLocalNotification(
        title: 'ℹ️ Düşük Öncelik',
        body: 'Bu düşük öncelikli bir bildirimdir',
        type: 'profile_update',
        data: {'priority': 'low'},
      );

      print('✅ Priority tests completed');
    } catch (e) {
      print('❌ Priority test failed: $e');
    }
  }
}
