// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chizo';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get username => 'Nombre de Usuario';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get age => 'Edad';

  @override
  String get country => 'País';

  @override
  String get gender => 'Género';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get instagramHandle => 'Usuario de Instagram';

  @override
  String get profession => 'Profession';

  @override
  String get voting => 'Votación';

  @override
  String get whichDoYouPrefer => '¿Cuál prefieres más?';

  @override
  String predictUserWinRate(String username) {
    return 'Predict $username\'s win rate';
  }

  @override
  String get correctPrediction => 'Predicción correcta = 1 moneda';

  @override
  String get submitPrediction => 'Enviar Predicción';

  @override
  String get winRate => 'Tasa de Victoria';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

  @override
  String get leaderboard => 'Tabla de Clasificación';

  @override
  String get tournament => 'Tournament';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Turco';

  @override
  String get english => 'Inglés';

  @override
  String get german => 'Alemán';

  @override
  String get spanish => 'Español';

  @override
  String get turkishLanguage => 'Turco';

  @override
  String get englishLanguage => 'Inglés';

  @override
  String get germanLanguage => 'Alemán';

  @override
  String get coins => 'Monedas';

  @override
  String get totalMatches => 'Partidos Totales';

  @override
  String get wins => 'Victorias';

  @override
  String get winRatePercentage => 'Porcentaje de Victoria';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get totalStreakDays => 'Total de Días de Racha';

  @override
  String get predictionStats => 'Estadísticas de Predicción';

  @override
  String get totalPredictions => 'Total Predictions';

  @override
  String get correctPredictions => 'Predicciones Correctas';

  @override
  String get accuracy => 'Precisión';

  @override
  String coinsEarnedFromPredictions(int coins) {
    return 'Coins earned from predictions: $coins';
  }

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get correctPredictionWithReward =>
      'You predicted correctly and earned 1 coin!';

  @override
  String wrongPredictionWithRate(double winRate) {
    return 'Wrong prediction. The actual win rate was $winRate%';
  }

  @override
  String get error => 'Error';

  @override
  String get success => 'Exitoso';

  @override
  String get loading => 'Cargando...';

  @override
  String get noMatchesAvailable =>
      'No hay partidos disponibles para votar en este momento';

  @override
  String get allMatchesVoted =>
      '¡Has votado en todos los partidos!\nEspera nuevos partidos...';

  @override
  String get usernameCannotBeEmpty =>
      'El nombre de usuario no puede estar vacío';

  @override
  String get emailCannotBeEmpty => 'El correo electrónico no puede estar vacío';

  @override
  String get passwordCannotBeEmpty => 'La contraseña no puede estar vacía';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get registrationSuccessful => '¡Registro exitoso!';

  @override
  String get userAlreadyExists =>
      'This user is already registered or an error occurred';

  @override
  String get loginSuccessful => '¡Inicio de sesión exitoso!';

  @override
  String get loginError => 'Error de inicio de sesión: Error desconocido';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? ';

  @override
  String get registerNow => 'Regístrate';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get loginNow => 'Inicia sesión';

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
  String get cancel => 'Cancelar';

  @override
  String upload(int coins) {
    return 'Upload ($coins coins)';
  }

  @override
  String photoUploaded(int coinsSpent) {
    return 'Photo uploaded! $coinsSpent coins spent.';
  }

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get confirmDeletePhoto =>
      'Are you sure you want to delete this photo?';

  @override
  String get delete => 'Eliminar';

  @override
  String get photoDeleted => 'Photo deleted!';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get takeFromCamera => 'Take from Camera';

  @override
  String get additionalMatchPhotos => 'Additional Match Photos';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String additionalPhotosDescription(int count) {
    return 'Additional photos that will appear in matches ($count/4)';
  }

  @override
  String get noAdditionalPhotos => 'No additional photos yet';

  @override
  String get secondPhotoCost => '2nd photo costs 50 coins!';

  @override
  String get premiumInfoAdded =>
      'Your premium information has been added! You can adjust visibility settings below.';

  @override
  String get premiumInfoVisibility => 'Premium Info Visibility';

  @override
  String get premiumInfoDescription =>
      'Other users can view this information by spending coins';

  @override
  String get instagramAccount => 'Instagram Account';

  @override
  String get statistics => 'Statistics';

  @override
  String get predictionStatistics => 'Prediction Statistics';

  @override
  String get matchHistory => '📊 Match History';

  @override
  String get viewLastFiveMatches =>
      'View your last 5 matches and opponents (5 coins)';

  @override
  String get visibleInMatches => 'Visible in Matches';

  @override
  String get nowVisibleInMatches => 'You will now appear in matches!';

  @override
  String get removedFromMatches => 'You have been removed from matches!';

  @override
  String addInfo(String type) {
    return 'Add $type';
  }

  @override
  String enterInfo(String type) {
    return 'Enter your $type information:';
  }

  @override
  String get add => 'Add';

  @override
  String infoAdded(String type) {
    return '✅ $type information added!';
  }

  @override
  String get errorAddingInfo => '❌ Error occurred while adding information!';

  @override
  String get matchInfoNotLoaded => 'Match information could not be loaded';

  @override
  String premiumInfo(String type) {
    return 'Premium Information';
  }

  @override
  String get spendFiveCoins => 'Spend 5 Coins';

  @override
  String get insufficientCoins => '❌ Insufficient coins!';

  @override
  String get fiveCoinsSpent => '✅ 5 coins spent';

  @override
  String get ok => 'OK';

  @override
  String matchCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get spendFiveCoinsToView =>
      'You will spend 5 coins to view this information';

  @override
  String get great => 'Great!';

  @override
  String get homePage => 'Home Page';

  @override
  String streakMessage(int days) {
    return '$days day streak!';
  }

  @override
  String get purchaseCoins => 'Comprar Monedas';

  @override
  String get watchAd => 'Ver Anuncio';

  @override
  String get dailyAdLimit => 'Puedes ver máximo 5 anuncios por día';

  @override
  String get coinsPerAd => 'Por anuncio: 20 monedas';

  @override
  String get watchAdButton => 'Ver Anuncio';

  @override
  String get dailyLimitReached => 'Límite diario alcanzado';

  @override
  String get recentTransactions => 'Transacciones Recientes:';

  @override
  String get noTransactionHistory => 'No hay historial de transacciones aún';

  @override
  String get accountSettings => 'Configuración de Cuenta';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirmation =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String logoutError(String error) {
    return 'Error occurred while logging out';
  }

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirmation =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y todos tus datos se eliminarán permanentemente.';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get typeDeleteToConfirm =>
      'Para eliminar tu cuenta, escribe \"ELIMINAR\":';

  @override
  String get pleaseTypeDelete => '¡Por favor escribe \"ELIMINAR\"!';

  @override
  String get accountDeletedSuccessfully =>
      '¡Tu cuenta ha sido eliminada exitosamente!';

  @override
  String errorDeletingAccount(String error) {
    return 'Error al eliminar la cuenta';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Error al ver el anuncio';
  }

  @override
  String get watchingAd => 'Viendo Anuncio';

  @override
  String get adLoading => 'Cargando anuncio...';

  @override
  String get adSimulation =>
      'This is a simulation ad. In the real app, an actual ad will be shown here.';

  @override
  String get adWatched => '¡Anuncio visto! ¡Ganaste +20 monedas!';

  @override
  String get errorAddingCoins => 'Error al agregar monedas';

  @override
  String get buy => 'Comprar';

  @override
  String get predict => 'Predict';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ 5 coins spent! Your match history is being displayed.';

  @override
  String get insufficientCoinsForHistory => '❌ Insufficient coins!';

  @override
  String get spendFiveCoinsForHistory =>
      'Spend 5 coins to see your last 5 matches and opponents';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins wins • $matches matches';
  }

  @override
  String get insufficientCoinsForTournament =>
      'Insufficient coins for tournament!';

  @override
  String get joinedTournament => 'You joined the tournament!';

  @override
  String get tournamentJoinFailed => 'Failed to join tournament!';

  @override
  String get dailyStreak => 'Daily Streak!';

  @override
  String get imageUpdated => 'Image updated!';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get imageUpdateFailed => 'Image update failed!';

  @override
  String get selectImage => 'Select Image';

  @override
  String get userInfoNotLoaded => 'User information could not be loaded';

  @override
  String get coin => 'Coin';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get addInstagram => 'Add Instagram Account';

  @override
  String get addProfession => 'Add Profession';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get profileUpdateFailed => 'Profile update failed!';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get passwordReset => 'Reset Password';

  @override
  String get passwordResetSubtitle => 'Reset password via email';

  @override
  String get logoutSubtitle => 'Secure logout from your account';

  @override
  String get deleteAccountSubtitle => 'Permanently delete your account';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get passwordResetTitle => 'Password Reset';

  @override
  String get passwordResetMessage =>
      'A password reset link will be sent to your email address. Do you want to continue?';

  @override
  String get send => 'Send';

  @override
  String get passwordResetSent => 'Password reset email sent!';

  @override
  String get emailNotFound => 'Email address not found!';

  @override
  String votingError(Object error) {
    return 'Error during voting: $error';
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
  String get remaining => 'Remaining';

  @override
  String get vs => 'VS';

  @override
  String get coinPurchase => 'Coin Purchase';

  @override
  String get purchaseSuccessful => 'Purchase successful!';

  @override
  String get purchaseFailed => 'Purchase failed!';

  @override
  String get coinPackages => 'Coin Packages';

  @override
  String get coinUsage => 'Coin Usage';

  @override
  String get instagramView => 'View Instagram accounts';

  @override
  String get professionView => 'View profession information';

  @override
  String get statsView => 'View detailed statistics';

  @override
  String get tournamentFees => 'Tarifas de participación en torneos';

  @override
  String get weeklyMaleTournament1000 =>
      'Torneo Masculino Semanal (1000 Monedas)';

  @override
  String get weeklyMaleTournament1000Desc =>
      'Torneo masculino semanal - capacidad para 300 personas';

  @override
  String get weeklyMaleTournament10000 =>
      'Torneo Masculino Semanal (10000 Monedas)';

  @override
  String get weeklyMaleTournament10000Desc =>
      'Torneo masculino premium - capacidad para 100 personas';

  @override
  String get weeklyFemaleTournament1000 =>
      'Torneo Femenino Semanal (1000 Monedas)';

  @override
  String get weeklyFemaleTournament1000Desc =>
      'Torneo femenino semanal - capacidad para 300 personas';

  @override
  String get weeklyFemaleTournament10000 =>
      'Torneo Femenino Semanal (10000 Monedas)';

  @override
  String get weeklyFemaleTournament10000Desc =>
      'Torneo femenino premium - capacidad para 100 personas';

  @override
  String get tournamentEntryFee => 'Tarifa de entrada al torneo';

  @override
  String get tournamentVotingTitle => 'Votación de Torneo';

  @override
  String get tournamentThirdPlace => 'Tercer lugar del torneo';

  @override
  String get tournamentWon => 'Torneo ganado';

  @override
  String get userNotLoggedIn => 'Usuario no ha iniciado sesión';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get firstLoginReward =>
      '🎉 ¡Primer inicio de sesión! ¡Ganaste 50 monedas!';

  @override
  String streakReward(Object coins, Object streak) {
    return '🔥 ¡$streak días de racha! ¡Ganaste $coins monedas!';
  }

  @override
  String get streakBroken =>
      '💔 ¡Racha rota! Nuevo comienzo: ¡Ganaste 50 monedas!';

  @override
  String dailyStreakReward(Object streak) {
    return 'Recompensa de racha diaria ($streak días)';
  }

  @override
  String get alreadyLoggedInToday => '¡Ya iniciaste sesión hoy!';

  @override
  String get streakCheckError =>
      'Ocurrió un error durante la verificación de racha';

  @override
  String get streakInfoError => 'No se pudo obtener información de racha';

  @override
  String get correctPredictionReward =>
      '¡Felicidades! ¡Predijiste correctamente y ganaste 1 moneda!';

  @override
  String get wrongPredictionMessage =>
      'Desafortunadamente, predijiste incorrectamente. Tasa de victoria real: null%';

  @override
  String get predictionSaveError => 'Ocurrió un error al guardar la predicción';

  @override
  String get coinAddError => 'Ocurrió un error al agregar monedas';

  @override
  String coinPurchaseTransaction(Object description) {
    return 'Compra de monedas - $description';
  }

  @override
  String get whiteThemeName => 'Blanco';

  @override
  String get darkThemeName => 'Oscuro';

  @override
  String get pinkThemeName => 'Rosa';

  @override
  String get premiumFilters => 'Premium filters';

  @override
  String get viewStats => 'View Stats';

  @override
  String get photoStats => 'Photo Statistics';

  @override
  String get photoStatsCost => 'View photo statistics costs 50 coins';

  @override
  String get insufficientCoinsForStats =>
      'Insufficient coins to view photo statistics. Required: 50 coins';

  @override
  String get pay => 'Pay';

  @override
  String get tournamentVotingSaved => 'Tournament voting saved!';

  @override
  String get tournamentVotingFailed => 'Tournament voting failed!';

  @override
  String get tournamentVoting => 'TOURNAMENT VOTING';

  @override
  String get whichTournamentParticipant =>
      'Which tournament participant do you prefer?';

  @override
  String ageYears(Object age, Object country) {
    return '$age years • $country';
  }

  @override
  String get clickToOpenInstagram => '📱 Click to open Instagram';

  @override
  String get openInstagram => 'Open Instagram';

  @override
  String get instagramCannotBeOpened =>
      '❌ Instagram could not be opened. Please check your Instagram app.';

  @override
  String instagramOpenError(Object error) {
    return '❌ Error opening Instagram: $error';
  }

  @override
  String get tournamentPhoto => '🏆 Tournament Photo';

  @override
  String get tournamentJoinedUploadPhoto =>
      'You joined the tournament! Now upload your tournament photo.';

  @override
  String get uploadLater => 'Upload Later';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get tournamentPhotoUploaded => '✅ Tournament photo uploaded!';

  @override
  String get photoUploadError => '❌ Error occurred while uploading photo!';

  @override
  String get noVotingForTournament => 'No voting found for this tournament';

  @override
  String votingLoadError(Object error) {
    return 'Error loading voting: $error';
  }

  @override
  String get whichParticipantPrefer => 'Which participant do you prefer?';

  @override
  String get voteSavedSuccessfully => 'Your vote has been saved successfully!';

  @override
  String get noActiveTournament => 'No active tournament currently';

  @override
  String get registration => 'Registration';

  @override
  String get upcoming => 'Upcoming';

  @override
  String coinPrize(Object prize) {
    return '$prize coin prize';
  }

  @override
  String startDate(Object date) {
    return 'Start: $date';
  }

  @override
  String get completed => 'Completed';

  @override
  String get join => 'Join';

  @override
  String get photo => 'Photo';

  @override
  String get languageChanged => 'Idioma cambiado';

  @override
  String get lightWhiteTheme => 'Tema claro de material blanco';

  @override
  String get neutralDarkGrayTheme => 'Neutral dark gray theme';

  @override
  String themeChanged(Object theme) {
    return 'Theme changed: $theme';
  }

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone! All your data will be permanently deleted.\nAre you sure you want to delete your account?';

  @override
  String get accountDeleted => 'Your account has been deleted';

  @override
  String get logoutButton => 'Cerrar Sesión';

  @override
  String get themeSelection => '🎨 Selección de Tema';

  @override
  String get darkMaterialTheme => 'Tema oscuro de material negro';

  @override
  String get lightPinkTheme => 'Tema de color rosa claro';

  @override
  String get notificationSettings => '🔔 Configuración de Notificaciones';

  @override
  String get allNotifications => 'Todas las Notificaciones';

  @override
  String get allNotificationsSubtitle =>
      'Activar/desactivar notificaciones principales';

  @override
  String get voteReminder => 'Vote Reminder';

  @override
  String get winCelebration => 'Win Celebration';

  @override
  String get streakReminder => 'Streak Reminder';

  @override
  String get streakReminderSubtitle => 'Daily streak reward reminders';

  @override
  String get moneyAndCoins => '💰 Money & Coin Transactions';

  @override
  String get purchaseCoinPackage => 'Purchase Coin Package';

  @override
  String get purchaseCoinPackageSubtitle => 'Buy coins and earn rewards';

  @override
  String get appSettings => '⚙️ App Settings';

  @override
  String get dailyRewards => 'Daily Rewards';

  @override
  String get dailyRewardsSubtitle => 'View streak rewards and boosts';

  @override
  String get aboutApp => 'About App';

  @override
  String get accountOperations => '👤 Account Operations';

  @override
  String get dailyStreakRewards => 'Daily Streak Rewards';

  @override
  String get dailyStreakDescription =>
      '🎯 Log in to the app every day and earn bonuses!';

  @override
  String get appDescription => 'Voting and tournament app in chat rooms.';

  @override
  String get predictWinRateTitle => 'Predict win rate!';

  @override
  String get wrongPredictionNoCoin => 'Wrong prediction = 0 coins';

  @override
  String get selectWinRateRange => 'Select Win Rate Range:';

  @override
  String get wrongPrediction => 'Wrong Prediction';

  @override
  String get correctPredictionMessage => 'You predicted correctly!';

  @override
  String actualRate(Object rate) {
    return 'Actual rate: $rate%';
  }

  @override
  String get earnedOneCoin => '+1 coin earned!';

  @override
  String myPhotos(Object count) {
    return 'My Photos ($count/5)';
  }

  @override
  String get photoCostInfo =>
      'First photo is free, others cost coins. You can view statistics for all photos.';

  @override
  String get addAge => 'Add Age';

  @override
  String get addCountry => 'Add Country';

  @override
  String get addGender => 'Add Gender';

  @override
  String get countrySelection => 'Country Selection';

  @override
  String countriesSelected(Object count) {
    return '$count countries selected';
  }

  @override
  String get allCountriesSelected => 'All countries selected';

  @override
  String get ageRangeSelection => 'Age Range Selection';

  @override
  String ageRangesSelected(Object count) {
    return '$count age ranges selected';
  }

  @override
  String get allAgeRangesSelected => 'All age ranges selected';

  @override
  String get editUsername => 'Edit Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get editAge => 'Edit Age';

  @override
  String get enterAge => 'Enter your age';

  @override
  String get selectCountry => 'Select Country';

  @override
  String get selectYourCountry => 'Select your country';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get selectYourGender => 'Select your gender';

  @override
  String get editInstagram => 'Edit Instagram Account';

  @override
  String get enterInstagram => 'Enter your Instagram username (without @)';

  @override
  String get editProfession => 'Edit Profession';

  @override
  String get enterProfession => 'Enter your profession';

  @override
  String get infoUpdated => 'Information updated';

  @override
  String get countryPreferencesUpdated => '✅ Country preferences updated';

  @override
  String get countryPreferencesUpdateFailed =>
      '❌ Country preferences could not be updated';

  @override
  String get ageRangePreferencesUpdated => '✅ Age range preferences updated';

  @override
  String get ageRangePreferencesUpdateFailed =>
      '❌ Age range preferences could not be updated';

  @override
  String winRateAndMatches(Object matches, Object winRate) {
    return '$winRate win rate • $matches matches';
  }

  @override
  String get mostWins => 'Más Victorias';

  @override
  String get highestWinRate => 'Highest Win Rate';

  @override
  String get noWinsYet =>
      'No wins yet!\nPlay your first match and enter the leaderboard!';

  @override
  String get noWinRateYet =>
      'No win rate yet!\nPlay matches to increase your win rate!';

  @override
  String get matchHistoryViewing => 'Match history viewing';

  @override
  String winRateColon(Object winRate) {
    return 'Win Rate: $winRate';
  }

  @override
  String matchesAndWins(Object matches, Object wins) {
    return '$matches matches • $wins wins';
  }

  @override
  String get youWon => 'You Won';

  @override
  String get youLost => 'You Lost';

  @override
  String get lastFiveMatchStats => '📊 Last 5 Match Statistics';

  @override
  String get noMatchHistoryYet =>
      'No match history yet!\nPlay your first match!';

  @override
  String get premiumFeature => '🔒 Premium Feature';

  @override
  String get save => 'Guardar';

  @override
  String get leaderboardTitle => '🏆 Leaderboard';

  @override
  String get day1_2Reward => 'Day 1-2: 10-25 Coin';

  @override
  String get day3_6Reward => 'Day 3-6: 50-100 Coin';

  @override
  String get day7PlusReward => 'Day 7+: 200+ Coin & Boost';

  @override
  String get photoStatsLoadError => 'Could not load photo statistics';

  @override
  String get tournamentNotifications => 'Notificaciones de Torneos';

  @override
  String get newTournamentInvitations => 'New tournament invitations';

  @override
  String get victoryNotifications => 'Victory notifications';

  @override
  String get vote => 'Votar';
}
