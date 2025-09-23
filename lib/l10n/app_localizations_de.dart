// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Chizo';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get username => 'Benutzername';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get age => 'Alter';

  @override
  String get country => 'Land';

  @override
  String get gender => 'Geschlecht';

  @override
  String get male => 'Männlich';

  @override
  String get female => 'Weiblich';

  @override
  String get instagramHandle => 'Instagram Benutzername';

  @override
  String get profession => 'Beruf';

  @override
  String get voting => 'Abstimmung';

  @override
  String get whichDoYouPrefer => 'Welches bevorzugen Sie?';

  @override
  String predictWinRate(String username) {
    return '${username}s Gewinnrate vorhersagen';
  }

  @override
  String get correctPrediction => 'Richtige Vorhersage = 1 Münze';

  @override
  String get submitPrediction => 'Vorhersage absenden';

  @override
  String get winRate => 'Gewinnrate';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get leaderboard => '🏆 Bestenliste';

  @override
  String get tournament => 'Turnier';

  @override
  String get language => 'Sprache';

  @override
  String get turkish => 'Türkisch';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get coins => 'Münzen';

  @override
  String get totalMatches => 'Gesamt-Matches';

  @override
  String get wins => 'Gewinne';

  @override
  String get winRatePercentage => 'Gewinnrate';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get totalStreakDays => 'Gesamte Serientage';

  @override
  String get predictionStats => 'Vorhersage-Statistiken';

  @override
  String get totalPredictions => 'Gesamt-Vorhersagen';

  @override
  String get correctPredictions => 'Richtige Vorhersagen';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String coinsEarnedFromPredictions(int coins) {
    return 'Durch Vorhersagen verdiente Coins: $coins';
  }

  @override
  String get congratulations => 'Glückwunsch!';

  @override
  String get correctPredictionMessage =>
      'Sie haben richtig vorhergesagt und 1 Münze verdient!';

  @override
  String wrongPredictionMessage(double winRate) {
    return 'Falsche Vorhersage. Die tatsächliche Gewinnrate war $winRate%';
  }

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get loading => 'Laden...';

  @override
  String get noMatchesAvailable => 'Keine Matches zum Abstimmen verfügbar';

  @override
  String get allMatchesVoted =>
      'Alle Matches abgestimmt!\nWarten auf neue Matches...';

  @override
  String get usernameCannotBeEmpty => 'Benutzername darf nicht leer sein';

  @override
  String get emailCannotBeEmpty => 'E-Mail darf nicht leer sein';

  @override
  String get passwordCannotBeEmpty => 'Passwort darf nicht leer sein';

  @override
  String get passwordMinLength => 'Passwort muss mindestens 6 Zeichen haben';

  @override
  String get registrationSuccessful => 'Registrierung erfolgreich!';

  @override
  String get userAlreadyExists =>
      'Dieser Benutzer ist bereits registriert oder ein Fehler ist aufgetreten';

  @override
  String get loginSuccessful => 'Anmeldung erfolgreich!';

  @override
  String get loginError => 'Anmeldefehler: Unbekannter Fehler';

  @override
  String get dontHaveAccount => 'Haben Sie kein Konto? ';

  @override
  String get registerNow => 'Jetzt registrieren';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto? ';

  @override
  String get loginNow => 'Jetzt anmelden';

  @override
  String get allPhotoSlotsFull => 'Alle zusätzlichen Foto-Slots sind voll!';

  @override
  String photoUploadSlot(int slot) {
    return 'Foto hochladen - Slot $slot';
  }

  @override
  String coinsRequiredForSlot(int coins) {
    return 'Dieser Slot benötigt $coins Coins.';
  }

  @override
  String currentCoins(int coins) {
    return 'Aktuelle Coins: $coins';
  }

  @override
  String get insufficientCoinsForUpload =>
      'Unzureichende Coins! Verwenden Sie die Coin-Schaltfläche auf der Profilseite, um Coins zu kaufen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String upload(int coins) {
    return 'Hochladen ($coins Coins)';
  }

  @override
  String photoUploaded(int coinsSpent) {
    return 'Foto hochgeladen! $coinsSpent Coins ausgegeben.';
  }

  @override
  String get deletePhoto => 'Foto löschen';

  @override
  String get confirmDeletePhoto =>
      'Sind Sie sicher, dass Sie dieses Foto löschen möchten?';

  @override
  String get delete => 'Löschen';

  @override
  String get photoDeleted => 'Foto gelöscht!';

  @override
  String get selectFromGallery => 'Aus Galerie auswählen';

  @override
  String get takeFromCamera => 'Mit Kamera aufnehmen';

  @override
  String get additionalMatchPhotos => 'Zusätzliche Match-Fotos';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String additionalPhotosDescription(int count) {
    return 'Zusätzliche Fotos, die in Matches angezeigt werden ($count/4)';
  }

  @override
  String get noAdditionalPhotos => 'Noch keine zusätzlichen Fotos';

  @override
  String get secondPhotoCost => '2. Foto kostet 50 Coins!';

  @override
  String get premiumInfoAdded =>
      'Ihre Premium-Informationen wurden hinzugefügt! Sie können die Sichtbarkeitseinstellungen unten anpassen.';

  @override
  String get premiumInfoVisibility => 'Premium-Info-Sichtbarkeit';

  @override
  String get premiumInfoDescription =>
      'Andere Benutzer können diese Informationen durch Ausgeben von Coins einsehen';

  @override
  String get instagramAccount => 'Instagram-Konto';

  @override
  String get statistics => 'Statistiken';

  @override
  String get predictionStatistics => 'Vorhersage-Statistiken';

  @override
  String get matchHistory => 'Match-Verlauf';

  @override
  String get viewLastFiveMatches =>
      'Ihre letzten 5 Matches und Gegner anzeigen (5 Coins)';

  @override
  String get visibleInMatches => 'In Matches sichtbar';

  @override
  String get nowVisibleInMatches => 'Sie werden jetzt in Matches angezeigt!';

  @override
  String get removedFromMatches => 'Sie wurden aus Matches entfernt!';

  @override
  String addInfo(String type) {
    return '$type hinzufügen';
  }

  @override
  String enterInfo(String type) {
    return 'Geben Sie Ihre $type-Informationen ein:';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String infoAdded(String type) {
    return '✅ $type-Information hinzugefügt!';
  }

  @override
  String get errorAddingInfo => '❌ Fehler beim Hinzufügen der Informationen!';

  @override
  String get matchInfoNotLoaded =>
      'Match-Informationen konnten nicht geladen werden';

  @override
  String premiumInfo(String type) {
    return 'Premium-Informationen';
  }

  @override
  String get spendFiveCoins => '5 Münzen ausgeben';

  @override
  String get insufficientCoins => '❌ Unzureichende Münzen!';

  @override
  String get fiveCoinsSpent => '✅ 5 Münzen ausgegeben';

  @override
  String get ok => 'OK';

  @override
  String matchCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get spendFiveCoinsToView =>
      'Sie werden 5 Münzen ausgeben, um diese Information zu sehen';

  @override
  String get great => 'Großartig!';

  @override
  String get homePage => 'Startseite';

  @override
  String streakMessage(int days) {
    return '$days Tage Serie!';
  }

  @override
  String get purchaseCoins => 'Münzen kaufen';

  @override
  String get watchAd => 'Werbung ansehen';

  @override
  String get dailyAdLimit => 'Sie können maximal 5 Werbespots pro Tag ansehen';

  @override
  String get coinsPerAd => 'Münzen pro Werbung: 20';

  @override
  String get watchAdButton => 'Werbung ansehen';

  @override
  String get dailyLimitReached => 'Tageslimit erreicht';

  @override
  String get recentTransactions => 'Letzte Transaktionen:';

  @override
  String get noTransactionHistory => 'Noch keine Transaktionshistorie';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirmation =>
      'Sind Sie sicher, dass Sie sich von Ihrem Konto abmelden möchten?';

  @override
  String logoutError(String error) {
    return 'Fehler beim Abmelden aufgetreten: $error';
  }

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountConfirmation =>
      'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden und alle Ihre Daten werden dauerhaft gelöscht.';

  @override
  String get finalConfirmation => 'Endgültige Bestätigung';

  @override
  String get typeDeleteToConfirm =>
      'Um Ihr Konto zu löschen, geben Sie \"LÖSCHEN\" ein:';

  @override
  String get pleaseTypeDelete => 'Bitte geben Sie \"LÖSCHEN\" ein!';

  @override
  String get accountDeletedSuccessfully =>
      'Ihr Konto wurde erfolgreich gelöscht!';

  @override
  String errorDeletingAccount(String error) {
    return 'Fehler beim Löschen des Kontos aufgetreten: $error';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Fehler beim Ansehen der Werbung aufgetreten: $error';
  }

  @override
  String get watchingAd => 'Werbung wird angesehen';

  @override
  String get adLoading => 'Werbung wird geladen...';

  @override
  String get adSimulation =>
      'Dies ist eine simulierte Werbung. In der echten App würde hier eine echte Werbung angezeigt werden.';

  @override
  String get adWatched => 'Werbung angesehen! +20 Münzen verdient!';

  @override
  String get errorAddingCoins =>
      'Fehler beim Hinzufügen von Münzen aufgetreten';

  @override
  String get buy => 'Kaufen';

  @override
  String get predict => 'Vorhersagen';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ 5 Münzen ausgegeben! Ihr Match-Verlauf wird angezeigt.';

  @override
  String get insufficientCoinsForHistory => '❌ Unzureichende Münzen!';

  @override
  String get spendFiveCoinsForHistory => '5 Münzen ausgeben';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins Siege • $matches Matches';
  }

  @override
  String get insufficientCoinsForTournament => 'Unzureichende Münzen!';

  @override
  String get joinedTournament => 'Turnier beigetreten!';

  @override
  String get tournamentJoinFailed => 'Beitritt zum Turnier fehlgeschlagen!';

  @override
  String get dailyStreak => 'Tägliche Serie!';

  @override
  String get imageUpdated => 'Bild aktualisiert!';

  @override
  String get updateFailed => 'Aktualisierung fehlgeschlagen!';

  @override
  String get imageUpdateFailed => 'Bildaktualisierung fehlgeschlagen!';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get userInfoNotLoaded =>
      'Benutzerinformationen konnten nicht geladen werden';

  @override
  String get coin => 'Münze';

  @override
  String get premiumFeatures => 'Premium-Features';

  @override
  String get addInstagram => 'Instagram-Konto hinzufügen';

  @override
  String get addProfession => 'Beruf hinzufügen';

  @override
  String get profileUpdated => 'Profil aktualisiert!';

  @override
  String get profileUpdateFailed => 'Fehler beim Aktualisieren des Profils';

  @override
  String get profileSettings => 'Profileinstellungen';

  @override
  String get passwordReset => 'Passwort zurücksetzen';

  @override
  String get passwordResetSubtitle => 'Passwort per E-Mail zurücksetzen';

  @override
  String get logoutSubtitle => 'Sichere Abmeldung von Ihrem Konto';

  @override
  String get deleteAccountSubtitle => 'Ihr Konto dauerhaft löschen';

  @override
  String get updateProfile => 'Profil aktualisieren';

  @override
  String get passwordResetTitle => 'Passwort zurücksetzen';

  @override
  String get passwordResetMessage =>
      'Ein Passwort-Reset-Link wird an Ihre E-Mail-Adresse gesendet. Möchten Sie fortfahren?';

  @override
  String get send => 'Senden';

  @override
  String get passwordResetSent => 'Passwort-Reset-E-Mail gesendet!';

  @override
  String get emailNotFound => 'E-Mail-Adresse nicht gefunden!';

  @override
  String get votingError => 'Fehler beim Abstimmungsvorgang';

  @override
  String slot(Object slot) {
    return 'Slot $slot';
  }

  @override
  String get instagramAdded => 'Instagram-Information hinzugefügt!';

  @override
  String get professionAdded => 'Berufsinformation hinzugefügt!';

  @override
  String get addInstagramFromSettings =>
      'Sie können diese Funktion nutzen, indem Sie Instagram- und Berufsinformationen aus den Einstellungen hinzufügen';
}
