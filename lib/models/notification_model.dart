import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

// Notification Types
class NotificationTypes {
  static const String tournamentUpdate = 'tournament_update';
  static const String tournamentLeagueReminder = 'tournament_league_reminder';
  static const String tournamentMatchStartReminder = 'tournament_match_start_reminder';
  static const String tournamentMatchEndReminder = 'tournament_match_end_reminder';
  static const String votingResult = 'voting_result';
  static const String coinReward = 'coin_reward';
  static const String streakReminder = 'streak_reminder';
  static const String streakDailyReminder = 'streak_daily_reminder';
  static const String streakRewardReminder = 'streak_reward_reminder';
  static const String matchCreated = 'match_created';
  static const String matchWon = 'match_won';
  static const String photoMilestone = 'photo_milestone';
  static const String totalMilestone = 'total_milestone';
  static const String profileUpdate = 'profile_update';
  static const String systemAnnouncement = 'system_announcement';
}

// Notification Icons
class NotificationIcons {
  static const String tournament = '🏆';
  static const String vote = '🗳️';
  static const String coin = '💰';
  static const String fire = '🔥';
  static const String match = '⚔️';
  static const String profile = '👤';
  static const String system = '📢';
}

// Get icon for notification type
String getNotificationIcon(String type) {
  switch (type) {
    case NotificationTypes.tournamentUpdate:
    case NotificationTypes.tournamentLeagueReminder:
    case NotificationTypes.tournamentMatchStartReminder:
    case NotificationTypes.tournamentMatchEndReminder:
      return NotificationIcons.tournament;
    case NotificationTypes.votingResult:
      return NotificationIcons.vote;
    case NotificationTypes.coinReward:
      return NotificationIcons.coin;
    case NotificationTypes.streakReminder:
    case NotificationTypes.streakDailyReminder:
    case NotificationTypes.streakRewardReminder:
      return NotificationIcons.fire;
    case NotificationTypes.matchCreated:
      return NotificationIcons.match;
    case NotificationTypes.matchWon:
    case NotificationTypes.photoMilestone:
    case NotificationTypes.totalMilestone:
      return '🎉';
    case NotificationTypes.profileUpdate:
      return NotificationIcons.profile;
    case NotificationTypes.systemAnnouncement:
      return NotificationIcons.system;
    default:
      return '🔔';
  }
}

// Get color for notification type
Color getNotificationColor(String type) {
  switch (type) {
    case NotificationTypes.matchWon:
    case NotificationTypes.photoMilestone:
    case NotificationTypes.totalMilestone:
      return Colors.green;
    case NotificationTypes.tournamentUpdate:
    case NotificationTypes.tournamentLeagueReminder:
    case NotificationTypes.tournamentMatchStartReminder:
    case NotificationTypes.tournamentMatchEndReminder:
      return Colors.blue;
    case NotificationTypes.coinReward:
      return Colors.amber;
    case NotificationTypes.streakReminder:
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
