import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/global_theme_service.dart';

class CompactLanguageSelector extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  
  const CompactLanguageSelector({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<CompactLanguageSelector> createState() => _CompactLanguageSelectorState();
}

class _CompactLanguageSelectorState extends State<CompactLanguageSelector> {
  Locale? _selectedLocale;
  String _currentTheme = 'Beyaz'; // Varsayılan değer

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    
    // Global theme service'e callback kaydet
    GlobalThemeService().setThemeChangeCallback((theme) {
      final safeTheme = theme.isNotEmpty ? theme : 'Beyaz';
      print('🔄 CompactLanguageSelector - Theme changed to: $safeTheme');
      if (mounted) {
        setState(() {
          _currentTheme = safeTheme;
        });
      }
    });
  }

  Future<void> _loadCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('selected_theme');
      final safeTheme = (theme != null && theme.isNotEmpty) ? theme : 'Beyaz';
      print('🔍 CompactLanguageSelector - Loaded theme from prefs: $safeTheme');
      if (mounted) {
        setState(() {
          _currentTheme = safeTheme;
        });
      }
    } catch (e) {
      print('❌ CompactLanguageSelector - Error loading theme: $e');
      if (mounted) {
        setState(() {
          _currentTheme = 'Beyaz';
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tema yükleme işlemini async olarak yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTheme();
    });
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLocale = await LanguageService.getCurrentLocale();
    setState(() {
      _selectedLocale = currentLocale;
    });
  }

  Future<void> _changeLanguage(Locale locale) async {
    // Parent'a bildir - main.dart'ta kaydetme ve restart yapılacak
    widget.onLanguageChanged(locale);
    
    // UI'ı güncelle
    if (mounted) {
      setState(() {
        _selectedLocale = locale;
      });
    }
    
    // Dil değişikliğinden sonra mevcut dili tekrar yükle
    await _loadCurrentLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final languageOptions = LanguageService.getLanguageOptions();
    // Tema değerini güvenli hale getir
    final safeTheme = _currentTheme.isNotEmpty ? _currentTheme : 'Beyaz';
    final isDarkTheme = safeTheme == 'Koyu';
    
    // Alternatif: Theme.of(context) ile tema kontrolü
    final brightness = Theme.of(context).brightness;
    final isSystemDark = brightness == Brightness.dark;
    
    // Debug için tema durumunu yazdır
    print('🌙 CompactLanguageSelector - Current Theme: $safeTheme, Is Dark: $isDarkTheme, System Dark: $isSystemDark');

    // Tema kontrolü: hem kendi değerimiz hem de sistem teması
    final shouldUseDarkTheme = isDarkTheme || isSystemDark;
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: AppLocalizations.of(context)!.language,
      color: shouldUseDarkTheme ? const Color(0xFF1E1E1E) : null, // Koyu tema arka plan
      surfaceTintColor: shouldUseDarkTheme ? const Color(0xFF1E1E1E) : null, // Koyu tema yüzey rengi
      onSelected: (locale) => _changeLanguage(locale),
      itemBuilder: (context) => languageOptions.map((option) {
        final isSelected = _selectedLocale?.languageCode == option['code'];
        
        return PopupMenuItem<Locale>(
          value: option['locale'],
          textStyle: TextStyle(
            color: shouldUseDarkTheme ? Colors.white : null,
          ),
          child: Container(
            decoration: shouldUseDarkTheme 
                ? BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFFF6B35).withOpacity(0.1)
                        : const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  )
                : BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFFF6B35).withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
            child: Row(
              children: [
                Text(
                  option['flag'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  option['name'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? const Color(0xFFFF6B35) // Turuncu seçili renk
                        : shouldUseDarkTheme 
                            ? Colors.white // Koyu temada beyaz yazı
                            : Colors.black87, // Açık temada siyah yazı
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check, 
                    color: const Color(0xFFFF6B35), // Turuncu check icon
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
