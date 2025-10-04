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
  String predictUserWinRate(String username) {
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
  String get spanish => 'İspanyolca';

  @override
  String get turkishLanguage => 'Türkçe';

  @override
  String get englishLanguage => 'İngilizce';

  @override
  String get germanLanguage => 'Almanca';

  @override
  String get coins => 'Coin';

  @override
  String get coinPackages => 'Coin Paketleri';

  @override
  String get watchAds => 'Reklam İzle';

  @override
  String get watchAdsToEarnCoins => 'Reklam İzleyerek Coin Kazan';

  @override
  String get watchAdsDescription =>
      '24 saat içinde 3 video izleme hakkı - Her video için 5 coin';

  @override
  String get buy => 'Satın Al';

  @override
  String get watchAd => 'Reklam İzle';

  @override
  String get watchAdConfirmation =>
      'Reklam izleyerek 5 coin kazanabilirsiniz. Devam etmek istiyor musunuz?';

  @override
  String get watchingAd => 'Reklam İzleniyor';

  @override
  String coinsEarned(int count) {
    return '$count coin kazandınız!';
  }

  @override
  String get errorAddingCoins => 'Coin eklenirken hata oluştu';

  @override
  String get buyCoins => 'Coin Satın Al';

  @override
  String buyCoinsConfirmation(int count) {
    return '$count coin satın almak istiyor musunuz?';
  }

  @override
  String get processing => 'İşlem gerçekleştiriliyor...';

  @override
  String coinsAdded(int count) {
    return '$count coin eklendi!';
  }

  @override
  String get watch => 'İzle';

  @override
  String get adLimitReached => 'Günlük reklam izleme limitiniz doldu!';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationSettingsDescription =>
      'Telefon bildirimlerini aç/kapat (bildirimler uygulamada görünmeye devam eder)';

  @override
  String get tournamentNotifications => 'Turnuva Bildirimleri';

  @override
  String get tournamentNotificationsDescription =>
      'Yeni turnuva davetleri ve güncellemeleri';

  @override
  String get winCelebrationNotifications => 'Zafer Kutlamaları';

  @override
  String get winCelebrationNotificationsDescription => 'Kazanma bildirimleri';

  @override
  String get streakReminderNotifications => 'Streak Hatırlatmaları';

  @override
  String get streakReminderNotificationsDescription =>
      'Günlük streak hatırlatmaları';

  @override
  String get notificationSettingsSaved => 'Bildirim ayarları kaydedildi';

  @override
  String get markAllAsRead => 'Tümünü Okundu İşaretle';

  @override
  String get deleteAll => 'Tümünü sil';

  @override
  String get totalMatches => 'Toplam Maç';

  @override
  String get wins => 'Kazanma';

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
  String get correctPredictionWithReward =>
      'Doğru tahmin ettin ve 1 coin kazandın!';

  @override
  String wrongPredictionWithRate(double winRate) {
    return 'Yanlış tahmin. Gerçek kazanma oranı %$winRate idi';
  }

  @override
  String get error => 'Hata';

  @override
  String get invalidEmail =>
      '❌ Geçersiz e-posta adresi! Lütfen doğru formatta e-posta girin.';

  @override
  String get userNotFoundError =>
      '❌ Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı!';

  @override
  String get userAlreadyRegistered =>
      '❌ Bu e-posta adresi zaten kayıtlı! Giriş yapmayı deneyin.';

  @override
  String get invalidPassword =>
      '❌ Yanlış şifre! Lütfen şifrenizi kontrol edin.';

  @override
  String get passwordMinLengthError => '❌ Şifre en az 6 karakter olmalıdır!';

  @override
  String get passwordTooWeak =>
      '❌ Şifre çok zayıf! Daha güçlü bir şifre seçin.';

  @override
  String get usernameAlreadyTaken =>
      '❌ Bu kullanıcı adı zaten alınmış! Başka bir kullanıcı adı seçin.';

  @override
  String get usernameTooShort => '❌ Kullanıcı adı en az 3 karakter olmalıdır!';

  @override
  String get networkError => '❌ İnternet bağlantınızı kontrol edin!';

  @override
  String get timeoutError => '❌ Bağlantı zaman aşımı! Lütfen tekrar deneyin.';

  @override
  String get emailNotConfirmed => '❌ E-posta adresinizi onaylamanız gerekiyor!';

  @override
  String get tooManyRequests =>
      '❌ Çok fazla deneme! Lütfen birkaç dakika sonra tekrar deneyin.';

  @override
  String get accountDisabled => '❌ Hesabınız devre dışı bırakılmış!';

  @override
  String get accountDeletedPleaseRegister =>
      '❌ Hesabınız silinmiş. Lütfen yeni bir hesap açınız.';

  @override
  String get duplicateData =>
      '❌ Bu bilgiler zaten kullanılıyor! Farklı bilgiler deneyin.';

  @override
  String get invalidData =>
      '❌ Girdiğiniz bilgilerde hata var! Lütfen kontrol edin.';

  @override
  String get invalidCredentials => '❌ E-posta veya şifre hatalı!';

  @override
  String get tooManyEmails =>
      '❌ Çok fazla e-posta gönderildi! Lütfen bekleyin.';

  @override
  String get operationFailed =>
      '❌ İşlem başarısız! Lütfen bilgilerinizi kontrol edin.';

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
    return 'Fotoğraf Yüklendi';
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
  String get viewRecentMatches => 'Son maçlarını gör';

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
    return '💎 $type Bilgisi';
  }

  @override
  String get spendFiveCoins => '5 Coin Harca';

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
      'Hesabınızdan çıkmak istediğinizden emin misiniz?';

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
  String get adLoading => 'Reklam yükleniyor...';

  @override
  String get adSimulation =>
      'Bu simülasyon reklamıdır. Gerçek uygulamada burada reklam gösterilecektir.';

  @override
  String get adWatched => 'Reklam izlendi! +20 coin kazandınız!';

  @override
  String get predict => 'Tahmin Et';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ 5 coin harcandı! Match geçmişiniz görüntüleniyor.';

  @override
  String get insufficientCoinsForHistory => '❌ Yeterli coin yok!';

  @override
  String get spendFiveCoinsForHistory =>
      'Son 5 matchinizi ve rakiplerinizi görmek için 5 coin harcayın';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins galibiyet • $matches maç';
  }

  @override
  String get insufficientCoinsForTournament => 'Turnuva için yeterli coin yok!';

  @override
  String get joinedTournament => 'Turnuvaya katıldınız!';

  @override
  String get tournamentJoinFailed => 'Turnuvaya katılım başarısız!';

  @override
  String get dailyStreak => 'Günlük Streak!';

  @override
  String get imageUpdated => 'Resim güncellendi!';

  @override
  String get updateFailed => 'Güncelleme başarısız';

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
  String get deleteAccountSubtitle => 'Hesabınızı kalıcı olarak sil';

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
  String votingError(Object error) {
    return 'Oylama sırasında hata: $error';
  }

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
  String currentCoins(int coins) {
    return 'Mevcut Coin';
  }

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
  String get weeklyMaleTournament1000 => 'Haftalık Erkek Turnuvası (1000 Coin)';

  @override
  String get weeklyMaleTournament1000Desc =>
      'Her hafta düzenlenen erkek turnuvası - 300 kişi kapasiteli';

  @override
  String get weeklyMaleTournament10000 =>
      'Haftalık Erkek Turnuvası (10000 Coin)';

  @override
  String get weeklyMaleTournament10000Desc =>
      'Premium erkek turnuvası - 100 kişi kapasiteli';

  @override
  String get weeklyFemaleTournament1000 =>
      'Haftalık Kadın Turnuvası (1000 Coin)';

  @override
  String get weeklyFemaleTournament1000Desc =>
      'Her hafta düzenlenen kadın turnuvası - 300 kişi kapasiteli';

  @override
  String get weeklyFemaleTournament10000 =>
      'Haftalık Kadın Turnuvası (10000 Coin)';

  @override
  String get weeklyFemaleTournament10000Desc =>
      'Premium kadın turnuvası - 100 kişi kapasiteli';

  @override
  String get tournamentEntryFee => 'Turnuva katılım ücreti';

  @override
  String get tournamentVotingTitle => 'Turnuva Oylaması';

  @override
  String get tournamentThirdPlace => 'Turnuva 3.lük';

  @override
  String get tournamentWon => 'Turnuva kazandı';

  @override
  String get userNotLoggedIn => 'Kullanıcı giriş yapmamış';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı';

  @override
  String get firstLoginReward => '🎉 İlk girişiniz! 50 coin kazandınız!';

  @override
  String streakReward(Object coins, Object streak) {
    return '🔥 $streak günlük streak! $coins coin kazandınız!';
  }

  @override
  String get streakBroken =>
      '💔 Streak kırıldı! Yeni başlangıç: 50 coin kazandınız!';

  @override
  String dailyStreakReward(Object streak) {
    return 'Günlük streak ödülü ($streak gün)';
  }

  @override
  String get alreadyLoggedInToday => 'Bugün zaten giriş yaptınız!';

  @override
  String get streakCheckError => 'Streak kontrolünde hata oluştu';

  @override
  String get streakInfoError => 'Streak bilgisi alınamadı';

  @override
  String get correctPredictionReward =>
      'Doğru tahmin ettiğinde 1 coin kazanacaksın!';

  @override
  String get wrongPredictionMessage => 'Maalesef yanlış tahmin ettin.';

  @override
  String get predictionSaveError => 'Tahmin kaydedilirken hata oluştu';

  @override
  String get coinAddError => 'Coin eklenirken hata oluştu';

  @override
  String coinPurchaseTransaction(Object description) {
    return 'Coin satın alma - $description';
  }

  @override
  String get whiteThemeName => 'Beyaz';

  @override
  String get darkThemeName => 'Koyu';

  @override
  String get pinkThemeName => 'Pembemsi';

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

  @override
  String get tournamentVotingSaved => '🏆 Turnuva oylaması kaydedildi!';

  @override
  String get tournamentVotingFailed => '❌ Turnuva oylaması kaydedilemedi!';

  @override
  String get tournamentVoting => '🏆 TURNUVA OYLAMASI';

  @override
  String get whichTournamentParticipant =>
      'Hangi turnuva katılımcısını tercih ediyorsunuz?';

  @override
  String ageYears(Object age, Object country) {
    return '$age yaş • $country';
  }

  @override
  String get clickToOpenInstagram => '📱 Instagram\'ı açmak için tıklayın';

  @override
  String get openInstagram => 'Instagram\'ı Aç';

  @override
  String get instagramCannotBeOpened =>
      '❌ Instagram açılamadı. Lütfen Instagram uygulamasını kontrol edin.';

  @override
  String instagramOpenError(Object error) {
    return '❌ Instagram açılırken hata oluştu: $error';
  }

  @override
  String get tournamentPhoto => '🏆 Turnuva Fotoğrafı';

  @override
  String get tournamentJoinedUploadPhoto =>
      'Turnuvaya katıldınız! Şimdi turnuva fotoğrafınızı yükleyin.';

  @override
  String get uploadLater => 'Sonra Yükle';

  @override
  String get uploadPhoto => 'Fotoğraf Yükle';

  @override
  String get tournamentPhotoUploaded => '✅ Turnuva fotoğrafı yüklendi!';

  @override
  String get photoUploadError => '❌ Fotoğraf yüklenirken hata oluştu!';

  @override
  String get noVotingForTournament => 'Bu turnuva için oylama bulunamadı';

  @override
  String votingLoadError(Object error) {
    return 'Oylama yüklenirken hata: $error';
  }

  @override
  String get whichParticipantPrefer => 'Hangi katılımcıyı tercih ediyorsunuz?';

  @override
  String get voteSavedSuccessfully => 'Oyunuz başarıyla kaydedildi!';

  @override
  String get noActiveTournament => 'Şu anda aktif turnuva bulunmuyor';

  @override
  String get registration => 'Kayıt';

  @override
  String get upcoming => 'Yaklaşıyor';

  @override
  String coinPrize(Object prize) {
    return '$prize coin ödül';
  }

  @override
  String startDate(Object date) {
    return 'Başlangıç: $date';
  }

  @override
  String get completed => 'Tamamlandı';

  @override
  String get join => 'Katıl';

  @override
  String get photo => 'Fotoğraf';

  @override
  String get languageChanged => 'Dil değiştirildi. Sayfa yenileniyor...';

  @override
  String get lightWhiteTheme => 'Beyaz materyal açık tema';

  @override
  String get neutralDarkGrayTheme => 'Nötr koyu gri tema';

  @override
  String themeChanged(Object theme) {
    return 'Tema değiştirildi: $theme';
  }

  @override
  String get deleteAccountWarning =>
      'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecek.\nHesabınızı silmek istediğinizden emin misiniz?';

  @override
  String get accountDeleted => 'Hesabınız silindi';

  @override
  String get logoutButton => 'Çıkış';

  @override
  String get themeSelection => '🎨 Tema Seçimi';

  @override
  String get darkMaterialTheme => 'Siyah materyal koyu tema';

  @override
  String get lightPinkTheme => 'Açık pembe renk tema';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get allNotifications => 'Tüm Bildirimler';

  @override
  String get allNotificationsSubtitle => 'Ana bildirimleri aç/kapat';

  @override
  String get voteReminder => 'Oylama Hatırlatması';

  @override
  String get winCelebration => 'Kazanç Kutlaması';

  @override
  String get streakReminder => 'Seri Hatırlatması';

  @override
  String get streakReminderSubtitle => 'Günlük seri ödülleri hatırlatması';

  @override
  String get moneyAndCoins => '💰 Para & Coin İşlemleri';

  @override
  String get purchaseCoinPackage => 'Coin Paketi Satın Al';

  @override
  String get purchaseCoinPackageSubtitle =>
      'Coin satın alın ve ödüller kazanın';

  @override
  String get appSettings => '⚙️ Uygulama Ayarları';

  @override
  String get dailyRewards => 'Günlük Ödüller';

  @override
  String get dailyRewardsSubtitle => 'Seri ödülleri ve boost\'ları görün';

  @override
  String get aboutApp => 'Uygulama Hakkında';

  @override
  String get accountOperations => '👤 Hesap İşlemleri';

  @override
  String get dailyStreakRewards => 'Günlük Seri Ödülleri';

  @override
  String get dailyStreakDescription =>
      '🎯 Her gün uygulamaya girin ve bonuslar kazanın!';

  @override
  String get appDescription =>
      'Sohbet odalarında oylama ve turnuva uygulaması.';

  @override
  String get predictWinRateTitle => 'Kazanma oranını tahmin et!';

  @override
  String get wrongPredictionNoCoin => 'Yanlış tahmin = 0 coin';

  @override
  String get selectWinRateRange => 'Kazanma Oranı Aralığı Seç:';

  @override
  String get wrongPrediction => 'Yanlış Tahmin';

  @override
  String get correctPredictionMessage => 'Doğru tahmin ettin!';

  @override
  String actualRate(Object rate) {
    return 'Gerçek oran: $rate%';
  }

  @override
  String get earnedOneCoin => '+1 coin kazandın!';

  @override
  String myPhotos(Object count) {
    return 'Fotoğraflarım ($count/5)';
  }

  @override
  String get photoCostInfo =>
      'İlk fotoğraf ücretsiz, diğerleri coin ile alınır. Tüm fotoğrafların istatistiklerini görebilirsiniz.';

  @override
  String get addAge => 'Yaş Ekle';

  @override
  String get addCountry => 'Ülke Ekle';

  @override
  String get addGender => 'Cinsiyet Ekle';

  @override
  String get countrySelection => 'Ülke Seçimi';

  @override
  String countriesSelected(Object count) {
    return '$count ülke seçili';
  }

  @override
  String get allCountriesSelected => 'Tüm ülkeler seçili';

  @override
  String get ageRangeSelection => 'Yaş Aralığı Seçimi';

  @override
  String ageRangesSelected(Object count) {
    return '$count yaş aralığı seçili';
  }

  @override
  String get allAgeRangesSelected => 'Tüm yaş aralıkları seçili';

  @override
  String get editUsername => 'Kullanıcı Adı Düzenle';

  @override
  String get enterUsername => 'Kullanıcı adınızı girin';

  @override
  String get editAge => 'Yaş Düzenle';

  @override
  String get enterAge => 'Yaşınızı girin';

  @override
  String get selectCountry => 'Ülke Seç';

  @override
  String get selectYourCountry => 'Ülkenizi seçin';

  @override
  String get selectGender => 'Cinsiyet Seç';

  @override
  String get selectYourGender => 'Cinsiyetinizi seçin';

  @override
  String get editInstagram => 'Instagram Hesabı Düzenle';

  @override
  String get enterInstagram => 'Instagram kullanıcı adınızı girin (@ olmadan)';

  @override
  String get editProfession => 'Meslek Düzenle';

  @override
  String get enterProfession => 'Mesleğinizi girin';

  @override
  String get infoUpdated => 'Bilgi güncellendi';

  @override
  String get countryPreferencesUpdated => '✅ Ülke tercihleri güncellendi';

  @override
  String get countryPreferencesUpdateFailed =>
      '❌ Ülke tercihleri güncellenemedi';

  @override
  String get ageRangePreferencesUpdated =>
      '✅ Yaş aralığı tercihleri güncellendi';

  @override
  String get ageRangePreferencesUpdateFailed =>
      '❌ Yaş aralığı tercihleri güncellenemedi';

  @override
  String winRateAndMatches(Object matches, Object winRate) {
    return '$matches maç • $winRate';
  }

  @override
  String get mostWins => 'En Çok Galibiyet';

  @override
  String get highestWinRate => 'En Yüksek Kazanma Oranı';

  @override
  String get noWinsYet =>
      'Henüz galibiyet yok!\nİlk maçını yap ve liderlik tablosuna gir!';

  @override
  String get noWinRateYet =>
      'Henüz kazanma oranı yok!\nMaç yaparak kazanma oranını artır!';

  @override
  String get matchHistoryViewing => 'Match geçmişi görüntüleme';

  @override
  String winRateColon(Object winRate) {
    return 'Kazanma Oranı: $winRate';
  }

  @override
  String matchesAndWins(Object matches, Object wins) {
    return '$matches maç • $wins galibiyet';
  }

  @override
  String get youWon => 'Kazandın';

  @override
  String get youLost => 'Kaybettin';

  @override
  String get lastFiveMatchStats => '📊 Son 5 Match İstatistikleri';

  @override
  String get noMatchHistoryYet =>
      'Henüz match geçmişiniz yok!\nİlk matchinizi yapın!';

  @override
  String get premiumFeature => '🔒 Premium Özellik';

  @override
  String get save => 'Kaydet';

  @override
  String get leaderboardTitle => '🏆 Liderlik Tablosu';

  @override
  String get day1_2Reward => 'Gün 1-2: 10-25 Coin';

  @override
  String get day3_6Reward => 'Gün 3-6: 50-100 Coin';

  @override
  String get day7PlusReward => 'Gün 7+: 200+ Coin & Boost';

  @override
  String get photoStatsLoadError => 'Fotoğraf istatistikleri yüklenemedi';

  @override
  String get newTournamentInvitations => 'Yeni turnuva davetleri';

  @override
  String get victoryNotifications => 'Zafer bildirimleri';

  @override
  String get vote => 'Oyla';

  @override
  String get lastFiveMatches => 'Son 5 Maç';

  @override
  String get total => 'Toplam';

  @override
  String get losses => 'Kaybetme';

  @override
  String get rate => 'Oran';

  @override
  String get ongoing => 'Devam Ediyor';

  @override
  String get tournamentFull => 'Turnuva Dolu';

  @override
  String get active => 'Aktif';

  @override
  String get joinWithKey => 'Key ile Katıl';

  @override
  String get private => 'Private';

  @override
  String get countryRanking => 'Ülke Sıralaması';

  @override
  String get countryRankingSubtitle =>
      'Hangi ülke vatandaşlarına karşı ne kadar başarılısın';

  @override
  String get countryRankingTitle => 'Ülke Sıralaması';

  @override
  String get countryRankingDescription =>
      'Hangi ülke vatandaşlarına karşı ne kadar başarılısın';

  @override
  String get winsAgainst => 'Kazanma';

  @override
  String get lossesAgainst => 'Kaybetme';

  @override
  String get winRateAgainst => 'Kazanma Oranı';

  @override
  String get noDataAvailable => 'Veri bulunamadı';

  @override
  String get loadingCountryStats => 'Ülke istatistikleri yükleniyor...';

  @override
  String get countryStats => 'Ülke İstatistikleri';

  @override
  String get yourPerformance => 'Performansın';

  @override
  String get againstCountry => 'Ülke Karşılaştırması';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get alreadyJoinedTournament => 'Bu turnuvaya zaten katıldınız';

  @override
  String get uploadTournamentPhoto => 'Turnuva Fotoğrafı Yükle';

  @override
  String get viewTournament => 'Turnuvayı Gör';

  @override
  String get tournamentParticipants => 'Turnuva Katılımcıları';

  @override
  String get yourRank => 'Sıralamanız';

  @override
  String get rank => 'Sıra';

  @override
  String get participant => 'Katılımcı';

  @override
  String get photoNotUploaded => 'Fotoğraf Yüklenmedi';

  @override
  String get uploadPhotoUntilWednesday =>
      'Fotoğrafı Çarşamba\'ya kadar yükleyebilirsiniz';

  @override
  String get tournamentStarted => 'Turnuva Başladı';

  @override
  String get viewTournamentPhotos => 'Turnuva Fotoğraflarını Görüntüle';

  @override
  String get genderMismatch => 'Cinsiyet Uyumsuzluğu';

  @override
  String get photoAlreadyUploaded => 'Fotoğraf Zaten Yüklendi';

  @override
  String get viewParticipantPhoto => 'Katılımcı Fotoğrafını Görüntüle';

  @override
  String get selectPhoto => 'Fotoğraf Seç';

  @override
  String get photoUploadFailed => 'Fotoğraf Yüklenemedi';

  @override
  String get tournamentCancelled => 'Turnuva İptal Edildi';

  @override
  String get refundFailed => 'İade İşlemi Başarısız';

  @override
  String get createPrivateTournament => 'Private Turnuva Oluştur';

  @override
  String get tournamentName => 'Turnuva Adı';

  @override
  String get maxParticipants => 'Maksimum Katılımcı';

  @override
  String get tournamentFormat => 'Turnuva Formatı';

  @override
  String get leagueFormat => 'Lig Usulü';

  @override
  String get eliminationFormat => 'Eleme Usulü';

  @override
  String get hybridFormat => 'Lig + Eleme';

  @override
  String get eliminationMaxParticipants => 'Eleme usulü için maksimum 8 kişi';

  @override
  String get eliminationMaxParticipantsWarning =>
      'Eleme usulü için maksimum 8 kişi olabilir';

  @override
  String get weeklyMaleTournament1000Description =>
      'Her hafta düzenlenen erkek turnuvası - 300 kişi kapasiteli';

  @override
  String get weeklyMaleTournament10000Description =>
      'Premium erkek turnuvası - 100 kişi kapasiteli';

  @override
  String get weeklyFemaleTournament1000Description =>
      'Her hafta düzenlenen kadın turnuvası - 300 kişi kapasiteli';

  @override
  String get weeklyFemaleTournament10000Description =>
      'Premium kadın turnuvası - 100 kişi kapasiteli';

  @override
  String get dataPrivacy => 'Veri Gizliliği';

  @override
  String get dataPrivacyDescription => 'Veri ve gizlilik ayarlarınızı yönetin';

  @override
  String get profileVisibility => 'Profil Görünürlüğü';

  @override
  String get profileVisibilityDescription =>
      'Profilinizi kimlerin görebileceğini kontrol edin';

  @override
  String get dataCollection => 'Veri Toplama';

  @override
  String get dataCollectionDescription =>
      'Analitik için veri toplamaya izin ver';

  @override
  String get marketingEmails => 'Pazarlama E-postaları';

  @override
  String get marketingEmailsDescription =>
      'Promosyon e-postaları ve güncellemeleri al';

  @override
  String get locationTracking => 'Konum Takibi';

  @override
  String get locationTrackingDescription =>
      'Konum tabanlı özelliklere izin ver';

  @override
  String get reportContent => 'İçerik Bildir';

  @override
  String get reportInappropriate => 'Uygunsuz İçerik Bildir';

  @override
  String get reportReason => 'Bildirim Sebebi';

  @override
  String get nudity => 'Çıplaklık';

  @override
  String get inappropriateContent => 'Uygunsuz İçerik';

  @override
  String get harassment => 'Taciz';

  @override
  String get spam => 'Spam';

  @override
  String get other => 'Diğer';

  @override
  String get reportSubmitted => 'Bildirim başarıyla gönderildi';

  @override
  String get reportError => 'Bildirim gönderilemedi';

  @override
  String get submit => 'Gönder';

  @override
  String get profileVisible => 'Profil artık görünür';

  @override
  String get profileHidden => 'Profil artık gizli';

  @override
  String get notificationCenter => 'Bildirimler';

  @override
  String get allNotificationsDescription =>
      'Tüm bildirim türlerini etkinleştir/devre dışı bırak';

  @override
  String get voteReminderNotifications => 'Oylama Hatırlatmaları';

  @override
  String get voteReminderNotificationsDescription =>
      'Oylama hatırlatma bildirimleri';

  @override
  String get notificationsList => 'Bildirimler';

  @override
  String get noNotificationsYet => 'Henüz bildirim yok';

  @override
  String get newNotificationsWillAppearHere =>
      'Yeni bildirimler burada görünecek';
}
