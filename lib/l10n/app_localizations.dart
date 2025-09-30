import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
    Locale('en'),
    Locale('tr'),
    Locale('de'),
    Locale('es'),
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
  String predictUserWinRate(String username);

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

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @turkishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkishLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @germanLanguage.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get germanLanguage;

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
  String get correctPredictionWithReward;

  /// Wrong prediction message
  ///
  /// In en, this message translates to:
  /// **'Wrong prediction. The actual win rate was {winRate}%'**
  String wrongPredictionWithRate(double winRate);

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'❌ Invalid email address! Please enter a valid email format.'**
  String get invalidEmail;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'❌ No user found with this email address!'**
  String get userNotFoundError;

  /// No description provided for @userAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'❌ This email address is already registered! Try logging in.'**
  String get userAlreadyRegistered;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'❌ Wrong password! Please check your password.'**
  String get invalidPassword;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'❌ Password must be at least 6 characters!'**
  String get passwordMinLengthError;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'❌ Password is too weak! Choose a stronger password.'**
  String get passwordTooWeak;

  /// No description provided for @usernameAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'❌ This username is already taken! Choose another username.'**
  String get usernameAlreadyTaken;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'❌ Username must be at least 3 characters!'**
  String get usernameTooShort;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'❌ Check your internet connection!'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'❌ Connection timeout! Please try again.'**
  String get timeoutError;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'❌ You need to confirm your email address!'**
  String get emailNotConfirmed;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'❌ Too many attempts! Please wait a few minutes and try again.'**
  String get tooManyRequests;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'❌ Your account has been disabled!'**
  String get accountDisabled;

  /// No description provided for @duplicateData.
  ///
  /// In en, this message translates to:
  /// **'❌ This information is already in use! Try different information.'**
  String get duplicateData;

  /// No description provided for @invalidData.
  ///
  /// In en, this message translates to:
  /// **'❌ There is an error in the information you entered! Please check.'**
  String get invalidData;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'❌ Email or password is incorrect!'**
  String get invalidCredentials;

  /// No description provided for @tooManyEmails.
  ///
  /// In en, this message translates to:
  /// **'❌ Too many emails sent! Please wait.'**
  String get tooManyEmails;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Operation failed! Please check your information.'**
  String get operationFailed;

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
  /// **'Photo Uploaded'**
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
  /// **'📊 Match History'**
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
  /// **'💎 {type} Information'**
  String premiumInfo(String type);

  /// Spend 5 coins button text
  ///
  /// In en, this message translates to:
  /// **'Spend 5 Coins'**
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
  /// **'Spend 5 coins to see your last 5 matches and opponents'**
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
  /// **'Update failed'**
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
  /// **'Error during voting: {error}'**
  String votingError(Object error);

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

  /// Name for weekly male tournament with 1000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Weekly Male Tournament (1000 Coins)'**
  String get weeklyMaleTournament1000;

  /// No description provided for @weeklyMaleTournament1000Desc.
  ///
  /// In en, this message translates to:
  /// **'Weekly male tournament - 300 person capacity'**
  String get weeklyMaleTournament1000Desc;

  /// Name for weekly male tournament with 10000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Weekly Male Tournament (10000 Coins)'**
  String get weeklyMaleTournament10000;

  /// No description provided for @weeklyMaleTournament10000Desc.
  ///
  /// In en, this message translates to:
  /// **'Premium male tournament - 100 person capacity'**
  String get weeklyMaleTournament10000Desc;

  /// Name for weekly female tournament with 1000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Weekly Female Tournament (1000 Coins)'**
  String get weeklyFemaleTournament1000;

  /// No description provided for @weeklyFemaleTournament1000Desc.
  ///
  /// In en, this message translates to:
  /// **'Weekly female tournament - 300 person capacity'**
  String get weeklyFemaleTournament1000Desc;

  /// Name for weekly female tournament with 10000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Weekly Female Tournament (10000 Coins)'**
  String get weeklyFemaleTournament10000;

  /// No description provided for @weeklyFemaleTournament10000Desc.
  ///
  /// In en, this message translates to:
  /// **'Premium female tournament - 100 person capacity'**
  String get weeklyFemaleTournament10000Desc;

  /// No description provided for @tournamentEntryFee.
  ///
  /// In en, this message translates to:
  /// **'Tournament entry fee'**
  String get tournamentEntryFee;

  /// No description provided for @tournamentVotingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tournament Voting'**
  String get tournamentVotingTitle;

  /// No description provided for @tournamentThirdPlace.
  ///
  /// In en, this message translates to:
  /// **'Tournament 3rd place'**
  String get tournamentThirdPlace;

  /// No description provided for @tournamentWon.
  ///
  /// In en, this message translates to:
  /// **'Tournament won'**
  String get tournamentWon;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @firstLoginReward.
  ///
  /// In en, this message translates to:
  /// **'🎉 First login! You earned 50 coins!'**
  String get firstLoginReward;

  /// No description provided for @streakReward.
  ///
  /// In en, this message translates to:
  /// **'🔥 {streak} day streak! You earned {coins} coins!'**
  String streakReward(Object coins, Object streak);

  /// No description provided for @streakBroken.
  ///
  /// In en, this message translates to:
  /// **'💔 Streak broken! New start: You earned 50 coins!'**
  String get streakBroken;

  /// No description provided for @dailyStreakReward.
  ///
  /// In en, this message translates to:
  /// **'Daily streak reward ({streak} days)'**
  String dailyStreakReward(Object streak);

  /// No description provided for @alreadyLoggedInToday.
  ///
  /// In en, this message translates to:
  /// **'You already logged in today!'**
  String get alreadyLoggedInToday;

  /// No description provided for @streakCheckError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during streak check'**
  String get streakCheckError;

  /// No description provided for @streakInfoError.
  ///
  /// In en, this message translates to:
  /// **'Could not get streak information'**
  String get streakInfoError;

  /// No description provided for @correctPredictionReward.
  ///
  /// In en, this message translates to:
  /// **'You will earn 1 coin for correct prediction!'**
  String get correctPredictionReward;

  /// No description provided for @wrongPredictionMessage.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, you predicted incorrectly.'**
  String get wrongPredictionMessage;

  /// No description provided for @predictionSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while saving prediction'**
  String get predictionSaveError;

  /// No description provided for @coinAddError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while adding coins'**
  String get coinAddError;

  /// No description provided for @coinPurchaseTransaction.
  ///
  /// In en, this message translates to:
  /// **'Coin purchase - {description}'**
  String coinPurchaseTransaction(Object description);

  /// No description provided for @whiteThemeName.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get whiteThemeName;

  /// No description provided for @darkThemeName.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkThemeName;

  /// No description provided for @pinkThemeName.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pinkThemeName;

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

  /// No description provided for @tournamentVotingSaved.
  ///
  /// In en, this message translates to:
  /// **'Tournament voting saved!'**
  String get tournamentVotingSaved;

  /// No description provided for @tournamentVotingFailed.
  ///
  /// In en, this message translates to:
  /// **'Tournament voting failed!'**
  String get tournamentVotingFailed;

  /// No description provided for @tournamentVoting.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT VOTING'**
  String get tournamentVoting;

  /// No description provided for @whichTournamentParticipant.
  ///
  /// In en, this message translates to:
  /// **'Which tournament participant do you prefer?'**
  String get whichTournamentParticipant;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years • {country}'**
  String ageYears(Object age, Object country);

  /// No description provided for @clickToOpenInstagram.
  ///
  /// In en, this message translates to:
  /// **'📱 Click to open Instagram'**
  String get clickToOpenInstagram;

  /// No description provided for @openInstagram.
  ///
  /// In en, this message translates to:
  /// **'Open Instagram'**
  String get openInstagram;

  /// No description provided for @instagramCannotBeOpened.
  ///
  /// In en, this message translates to:
  /// **'❌ Instagram could not be opened. Please check your Instagram app.'**
  String get instagramCannotBeOpened;

  /// No description provided for @instagramOpenError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error opening Instagram: {error}'**
  String instagramOpenError(Object error);

  /// No description provided for @tournamentPhoto.
  ///
  /// In en, this message translates to:
  /// **'🏆 Tournament Photo'**
  String get tournamentPhoto;

  /// No description provided for @tournamentJoinedUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'You joined the tournament! Now upload your tournament photo.'**
  String get tournamentJoinedUploadPhoto;

  /// No description provided for @uploadLater.
  ///
  /// In en, this message translates to:
  /// **'Upload Later'**
  String get uploadLater;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @tournamentPhotoUploaded.
  ///
  /// In en, this message translates to:
  /// **'✅ Tournament photo uploaded!'**
  String get tournamentPhotoUploaded;

  /// No description provided for @photoUploadError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error occurred while uploading photo!'**
  String get photoUploadError;

  /// No description provided for @noVotingForTournament.
  ///
  /// In en, this message translates to:
  /// **'No voting found for this tournament'**
  String get noVotingForTournament;

  /// No description provided for @votingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading voting: {error}'**
  String votingLoadError(Object error);

  /// No description provided for @whichParticipantPrefer.
  ///
  /// In en, this message translates to:
  /// **'Which participant do you prefer?'**
  String get whichParticipantPrefer;

  /// No description provided for @voteSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your vote has been saved successfully!'**
  String get voteSavedSuccessfully;

  /// No description provided for @noActiveTournament.
  ///
  /// In en, this message translates to:
  /// **'No active tournament currently'**
  String get noActiveTournament;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @coinPrize.
  ///
  /// In en, this message translates to:
  /// **'{prize} coin prize'**
  String coinPrize(Object prize);

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String startDate(Object date);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed. Refreshing page...'**
  String get languageChanged;

  /// No description provided for @lightWhiteTheme.
  ///
  /// In en, this message translates to:
  /// **'White material light theme'**
  String get lightWhiteTheme;

  /// No description provided for @neutralDarkGrayTheme.
  ///
  /// In en, this message translates to:
  /// **'Neutral dark gray theme'**
  String get neutralDarkGrayTheme;

  /// No description provided for @themeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme changed: {theme}'**
  String themeChanged(Object theme);

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone! All your data will be permanently deleted.\nAre you sure you want to delete your account?'**
  String get deleteAccountWarning;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get accountDeleted;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @themeSelection.
  ///
  /// In en, this message translates to:
  /// **'🎨 Theme Selection'**
  String get themeSelection;

  /// No description provided for @darkMaterialTheme.
  ///
  /// In en, this message translates to:
  /// **'Black material dark theme'**
  String get darkMaterialTheme;

  /// No description provided for @lightPinkTheme.
  ///
  /// In en, this message translates to:
  /// **'Light pink color theme'**
  String get lightPinkTheme;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'🔔 Notification Settings'**
  String get notificationSettings;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @allNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on/off main notifications'**
  String get allNotificationsSubtitle;

  /// No description provided for @voteReminder.
  ///
  /// In en, this message translates to:
  /// **'Vote Reminder'**
  String get voteReminder;

  /// No description provided for @winCelebration.
  ///
  /// In en, this message translates to:
  /// **'Win Celebration'**
  String get winCelebration;

  /// No description provided for @streakReminder.
  ///
  /// In en, this message translates to:
  /// **'Streak Reminder'**
  String get streakReminder;

  /// No description provided for @streakReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily streak reward reminders'**
  String get streakReminderSubtitle;

  /// No description provided for @moneyAndCoins.
  ///
  /// In en, this message translates to:
  /// **'💰 Money & Coin Transactions'**
  String get moneyAndCoins;

  /// No description provided for @purchaseCoinPackage.
  ///
  /// In en, this message translates to:
  /// **'Purchase Coin Package'**
  String get purchaseCoinPackage;

  /// No description provided for @purchaseCoinPackageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy coins and earn rewards'**
  String get purchaseCoinPackageSubtitle;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'⚙️ App Settings'**
  String get appSettings;

  /// No description provided for @dailyRewards.
  ///
  /// In en, this message translates to:
  /// **'Daily Rewards'**
  String get dailyRewards;

  /// No description provided for @dailyRewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View streak rewards and boosts'**
  String get dailyRewardsSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @accountOperations.
  ///
  /// In en, this message translates to:
  /// **'👤 Account Operations'**
  String get accountOperations;

  /// No description provided for @dailyStreakRewards.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak Rewards'**
  String get dailyStreakRewards;

  /// No description provided for @dailyStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'🎯 Log in to the app every day and earn bonuses!'**
  String get dailyStreakDescription;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Voting and tournament app in chat rooms.'**
  String get appDescription;

  /// No description provided for @predictWinRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Predict win rate!'**
  String get predictWinRateTitle;

  /// No description provided for @wrongPredictionNoCoin.
  ///
  /// In en, this message translates to:
  /// **'Wrong prediction = 0 coins'**
  String get wrongPredictionNoCoin;

  /// No description provided for @selectWinRateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Win Rate Range:'**
  String get selectWinRateRange;

  /// No description provided for @wrongPrediction.
  ///
  /// In en, this message translates to:
  /// **'Wrong Prediction'**
  String get wrongPrediction;

  /// No description provided for @correctPredictionMessage.
  ///
  /// In en, this message translates to:
  /// **'You predicted correctly!'**
  String get correctPredictionMessage;

  /// No description provided for @actualRate.
  ///
  /// In en, this message translates to:
  /// **'Actual rate: {rate}%'**
  String actualRate(Object rate);

  /// No description provided for @earnedOneCoin.
  ///
  /// In en, this message translates to:
  /// **'+1 coin earned!'**
  String get earnedOneCoin;

  /// No description provided for @myPhotos.
  ///
  /// In en, this message translates to:
  /// **'My Photos ({count}/5)'**
  String myPhotos(Object count);

  /// No description provided for @photoCostInfo.
  ///
  /// In en, this message translates to:
  /// **'First photo is free, others cost coins. You can view statistics for all photos.'**
  String get photoCostInfo;

  /// No description provided for @addAge.
  ///
  /// In en, this message translates to:
  /// **'Add Age'**
  String get addAge;

  /// No description provided for @addCountry.
  ///
  /// In en, this message translates to:
  /// **'Add Country'**
  String get addCountry;

  /// No description provided for @addGender.
  ///
  /// In en, this message translates to:
  /// **'Add Gender'**
  String get addGender;

  /// No description provided for @countrySelection.
  ///
  /// In en, this message translates to:
  /// **'Country Selection'**
  String get countrySelection;

  /// No description provided for @countriesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} countries selected'**
  String countriesSelected(Object count);

  /// No description provided for @allCountriesSelected.
  ///
  /// In en, this message translates to:
  /// **'All countries selected'**
  String get allCountriesSelected;

  /// No description provided for @ageRangeSelection.
  ///
  /// In en, this message translates to:
  /// **'Age Range Selection'**
  String get ageRangeSelection;

  /// No description provided for @ageRangesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} age ranges selected'**
  String ageRangesSelected(Object count);

  /// No description provided for @allAgeRangesSelected.
  ///
  /// In en, this message translates to:
  /// **'All age ranges selected'**
  String get allAgeRangesSelected;

  /// No description provided for @editUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get editUsername;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @editAge.
  ///
  /// In en, this message translates to:
  /// **'Edit Age'**
  String get editAge;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterAge;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @selectYourCountry.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectYourCountry;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @selectYourGender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get selectYourGender;

  /// No description provided for @editInstagram.
  ///
  /// In en, this message translates to:
  /// **'Edit Instagram Account'**
  String get editInstagram;

  /// No description provided for @enterInstagram.
  ///
  /// In en, this message translates to:
  /// **'Enter your Instagram username (without @)'**
  String get enterInstagram;

  /// No description provided for @editProfession.
  ///
  /// In en, this message translates to:
  /// **'Edit Profession'**
  String get editProfession;

  /// No description provided for @enterProfession.
  ///
  /// In en, this message translates to:
  /// **'Enter your profession'**
  String get enterProfession;

  /// No description provided for @infoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Information updated'**
  String get infoUpdated;

  /// No description provided for @countryPreferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'✅ Country preferences updated'**
  String get countryPreferencesUpdated;

  /// No description provided for @countryPreferencesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Country preferences could not be updated'**
  String get countryPreferencesUpdateFailed;

  /// No description provided for @ageRangePreferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'✅ Age range preferences updated'**
  String get ageRangePreferencesUpdated;

  /// No description provided for @ageRangePreferencesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Age range preferences could not be updated'**
  String get ageRangePreferencesUpdateFailed;

  /// No description provided for @winRateAndMatches.
  ///
  /// In en, this message translates to:
  /// **'{matches} matches • {winRate}'**
  String winRateAndMatches(Object matches, Object winRate);

  /// No description provided for @mostWins.
  ///
  /// In en, this message translates to:
  /// **'Most Wins'**
  String get mostWins;

  /// No description provided for @highestWinRate.
  ///
  /// In en, this message translates to:
  /// **'Highest Win Rate'**
  String get highestWinRate;

  /// No description provided for @noWinsYet.
  ///
  /// In en, this message translates to:
  /// **'No wins yet!\nPlay your first match and enter the leaderboard!'**
  String get noWinsYet;

  /// No description provided for @noWinRateYet.
  ///
  /// In en, this message translates to:
  /// **'No win rate yet!\nPlay matches to increase your win rate!'**
  String get noWinRateYet;

  /// No description provided for @matchHistoryViewing.
  ///
  /// In en, this message translates to:
  /// **'Match history viewing'**
  String get matchHistoryViewing;

  /// No description provided for @winRateColon.
  ///
  /// In en, this message translates to:
  /// **'Win Rate: {winRate}'**
  String winRateColon(Object winRate);

  /// No description provided for @matchesAndWins.
  ///
  /// In en, this message translates to:
  /// **'{matches} matches • {wins} wins'**
  String matchesAndWins(Object matches, Object wins);

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You Won'**
  String get youWon;

  /// No description provided for @youLost.
  ///
  /// In en, this message translates to:
  /// **'You Lost'**
  String get youLost;

  /// No description provided for @lastFiveMatchStats.
  ///
  /// In en, this message translates to:
  /// **'📊 Last 5 Match Statistics'**
  String get lastFiveMatchStats;

  /// No description provided for @noMatchHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No match history yet!\nPlay your first match!'**
  String get noMatchHistoryYet;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'🔒 Premium Feature'**
  String get premiumFeature;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'🏆 Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @day1_2Reward.
  ///
  /// In en, this message translates to:
  /// **'Day 1-2: 10-25 Coin'**
  String get day1_2Reward;

  /// No description provided for @day3_6Reward.
  ///
  /// In en, this message translates to:
  /// **'Day 3-6: 50-100 Coin'**
  String get day3_6Reward;

  /// No description provided for @day7PlusReward.
  ///
  /// In en, this message translates to:
  /// **'Day 7+: 200+ Coin & Boost'**
  String get day7PlusReward;

  /// No description provided for @photoStatsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load photo statistics'**
  String get photoStatsLoadError;

  /// No description provided for @tournamentNotifications.
  ///
  /// In en, this message translates to:
  /// **'Tournament Notifications'**
  String get tournamentNotifications;

  /// No description provided for @newTournamentInvitations.
  ///
  /// In en, this message translates to:
  /// **'New tournament invitations'**
  String get newTournamentInvitations;

  /// No description provided for @victoryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Victory notifications'**
  String get victoryNotifications;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @lastFiveMatches.
  ///
  /// In en, this message translates to:
  /// **'Last 5 Matches'**
  String get lastFiveMatches;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @tournamentFull.
  ///
  /// In en, this message translates to:
  /// **'Tournament Full'**
  String get tournamentFull;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @joinWithKey.
  ///
  /// In en, this message translates to:
  /// **'Join with Key'**
  String get joinWithKey;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @countryRanking.
  ///
  /// In en, this message translates to:
  /// **'Country Ranking'**
  String get countryRanking;

  /// No description provided for @countryRankingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How successful are you against citizens of different countries'**
  String get countryRankingSubtitle;

  /// No description provided for @countryRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Country Ranking'**
  String get countryRankingTitle;

  /// No description provided for @countryRankingDescription.
  ///
  /// In en, this message translates to:
  /// **'How successful are you against citizens of different countries'**
  String get countryRankingDescription;

  /// No description provided for @winsAgainst.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get winsAgainst;

  /// No description provided for @lossesAgainst.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get lossesAgainst;

  /// No description provided for @winRateAgainst.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRateAgainst;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @loadingCountryStats.
  ///
  /// In en, this message translates to:
  /// **'Loading country statistics...'**
  String get loadingCountryStats;

  /// No description provided for @countryStats.
  ///
  /// In en, this message translates to:
  /// **'Country Statistics'**
  String get countryStats;

  /// No description provided for @yourPerformance.
  ///
  /// In en, this message translates to:
  /// **'Your Performance'**
  String get yourPerformance;

  /// No description provided for @againstCountry.
  ///
  /// In en, this message translates to:
  /// **'Country Comparison'**
  String get againstCountry;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @alreadyJoinedTournament.
  ///
  /// In en, this message translates to:
  /// **'You have already joined this tournament'**
  String get alreadyJoinedTournament;

  /// No description provided for @uploadTournamentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Tournament Photo'**
  String get uploadTournamentPhoto;

  /// No description provided for @viewTournament.
  ///
  /// In en, this message translates to:
  /// **'View Tournament'**
  String get viewTournament;

  /// No description provided for @tournamentParticipants.
  ///
  /// In en, this message translates to:
  /// **'Tournament Participants'**
  String get tournamentParticipants;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get yourRank;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @participant.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get participant;

  /// No description provided for @photoNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo Not Uploaded'**
  String get photoNotUploaded;

  /// No description provided for @uploadPhotoUntilWednesday.
  ///
  /// In en, this message translates to:
  /// **'You can upload photo until Wednesday'**
  String get uploadPhotoUntilWednesday;

  /// No description provided for @tournamentStarted.
  ///
  /// In en, this message translates to:
  /// **'Tournament Started'**
  String get tournamentStarted;

  /// No description provided for @viewTournamentPhotos.
  ///
  /// In en, this message translates to:
  /// **'View Tournament Photos'**
  String get viewTournamentPhotos;

  /// No description provided for @genderMismatch.
  ///
  /// In en, this message translates to:
  /// **'Gender Mismatch'**
  String get genderMismatch;

  /// No description provided for @photoAlreadyUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo Already Uploaded'**
  String get photoAlreadyUploaded;

  /// No description provided for @viewParticipantPhoto.
  ///
  /// In en, this message translates to:
  /// **'View Participant Photo'**
  String get viewParticipantPhoto;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @photoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo Upload Failed'**
  String get photoUploadFailed;

  /// No description provided for @tournamentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Tournament Cancelled'**
  String get tournamentCancelled;

  /// No description provided for @refundFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund Failed'**
  String get refundFailed;

  /// No description provided for @createPrivateTournament.
  ///
  /// In en, this message translates to:
  /// **'Create Private Tournament'**
  String get createPrivateTournament;

  /// No description provided for @tournamentName.
  ///
  /// In en, this message translates to:
  /// **'Tournament Name'**
  String get tournamentName;

  /// No description provided for @maxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Maximum Participants'**
  String get maxParticipants;

  /// No description provided for @tournamentFormat.
  ///
  /// In en, this message translates to:
  /// **'Tournament Format'**
  String get tournamentFormat;

  /// No description provided for @leagueFormat.
  ///
  /// In en, this message translates to:
  /// **'League Format'**
  String get leagueFormat;

  /// No description provided for @eliminationFormat.
  ///
  /// In en, this message translates to:
  /// **'Elimination Format'**
  String get eliminationFormat;

  /// No description provided for @hybridFormat.
  ///
  /// In en, this message translates to:
  /// **'League + Elimination'**
  String get hybridFormat;

  /// No description provided for @eliminationMaxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Maximum 8 participants for elimination format'**
  String get eliminationMaxParticipants;

  /// No description provided for @eliminationMaxParticipantsWarning.
  ///
  /// In en, this message translates to:
  /// **'Maximum 8 participants allowed for elimination format'**
  String get eliminationMaxParticipantsWarning;

  /// Description for weekly male tournament with 1000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Weekly male tournament - 300 participant capacity'**
  String get weeklyMaleTournament1000Description;

  /// Description for weekly male tournament with 10000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Premium male tournament - 100 participant capacity'**
  String get weeklyMaleTournament10000Description;

  /// Description for weekly female tournament with 1000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Weekly female tournament - 300 participant capacity'**
  String get weeklyFemaleTournament1000Description;

  /// Description for weekly female tournament with 10000 coin entry fee
  ///
  /// In en, this message translates to:
  /// **'Premium female tournament - 100 participant capacity'**
  String get weeklyFemaleTournament10000Description;
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
      <String>['de', 'en', 'es', 'tr'].contains(locale.languageCode);

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
    case 'es':
      return AppLocalizationsEs();
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
