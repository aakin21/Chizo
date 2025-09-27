import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class NotificationService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Local notifications initialize
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Notification tap handler
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('Notification tapped: ${notificationResponse.payload}');
  }

  // Show instant in-app notification
  static Future<void> showInAppNotification({
    required String title,
    required String message,
    String? type,
  }) async {
    try {
      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'chizo_app_notifications',
        'Chizo Application Notifications',
        channelDescription: 'Notifications for matches, tournaments, and app events',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notificationId,
        title,
        message,
        platformDetails,
        payload: jsonEncode({'type': type, 'timestamp': DateTime.now().toIso8601String()}),
      );

      print('Shown notification: $title - $message');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Check user notification preferences from database 
  static Future<bool?> isNotificationEnabled(String type) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _client
          .from('user_notification_preferences')
          .select('is_enabled')
          .eq('user_id', currentUser.id)
          .eq('notification_type', type)
          .maybeSingle();

      if (response == null) return null;
      return response['is_enabled'] == true;
    } catch (e) {
      print('Error checking notification preferences: $e');
      return null; // No preference found
    }
  }

  // Update user notification preferences
  static Future<bool> updateNotificationPreference(String type, bool isEnabled) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      await _client
          .from('user_notification_preferences')
          .upsert({
            'user_id': currentUser.id,
            'notification_type': type,
            'is_enabled': isEnabled,
            'updated_at': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      print('Error updating notification preference: $e');
      return false;
    }
  }

  // Tournament notifications
  static Future<void> notifyTournamentJoin(String tournamentTitle) async {
    final isEnabled = await isNotificationEnabled('tournament');
    if (isEnabled == null || !isEnabled) return;
    
    await showInAppNotification(
      title: '🏆 Turnuva',
      message: 'Yeni turnuva "$tournamentTitle" başladı!',
      type: 'tournament',
    );
  }

  static Future<void> notifyTournamentResult(String tournamentTitle, bool isWinner) async {
    final isEnabled = await isNotificationEnabled('tournament');
    if (isEnabled == null || !isEnabled) return;
    
    await showInAppNotification(
      title: '🏆 Turnuva Sonucu',
      message: isWinner 
          ? 'Tebrikler! "$tournamentTitle" turnuvasını kazandınız!'
          : '"$tournamentTitle" turnuvasını tamamladınız.',
      type: 'tournament',
    );
  }

  // Match notifications  
  static Future<void> notifyMatchReminder() async {
    final isEnabled = await isNotificationEnabled('vote_reminder');
    if (isEnabled == null || !isEnabled) return;
    
    await showInAppNotification(
      title: '🗳️ Oy Hatırlatması', 
      message: 'Bekleyen oy verme işleminiz var!',
      type: 'vote_reminder',
    );
  }

  // Victory notifications
  static Future<void> notifyVictory(int coinsEarned) async {
    final isEnabled = await isNotificationEnabled('win_celebration');
    if (isEnabled == null || !isEnabled) return;
    
    await showInAppNotification(
      title: '🎉 Tebrikler!',
      message: 'Zafer kazandınız ve $coinsEarned coin kazandınız!',
      type: 'victory',
    );
  }

  // Streak notifications
  static Future<void> notifyStreakReminder(int currentStreak) async {
    final isEnabled = await isNotificationEnabled('streak_reminder');
    if (isEnabled == null || !isEnabled) return;
    
    await showInAppNotification(
      title: '🔥 Streak Hatırlatması',
      message: 'Günlük streak\'iniz devam ediyor! ($currentStreak gün)',
      type: 'streak',
    );
  }

  static Future<void> notifyNewStreak(int streakDays, int coinsEarned) async {
    final isEnabled = await isNotificationEnabled('streak_reminder');
    if (isEnabled == null || !isEnabled) return;
    
    await showInAppNotification(
      title: '🔥 Yeni Streak!',
      message: 'Günlük streak ödülü: $streakDays gün streak ile $coinsEarned coin!',
      type: 'streak',
    );
  }

  // Store notification history to database
  static Future<void> storeNotificationHistory({
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      await _client.from('notification_history').insert({
        'user_id': currentUser.id,
        'title': title,
        'message': message,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      print('Error storing notification history: $e');
    }
  }

  // Get notification history for user
  static Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _client
          .from('notification_history')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting notification history: $e');
      return [];
    }
  }

  // Schedule future notification
  static Future<void> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledTime,
    String? type,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'chizo_scheduled_notifications',
        'Chizo Scheduled Notifications',
        channelDescription: 'Scheduled notifications for reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        message,
        tzScheduledTime,
        platformDetails,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'type': type}),
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
