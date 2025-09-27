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
  String get profession => 'Profesión';

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
  String get leaderboard => '🏆 Liderazgo';

  @override
  String get tournament => 'Torneo';

  @override
  String get language => 'Idioma';

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
  String get currentStreak => 'Racha Actual';

  @override
  String get totalStreakDays => 'Total de Días de Racha';

  @override
  String get predictionStats => 'Estadísticas de Predicción';

  @override
  String get totalPredictions => 'Total de Predicciones';

  @override
  String get correctPredictions => 'Predicciones Correctas';

  @override
  String get accuracy => 'Precisión';

  @override
  String coinsEarnedFromPredictions(int coins) {
    return 'Monedas Ganadas de Predicciones: $coins monedas';
  }

  @override
  String get congratulations => '¡Felicidades!';

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
  String get invalidEmail =>
      '❌ ¡Dirección de correo electrónico inválida! Por favor ingrese un formato de correo válido.';

  @override
  String get userNotFoundError =>
      '❌ ¡No se encontró usuario con esta dirección de correo electrónico!';

  @override
  String get userAlreadyRegistered =>
      '❌ ¡Esta dirección de correo electrónico ya está registrada! Intente iniciar sesión.';

  @override
  String get invalidPassword =>
      '❌ ¡Contraseña incorrecta! Por favor verifique su contraseña.';

  @override
  String get passwordMinLengthError =>
      '❌ ¡La contraseña debe tener al menos 6 caracteres!';

  @override
  String get passwordTooWeak =>
      '❌ ¡La contraseña es muy débil! Elija una contraseña más fuerte.';

  @override
  String get usernameAlreadyTaken =>
      '❌ ¡Este nombre de usuario ya está tomado! Elija otro nombre de usuario.';

  @override
  String get usernameTooShort =>
      '❌ ¡El nombre de usuario debe tener al menos 3 caracteres!';

  @override
  String get networkError => '❌ ¡Verifique su conexión a internet!';

  @override
  String get timeoutError =>
      '❌ ¡Tiempo de conexión agotado! Por favor intente de nuevo.';

  @override
  String get emailNotConfirmed =>
      '❌ ¡Necesita confirmar su dirección de correo electrónico!';

  @override
  String get tooManyRequests =>
      '❌ ¡Demasiados intentos! Por favor espere unos minutos e intente de nuevo.';

  @override
  String get accountDisabled => '❌ ¡Su cuenta ha sido deshabilitada!';

  @override
  String get duplicateData =>
      '❌ ¡Esta información ya está en uso! Intente con información diferente.';

  @override
  String get invalidData =>
      '❌ ¡Hay un error en la información que ingresó! Por favor verifique.';

  @override
  String get invalidCredentials =>
      '❌ ¡El correo electrónico o la contraseña son incorrectos!';

  @override
  String get tooManyEmails =>
      '❌ ¡Demasiados correos electrónicos enviados! Por favor espere.';

  @override
  String get operationFailed =>
      '❌ ¡Operación fallida! Por favor verifique su información.';

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
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get registrationSuccessful => '¡Registro exitoso!';

  @override
  String get userAlreadyExists =>
      'Este usuario ya está registrado o ocurrió un error';

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
  String get allPhotoSlotsFull =>
      '¡Todos los espacios de fotos adicionales están llenos!';

  @override
  String photoUploadSlot(int slot) {
    return 'Subir Foto - Espacio $slot';
  }

  @override
  String coinsRequiredForSlot(int coins) {
    return 'Se requieren $coins monedas para este espacio.';
  }

  @override
  String get insufficientCoinsForUpload =>
      '¡Monedas insuficientes! Usa el botón de monedas en la página de perfil para comprar monedas.';

  @override
  String get cancel => 'Cancelar';

  @override
  String upload(int coins) {
    return 'Subir ($coins monedas)';
  }

  @override
  String photoUploaded(int coinsSpent) {
    return '¡Foto subida! $coinsSpent monedas gastadas.';
  }

  @override
  String get deletePhoto => 'Eliminar Foto';

  @override
  String get confirmDeletePhoto =>
      '¿Estás seguro de que quieres eliminar esta foto?';

  @override
  String get delete => 'Eliminar';

  @override
  String get photoDeleted => '¡Foto eliminada!';

  @override
  String get selectFromGallery => 'Seleccionar de Galería';

  @override
  String get takeFromCamera => 'Tomar de Cámara';

  @override
  String get additionalMatchPhotos => 'Fotos Adicionales de Partidos';

  @override
  String get addPhoto => 'Agregar Foto';

  @override
  String additionalPhotosDescription(int count) {
    return 'Tus fotos adicionales que aparecerán en los partidos ($count/4)';
  }

  @override
  String get noAdditionalPhotos => 'Aún no hay fotos adicionales';

  @override
  String get secondPhotoCost => '¡2ª foto cuesta 50 monedas!';

  @override
  String get premiumInfoAdded =>
      '¡Información premium agregada! Puedes configurar la visibilidad desde abajo.';

  @override
  String get premiumInfoVisibility => '💎 Visibilidad de Información Premium';

  @override
  String get premiumInfoDescription =>
      'Otros usuarios pueden ver esta información gastando monedas';

  @override
  String get instagramAccount => 'Cuenta de Instagram';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get predictionStatistics => '🎯 Estadísticas de Predicción';

  @override
  String get matchHistory => '📊 Historial de Partidos';

  @override
  String get viewLastFiveMatches =>
      'Ver tus últimos 5 partidos y oponentes (5 monedas)';

  @override
  String get visibleInMatches => 'Visible en Partidos';

  @override
  String get nowVisibleInMatches => '¡Ahora aparecerás en los partidos!';

  @override
  String get removedFromMatches => '¡Removido de los partidos!';

  @override
  String addInfo(String type) {
    return 'Agregar $type';
  }

  @override
  String enterInfo(String type) {
    return 'Ingresa tu información de $type:';
  }

  @override
  String get add => 'Agregar';

  @override
  String infoAdded(String type) {
    return '✅ ¡Información de $type agregada!';
  }

  @override
  String get errorAddingInfo => '❌ ¡Error al agregar información!';

  @override
  String get matchInfoNotLoaded =>
      'No se pudieron cargar los datos del partido';

  @override
  String premiumInfo(String type) {
    return '💎 Información de $type';
  }

  @override
  String get spendFiveCoins => 'Gastar 5 Monedas';

  @override
  String get insufficientCoins => '❌ ¡Monedas insuficientes!';

  @override
  String get fiveCoinsSpent => '✅ 5 monedas gastadas';

  @override
  String get ok => 'OK';

  @override
  String matchCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get spendFiveCoinsToView =>
      'Gastarás 5 monedas para ver esta información';

  @override
  String get great => '¡Genial!';

  @override
  String get homePage => 'Página de Inicio';

  @override
  String streakMessage(int days) {
    return '¡$days días de racha!';
  }

  @override
  String get purchaseCoins => 'Purchase Coins';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get dailyAdLimit => 'You can watch maximum 5 ads per day';

  @override
  String get coinsPerAd => 'Coins per ad: 20';

  @override
  String get watchAdButton => 'Watch Ad';

  @override
  String get dailyLimitReached => 'Daily limit reached';

  @override
  String get recentTransactions => 'Recent Transactions:';

  @override
  String get noTransactionHistory => 'No transaction history yet';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to logout from your account?';

  @override
  String logoutError(String error) {
    return 'Error occurred while logging out';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get typeDeleteToConfirm => 'To delete your account, type \"DELETE\":';

  @override
  String get pleaseTypeDelete => 'Please type \"DELETE\"!';

  @override
  String get accountDeletedSuccessfully =>
      'Your account has been successfully deleted!';

  @override
  String errorDeletingAccount(String error) {
    return 'Error occurred while deleting account';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Error occurred while watching ad';
  }

  @override
  String get watchingAd => 'Watching Ad';

  @override
  String get adLoading => 'Ad loading...';

  @override
  String get adSimulation =>
      'This is a simulation ad. In the real app, an actual ad will be shown here.';

  @override
  String get adWatched => 'Ad watched! +20 coins earned!';

  @override
  String get errorAddingCoins => 'Error occurred while adding coins';

  @override
  String get buy => 'Comprar';

  @override
  String get predict => 'Predecir';

  @override
  String get fiveCoinsSpentForHistory =>
      '✅ ¡5 monedas gastadas! Tu historial de partidos se está mostrando.';

  @override
  String get insufficientCoinsForHistory => '❌ ¡Monedas insuficientes!';

  @override
  String get spendFiveCoinsForHistory => 'Gastar 5 Monedas';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins victorias • $matches partidos';
  }

  @override
  String get insufficientCoinsForTournament =>
      '¡Monedas insuficientes para el torneo!';

  @override
  String get joinedTournament => '¡Te uniste al torneo!';

  @override
  String get tournamentJoinFailed => '¡Fallo al unirse al torneo!';

  @override
  String get dailyStreak => '¡Racha Diaria!';

  @override
  String get imageUpdated => '¡Imagen actualizada!';

  @override
  String get updateFailed => 'Actualización fallida';

  @override
  String get imageUpdateFailed => '¡No se pudo actualizar la imagen!';

  @override
  String get selectImage => 'Seleccionar Imagen';

  @override
  String get userInfoNotLoaded => 'No se pudieron cargar los datos del usuario';

  @override
  String get coin => 'Moneda';

  @override
  String get premiumFeatures => 'Características Premium';

  @override
  String get addInstagram => 'Agregar Cuenta de Instagram';

  @override
  String get addProfession => 'Agregar Profesión';

  @override
  String get profileUpdated => '¡Perfil actualizado!';

  @override
  String get profileUpdateFailed => 'Error al actualizar el perfil';

  @override
  String get profileSettings => 'Configuración de Perfil';

  @override
  String get passwordReset => 'Restablecer Contraseña';

  @override
  String get passwordResetSubtitle =>
      'Restablecer contraseña por correo electrónico';

  @override
  String get logoutSubtitle => 'Cerrar sesión segura de tu cuenta';

  @override
  String get deleteAccountSubtitle => 'Eliminar tu cuenta permanentemente';

  @override
  String get updateProfile => 'Actualizar Perfil';

  @override
  String get passwordResetTitle => 'Restablecimiento de Contraseña';

  @override
  String get passwordResetMessage =>
      'Se enviará un enlace de restablecimiento de contraseña a tu dirección de correo electrónico. ¿Quieres continuar?';

  @override
  String get send => 'Enviar';

  @override
  String get passwordResetSent =>
      '¡Correo de restablecimiento de contraseña enviado!';

  @override
  String get emailNotFound => '¡Dirección de correo electrónico no encontrada!';

  @override
  String votingError(Object error) {
    return 'Error durante la votación';
  }

  @override
  String slot(Object slot) {
    return 'Espacio $slot';
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
  String get tournamentFees => 'Tournament participation fees';

  @override
  String get weeklyMaleTournament1000 => 'Weekly Male Tournament (1000 Coins)';

  @override
  String get weeklyMaleTournament1000Desc =>
      'Weekly male tournament - 300 person capacity';

  @override
  String get weeklyMaleTournament10000 =>
      'Weekly Male Tournament (10000 Coins)';

  @override
  String get weeklyMaleTournament10000Desc =>
      'Premium male tournament - 100 person capacity';

  @override
  String get weeklyFemaleTournament1000 =>
      'Weekly Female Tournament (1000 Coins)';

  @override
  String get weeklyFemaleTournament1000Desc =>
      'Weekly female tournament - 300 person capacity';

  @override
  String get weeklyFemaleTournament10000 =>
      'Weekly Female Tournament (10000 Coins)';

  @override
  String get weeklyFemaleTournament10000Desc =>
      'Premium female tournament - 100 person capacity';

  @override
  String get tournamentEntryFee => 'Tournament entry fee';

  @override
  String get tournamentVotingTitle => 'Tournament Voting';

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
      'You will earn 1 coin for correct prediction!';

  @override
  String get wrongPredictionMessage =>
      'Predicción incorrecta. La tasa de victoria real fue null%';

  @override
  String get predictionSaveError => 'Error occurred while saving prediction';

  @override
  String get coinAddError => 'Error occurred while adding coins';

  @override
  String coinPurchaseTransaction(Object description) {
    return 'Coin purchase - $description';
  }

  @override
  String get whiteThemeName => 'White';

  @override
  String get darkThemeName => 'Dark';

  @override
  String get pinkThemeName => 'Pink';

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
  String get languageChanged => 'Language changed. Refreshing page...';

  @override
  String get lightWhiteTheme => 'White material light theme';

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
  String get logoutButton => 'Logout';

  @override
  String get themeSelection => '🎨 Theme Selection';

  @override
  String get darkMaterialTheme => 'Black material dark theme';

  @override
  String get lightPinkTheme => 'Light pink color theme';

  @override
  String get notificationSettings => '🔔 Notification Settings';

  @override
  String get allNotifications => 'All Notifications';

  @override
  String get allNotificationsSubtitle => 'Turn on/off main notifications';

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
  String get correctPredictionMessage =>
      '¡Predijiste correctamente y ganaste 1 moneda!';

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
  String get mostWins => 'Most Wins';

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
  String get save => 'Save';

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
  String get tournamentNotifications => 'Tournament Notifications';

  @override
  String get newTournamentInvitations => 'New tournament invitations';

  @override
  String get victoryNotifications => 'Victory notifications';

  @override
  String get vote => 'Vote';
}
