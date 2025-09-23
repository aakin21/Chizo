class UserModel {
  final String id;
  final String username;
  final String email;
  final int coins;
  final String? profileImageUrl;
  final int? age;
  final String? country;
  final String? gender;
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

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.coins,
    this.profileImageUrl,
    this.age,
    this.country,
    this.gender,
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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      coins: json['coins'] ?? 0,
      profileImageUrl: json['profile_image_url'],
      age: json['age'],
      country: json['country'],
      gender: json['gender'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'coins': coins,
      'profile_image_url': profileImageUrl,
      'age': age,
      'country': country,
      'gender': gender,
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

