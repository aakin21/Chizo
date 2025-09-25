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
  final String status; // 'registration', 'active', 'completed'
  final String? winnerId;
  final String? secondPlaceId; // İkinci sıra
  final String? thirdPlaceId; // Üçüncü sıra
  final DateTime createdAt;
  final String gender; // 'Erkek' or 'Kadın'
  final String currentPhase; // 'registration', 'qualifying', 'quarter_final', 'semi_final', 'final', 'completed'
  final int? currentRound; // Hangi turda olduğu (1, 2, 3, 4)
  final DateTime? phaseStartDate; // Mevcut fazın başlangıç tarihi
  final DateTime? registrationStartDate; // Kayıt başlangıç tarihi

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
    this.secondPlaceId,
    this.thirdPlaceId,
    required this.createdAt,
    required this.gender,
    required this.currentPhase,
    this.currentRound,
    this.phaseStartDate,
    this.registrationStartDate,
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
      secondPlaceId: json['second_place_id'],
      thirdPlaceId: json['third_place_id'],
      createdAt: DateTime.parse(json['created_at']),
      gender: json['gender'],
      currentPhase: json['current_phase'],
      currentRound: json['current_round'],
      phaseStartDate: json['phase_start_date'] != null ? DateTime.parse(json['phase_start_date']) : null,
      registrationStartDate: json['registration_start_date'] != null ? DateTime.parse(json['registration_start_date']) : null,
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
      'second_place_id': secondPlaceId,
      'third_place_id': thirdPlaceId,
      'created_at': createdAt.toIso8601String(),
      'gender': gender,
      'current_phase': currentPhase,
      'current_round': currentRound,
      'phase_start_date': phaseStartDate?.toIso8601String(),
      'registration_start_date': registrationStartDate?.toIso8601String(),
    };
  }
}



