import 'package:flutter/material.dart';
import 'en_strings.dart';
import 'ms_strings.dart';

/// Supported languages
enum AppLanguage {
  english('en', 'English'),
  bahasaMalaysia('ms', 'Bahasa Malaysia');

  final String code;
  final String displayName;

  const AppLanguage(this.code, this.displayName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Localization manager for handling multi-language support
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ms'),
  ];

  bool get isEnglish => locale.languageCode == 'en';
  bool get isMalay => locale.languageCode == 'ms';

  // General
  String get appName => isEnglish ? EnStrings.appName : MsStrings.appName;
  String get ok => isEnglish ? EnStrings.ok : MsStrings.ok;
  String get cancel => isEnglish ? EnStrings.cancel : MsStrings.cancel;
  String get save => isEnglish ? EnStrings.save : MsStrings.save;
  String get delete => isEnglish ? EnStrings.delete : MsStrings.delete;
  String get edit => isEnglish ? EnStrings.edit : MsStrings.edit;
  String get back => isEnglish ? EnStrings.back : MsStrings.back;
  String get next => isEnglish ? EnStrings.next : MsStrings.next;
  String get done => isEnglish ? EnStrings.done : MsStrings.done;
  String get retry => isEnglish ? EnStrings.retry : MsStrings.retry;
  String get loading => isEnglish ? EnStrings.loading : MsStrings.loading;
  String get error => isEnglish ? EnStrings.error : MsStrings.error;
  String get success => isEnglish ? EnStrings.success : MsStrings.success;
  String get warning => isEnglish ? EnStrings.warning : MsStrings.warning;
  String get yes => isEnglish ? EnStrings.yes : MsStrings.yes;
  String get no => isEnglish ? EnStrings.no : MsStrings.no;
  String get close => isEnglish ? EnStrings.close : MsStrings.close;
  String get submit => isEnglish ? EnStrings.submit : MsStrings.submit;
  String get start => isEnglish ? EnStrings.start : MsStrings.start;
  String get pause => isEnglish ? EnStrings.pause : MsStrings.pause;
  String get resume => isEnglish ? EnStrings.resume : MsStrings.resume;
  String get stop => isEnglish ? EnStrings.stop : MsStrings.stop;

  // Auth
  String get login => isEnglish ? EnStrings.login : MsStrings.login;
  String get logout => isEnglish ? EnStrings.logout : MsStrings.logout;
  String get register => isEnglish ? EnStrings.register : MsStrings.register;
  String get email => isEnglish ? EnStrings.email : MsStrings.email;
  String get password => isEnglish ? EnStrings.password : MsStrings.password;
  String get confirmPassword => isEnglish ? EnStrings.confirmPassword : MsStrings.confirmPassword;
  String get forgotPassword => isEnglish ? EnStrings.forgotPassword : MsStrings.forgotPassword;
  String get resetPassword => isEnglish ? EnStrings.resetPassword : MsStrings.resetPassword;
  String get createAccount => isEnglish ? EnStrings.createAccount : MsStrings.createAccount;
  String get alreadyHaveAccount => isEnglish ? EnStrings.alreadyHaveAccount : MsStrings.alreadyHaveAccount;
  String get dontHaveAccount => isEnglish ? EnStrings.dontHaveAccount : MsStrings.dontHaveAccount;
  String get loginSuccess => isEnglish ? EnStrings.loginSuccess : MsStrings.loginSuccess;
  String get registerSuccess => isEnglish ? EnStrings.registerSuccess : MsStrings.registerSuccess;
  String get logoutSuccess => isEnglish ? EnStrings.logoutSuccess : MsStrings.logoutSuccess;
  String get invalidEmail => isEnglish ? EnStrings.invalidEmail : MsStrings.invalidEmail;
  String get passwordTooShort => isEnglish ? EnStrings.passwordTooShort : MsStrings.passwordTooShort;
  String get passwordsDoNotMatch => isEnglish ? EnStrings.passwordsDoNotMatch : MsStrings.passwordsDoNotMatch;
  String get enterEmail => isEnglish ? EnStrings.enterEmail : MsStrings.enterEmail;
  String get enterPassword => isEnglish ? EnStrings.enterPassword : MsStrings.enterPassword;
  String get parentPassword => isEnglish ? EnStrings.parentPassword : MsStrings.parentPassword;
  String get parentPasswordHint => isEnglish ? EnStrings.parentPasswordHint : MsStrings.parentPasswordHint;
  String get enterParentPassword => isEnglish ? EnStrings.enterParentPassword : MsStrings.enterParentPassword;

  // Child Profile
  String get addChild => isEnglish ? EnStrings.addChild : MsStrings.addChild;
  String get editChild => isEnglish ? EnStrings.editChild : MsStrings.editChild;
  String get deleteChild => isEnglish ? EnStrings.deleteChild : MsStrings.deleteChild;
  String get childName => isEnglish ? EnStrings.childName : MsStrings.childName;
  String get selectChild => isEnglish ? EnStrings.selectChild : MsStrings.selectChild;
  String get switchChild => isEnglish ? EnStrings.switchChild : MsStrings.switchChild;
  String get enterChildName => isEnglish ? EnStrings.enterChildName : MsStrings.enterChildName;
  String get childAddedSuccess => isEnglish ? EnStrings.childAddedSuccess : MsStrings.childAddedSuccess;
  String get childUpdatedSuccess => isEnglish ? EnStrings.childUpdatedSuccess : MsStrings.childUpdatedSuccess;
  String get childDeletedSuccess => isEnglish ? EnStrings.childDeletedSuccess : MsStrings.childDeletedSuccess;
  String get confirmDeleteChild => isEnglish ? EnStrings.confirmDeleteChild : MsStrings.confirmDeleteChild;
  String get noChildren => isEnglish ? EnStrings.noChildren : MsStrings.noChildren;
  String get addFirstChild => isEnglish ? EnStrings.addFirstChild : MsStrings.addFirstChild;

  // Home
  String get home => isEnglish ? EnStrings.home : MsStrings.home;
  String get hello => isEnglish ? EnStrings.hello : MsStrings.hello;
  String get explore => isEnglish ? EnStrings.explore : MsStrings.explore;
  String get welcomeBack => isEnglish ? EnStrings.welcomeBack : MsStrings.welcomeBack;
  String get todayWorksheet => isEnglish ? EnStrings.todayWorksheet : MsStrings.todayWorksheet;
  String get todaysWorksheet => isEnglish ? EnStrings.todaysWorksheet : MsStrings.todaysWorksheet;
  String get worksheetCompleted => isEnglish ? EnStrings.worksheetCompleted : MsStrings.worksheetCompleted;
  String get comeBackTomorrow => isEnglish ? EnStrings.comeBackTomorrow : MsStrings.comeBackTomorrow;
  String get worksheetDescription => isEnglish ? EnStrings.worksheetDescription : MsStrings.worksheetDescription;
  String get startNow => isEnglish ? EnStrings.startNow : MsStrings.startNow;
  String get continueWorksheet => isEnglish ? EnStrings.continueWorksheet : MsStrings.continueWorksheet;
  String get startWorksheet => isEnglish ? EnStrings.startWorksheet : MsStrings.startWorksheet;
  String get viewProgress => isEnglish ? EnStrings.viewProgress : MsStrings.viewProgress;
  String get currentLevel => isEnglish ? EnStrings.currentLevel : MsStrings.currentLevel;
  String get currentStreak => isEnglish ? EnStrings.currentStreak : MsStrings.currentStreak;
  String get days => isEnglish ? EnStrings.days : MsStrings.days;
  String get totalStars => isEnglish ? EnStrings.totalStars : MsStrings.totalStars;

  // Level Map
  String get levels => isEnglish ? EnStrings.levels : MsStrings.levels;
  String get level => isEnglish ? EnStrings.level : MsStrings.level;
  String get levelMap => isEnglish ? EnStrings.levelMap : MsStrings.levelMap;
  String get phase => isEnglish ? EnStrings.phase : MsStrings.phase;
  String get locked => isEnglish ? EnStrings.locked : MsStrings.locked;
  String get unlocked => isEnglish ? EnStrings.unlocked : MsStrings.unlocked;
  String get completed => isEnglish ? EnStrings.completed : MsStrings.completed;
  String get inProgress => isEnglish ? EnStrings.inProgress : MsStrings.inProgress;
  String get unlockLevel => isEnglish ? EnStrings.unlockLevel : MsStrings.unlockLevel;
  String get levelUnlocked => isEnglish ? EnStrings.levelUnlocked : MsStrings.levelUnlocked;
  String get parentUnlock => isEnglish ? EnStrings.parentUnlock : MsStrings.parentUnlock;
  String get bestScore => isEnglish ? EnStrings.bestScore : MsStrings.bestScore;

  // Worksheet
  String get worksheet => isEnglish ? EnStrings.worksheet : MsStrings.worksheet;
  String get question => isEnglish ? EnStrings.question : MsStrings.question;
  String get page => isEnglish ? EnStrings.page : MsStrings.page;
  String get of_ => isEnglish ? EnStrings.of_ : MsStrings.of_;
  String get timeRemaining => isEnglish ? EnStrings.timeRemaining : MsStrings.timeRemaining;
  String get submitWorksheet => isEnglish ? EnStrings.submitWorksheet : MsStrings.submitWorksheet;
  String get confirmSubmit => isEnglish ? EnStrings.confirmSubmit : MsStrings.confirmSubmit;
  String get timeUp => isEnglish ? EnStrings.timeUp : MsStrings.timeUp;
  String get timeUpMessage => isEnglish ? EnStrings.timeUpMessage : MsStrings.timeUpMessage;
  String get tapToWrite => isEnglish ? EnStrings.tapToWrite : MsStrings.tapToWrite;
  String get clearAnswer => isEnglish ? EnStrings.clearAnswer : MsStrings.clearAnswer;
  String get nextQuestion => isEnglish ? EnStrings.nextQuestion : MsStrings.nextQuestion;
  String get previousQuestion => isEnglish ? EnStrings.previousQuestion : MsStrings.previousQuestion;

  // Results
  String get results => isEnglish ? EnStrings.results : MsStrings.results;
  String get yourScore => isEnglish ? EnStrings.yourScore : MsStrings.yourScore;
  String get correct => isEnglish ? EnStrings.correct : MsStrings.correct;
  String get incorrect => isEnglish ? EnStrings.incorrect : MsStrings.incorrect;
  String get timeTaken => isEnglish ? EnStrings.timeTaken : MsStrings.timeTaken;
  String get minutes => isEnglish ? EnStrings.minutes : MsStrings.minutes;
  String get seconds => isEnglish ? EnStrings.seconds : MsStrings.seconds;
  String get excellent => isEnglish ? EnStrings.excellent : MsStrings.excellent;
  String get greatJob => isEnglish ? EnStrings.greatJob : MsStrings.greatJob;
  String get goodEffort => isEnglish ? EnStrings.goodEffort : MsStrings.goodEffort;
  String get keepPracticing => isEnglish ? EnStrings.keepPracticing : MsStrings.keepPracticing;
  String get passed => isEnglish ? EnStrings.passed : MsStrings.passed;
  String get needsCorrection => isEnglish ? EnStrings.needsCorrection : MsStrings.needsCorrection;
  String get doCorrections => isEnglish ? EnStrings.doCorrections : MsStrings.doCorrections;
  String get viewIncorrect => isEnglish ? EnStrings.viewIncorrect : MsStrings.viewIncorrect;
  String get nextLevel => isEnglish ? EnStrings.nextLevel : MsStrings.nextLevel;

  // Corrections
  String get corrections => isEnglish ? EnStrings.corrections : MsStrings.corrections;
  String get correctYourAnswers => isEnglish ? EnStrings.correctYourAnswers : MsStrings.correctYourAnswers;
  String get remaining => isEnglish ? EnStrings.remaining : MsStrings.remaining;
  String get allCorrect => isEnglish ? EnStrings.allCorrect : MsStrings.allCorrect;
  String get worksheetComplete => isEnglish ? EnStrings.worksheetComplete : MsStrings.worksheetComplete;
  String get correctAnswer => isEnglish ? EnStrings.correctAnswer : MsStrings.correctAnswer;
  String get yourAnswer => isEnglish ? EnStrings.yourAnswer : MsStrings.yourAnswer;
  String get tryAgain => isEnglish ? EnStrings.tryAgain : MsStrings.tryAgain;

  // Calendar
  String get calendar => isEnglish ? EnStrings.calendar : MsStrings.calendar;
  String get today => isEnglish ? EnStrings.today : MsStrings.today;
  String get missed => isEnglish ? EnStrings.missed : MsStrings.missed;
  String get noWorksheetToday => isEnglish ? EnStrings.noWorksheetToday : MsStrings.noWorksheetToday;

  // Performance
  String get performance => isEnglish ? EnStrings.performance : MsStrings.performance;
  String get statistics => isEnglish ? EnStrings.statistics : MsStrings.statistics;
  String get worksheetsCompleted => isEnglish ? EnStrings.worksheetsCompleted : MsStrings.worksheetsCompleted;
  String get averageScore => isEnglish ? EnStrings.averageScore : MsStrings.averageScore;
  String get longestStreak => isEnglish ? EnStrings.longestStreak : MsStrings.longestStreak;
  String get thisWeek => isEnglish ? EnStrings.thisWeek : MsStrings.thisWeek;
  String get thisMonth => isEnglish ? EnStrings.thisMonth : MsStrings.thisMonth;
  String get allTime => isEnglish ? EnStrings.allTime : MsStrings.allTime;
  String get progressChart => isEnglish ? EnStrings.progressChart : MsStrings.progressChart;

  // Parent Dashboard
  String get parentDashboard => isEnglish ? EnStrings.parentDashboard : MsStrings.parentDashboard;
  String get childProgress => isEnglish ? EnStrings.childProgress : MsStrings.childProgress;
  String get levelManagement => isEnglish ? EnStrings.levelManagement : MsStrings.levelManagement;
  String get unlockAllLevels => isEnglish ? EnStrings.unlockAllLevels : MsStrings.unlockAllLevels;
  String get lockLevel => isEnglish ? EnStrings.lockLevel : MsStrings.lockLevel;
  String get scoreHistory => isEnglish ? EnStrings.scoreHistory : MsStrings.scoreHistory;
  String get weeklyReport => isEnglish ? EnStrings.weeklyReport : MsStrings.weeklyReport;

  // Settings
  String get settings => isEnglish ? EnStrings.settings : MsStrings.settings;
  String get language => isEnglish ? EnStrings.language : MsStrings.language;
  String get english => isEnglish ? EnStrings.english : MsStrings.english;
  String get bahasaMalaysia => isEnglish ? EnStrings.bahasaMalaysia : MsStrings.bahasaMalaysia;
  String get changePassword => isEnglish ? EnStrings.changePassword : MsStrings.changePassword;
  String get changeParentPassword => isEnglish ? EnStrings.changeParentPassword : MsStrings.changeParentPassword;
  String get notifications => isEnglish ? EnStrings.notifications : MsStrings.notifications;
  String get about => isEnglish ? EnStrings.about : MsStrings.about;
  String get privacyPolicy => isEnglish ? EnStrings.privacyPolicy : MsStrings.privacyPolicy;
  String get termsOfService => isEnglish ? EnStrings.termsOfService : MsStrings.termsOfService;
  String get version => isEnglish ? EnStrings.version : MsStrings.version;
  String get contactUs => isEnglish ? EnStrings.contactUs : MsStrings.contactUs;

  // Subscription
  String get subscription => isEnglish ? EnStrings.subscription : MsStrings.subscription;
  String get freeTrial => isEnglish ? EnStrings.freeTrial : MsStrings.freeTrial;
  String get daysRemaining => isEnglish ? EnStrings.daysRemaining : MsStrings.daysRemaining;
  String get trialExpired => isEnglish ? EnStrings.trialExpired : MsStrings.trialExpired;
  String get subscribe => isEnglish ? EnStrings.subscribe : MsStrings.subscribe;
  String get monthly => isEnglish ? EnStrings.monthly : MsStrings.monthly;
  String get yearly => isEnglish ? EnStrings.yearly : MsStrings.yearly;
  String get perMonth => isEnglish ? EnStrings.perMonth : MsStrings.perMonth;
  String get perYear => isEnglish ? EnStrings.perYear : MsStrings.perYear;
  String get currentPlan => isEnglish ? EnStrings.currentPlan : MsStrings.currentPlan;
  String get upgradePlan => isEnglish ? EnStrings.upgradePlan : MsStrings.upgradePlan;
  String get cancelSubscription => isEnglish ? EnStrings.cancelSubscription : MsStrings.cancelSubscription;
  String get restorePurchases => isEnglish ? EnStrings.restorePurchases : MsStrings.restorePurchases;
  String get subscriptionBenefits => isEnglish ? EnStrings.subscriptionBenefits : MsStrings.subscriptionBenefits;
  String get unlimitedAccess => isEnglish ? EnStrings.unlimitedAccess : MsStrings.unlimitedAccess;
  String get multipleChildren => isEnglish ? EnStrings.multipleChildren : MsStrings.multipleChildren;
  String get detailedReports => isEnglish ? EnStrings.detailedReports : MsStrings.detailedReports;
  String get noAds => isEnglish ? EnStrings.noAds : MsStrings.noAds;

  // Games
  String get games => isEnglish ? EnStrings.games : MsStrings.games;
  String get play => isEnglish ? EnStrings.play : MsStrings.play;
  String get gameTokens => isEnglish ? EnStrings.gameTokens : MsStrings.gameTokens;
  String get highScore => isEnglish ? EnStrings.highScore : MsStrings.highScore;
  String get playGame => isEnglish ? EnStrings.playGame : MsStrings.playGame;
  String get notEnoughTokens => isEnglish ? EnStrings.notEnoughTokens : MsStrings.notEnoughTokens;
  String get earnMoreTokens => isEnglish ? EnStrings.earnMoreTokens : MsStrings.earnMoreTokens;
  String get flappyBird => isEnglish ? EnStrings.flappyBird : MsStrings.flappyBird;
  String get balloonPop => isEnglish ? EnStrings.balloonPop : MsStrings.balloonPop;
  String get platformer => isEnglish ? EnStrings.platformer : MsStrings.platformer;
  String get gameOver => isEnglish ? EnStrings.gameOver : MsStrings.gameOver;
  String get newHighScore => isEnglish ? EnStrings.newHighScore : MsStrings.newHighScore;
  String get score => isEnglish ? EnStrings.score : MsStrings.score;
  String get playAgain => isEnglish ? EnStrings.playAgain : MsStrings.playAgain;

  // Tutorial
  String get tutorial => isEnglish ? EnStrings.tutorial : MsStrings.tutorial;
  String get watchTutorial => isEnglish ? EnStrings.watchTutorial : MsStrings.watchTutorial;
  String get skipTutorial => isEnglish ? EnStrings.skipTutorial : MsStrings.skipTutorial;
  String get tutorialComplete => isEnglish ? EnStrings.tutorialComplete : MsStrings.tutorialComplete;

  // Rewards
  String get rewards => isEnglish ? EnStrings.rewards : MsStrings.rewards;
  String get achievements => isEnglish ? EnStrings.achievements : MsStrings.achievements;
  String get badges => isEnglish ? EnStrings.badges : MsStrings.badges;
  String get stars => isEnglish ? EnStrings.stars : MsStrings.stars;
  String get earned => isEnglish ? EnStrings.earned : MsStrings.earned;
  String get streakBonus => isEnglish ? EnStrings.streakBonus : MsStrings.streakBonus;
  String get perfectScore => isEnglish ? EnStrings.perfectScore : MsStrings.perfectScore;
  String get firstWorksheet => isEnglish ? EnStrings.firstWorksheet : MsStrings.firstWorksheet;
  String get levelMaster => isEnglish ? EnStrings.levelMaster : MsStrings.levelMaster;
  String get weekStreak => isEnglish ? EnStrings.weekStreak : MsStrings.weekStreak;
  String get monthStreak => isEnglish ? EnStrings.monthStreak : MsStrings.monthStreak;

  // Errors
  String get somethingWentWrong => isEnglish ? EnStrings.somethingWentWrong : MsStrings.somethingWentWrong;
  String get noInternet => isEnglish ? EnStrings.noInternet : MsStrings.noInternet;
  String get pleaseCheckConnection => isEnglish ? EnStrings.pleaseCheckConnection : MsStrings.pleaseCheckConnection;
  String get sessionExpired => isEnglish ? EnStrings.sessionExpired : MsStrings.sessionExpired;
  String get tryAgainLater => isEnglish ? EnStrings.tryAgainLater : MsStrings.tryAgainLater;

  // Confirmation
  String get confirmLogout => isEnglish ? EnStrings.confirmLogout : MsStrings.confirmLogout;
  String get confirmExit => isEnglish ? EnStrings.confirmExit : MsStrings.confirmExit;
  String get unsavedChanges => isEnglish ? EnStrings.unsavedChanges : MsStrings.unsavedChanges;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
