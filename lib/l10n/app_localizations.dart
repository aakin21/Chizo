import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Chizo'**
  String get appTitle;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Instagram handle field label
  ///
  /// In en, this message translates to:
  /// **'Instagram Handle'**
  String get instagramHandle;

  /// Profession field label
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get profession;

  /// Voting tab title
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get voting;

  /// Voting question text
  ///
  /// In en, this message translates to:
  /// **'Which one do you prefer?'**
  String get whichDoYouPrefer;

  /// Win rate prediction text
  ///
  /// In en, this message translates to:
  /// **'Predict {username}\'s win rate'**
  String predictWinRate(String username);

  /// Correct prediction reward text
  ///
  /// In en, this message translates to:
  /// **'Correct prediction = 1 coin'**
  String get correctPrediction;

  /// Submit prediction button text
  ///
  /// In en, this message translates to:
  /// **'Submit Prediction'**
  String get submitPrediction;

  /// Win rate label in statistics
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// Profile tab title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings tab title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Leaderboard tab title
  ///
  /// In en, this message translates to:
  /// **'🏆 Leaderboard'**
  String get leaderboard;

  /// Tournament tab title
  ///
  /// In en, this message translates to:
  /// **'Tournament'**
  String get tournament;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Turkish language option
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Coins label
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// Total matches label in statistics
  ///
  /// In en, this message translates to:
  /// **'Total Matches'**
  String get totalMatches;

  /// Wins label in statistics
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// Win rate percentage label
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRatePercentage;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Total streak days label
  ///
  /// In en, this message translates to:
  /// **'Total Streak Days'**
  String get totalStreakDays;

  /// Prediction statistics title
  ///
  /// In en, this message translates to:
  /// **'Prediction Statistics'**
  String get predictionStats;

  /// Total predictions label
  ///
  /// In en, this message translates to:
  /// **'Total Predictions'**
  String get totalPredictions;

  /// Correct predictions label
  ///
  /// In en, this message translates to:
  /// **'Correct Predictions'**
  String get correctPredictions;

  /// Accuracy label
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// Coins earned from predictions
  ///
  /// In en, this message translates to:
  /// **'Coins earned from predictions: {coins}'**
  String coinsEarnedFromPredictions(int coins);

  /// Congratulations text
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Correct prediction success message
  ///
  /// In en, this message translates to:
  /// **'You predicted correctly and earned 1 coin!'**
  String get correctPredictionMessage;

  /// Wrong prediction message
  ///
  /// In en, this message translates to:
  /// **'Wrong prediction. The actual win rate was {winRate}%'**
  String wrongPredictionMessage(double winRate);

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success label
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No matches available message
  ///
  /// In en, this message translates to:
  /// **'No matches available for voting'**
  String get noMatchesAvailable;

  /// All matches voted message
  ///
  /// In en, this message translates to:
  /// **'All matches voted!\nWaiting for new matches...'**
  String get allMatchesVoted;

  /// Username validation error message
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// Email validation error message
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailCannotBeEmpty;

  /// Password validation error message
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// Password minimum length validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// User already exists error message
  ///
  /// In en, this message translates to:
  /// **'This user is already registered or an error occurred'**
  String get userAlreadyExists;

  /// Login success message
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login error: Unknown error'**
  String get loginError;

  /// Don't have account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Register now button text
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Login now button text
  ///
  /// In en, this message translates to:
  /// **'Login now'**
  String get loginNow;

  /// All photo slots full message
  ///
  /// In en, this message translates to:
  /// **'All additional photo slots are full!'**
  String get allPhotoSlotsFull;

  /// Photo upload dialog title
  ///
  /// In en, this message translates to:
  /// **'Photo Upload - Slot {slot}'**
  String photoUploadSlot(int slot);

  /// Coins required for slot message
  ///
  /// In en, this message translates to:
  /// **'This slot requires {coins} coins.'**
  String coinsRequiredForSlot(int coins);

  /// Insufficient coins for photo upload message
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins! Use the coin button on profile page to purchase coins.'**
  String get insufficientCoinsForUpload;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Upload button text
  ///
  /// In en, this message translates to:
  /// **'Upload ({coins} coins)'**
  String upload(int coins);

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded! {coinsSpent} coins spent.'**
  String photoUploaded(int coinsSpent);

  /// Delete photo dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// Confirm photo deletion message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get confirmDeletePhoto;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Photo deletion success message
  ///
  /// In en, this message translates to:
  /// **'Photo deleted!'**
  String get photoDeleted;

  /// Select from gallery option
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// Take from camera option
  ///
  /// In en, this message translates to:
  /// **'Take from Camera'**
  String get takeFromCamera;

  /// Additional match photos section title
  ///
  /// In en, this message translates to:
  /// **'Additional Match Photos'**
  String get additionalMatchPhotos;

  /// Add photo button text
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Additional photos description
  ///
  /// In en, this message translates to:
  /// **'Additional photos that will appear in matches ({count}/4)'**
  String additionalPhotosDescription(int count);

  /// No additional photos message
  ///
  /// In en, this message translates to:
  /// **'No additional photos yet'**
  String get noAdditionalPhotos;

  /// Second photo cost message
  ///
  /// In en, this message translates to:
  /// **'2nd photo costs 50 coins!'**
  String get secondPhotoCost;

  /// Premium info added message
  ///
  /// In en, this message translates to:
  /// **'Your premium information has been added! You can adjust visibility settings below.'**
  String get premiumInfoAdded;

  /// Premium info visibility section title
  ///
  /// In en, this message translates to:
  /// **'Premium Info Visibility'**
  String get premiumInfoVisibility;

  /// Premium info description
  ///
  /// In en, this message translates to:
  /// **'Other users can view this information by spending coins'**
  String get premiumInfoDescription;

  /// Instagram account label
  ///
  /// In en, this message translates to:
  /// **'Instagram Account'**
  String get instagramAccount;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Prediction statistics section title
  ///
  /// In en, this message translates to:
  /// **'Prediction Statistics'**
  String get predictionStatistics;

  /// Match history section title
  ///
  /// In en, this message translates to:
  /// **'Match History'**
  String get matchHistory;

  /// View match history message
  ///
  /// In en, this message translates to:
  /// **'View your last 5 matches and opponents (5 coins)'**
  String get viewLastFiveMatches;

  /// Visible in matches toggle label
  ///
  /// In en, this message translates to:
  /// **'Visible in Matches'**
  String get visibleInMatches;

  /// Now visible in matches message
  ///
  /// In en, this message translates to:
  /// **'You will now appear in matches!'**
  String get nowVisibleInMatches;

  /// Removed from matches message
  ///
  /// In en, this message translates to:
  /// **'You have been removed from matches!'**
  String get removedFromMatches;

  /// Add info dialog title
  ///
  /// In en, this message translates to:
  /// **'Add {type}'**
  String addInfo(String type);

  /// Enter info dialog message
  ///
  /// In en, this message translates to:
  /// **'Enter your {type} information:'**
  String enterInfo(String type);

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Info added success message
  ///
  /// In en, this message translates to:
  /// **'✅ {type} information added!'**
  String infoAdded(String type);

  /// Error adding info message
  ///
  /// In en, this message translates to:
  /// **'❌ Error occurred while adding information!'**
  String get errorAddingInfo;

  /// Match info not loaded error message
  ///
  /// In en, this message translates to:
  /// **'Match information could not be loaded'**
  String get matchInfoNotLoaded;

  /// Premium info dialog title
  ///
  /// In en, this message translates to:
  /// **'Premium Information'**
  String premiumInfo(String type);

  /// Spend 5 coins button text
  ///
  /// In en, this message translates to:
  /// **'Spend 5 coins to view this information'**
  String get spendFiveCoins;

  /// Insufficient coins error message
  ///
  /// In en, this message translates to:
  /// **'❌ Insufficient coins!'**
  String get insufficientCoins;

  /// 5 coins spent message
  ///
  /// In en, this message translates to:
  /// **'✅ 5 coins spent'**
  String get fiveCoinsSpent;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Match counter text
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String matchCounter(int current, int total);

  /// Spend coins to view message
  ///
  /// In en, this message translates to:
  /// **'You will spend 5 coins to view this information'**
  String get spendFiveCoinsToView;

  /// Great exclamation
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// Streak message
  ///
  /// In en, this message translates to:
  /// **'{days} day streak!'**
  String streakMessage(int days);

  /// Purchase coins button text
  ///
  /// In en, this message translates to:
  /// **'Purchase Coins'**
  String get purchaseCoins;

  /// Watch ad button text
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// Daily ad limit message
  ///
  /// In en, this message translates to:
  /// **'You can watch maximum 5 ads per day'**
  String get dailyAdLimit;

  /// Coins per ad message
  ///
  /// In en, this message translates to:
  /// **'Coins per ad: 20'**
  String get coinsPerAd;

  /// Watch ad button label
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAdButton;

  /// Daily limit reached message
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get dailyLimitReached;

  /// Recent transactions title
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions:'**
  String get recentTransactions;

  /// No transaction history message
  ///
  /// In en, this message translates to:
  /// **'No transaction history yet'**
  String get noTransactionHistory;

  /// Account settings section title
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutConfirmation;

  /// Logout error message
  ///
  /// In en, this message translates to:
  /// **'Error occurred while logging out'**
  String logoutError(String error);

  /// Delete account button text
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// Final confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// Type delete to confirm message
  ///
  /// In en, this message translates to:
  /// **'To delete your account, type \"DELETE\":'**
  String get typeDeleteToConfirm;

  /// Please type delete message
  ///
  /// In en, this message translates to:
  /// **'Please type \"DELETE\"!'**
  String get pleaseTypeDelete;

  /// Account deleted successfully message
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted!'**
  String get accountDeletedSuccessfully;

  /// Error deleting account message
  ///
  /// In en, this message translates to:
  /// **'Error occurred while deleting account'**
  String errorDeletingAccount(String error);

  /// Error watching ad message
  ///
  /// In en, this message translates to:
  /// **'Error occurred while watching ad'**
  String errorWatchingAd(String error);

  /// Watching ad dialog title
  ///
  /// In en, this message translates to:
  /// **'Watching Ad'**
  String get watchingAd;

  /// Ad loading message
  ///
  /// In en, this message translates to:
  /// **'Ad loading...'**
  String get adLoading;

  /// Ad simulation message
  ///
  /// In en, this message translates to:
  /// **'This is a simulation ad. In the real app, an actual ad will be shown here.'**
  String get adSimulation;

  /// Ad watched success message
  ///
  /// In en, this message translates to:
  /// **'Ad watched! +20 coins earned!'**
  String get adWatched;

  /// Error adding coins message
  ///
  /// In en, this message translates to:
  /// **'Error occurred while adding coins'**
  String get errorAddingCoins;

  /// Buy button text
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Predict button text
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get predict;

  /// 5 coins spent for history message
  ///
  /// In en, this message translates to:
  /// **'✅ 5 coins spent! Your match history is being displayed.'**
  String get fiveCoinsSpentForHistory;

  /// Insufficient coins for history message
  ///
  /// In en, this message translates to:
  /// **'❌ Insufficient coins!'**
  String get insufficientCoinsForHistory;

  /// Spend 5 coins for history button text
  ///
  /// In en, this message translates to:
  /// **'Spend 5 Coins'**
  String get spendFiveCoinsForHistory;

  /// Wins and matches display
  ///
  /// In en, this message translates to:
  /// **'{wins} wins • {matches} matches'**
  String winsAndMatches(int wins, int matches);

  /// Insufficient coins for tournament message
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins for tournament!'**
  String get insufficientCoinsForTournament;

  /// Joined tournament success message
  ///
  /// In en, this message translates to:
  /// **'You joined the tournament!'**
  String get joinedTournament;

  /// Tournament join failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to join tournament!'**
  String get tournamentJoinFailed;

  /// Daily streak message
  ///
  /// In en, this message translates to:
  /// **'Daily Streak!'**
  String get dailyStreak;

  /// Image update success message
  ///
  /// In en, this message translates to:
  /// **'Image updated!'**
  String get imageUpdated;

  /// Update failed message
  ///
  /// In en, this message translates to:
  /// **'Update failed!'**
  String get updateFailed;

  /// Image update failed message
  ///
  /// In en, this message translates to:
  /// **'Image update failed!'**
  String get imageUpdateFailed;

  /// Select image message
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// User info not loaded message
  ///
  /// In en, this message translates to:
  /// **'User information could not be loaded'**
  String get userInfoNotLoaded;

  /// Coin label
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get coin;

  /// Premium features label
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// Add Instagram account button text
  ///
  /// In en, this message translates to:
  /// **'Add Instagram Account'**
  String get addInstagram;

  /// Add profession button text
  ///
  /// In en, this message translates to:
  /// **'Add Profession'**
  String get addProfession;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// Profile update failed message
  ///
  /// In en, this message translates to:
  /// **'Profile update failed!'**
  String get profileUpdateFailed;

  /// Profile settings title
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// Password reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get passwordReset;

  /// Password reset subtitle
  ///
  /// In en, this message translates to:
  /// **'Reset password via email'**
  String get passwordResetSubtitle;

  /// Logout subtitle
  ///
  /// In en, this message translates to:
  /// **'Secure logout from your account'**
  String get logoutSubtitle;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountSubtitle;

  /// Update profile button text
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// Password reset dialog title
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordResetTitle;

  /// Password reset dialog message
  ///
  /// In en, this message translates to:
  /// **'A password reset link will be sent to your email address. Do you want to continue?'**
  String get passwordResetMessage;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Password reset email sent message
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get passwordResetSent;

  /// Email not found message
  ///
  /// In en, this message translates to:
  /// **'Email address not found!'**
  String get emailNotFound;

  /// Voting error message
  ///
  /// In en, this message translates to:
  /// **'Error occurred during voting'**
  String get votingError;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot}'**
  String slot(Object slot);

  /// No description provided for @instagramAdded.
  ///
  /// In en, this message translates to:
  /// **'Instagram information added!'**
  String get instagramAdded;

  /// No description provided for @professionAdded.
  ///
  /// In en, this message translates to:
  /// **'Profession information added!'**
  String get professionAdded;

  /// No description provided for @addInstagramFromSettings.
  ///
  /// In en, this message translates to:
  /// **'You can use this feature by adding Instagram and profession information from settings'**
  String get addInstagramFromSettings;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @premiumInfoSettings.
  ///
  /// In en, this message translates to:
  /// **'Premium Information'**
  String get premiumInfoSettings;

  /// No description provided for @premiumInfoDescriptionSettings.
  ///
  /// In en, this message translates to:
  /// **'Other users can view this information by spending coins'**
  String get premiumInfoDescriptionSettings;

  /// No description provided for @coinInfo.
  ///
  /// In en, this message translates to:
  /// **'Coin Information'**
  String get coinInfo;

  /// Current coins display
  ///
  /// In en, this message translates to:
  /// **'Current Coins'**
  String currentCoins(int coins);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @coinPurchase.
  ///
  /// In en, this message translates to:
  /// **'Coin Purchase'**
  String get coinPurchase;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccessful;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed!'**
  String get purchaseFailed;

  /// No description provided for @coinPackages.
  ///
  /// In en, this message translates to:
  /// **'Coin Packages'**
  String get coinPackages;

  /// No description provided for @coinUsage.
  ///
  /// In en, this message translates to:
  /// **'Coin Usage'**
  String get coinUsage;

  /// No description provided for @instagramView.
  ///
  /// In en, this message translates to:
  /// **'View Instagram accounts'**
  String get instagramView;

  /// No description provided for @professionView.
  ///
  /// In en, this message translates to:
  /// **'View profession information'**
  String get professionView;

  /// No description provided for @statsView.
  ///
  /// In en, this message translates to:
  /// **'View detailed statistics'**
  String get statsView;

  /// No description provided for @tournamentFees.
  ///
  /// In en, this message translates to:
  /// **'Tournament participation fees'**
  String get tournamentFees;

  /// No description provided for @premiumFilters.
  ///
  /// In en, this message translates to:
  /// **'Premium filters'**
  String get premiumFilters;

  /// Button text to view photo statistics
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStats;

  /// Title for photo statistics modal
  ///
  /// In en, this message translates to:
  /// **'Photo Statistics'**
  String get photoStats;

  /// Message about photo stats cost
  ///
  /// In en, this message translates to:
  /// **'View photo statistics costs 50 coins'**
  String get photoStatsCost;

  /// Error message when user doesn't have enough coins for photo stats
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins to view photo statistics. Required: 50 coins'**
  String get insufficientCoinsForStats;

  /// Pay button text
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
