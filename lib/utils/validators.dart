/// Input validation utilities for Chizo app
/// Provides validation for email, username, age, and other user inputs

class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) return false;

    // RFC 5322 compliant email regex (simplified)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    return emailRegex.hasMatch(email.trim());
  }

  // Username validation
  static bool isValidUsername(String username) {
    if (username.trim().isEmpty) return false;

    final trimmed = username.trim();

    // Length check: 3-20 characters
    if (trimmed.length < 3 || trimmed.length > 20) return false;

    // Only alphanumeric and underscore allowed
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(trimmed);
  }

  // Password validation
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;

    // Minimum 6 characters (Supabase default)
    if (password.length < 6) return false;

    return true;
  }

  // Strong password validation (optional - for premium accounts)
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    // At least one uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // At least one lowercase
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // At least one number
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    return true;
  }

  // Age validation
  static bool isValidAge(int? age) {
    if (age == null) return false;

    // Age range: 18-99
    return age >= 18 && age <= 99;
  }

  // Instagram handle validation
  static bool isValidInstagramHandle(String? handle) {
    if (handle == null || handle.trim().isEmpty) return true; // Optional field

    final trimmed = handle.trim();

    // Remove @ if present
    final cleaned = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;

    // Instagram username rules: 1-30 chars, alphanumeric, dots, underscores
    if (cleaned.length < 1 || cleaned.length > 30) return false;

    final instagramRegex = RegExp(r'^[a-zA-Z0-9._]+$');
    return instagramRegex.hasMatch(cleaned);
  }

  // Profession validation
  static bool isValidProfession(String? profession) {
    if (profession == null || profession.trim().isEmpty) return true; // Optional field

    final trimmed = profession.trim();

    // Length: 2-50 characters
    if (trimmed.length < 2 || trimmed.length > 50) return false;

    // Only letters, spaces, and basic punctuation
    final professionRegex = RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ\s\-\'\.]+$');
    return professionRegex.hasMatch(trimmed);
  }

  // Get user-friendly error messages
  static String? getEmailError(String email) {
    if (email.trim().isEmpty) return 'Email adresi boş olamaz';
    if (!isValidEmail(email)) return 'Geçerli bir email adresi girin';
    return null;
  }

  static String? getUsernameError(String username) {
    if (username.trim().isEmpty) return 'Kullanıcı adı boş olamaz';

    final trimmed = username.trim();
    if (trimmed.length < 3) return 'Kullanıcı adı en az 3 karakter olmalı';
    if (trimmed.length > 20) return 'Kullanıcı adı en fazla 20 karakter olabilir';

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Sadece harf, rakam ve alt çizgi kullanılabilir';
    }

    return null;
  }

  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Şifre boş olamaz';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  static String? getAgeError(int? age) {
    if (age == null) return 'Yaş seçilmeli';
    if (age < 18) return 'En az 18 yaşında olmalısınız';
    if (age > 99) return 'Geçerli bir yaş girin';
    return null;
  }

  static String? getInstagramHandleError(String? handle) {
    if (handle == null || handle.trim().isEmpty) return null; // Optional

    final trimmed = handle.trim();
    final cleaned = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;

    if (cleaned.isEmpty) return null;
    if (cleaned.length > 30) return 'Instagram kullanıcı adı çok uzun';

    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(cleaned)) {
      return 'Geçersiz Instagram kullanıcı adı';
    }

    return null;
  }

  static String? getProfessionError(String? profession) {
    if (profession == null || profession.trim().isEmpty) return null; // Optional

    final trimmed = profession.trim();
    if (trimmed.length < 2) return 'Meslek en az 2 karakter olmalı';
    if (trimmed.length > 50) return 'Meslek en fazla 50 karakter olabilir';

    if (!RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ\s\-\'\.]+$').hasMatch(trimmed)) {
      return 'Geçersiz karakter kullanıldı';
    }

    return null;
  }

  // Sanitize input (remove potentially dangerous characters)
  static String sanitize(String input) {
    // Remove leading/trailing whitespace
    String cleaned = input.trim();

    // Remove null bytes
    cleaned = cleaned.replaceAll('\x00', '');

    // Remove control characters (except newline and tab)
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    return cleaned;
  }

  // Clean Instagram handle (remove @ if present)
  static String cleanInstagramHandle(String handle) {
    final trimmed = handle.trim();
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }
}
