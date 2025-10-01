import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationHistoryService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Son 50 bildirimi getir
  static Future<List<NotificationModel>> getNotificationHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Failed to get notification history: $e');
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

      await _client
          .from('notifications')
          .delete()
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      print('❌ Failed to delete all notifications: $e');
      return false;
    }
  }

  // Okunmamış bildirim sayısını getir
  static Future<int> getUnreadCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final response = await _client
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

      await _client
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

  // Seçili bildirimleri sil
  static Future<bool> deleteNotifications(List<String> notificationIds) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('notifications')
          .delete()
          .eq('user_id', user.id)
          .inFilter('id', notificationIds);

      return true;
    } catch (e) {
      print('❌ Failed to delete selected notifications: $e');
      return false;
    }
  }
}
