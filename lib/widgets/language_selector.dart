import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';

class LanguageSelector extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  
  const LanguageSelector({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLocale = await LanguageService.getCurrentLocale();
    setState(() {
      _selectedLocale = currentLocale;
    });
  }

  Future<void> _changeLanguage(Locale locale) async {
    await LanguageService.setLanguage(locale);
    setState(() {
      _selectedLocale = locale;
    });
    widget.onLanguageChanged(locale);
  }

  @override
  Widget build(BuildContext context) {
    final languageOptions = LanguageService.getLanguageOptions();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).language,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Dil seçenekleri
          ...languageOptions.map((option) {
            final isSelected = _selectedLocale?.languageCode == option['code'];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  option['flag'],
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  option['name'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () => _changeLanguage(option['locale']),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                tileColor: isSelected ? Colors.blue[50] : Colors.white,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
