import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/country_model.dart';

class CountryService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Kullanıcının diline göre ülke listesini getir
  static Future<List<Country>> getCountriesByLanguage(String language) async {
    try {
      final response = await _supabase
          .rpc('get_countries_by_language', params: {'lang': language})
          .select();

      final countries = (response as List)
          .map((json) => Country.fromJson(json as Map<String, dynamic>))
          .toList();
          
      // Duplicate country codes'ları temizle
      final uniqueCountries = <String, Country>{};
      for (final country in countries) {
        uniqueCountries[country.code] = country;
      }
      return uniqueCountries.values.toList();
    } catch (e) {
      print('Error fetching countries: $e');
      return [];
    }
  }

  /// Ülke koduna göre ülke bilgisini getir
  static Future<Country?> getCountryByCode(String code, String language) async {
    try {
      final countries = await getCountriesByLanguage(language);
      return countries.firstWhere(
        (country) => country.code == code,
        orElse: () => Country(code: code, name: code),
      );
    } catch (e) {
      print('Error fetching country by code: $e');
      return Country(code: code, name: code);
    }
  }

  /// Tüm ülkeleri getir (İngilizce)
  static Future<List<Country>> getAllCountries() async {
    return await getCountriesByLanguage('en');
  }

  /// Türkçe ülkeleri getir
  static Future<List<Country>> getTurkishCountries() async {
    return await getCountriesByLanguage('tr');
  }

  /// Almanca ülkeleri getir
  static Future<List<Country>> getGermanCountries() async {
    return await getCountriesByLanguage('de');
  }

  /// İspanyolca ülkeleri getir
  static Future<List<Country>> getSpanishCountries() async {
    return await getCountriesByLanguage('es');
  }
}
