import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'dart:convert';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;

  static String? _fcmToken;
  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase (sadece mobile için)
      try {
        await Firebase.initializeApp();
      } catch (e) {
        print('Firebase initialization failed (web platform): $e');
        // Web'de Firebase olmadan devam et
        _isInitialized = true;
        return;
      }
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request permissions
      await _requestPermissions();
      
      // Get FCM token
      await _getFCMToken();
      
      // Setup message handlers
      _setupMessageHandlers();
      
      _isInitialized = true;
    } catch (e) {
      print('❌ NotificationService initialization failed: $e');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    // Request FCM permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    // Request local notification permissions for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Get FCM token
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');
      
      // Save token to Supabase
      await _saveTokenToDatabase(_fcmToken);
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
    }
  }

  /// Save FCM token to database
  static Future<void> _saveTokenToDatabase(String? token) async {
    if (token == null) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Foreground message received: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(message);
    
    // Save to database
    await _saveNotificationToDatabase(message);
  }

  /// Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('👆 Notification tapped: ${message.messageId}');
    
    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data);
  }

  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.id}');
    
    // Handle navigation based on notification data
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  /// Handle notification navigation
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    
    switch (type) {
      case NotificationTypes.tournamentUpdate:
        // Navigate to tournament tab
        print('Navigate to tournament');
        break;
      case NotificationTypes.votingResult:
        // Navigate to voting tab
        print('Navigate to voting');
        break;
      case NotificationTypes.coinReward:
        // Navigate to profile tab
        print('Navigate to profile');
        break;
      default:
        print('Navigate to home');
        break;
    }
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chizo_notifications',
      'Chizo Notifications',
      channelDescription: 'Notifications for Chizo app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
      payload: json.encode(message.data),
    );
  }

  /// Save notification to database
  static Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        type: message.data['type'] ?? 'system_announcement',
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        data: message.data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _supabase.from('notifications').insert(notification.toJson());
    } catch (e) {
      print('❌ Failed to save notification: $e');
    }
  }

  /// Get user notifications
  static Future<List<NotificationModel>> getUserNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Failed to get notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      return true;
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('is_read', false);

      return true;
    } catch (e) {
      print('❌ Failed to mark all notifications as read: $e');
      return false;
    }
  }

  /// Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Send test notification
  static Future<void> sendTestNotification() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'chizo_test',
        'Test Notifications',
        channelDescription: 'Test notifications for Chizo app',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '🧪 Test Notification',
        'Chizo notification system is working!',
        details,
      );

    } catch (e) {
      print('❌ Failed to send test notification: $e');
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('❌ Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('❌ Failed to unsubscribe from topic: $e');
    }
  }

  /// Check if notification type is enabled
  static Future<bool?> isNotificationEnabled(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notification_$type');
    } catch (e) {
      print('❌ Failed to get notification preference: $e');
      return null;
    }
  }

  /// Update notification preference
  static Future<void> updateNotificationPreference(String type, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_$type', enabled);
    } catch (e) {
      print('❌ Failed to update notification preference: $e');
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
}