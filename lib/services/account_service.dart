import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AccountService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Store delete reason feedback (best-effort)
  static Future<void> _storeDeleteFeedback({
    required String userId,
    required String email,
    required String reason,
    String? details,
  }) async {
    try {
      await _client.from('account_delete_feedback').insert({
        'user_id': userId,
        'email': email,
        'reason': reason,
        'details': details,
      });
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed to store delete feedback (table may not exist): $e');
    }
  }

  /// Remove user images from storage based on user_photos table
  static Future<void> _deleteUserStorageFiles(String userId) async {
    try {
      final photos = await _client
          .from('user_photos')
          .select('photo_url')
          .eq('user_id', userId);
      final List<String> toRemove = [];
      for (final p in photos) {
        final url = (p['photo_url'] ?? '') as String;
        if (url.isEmpty) continue;
        // Expecting public URL like .../profile-images/object-path
        final parts = url.split('/profile-images/');
        if (parts.length == 2) {
          final objectPath = parts[1];
          toRemove.add(objectPath);
        }
      }
      if (toRemove.isNotEmpty) {
        await _client.storage.from('profile-images').remove(toRemove);
      }
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed to delete user storage files: $e');
    }
  }

  /// Delete rows from a table with a where condition, ignore failures
  static Future<void> _deleteWhere(String table, String column, String value) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed to delete from $table where $column=$value: $e');
    }
  }

  /// Attempt to fully delete user's app data.
  /// NOTE: Deleting the auth user itself requires server-side service role.
  static Future<void> deleteAccountCompletely({
    required String reason,
    String? details,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return;
    final authId = authUser.id;
    final email = authUser.email ?? '';

    // 1) Feedback (best-effort)
    await _storeDeleteFeedback(userId: authId, email: email, reason: reason, details: details);

    // 2) Storage cleanup (best-effort)
    try {
      // Find internal user row id
      final userRow = await _client
          .from('users')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      final String? userRowId = userRow != null ? (userRow['id'] as String?) : null;

      if (userRowId != null) {
        await _deleteUserStorageFiles(userRowId);
      }
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed during storage cleanup phase: $e');
    }

    // 3) Relational data deletions (best-effort)
    // Add here any table that references the user
    final tablesUserId = <String>[
      'user_tokens',
      'notifications',
      'tournament_participants',
      'tournament_votes',
      'votes',
      'matches',
      'photo_stats',
      'user_photos',
      'coin_transactions',
      'reports',
      'user_country_stats',
    ];
    try {
      // Resolve internal user row id once
      final userRow = await _client
          .from('users')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();
      final String? userRowId = userRow != null ? (userRow['id'] as String?) : null;

      if (userRowId != null) {
        for (final t in tablesUserId) {
          await _deleteWhere(t, 'user_id', userRowId);
        }

        // Some tables might use other foreign keys
        await _deleteWhere('notifications', 'recipient_id', userRowId);
        await _deleteWhere('tournament_participants', 'participant_id', userRowId);

        // 4) Core user row last
        await _deleteWhere('users', 'id', userRowId);
      }
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed during relational data deletion phase: $e');
    }

    // 5) Ask Edge Function to remove auth user (requires setup)
    try {
      await _client.functions.invoke('delete-user', body: {
        'userId': authId,
      });
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed to invoke delete-user function (may not be configured): $e');
    }

    // 6) Finally sign out (caller will handle navigation)
    try {
      await _client.auth.signOut();
    } catch (e) {
      // ✅ FIX: Log error instead of silent failure
      debugPrint('Warning: Failed to sign out: $e');
    }
  }
}


