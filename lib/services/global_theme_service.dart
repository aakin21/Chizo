import 'package:shared_preferences/shared_preferences.dart';

class GlobalThemeService {
  static final GlobalThemeService _instance = GlobalThemeService._internal();
  factory GlobalThemeService() => _instance;
  GlobalThemeService._internal();

  // Global theme değiştirme callback'i
  Function(String)? _onThemeChanged;

  // Callback'i kaydet
  void setThemeChangeCallback(Function(String) callback) {
    _onThemeChanged = callback;
  }

  // Theme değiştir
  Future<void> changeTheme(String theme) async {
    // Önce theme ayarını kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
    
    // Kısa bir gecikme - theme ayarının kaydedilmesi için
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Sonra global callback'i çağır
    if (_onThemeChanged != null) {
      _onThemeChanged!(theme);
    }
  }

  // Mevcut theme'i al
  Future<String> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_theme') ?? 'Beyaz';
  }

  // Desteklenen theme'ler
  static List<String> getSupportedThemes() {
    return ['Beyaz', 'Koyu', 'Pembemsi'];
  }
}
