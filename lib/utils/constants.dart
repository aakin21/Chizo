class AppConstants {
  // App name and version info
  static const String appName = 'Chizo';
  static const String appVersion = '1.0.0';
  
  // Avrupa ülkeleri + Türkiye listesi (keys for localization)
  static const List<String> countries = [
    'turkey',
    'germany',
    'france',
    'italy',
    'spain',
    'netherlands',
    'belgium',
    'austria',
    'switzerland',
    'poland',
    'czech_republic',
    'hungary',
    'romania',
    'bulgaria',
    'croatia',
    'slovenia',
    'slovakia',
    'estonia',
    'latvia',
    'lithuania',
    'finland',
    'sweden',
    'norway',
    'denmark',
    'portugal',
    'greece',
    'cyprus',
    'malta',
    'luxembourg',
    'ireland',
    'united_kingdom',
    'iceland',
  ];

  static const List<String> genders = ['Erkek', 'Kadın'];
  
  static const List<String> ageRanges = ['18-24', '24-32', '32-40', '40+'];
  
  // UI Constants for consistent spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Color constants
  static const int primaryColorValue = 0xFF673AB7; // deepPurple
  static const int successColor = 0xFF4CAF50;
  static const int errorColor = 0xFFF44336;
  static const int warningColor = 0xFFFF9800;

  // ✅ SECURITY: Photo upload security constants
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB max file size
  static const int maxImageDimension = 2048; // 2048x2048 max dimensions
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png'];
}
