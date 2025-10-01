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
    return 'Predice la tasa de victoria de $username';
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
      '¡Predijiste correctamente y ganaste 1 moneda!';

  @override
  String wrongPredictionWithRate(double winRate) {
    return 'Predicción incorrecta. La tasa de victoria real fue $winRate%';
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
  String get accountDeletedPleaseRegister =>
      '❌ Su cuenta ha sido eliminada. Por favor cree una cuenta nueva.';

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
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

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
    return 'Foto Subida';
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
  String get purchaseCoins => 'Comprar Monedas';

  @override
  String get watchAd => 'Ver Anuncio';

  @override
  String get dailyAdLimit => 'Puedes ver un máximo de 5 anuncios por día';

  @override
  String get coinsPerAd => 'Monedas por anuncio: 20';

  @override
  String get watchAdButton => 'Ver Anuncio';

  @override
  String get dailyLimitReached => 'Límite diario alcanzado';

  @override
  String get recentTransactions => 'Transacciones Recientes:';

  @override
  String get noTransactionHistory => 'Aún no hay historial de transacciones';

  @override
  String get accountSettings => 'Configuración de Cuenta';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirmation =>
      '¿Estás seguro de que quieres cerrar sesión de tu cuenta?';

  @override
  String logoutError(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirmation =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y todos tus datos serán eliminados permanentemente.';

  @override
  String get finalConfirmation => 'Confirmación Final';

  @override
  String get typeDeleteToConfirm =>
      'Para eliminar tu cuenta, escribe \"DELETE\":';

  @override
  String get pleaseTypeDelete => '¡Por favor escribe \"DELETE\"!';

  @override
  String get accountDeletedSuccessfully =>
      '¡Tu cuenta ha sido eliminada exitosamente!';

  @override
  String errorDeletingAccount(String error) {
    return 'Error al eliminar cuenta: $error';
  }

  @override
  String errorWatchingAd(String error) {
    return 'Error al ver anuncio: $error';
  }

  @override
  String get watchingAd => 'Viendo Anuncio';

  @override
  String get adLoading => 'Cargando anuncio...';

  @override
  String get adSimulation =>
      'Este es un anuncio simulado. En la aplicación real, se mostraría un anuncio real aquí.';

  @override
  String get adWatched => '¡Anuncio visto! +20 monedas ganadas!';

  @override
  String get errorAddingCoins => 'Error al agregar monedas';

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
  String get spendFiveCoinsForHistory =>
      'Gastar 5 monedas para ver tus últimos 5 partidos y oponentes';

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
  String get deleteAccountSubtitle => 'Eliminar permanentemente tu cuenta';

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
    return 'Error durante la votación: $error';
  }

  @override
  String slot(Object slot) {
    return 'Espacio $slot';
  }

  @override
  String get instagramAdded => '¡Información de Instagram agregada!';

  @override
  String get professionAdded => '¡Información de profesión agregada!';

  @override
  String get addInstagramFromSettings =>
      'Puedes usar esta función agregando información de Instagram y profesión desde configuración';

  @override
  String get basicInfo => 'Información Básica';

  @override
  String get premiumInfoSettings => 'Información Premium';

  @override
  String get premiumInfoDescriptionSettings =>
      'Otros usuarios pueden ver esta información gastando monedas';

  @override
  String get coinInfo => 'Información de Monedas';

  @override
  String currentCoins(int coins) {
    return 'Monedas Actuales: $coins';
  }

  @override
  String get remaining => 'Restante';

  @override
  String get vs => 'VS';

  @override
  String get coinPurchase => 'Compra de Monedas';

  @override
  String get purchaseSuccessful => '¡Compra exitosa!';

  @override
  String get purchaseFailed => '¡Compra fallida!';

  @override
  String get coinPackages => 'Paquetes de Monedas';

  @override
  String get coinUsage => 'Uso de Monedas';

  @override
  String get instagramView => 'Ver cuentas de Instagram';

  @override
  String get professionView => 'Ver información de profesión';

  @override
  String get statsView => 'Ver estadísticas detalladas';

  @override
  String get tournamentFees => 'Tarifas de participación en torneos';

  @override
  String get weeklyMaleTournament1000 =>
      'Torneo Masculino Semanal (1000 Monedas)';

  @override
  String get weeklyMaleTournament1000Desc =>
      'Torneo masculino semanal - capacidad de 300 personas';

  @override
  String get weeklyMaleTournament10000 =>
      'Torneo Masculino Semanal (10000 Monedas)';

  @override
  String get weeklyMaleTournament10000Desc =>
      'Torneo masculino premium - capacidad de 100 personas';

  @override
  String get weeklyFemaleTournament1000 =>
      'Torneo Femenino Semanal (1000 Monedas)';

  @override
  String get weeklyFemaleTournament1000Desc =>
      'Torneo femenino semanal - capacidad de 300 personas';

  @override
  String get weeklyFemaleTournament10000 =>
      'Torneo Femenino Semanal (10000 Monedas)';

  @override
  String get weeklyFemaleTournament10000Desc =>
      'Torneo femenino premium - capacidad de 100 personas';

  @override
  String get tournamentEntryFee => 'Tarifa de entrada al torneo';

  @override
  String get tournamentVotingTitle => 'Votación del Torneo';

  @override
  String get tournamentThirdPlace => '3er lugar del torneo';

  @override
  String get tournamentWon => 'Torneo ganado';

  @override
  String get userNotLoggedIn => 'Usuario no conectado';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get firstLoginReward =>
      '🎉 ¡Primer inicio de sesión! ¡Ganaste 50 monedas!';

  @override
  String streakReward(Object coins, Object streak) {
    return '🔥 ¡Racha de $streak días! ¡Ganaste $coins monedas!';
  }

  @override
  String get streakBroken =>
      '💔 ¡Racha rota! Nuevo inicio: ¡Ganaste 50 monedas!';

  @override
  String dailyStreakReward(Object streak) {
    return 'Recompensa de racha diaria ($streak días)';
  }

  @override
  String get alreadyLoggedInToday => '¡Ya iniciaste sesión hoy!';

  @override
  String get streakCheckError => 'Error durante la verificación de racha';

  @override
  String get streakInfoError => 'No se pudo obtener información de racha';

  @override
  String get correctPredictionReward =>
      '¡Ganarás 1 moneda por predicción correcta!';

  @override
  String get wrongPredictionMessage =>
      'Desafortunadamente, predijiste incorrectamente.';

  @override
  String get predictionSaveError => 'Error al guardar predicción';

  @override
  String get coinAddError => 'Error al agregar monedas';

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
  String get premiumFilters => 'Filtros premium';

  @override
  String get viewStats => 'Ver Estadísticas';

  @override
  String get photoStats => 'Estadísticas de Fotos';

  @override
  String get photoStatsCost => 'Ver estadísticas de fotos cuesta 50 monedas';

  @override
  String get insufficientCoinsForStats =>
      'Monedas insuficientes para ver estadísticas de fotos. Requerido: 50 monedas';

  @override
  String get pay => 'Pagar';

  @override
  String get tournamentVotingSaved => '¡Votación del torneo guardada!';

  @override
  String get tournamentVotingFailed => '¡Votación del torneo fallida!';

  @override
  String get tournamentVoting => 'VOTACIÓN DEL TORNEO';

  @override
  String get whichTournamentParticipant =>
      '¿Qué participante del torneo prefieres?';

  @override
  String ageYears(Object age, Object country) {
    return '$age años • $country';
  }

  @override
  String get clickToOpenInstagram => '📱 Haz clic para abrir Instagram';

  @override
  String get openInstagram => 'Abrir Instagram';

  @override
  String get instagramCannotBeOpened =>
      '❌ No se pudo abrir Instagram. Por favor verifica tu aplicación de Instagram.';

  @override
  String instagramOpenError(Object error) {
    return '❌ Error al abrir Instagram: $error';
  }

  @override
  String get tournamentPhoto => '🏆 Foto del Torneo';

  @override
  String get tournamentJoinedUploadPhoto =>
      '¡Te uniste al torneo! Ahora sube tu foto del torneo.';

  @override
  String get uploadLater => 'Subir Más Tarde';

  @override
  String get uploadPhoto => 'Subir Foto';

  @override
  String get tournamentPhotoUploaded => '✅ ¡Foto del torneo subida!';

  @override
  String get photoUploadError => '❌ ¡Error al subir foto!';

  @override
  String get noVotingForTournament =>
      'No se encontró votación para este torneo';

  @override
  String votingLoadError(Object error) {
    return 'Error al cargar votación: $error';
  }

  @override
  String get whichParticipantPrefer => '¿Qué participante prefieres?';

  @override
  String get voteSavedSuccessfully => '¡Tu voto ha sido guardado exitosamente!';

  @override
  String get noActiveTournament => 'No hay torneo activo actualmente';

  @override
  String get registration => 'Registro';

  @override
  String get upcoming => 'Próximo';

  @override
  String coinPrize(Object prize) {
    return 'Premio de $prize monedas';
  }

  @override
  String startDate(Object date) {
    return 'Inicio: $date';
  }

  @override
  String get completed => 'Completado';

  @override
  String get join => 'Unirse';

  @override
  String get photo => 'Foto';

  @override
  String get languageChanged => 'Idioma cambiado. Actualizando página...';

  @override
  String get lightWhiteTheme => 'Tema claro blanco material';

  @override
  String get neutralDarkGrayTheme => 'Tema gris oscuro neutro';

  @override
  String themeChanged(Object theme) {
    return 'Tema cambiado: $theme';
  }

  @override
  String get deleteAccountWarning =>
      '¡Esta acción no se puede deshacer! Todos tus datos serán eliminados permanentemente.\n¿Estás seguro de que quieres eliminar tu cuenta?';

  @override
  String get accountDeleted => 'Tu cuenta ha sido eliminada';

  @override
  String get logoutButton => 'Cerrar Sesión';

  @override
  String get themeSelection => '🎨 Selección de Tema';

  @override
  String get darkMaterialTheme => 'Tema oscuro negro material';

  @override
  String get lightPinkTheme => 'Tema de color rosa claro';

  @override
  String get notificationSettings => 'Configuración de Notificaciones';

  @override
  String get allNotifications => 'Todas las Notificaciones';

  @override
  String get allNotificationsSubtitle =>
      'Activar/desactivar notificaciones principales';

  @override
  String get voteReminder => 'Recordatorio de Voto';

  @override
  String get winCelebration => 'Celebración de Victoria';

  @override
  String get streakReminder => 'Recordatorio de Racha';

  @override
  String get streakReminderSubtitle =>
      'Recordatorios de recompensas de racha diaria';

  @override
  String get moneyAndCoins => '💰 Dinero y Transacciones de Monedas';

  @override
  String get purchaseCoinPackage => 'Comprar Paquete de Monedas';

  @override
  String get purchaseCoinPackageSubtitle =>
      'Comprar monedas y ganar recompensas';

  @override
  String get appSettings => '⚙️ Configuración de la Aplicación';

  @override
  String get dailyRewards => 'Recompensas Diarias';

  @override
  String get dailyRewardsSubtitle => 'Ver recompensas de racha y mejoras';

  @override
  String get aboutApp => 'Acerca de la Aplicación';

  @override
  String get accountOperations => '👤 Operaciones de Cuenta';

  @override
  String get dailyStreakRewards => 'Recompensas de Racha Diaria';

  @override
  String get dailyStreakDescription =>
      '🎯 ¡Inicia sesión en la aplicación todos los días y gana bonificaciones!';

  @override
  String get appDescription =>
      'Aplicación de votación y torneos en salas de chat.';

  @override
  String get predictWinRateTitle => '¡Predice la tasa de victoria!';

  @override
  String get wrongPredictionNoCoin => 'Predicción incorrecta = 0 monedas';

  @override
  String get selectWinRateRange => 'Seleccionar Rango de Tasa de Victoria:';

  @override
  String get wrongPrediction => 'Predicción Incorrecta';

  @override
  String get correctPredictionMessage => '¡Predijiste correctamente!';

  @override
  String actualRate(Object rate) {
    return 'Tasa real: $rate%';
  }

  @override
  String get earnedOneCoin => '¡+1 moneda ganada!';

  @override
  String myPhotos(Object count) {
    return 'Mis Fotos ($count/5)';
  }

  @override
  String get photoCostInfo =>
      'La primera foto es gratuita, las otras cuestan monedas. Puedes ver estadísticas de todas las fotos.';

  @override
  String get addAge => 'Agregar Edad';

  @override
  String get addCountry => 'Agregar País';

  @override
  String get addGender => 'Agregar Género';

  @override
  String get countrySelection => 'Selección de País';

  @override
  String countriesSelected(Object count) {
    return '$count países seleccionados';
  }

  @override
  String get allCountriesSelected => 'Todos los países seleccionados';

  @override
  String get ageRangeSelection => 'Selección de Rango de Edad';

  @override
  String ageRangesSelected(Object count) {
    return '$count rangos de edad seleccionados';
  }

  @override
  String get allAgeRangesSelected => 'Todos los rangos de edad seleccionados';

  @override
  String get editUsername => 'Editar Nombre de Usuario';

  @override
  String get enterUsername => 'Ingresa tu nombre de usuario';

  @override
  String get editAge => 'Editar Edad';

  @override
  String get enterAge => 'Ingresa tu edad';

  @override
  String get selectCountry => 'Seleccionar País';

  @override
  String get selectYourCountry => 'Selecciona tu país';

  @override
  String get selectGender => 'Seleccionar Género';

  @override
  String get selectYourGender => 'Selecciona tu género';

  @override
  String get editInstagram => 'Editar Cuenta de Instagram';

  @override
  String get enterInstagram =>
      'Ingresa tu nombre de usuario de Instagram (sin @)';

  @override
  String get editProfession => 'Editar Profesión';

  @override
  String get enterProfession => 'Ingresa tu profesión';

  @override
  String get infoUpdated => 'Información actualizada';

  @override
  String get countryPreferencesUpdated => '✅ Preferencias de país actualizadas';

  @override
  String get countryPreferencesUpdateFailed =>
      '❌ No se pudieron actualizar las preferencias de país';

  @override
  String get ageRangePreferencesUpdated =>
      '✅ Preferencias de rango de edad actualizadas';

  @override
  String get ageRangePreferencesUpdateFailed =>
      '❌ No se pudieron actualizar las preferencias de rango de edad';

  @override
  String winRateAndMatches(Object matches, Object winRate) {
    return '$winRate tasa de victoria • $matches partidos';
  }

  @override
  String get mostWins => 'Más Victorias';

  @override
  String get highestWinRate => 'Mayor Tasa de Victoria';

  @override
  String get noWinsYet =>
      '¡Aún no hay victorias!\n¡Juega tu primer partido y entra en la tabla de clasificación!';

  @override
  String get noWinRateYet =>
      '¡Aún no hay tasa de victoria!\n¡Juega partidos para aumentar tu tasa de victoria!';

  @override
  String get matchHistoryViewing => 'Visualización del historial de partidos';

  @override
  String winRateColon(Object winRate) {
    return 'Tasa de Victoria: $winRate';
  }

  @override
  String matchesAndWins(Object matches, Object wins) {
    return '$matches partidos • $wins victorias';
  }

  @override
  String get youWon => 'Ganaste';

  @override
  String get youLost => 'Perdiste';

  @override
  String get lastFiveMatchStats => '📊 Estadísticas de los Últimos 5 Partidos';

  @override
  String get noMatchHistoryYet =>
      '¡Aún no hay historial de partidos!\n¡Juega tu primer partido!';

  @override
  String get premiumFeature => '🔒 Característica Premium';

  @override
  String get save => 'Guardar';

  @override
  String get leaderboardTitle => '🏆 Tabla de Clasificación';

  @override
  String get day1_2Reward => 'Día 1-2: 10-25 Monedas';

  @override
  String get day3_6Reward => 'Día 3-6: 50-100 Monedas';

  @override
  String get day7PlusReward => 'Día 7+: 200+ Monedas y Mejora';

  @override
  String get photoStatsLoadError =>
      'No se pudieron cargar las estadísticas de fotos';

  @override
  String get tournamentNotifications => 'Notificaciones de Torneos';

  @override
  String get newTournamentInvitations => 'Nuevas invitaciones de torneo';

  @override
  String get victoryNotifications => 'Notificaciones de victoria';

  @override
  String get vote => 'Votar';

  @override
  String get lastFiveMatches => 'Últimos 5 Partidos';

  @override
  String get total => 'Total';

  @override
  String get losses => 'Derrotas';

  @override
  String get rate => 'Tasa';

  @override
  String get ongoing => 'En Curso';

  @override
  String get tournamentFull => 'Torneo Lleno';

  @override
  String get active => 'Activo';

  @override
  String get joinWithKey => 'Unirse con Clave';

  @override
  String get private => 'Privado';

  @override
  String get countryRanking => 'Ranking de Países';

  @override
  String get countryRankingSubtitle =>
      'Qué tan exitoso eres contra ciudadanos de diferentes países';

  @override
  String get countryRankingTitle => 'Ranking de Países';

  @override
  String get countryRankingDescription =>
      'Qué tan exitoso eres contra ciudadanos de diferentes países';

  @override
  String get winsAgainst => 'Victorias';

  @override
  String get lossesAgainst => 'Derrotas';

  @override
  String get winRateAgainst => 'Tasa de Victoria';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get loadingCountryStats => 'Cargando estadísticas de países...';

  @override
  String get countryStats => 'Estadísticas de Países';

  @override
  String get yourPerformance => 'Tu Rendimiento';

  @override
  String get againstCountry => 'Comparación de Países';

  @override
  String get retry => 'Reintentar';

  @override
  String get alreadyJoinedTournament => 'Ya te has unido a este torneo';

  @override
  String get uploadTournamentPhoto => 'Subir Foto del Torneo';

  @override
  String get viewTournament => 'Ver Torneo';

  @override
  String get tournamentParticipants => 'Participantes del Torneo';

  @override
  String get yourRank => 'Tu Posición';

  @override
  String get rank => 'Posición';

  @override
  String get participant => 'Participante';

  @override
  String get photoNotUploaded => 'Foto No Subida';

  @override
  String get uploadPhotoUntilWednesday =>
      'Puedes subir la foto hasta el miércoles';

  @override
  String get tournamentStarted => 'Torneo Iniciado';

  @override
  String get viewTournamentPhotos => 'Ver Fotos del Torneo';

  @override
  String get genderMismatch => 'Incompatibilidad de Género';

  @override
  String get photoAlreadyUploaded => 'Foto Ya Subida';

  @override
  String get viewParticipantPhoto => 'Ver Foto del Participante';

  @override
  String get selectPhoto => 'Seleccionar Foto';

  @override
  String get photoUploadFailed => 'Error al Subir Foto';

  @override
  String get tournamentCancelled => 'Torneo Cancelado';

  @override
  String get refundFailed => 'Reembolso Fallido';

  @override
  String get createPrivateTournament => 'Crear Torneo Privado';

  @override
  String get tournamentName => 'Nombre del Torneo';

  @override
  String get maxParticipants => 'Máximo de Participantes';

  @override
  String get tournamentFormat => 'Formato del Torneo';

  @override
  String get leagueFormat => 'Formato de Liga';

  @override
  String get eliminationFormat => 'Formato de Eliminación';

  @override
  String get hybridFormat => 'Liga + Eliminación';

  @override
  String get eliminationMaxParticipants =>
      'Máximo 8 participantes para formato de eliminación';

  @override
  String get eliminationMaxParticipantsWarning =>
      'Máximo 8 participantes permitidos para formato de eliminación';

  @override
  String get weeklyMaleTournament1000Description =>
      'Torneo masculino semanal - capacidad de 300 participantes';

  @override
  String get weeklyMaleTournament10000Description =>
      'Torneo masculino premium - capacidad de 100 participantes';

  @override
  String get weeklyFemaleTournament1000Description =>
      'Torneo femenino semanal - capacidad de 300 participantes';

  @override
  String get weeklyFemaleTournament10000Description =>
      'Torneo femenino premium - capacidad de 100 participantes';

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
  String get notificationCenter => 'Notificaciones';

  @override
  String get allNotificationsDescription =>
      'Activar/desactivar todos los tipos de notificaciones';

  @override
  String get tournamentNotificationsDescription =>
      'Nuevas invitaciones y actualizaciones de torneos';

  @override
  String get voteReminderNotifications => 'Recordatorios de Votación';

  @override
  String get voteReminderNotificationsDescription =>
      'Notificaciones de recordatorio de votación';

  @override
  String get winCelebrationNotifications => 'Celebraciones de Victoria';

  @override
  String get winCelebrationNotificationsDescription =>
      'Notificaciones de victoria';

  @override
  String get streakReminderNotifications => 'Recordatorios de Racha';

  @override
  String get streakReminderNotificationsDescription =>
      'Recordatorios de racha diaria';

  @override
  String get notificationsList => 'Notificaciones';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get newNotificationsWillAppearHere =>
      'Las nuevas notificaciones aparecerán aquí';

  @override
  String get markAllAsRead => 'Marcar Todo como Leído';
}
