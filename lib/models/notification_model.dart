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
  static const String hotStreakReward = 'hotstreak_reward';
  static const String hotStreakReminder = 'hotstreak_reminder';
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
  static const String purchase = '💳';
  static const String spent = '💸';
  static const String referral = '🎁';
  static const String achievement = '🏅';
  static const String reminder = '⏰';
  static const String update = '🔄';
  static const String win = '🎉';
  static const String streak = '🔥';
  static const String daily = '📅';
  static const String photo = '📸';
  static const String milestone = '🎯';
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
    case 'coin_purchase':
      return NotificationIcons.purchase;
    case 'coin_spent':
      return NotificationIcons.spent;
    case 'referral_reward':
    case 'referral_invite':
      return NotificationIcons.referral;
    case 'achievement_unlocked':
      return NotificationIcons.achievement;
    case NotificationTypes.streakReminder:
    case NotificationTypes.streakDailyReminder:
    case NotificationTypes.streakRewardReminder:
      return NotificationIcons.streak;
    case NotificationTypes.hotStreakReward:
    case NotificationTypes.hotStreakReminder:
      return NotificationIcons.streak;
    case NotificationTypes.matchCreated:
      return NotificationIcons.match;
    case NotificationTypes.matchWon:
      return NotificationIcons.win;
    case NotificationTypes.photoMilestone:
      return NotificationIcons.photo;
    case NotificationTypes.totalMilestone:
      return NotificationIcons.milestone;
    case NotificationTypes.profileUpdate:
      return NotificationIcons.profile;
    case NotificationTypes.systemAnnouncement:
      return NotificationIcons.system;
    case 'reminder':
      return NotificationIcons.reminder;
    case 'daily_login':
      return NotificationIcons.daily;
    case 'photo_stats_view':
      return NotificationIcons.photo;
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
    case 'coin_purchase':
      return Colors.amber;
    case 'coin_spent':
      return Colors.red;
    case 'referral_reward':
    case 'referral_invite':
      return Colors.purple;
    case NotificationTypes.streakReminder:
    case NotificationTypes.streakDailyReminder:
    case NotificationTypes.streakRewardReminder:
      return Colors.orange;
    case NotificationTypes.hotStreakReward:
    case NotificationTypes.hotStreakReminder:
      return Colors.orange;
    case NotificationTypes.votingResult:
      return Colors.indigo;
    case NotificationTypes.systemAnnouncement:
      return Colors.grey;
    case 'reminder':
      return Colors.teal;
    case 'photo_stats_view':
      return Colors.pink;
    default:
      return Colors.grey;
  }
}
