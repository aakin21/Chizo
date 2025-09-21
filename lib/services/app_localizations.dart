import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'appTitle': 'Chizo',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'username': 'Kullanıcı Adı',
      'email': 'E-posta',
      'password': 'Şifre',
      'forgotPassword': 'Şifremi Unuttum?',
      'noAccount': 'Hesabın yok mu?',
      'alreadyHaveAccount': 'Zaten hesabın var mı?',
      'voting': 'Oylama',
      'whichDoYouPrefer': 'Hangisini daha çok beğeniyorsunuz?',
      'predictWinRate': '{username} kazanma oranını tahmin et',
      'correctPrediction': 'Doğru tahmin = 1 coin',
      'winRate': 'Kazanma Oranı',
      'submitPrediction': 'Tahmini Gönder',
      'language': 'Dil Seçimi',
      'turkish': 'Türkçe',
      'english': 'İngilizce',
      'correctPredictionMessage': 'Doğru tahmin ettin ve 1 coin kazandın!',
      'wrongPredictionMessage': 'Yanlış tahmin. Gerçek kazanma oranı %{winRate} idi',
      'error': 'Hata',
      'success': 'Başarılı',
      'loading': 'Yükleniyor...',
      'noMatchesAvailable': 'Şu anda oylayabileceğiniz maç bulunmuyor',
      'allMatchesVoted': 'Tüm maçları oyladınız!\nYeni maçlar için bekleyin...',
      'votingError': 'Oylama sırasında hata oluştu',
      'coinPurchase': 'Coin Satın Al',
      'currentCoins': 'Mevcut Coin',
      'coinPackages': 'Coin Paketleri',
      'coinUsage': 'Coin Kullanım Alanları',
      'instagramView': 'Instagram hesabı görme: 10 coin',
      'professionView': 'Meslek bilgisi görme: 5 coin',
      'statsView': 'Kullanıcı istatistikleri görme: 3 coin',
      'tournamentFees': 'Turnuva katılım ücretleri',
      'premiumFilters': 'Premium filtreleme seçenekleri',
      'purchaseSuccessful': 'Coin satın alma başarılı!',
      'purchaseFailed': 'Coin satın alma başarısız!',
      'logout': 'Çıkış Yap',
      'logoutSubtitle': 'Hesabınızdan güvenli çıkış',
      'deleteAccount': 'Hesabı Sil',
      'deleteAccountSubtitle': 'Hesabınızı kalıcı olarak silin',
      'passwordReset': 'Şifre Sıfırla',
      'passwordResetSubtitle': 'E-posta ile şifre sıfırlama',
      'passwordResetSent': 'Şifre sıfırlama e-postası gönderildi!',
      'emailNotFound': 'E-posta adresi bulunamadı!',
      'logoutConfirm': 'Çıkış yapmak istediğinizden emin misiniz?',
      'deleteAccountConfirm': 'Hesabınızı silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz!',
      'cancel': 'İptal',
      'confirm': 'Onayla',
      'delete': 'Sil',
      'logoutSuccess': 'Başarıyla çıkış yapıldı',
      'accountDeleted': 'Hesap başarıyla silindi',
      'profile': 'Profil',
      'leaderboard': 'Liderlik Tablosu',
      'tournament': 'Turnuva',
      'settings': 'Ayarlar',
      'profileSettings': 'Profil Ayarları',
      'userInfoNotLoaded': 'Kullanıcı bilgileri yüklenemedi',
      'updateProfile': 'Profili Güncelle',
      'profileUpdated': 'Profil güncellendi!',
      'profileUpdateFailed': 'Profil güncellenirken hata oluştu',
      'passwordResetTitle': 'Şifre Sıfırlama',
      'passwordResetMessage': 'E-posta adresinize şifre sıfırlama bağlantısı gönderilecek. Devam etmek istiyor musunuz?',
      'send': 'Gönder',
      'dailyStreak': 'Günlük Streak!',
      'coin': 'Coin',
      'totalMatches': 'Toplam Maç',
      'wins': 'Galibiyet',
      'winRatePercentage': 'Kazanma Oranı',
      'currentStreak': 'Mevcut Seri',
      'totalStreakDays': 'Toplam Seri Günü',
      'predictionStats': 'Tahmin İstatistikleri',
      'totalPredictions': 'Toplam Tahmin',
      'correctPredictions': 'Doğru Tahmin',
      'accuracy': 'Başarı Oranı',
      'coinsEarnedFromPredictions': 'Tahminlerden Kazanılan Coin',
      'matchHistory': 'Maç Geçmişi',
      'premiumFeatures': 'Premium Özellikler',
      'viewInstagram': 'Instagram Görüntüle',
      'viewProfession': 'Meslek Görüntüle',
      'viewStats': 'İstatistikleri Görüntüle',
      'cost': 'Maliyet',
      'insufficientCoins': 'Yetersiz coin!',
      'selectImage': 'Resim Seç',
      'camera': 'Kamera',
      'gallery': 'Galeri',
      'imageUpdated': 'Resim güncellendi!',
      'imageUpdateFailed': 'Resim güncellenemedi!',
      'editProfile': 'Profili Düzenle',
      'save': 'Kaydet',
      'updateSuccessful': 'Güncelleme başarılı!',
      'updateFailed': 'Güncelleme başarısız!',
      'age': 'Yaş',
      'country': 'Ülke',
      'gender': 'Cinsiyet',
      'premiumInfoDescription': 'Bu bilgileri diğer kullanıcılar coin harcayarak görebilir',
      'addInstagram': 'Instagram Hesabı Ekle',
      'addProfession': 'Meslek Ekle',
      'instagramAccount': 'Instagram Hesabı',
      'profession': 'Meslek',
      'addInfoDescription': 'Instagram ve meslek bilgilerini ayarlardan ekleyerek bu özelliği kullanabilirsin',
      'joinTournament': 'Turnuvaya Katıl',
      'leaveTournament': 'Turnuvadan Ayrıl',
      'tournamentJoined': 'Turnuvaya katıldınız!',
      'tournamentLeft': 'Turnuvadan ayrıldınız!',
      'tournamentJoinFailed': 'Turnuvaya katılım başarısız!',
      'tournamentLeaveFailed': 'Turnuvadan ayrılma başarısız!',
      'noTournamentsAvailable': 'Katılabileceğiniz turnuva bulunmuyor',
      'tournamentDetails': 'Turnuva Detayları',
      'participants': 'Katılımcılar',
      'prize': 'Ödül',
      'startDate': 'Başlangıç Tarihi',
      'endDate': 'Bitiş Tarihi',
      'status': 'Durum',
      'active': 'Aktif',
      'completed': 'Tamamlandı',
      'upcoming': 'Yaklaşan',
      'noMatchesFound': 'Henüz maç bulunamadı',
      'matchDetails': 'Maç Detayları',
      'winner': 'Kazanan',
      'loser': 'Kaybeden',
      'matchDate': 'Maç Tarihi',
      'tournamentName': 'Turnuva Adı',
    },
    'en': {
      'appTitle': 'Chizo',
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'noAccount': 'Don\'t have an account?',
      'alreadyHaveAccount': 'Already have an account?',
      'voting': 'Voting',
      'whichDoYouPrefer': 'Which one do you prefer?',
      'predictWinRate': 'Predict {username}\'s win rate',
      'correctPrediction': 'Correct prediction = 1 coin',
      'winRate': 'Win Rate',
      'submitPrediction': 'Submit Prediction',
      'language': 'Language',
      'turkish': 'Turkish',
      'english': 'English',
      'correctPredictionMessage': 'You predicted correctly and earned 1 coin!',
      'wrongPredictionMessage': 'Wrong prediction. The actual win rate was {winRate}%',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'noMatchesAvailable': 'No matches available for voting',
      'allMatchesVoted': 'All matches voted!\nWaiting for new matches...',
      'votingError': 'Error occurred during voting',
      'coinPurchase': 'Purchase Coins',
      'currentCoins': 'Current Coins',
      'coinPackages': 'Coin Packages',
      'coinUsage': 'Coin Usage Areas',
      'instagramView': 'View Instagram account: 10 coins',
      'professionView': 'View profession info: 5 coins',
      'statsView': 'View user statistics: 3 coins',
      'tournamentFees': 'Tournament participation fees',
      'premiumFilters': 'Premium filtering options',
      'purchaseSuccessful': 'Coin purchase successful!',
      'purchaseFailed': 'Coin purchase failed!',
      'logout': 'Logout',
      'logoutSubtitle': 'Secure logout from your account',
      'deleteAccount': 'Delete Account',
      'deleteAccountSubtitle': 'Permanently delete your account',
      'passwordReset': 'Reset Password',
      'passwordResetSubtitle': 'Reset password via email',
      'passwordResetSent': 'Password reset email sent!',
      'emailNotFound': 'Email address not found!',
      'logoutConfirm': 'Are you sure you want to logout?',
      'deleteAccountConfirm': 'Are you sure you want to delete your account?\nThis action cannot be undone!',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'logoutSuccess': 'Successfully logged out',
      'accountDeleted': 'Account successfully deleted',
      'profile': 'Profile',
      'leaderboard': 'Leaderboard',
      'tournament': 'Tournament',
      'settings': 'Settings',
      'profileSettings': 'Profile Settings',
      'userInfoNotLoaded': 'User information could not be loaded',
      'updateProfile': 'Update Profile',
      'profileUpdated': 'Profile updated!',
      'profileUpdateFailed': 'Error occurred while updating profile',
      'passwordResetTitle': 'Password Reset',
      'passwordResetMessage': 'A password reset link will be sent to your email address. Do you want to continue?',
      'send': 'Send',
      'dailyStreak': 'Daily Streak!',
      'coin': 'Coin',
      'totalMatches': 'Total Matches',
      'wins': 'Wins',
      'winRatePercentage': 'Win Rate',
      'currentStreak': 'Current Streak',
      'totalStreakDays': 'Total Streak Days',
      'predictionStats': 'Prediction Statistics',
      'totalPredictions': 'Total Predictions',
      'correctPredictions': 'Correct Predictions',
      'accuracy': 'Accuracy',
      'coinsEarnedFromPredictions': 'Coins Earned from Predictions',
      'matchHistory': 'Match History',
      'premiumFeatures': 'Premium Features',
      'viewInstagram': 'View Instagram',
      'viewProfession': 'View Profession',
      'viewStats': 'View Statistics',
      'cost': 'Cost',
      'insufficientCoins': 'Insufficient coins!',
      'selectImage': 'Select Image',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'imageUpdated': 'Image updated!',
      'imageUpdateFailed': 'Image update failed!',
      'editProfile': 'Edit Profile',
      'save': 'Save',
      'updateSuccessful': 'Update successful!',
      'updateFailed': 'Update failed!',
      'age': 'Age',
      'country': 'Country',
      'gender': 'Gender',
      'premiumInfoDescription': 'Other users can view this information by spending coins',
      'addInstagram': 'Add Instagram Account',
      'addProfession': 'Add Profession',
      'instagramAccount': 'Instagram Account',
      'profession': 'Profession',
      'addInfoDescription': 'You can use this feature by adding Instagram and profession information from settings',
      'joinTournament': 'Join Tournament',
      'leaveTournament': 'Leave Tournament',
      'tournamentJoined': 'Joined tournament!',
      'tournamentLeft': 'Left tournament!',
      'tournamentJoinFailed': 'Failed to join tournament!',
      'tournamentLeaveFailed': 'Failed to leave tournament!',
      'noTournamentsAvailable': 'No tournaments available to join',
      'tournamentDetails': 'Tournament Details',
      'participants': 'Participants',
      'prize': 'Prize',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'status': 'Status',
      'active': 'Active',
      'completed': 'Completed',
      'upcoming': 'Upcoming',
      'noMatchesFound': 'No matches found yet',
      'matchDetails': 'Match Details',
      'winner': 'Winner',
      'loser': 'Loser',
      'matchDate': 'Match Date',
      'tournamentName': 'Tournament Name',
    },
  };
  
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get username => _localizedValues[locale.languageCode]!['username']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get noAccount => _localizedValues[locale.languageCode]!['noAccount']!;
  String get alreadyHaveAccount => _localizedValues[locale.languageCode]!['alreadyHaveAccount']!;
  String get voting => _localizedValues[locale.languageCode]!['voting']!;
  String get whichDoYouPrefer => _localizedValues[locale.languageCode]!['whichDoYouPrefer']!;
  String predictWinRate(String username) => _localizedValues[locale.languageCode]!['predictWinRate']!.replaceAll('{username}', username);
  String get correctPrediction => _localizedValues[locale.languageCode]!['correctPrediction']!;
  String get submitPrediction => _localizedValues[locale.languageCode]!['submitPrediction']!;
  String get winRate => _localizedValues[locale.languageCode]!['winRate']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get turkish => _localizedValues[locale.languageCode]!['turkish']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get correctPredictionMessage => _localizedValues[locale.languageCode]!['correctPredictionMessage']!;
  String get wrongPredictionMessage => _localizedValues[locale.languageCode]!['wrongPredictionMessage']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get noMatchesAvailable => _localizedValues[locale.languageCode]!['noMatchesAvailable']!;
  String get allMatchesVoted => _localizedValues[locale.languageCode]!['allMatchesVoted']!;
  String get votingError => _localizedValues[locale.languageCode]!['votingError']!;
  String get coinPurchase => _localizedValues[locale.languageCode]!['coinPurchase']!;
  String get currentCoins => _localizedValues[locale.languageCode]!['currentCoins']!;
  String get coinPackages => _localizedValues[locale.languageCode]!['coinPackages']!;
  String get coinUsage => _localizedValues[locale.languageCode]!['coinUsage']!;
  String get instagramView => _localizedValues[locale.languageCode]!['instagramView']!;
  String get professionView => _localizedValues[locale.languageCode]!['professionView']!;
  String get statsView => _localizedValues[locale.languageCode]!['statsView']!;
  String get tournamentFees => _localizedValues[locale.languageCode]!['tournamentFees']!;
  String get premiumFilters => _localizedValues[locale.languageCode]!['premiumFilters']!;
  String get purchaseSuccessful => _localizedValues[locale.languageCode]!['purchaseSuccessful']!;
  String get purchaseFailed => _localizedValues[locale.languageCode]!['purchaseFailed']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get logoutSubtitle => _localizedValues[locale.languageCode]!['logoutSubtitle']!;
  String get deleteAccount => _localizedValues[locale.languageCode]!['deleteAccount']!;
  String get deleteAccountSubtitle => _localizedValues[locale.languageCode]!['deleteAccountSubtitle']!;
  String get passwordReset => _localizedValues[locale.languageCode]!['passwordReset']!;
  String get passwordResetSubtitle => _localizedValues[locale.languageCode]!['passwordResetSubtitle']!;
  String get passwordResetSent => _localizedValues[locale.languageCode]!['passwordResetSent']!;
  String get emailNotFound => _localizedValues[locale.languageCode]!['emailNotFound']!;
  String get logoutConfirm => _localizedValues[locale.languageCode]!['logoutConfirm']!;
  String get deleteAccountConfirm => _localizedValues[locale.languageCode]!['deleteAccountConfirm']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get logoutSuccess => _localizedValues[locale.languageCode]!['logoutSuccess']!;
  String get accountDeleted => _localizedValues[locale.languageCode]!['accountDeleted']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get leaderboard => _localizedValues[locale.languageCode]!['leaderboard']!;
  String get tournament => _localizedValues[locale.languageCode]!['tournament']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get profileSettings => _localizedValues[locale.languageCode]!['profileSettings']!;
  String get userInfoNotLoaded => _localizedValues[locale.languageCode]!['userInfoNotLoaded']!;
  String get updateProfile => _localizedValues[locale.languageCode]!['updateProfile']!;
  String get profileUpdated => _localizedValues[locale.languageCode]!['profileUpdated']!;
  String get profileUpdateFailed => _localizedValues[locale.languageCode]!['profileUpdateFailed']!;
  String get passwordResetTitle => _localizedValues[locale.languageCode]!['passwordResetTitle']!;
  String get passwordResetMessage => _localizedValues[locale.languageCode]!['passwordResetMessage']!;
  String get send => _localizedValues[locale.languageCode]!['send']!;
  String get dailyStreak => _localizedValues[locale.languageCode]!['dailyStreak']!;
  String get coin => _localizedValues[locale.languageCode]!['coin']!;
  String get totalMatches => _localizedValues[locale.languageCode]!['totalMatches']!;
  String get wins => _localizedValues[locale.languageCode]!['wins']!;
  String get winRatePercentage => _localizedValues[locale.languageCode]!['winRatePercentage']!;
  String get currentStreak => _localizedValues[locale.languageCode]!['currentStreak']!;
  String get totalStreakDays => _localizedValues[locale.languageCode]!['totalStreakDays']!;
  String get predictionStats => _localizedValues[locale.languageCode]!['predictionStats']!;
  String get totalPredictions => _localizedValues[locale.languageCode]!['totalPredictions']!;
  String get correctPredictions => _localizedValues[locale.languageCode]!['correctPredictions']!;
  String get accuracy => _localizedValues[locale.languageCode]!['accuracy']!;
  String get coinsEarnedFromPredictions => _localizedValues[locale.languageCode]!['coinsEarnedFromPredictions']!;
  String get matchHistory => _localizedValues[locale.languageCode]!['matchHistory']!;
  String get premiumFeatures => _localizedValues[locale.languageCode]!['premiumFeatures']!;
  String get viewInstagram => _localizedValues[locale.languageCode]!['viewInstagram']!;
  String get viewProfession => _localizedValues[locale.languageCode]!['viewProfession']!;
  String get viewStats => _localizedValues[locale.languageCode]!['viewStats']!;
  String get cost => _localizedValues[locale.languageCode]!['cost']!;
  String get insufficientCoins => _localizedValues[locale.languageCode]!['insufficientCoins']!;
  String get selectImage => _localizedValues[locale.languageCode]!['selectImage']!;
  String get camera => _localizedValues[locale.languageCode]!['camera']!;
  String get gallery => _localizedValues[locale.languageCode]!['gallery']!;
  String get imageUpdated => _localizedValues[locale.languageCode]!['imageUpdated']!;
  String get imageUpdateFailed => _localizedValues[locale.languageCode]!['imageUpdateFailed']!;
  String get editProfile => _localizedValues[locale.languageCode]!['editProfile']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get updateSuccessful => _localizedValues[locale.languageCode]!['updateSuccessful']!;
  String get updateFailed => _localizedValues[locale.languageCode]!['updateFailed']!;
  String get age => _localizedValues[locale.languageCode]!['age']!;
  String get country => _localizedValues[locale.languageCode]!['country']!;
  String get gender => _localizedValues[locale.languageCode]!['gender']!;
  String get premiumInfoDescription => _localizedValues[locale.languageCode]!['premiumInfoDescription']!;
  String get addInstagram => _localizedValues[locale.languageCode]!['addInstagram']!;
  String get addProfession => _localizedValues[locale.languageCode]!['addProfession']!;
  String get instagramAccount => _localizedValues[locale.languageCode]!['instagramAccount']!;
  String get profession => _localizedValues[locale.languageCode]!['profession']!;
  String get addInfoDescription => _localizedValues[locale.languageCode]!['addInfoDescription']!;
  String get joinTournament => _localizedValues[locale.languageCode]!['joinTournament']!;
  String get leaveTournament => _localizedValues[locale.languageCode]!['leaveTournament']!;
  String get tournamentJoined => _localizedValues[locale.languageCode]!['tournamentJoined']!;
  String get tournamentLeft => _localizedValues[locale.languageCode]!['tournamentLeft']!;
  String get tournamentJoinFailed => _localizedValues[locale.languageCode]!['tournamentJoinFailed']!;
  String get tournamentLeaveFailed => _localizedValues[locale.languageCode]!['tournamentLeaveFailed']!;
  String get noTournamentsAvailable => _localizedValues[locale.languageCode]!['noTournamentsAvailable']!;
  String get tournamentDetails => _localizedValues[locale.languageCode]!['tournamentDetails']!;
  String get participants => _localizedValues[locale.languageCode]!['participants']!;
  String get prize => _localizedValues[locale.languageCode]!['prize']!;
  String get startDate => _localizedValues[locale.languageCode]!['startDate']!;
  String get endDate => _localizedValues[locale.languageCode]!['endDate']!;
  String get status => _localizedValues[locale.languageCode]!['status']!;
  String get active => _localizedValues[locale.languageCode]!['active']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get upcoming => _localizedValues[locale.languageCode]!['upcoming']!;
  String get noMatchesFound => _localizedValues[locale.languageCode]!['noMatchesFound']!;
  String get matchDetails => _localizedValues[locale.languageCode]!['matchDetails']!;
  String get winner => _localizedValues[locale.languageCode]!['winner']!;
  String get loser => _localizedValues[locale.languageCode]!['loser']!;
  String get matchDate => _localizedValues[locale.languageCode]!['matchDate']!;
  String get tournamentName => _localizedValues[locale.languageCode]!['tournamentName']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}