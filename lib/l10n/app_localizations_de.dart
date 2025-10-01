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
  String predictUserWinRate(String username) {
    return '${username}s Gewinnrate vorhersagen';
  }

  @override
  String get correctPrediction => 'Richtige Vorhersage = 1 Münze';

  @override
  String get submitPrediction => 'Vorhersage absenden';

  @override
  String get winRate => 'Siegesrate';

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
  String get spanish => 'Spanisch';

  @override
  String get turkishLanguage => 'Türkisch';

  @override
  String get englishLanguage => 'Englisch';

  @override
  String get germanLanguage => 'Deutsch';

  @override
  String get coins => 'Münzen';

  @override
  String get totalMatches => 'Gesamte Matches';

  @override
  String get wins => 'Siege';

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
  String get correctPredictionWithReward =>
      'Sie haben richtig vorhergesagt und 1 Münze verdient!';

  @override
  String wrongPredictionWithRate(double winRate) {
    return 'Falsche Vorhersage. Die tatsächliche Gewinnrate war $winRate%';
  }

  @override
  String get error => 'Fehler';

  @override
  String get invalidEmail =>
      '❌ Ungültige E-Mail-Adresse! Bitte geben Sie eine gültige E-Mail-Format ein.';

  @override
  String get userNotFoundError =>
      '❌ Kein Benutzer mit dieser E-Mail-Adresse gefunden!';

  @override
  String get userAlreadyRegistered =>
      '❌ Diese E-Mail-Adresse ist bereits registriert! Versuchen Sie sich anzumelden.';

  @override
  String get invalidPassword =>
      '❌ Falsches Passwort! Bitte überprüfen Sie Ihr Passwort.';

  @override
  String get passwordMinLengthError =>
      '❌ Passwort muss mindestens 6 Zeichen haben!';

  @override
  String get passwordTooWeak =>
      '❌ Passwort ist zu schwach! Wählen Sie ein stärkeres Passwort.';

  @override
  String get usernameAlreadyTaken =>
      '❌ Dieser Benutzername ist bereits vergeben! Wählen Sie einen anderen Benutzernamen.';

  @override
  String get usernameTooShort =>
      '❌ Benutzername muss mindestens 3 Zeichen haben!';

  @override
  String get networkError => '❌ Überprüfen Sie Ihre Internetverbindung!';

  @override
  String get timeoutError =>
      '❌ Verbindungszeitüberschreitung! Bitte versuchen Sie es erneut.';

  @override
  String get emailNotConfirmed =>
      '❌ Sie müssen Ihre E-Mail-Adresse bestätigen!';

  @override
  String get tooManyRequests =>
      '❌ Zu viele Versuche! Bitte warten Sie ein paar Minuten und versuchen Sie es erneut.';

  @override
  String get accountDisabled => '❌ Ihr Konto wurde deaktiviert!';

  @override
  String get accountDeletedPleaseRegister =>
      '❌ Ihr Konto wurde gelöscht. Bitte erstellen Sie ein neues Konto.';

  @override
  String get duplicateData =>
      '❌ Diese Informationen werden bereits verwendet! Versuchen Sie andere Informationen.';

  @override
  String get invalidData =>
      '❌ Es gibt einen Fehler in den eingegebenen Informationen! Bitte überprüfen Sie.';

  @override
  String get invalidCredentials => '❌ E-Mail oder Passwort ist falsch!';

  @override
  String get tooManyEmails => '❌ Zu viele E-Mails gesendet! Bitte warten Sie.';

  @override
  String get operationFailed =>
      '❌ Vorgang fehlgeschlagen! Bitte überprüfen Sie Ihre Informationen.';

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
    return 'Foto hochgeladen';
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
  String get matchHistory => '📊 Match-Verlauf';

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
    return '💎 $type Informationen';
  }

  @override
  String get spendFiveCoins => '5 Münzen ausgeben';

  @override
  String get insufficientCoins => '❌ Nicht genügend Münzen!';

  @override
  String get fiveCoinsSpent => '✅ 5 Coins ausgegeben';

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
  String get purchaseCoins => 'Coins kaufen';

  @override
  String get watchAd => 'Werbung ansehen';

  @override
  String get dailyAdLimit => 'Sie können maximal 5 Werbungen pro Tag ansehen';

  @override
  String get coinsPerAd => 'Coins pro Werbung: 20';

  @override
  String get watchAdButton => 'Werbung ansehen';

  @override
  String get dailyLimitReached => 'Tageslimit erreicht';

  @override
  String get recentTransactions => 'Letzte Transaktionen:';

  @override
  String get noTransactionHistory => 'Noch keine Transaktionshistorie';

  @override
  String get accountSettings => 'Konto-Einstellungen';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirmation =>
      'Sind Sie sicher, dass Sie sich von Ihrem Konto abmelden möchten?';

  @override
  String logoutError(String error) {
    return 'Fehler beim Abmelden';
  }

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountConfirmation =>
      'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden und alle Ihre Daten werden dauerhaft gelöscht.';

  @override
  String get finalConfirmation => 'Letzte Bestätigung';

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
    return 'Fehler beim Löschen des Kontos';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Fehler beim Ansehen der Werbung';
  }

  @override
  String get watchingAd => 'Werbung wird angesehen';

  @override
  String get adLoading => 'Werbung wird geladen...';

  @override
  String get adSimulation =>
      'Dies ist eine simulierte Werbung. In der echten App wird hier eine echte Werbung angezeigt.';

  @override
  String get adWatched => 'Werbung angesehen! +20 Coins verdient!';

  @override
  String get errorAddingCoins => 'Fehler beim Hinzufügen von Coins';

  @override
  String get buy => 'Kaufen';

  @override
  String get predict => 'Vorhersagen';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ 5 Coins ausgegeben! Ihr Match-Verlauf wird angezeigt.';

  @override
  String get insufficientCoinsForHistory => '❌ Unzureichende Münzen!';

  @override
  String get spendFiveCoinsForHistory =>
      'Geben Sie 5 Coins aus, um Ihre letzten 5 Matches und Gegner zu sehen';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins Siege • $matches Matches';
  }

  @override
  String get insufficientCoinsForTournament =>
      'Nicht genügend Coins für Turnier!';

  @override
  String get joinedTournament => 'Sie sind dem Turnier beigetreten!';

  @override
  String get tournamentJoinFailed => 'Turnier-Beitritt fehlgeschlagen!';

  @override
  String get dailyStreak => 'Tägliche Serie!';

  @override
  String get imageUpdated => 'Bild aktualisiert!';

  @override
  String get updateFailed => 'Aktualisierung fehlgeschlagen';

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
  String votingError(Object error) {
    return 'Fehler während der Abstimmung: $error';
  }

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

  @override
  String get basicInfo => 'Grundinformationen';

  @override
  String get premiumInfoSettings => 'Premium-Informationen';

  @override
  String get premiumInfoDescriptionSettings =>
      'Andere Benutzer können diese Informationen durch Ausgeben von Coins einsehen';

  @override
  String get coinInfo => 'Coin-Informationen';

  @override
  String currentCoins(int coins) {
    return 'Aktuelle Coins';
  }

  @override
  String get remaining => 'Verbleibend';

  @override
  String get vs => 'VS';

  @override
  String get coinPurchase => 'Coins kaufen';

  @override
  String get purchaseSuccessful => 'Kauf erfolgreich!';

  @override
  String get purchaseFailed => 'Kauf fehlgeschlagen!';

  @override
  String get coinPackages => 'Coin-Pakete';

  @override
  String get coinUsage => 'Coin-Verwendung';

  @override
  String get instagramView => 'Instagram-Konten anzeigen';

  @override
  String get professionView => 'Berufsinformationen anzeigen';

  @override
  String get statsView => 'Detaillierte Statistiken anzeigen';

  @override
  String get tournamentFees => 'Turnier-Teilnahmegebühren';

  @override
  String get weeklyMaleTournament1000 =>
      'Wöchentliches Männerturnier (1000 Münzen)';

  @override
  String get weeklyMaleTournament1000Desc =>
      'Wöchentliches Männerturnier - 300 Personen Kapazität';

  @override
  String get weeklyMaleTournament10000 =>
      'Wöchentliches Männerturnier (10000 Münzen)';

  @override
  String get weeklyMaleTournament10000Desc =>
      'Premium Männerturnier - 100 Personen Kapazität';

  @override
  String get weeklyFemaleTournament1000 =>
      'Wöchentliches Frauenturnier (1000 Münzen)';

  @override
  String get weeklyFemaleTournament1000Desc =>
      'Wöchentliches Frauenturnier - 300 Personen Kapazität';

  @override
  String get weeklyFemaleTournament10000 =>
      'Wöchentliches Frauenturnier (10000 Münzen)';

  @override
  String get weeklyFemaleTournament10000Desc =>
      'Premium Frauenturnier - 100 Personen Kapazität';

  @override
  String get tournamentEntryFee => 'Turnier-Teilnahmegebühr';

  @override
  String get tournamentVotingTitle => 'Turnier-Abstimmung';

  @override
  String get tournamentThirdPlace => 'Turnier 3. Platz';

  @override
  String get tournamentWon => 'Turnier gewonnen';

  @override
  String get userNotLoggedIn => 'Benutzer nicht angemeldet';

  @override
  String get userNotFound => 'Benutzer nicht gefunden';

  @override
  String get firstLoginReward =>
      '🎉 Erster Login! Sie haben 50 Münzen verdient!';

  @override
  String streakReward(Object coins, Object streak) {
    return '🔥 $streak Tage Streak! Sie haben $coins Münzen verdient!';
  }

  @override
  String get streakBroken =>
      '💔 Streak unterbrochen! Neuer Start: Sie haben 50 Münzen verdient!';

  @override
  String dailyStreakReward(Object streak) {
    return 'Tägliche Streak-Belohnung ($streak Tage)';
  }

  @override
  String get alreadyLoggedInToday => 'Sie haben sich heute bereits angemeldet!';

  @override
  String get streakCheckError => 'Fehler beim Streak-Check aufgetreten';

  @override
  String get streakInfoError =>
      'Streak-Informationen konnten nicht abgerufen werden';

  @override
  String get correctPredictionReward =>
      'Sie verdienen 1 Coin für eine richtige Vorhersage!';

  @override
  String get wrongPredictionMessage => 'Leider haben Sie falsch vorhergesagt.';

  @override
  String get predictionSaveError =>
      'Fehler beim Speichern der Vorhersage aufgetreten';

  @override
  String get coinAddError => 'Fehler beim Hinzufügen von Münzen aufgetreten';

  @override
  String coinPurchaseTransaction(Object description) {
    return 'Münzen-Kauf - $description';
  }

  @override
  String get whiteThemeName => 'Weiß';

  @override
  String get darkThemeName => 'Dunkel';

  @override
  String get pinkThemeName => 'Rosa';

  @override
  String get premiumFilters => 'Premium-Filter';

  @override
  String get viewStats => 'Statistiken anzeigen';

  @override
  String get photoStats => 'Foto-Statistiken';

  @override
  String get photoStatsCost =>
      'Das Anzeigen von Foto-Statistiken kostet 50 Coins';

  @override
  String get insufficientCoinsForStats =>
      'Unzureichende Coins zum Anzeigen von Foto-Statistiken. Erforderlich: 50 Coins';

  @override
  String get pay => 'Bezahlen';

  @override
  String get tournamentVotingSaved => '🏆 Turnier-Abstimmung gespeichert!';

  @override
  String get tournamentVotingFailed => '❌ Turnier-Abstimmung fehlgeschlagen!';

  @override
  String get tournamentVoting => '🏆 TURNIER-ABSTIMMUNG';

  @override
  String get whichTournamentParticipant =>
      'Welchen Turnier-Teilnehmer bevorzugen Sie?';

  @override
  String ageYears(Object age, Object country) {
    return '$age Jahre • $country';
  }

  @override
  String get clickToOpenInstagram => '📱 Klicken Sie, um Instagram zu öffnen';

  @override
  String get openInstagram => 'Instagram öffnen';

  @override
  String get instagramCannotBeOpened =>
      '❌ Instagram konnte nicht geöffnet werden. Bitte überprüfen Sie Ihre Instagram-App.';

  @override
  String instagramOpenError(Object error) {
    return '❌ Fehler beim Öffnen von Instagram: $error';
  }

  @override
  String get tournamentPhoto => '🏆 Turnier-Foto';

  @override
  String get tournamentJoinedUploadPhoto =>
      'Sie sind dem Turnier beigetreten! Laden Sie jetzt Ihr Turnier-Foto hoch.';

  @override
  String get uploadLater => 'Später hochladen';

  @override
  String get uploadPhoto => 'Foto hochladen';

  @override
  String get tournamentPhotoUploaded => '✅ Turnier-Foto hochgeladen!';

  @override
  String get photoUploadError => '❌ Fehler beim Hochladen des Fotos!';

  @override
  String get noVotingForTournament =>
      'Keine Abstimmung für dieses Turnier gefunden';

  @override
  String votingLoadError(Object error) {
    return 'Fehler beim Laden der Abstimmung: $error';
  }

  @override
  String get whichParticipantPrefer => 'Welchen Teilnehmer bevorzugen Sie?';

  @override
  String get voteSavedSuccessfully =>
      'Ihre Stimme wurde erfolgreich gespeichert!';

  @override
  String get noActiveTournament => 'Derzeit kein aktives Turnier';

  @override
  String get registration => 'Anmeldung';

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String coinPrize(Object prize) {
    return '$prize Coin-Preis';
  }

  @override
  String startDate(Object date) {
    return 'Start: $date';
  }

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get join => 'Beitreten';

  @override
  String get photo => 'Foto';

  @override
  String get languageChanged => 'Sprache geändert. Seite wird aktualisiert...';

  @override
  String get lightWhiteTheme => 'Weißes Material helles Theme';

  @override
  String get neutralDarkGrayTheme => 'Neutrales dunkelgraues Theme';

  @override
  String themeChanged(Object theme) {
    return 'Theme geändert: $theme';
  }

  @override
  String get deleteAccountWarning =>
      'Diese Aktion kann nicht rückgängig gemacht werden! Alle Ihre Daten werden dauerhaft gelöscht.\nSind Sie sicher, dass Sie Ihr Konto löschen möchten?';

  @override
  String get accountDeleted => 'Ihr Konto wurde gelöscht';

  @override
  String get logoutButton => 'Abmelden';

  @override
  String get themeSelection => '🎨 Theme-Auswahl';

  @override
  String get darkMaterialTheme => 'Schwarzes Material dunkles Theme';

  @override
  String get lightPinkTheme => 'Helles rosa Farb-Theme';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get allNotifications => 'Alle Benachrichtigungen';

  @override
  String get allNotificationsSubtitle =>
      'Hauptbenachrichtigungen ein/ausschalten';

  @override
  String get voteReminder => 'Abstimmungserinnerung';

  @override
  String get winCelebration => 'Gewinn-Feier';

  @override
  String get streakReminder => 'Serien-Erinnerung';

  @override
  String get streakReminderSubtitle => 'Tägliche Serien-Belohnungserinnerungen';

  @override
  String get moneyAndCoins => '💰 Geld & Coin-Transaktionen';

  @override
  String get purchaseCoinPackage => 'Coin-Paket kaufen';

  @override
  String get purchaseCoinPackageSubtitle =>
      'Coins kaufen und Belohnungen verdienen';

  @override
  String get appSettings => '⚙️ App-Einstellungen';

  @override
  String get dailyRewards => 'Tägliche Belohnungen';

  @override
  String get dailyRewardsSubtitle => 'Serien-Belohnungen und Boosts anzeigen';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get accountOperations => '👤 Konto-Operationen';

  @override
  String get dailyStreakRewards => 'Tägliche Serien-Belohnungen';

  @override
  String get dailyStreakDescription =>
      '🎯 Melden Sie sich jeden Tag in der App an und verdienen Sie Boni!';

  @override
  String get appDescription => 'Abstimmungs- und Turnier-App in Chaträumen.';

  @override
  String get predictWinRateTitle => 'Gewinnrate vorhersagen!';

  @override
  String get wrongPredictionNoCoin => 'Falsche Vorhersage = 0 Coins';

  @override
  String get selectWinRateRange => 'Gewinnrate-Bereich wählen:';

  @override
  String get wrongPrediction => 'Falsche Vorhersage';

  @override
  String get correctPredictionMessage => 'Sie haben richtig vorhergesagt!';

  @override
  String actualRate(Object rate) {
    return 'Tatsächliche Rate: $rate%';
  }

  @override
  String get earnedOneCoin => '+1 Coin verdient!';

  @override
  String myPhotos(Object count) {
    return 'Meine Fotos ($count/5)';
  }

  @override
  String get photoCostInfo =>
      'Das erste Foto ist kostenlos, andere kosten Coins. Sie können Statistiken für alle Fotos anzeigen.';

  @override
  String get addAge => 'Alter hinzufügen';

  @override
  String get addCountry => 'Land hinzufügen';

  @override
  String get addGender => 'Geschlecht hinzufügen';

  @override
  String get countrySelection => 'Länderauswahl';

  @override
  String countriesSelected(Object count) {
    return '$count Länder ausgewählt';
  }

  @override
  String get allCountriesSelected => 'Alle Länder ausgewählt';

  @override
  String get ageRangeSelection => 'Altersbereich-Auswahl';

  @override
  String ageRangesSelected(Object count) {
    return '$count Altersbereiche ausgewählt';
  }

  @override
  String get allAgeRangesSelected => 'Alle Altersbereiche ausgewählt';

  @override
  String get editUsername => 'Benutzername bearbeiten';

  @override
  String get enterUsername => 'Geben Sie Ihren Benutzernamen ein';

  @override
  String get editAge => 'Alter bearbeiten';

  @override
  String get enterAge => 'Geben Sie Ihr Alter ein';

  @override
  String get selectCountry => 'Land wählen';

  @override
  String get selectYourCountry => 'Wählen Sie Ihr Land';

  @override
  String get selectGender => 'Geschlecht wählen';

  @override
  String get selectYourGender => 'Wählen Sie Ihr Geschlecht';

  @override
  String get editInstagram => 'Instagram-Konto bearbeiten';

  @override
  String get enterInstagram =>
      'Geben Sie Ihren Instagram-Benutzernamen ein (ohne @)';

  @override
  String get editProfession => 'Beruf bearbeiten';

  @override
  String get enterProfession => 'Geben Sie Ihren Beruf ein';

  @override
  String get infoUpdated => 'Informationen aktualisiert';

  @override
  String get countryPreferencesUpdated => '✅ Länderpräferenzen aktualisiert';

  @override
  String get countryPreferencesUpdateFailed =>
      '❌ Länderpräferenzen konnten nicht aktualisiert werden';

  @override
  String get ageRangePreferencesUpdated =>
      '✅ Altersbereich-Präferenzen aktualisiert';

  @override
  String get ageRangePreferencesUpdateFailed =>
      '❌ Altersbereich-Präferenzen konnten nicht aktualisiert werden';

  @override
  String winRateAndMatches(Object matches, Object winRate) {
    return '$winRate Gewinnrate • $matches Matches';
  }

  @override
  String get mostWins => 'Meiste Siege';

  @override
  String get highestWinRate => 'Höchste Gewinnrate';

  @override
  String get noWinsYet =>
      'Noch keine Siege!\nSpielen Sie Ihr erstes Match und treten Sie der Bestenliste bei!';

  @override
  String get noWinRateYet =>
      'Noch keine Gewinnrate!\nSpielen Sie Matches, um Ihre Gewinnrate zu erhöhen!';

  @override
  String get matchHistoryViewing => 'Match-Verlauf anzeigen';

  @override
  String winRateColon(Object winRate) {
    return 'Gewinnrate: $winRate';
  }

  @override
  String matchesAndWins(Object matches, Object wins) {
    return '$matches Matches • $wins Siege';
  }

  @override
  String get youWon => 'Sie haben gewonnen';

  @override
  String get youLost => 'Sie haben verloren';

  @override
  String get lastFiveMatchStats => '📊 Letzte 5 Match-Statistiken';

  @override
  String get noMatchHistoryYet =>
      'Noch kein Match-Verlauf!\nSpielen Sie Ihr erstes Match!';

  @override
  String get premiumFeature => '🔒 Premium-Feature';

  @override
  String get save => 'Speichern';

  @override
  String get leaderboardTitle => '🏆 Bestenliste';

  @override
  String get day1_2Reward => 'Tag 1-2: 10-25 Coin';

  @override
  String get day3_6Reward => 'Tag 3-6: 50-100 Coin';

  @override
  String get day7PlusReward => 'Tag 7+: 200+ Coin & Boost';

  @override
  String get photoStatsLoadError =>
      'Fotostatistiken konnten nicht geladen werden';

  @override
  String get tournamentNotifications => 'Turnier-Benachrichtigungen';

  @override
  String get newTournamentInvitations => 'Neue Turnier-Einladungen';

  @override
  String get victoryNotifications => 'Sieges-Benachrichtigungen';

  @override
  String get vote => 'Abstimmen';

  @override
  String get lastFiveMatches => 'Letzte 5 Spiele';

  @override
  String get total => 'Gesamt';

  @override
  String get losses => 'Niederlagen';

  @override
  String get rate => 'Rate';

  @override
  String get ongoing => 'Laufend';

  @override
  String get tournamentFull => 'Turnier Voll';

  @override
  String get active => 'Aktiv';

  @override
  String get joinWithKey => 'Mit Schlüssel beitreten';

  @override
  String get private => 'Privat';

  @override
  String get countryRanking => 'Länder-Ranking';

  @override
  String get countryRankingSubtitle =>
      'Wie erfolgreich sind Sie gegen Bürger verschiedener Länder';

  @override
  String get countryRankingTitle => 'Länder-Ranking';

  @override
  String get countryRankingDescription =>
      'Wie erfolgreich sind Sie gegen Bürger verschiedener Länder';

  @override
  String get winsAgainst => 'Siege';

  @override
  String get lossesAgainst => 'Niederlagen';

  @override
  String get winRateAgainst => 'Gewinnrate';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get loadingCountryStats => 'Länder-Statistiken werden geladen...';

  @override
  String get countryStats => 'Länder-Statistiken';

  @override
  String get yourPerformance => 'Ihre Leistung';

  @override
  String get againstCountry => 'Länder-Vergleich';

  @override
  String get retry => 'Wiederholen';

  @override
  String get alreadyJoinedTournament =>
      'Sie sind diesem Turnier bereits beigetreten';

  @override
  String get uploadTournamentPhoto => 'Turnier-Foto hochladen';

  @override
  String get viewTournament => 'Turnier anzeigen';

  @override
  String get tournamentParticipants => 'Turnier-Teilnehmer';

  @override
  String get yourRank => 'Ihr Rang';

  @override
  String get rank => 'Rang';

  @override
  String get participant => 'Teilnehmer';

  @override
  String get photoNotUploaded => 'Foto nicht hochgeladen';

  @override
  String get uploadPhotoUntilWednesday =>
      'Sie können das Foto bis Mittwoch hochladen';

  @override
  String get tournamentStarted => 'Turnier gestartet';

  @override
  String get viewTournamentPhotos => 'Turnier-Fotos anzeigen';

  @override
  String get genderMismatch => 'Geschlecht stimmt nicht überein';

  @override
  String get photoAlreadyUploaded => 'Foto bereits hochgeladen';

  @override
  String get viewParticipantPhoto => 'Teilnehmer-Foto anzeigen';

  @override
  String get selectPhoto => 'Foto auswählen';

  @override
  String get photoUploadFailed => 'Foto-Upload fehlgeschlagen';

  @override
  String get tournamentCancelled => 'Turnier abgebrochen';

  @override
  String get refundFailed => 'Rückerstattung fehlgeschlagen';

  @override
  String get createPrivateTournament => 'Privates Turnier erstellen';

  @override
  String get tournamentName => 'Turnier-Name';

  @override
  String get maxParticipants => 'Maximale Teilnehmer';

  @override
  String get tournamentFormat => 'Turnier-Format';

  @override
  String get leagueFormat => 'Liga-Format';

  @override
  String get eliminationFormat => 'K.O.-Format';

  @override
  String get hybridFormat => 'Liga + K.O.';

  @override
  String get eliminationMaxParticipants =>
      'Maximal 8 Teilnehmer für K.O.-Format';

  @override
  String get eliminationMaxParticipantsWarning =>
      'Maximal 8 Teilnehmer für K.O.-Format erlaubt';

  @override
  String get weeklyMaleTournament1000Description =>
      'Wöchentliches Männerturnier - 300 Teilnehmer Kapazität';

  @override
  String get weeklyMaleTournament10000Description =>
      'Premium Männerturnier - 100 Teilnehmer Kapazität';

  @override
  String get weeklyFemaleTournament1000Description =>
      'Wöchentliches Frauenturnier - 300 Teilnehmer Kapazität';

  @override
  String get weeklyFemaleTournament10000Description =>
      'Premium Frauenturnier - 100 Teilnehmer Kapazität';

  @override
  String get dataPrivacy => 'Data Privacy';

  @override
  String get dataPrivacyDescription => 'Manage your data and privacy settings';

  @override
  String get profileVisibility => 'Profile Visibility';

  @override
  String get profileVisibilityDescription => 'Control who can see your profile';

  @override
  String get dataCollection => 'Data Collection';

  @override
  String get dataCollectionDescription => 'Allow data collection for analytics';

  @override
  String get marketingEmails => 'Marketing Emails';

  @override
  String get marketingEmailsDescription =>
      'Receive promotional emails and updates';

  @override
  String get locationTracking => 'Location Tracking';

  @override
  String get locationTrackingDescription => 'Allow location-based features';

  @override
  String get reportContent => 'Report Content';

  @override
  String get reportInappropriate => 'Report Inappropriate';

  @override
  String get reportReason => 'Report Reason';

  @override
  String get nudity => 'Nudity';

  @override
  String get inappropriateContent => 'Inappropriate Content';

  @override
  String get harassment => 'Harassment';

  @override
  String get spam => 'Spam';

  @override
  String get other => 'Other';

  @override
  String get reportSubmitted => 'Report submitted successfully';

  @override
  String get reportError => 'Failed to submit report';

  @override
  String get submit => 'Submit';

  @override
  String get profileVisible => 'Profile is now visible';

  @override
  String get profileHidden => 'Profile is now hidden';

  @override
  String get notificationCenter => 'Benachrichtigungen';

  @override
  String get allNotificationsDescription =>
      'Alle Benachrichtigungstypen aktivieren/deaktivieren';

  @override
  String get tournamentNotificationsDescription =>
      'Neue Turnier-Einladungen und Updates';

  @override
  String get voteReminderNotifications => 'Abstimmungserinnerungen';

  @override
  String get voteReminderNotificationsDescription =>
      'Abstimmungserinnerungs-Benachrichtigungen';

  @override
  String get winCelebrationNotifications => 'Siegfeiern';

  @override
  String get winCelebrationNotificationsDescription =>
      'Sieg-Benachrichtigungen';

  @override
  String get streakReminderNotifications => 'Streak-Erinnerungen';

  @override
  String get streakReminderNotificationsDescription =>
      'Tägliche Streak-Erinnerungen';

  @override
  String get notificationsList => 'Benachrichtigungen';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen';

  @override
  String get newNotificationsWillAppearHere =>
      'Neue Benachrichtigungen erscheinen hier';

  @override
  String get markAllAsRead => 'Alle als gelesen markieren';
}
