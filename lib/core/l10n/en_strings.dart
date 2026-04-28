/// English strings for the app
class EnStrings {
  EnStrings._();

  // General
  static const String appName = 'Math Learning App';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String close = 'Close';
  static const String submit = 'Submit';
  static const String start = 'Start';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String stop = 'Stop';
  
  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String enterEmail = 'Please enter your email';
  static const String enterPassword = 'Please enter your password';
  static const String parentPassword = 'Parent Password';
  static const String parentPasswordHint = 'Set a password to protect parent features';
  static const String enterParentPassword = 'Enter parent password to continue';
  
  // Child Profile
  static const String addChild = 'Add Child';
  static const String editChild = 'Edit Child';
  static const String deleteChild = 'Delete Child';
  static const String childName = 'Child Name';
  static const String selectChild = 'Select Child';
  static const String switchChild = 'Switch Child';
  static const String enterChildName = 'Please enter child name';
  static const String childAddedSuccess = 'Child profile added!';
  static const String childUpdatedSuccess = 'Child profile updated!';
  static const String childDeletedSuccess = 'Child profile deleted';
  static const String confirmDeleteChild = 'Are you sure you want to delete this child profile? All progress will be lost.';
  static const String noChildren = 'No children added yet';
  static const String addFirstChild = 'Add your first child to get started!';
  
  // Home
  static const String home = 'Home';
  static const String hello = 'Hello';
  static const String explore = 'Explore';
  static const String welcomeBack = 'Welcome Back';
  static const String todayWorksheet = "Today's Worksheet";
  static const String todaysWorksheet = "Today's Worksheet";
  static const String worksheetCompleted = 'Worksheet Completed!';
  static const String comeBackTomorrow = 'Great job! Come back tomorrow for more.';
  static const String worksheetDescription = '20 questions to practice your math skills';
  static const String startNow = 'Start Now';
  static const String continueWorksheet = 'Continue Worksheet';
  static const String startWorksheet = 'Start Worksheet';
  static const String viewProgress = 'View Progress';
  static const String currentLevel = 'Current Level';
  static const String currentStreak = 'Current Streak';
  static const String days = 'days';
  static const String totalStars = 'Total Stars';
  
  // Level Map
  static const String levels = 'Levels';
  static const String level = 'Level';
  static const String levelMap = 'Level Map';
  static const String phase = 'Phase';
  static const String locked = 'Locked';
  static const String unlocked = 'Unlocked';
  static const String completed = 'Completed';
  static const String inProgress = 'In Progress';
  static const String unlockLevel = 'Unlock Level';
  static const String levelUnlocked = 'Level unlocked!';
  static const String parentUnlock = 'Parent unlock required';
  static const String bestScore = 'Best Score';
  
  // Worksheet
  static const String worksheet = 'Worksheet';
  static const String question = 'Question';
  static const String page = 'Page';
  static const String of_ = 'of';
  static const String timeRemaining = 'Time Remaining';
  static const String submitWorksheet = 'Submit Worksheet';
  static const String confirmSubmit = 'Are you sure you want to submit? You still have time remaining.';
  static const String timeUp = "Time's Up!";
  static const String timeUpMessage = 'Your worksheet has been automatically submitted.';
  static const String tapToWrite = 'Tap to write your answer';
  static const String clearAnswer = 'Clear';
  static const String nextQuestion = 'Next';
  static const String previousQuestion = 'Previous';
  
  // Results
  static const String results = 'Results';
  static const String yourScore = 'Your Score';
  static const String correct = 'Correct';
  static const String incorrect = 'Incorrect';
  static const String timeTaken = 'Time Taken';
  static const String minutes = 'minutes';
  static const String seconds = 'seconds';
  static const String excellent = 'Excellent!';
  static const String greatJob = 'Great Job!';
  static const String goodEffort = 'Good Effort!';
  static const String keepPracticing = 'Keep Practicing!';
  static const String passed = 'PASSED!';
  static const String needsCorrection = 'Needs Correction';
  static const String doCorrections = 'Do Corrections';
  static const String viewIncorrect = 'View Incorrect Answers';
  static const String nextLevel = 'Next Level Unlocked!';
  
  // Corrections
  static const String corrections = 'Corrections';
  static const String correctYourAnswers = 'Correct your answers';
  static const String remaining = 'remaining';
  static const String allCorrect = 'All Correct!';
  static const String worksheetComplete = 'Worksheet Complete';
  static const String correctAnswer = 'Correct Answer';
  static const String yourAnswer = 'Your Answer';
  static const String tryAgain = 'Try Again';
  
  // Calendar
  static const String calendar = 'Calendar';
  static const String today = 'Today';
  static const String missed = 'Missed';
  static const String noWorksheetToday = 'No worksheet completed today';
  
  // Performance
  static const String performance = 'Performance';
  static const String statistics = 'Statistics';
  static const String worksheetsCompleted = 'Worksheets Completed';
  static const String averageScore = 'Average Score';
  static const String longestStreak = 'Longest Streak';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String allTime = 'All Time';
  static const String progressChart = 'Progress Chart';
  
  // Parent Dashboard
  static const String parentDashboard = 'Parent Dashboard';
  static const String childProgress = 'Child Progress';
  static const String levelManagement = 'Level Management';
  static const String unlockAllLevels = 'Unlock All Levels';
  static const String lockLevel = 'Lock Level';
  static const String scoreHistory = 'Score History';
  static const String weeklyReport = 'Weekly Report';
  
  // Settings
  static const String settings = 'Settings';
  static const String language = 'Language';
  static const String english = 'English';
  static const String bahasaMalaysia = 'Bahasa Malaysia';
  static const String changePassword = 'Change Password';
  static const String changeParentPassword = 'Change Parent Password';
  static const String notifications = 'Notifications';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String version = 'Version';
  static const String contactUs = 'Contact Us';
  
  // Subscription
  static const String subscription = 'Subscription';
  static const String freeTrial = 'Free Trial';
  static const String daysRemaining = 'days remaining';
  static const String trialExpired = 'Trial Expired';
  static const String subscribe = 'Subscribe';
  static const String monthly = 'Monthly';
  static const String yearly = 'Yearly';
  static const String perMonth = '/month';
  static const String perYear = '/year';
  static const String currentPlan = 'Current Plan';
  static const String upgradePlan = 'Upgrade Plan';
  static const String cancelSubscription = 'Cancel Subscription';
  static const String restorePurchases = 'Restore Purchases';
  static const String subscriptionBenefits = 'Subscription Benefits';
  static const String unlimitedAccess = 'Unlimited access to all levels';
  static const String multipleChildren = 'Multiple child profiles';
  static const String detailedReports = 'Detailed progress reports';
  static const String noAds = 'No advertisements';
  
  // Games
  static const String games = 'Games';
  static const String play = 'Play';
  static const String gameTokens = 'Game Tokens';
  static const String highScore = 'High Score';
  static const String playGame = 'Play Game';
  static const String notEnoughTokens = 'Not enough tokens';
  static const String earnMoreTokens = 'Complete worksheets to earn more tokens!';
  static const String flappyBird = 'Flappy Bird';
  static const String balloonPop = 'Balloon Pop';
  static const String platformer = 'Adventure Run';
  static const String gameOver = 'Game Over';
  static const String newHighScore = 'New High Score!';
  static const String score = 'Score';
  static const String playAgain = 'Play Again';
  
  // Tutorial
  static const String tutorial = 'Tutorial';
  static const String watchTutorial = 'Watch Tutorial';
  static const String skipTutorial = 'Skip';
  static const String tutorialComplete = 'Tutorial Complete';
  
  // Rewards
  static const String rewards = 'Rewards';
  static const String achievements = 'Achievements';
  static const String badges = 'Badges';
  static const String stars = 'Stars';
  static const String earned = 'Earned';
  static const String streakBonus = 'Streak Bonus';
  static const String perfectScore = 'Perfect Score';
  static const String firstWorksheet = 'First Worksheet';
  static const String levelMaster = 'Level Master';
  static const String weekStreak = 'Week Streak';
  static const String monthStreak = 'Month Streak';
  
  // Errors
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternet = 'No internet connection';
  static const String pleaseCheckConnection = 'Please check your connection and try again';
  static const String sessionExpired = 'Session expired. Please login again.';
  static const String tryAgainLater = 'Please try again later';
  
  // Confirmation
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmExit = 'Are you sure you want to exit?';
  static const String unsavedChanges = 'You have unsaved changes. Are you sure you want to leave?';
}
