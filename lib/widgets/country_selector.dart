import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CountrySelector extends StatefulWidget {
  final String? selectedCountryCode;
  final Function(String?) onCountrySelected;
  final String? label;
  final bool enabled;

  const CountrySelector({
    super.key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.label,
    this.enabled = true,
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.selectedCountryCode;
  }

  @override
  void didUpdateWidget(CountrySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCountryCode != oldWidget.selectedCountryCode) {
      _selectedCountryCode = widget.selectedCountryCode;
    }
  }

  List<Map<String, String>> _getCountries() {
    final language = Localizations.localeOf(context).languageCode;
    
    if (language == 'tr') {
      return [
        {'code': 'TR', 'name': 'Türkiye'},
        {'code': 'US', 'name': 'Amerika Birleşik Devletleri'},
        {'code': 'DE', 'name': 'Almanya'},
        {'code': 'FR', 'name': 'Fransa'},
        {'code': 'GB', 'name': 'Birleşik Krallık'},
        {'code': 'IT', 'name': 'İtalya'},
        {'code': 'ES', 'name': 'İspanya'},
        {'code': 'NL', 'name': 'Hollanda'},
        {'code': 'BE', 'name': 'Belçika'},
        {'code': 'CH', 'name': 'İsviçre'},
        {'code': 'AT', 'name': 'Avusturya'},
        {'code': 'SE', 'name': 'İsveç'},
        {'code': 'NO', 'name': 'Norveç'},
        {'code': 'DK', 'name': 'Danimarka'},
        {'code': 'FI', 'name': 'Finlandiya'},
        {'code': 'PL', 'name': 'Polonya'},
        {'code': 'CZ', 'name': 'Çek Cumhuriyeti'},
        {'code': 'HU', 'name': 'Macaristan'},
        {'code': 'RO', 'name': 'Romanya'},
        {'code': 'BG', 'name': 'Bulgaristan'},
        {'code': 'GR', 'name': 'Yunanistan'},
        {'code': 'CY', 'name': 'Kıbrıs'},
        {'code': 'RU', 'name': 'Rusya'},
        {'code': 'UA', 'name': 'Ukrayna'},
        {'code': 'CA', 'name': 'Kanada'},
        {'code': 'AU', 'name': 'Avustralya'},
        {'code': 'JP', 'name': 'Japonya'},
        {'code': 'KR', 'name': 'Güney Kore'},
        {'code': 'CN', 'name': 'Çin'},
        {'code': 'IN', 'name': 'Hindistan'},
        {'code': 'BR', 'name': 'Brezilya'},
        {'code': 'AR', 'name': 'Arjantin'},
        {'code': 'MX', 'name': 'Meksika'},
        {'code': 'SA', 'name': 'Suudi Arabistan'},
        {'code': 'AE', 'name': 'Birleşik Arap Emirlikleri'},
        {'code': 'EG', 'name': 'Mısır'},
        {'code': 'ZA', 'name': 'Güney Afrika'},
        {'code': 'NG', 'name': 'Nijerya'},
        {'code': 'KE', 'name': 'Kenya'},
        {'code': 'MA', 'name': 'Fas'},
        {'code': 'TN', 'name': 'Tunus'},
        {'code': 'DZ', 'name': 'Cezayir'},
        {'code': 'LY', 'name': 'Libya'},
        {'code': 'SD', 'name': 'Sudan'},
        {'code': 'ET', 'name': 'Etiyopya'},
        {'code': 'UG', 'name': 'Uganda'},
        {'code': 'TZ', 'name': 'Tanzanya'},
        {'code': 'GH', 'name': 'Gana'},
        {'code': 'CI', 'name': 'Fildişi Sahili'},
        {'code': 'SN', 'name': 'Senegal'},
        {'code': 'ML', 'name': 'Mali'},
        {'code': 'BF', 'name': 'Burkina Faso'},
        {'code': 'NE', 'name': 'Nijer'},
        {'code': 'TD', 'name': 'Çad'},
        {'code': 'CM', 'name': 'Kamerun'},
        {'code': 'CF', 'name': 'Orta Afrika Cumhuriyeti'},
        {'code': 'CG', 'name': 'Kongo'},
        {'code': 'CD', 'name': 'Demokratik Kongo Cumhuriyeti'},
        {'code': 'AO', 'name': 'Angola'},
        {'code': 'ZM', 'name': 'Zambiya'},
        {'code': 'ZW', 'name': 'Zimbabve'},
        {'code': 'BW', 'name': 'Botsvana'},
        {'code': 'NA', 'name': 'Namibya'},
        {'code': 'SZ', 'name': 'Eswatini'},
        {'code': 'LS', 'name': 'Lesotho'},
        {'code': 'MW', 'name': 'Malavi'},
        {'code': 'MZ', 'name': 'Mozambik'},
        {'code': 'MG', 'name': 'Madagaskar'},
        {'code': 'MU', 'name': 'Mauritius'},
        {'code': 'SC', 'name': 'Seyşeller'},
        {'code': 'KM', 'name': 'Komorlar'},
        {'code': 'DJ', 'name': 'Cibuti'},
        {'code': 'SO', 'name': 'Somali'},
        {'code': 'ER', 'name': 'Eritre'},
        {'code': 'SS', 'name': 'Güney Sudan'},
        {'code': 'RW', 'name': 'Ruanda'},
        {'code': 'BI', 'name': 'Burundi'},
        {'code': 'CV', 'name': 'Yeşil Burun Adaları'},
        {'code': 'GW', 'name': 'Gine-Bissau'},
        {'code': 'GN', 'name': 'Gine'},
        {'code': 'SL', 'name': 'Sierra Leone'},
        {'code': 'LR', 'name': 'Liberya'},
        {'code': 'TG', 'name': 'Togo'},
        {'code': 'BJ', 'name': 'Benin'},
        {'code': 'MR', 'name': 'Moritanya'},
      ];
    } else if (language == 'de') {
      return [
        {'code': 'TR', 'name': 'Türkei'},
        {'code': 'DE', 'name': 'Deutschland'},
        {'code': 'AT', 'name': 'Österreich'},
        {'code': 'CH', 'name': 'Schweiz'},
        {'code': 'US', 'name': 'Vereinigte Staaten'},
        {'code': 'FR', 'name': 'Frankreich'},
        {'code': 'GB', 'name': 'Vereinigtes Königreich'},
        {'code': 'IT', 'name': 'Italien'},
        {'code': 'ES', 'name': 'Spanien'},
        {'code': 'NL', 'name': 'Niederlande'},
        {'code': 'BE', 'name': 'Belgien'},
        {'code': 'SE', 'name': 'Schweden'},
        {'code': 'NO', 'name': 'Norwegen'},
        {'code': 'DK', 'name': 'Dänemark'},
        {'code': 'FI', 'name': 'Finnland'},
        {'code': 'PL', 'name': 'Polen'},
        {'code': 'CZ', 'name': 'Tschechien'},
        {'code': 'HU', 'name': 'Ungarn'},
        {'code': 'RO', 'name': 'Rumänien'},
        {'code': 'BG', 'name': 'Bulgarien'},
        {'code': 'GR', 'name': 'Griechenland'},
        {'code': 'CY', 'name': 'Zypern'},
        {'code': 'RU', 'name': 'Russland'},
        {'code': 'UA', 'name': 'Ukraine'},
        {'code': 'CA', 'name': 'Kanada'},
        {'code': 'AU', 'name': 'Australien'},
        {'code': 'JP', 'name': 'Japan'},
        {'code': 'KR', 'name': 'Südkorea'},
        {'code': 'CN', 'name': 'China'},
        {'code': 'IN', 'name': 'Indien'},
        {'code': 'BR', 'name': 'Brasilien'},
        {'code': 'AR', 'name': 'Argentinien'},
        {'code': 'MX', 'name': 'Mexiko'},
        {'code': 'SA', 'name': 'Saudi-Arabien'},
        {'code': 'AE', 'name': 'Vereinigte Arabische Emirate'},
        {'code': 'EG', 'name': 'Ägypten'},
        {'code': 'ZA', 'name': 'Südafrika'},
      ];
    } else if (language == 'es') {
      return [
        {'code': 'TR', 'name': 'Turquía'},
        {'code': 'ES', 'name': 'España'},
        {'code': 'MX', 'name': 'México'},
        {'code': 'AR', 'name': 'Argentina'},
        {'code': 'CO', 'name': 'Colombia'},
        {'code': 'PE', 'name': 'Perú'},
        {'code': 'VE', 'name': 'Venezuela'},
        {'code': 'CL', 'name': 'Chile'},
        {'code': 'EC', 'name': 'Ecuador'},
        {'code': 'GT', 'name': 'Guatemala'},
        {'code': 'CU', 'name': 'Cuba'},
        {'code': 'BO', 'name': 'Bolivia'},
        {'code': 'DO', 'name': 'República Dominicana'},
        {'code': 'HN', 'name': 'Honduras'},
        {'code': 'PY', 'name': 'Paraguay'},
        {'code': 'SV', 'name': 'El Salvador'},
        {'code': 'NI', 'name': 'Nicaragua'},
        {'code': 'CR', 'name': 'Costa Rica'},
        {'code': 'PA', 'name': 'Panamá'},
        {'code': 'UY', 'name': 'Uruguay'},
        {'code': 'PR', 'name': 'Puerto Rico'},
        {'code': 'US', 'name': 'Estados Unidos'},
        {'code': 'DE', 'name': 'Alemania'},
        {'code': 'FR', 'name': 'Francia'},
        {'code': 'IT', 'name': 'Italia'},
        {'code': 'GB', 'name': 'Reino Unido'},
        {'code': 'NL', 'name': 'Países Bajos'},
        {'code': 'BE', 'name': 'Bélgica'},
        {'code': 'CH', 'name': 'Suiza'},
        {'code': 'AT', 'name': 'Austria'},
        {'code': 'SE', 'name': 'Suecia'},
        {'code': 'NO', 'name': 'Noruega'},
        {'code': 'DK', 'name': 'Dinamarca'},
        {'code': 'FI', 'name': 'Finlandia'},
        {'code': 'PL', 'name': 'Polonia'},
        {'code': 'CZ', 'name': 'República Checa'},
        {'code': 'HU', 'name': 'Hungría'},
        {'code': 'RO', 'name': 'Rumania'},
        {'code': 'BG', 'name': 'Bulgaria'},
        {'code': 'GR', 'name': 'Grecia'},
        {'code': 'CY', 'name': 'Chipre'},
        {'code': 'RU', 'name': 'Rusia'},
        {'code': 'UA', 'name': 'Ucrania'},
        {'code': 'CA', 'name': 'Canadá'},
        {'code': 'AU', 'name': 'Australia'},
        {'code': 'JP', 'name': 'Japón'},
        {'code': 'KR', 'name': 'Corea del Sur'},
        {'code': 'CN', 'name': 'China'},
        {'code': 'IN', 'name': 'India'},
        {'code': 'BR', 'name': 'Brasil'},
        {'code': 'SA', 'name': 'Arabia Saudí'},
        {'code': 'AE', 'name': 'Emiratos Árabes Unidos'},
        {'code': 'EG', 'name': 'Egipto'},
        {'code': 'ZA', 'name': 'Sudáfrica'},
      ];
    } else {
      // English
      return [
        {'code': 'TR', 'name': 'Turkey'},
        {'code': 'US', 'name': 'United States'},
        {'code': 'DE', 'name': 'Germany'},
        {'code': 'FR', 'name': 'France'},
        {'code': 'GB', 'name': 'United Kingdom'},
        {'code': 'IT', 'name': 'Italy'},
        {'code': 'ES', 'name': 'Spain'},
        {'code': 'NL', 'name': 'Netherlands'},
        {'code': 'BE', 'name': 'Belgium'},
        {'code': 'CH', 'name': 'Switzerland'},
        {'code': 'AT', 'name': 'Austria'},
        {'code': 'SE', 'name': 'Sweden'},
        {'code': 'NO', 'name': 'Norway'},
        {'code': 'DK', 'name': 'Denmark'},
        {'code': 'FI', 'name': 'Finland'},
        {'code': 'PL', 'name': 'Poland'},
        {'code': 'CZ', 'name': 'Czech Republic'},
        {'code': 'HU', 'name': 'Hungary'},
        {'code': 'RO', 'name': 'Romania'},
        {'code': 'BG', 'name': 'Bulgaria'},
        {'code': 'GR', 'name': 'Greece'},
        {'code': 'CY', 'name': 'Cyprus'},
        {'code': 'RU', 'name': 'Russia'},
        {'code': 'UA', 'name': 'Ukraine'},
        {'code': 'CA', 'name': 'Canada'},
        {'code': 'AU', 'name': 'Australia'},
        {'code': 'JP', 'name': 'Japan'},
        {'code': 'KR', 'name': 'South Korea'},
        {'code': 'CN', 'name': 'China'},
        {'code': 'IN', 'name': 'India'},
        {'code': 'BR', 'name': 'Brazil'},
        {'code': 'AR', 'name': 'Argentina'},
        {'code': 'MX', 'name': 'Mexico'},
        {'code': 'SA', 'name': 'Saudi Arabia'},
        {'code': 'AE', 'name': 'United Arab Emirates'},
        {'code': 'EG', 'name': 'Egypt'},
        {'code': 'ZA', 'name': 'South Africa'},
        {'code': 'NG', 'name': 'Nigeria'},
        {'code': 'KE', 'name': 'Kenya'},
        {'code': 'MA', 'name': 'Morocco'},
        {'code': 'TN', 'name': 'Tunisia'},
        {'code': 'DZ', 'name': 'Algeria'},
        {'code': 'LY', 'name': 'Libya'},
        {'code': 'SD', 'name': 'Sudan'},
        {'code': 'ET', 'name': 'Ethiopia'},
        {'code': 'UG', 'name': 'Uganda'},
        {'code': 'TZ', 'name': 'Tanzania'},
        {'code': 'GH', 'name': 'Ghana'},
        {'code': 'CI', 'name': 'Ivory Coast'},
        {'code': 'SN', 'name': 'Senegal'},
        {'code': 'ML', 'name': 'Mali'},
        {'code': 'BF', 'name': 'Burkina Faso'},
        {'code': 'NE', 'name': 'Niger'},
        {'code': 'TD', 'name': 'Chad'},
        {'code': 'CM', 'name': 'Cameroon'},
        {'code': 'CF', 'name': 'Central African Republic'},
        {'code': 'CG', 'name': 'Congo'},
        {'code': 'CD', 'name': 'Democratic Republic of the Congo'},
        {'code': 'AO', 'name': 'Angola'},
        {'code': 'ZM', 'name': 'Zambia'},
        {'code': 'ZW', 'name': 'Zimbabwe'},
        {'code': 'BW', 'name': 'Botswana'},
        {'code': 'NA', 'name': 'Namibia'},
        {'code': 'SZ', 'name': 'Eswatini'},
        {'code': 'LS', 'name': 'Lesotho'},
        {'code': 'MW', 'name': 'Malawi'},
        {'code': 'MZ', 'name': 'Mozambique'},
        {'code': 'MG', 'name': 'Madagascar'},
        {'code': 'MU', 'name': 'Mauritius'},
        {'code': 'SC', 'name': 'Seychelles'},
        {'code': 'KM', 'name': 'Comoros'},
        {'code': 'DJ', 'name': 'Djibouti'},
        {'code': 'SO', 'name': 'Somalia'},
        {'code': 'ER', 'name': 'Eritrea'},
        {'code': 'SS', 'name': 'South Sudan'},
        {'code': 'RW', 'name': 'Rwanda'},
        {'code': 'BI', 'name': 'Burundi'},
        {'code': 'CV', 'name': 'Cape Verde'},
        {'code': 'GW', 'name': 'Guinea-Bissau'},
        {'code': 'GN', 'name': 'Guinea'},
        {'code': 'SL', 'name': 'Sierra Leone'},
        {'code': 'LR', 'name': 'Liberia'},
        {'code': 'TG', 'name': 'Togo'},
        {'code': 'BJ', 'name': 'Benin'},
        {'code': 'MR', 'name': 'Mauritania'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final countries = _getCountries();
    final selectedCountry = countries.firstWhere(
      (country) => country['code'] == _selectedCountryCode,
      orElse: () => {'code': '', 'name': ''},
    );
    
    return GestureDetector(
      onTap: widget.enabled ? () => _showCountryPicker(context, countries) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label ?? AppLocalizations.of(context)!.country,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.public),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          child: Text(
            _selectedCountryCode != null ? selectedCountry['name']! : AppLocalizations.of(context)!.selectCountry,
            style: TextStyle(
              color: _selectedCountryCode != null ? Colors.black : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context, List<Map<String, String>> countries) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectCountry),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              return ListTile(
                title: Text(country['name']!),
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country['code'];
                  });
                  widget.onCountrySelected(country['code']);
                  Navigator.pop(context);
                },
                selected: _selectedCountryCode == country['code'],
              );
            },
          ),
        ),
      ),
    );
  }
}