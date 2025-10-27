/// Safe parsing utilities to prevent runtime crashes
class SafeParsing {
  /// Safely parse DateTime from string
  /// Returns null if parsing fails instead of throwing FormatException
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Safely parse DateTime with a required fallback
  /// Returns fallback (default: current time) if parsing fails
  static DateTime parseDateTimeRequired(dynamic value, {DateTime? fallback}) {
    final parsed = parseDateTime(value);
    return parsed ?? fallback ?? DateTime.now();
  }

  /// Safely get required string field from JSON
  /// Throws descriptive exception if field is null or empty
  static String getRequiredString(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value == null) {
      throw Exception('Missing required field: $key');
    }

    if (value is! String) {
      throw Exception('Field $key must be a string, got ${value.runtimeType}');
    }

    if (value.trim().isEmpty) {
      throw Exception('Field $key cannot be empty');
    }

    return value;
  }

  /// Safely get optional string field from JSON
  static String? getOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : null;
  }

  /// Safely get int field with default value
  static int getInt(Map<String, dynamic> json, String key, {int defaultValue = 0}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get bool field with default value
  static bool getBool(Map<String, dynamic> json, String key, {bool defaultValue = false}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    return defaultValue;
  }
}
