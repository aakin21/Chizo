import '../l10n/app_localizations.dart';

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
  
  // Private tournament fields
  final bool isPrivate; // Private turnuva mı?
  final String? privateKey; // Private turnuva key'i
  final String? creatorId; // Turnuva oluşturan kullanıcı ID'si
  final String tournamentFormat; // 'league', 'elimination', 'hybrid'
  final String? customRules; // Özel kurallar
  final String language; // Turnuva dili
  final bool isSystemTournament; // Sistem turnuvası mı?
  final String? nameKey; // Localization key for name
  final String? descriptionKey; // Localization key for description
  bool isUserParticipating; // Kullanıcı bu turnuvaya katılmış mı?

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
    this.isPrivate = false,
    this.privateKey,
    this.creatorId,
    this.tournamentFormat = 'league',
    this.customRules,
    this.language = 'tr',
    this.isSystemTournament = false,
    this.nameKey,
    this.descriptionKey,
    this.isUserParticipating = false,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      entryFee: json['entry_fee'],
      prizePool: json['prize_pool'],
      maxParticipants: json['max_participants'] is int 
          ? json['max_participants'] 
          : int.tryParse(json['max_participants'].toString()) ?? 0,
      currentParticipants: json['current_participants'] is int 
          ? json['current_participants'] 
          : int.tryParse(json['current_participants'].toString()) ?? 0,
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
      isPrivate: json['is_private'] ?? false,
      privateKey: json['private_key'],
      creatorId: json['creator_id'],
      tournamentFormat: json['tournament_format'] ?? 'league',
      customRules: json['custom_rules'],
      language: json['language'] ?? 'tr',
      isSystemTournament: json['is_system_tournament'] ?? false,
      nameKey: json['name_key'],
      descriptionKey: json['description_key'],
      isUserParticipating: false, // Default olarak false, sonra güncellenecek
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
      'is_private': isPrivate,
      'private_key': privateKey,
      'creator_id': creatorId,
      'tournament_format': tournamentFormat,
      'custom_rules': customRules,
      'language': language,
      'is_system_tournament': isSystemTournament,
      'name_key': nameKey,
      'description_key': descriptionKey,
    };
  }

  // Localized name getter - uses nameKey if available, otherwise falls back to name
  String getLocalizedName(AppLocalizations localizations) {
    if (nameKey != null) {
      switch (nameKey) {
        case 'instantMaleTournament5000':
          return localizations.instantMaleTournament5000;
        case 'instantFemaleTournament5000':
          return localizations.instantFemaleTournament5000;
        case 'weeklyMaleTournament5000':
          return localizations.weeklyMaleTournament5000;
        case 'weeklyFemaleTournament5000':
          return localizations.weeklyFemaleTournament5000;
        default:
          return name; // Fallback to static name
      }
    }
    return name; // Fallback to static name
  }
}



