import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gender_model.dart';

class GenderService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Kullanıcının diline göre cinsiyet listesini getir
  static Future<List<Gender>> getGendersByLanguage(String language) async {
    try {
      final response = await _supabase
          .rpc('get_genders_by_language', params: {'lang': language})
          .select();

      final genders = (response as List)
          .map((json) => Gender.fromJson(json as Map<String, dynamic>))
          .toList();
          
      // Duplicate gender codes'ları temizle
      final uniqueGenders = <String, Gender>{};
      for (final gender in genders) {
        uniqueGenders[gender.code] = gender;
      }
      return uniqueGenders.values.toList();
    } catch (e) {
      // debugPrint('Error fetching genders: $e');
      return [];
    }
  }

  /// Cinsiyet koduna göre cinsiyet bilgisini getir
  static Future<Gender?> getGenderByCode(String code, String language) async {
    try {
      final genders = await getGendersByLanguage(language);
      return genders.firstWhere(
        (gender) => gender.code == code,
        orElse: () => Gender(code: code, name: code),
      );
    } catch (e) {
      // debugPrint('Error fetching gender by code: $e');
      return Gender(code: code, name: code);
    }
  }

  /// Tüm cinsiyetleri getir (İngilizce)
  static Future<List<Gender>> getAllGenders() async {
    return await getGendersByLanguage('en');
  }

  /// Türkçe cinsiyetleri getir
  static Future<List<Gender>> getTurkishGenders() async {
    return await getGendersByLanguage('tr');
  }

  /// Almanca cinsiyetleri getir
  static Future<List<Gender>> getGermanGenders() async {
    return await getGendersByLanguage('de');
  }

  /// İspanyolca cinsiyetleri getir
  static Future<List<Gender>> getSpanishGenders() async {
    return await getGendersByLanguage('es');
  }
}

