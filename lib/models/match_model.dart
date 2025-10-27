import '../utils/safe_parsing.dart';

class MatchModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;

  MatchModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.winnerId,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: SafeParsing.getRequiredString(json, 'id'),
      user1Id: SafeParsing.getRequiredString(json, 'user1_id'),
      user2Id: SafeParsing.getRequiredString(json, 'user2_id'),
      winnerId: SafeParsing.getOptionalString(json, 'winner_id'),
      createdAt: SafeParsing.parseDateTimeRequired(json['created_at']),
      completedAt: SafeParsing.parseDateTime(json['completed_at']),
      isCompleted: SafeParsing.getBool(json, 'is_completed', defaultValue: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'winner_id': winnerId,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}

