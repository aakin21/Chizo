class TournamentParticipantModel {
  final String id;
  final String tournamentId;
  final String userId;
  final DateTime joinedAt;
  final bool isEliminated;
  final int score;

  TournamentParticipantModel({
    required this.id,
    required this.tournamentId,
    required this.userId,
    required this.joinedAt,
    this.isEliminated = false,
    this.score = 0,
  });

  factory TournamentParticipantModel.fromJson(Map<String, dynamic> json) {
    return TournamentParticipantModel(
      id: json['id'],
      tournamentId: json['tournament_id'],
      userId: json['user_id'],
      joinedAt: DateTime.parse(json['joined_at']),
      isEliminated: json['is_eliminated'] ?? false,
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
      'is_eliminated': isEliminated,
      'score': score,
    };
  }
}



