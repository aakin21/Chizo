class Gender {
  final String code;
  final String name;

  Gender({
    required this.code,
    required this.name,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Gender(code: $code, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gender && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

