import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class LogNotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Log bildirimi oluştur (kullanıcı bildirimleri kapatsa bile)
  static Future<void> createLogNotification({
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Log bildirimleri tamamen devre dışı
    return;
  }

  // Tüm log fonksiyonları devre dışı
  static Future<void> logAppStart() async { return; }
  static Future<void> logUserLogin(String username) async { return; }
  static Future<void> logUserLogout() async { return; }
  static Future<void> logMatchCreated(String matchId) async { return; }
  static Future<void> logMatchCompleted(String matchId, String winnerId) async { return; }
  static Future<void> logCoinTransaction(int amount, String type, String description) async { return; }
  static Future<void> logPrediction(String winnerId, bool isCorrect, int rewardCoins) async { return; }
  static Future<void> logError(String error, String context) async { return; }
  static Future<void> logSystemNotification(String title, String body) async { return; }

  // Log bildirimlerini getir
  static Future<List<NotificationModel>> getLogNotifications({int limit = 50}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .eq('is_log', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Failed to get log notifications: $e');
      return [];
    }
  }

  // Eski log bildirimlerini temizle (30 günden eski)
  static Future<void> cleanupOldLogs() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', user.id)
          .eq('is_log', true)
          .lt('created_at', thirtyDaysAgo.toIso8601String());

      print('✅ Old log notifications cleaned up');
    } catch (e) {
      print('❌ Failed to cleanup old logs: $e');
    }
  }
}
