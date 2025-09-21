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
  String get leaderboard => 'Leaderboard';

  @override
  String get tournament => 'Tournament';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

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
  String get coinsEarnedFromPredictions => 'Coins Earned from Predictions';

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
}
