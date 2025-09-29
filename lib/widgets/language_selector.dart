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
    final currentLanguage = languageOptions.firstWhere(
      (option) => _selectedLocale?.languageCode == option['code'],
      orElse: () => languageOptions.first,
    );

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.blue),
      title: Text(
        AppLocalizations.of(context)!.language,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        currentLanguage['name'],
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLanguage['flag'],
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onTap: () => _showLanguageDialog(context, languageOptions),
    );
  }

  void _showLanguageDialog(BuildContext context, List<Map<String, dynamic>> languageOptions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.language, color: Colors.blue),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.language),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageOptions.map((option) {
            final isSelected = _selectedLocale?.languageCode == option['code'];
            
            return ListTile(
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
                  : null,
              onTap: () {
                _changeLanguage(option['locale']);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              tileColor: isSelected 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
