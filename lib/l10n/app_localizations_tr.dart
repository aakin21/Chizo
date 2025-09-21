// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Chizo';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get age => 'Yaş';

  @override
  String get country => 'Ülke';

  @override
  String get gender => 'Cinsiyet';

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kadın';

  @override
  String get instagramHandle => 'Instagram Kullanıcı Adı';

  @override
  String get profession => 'Meslek';

  @override
  String get voting => 'Oylama';

  @override
  String get whichDoYouPrefer => 'Hangisini daha çok beğeniyorsunuz?';

  @override
  String predictWinRate(String username) {
    return '$username kazanma oranını tahmin et';
  }

  @override
  String get correctPrediction => 'Doğru tahmin = 1 coin';

  @override
  String get submitPrediction => 'Tahmini Gönder';

  @override
  String get winRate => 'Kazanma Oranı';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get leaderboard => 'Liderlik Tablosu';

  @override
  String get tournament => 'Turnuva';

  @override
  String get language => 'Dil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'İngilizce';

  @override
  String get coins => 'Coin';

  @override
  String get totalMatches => 'Toplam Maç';

  @override
  String get wins => 'Galibiyet';

  @override
  String get winRatePercentage => 'Kazanma Oranı';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get totalStreakDays => 'Toplam Seri Günü';

  @override
  String get predictionStats => 'Tahmin İstatistikleri';

  @override
  String get totalPredictions => 'Toplam Tahmin';

  @override
  String get correctPredictions => 'Doğru Tahmin';

  @override
  String get accuracy => 'Başarı Oranı';

  @override
  String get coinsEarnedFromPredictions => 'Tahminlerden Kazanılan Coin';

  @override
  String get congratulations => 'Tebrikler!';

  @override
  String get correctPredictionMessage =>
      'Doğru tahmin ettin ve 1 coin kazandın!';

  @override
  String wrongPredictionMessage(double winRate) {
    return 'Yanlış tahmin. Gerçek kazanma oranı %$winRate idi';
  }

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get noMatchesAvailable => 'Şu anda oylayabileceğiniz maç bulunmuyor';

  @override
  String get allMatchesVoted =>
      'Tüm maçları oyladınız!\nYeni maçlar için bekleyin...';
}
