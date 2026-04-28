/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Math Learning App';
  static const String appVersion = '1.0.0';

  // Worksheet Configuration
  static const int questionsPerPage = 10;
  static const int pagesPerWorksheet = 10;
  static const int totalQuestions = questionsPerPage * pagesPerWorksheet; // 100
  static const int worksheetTimeLimitMinutes = 15;
  static const int worksheetTimeLimitSeconds = worksheetTimeLimitMinutes * 60;
  static const int passingScorePercentage = 95;

  // Levels & Phases
  static const int totalLevels = 54; // Current implemented levels
  static const int totalPhases = 12;

  // Trial Period
  static const int trialPeriodDays = 30;

  // Rewards
  static const int starsPerCompletedWorksheet = 10;
  static const int starsPerPerfectScore = 25;
  static const int gameTokensPerWorksheet = 1;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Handwriting Recognition
  static const double minStrokeLength = 5.0;
  static const double recognitionConfidenceThreshold = 0.7;

  // Cache Keys
  static const String currentChildKey = 'current_child_id';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Supabase Table Names
  static const String userProfilesTable = 'user_profiles';
  static const String childrenTable = 'children';
  static const String levelsTable = 'levels';
  static const String childLevelProgressTable = 'child_level_progress';
  static const String worksheetsTable = 'worksheets';
  static const String submissionsTable = 'submissions';
  static const String dailyRecordsTable = 'daily_records';
  static const String achievementsTable = 'achievements';
  static const String childAchievementsTable = 'child_achievements';
  static const String gameTokensTable = 'game_tokens';
  static const String subscriptionsTable = 'subscriptions';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String authError = 'Authentication failed. Please login again.';

  // Supported Languages
  static const String englishCode = 'en';
  static const String malayCode = 'ms';
  static const List<String> supportedLanguages = [englishCode, malayCode];
}

/// Level configuration by phase
class LevelConfig {
  LevelConfig._();

  // Phase definitions with level ranges
  static const Map<int, PhaseInfo> phases = {
    1: PhaseInfo(
      id: 1,
      name: 'Hand Coordination',
      nameMs: 'Koordinasi Tangan',
      startLevel: 1,
      endLevel: 8,
    ),
    2: PhaseInfo(
      id: 2,
      name: 'Number Sequences',
      nameMs: 'Urutan Nombor',
      startLevel: 9,
      endLevel: 9,
    ),
    3: PhaseInfo(
      id: 3,
      name: 'Addition',
      nameMs: 'Penambahan',
      startLevel: 10,
      endLevel: 13,
    ),
    4: PhaseInfo(
      id: 4,
      name: 'Subtraction',
      nameMs: 'Penolakan',
      startLevel: 14,
      endLevel: 16,
    ),
    5: PhaseInfo(
      id: 5,
      name: 'Multiplication',
      nameMs: 'Pendaraban',
      startLevel: 17,
      endLevel: 18,
    ),
    6: PhaseInfo(
      id: 6,
      name: 'Division',
      nameMs: 'Pembahagian',
      startLevel: 19,
      endLevel: 20,
    ),
    7: PhaseInfo(
      id: 7,
      name: 'Fractions',
      nameMs: 'Pecahan',
      startLevel: 21,
      endLevel: 22,
    ),
    8: PhaseInfo(
      id: 8,
      name: 'Pre-Algebra',
      nameMs: 'Pra-Algebra',
      startLevel: 23,
      endLevel: 37,
    ),
    9: PhaseInfo(
      id: 9,
      name: 'Square Roots & Indices',
      nameMs: 'Punca Kuasa Dua & Indeks',
      startLevel: 38,
      endLevel: 42,
    ),
    10: PhaseInfo(
      id: 10,
      name: 'Polynomials',
      nameMs: 'Polinomial',
      startLevel: 43,
      endLevel: 45,
    ),
    11: PhaseInfo(
      id: 11,
      name: 'Factorization',
      nameMs: 'Pemfaktoran',
      startLevel: 46,
      endLevel: 56,
    ),
    12: PhaseInfo(
      id: 12,
      name: 'Geometry',
      nameMs: 'Geometri',
      startLevel: 57,
      endLevel: 62,
    ),
  };

  /// Get phase for a given level
  static PhaseInfo? getPhaseForLevel(int level) {
    for (final phase in phases.values) {
      if (level >= phase.startLevel && level <= phase.endLevel) {
        return phase;
      }
    }
    return null;
  }

  /// Get all levels in a phase
  static List<int> getLevelsInPhase(int phaseId) {
    final phase = phases[phaseId];
    if (phase == null) return [];
    return List.generate(
      phase.endLevel - phase.startLevel + 1,
      (index) => phase.startLevel + index,
    );
  }
}

/// Phase information
class PhaseInfo {
  final int id;
  final String name;
  final String nameMs;
  final int startLevel;
  final int endLevel;

  const PhaseInfo({
    required this.id,
    required this.name,
    required this.nameMs,
    required this.startLevel,
    required this.endLevel,
  });

  int get levelCount => endLevel - startLevel + 1;
}
