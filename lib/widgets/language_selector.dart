import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

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
              Icon(
                Icons.language, 
                color: Theme.of(context).colorScheme.primary
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.language,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                    : Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.outline),
                onTap: () => _changeLanguage(option['locale']),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                tileColor: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
