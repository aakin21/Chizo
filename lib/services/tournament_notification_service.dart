import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class TournamentNotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Schedule tournament start/end notifications
  static Future<void> scheduleTournamentNotifications({
    required String tournamentId,
    required DateTime startTime,
    required DateTime endTime,
    required String tournamentName,
  }) async {
    try {
      await NotificationService.scheduleTournamentNotifications(
        startTime: startTime,
        endTime: endTime,
        tournamentName: tournamentName,
      );

      // Veritabanına kaydet
      await _client.from('scheduled_notifications').insert({
        'tournament_id': tournamentId,
        'type': 'tournament',
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'title': tournamentName,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Failed to schedule tournament notifications: $e');
    }
  }

  /// Schedule elimination round notifications
  static Future<void> scheduleEliminationNotifications({
    required String eliminationId,
    required DateTime startTime,
    required DateTime endTime,
    required String eliminationName,
  }) async {
    try {
      await NotificationService.scheduleEliminationNotifications(
        startTime: startTime,
        endTime: endTime,
        eliminationName: eliminationName,
      );

      // Veritabanına kaydet
      await _client.from('scheduled_notifications').insert({
        'elimination_id': eliminationId,
        'type': 'elimination',
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'title': eliminationName,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Failed to schedule elimination notifications: $e');
    }
  }

  /// Send tournament update notification
  static Future<void> sendTournamentUpdateNotification({
    required String tournamentName,
    required String message,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: '🏆 Turnuva Güncellemesi',
        body: '$tournamentName: $message',
        type: NotificationTypes.tournamentUpdate,
        data: {
          'tournament_name': tournamentName,
          'message': message,
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to send tournament update notification: $e');
    }
  }

  /// Send voting result notification
  static Future<void> sendVotingResultNotification({
    required String matchId,
    required String winnerName,
    required String loserName,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: '🗳️ Oylama Sonucu',
        body: '$winnerName vs $loserName - $winnerName kazandı!',
        type: NotificationTypes.votingResult,
        data: {
          'match_id': matchId,
          'winner_name': winnerName,
          'loser_name': loserName,
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to send voting result notification: $e');
    }
  }

  /// Clean up old scheduled notifications
  static Future<void> cleanupOldNotifications() async {
    try {
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      
      await _client
          .from('scheduled_notifications')
          .delete()
          .lt('created_at', oneWeekAgo.toIso8601String());
    } catch (e) {
      debugPrint('❌ Failed to cleanup old notifications: $e');
    }
  }
}

