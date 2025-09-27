import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../services/country_service.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class CountrySelector extends StatefulWidget {
  final String? selectedCountryCode;
  final Function(String?) onCountrySelected;
  final String? label;
  final bool enabled;

  const CountrySelector({
    Key? key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.label,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _selectedCountryCode;
  String? _currentLanguage;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.selectedCountryCode;
    _loadCountries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değiştiğinde ülkeleri yeniden yükle
    final newLanguage = Localizations.localeOf(context).languageCode;
    if (_currentLanguage != newLanguage) {
      _currentLanguage = newLanguage;
      _loadCountries();
    }
  }

  Future<void> _loadCountries() async {
    try {
      // Context'ten mevcut dili al
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final countries = await CountryService.getCountriesByLanguage(currentLanguage);
      
      setState(() {
        _countries = countries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? AppLocalizations.of(context)!.country,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode != null && 
                           _countries.any((c) => c.code == _selectedCountryCode) 
                           ? _selectedCountryCode : null,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    hint: Text(
                      AppLocalizations.of(context)!.selectCountry,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    items: _countries.map((Country country) {
                      return DropdownMenuItem<String>(
                        value: country.code,
                        child: Text(
                          country.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: widget.enabled
                        ? (String? newValue) {
                            setState(() {
                              _selectedCountryCode = newValue;
                            });
                            widget.onCountrySelected(newValue);
                          }
                        : null,
                  ),
                ),
        ),
      ],
    );
  }

  /// Ülke listesini yenile (dil değiştiğinde)
  Future<void> refreshCountries() async {
    setState(() {
      _isLoading = true;
    });
    await _loadCountries();
  }
}
