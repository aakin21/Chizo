import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationHistoryService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Son 20 bildirimi getir (maksimum limit)
  static Future<List<NotificationModel>> getNotificationHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    print('🔍 DEBUG: getNotificationHistory called!');
    try {
      final user = _client.auth.currentUser;
      print('🔍 DEBUG: Current user: ${user?.id}');

      if (user == null) {
        print('❌ DEBUG: No user logged in!');
        return [];
      }

      // users tablosundan gerçek user_id al
      print('🔍 DEBUG: Querying users table for auth_id: ${user.id}');
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      print('🔍 DEBUG: User record: $userRecord');

      if (userRecord == null) {
        print('❌ User not found in users table for auth_id: ${user.id}');
        return [];
      }

      final userId = userRecord['id'];
      print('🔍 DEBUG: Real user_id: $userId');

      // Maksimum 20 bildirim limiti
      final actualLimit = limit > 20 ? 20 : limit;

      // Gerçek user_id ile bildirimleri getir
      print('🔍 DEBUG: Querying notifications for user_id: $userId');
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + actualLimit - 1);

      print('✅ Loaded ${(response as List).length} notifications');
      print('🔍 DEBUG: First notification raw: ${(response as List).isNotEmpty ? response[0] : "none"}');

      final notifications = <NotificationModel>[];
      for (var json in (response as List)) {
        try {
          final notification = NotificationModel.fromJson(json);
          notifications.add(notification);
          print('✅ Parsed notification: ${notification.title}');
        } catch (e) {
          print('❌ Failed to parse notification: $e');
          print('❌ JSON: $json');
        }
      }

      print('✅ Total parsed: ${notifications.length}');
      return notifications;
    } catch (e, stackTrace) {
      print('❌ Failed to get notification history: $e');
      print('❌ Stack trace: $stackTrace');
      return [];
    }
  }

  // Bildirimi sil
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      print('❌ Failed to delete notification: $e');
      return false;
    }
  }

  // Tüm bildirimleri sil
  static Future<bool> deleteAllNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return false;

      await _client
          .from('notifications')
          .delete()
          .eq('user_id', userRecord['id']);

      return true;
    } catch (e) {
      print('❌ Failed to delete all notifications: $e');
      return false;
    }
  }

  // Uygulama başlatıldığında bildirimleri temizle
  static Future<void> initializeNotificationCleanup() async {
    try {
      await cleanupExcessNotifications();
      print('✅ Notification cleanup initialized');
    } catch (e) {
      print('❌ Failed to initialize notification cleanup: $e');
    }
  }

  // 20'den fazla bildirim varsa eski olanları sil
  static Future<void> cleanupExcessNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return;

      // Toplam bildirim sayısını kontrol et
      final countResponse = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userRecord['id']);

      final totalCount = countResponse.length;

      if (totalCount > 20) {
        // 20'den fazla bildirim varsa, en eski olanları sil
        final excessCount = totalCount - 20;

        // En eski bildirimleri bul
        final oldNotifications = await _client
            .from('notifications')
            .select('id')
            .eq('user_id', userRecord['id'])
            .order('created_at', ascending: true) // En eski önce
            .limit(excessCount);

        if (oldNotifications.isNotEmpty) {
          // Eski bildirimlerin ID'lerini al
          final idsToDelete = oldNotifications.map((n) => n['id']).toList();

          // Eski bildirimleri sil
          for (final id in idsToDelete) {
            await _client
                .from('notifications')
                .delete()
                .eq('id', id)
                .eq('user_id', userRecord['id']);
          }

          print('✅ Cleaned up $excessCount excess notifications');
        }
      }
    } catch (e) {
      print('❌ Failed to cleanup excess notifications: $e');
    }
  }

  // Okunmamış bildirim sayısını getir
  static Future<int> getUnreadCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return 0;

      final response = await _client
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

  // Bildirimi okundu olarak işaretle
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _client
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

  // Tüm bildirimleri okundu olarak işaretle
  static Future<bool> markAllAsRead() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return false;

      await _client
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

  // Seçili bildirimleri sil
  static Future<bool> deleteNotifications(List<String> notificationIds) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userRecord == null) return false;

      await _client
          .from('notifications')
          .delete()
          .eq('user_id', userRecord['id'])
          .inFilter('id', notificationIds);

      return true;
    } catch (e) {
      print('❌ Failed to delete selected notifications: $e');
      return false;
    }
  }
}
