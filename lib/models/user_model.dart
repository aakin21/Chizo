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
      id: json['id'],
      username: json['username'],
      email: json['email'],
      coins: json['coins'] ?? 0,
      age: json['age'],
      countryCode: json['country_code'] ?? json['country'], // Backward compatibility
      genderCode: json['gender_code'] ?? json['gender'], // Backward compatibility
      instagramHandle: json['instagram_handle'],
      profession: json['profession'],
      isVisible: json['is_visible'] ?? true,
      showInstagram: json['show_instagram'] ?? false,
      showProfession: json['show_profession'] ?? false,
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      totalStreakDays: json['total_streak_days'] ?? 0,
      lastLoginDate: json['last_login_date'] != null 
          ? DateTime.parse(json['last_login_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      matchPhotos: json['match_photos'] != null 
          ? List<Map<String, dynamic>>.from(json['match_photos'])
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
}

