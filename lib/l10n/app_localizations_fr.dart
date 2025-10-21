// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chizo';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get age => 'Âge';

  @override
  String get country => 'Pays';

  @override
  String get gender => 'Genre';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get instagramHandle => 'Compte Instagram';

  @override
  String get profession => 'Profession';

  @override
  String get voting => 'Vote';

  @override
  String get whichDoYouPrefer => 'Lequel préférez-vous ?';

  @override
  String predictUserWinRate(String username) {
    return 'Prédire le taux de victoire de $username';
  }

  @override
  String get correctPrediction => 'Prédiction correcte = 1 pièce';

  @override
  String get submitPrediction => 'Soumettre la prédiction';

  @override
  String get winRate => 'Taux de victoire';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get leaderboard => 'Classement';

  @override
  String get tournament => 'Tournoi';

  @override
  String get language => 'Langue';

  @override
  String get turkish => 'Turc';

  @override
  String get english => 'Anglais';

  @override
  String get german => 'Allemand';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get turkishLanguage => 'Turc';

  @override
  String get englishLanguage => 'Anglais';

  @override
  String get germanLanguage => 'Allemand';

  @override
  String get spanishLanguage => 'Espagnol';

  @override
  String get frenchLanguage => 'Français';

  @override
  String get coins => 'Pièces';

  @override
  String get coinPackages => '💰 Packs de pièces';

  @override
  String get watchAds => 'Regarder des pubs';

  @override
  String get watchAdsToEarnCoins => 'Regardez des pubs pour gagner des pièces';

  @override
  String get watchAdsDescription =>
      '3 vidéos dans les 24 heures - 5 pièces par vidéo';

  @override
  String get buy => 'Acheter';

  @override
  String get watchAd => 'Regarder une pub';

  @override
  String get watchAdConfirmation =>
      'Vous pouvez gagner 5 pièces en regardant une pub. Continuer ?';

  @override
  String get watchingAd => 'Regarder la pub...';

  @override
  String coinsEarned(int count) {
    return 'Vous avez gagné $count pièces !';
  }

  @override
  String get errorAddingCoins => 'Erreur lors de l\'ajout de pièces !';

  @override
  String get buyCoins => 'Acheter des pièces';

  @override
  String buyCoinsConfirmation(int count) {
    return 'Voulez-vous acheter $count pièces ?';
  }

  @override
  String get processing => 'Traitement...';

  @override
  String coinsAdded(int count) {
    return '$count pièces ajoutées !';
  }

  @override
  String get watch => 'Regarder';

  @override
  String get adLimitReached => 'Limite quotidienne de pubs atteinte !';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettingsDescription =>
      'Activer/désactiver les notifications téléphoniques (les notifications continueront d\'apparaître dans l\'app)';

  @override
  String get tournamentNotifications => 'Notifications de tournoi';

  @override
  String get tournamentNotificationsDescription =>
      'Phase de ligue, rappels de début/fin de match';

  @override
  String get winCelebrationNotifications => 'Célébrations de victoire';

  @override
  String get winCelebrationNotificationsDescription =>
      'Victoires de match et notifications de jalons';

  @override
  String get streakReminderNotifications => 'Rappels de série';

  @override
  String get streakReminderNotificationsDescription =>
      'Rappels quotidiens de série et de récompenses';

  @override
  String get notificationSettingsSaved =>
      'Paramètres de notification enregistrés';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get marketingSettings => 'Paramètres marketing';

  @override
  String get marketingEmails => 'Emails marketing';

  @override
  String get marketingEmailsDescription =>
      'Recevoir des emails promotionnels et des mises à jour';

  @override
  String get marketingEmailsEnabled => 'Emails marketing activés';

  @override
  String get marketingEmailsDisabled => 'Emails marketing désactivés';

  @override
  String get totalMatches => 'Total de matchs';

  @override
  String get wins => 'Victoires';

  @override
  String get winRatePercentage => 'Taux de victoire';

  @override
  String get currentStreak => 'Série actuelle';

  @override
  String get totalStreakDays => 'Total de jours de série';

  @override
  String get predictionStats => 'Statistiques de prédiction';

  @override
  String get totalPredictions => 'Total de prédictions';

  @override
  String get correctPredictions => 'Prédictions correctes';

  @override
  String get accuracy => 'Précision';

  @override
  String coinsEarnedFromPredictions(int coins) {
    return 'Pièces gagnées des prédictions';
  }

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get correctPredictionWithReward =>
      'Vous avez prédit correctement et gagné 1 pièce !';

  @override
  String wrongPredictionWithRate(double winRate) {
    return 'Mauvaise prédiction. Le taux de victoire réel était $winRate%';
  }

  @override
  String get error => 'Erreur';

  @override
  String get invalidEmail =>
      '❌ Adresse email invalide ! Veuillez entrer un format d\'email valide.';

  @override
  String get userNotFoundError =>
      '❌ Aucun utilisateur trouvé avec cette adresse email !';

  @override
  String get userAlreadyRegistered =>
      '❌ Cette adresse email est déjà enregistrée ! Essayez de vous connecter.';

  @override
  String get invalidPassword =>
      '❌ Mauvais mot de passe ! Veuillez vérifier votre mot de passe.';

  @override
  String get passwordMinLengthError =>
      '❌ Le mot de passe doit contenir au moins 6 caractères !';

  @override
  String get passwordTooWeak =>
      '❌ Le mot de passe est trop faible ! Choisissez un mot de passe plus fort.';

  @override
  String get usernameAlreadyTaken =>
      '❌ Ce nom d\'utilisateur est déjà pris ! Choisissez un autre nom d\'utilisateur.';

  @override
  String get usernameTooShort =>
      '❌ Le nom d\'utilisateur doit contenir au moins 3 caractères !';

  @override
  String get networkError => '❌ Vérifiez votre connexion internet !';

  @override
  String get timeoutError =>
      '❌ Délai de connexion dépassé ! Veuillez réessayer.';

  @override
  String get emailNotConfirmed =>
      '❌ Vous devez confirmer votre adresse email !';

  @override
  String get tooManyRequests =>
      '❌ Trop de tentatives ! Veuillez attendre quelques minutes et réessayer.';

  @override
  String get accountDisabled => '❌ Votre compte a été désactivé !';

  @override
  String get accountDeletedPleaseRegister =>
      '❌ Votre compte a été supprimé. Veuillez créer un nouveau compte.';

  @override
  String get duplicateData =>
      '❌ Ces informations sont déjà utilisées ! Essayez des informations différentes.';

  @override
  String get invalidData =>
      '❌ Il y a une erreur dans les informations que vous avez entrées ! Veuillez vérifier.';

  @override
  String get invalidCredentials =>
      '❌ L\'email ou le mot de passe est incorrect !';

  @override
  String get tooManyEmails => '❌ Trop d\'emails envoyés ! Veuillez attendre.';

  @override
  String get operationFailed =>
      '❌ L\'opération a échoué ! Veuillez vérifier vos informations.';

  @override
  String get success => 'Succès';

  @override
  String get loading => 'Chargement...';

  @override
  String get noMatchesAvailable => 'Aucun match disponible pour voter';

  @override
  String get allMatchesVoted =>
      'Tous les matchs votés !\nEn attente de nouveaux matchs...';

  @override
  String get usernameCannotBeEmpty =>
      'Le nom d\'utilisateur ne peut pas être vide';

  @override
  String get emailCannotBeEmpty => 'L\'email ne peut pas être vide';

  @override
  String get passwordCannotBeEmpty => 'Le mot de passe ne peut pas être vide';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get registrationSuccessful => 'Inscription réussie !';

  @override
  String get userAlreadyExists =>
      'Cet utilisateur est déjà enregistré ou une erreur s\'est produite';

  @override
  String get loginSuccessful => 'Connexion réussie !';

  @override
  String get loginError => 'Erreur de connexion : Erreur inconnue';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get registerNow => 'S\'inscrire maintenant';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get loginNow => 'Se connecter maintenant';

  @override
  String get allPhotoSlotsFull => 'All additional photo slots are full!';

  @override
  String photoUploadSlot(int slot) {
    return 'Photo Upload - Slot $slot';
  }

  @override
  String coinsRequiredForSlot(int coins) {
    return 'This slot requires $coins coins.';
  }

  @override
  String get insufficientCoinsForUpload =>
      'Insufficient coins! Use the coin button on profile page to purchase coins.';

  @override
  String get cancel => 'Annuler';

  @override
  String upload(int coins) {
    return 'Télécharger ($coins pièces)';
  }

  @override
  String photoUploaded(int coinsSpent) {
    return 'Photo téléchargée';
  }

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get confirmDeletePhoto =>
      'Êtes-vous sûr de vouloir supprimer cette photo ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get photoDeleted => '✅ Photo supprimée !';

  @override
  String get selectFromGallery => 'Sélectionner de la galerie';

  @override
  String get takeFromCamera => 'Prendre avec l\'appareil photo';

  @override
  String get additionalMatchPhotos => '📸 Photos de match supplémentaires';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String additionalPhotosDescription(int count) {
    return 'Additional photos that will appear in matches ($count/4)';
  }

  @override
  String get noAdditionalPhotos => 'Pas encore de photos supplémentaires';

  @override
  String get secondPhotoCost => '2nd photo costs 50 coins!';

  @override
  String get premiumInfoAdded =>
      'Your premium information has been added! You can adjust visibility settings below.';

  @override
  String get premiumInfoVisibility => '💎 Visibilité des infos premium';

  @override
  String get premiumInfoDescription =>
      'Les autres utilisateurs peuvent voir ces informations en dépensant des pièces';

  @override
  String get instagramAccount => 'Compte Instagram';

  @override
  String get statistics => 'Statistiques';

  @override
  String get predictionStatistics => '🎯 Statistiques de prédiction';

  @override
  String get matchHistory => 'Historique des matchs';

  @override
  String get viewLastFiveMatches =>
      'Voir vos 5 derniers matchs et adversaires (5 pièces)';

  @override
  String get viewRecentMatches => 'Voir les matchs récents';

  @override
  String get visibleInMatches => 'Visible dans les matchs';

  @override
  String get nowVisibleInMatches =>
      'Vous apparaîtrez maintenant dans les matchs !';

  @override
  String get removedFromMatches => 'Vous avez été retiré des matchs !';

  @override
  String addInfo(String type) {
    return 'Ajouter $type';
  }

  @override
  String enterInfo(String type) {
    return 'Entrez vos informations $type :';
  }

  @override
  String get add => 'Ajouter';

  @override
  String infoAdded(String type) {
    return '✅ Informations $type ajoutées !';
  }

  @override
  String get errorAddingInfo => '❌ Erreur lors de l\'ajout des informations !';

  @override
  String get matchInfoNotLoaded =>
      'Les informations du match n\'ont pas pu être chargées';

  @override
  String premiumInfo(String type) {
    return '💎 Informations $type';
  }

  @override
  String get spendFiveCoins => 'Dépenser 5 pièces';

  @override
  String get insufficientCoins => '❌ Pièces insuffisantes !';

  @override
  String get fiveCoinsSpent => '✅ 5 pièces dépensées';

  @override
  String get ok => 'OK';

  @override
  String matchCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get spendFiveCoinsToView =>
      'Vous dépenserez 5 pièces pour voir cette information';

  @override
  String get great => 'Génial !';

  @override
  String get homePage => 'Page d\'accueil';

  @override
  String streakMessage(int days) {
    return 'Série de $days jours !';
  }

  @override
  String get purchaseCoins => 'Acheter des pièces';

  @override
  String get dailyAdLimit => 'Vous pouvez regarder maximum 5 pubs par jour';

  @override
  String get coinsPerAd => 'Pièces par pub : 20';

  @override
  String get watchAdButton => 'Regarder une pub';

  @override
  String get dailyLimitReached => 'Limite quotidienne atteinte';

  @override
  String get recentTransactions => 'Transactions récentes :';

  @override
  String get noTransactionHistory => 'Pas encore d\'historique de transactions';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?';

  @override
  String logoutError(String error) {
    return 'Erreur lors de la déconnexion';
  }

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action ne peut pas être annulée et toutes vos données seront définitivement supprimées.';

  @override
  String get finalConfirmation => 'Confirmation finale';

  @override
  String get typeDeleteToConfirm =>
      'Pour supprimer votre compte, tapez \"SUPPRIMER\" :';

  @override
  String get pleaseTypeDelete => 'Veuillez taper \"SUPPRIMER\" !';

  @override
  String get accountDeletedSuccessfully =>
      'Votre compte a été supprimé avec succès !';

  @override
  String errorDeletingAccount(String error) {
    return 'Erreur lors de la suppression du compte';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Error occurred while watching ad';
  }

  @override
  String get adLoading => 'Ad loading...';

  @override
  String get adSimulation =>
      'This is a simulation ad. In the real app, an actual ad will be shown here.';

  @override
  String get adWatched => 'Ad watched! +20 coins earned!';

  @override
  String get predict => 'Prédire';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ 5 pièces dépensées ! Votre historique de matchs s\'affiche.';

  @override
  String get insufficientCoinsForHistory => '❌ Insufficient coins!';

  @override
  String get spendFiveCoinsForHistory =>
      'Dépensez 5 pièces pour voir vos 5 derniers matchs et adversaires';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins victoires • $matches matchs';
  }

  @override
  String get insufficientCoinsForTournament =>
      'Pièces insuffisantes pour le tournoi !';

  @override
  String get joinedTournament => 'Vous avez rejoint le tournoi !';

  @override
  String get tournamentJoinFailed => 'Échec de la participation au tournoi !';

  @override
  String get dailyStreak => 'Série quotidienne !';

  @override
  String get imageUpdated => 'Image mise à jour !';

  @override
  String get updateFailed => 'Échec de la mise à jour !';

  @override
  String get imageUpdateFailed => 'Échec de la mise à jour de l\'image !';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get userInfoNotLoaded =>
      'Les informations de l\'utilisateur n\'ont pas pu être chargées';

  @override
  String get coin => 'Pièce';

  @override
  String get premiumFeatures => 'Fonctionnalités premium';

  @override
  String get addInstagram => 'Ajouter un compte Instagram';

  @override
  String get addProfession => 'Ajouter une profession';

  @override
  String get profileUpdated => 'Profil mis à jour !';

  @override
  String get profileUpdateFailed => 'Échec de la mise à jour du profil !';

  @override
  String get profileSettings => 'Paramètres du profil';

  @override
  String get passwordReset => 'Réinitialiser le mot de passe';

  @override
  String get passwordResetSubtitle => 'Réinitialiser le mot de passe par email';

  @override
  String get logoutSubtitle => 'Déconnexion sécurisée de votre compte';

  @override
  String get deleteAccountSubtitle => 'Supprimer définitivement votre compte';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get passwordResetTitle => 'Réinitialisation du mot de passe';

  @override
  String get passwordResetMessage =>
      'Un lien de réinitialisation du mot de passe sera envoyé à votre adresse email. Voulez-vous continuer ?';

  @override
  String get send => 'Envoyer';

  @override
  String get passwordResetSent =>
      'Email de réinitialisation du mot de passe envoyé !';

  @override
  String get emailNotFound => 'Adresse email introuvable !';

  @override
  String votingError(Object error) {
    return 'Erreur lors du vote : $error';
  }

  @override
  String slot(Object slot) {
    return 'Slot $slot';
  }

  @override
  String get instagramAdded => 'Instagram information added!';

  @override
  String get professionAdded => 'Profession information added!';

  @override
  String get addInstagramFromSettings =>
      'You can use this feature by adding Instagram and profession information from settings';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get premiumInfoSettings => 'Premium Information';

  @override
  String get premiumInfoDescriptionSettings =>
      'Other users can view this information by spending coins';

  @override
  String get coinInfo => 'Coin Information';

  @override
  String currentCoins(int coins) {
    return 'Current Coins';
  }

  @override
  String get remaining => 'Restant';

  @override
  String get vs => 'VS';

  @override
  String get coinPurchase => 'Coin Purchase';

  @override
  String get purchaseSuccessful => 'Purchase successful!';

  @override
  String get purchaseFailed => 'Purchase failed!';

  @override
  String get coinUsage => 'Coin Usage';

  @override
  String get instagramView => 'View Instagram accounts';

  @override
  String get professionView => 'View profession information';

  @override
  String get statsView => 'View detailed statistics';

  @override
  String get tournamentFees => 'Tournament participation fees';

  @override
  String get weeklyMaleTournament5000 => 'Tournoi masculin Chizo (5000 pièces)';

  @override
  String get weeklyMaleTournament5000Desc =>
      'Premium male tournament - 100 person capacity';

  @override
  String get weeklyFemaleTournament5000 =>
      'Tournoi féminin Chizo (5000 pièces)';

  @override
  String get weeklyFemaleTournament5000Desc =>
      'Premium female tournament - 100 person capacity';

  @override
  String get tournamentEntryFee => 'Tournament entry fee';

  @override
  String get tournamentVotingTitle => 'Vote du tournoi';

  @override
  String get tournamentThirdPlace => 'Tournament 3rd place';

  @override
  String get tournamentWon => 'Tournament won';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get userNotFound => 'User not found';

  @override
  String get firstLoginReward => '🎉 First login! You earned 50 coins!';

  @override
  String streakReward(Object coins, Object streak) {
    return '🔥 $streak day streak! You earned $coins coins!';
  }

  @override
  String get streakBroken =>
      '💔 Streak broken! New start: You earned 50 coins!';

  @override
  String dailyStreakReward(Object streak) {
    return 'Daily streak reward ($streak days)';
  }

  @override
  String get alreadyLoggedInToday => 'You already logged in today!';

  @override
  String get streakCheckError => 'Error occurred during streak check';

  @override
  String get streakInfoError => 'Could not get streak information';

  @override
  String get correctPredictionReward =>
      'Vous gagnerez 1 pièce pour une prédiction correcte !';

  @override
  String get wrongPredictionMessage =>
      'Malheureusement, vous avez prédit incorrectement.';

  @override
  String get predictionSaveError => 'Error occurred while saving prediction';

  @override
  String get coinAddError => 'Error occurred while adding coins';

  @override
  String coinPurchaseTransaction(Object description) {
    return 'Coin purchase - $description';
  }

  @override
  String get whiteThemeName => 'Blanc';

  @override
  String get darkThemeName => 'Sombre';

  @override
  String get pinkThemeName => 'Rose';

  @override
  String get premiumFilters => 'Premium filters';

  @override
  String get viewStats => 'Voir les statistiques';

  @override
  String get photoStats => 'Statistiques de la photo';

  @override
  String get photoStatsCost =>
      'Voir les statistiques de la photo coûte 50 pièces';

  @override
  String get insufficientCoinsForStats =>
      'Pièces insuffisantes pour voir les statistiques de la photo. Requis : 50 pièces';

  @override
  String get pay => 'Payer';

  @override
  String get tournamentVotingSaved => 'Vote du tournoi enregistré !';

  @override
  String get tournamentVotingFailed => 'Échec du vote du tournoi !';

  @override
  String get tournamentVoting => 'VOTE DU TOURNOI';

  @override
  String get whichTournamentParticipant =>
      'Quel participant du tournoi préférez-vous ?';

  @override
  String ageYears(Object age, Object country) {
    return '$age ans • $country';
  }

  @override
  String get clickToOpenInstagram => '📱 Cliquez pour ouvrir Instagram';

  @override
  String get openInstagram => 'Ouvrir Instagram';

  @override
  String get instagramCannotBeOpened =>
      '❌ Instagram n\'a pas pu être ouvert. Veuillez vérifier votre application Instagram.';

  @override
  String instagramOpenError(Object error) {
    return '❌ Erreur lors de l\'ouverture d\'Instagram : $error';
  }

  @override
  String get tournamentPhoto => '🏆 Photo du tournoi';

  @override
  String get tournamentJoinedUploadPhoto =>
      'Vous avez rejoint le tournoi ! Téléchargez maintenant votre photo de tournoi.';

  @override
  String get uploadLater => 'Télécharger plus tard';

  @override
  String get uploadPhoto => 'Télécharger la photo';

  @override
  String get tournamentPhotoUploaded => '✅ Photo du tournoi téléchargée !';

  @override
  String get photoUploadError =>
      '❌ Erreur lors du téléchargement de la photo !';

  @override
  String get noVotingForTournament => 'Aucun vote trouvé pour ce tournoi';

  @override
  String votingLoadError(Object error) {
    return 'Erreur lors du chargement du vote : $error';
  }

  @override
  String get whichParticipantPrefer => 'Quel participant préférez-vous ?';

  @override
  String get voteSavedSuccessfully =>
      'Votre vote a été enregistré avec succès !';

  @override
  String get noActiveTournament => 'Aucun tournoi actif actuellement';

  @override
  String get registration => 'Inscription';

  @override
  String get upcoming => 'À venir';

  @override
  String coinPrize(Object prize) {
    return 'Prix de $prize pièces';
  }

  @override
  String startDate(Object date) {
    return 'Début : $date';
  }

  @override
  String get completed => 'Terminé';

  @override
  String get join => 'Rejoindre';

  @override
  String get photo => 'Photo';

  @override
  String get languageChanged => 'Langue changée. Actualisation de la page...';

  @override
  String get lightWhiteTheme => 'Thème clair blanc matériel';

  @override
  String get neutralDarkGrayTheme => 'Neutral dark gray theme';

  @override
  String themeChanged(Object theme) {
    return 'Thème changé : $theme';
  }

  @override
  String get deleteAccountWarning =>
      'Cette action ne peut pas être annulée ! Toutes vos données seront définitivement supprimées.\nÊtes-vous sûr de vouloir supprimer votre compte ?';

  @override
  String get accountDeleted => 'Votre compte a été supprimé';

  @override
  String get logoutButton => 'Déconnexion';

  @override
  String get themeSelection => '🎨 Sélection du thème';

  @override
  String get darkMaterialTheme => 'Thème sombre noir matériel';

  @override
  String get lightPinkTheme => 'Thème rose clair';

  @override
  String get notificationSettings => '🔔 Paramètres de notification';

  @override
  String get allNotifications => 'Toutes les notifications';

  @override
  String get allNotificationsSubtitle =>
      'Activer/désactiver les notifications principales';

  @override
  String get voteReminder => 'Rappel de vote';

  @override
  String get winCelebration => 'Célébration de victoire';

  @override
  String get streakReminder => 'Rappel de série';

  @override
  String get streakReminderSubtitle =>
      'Rappels de récompenses de série quotidienne';

  @override
  String get moneyAndCoins => '💰 Transactions d\'argent et de pièces';

  @override
  String get purchaseCoinPackage => 'Acheter un pack de pièces';

  @override
  String get purchaseCoinPackageSubtitle =>
      'Achetez des pièces et gagnez des récompenses';

  @override
  String get appSettings => '⚙️ Paramètres de l\'application';

  @override
  String get dailyRewards => 'Récompenses quotidiennes';

  @override
  String get dailyRewardsSubtitle =>
      'Voir les récompenses de série et les boosts';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get accountOperations => '👤 Opérations de compte';

  @override
  String get dailyStreakRewards => 'Récompenses de série quotidienne';

  @override
  String get dailyStreakDescription =>
      '🎯 Connectez-vous à l\'application chaque jour et gagnez des bonus !';

  @override
  String get appDescription =>
      'Application de vote et de tournoi dans les salles de discussion.';

  @override
  String get predictWinRateTitle => 'Prédire le taux de victoire !';

  @override
  String get wrongPredictionNoCoin => 'Mauvaise prédiction = 0 pièce';

  @override
  String get selectWinRateRange =>
      'Sélectionner la plage de taux de victoire :';

  @override
  String get wrongPrediction => 'Mauvaise prédiction';

  @override
  String get correctPredictionMessage => 'Vous avez prédit correctement !';

  @override
  String actualRate(Object rate) {
    return 'Taux réel : $rate%';
  }

  @override
  String get earnedOneCoin => '+1 pièce gagnée !';

  @override
  String myPhotos(Object count) {
    return 'Mes photos ($count/5)';
  }

  @override
  String get photoCostInfo =>
      'La première photo est gratuite, les autres coûtent des pièces. Vous pouvez voir les statistiques de toutes les photos.';

  @override
  String get addAge => 'Ajouter l\'âge';

  @override
  String get addCountry => 'Ajouter le pays';

  @override
  String get addGender => 'Ajouter le genre';

  @override
  String get countrySelection => 'Sélection du pays';

  @override
  String countriesSelected(Object count) {
    return '$count pays sélectionnés';
  }

  @override
  String get allCountriesSelected => 'Tous les pays sélectionnés';

  @override
  String get countrySelectionSubtitle =>
      'Sélectionnez les pays dont vous souhaitez être voté';

  @override
  String get ageRangeSelection => 'Sélection de la tranche d\'âge';

  @override
  String ageRangesSelected(Object count) {
    return '$count tranches d\'âge sélectionnées';
  }

  @override
  String get allAgeRangesSelected => 'Toutes les tranches d\'âge sélectionnées';

  @override
  String get ageRangeSelectionSubtitle =>
      'Sélectionnez les tranches d\'âge dont vous souhaitez être voté';

  @override
  String get selectCountriesDialogSubtitle =>
      'Sélectionnez les pays dont vous souhaitez être voté:';

  @override
  String get editUsername => 'Modifier le nom d\'utilisateur';

  @override
  String get enterUsername => 'Entrez votre nom d\'utilisateur';

  @override
  String get editAge => 'Modifier l\'âge';

  @override
  String get enterAge => 'Entrez votre âge';

  @override
  String get selectCountry => 'Sélectionner le pays';

  @override
  String get selectYourCountry => 'Sélectionnez votre pays';

  @override
  String get selectGender => 'Sélectionner le genre';

  @override
  String get selectYourGender => 'Sélectionnez votre genre';

  @override
  String get editInstagram => 'Modifier le compte Instagram';

  @override
  String get enterInstagram =>
      'Entrez votre nom d\'utilisateur Instagram (sans @)';

  @override
  String get editProfession => 'Modifier la profession';

  @override
  String get enterProfession => 'Entrez votre profession';

  @override
  String get infoUpdated => 'Informations mises à jour';

  @override
  String get countryPreferencesUpdated => '✅ Préférences de pays mises à jour';

  @override
  String get countryPreferencesUpdateFailed =>
      '❌ Les préférences de pays n\'ont pas pu être mises à jour';

  @override
  String get ageRangePreferencesUpdated =>
      '✅ Préférences de tranche d\'âge mises à jour';

  @override
  String get ageRangePreferencesUpdateFailed =>
      '❌ Les préférences de tranche d\'âge n\'ont pas pu être mises à jour';

  @override
  String winRateAndMatches(Object matches, Object winRate) {
    return '$matches matchs • $winRate';
  }

  @override
  String get mostWins => 'Plus de victoires';

  @override
  String get highestWinRate => 'Taux de victoire le plus élevé';

  @override
  String get noWinsYet =>
      'Pas encore de victoires !\nJouez votre premier match et entrez dans le classement !';

  @override
  String get noWinRateYet =>
      'Pas encore de taux de victoire !\nJouez des matchs pour augmenter votre taux de victoire !';

  @override
  String get matchHistoryViewing => 'Visualisation de l\'historique des matchs';

  @override
  String winRateColon(Object winRate) {
    return 'Taux de victoire : $winRate';
  }

  @override
  String matchesAndWins(Object matches, Object wins) {
    return '$matches matchs • $wins victoires';
  }

  @override
  String get youWon => 'Vous avez gagné';

  @override
  String get youLost => 'Vous avez perdu';

  @override
  String get lastFiveMatchStats => '📊 Statistiques des 5 derniers matchs';

  @override
  String get noMatchHistoryYet =>
      'Pas encore d\'historique de matchs !\nJouez votre premier match !';

  @override
  String get premiumFeature => '🔒 Fonctionnalité premium';

  @override
  String get save => 'Enregistrer';

  @override
  String get leaderboardTitle => '🏆 Classement';

  @override
  String get day1_2Reward => 'Jour 1-2 : 10-25 pièces';

  @override
  String get day3_6Reward => 'Jour 3-6 : 50-100 pièces';

  @override
  String get day7PlusReward => 'Jour 7+ : 200+ pièces et boost';

  @override
  String get photoStatsLoadError =>
      'Impossible de charger les statistiques de la photo';

  @override
  String get newTournamentInvitations => 'New tournament invitations';

  @override
  String get victoryNotifications => 'Victory notifications';

  @override
  String get vote => 'Voter';

  @override
  String get lastFiveMatches => '5 derniers matchs';

  @override
  String get total => 'Total';

  @override
  String get losses => 'Défaites';

  @override
  String get rate => 'Taux';

  @override
  String get ongoing => 'En cours';

  @override
  String get tournamentFull => 'Tournoi complet';

  @override
  String get active => 'Actif';

  @override
  String get joinWithKey => 'Rejoindre avec une clé';

  @override
  String get private => 'Privé';

  @override
  String get countryRanking => 'Classement par pays';

  @override
  String get countryRankingSubtitle =>
      'Votre réussite contre les citoyens de différents pays';

  @override
  String get countryRankingTitle => 'Classement par pays';

  @override
  String get countryRankingDescription =>
      'Votre réussite contre les citoyens de différents pays';

  @override
  String get winsAgainst => 'Victoires';

  @override
  String get lossesAgainst => 'Défaites';

  @override
  String get winRateAgainst => 'Taux de victoire';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get loadingCountryStats => 'Chargement des statistiques du pays...';

  @override
  String get countryStats => 'Statistiques du pays';

  @override
  String get yourPerformance => 'Vos performances';

  @override
  String get againstCountry => 'Comparaison par pays';

  @override
  String get retry => 'Réessayer';

  @override
  String get alreadyJoinedTournament => 'Vous avez déjà rejoint ce tournoi';

  @override
  String get uploadTournamentPhoto => 'Télécharger la photo du tournoi';

  @override
  String get viewTournament => 'Voir le tournoi';

  @override
  String get tournamentParticipants => 'Participants au tournoi';

  @override
  String get yourRank => 'Votre rang';

  @override
  String get rank => 'Rang';

  @override
  String get participant => 'Participant';

  @override
  String get photoNotUploaded => 'Photo non téléchargée';

  @override
  String get uploadPhotoUntilWednesday =>
      'Vous pouvez télécharger une photo jusqu\'à mercredi';

  @override
  String get tournamentStarted => 'Le tournoi a commencé';

  @override
  String get viewTournamentPhotos => 'Voir les photos du tournoi';

  @override
  String get genderMismatch => 'Incompatibilité de genre';

  @override
  String get photoAlreadyUploaded => 'Photo déjà téléchargée';

  @override
  String get viewParticipantPhoto => 'Voir la photo du participant';

  @override
  String get selectPhoto => 'Sélectionner une photo';

  @override
  String get photoUploadFailed => 'Échec du téléchargement de la photo';

  @override
  String get tournamentCancelled => 'Tournoi annulé';

  @override
  String get refundFailed => 'Échec du remboursement';

  @override
  String get createPrivateTournament => 'Créer un tournoi privé';

  @override
  String get tournamentName => 'Nom du tournoi';

  @override
  String get maxParticipants => 'Participants maximum';

  @override
  String get tournamentFormat => 'Format du tournoi';

  @override
  String get leagueFormat => 'Format de ligue';

  @override
  String get eliminationFormat => 'Format d\'élimination';

  @override
  String get hybridFormat => 'Ligue + Élimination';

  @override
  String get eliminationMaxParticipants =>
      'Maximum 8 participants pour le format d\'élimination';

  @override
  String get eliminationMaxParticipantsWarning =>
      'Maximum 8 participants autorisés pour le format d\'élimination';

  @override
  String get weeklyMaleTournament5000Description =>
      'Tournoi masculin premium - Capacité de 100 participants';

  @override
  String get weeklyFemaleTournament5000Description =>
      'Tournoi féminin premium - Capacité de 100 participants';

  @override
  String get instantMaleTournament5000 => 'Chizo Male Tournament (5000 Coins)';

  @override
  String get instantMaleTournament5000Description =>
      'Premium male tournament that starts when 100 participants join';

  @override
  String get instantFemaleTournament5000 =>
      'Chizo Female Tournament (5000 Coins)';

  @override
  String get instantFemaleTournament5000Description =>
      'Premium female tournament that starts when 100 participants join';

  @override
  String get dataPrivacy => 'Confidentialité des données';

  @override
  String get dataPrivacyDescription =>
      'Gérez vos paramètres de données et de confidentialité';

  @override
  String get profileVisibility => 'Visibilité du profil';

  @override
  String get profileVisibilityDescription =>
      'Contrôlez qui peut voir votre profil';

  @override
  String get dataCollection => 'Collecte de données';

  @override
  String get dataCollectionDescription =>
      'Autoriser la collecte de données pour l\'analyse';

  @override
  String get locationTracking => 'Suivi de localisation';

  @override
  String get locationTrackingDescription =>
      'Autoriser les fonctionnalités basées sur la localisation';

  @override
  String get reportContent => 'Signaler le contenu';

  @override
  String get reportInappropriate => 'Signaler un contenu inapproprié';

  @override
  String get reportReason => 'Raison du signalement';

  @override
  String get nudity => 'Nudité';

  @override
  String get inappropriateContent => 'Contenu inapproprié';

  @override
  String get harassment => 'Harcèlement';

  @override
  String get spam => 'Spam';

  @override
  String get other => 'Autre';

  @override
  String get reportSubmitted => 'Signalement soumis avec succès';

  @override
  String get reportError => 'Échec de la soumission du signalement';

  @override
  String get submit => 'Soumettre';

  @override
  String get profileVisible => 'Le profil est maintenant visible';

  @override
  String get profileHidden => 'Le profil est maintenant caché';

  @override
  String get notificationCenter => 'Notifications';

  @override
  String get allNotificationsDescription =>
      'Activer/désactiver tous les types de notifications';

  @override
  String get voteReminderNotifications => 'Vote Reminders';

  @override
  String get voteReminderNotificationsDescription =>
      'Vote reminder notifications';

  @override
  String get notificationsList => 'Notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get newNotificationsWillAppearHere =>
      'New notifications will appear here';

  @override
  String get referralSystem => '🎁 Système de parrainage';

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get inviteFriendsDescription =>
      'Invitez vos amis et vous gagnerez tous les deux 100 pièces !';

  @override
  String get yourReferralLink => 'Votre lien de parrainage';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get linkCopied => 'Lien copié !';

  @override
  String get shareLink => 'Partager le lien';

  @override
  String get referralReward => 'Récompense de parrainage';

  @override
  String get referralRewardDescription =>
      'Gagnez 100 pièces pour chaque ami que vous invitez !';

  @override
  String get inviteeReward => 'Récompense de l\'invité';

  @override
  String get inviteeRewardDescription =>
      'Les amis qui rejoignent avec votre lien gagnent également 100 pièces !';

  @override
  String get referralStats => 'Statistiques de parrainage';

  @override
  String get totalReferrals => 'Total de parrainages';

  @override
  String get referralCoinsEarned => 'Pièces gagnées grâce aux parrainages';

  @override
  String get store => 'Boutique';

  @override
  String get tournamentAccessGranted =>
      'Accès au tournoi accordé. Appuyez sur le bouton \"Rejoindre\" pour participer.';

  @override
  String get joinFailed => 'Échec de la participation';

  @override
  String get visibleInMatchesDesc =>
      'Les autres utilisateurs peuvent vous voir';

  @override
  String get cropImage => 'Recadrer l\'image';

  @override
  String get cropImageDone => 'Terminé';

  @override
  String get cropImageCancel => 'Annuler';

  @override
  String get cropImageInstructions => 'Recadrez votre image au format carré';
}
