import 'notification_service.dart';
import 'notification_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDebugService {
  /// Debug notification system status
  static Future<void> debugNotificationSystem() async {
    try {
      print('🔍 === NOTIFICATION SYSTEM DEBUG ===');
      
      // Check initialization status
      print('🔍 Checking initialization status...');
      // Note: We can't directly check _isInitialized since it's private
      // But we can test by trying to send a notification
      
      // Check notification settings
      print('🔍 Checking notification settings...');
      final allSettings = await NotificationSettingsService.getAllNotificationSettings();
      print('📱 All notification settings: $allSettings');
      
      // Check SharedPreferences
      print('🔍 Checking SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final notificationKeys = keys.where((key) => key.startsWith('notification_')).toList();
      print('📱 Notification keys in SharedPreferences: $notificationKeys');
      
      // Check if notifications are enabled
      for (final key in notificationKeys) {
        final value = prefs.getBool(key);
        print('📱 $key: $value');
      }
      
      // Test basic notification
      print('🔍 Testing basic notification...');
      await NotificationService.sendLocalNotification(
        title: '🔍 Debug Test',
        body: 'Bu bir debug test bildirimidir',
        type: 'system_announcement',
        data: {'debug': true, 'timestamp': DateTime.now().toIso8601String()},
      );
      
      print('✅ Debug completed');
    } catch (e) {
      print('❌ Debug failed: $e');
    }
  }
  
  /// Check notification permissions
  static Future<void> checkNotificationPermissions() async {
    try {
      print('🔍 === NOTIFICATION PERMISSIONS DEBUG ===');
      
      // Check if notifications are enabled in settings
      final isSystemEnabled = await NotificationSettingsService.isNotificationEnabled('system_announcement');
      print('📱 System announcements enabled: $isSystemEnabled');
      
      // Check all notification types
      final allSettings = await NotificationSettingsService.getAllNotificationSettings();
      for (final entry in allSettings.entries) {
        print('📱 ${entry.key}: ${entry.value}');
      }
      
      // Check SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final notificationKeys = keys.where((key) => key.startsWith('notification_')).toList();
      
      print('📱 Found ${notificationKeys.length} notification settings:');
      for (final key in notificationKeys) {
        final value = prefs.getBool(key);
        print('📱 $key: $value');
      }
      
      print('✅ Permission check completed');
    } catch (e) {
      print('❌ Permission check failed: $e');
    }
  }
  
  /// Reset all notification settings
  static Future<void> resetNotificationSettings() async {
    try {
      print('🔍 === RESETTING NOTIFICATION SETTINGS ===');
      
      // Reset to defaults
      await NotificationSettingsService.resetToDefaults();
      print('✅ Notification settings reset to defaults');
      
      // Verify reset
      final allSettings = await NotificationSettingsService.getAllNotificationSettings();
      print('📱 Settings after reset: $allSettings');
      
      print('✅ Reset completed');
    } catch (e) {
      print('❌ Reset failed: $e');
    }
  }
  
  /// Test notification with different types
  static Future<void> testAllNotificationTypes() async {
    try {
      print('🔍 === TESTING ALL NOTIFICATION TYPES ===');
      
      final notificationTypes = [
        'system_announcement',
        'tournament_update',
        'voting_result',
        'coin_reward',
        'match_won',
        'photo_milestone',
        'total_milestone',
        'streak_daily_reminder',
      ];
      
      for (final type in notificationTypes) {
        print('📱 Testing notification type: $type');
        
        await NotificationService.sendLocalNotification(
          title: '🔍 Test: $type',
          body: 'Bu bir $type test bildirimidir',
          type: type,
          data: {'test_type': type, 'timestamp': DateTime.now().toIso8601String()},
        );
        
        // Small delay between notifications
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      print('✅ All notification types tested');
    } catch (e) {
      print('❌ Notification type testing failed: $e');
    }
  }
}
