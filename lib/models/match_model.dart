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
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      winnerId: json['winner_id'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      isCompleted: json['is_completed'] ?? false,
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

