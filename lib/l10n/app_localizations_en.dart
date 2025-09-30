// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chizo';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get age => 'Age';

  @override
  String get country => 'Country';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get instagramHandle => 'Instagram Handle';

  @override
  String get profession => 'Profession';

  @override
  String get voting => 'Voting';

  @override
  String get whichDoYouPrefer => 'Which one do you prefer?';

  @override
  String predictUserWinRate(String username) {
    return 'Predict $username\'s win rate';
  }

  @override
  String get correctPrediction => 'Correct prediction = 1 coin';

  @override
  String get submitPrediction => 'Submit Prediction';

  @override
  String get winRate => 'Win Rate';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get leaderboard => '🏆 Leaderboard';

  @override
  String get tournament => 'Tournament';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get spanish => 'Spanish';

  @override
  String get turkishLanguage => 'Turkish';

  @override
  String get englishLanguage => 'English';

  @override
  String get germanLanguage => 'German';

  @override
  String get coins => 'Coins';

  @override
  String get totalMatches => 'Total Matches';

  @override
  String get wins => 'Wins';

  @override
  String get winRatePercentage => 'Win Rate';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get totalStreakDays => 'Total Streak Days';

  @override
  String get predictionStats => 'Prediction Statistics';

  @override
  String get totalPredictions => 'Total Predictions';

  @override
  String get correctPredictions => 'Correct Predictions';

  @override
  String get accuracy => 'Accuracy';

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
  String get invalidEmail =>
      '❌ Invalid email address! Please enter a valid email format.';

  @override
  String get userNotFoundError => '❌ No user found with this email address!';

  @override
  String get userAlreadyRegistered =>
      '❌ This email address is already registered! Try logging in.';

  @override
  String get invalidPassword => '❌ Wrong password! Please check your password.';

  @override
  String get passwordMinLengthError =>
      '❌ Password must be at least 6 characters!';

  @override
  String get passwordTooWeak =>
      '❌ Password is too weak! Choose a stronger password.';

  @override
  String get usernameAlreadyTaken =>
      '❌ This username is already taken! Choose another username.';

  @override
  String get usernameTooShort => '❌ Username must be at least 3 characters!';

  @override
  String get networkError => '❌ Check your internet connection!';

  @override
  String get timeoutError => '❌ Connection timeout! Please try again.';

  @override
  String get emailNotConfirmed => '❌ You need to confirm your email address!';

  @override
  String get tooManyRequests =>
      '❌ Too many attempts! Please wait a few minutes and try again.';

  @override
  String get accountDisabled => '❌ Your account has been disabled!';

  @override
  String get duplicateData =>
      '❌ This information is already in use! Try different information.';

  @override
  String get invalidData =>
      '❌ There is an error in the information you entered! Please check.';

  @override
  String get invalidCredentials => '❌ Email or password is incorrect!';

  @override
  String get tooManyEmails => '❌ Too many emails sent! Please wait.';

  @override
  String get operationFailed =>
      '❌ Operation failed! Please check your information.';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noMatchesAvailable => 'No matches available for voting';

  @override
  String get allMatchesVoted =>
      'All matches voted!\nWaiting for new matches...';

  @override
  String get usernameCannotBeEmpty => 'Username cannot be empty';

  @override
  String get emailCannotBeEmpty => 'Email cannot be empty';

  @override
  String get passwordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String get userAlreadyExists =>
      'This user is already registered or an error occurred';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String get loginError => 'Login error: Unknown error';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Register now';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginNow => 'Login now';

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
  String get cancel => 'Cancel';

  @override
  String upload(int coins) {
    return 'Upload ($coins coins)';
  }

  @override
  String photoUploaded(int coinsSpent) {
    return 'Photo Uploaded';
  }

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get confirmDeletePhoto =>
      'Are you sure you want to delete this photo?';

  @override
  String get delete => 'Delete';

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
    return '💎 $type Information';
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
  String get buy => 'Buy';

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
      'Unfortunately, you predicted incorrectly.';

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
  String get notificationSettings => 'Notification Settings';

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
    return '$matches matches • $winRate';
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

  @override
  String get lastFiveMatches => 'Last 5 Matches';

  @override
  String get total => 'Total';

  @override
  String get losses => 'Losses';

  @override
  String get rate => 'Rate';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get tournamentFull => 'Tournament Full';

  @override
  String get active => 'Active';

  @override
  String get joinWithKey => 'Join with Key';

  @override
  String get private => 'Private';

  @override
  String get countryRanking => 'Country Ranking';

  @override
  String get countryRankingSubtitle =>
      'How successful are you against citizens of different countries';

  @override
  String get countryRankingTitle => 'Country Ranking';

  @override
  String get countryRankingDescription =>
      'How successful are you against citizens of different countries';

  @override
  String get winsAgainst => 'Wins';

  @override
  String get lossesAgainst => 'Losses';

  @override
  String get winRateAgainst => 'Win Rate';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get loadingCountryStats => 'Loading country statistics...';

  @override
  String get countryStats => 'Country Statistics';

  @override
  String get yourPerformance => 'Your Performance';

  @override
  String get againstCountry => 'Country Comparison';

  @override
  String get retry => 'Retry';

  @override
  String get alreadyJoinedTournament =>
      'You have already joined this tournament';

  @override
  String get uploadTournamentPhoto => 'Upload Tournament Photo';

  @override
  String get viewTournament => 'View Tournament';

  @override
  String get tournamentParticipants => 'Tournament Participants';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get rank => 'Rank';

  @override
  String get participant => 'Participant';

  @override
  String get photoNotUploaded => 'Photo Not Uploaded';

  @override
  String get uploadPhotoUntilWednesday =>
      'You can upload photo until Wednesday';

  @override
  String get tournamentStarted => 'Tournament Started';

  @override
  String get viewTournamentPhotos => 'View Tournament Photos';

  @override
  String get genderMismatch => 'Gender Mismatch';

  @override
  String get photoAlreadyUploaded => 'Photo Already Uploaded';

  @override
  String get viewParticipantPhoto => 'View Participant Photo';

  @override
  String get selectPhoto => 'Select Photo';

  @override
  String get photoUploadFailed => 'Photo Upload Failed';

  @override
  String get tournamentCancelled => 'Tournament Cancelled';

  @override
  String get refundFailed => 'Refund Failed';

  @override
  String get createPrivateTournament => 'Create Private Tournament';

  @override
  String get tournamentName => 'Tournament Name';

  @override
  String get maxParticipants => 'Maximum Participants';

  @override
  String get tournamentFormat => 'Tournament Format';

  @override
  String get leagueFormat => 'League Format';

  @override
  String get eliminationFormat => 'Elimination Format';

  @override
  String get hybridFormat => 'League + Elimination';

  @override
  String get eliminationMaxParticipants =>
      'Maximum 8 participants for elimination format';

  @override
  String get eliminationMaxParticipantsWarning =>
      'Maximum 8 participants allowed for elimination format';

  @override
  String get weeklyMaleTournament1000Description =>
      'Weekly male tournament - 300 participant capacity';

  @override
  String get weeklyMaleTournament10000Description =>
      'Premium male tournament - 100 participant capacity';

  @override
  String get weeklyFemaleTournament1000Description =>
      'Weekly female tournament - 300 participant capacity';

  @override
  String get weeklyFemaleTournament10000Description =>
      'Premium female tournament - 100 participant capacity';

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
  String get notificationCenter => 'Notifications';

  @override
  String get allNotificationsDescription =>
      'Enable/disable all notification types';

  @override
  String get tournamentNotificationsDescription =>
      'New tournament invitations and updates';

  @override
  String get voteReminderNotifications => 'Vote Reminders';

  @override
  String get voteReminderNotificationsDescription =>
      'Vote reminder notifications';

  @override
  String get winCelebrationNotifications => 'Victory Celebrations';

  @override
  String get winCelebrationNotificationsDescription => 'Victory notifications';

  @override
  String get streakReminderNotifications => 'Streak Reminders';

  @override
  String get streakReminderNotificationsDescription => 'Daily streak reminders';

  @override
  String get notificationsList => 'Notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get newNotificationsWillAppearHere =>
      'New notifications will appear here';

  @override
  String get markAllAsRead => 'Mark All as Read';
}
