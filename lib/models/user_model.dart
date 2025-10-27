import '../utils/safe_parsing.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final int coins;
  final int? age;
  final String? countryCode;
  final String? genderCode;
  final String? instagramHandle;
  final String? profession;
  final bool isVisible;
  final bool showInstagram;
  final bool showProfession;
  final int totalMatches;
  final int wins;
  final int currentStreak;
  final int totalStreakDays;
  final DateTime? lastLoginDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>>? matchPhotos; // Çoklu fotoğraflar
  final List<String>? countryPreferences; // Hangi ülkelerden oylanmak istediği
  final List<String>? ageRangePreferences; // Hangi yaş aralıklarından oylanmak istediği

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.coins,
    this.age,
    this.countryCode,
    this.genderCode,
    this.instagramHandle,
    this.profession,
    this.isVisible = true,
    this.showInstagram = false,
    this.showProfession = false,
    this.totalMatches = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.totalStreakDays = 0,
    this.lastLoginDate,
    required this.createdAt,
    required this.updatedAt,
    this.matchPhotos,
    this.countryPreferences,
    this.ageRangePreferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: SafeParsing.getRequiredString(json, 'id'),
      username: SafeParsing.getRequiredString(json, 'username'),
      email: SafeParsing.getRequiredString(json, 'email'),
      coins: SafeParsing.getInt(json, 'coins', defaultValue: 0),
      age: json['age'] as int?,
      countryCode: SafeParsing.getOptionalString(json, 'country_code') ?? SafeParsing.getOptionalString(json, 'country'),
      genderCode: SafeParsing.getOptionalString(json, 'gender_code') ?? SafeParsing.getOptionalString(json, 'gender'),
      instagramHandle: SafeParsing.getOptionalString(json, 'instagram_handle'),
      profession: SafeParsing.getOptionalString(json, 'profession'),
      isVisible: SafeParsing.getBool(json, 'is_visible', defaultValue: true),
      showInstagram: SafeParsing.getBool(json, 'show_instagram', defaultValue: false),
      showProfession: SafeParsing.getBool(json, 'show_profession', defaultValue: false),
      totalMatches: SafeParsing.getInt(json, 'total_matches', defaultValue: 0),
      wins: SafeParsing.getInt(json, 'wins', defaultValue: 0),
      currentStreak: SafeParsing.getInt(json, 'current_streak', defaultValue: 0),
      totalStreakDays: SafeParsing.getInt(json, 'total_streak_days', defaultValue: 0),
      lastLoginDate: SafeParsing.parseDateTime(json['last_login_date']),
      createdAt: SafeParsing.parseDateTimeRequired(json['created_at']),
      updatedAt: SafeParsing.parseDateTimeRequired(json['updated_at']),
      matchPhotos: json['match_photos'] != null 
          ? List<Map<String, dynamic>>.from(json['match_photos'])
          : json['user_photos'] != null 
              ? List<Map<String, dynamic>>.from(json['user_photos'])
              : null,
      countryPreferences: json['country_preferences'] != null 
          ? List<String>.from(json['country_preferences'])
          : null,
      ageRangePreferences: json['age_range_preferences'] != null 
          ? List<String>.from(json['age_range_preferences'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'coins': coins,
      'age': age,
      'country_code': countryCode,
      'gender_code': genderCode,
      'instagram_handle': instagramHandle,
      'profession': profession,
      'is_visible': isVisible,
      'show_instagram': showInstagram,
      'show_profession': showProfession,
      'total_matches': totalMatches,
      'wins': wins,
      'current_streak': currentStreak,
      'total_streak_days': totalStreakDays,
      'last_login_date': lastLoginDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'match_photos': matchPhotos,
      'country_preferences': countryPreferences,
      'age_range_preferences': ageRangePreferences,
    };
  }

  // Kazanma oranını hesapla
  double get winRate {
    if (totalMatches == 0) return 0.0;
    return (wins / totalMatches) * 100;
  }

  // Kazanma oranını string olarak döndür
  String get winRateString {
    return '${winRate.toStringAsFixed(1)}%';
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    int? coins,
    int? age,
    String? countryCode,
    String? genderCode,
    String? instagramHandle,
    String? profession,
    bool? isVisible,
    bool? showInstagram,
    bool? showProfession,
    int? totalMatches,
    int? wins,
    int? currentStreak,
    int? totalStreakDays,
    DateTime? lastLoginDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? matchPhotos,
    List<String>? countryPreferences,
    List<String>? ageRangePreferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      age: age ?? this.age,
      countryCode: countryCode ?? this.countryCode,
      genderCode: genderCode ?? this.genderCode,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      profession: profession ?? this.profession,
      isVisible: isVisible ?? this.isVisible,
      showInstagram: showInstagram ?? this.showInstagram,
      showProfession: showProfession ?? this.showProfession,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      currentStreak: currentStreak ?? this.currentStreak,
      totalStreakDays: totalStreakDays ?? this.totalStreakDays,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      matchPhotos: matchPhotos ?? this.matchPhotos,
      countryPreferences: countryPreferences ?? this.countryPreferences,
      ageRangePreferences: ageRangePreferences ?? this.ageRangePreferences,
    );
  }
}

