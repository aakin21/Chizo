import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationSettingsService {
  /// Get notification setting for a specific type
  static Future<bool> isNotificationEnabled(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notification_$type') ?? true; // Default: enabled
    } catch (e) {
      print('❌ Failed to get notification setting: $e');
      return true; // Default: enabled
    }
  }

  /// Set notification setting for a specific type
  static Future<void> setNotificationEnabled(String type, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_$type', enabled);
    } catch (e) {
      print('❌ Failed to set notification setting: $e');
    }
  }

  /// Get all notification settings
  static Future<Map<String, bool>> getAllNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'tournament_updates': prefs.getBool('notification_${NotificationTypes.tournamentUpdate}') ?? true,
        'tournament_reminders': prefs.getBool('notification_${NotificationTypes.tournamentMatchStartReminder}') ?? true,
        'voting_results': prefs.getBool('notification_${NotificationTypes.votingResult}') ?? true,
        'coin_rewards': prefs.getBool('notification_${NotificationTypes.coinReward}') ?? true,
        'hot_streak_reminders': prefs.getBool('notification_${NotificationTypes.streakDailyReminder}') ?? true,
        'match_notifications': prefs.getBool('notification_${NotificationTypes.matchWon}') ?? true,
        'milestone_notifications': prefs.getBool('notification_${NotificationTypes.photoMilestone}') ?? true,
        'system_announcements': prefs.getBool('notification_${NotificationTypes.systemAnnouncement}') ?? true,
      };
    } catch (e) {
      print('❌ Failed to get all notification settings: $e');
      return {};
    }
  }

  /// Set all notification settings
  static Future<void> setAllNotificationSettings(Map<String, bool> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var entry in settings.entries) {
        await prefs.setBool('notification_${entry.key}', entry.value);
      }
    } catch (e) {
      print('❌ Failed to set all notification settings: $e');
    }
  }

  /// Check if notification should be sent (considering settings)
  static Future<bool> shouldSendNotification(String type) async {
    try {
      final isEnabled = await isNotificationEnabled(type);
      return isEnabled;
    } catch (e) {
      print('❌ Failed to check if notification should be sent: $e');
      return true; // Default: send notification
    }
  }

  /// Reset all notification settings to default (all enabled)
  static Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultSettings = {
        'notification_${NotificationTypes.tournamentUpdate}': true,
        'notification_${NotificationTypes.tournamentMatchStartReminder}': true,
        'notification_${NotificationTypes.tournamentMatchEndReminder}': true,
        'notification_${NotificationTypes.votingResult}': true,
        'notification_${NotificationTypes.coinReward}': true,
        'notification_${NotificationTypes.streakDailyReminder}': true,
        'notification_${NotificationTypes.streakRewardReminder}': true,
        'notification_${NotificationTypes.matchWon}': true,
        'notification_${NotificationTypes.photoMilestone}': true,
        'notification_${NotificationTypes.totalMilestone}': true,
        'notification_${NotificationTypes.systemAnnouncement}': true,
      };

      for (var entry in defaultSettings.entries) {
        await prefs.setBool(entry.key, entry.value);
      }
    } catch (e) {
      print('❌ Failed to reset notification settings: $e');
    }
  }
}

