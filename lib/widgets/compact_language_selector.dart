import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLocale = await LanguageService.getCurrentLocale();
    print('🔍 COMPACT LANGUAGE SELECTOR: Loaded locale = $currentLocale');
    setState(() {
      _selectedLocale = currentLocale;
    });
    print('🔍 COMPACT LANGUAGE SELECTOR: State updated, _selectedLocale = $_selectedLocale');
  }

  Future<void> _changeLanguage(Locale locale) async {
    print('🔄 COMPACT LANGUAGE SELECTOR: Changing language to $locale');
    await LanguageService.setLanguage(locale);
    print('💾 COMPACT LANGUAGE SELECTOR: Language saved to SharedPreferences');
    setState(() {
      _selectedLocale = locale;
    });
    print('🔄 COMPACT LANGUAGE SELECTOR: State updated, calling parent callback');
    // Parent widget'a dil değişikliğini bildir
    widget.onLanguageChanged(locale);
  }

  @override
  Widget build(BuildContext context) {
    final languageOptions = LanguageService.getLanguageOptions();

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: AppLocalizations.of(context)!.language,
      onSelected: (locale) => _changeLanguage(locale),
      itemBuilder: (context) => languageOptions.map((option) {
        final isSelected = _selectedLocale?.languageCode == option['code'];
        
        return PopupMenuItem<Locale>(
          value: option['locale'],
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
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.blue, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
