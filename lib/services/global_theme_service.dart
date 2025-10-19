import 'package:shared_preferences/shared_preferences.dart';

class GlobalThemeService {
  static final GlobalThemeService _instance = GlobalThemeService._internal();
  factory GlobalThemeService() => _instance;
  GlobalThemeService._internal();

  // Birden fazla callback'i desteklemek için liste
  final List<Function(String)> _themeChangeCallbacks = [];

  // Callback'i kaydet
  void setThemeChangeCallback(Function(String) callback) {
    // Aynı callback'i tekrar eklemeyi engelle
    if (!_themeChangeCallbacks.contains(callback)) {
      _themeChangeCallbacks.add(callback);
    }
  }

  // Callback'i kaldır
  void removeThemeChangeCallback(Function(String) callback) {
    _themeChangeCallbacks.remove(callback);
  }

  // Tüm callback'leri temizle
  void clearAllCallbacks() {
    _themeChangeCallbacks.clear();
  }

  // Theme değiştir
  Future<void> changeTheme(String theme) async {
    // Önce theme ayarını kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);

    // Kısa bir gecikme - theme ayarının kaydedilmesi için
    await Future.delayed(const Duration(milliseconds: 100));

    // Tüm callback'leri çağır
    for (int i = 0; i < _themeChangeCallbacks.length; i++) {
      try {
        _themeChangeCallbacks[i](theme);
      } catch (e) {
        // Hata sessizce yutulur
      }
    }
  }

  // Mevcut theme'i al
  Future<String> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_theme') ?? 'Koyu';
  }

  // Desteklenen theme'ler
  static List<String> getSupportedThemes() {
    return ['Beyaz', 'Koyu'];
  }
}
