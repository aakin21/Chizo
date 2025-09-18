class VoteModel {
  final String id;
  final String matchId;
  final String voterId;
  final String winnerId;
  final bool isCorrect;
  final DateTime createdAt;

  VoteModel({
    required this.id,
    required this.matchId,
    required this.voterId,
    required this.winnerId,
    required this.isCorrect,
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'],
      matchId: json['match_id'],
      voterId: json['voter_id'],
      winnerId: json['winner_id'],
      isCorrect: json['is_correct'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'voter_id': voterId,
      'winner_id': winnerId,
      'is_correct': isCorrect,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

