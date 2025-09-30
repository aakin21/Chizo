import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Report reasons
  static const List<String> reportReasons = [
    'nudity',
    'inappropriate_content',
    'harassment',
    'spam',
    'other'
  ];

  // Report a match
  static Future<bool> reportMatch({
    required String matchId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      // Get current user ID from users table
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();
      
      if (currentUserRecord == null) return false;
      
      final reporterId = currentUserRecord['id'];

      // Check if already reported
      final existingReport = await _client
          .from('reports')
          .select('id')
          .eq('reporter_id', reporterId)
          .eq('match_id', matchId)
          .eq('reported_user_id', reportedUserId)
          .maybeSingle();

      if (existingReport != null) {
        return false; // Already reported
      }

      // Create report
      await _client.from('reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'match_id': matchId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error reporting match: $e');
      return false;
    }
  }

  // Report a user
  static Future<bool> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      // Get current user ID from users table
      final currentUserRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();
      
      if (currentUserRecord == null) return false;
      
      final reporterId = currentUserRecord['id'];

      // Check if already reported
      final existingReport = await _client
          .from('reports')
          .select('id')
          .eq('reporter_id', reporterId)
          .eq('reported_user_id', reportedUserId)
          .maybeSingle();

      if (existingReport != null) {
        return false; // Already reported
      }

      // Create report
      await _client.from('reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error reporting user: $e');
      return false;
    }
  }

  // Get report reasons with localized names
  static List<Map<String, String>> getReportReasons() {
    return [
      {'key': 'nudity', 'name': 'Nudity'},
      {'key': 'inappropriate_content', 'name': 'Inappropriate Content'},
      {'key': 'harassment', 'name': 'Harassment'},
      {'key': 'spam', 'name': 'Spam'},
      {'key': 'other', 'name': 'Other'},
    ];
  }
}
