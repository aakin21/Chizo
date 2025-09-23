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
  String predictWinRate(String username) {
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
  String get correctPredictionMessage =>
      'You predicted correctly and earned 1 coin!';

  @override
  String wrongPredictionMessage(double winRate) {
    return 'Wrong prediction. The actual win rate was $winRate%';
  }

  @override
  String get error => 'Error';

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
  String currentCoins(int coins) {
    return 'Current Coins';
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
    return 'Photo uploaded! $coinsSpent coins spent.';
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
  String get matchHistory => 'Match History';

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
  String get spendFiveCoins => 'Spend 5 coins to view this information';

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
  String get spendFiveCoinsForHistory => 'Spend 5 Coins';

  @override
  String winsAndMatches(int wins, int matches) {
    return '$wins wins • $matches matches';
  }

  @override
  String get insufficientCoinsForTournament => 'Insufficient coins!';

  @override
  String get joinedTournament => 'Joined tournament!';

  @override
  String get tournamentJoinFailed => 'Failed to join tournament!';

  @override
  String get dailyStreak => 'Daily Streak!';

  @override
  String get imageUpdated => 'Image updated!';

  @override
  String get updateFailed => 'Update failed!';

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
  String get votingError => 'Error occurred during voting';

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
}
