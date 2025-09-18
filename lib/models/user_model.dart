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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

