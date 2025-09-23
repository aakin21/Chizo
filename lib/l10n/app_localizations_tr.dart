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
  String get winRate => 'Galibiyet Oranı';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get leaderboard => '🏆 Liderlik';

  @override
  String get tournament => 'Turnuva';

  @override
  String get language => 'Dil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'İngilizce';

  @override
  String get german => 'Almanca';

  @override
  String get coins => 'Coin';

  @override
  String get totalMatches => 'Toplam Maçlar';

  @override
  String get wins => 'Galibiyetler';

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
  String coinsEarnedFromPredictions(int coins) {
    return 'Tahminlerden Kazanılan: $coins coin';
  }

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

  @override
  String get usernameCannotBeEmpty => 'Kullanıcı adı boş olamaz';

  @override
  String get emailCannotBeEmpty => 'E-posta boş olamaz';

  @override
  String get passwordCannotBeEmpty => 'Şifre boş olamaz';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get registrationSuccessful => 'Kayıt başarılı!';

  @override
  String get userAlreadyExists =>
      'Bu kullanıcı zaten kayıtlı veya bir hata oluştu';

  @override
  String get loginSuccessful => 'Giriş başarılı!';

  @override
  String get loginError => 'Giriş hatası: Bilinmeyen hata';

  @override
  String get dontHaveAccount => 'Hesabın yok mu? ';

  @override
  String get registerNow => 'Kayıt ol';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı? ';

  @override
  String get loginNow => 'Giriş yap';

  @override
  String get allPhotoSlotsFull => 'Tüm ek fotoğraf slotları dolu!';

  @override
  String photoUploadSlot(int slot) {
    return 'Fotoğraf Yükle - Slot $slot';
  }

  @override
  String coinsRequiredForSlot(int coins) {
    return 'Bu slot için $coins coin gerekiyor.';
  }

  @override
  String currentCoins(int coins) {
    return 'Mevcut Coin';
  }

  @override
  String get insufficientCoinsForUpload =>
      'Yetersiz coin! Coin satın almak için profil sayfasındaki coin butonunu kullanın.';

  @override
  String get cancel => 'İptal';

  @override
  String upload(int coins) {
    return 'Yükle ($coins coin)';
  }

  @override
  String photoUploaded(int coinsSpent) {
    return 'Fotoğraf yüklendi! $coinsSpent coin harcandı.';
  }

  @override
  String get deletePhoto => 'Fotoğrafı Sil';

  @override
  String get confirmDeletePhoto =>
      'Bu fotoğrafı silmek istediğinizden emin misiniz?';

  @override
  String get delete => 'Sil';

  @override
  String get photoDeleted => 'Fotoğraf silindi!';

  @override
  String get selectFromGallery => 'Galeriden Seç';

  @override
  String get takeFromCamera => 'Kameradan Çek';

  @override
  String get additionalMatchPhotos => 'Ek Match Fotoğrafları';

  @override
  String get addPhoto => 'Fotoğraf Ekle';

  @override
  String additionalPhotosDescription(int count) {
    return 'Matchlerde görünecek ek fotoğraflarınız ($count/4)';
  }

  @override
  String get noAdditionalPhotos => 'Henüz ek fotoğraf yok';

  @override
  String get secondPhotoCost => '2. fotoğraf 50 coin!';

  @override
  String get premiumInfoAdded =>
      'Premium bilgileriniz eklendi! Görünürlük ayarlarını aşağıdan yapabilirsiniz.';

  @override
  String get premiumInfoVisibility => 'Premium Bilgi Görünürlüğü';

  @override
  String get premiumInfoDescription =>
      'Bu bilgileri diğer kullanıcılar coin harcayarak görebilir';

  @override
  String get instagramAccount => 'Instagram Hesabı';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get predictionStatistics => 'Tahmin İstatistikleri';

  @override
  String get matchHistory => 'Match Geçmişi';

  @override
  String get viewLastFiveMatches =>
      'Son 5 matchinizi ve rakiplerinizi görün (5 coin)';

  @override
  String get visibleInMatches => 'Matchlere Açık';

  @override
  String get nowVisibleInMatches => 'Artık matchlerde görüneceksiniz!';

  @override
  String get removedFromMatches => 'Matchlerden çıkarıldınız!';

  @override
  String addInfo(String type) {
    return '$type Ekle';
  }

  @override
  String enterInfo(String type) {
    return '$type bilginizi girin:';
  }

  @override
  String get add => 'Ekle';

  @override
  String infoAdded(String type) {
    return '✅ $type bilgisi eklendi!';
  }

  @override
  String get errorAddingInfo => '❌ Bilgi eklenirken hata oluştu!';

  @override
  String get matchInfoNotLoaded => 'Maç bilgileri yüklenemedi';

  @override
  String premiumInfo(String type) {
    return 'Premium Bilgiler';
  }

  @override
  String get spendFiveCoins => 'Bu bilgiyi görmek için 5 coin harcayacaksın';

  @override
  String get insufficientCoins => '❌ Yeterli coin yok!';

  @override
  String get fiveCoinsSpent => '✅ 5 coin harcandı';

  @override
  String get ok => 'Tamam';

  @override
  String matchCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get spendFiveCoinsToView =>
      'Bu bilgiyi görmek için 5 coin harcayacaksın';

  @override
  String get great => 'Harika!';

  @override
  String get homePage => 'Ana Sayfa';

  @override
  String streakMessage(int days) {
    return '$days günlük streak!';
  }

  @override
  String get purchaseCoins => 'Coin Satın Al';

  @override
  String get watchAd => 'Reklam İzle';

  @override
  String get dailyAdLimit => 'Günde maksimum 5 reklam izleyebilirsiniz';

  @override
  String get coinsPerAd => 'Reklam başına: 20 coin';

  @override
  String get watchAdButton => 'Reklam İzle';

  @override
  String get dailyLimitReached => 'Günlük limit doldu';

  @override
  String get recentTransactions => 'Son İşlemler:';

  @override
  String get noTransactionHistory => 'Henüz işlem geçmişi yok';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirmation =>
      'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?';

  @override
  String logoutError(String error) {
    return 'Çıkış yapılırken hata oluştu';
  }

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountConfirmation =>
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.';

  @override
  String get finalConfirmation => 'Son Onay';

  @override
  String get typeDeleteToConfirm => 'Hesabınızı silmek için \"SİL\" yazın:';

  @override
  String get pleaseTypeDelete => 'Lütfen \"SİL\" yazın!';

  @override
  String get accountDeletedSuccessfully => 'Hesabınız başarıyla silindi!';

  @override
  String errorDeletingAccount(String error) {
    return 'Hesap silinirken hata oluştu';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Reklam izlenirken hata oluştu';
  }

  @override
  String get watchingAd => 'Reklam İzleniyor';

  @override
  String get adLoading => 'Reklam yükleniyor...';

  @override
  String get adSimulation =>
      'Bu simülasyon reklamıdır. Gerçek uygulamada burada reklam gösterilecektir.';

  @override
  String get adWatched => 'Reklam izlendi! +20 coin kazandınız!';

  @override
  String get errorAddingCoins => 'Coin eklenirken hata oluştu';

  @override
  String get buy => 'Satın Al';

  @override
  String get predict => 'Tahmin Et';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ 5 coin harcandı! Match geçmişiniz görüntüleniyor.';

  @override
  String get insufficientCoinsForHistory => '❌ Yeterli coin yok!';

  @override
  String get spendFiveCoinsForHistory => '5 Coin Harca';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins galibiyet • $matches maç';
  }

  @override
  String get insufficientCoinsForTournament => 'Yetersiz coin!';

  @override
  String get joinedTournament => 'Turnuvaya katıldınız!';

  @override
  String get tournamentJoinFailed => 'Turnuvaya katılım başarısız!';

  @override
  String get dailyStreak => 'Günlük Streak!';

  @override
  String get imageUpdated => 'Resim güncellendi!';

  @override
  String get updateFailed => 'Güncelleme başarısız!';

  @override
  String get imageUpdateFailed => 'Resim güncellenemedi!';

  @override
  String get selectImage => 'Resim Seç';

  @override
  String get userInfoNotLoaded => 'Kullanıcı bilgileri yüklenemedi';

  @override
  String get coin => 'Coin';

  @override
  String get premiumFeatures => 'Premium Özellikler';

  @override
  String get addInstagram => 'Instagram Hesabı Ekle';

  @override
  String get addProfession => 'Meslek Ekle';

  @override
  String get profileUpdated => 'Profil güncellendi!';

  @override
  String get profileUpdateFailed => 'Profil güncellenirken hata oluştu';

  @override
  String get profileSettings => 'Profil Ayarları';

  @override
  String get passwordReset => 'Şifre Sıfırla';

  @override
  String get passwordResetSubtitle => 'E-posta ile şifre sıfırlama';

  @override
  String get logoutSubtitle => 'Hesabınızdan güvenli çıkış';

  @override
  String get deleteAccountSubtitle => 'Hesabınızı kalıcı olarak silin';

  @override
  String get updateProfile => 'Profili Güncelle';

  @override
  String get passwordResetTitle => 'Şifre Sıfırlama';

  @override
  String get passwordResetMessage =>
      'E-posta adresinize şifre sıfırlama bağlantısı gönderilecek. Devam etmek istiyor musunuz?';

  @override
  String get send => 'Gönder';

  @override
  String get passwordResetSent => 'Şifre sıfırlama e-postası gönderildi!';

  @override
  String get emailNotFound => 'E-posta adresi bulunamadı!';

  @override
  String get votingError => 'Oylama sırasında hata oluştu';

  @override
  String slot(Object slot) {
    return 'Slot $slot';
  }

  @override
  String get instagramAdded => 'Instagram bilgisi eklendi!';

  @override
  String get professionAdded => 'Meslek bilgisi eklendi!';

  @override
  String get addInstagramFromSettings =>
      'Instagram ve meslek bilgilerini ayarlardan ekleyerek bu özelliği kullanabilirsin';

  @override
  String get basicInfo => 'Temel Bilgiler';

  @override
  String get premiumInfoSettings => 'Premium Bilgiler';

  @override
  String get premiumInfoDescriptionSettings =>
      'Bu bilgileri diğer kullanıcılar coin harcayarak görebilir';

  @override
  String get coinInfo => 'Coin Bilgileri';

  @override
  String get remaining => 'Kalan';

  @override
  String get vs => 'VS';

  @override
  String get coinPurchase => 'Coin Satın Al';

  @override
  String get purchaseSuccessful => 'Satın alma başarılı!';

  @override
  String get purchaseFailed => 'Satın alma başarısız!';

  @override
  String get coinPackages => 'Coin Paketleri';

  @override
  String get coinUsage => 'Coin Kullanımı';

  @override
  String get instagramView => 'Instagram hesaplarını görüntüle';

  @override
  String get professionView => 'Meslek bilgilerini görüntüle';

  @override
  String get statsView => 'Detaylı istatistikleri görüntüle';

  @override
  String get tournamentFees => 'Turnuva katılım ücretleri';

  @override
  String get premiumFilters => 'Premium filtreler';

  @override
  String get viewStats => 'İstatistik Gör';

  @override
  String get photoStats => 'Fotoğraf İstatistikleri';

  @override
  String get photoStatsCost =>
      'Fotoğraf istatistiklerini görüntülemek 50 coin tutar';

  @override
  String get insufficientCoinsForStats =>
      'Fotoğraf istatistiklerini görüntülemek için yetersiz coin. Gerekli: 50 coin';

  @override
  String get pay => 'Öde';
}
