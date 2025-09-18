class TournamentModel {
  final String id;
  final String name;
  final String description;
  final int entryFee;
  final int prizePool;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'upcoming', 'active', 'completed'
  final String? winnerId;
  final DateTime createdAt;

  TournamentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.entryFee,
    required this.prizePool,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.winnerId,
    required this.createdAt,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      entryFee: json['entry_fee'],
      prizePool: json['prize_pool'],
      maxParticipants: json['max_participants'],
      currentParticipants: json['current_participants'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      winnerId: json['winner_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'entry_fee': entryFee,
      'prize_pool': prizePool,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'winner_id': winnerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}



