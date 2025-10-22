import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'notification_language_service.dart';
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
    if (_isInitialized) {
      print('🔔 NotificationService already initialized');
      return;
    }

    try {
      print('🔔 Initializing NotificationService...');
      
      // Initialize Firebase (sadece mobile için)
      try {
        await Firebase.initializeApp();
        print('✅ Firebase initialized successfully');
      } catch (e) {
        print('⚠️ Firebase initialization failed (web platform): $e');
        // Web'de Firebase olmadan devam et
        _isInitialized = true;
        return;
      }
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      print('✅ Local notifications initialized');
      
      // Request permissions
      await _requestPermissions();
      print('✅ Permissions requested');
      
      // Get FCM token
      await _getFCMToken();
      print('✅ FCM token obtained');
      
      // Setup message handlers
      _setupMessageHandlers();
      print('✅ Message handlers setup');
      
      _isInitialized = true;
      print('✅ NotificationService initialization completed');
    } catch (e) {
      print('❌ NotificationService initialization failed: $e');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channels for Android
    await _createNotificationChannels();
  }
  
  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'chizo_notifications',
      'Chizo Notifications',
      description: 'General notifications for Chizo app',
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );
    
    const AndroidNotificationChannel highPriorityChannel = AndroidNotificationChannel(
      'chizo_high_priority',
      'Chizo High Priority',
      description: 'High priority notifications for Chizo app',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
        
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highPriorityChannel);
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    try {
      // Request Firebase permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
      );
      
      print('🔔 Notification permission status: ${settings.authorizationStatus}');
      
      // Request local notification permissions for Android
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print('🔔 Android notification permission granted: $granted');
      }
      
    } catch (e) {
      print('❌ Failed to request permissions: $e');
    }
  }

  /// Get FCM token
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _saveTokenToDatabase(_fcmToken);
      }
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

  // Public helper methods for debugging

  /// Get the current FCM token
  static Future<String?> getFCMToken() async {
    if (_fcmToken != null) return _fcmToken;
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      return _fcmToken;
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Check if notification permissions are granted
  static Future<bool> hasPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('❌ Failed to check permission: $e');
      return false;
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
    final type = data['type'] as String?;
    
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

      // users tablosundan gerçek user_id al
      final userRecord = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return;

      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userRecord['id'],
        type: message.data['type'] ?? 'system_announcement',
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        data: message.data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _supabase.from('notifications').insert(notification.toJson());
      await _cleanupExcessNotifications();
    } catch (e) {
      print('❌ Failed to save notification: $e');
    }
  }

  /// Get user notifications (maksimum 20)
  static Future<List<NotificationModel>> getUserNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // users tablosundan gerçek user_id al
      final userRecord = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return [];

      final actualLimit = limit > 20 ? 20 : limit;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userRecord['id'])
          .order('created_at', ascending: false)
          .range(offset, offset + actualLimit - 1);

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

      // users tablosundan gerçek user_id al
      final userRecord = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return false;

      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userRecord['id'])
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

      // users tablosundan gerçek user_id al
      final userRecord = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userRecord['id'])
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0;
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

  /// Send local notification with language support
  static Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Bildirim ayarlarını kontrol et
      if (type != null) {
        final prefs = await SharedPreferences.getInstance();
        final isEnabled = prefs.getBool('notification_$type') ?? true;
        if (!isEnabled) {
          // Ayarlar kapalı olsa bile veritabanına kaydet (uygulama içinde görünsün)
          await _saveLocalNotificationToDatabase(title, body, type, data);
          return;
        }
      }

      // Coin bildirimleri için custom icon kullan
      String iconPath = '@mipmap/ic_launcher';
      String? largeIconPath;
      
      if (type != null && (type.contains('coin') || type.contains('spent') || type.contains('purchase') || type.contains('reward'))) {
        iconPath = '@drawable/coin_icon';
        largeIconPath = '@drawable/coin_icon';
      }

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'chizo_notifications',
        'Chizo Notifications',
        channelDescription: 'Notifications for Chizo app',
        importance: Importance.high,
        icon: iconPath,
        largeIcon: largeIconPath != null ? DrawableResourceAndroidBitmap(largeIconPath) : null,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: data != null ? json.encode(data) : null,
      );

      // Save to database
      await _saveLocalNotificationToDatabase(title, body, type, data);
    } catch (e) {
      print('❌ Failed to send local notification: $e');
    }
  }

  /// Send localized notification (new method)
  static Future<void> sendLocalizedNotification({
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final localizedContent = await NotificationLanguageService.getLocalizedContent(
        type: type,
        data: data,
      );

      await sendLocalNotification(
        title: localizedContent['title']!,
        body: localizedContent['body']!,
        type: type,
        data: data,
      );
    } catch (e) {
      print('❌ Failed to send localized notification: $e');
    }
  }

  /// Send localized notification with specific language
  static Future<void> sendLocalizedNotificationWithLanguage({
    required String type,
    required String language,
    Map<String, dynamic>? data,
  }) async {
    try {
      final localizedContent = NotificationLanguageService.getLocalizedContentWithLanguage(
        type: type,
        language: language,
        data: data,
      );

      await sendLocalNotification(
        title: localizedContent['title']!,
        body: localizedContent['body']!,
        type: type,
        data: data,
      );
    } catch (e) {
      print('❌ Failed to send localized notification: $e');
    }
  }

  /// Save local notification to database
  static Future<void> _saveLocalNotificationToDatabase(
    String title,
    String body,
    String? type,
    Map<String, dynamic>? data,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return;
      }

      // users tablosundan gerçek user_id al
      final userRecord = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) {
        print('❌ User not found in users table for auth_id: ${user.id}');
        return;
      }

      final notificationData = {
        'user_id': userRecord['id'],
        'type': type ?? 'system_announcement',
        'title': title,
        'body': body,
        'data': data,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('notifications').insert(notificationData);
      await _cleanupExcessNotifications();
    } catch (e) {
      print('❌ Failed to save notification: $e');
    }
  }

  /// Fazla bildirimleri temizle (maksimum 20 bildirim)
  static Future<void> _cleanupExcessNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // users tablosundan gerçek user_id al
      final userRecord = await _supabase
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return;

      final countResponse = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userRecord['id']);

      final totalCount = countResponse.length;

      if (totalCount > 20) {
        final excessCount = totalCount - 20;

        final oldNotifications = await _supabase
            .from('notifications')
            .select('id')
            .eq('user_id', userRecord['id'])
            .order('created_at', ascending: true)
            .limit(excessCount);

        if (oldNotifications.isNotEmpty) {
          final idsToDelete = oldNotifications.map((n) => n['id']).toList();

          for (final id in idsToDelete) {
            await _supabase
                .from('notifications')
                .delete()
                .eq('id', id)
                .eq('user_id', userRecord['id']);
          }
        }
      }
    } catch (e) {
      print('❌ Failed to cleanup excess notifications: $e');
    }
  }

  /// Schedule tournament notifications
  static Future<void> scheduleTournamentNotifications({
    required DateTime startTime,
    required DateTime endTime,
    required String tournamentName,
  }) async {
    try {
      // 1 saat öncesi başlama bildirimi
      final startReminderTime = startTime.subtract(Duration(hours: 1));
      if (startReminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 'tournament_start_${startTime.millisecondsSinceEpoch}',
          title: '🏆 Turnuva Başlıyor!',
          body: '$tournamentName turnuvası 1 saat sonra başlayacak!',
          scheduledTime: startReminderTime,
          type: NotificationTypes.tournamentMatchStartReminder,
        );
      }

      // 1 saat öncesi bitiş bildirimi
      final endReminderTime = endTime.subtract(Duration(hours: 1));
      if (endReminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 'tournament_end_${endTime.millisecondsSinceEpoch}',
          title: '🏆 Turnuva Bitiyor!',
          body: '$tournamentName turnuvası 1 saat sonra bitecek!',
          scheduledTime: endReminderTime,
          type: NotificationTypes.tournamentMatchEndReminder,
        );
      }
    } catch (e) {
      print('❌ Failed to schedule tournament notifications: $e');
    }
  }

  /// Schedule elimination notifications
  static Future<void> scheduleEliminationNotifications({
    required DateTime startTime,
    required DateTime endTime,
    required String eliminationName,
  }) async {
    try {
      // 1 saat öncesi başlama bildirimi
      final startReminderTime = startTime.subtract(Duration(hours: 1));
      if (startReminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 'elimination_start_${startTime.millisecondsSinceEpoch}',
          title: '⚔️ Eleme Turu Başlıyor!',
          body: '$eliminationName eleme turu 1 saat sonra başlayacak!',
          scheduledTime: startReminderTime,
          type: NotificationTypes.tournamentMatchStartReminder,
        );
      }

      // 1 saat öncesi bitiş bildirimi
      final endReminderTime = endTime.subtract(Duration(hours: 1));
      if (endReminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 'elimination_end_${endTime.millisecondsSinceEpoch}',
          title: '⚔️ Eleme Turu Bitiyor!',
          body: '$eliminationName eleme turu 1 saat sonra bitecek!',
          scheduledTime: endReminderTime,
          type: NotificationTypes.tournamentMatchEndReminder,
        );
      }
    } catch (e) {
      print('❌ Failed to schedule elimination notifications: $e');
    }
  }

  /// Schedule hot streak reminder
  static Future<void> scheduleHotStreakReminder({
    required int currentStreak,
    required DateTime lastLoginTime,
  }) async {
    try {
      // 12 saat sonra hatırlatma
      final reminderTime = lastLoginTime.add(Duration(hours: 12));
      if (reminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 'hotstreak_reminder_${reminderTime.millisecondsSinceEpoch}',
          title: '🔥 Hot Streak Hatırlatması!',
          body: 'Bu gün girmeyi unutma! $currentStreak. gün hot streakini kaçırma!',
          scheduledTime: reminderTime,
          type: NotificationTypes.streakDailyReminder,
        );
      }
    } catch (e) {
      print('❌ Failed to schedule hot streak reminder: $e');
    }
  }

  /// Send photo milestone notification
  static Future<void> sendPhotoMilestoneNotification({
    required int photoId,
    required int winCount,
    required String photoName,
  }) async {
    try {
      await sendLocalNotification(
        title: '🎉 Foto Milestone!',
        body: '$photoName fotoğrafı $winCount. winini aldı!',
        type: NotificationTypes.photoMilestone,
        data: {
          'photo_id': photoId,
          'win_count': winCount,
          'photo_name': photoName,
        },
      );
    } catch (e) {
      print('❌ Failed to send photo milestone notification: $e');
    }
  }

  /// Send total milestone notification
  static Future<void> sendTotalMilestoneNotification({
    required int totalWins,
  }) async {
    try {
      await sendLocalNotification(
        title: '🏆 Toplam Milestone!',
        body: 'Tebrikler! Toplam $totalWins win aldınız!',
        type: NotificationTypes.totalMilestone,
        data: {
          'total_wins': totalWins,
        },
      );
    } catch (e) {
      print('❌ Failed to send total milestone notification: $e');
    }
  }

  /// Schedule notification
  static Future<void> _scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('⏰ Scheduling notification: $title for ${scheduledTime.toIso8601String()}');
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'chizo_notifications',
        'Chizo Notifications',
        channelDescription: 'Notifications for Chizo app',
        importance: Importance.high,
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

      final notificationId = int.parse(id.split('_').last);
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: data != null ? json.encode(data) : null,
      );

      print('✅ Notification scheduled successfully');

      // Save to database
      await _saveLocalNotificationToDatabase(title, body, type, data);
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    print('📱 Background message received: ${message.messageId}');
    
    // Handle background message
    if (message.notification != null) {
      print('📱 Background notification: ${message.notification!.title}');
    }
  } catch (e) {
    print('❌ Background message handler error: $e');
  }
}