import 'package:equatable/equatable.dart';

/// Achievement type enumeration
enum AchievementType {
  // Streak achievements
  streak3Days,
  streak7Days,
  streak14Days,
  streak30Days,
  streak100Days,
  streak365Days,
  
  // Worksheet achievements
  firstWorksheet,
  tenWorksheets,
  fiftyWorksheets,
  hundredWorksheets,
  fiveHundredWorksheets,
  
  // Score achievements
  perfectScore,
  tenPerfectScores,
  fiftyPerfectScores,
  
  // Level achievements
  level5Complete,
  level10Complete,
  level25Complete,
  level54Complete,
  
  // Phase achievements
  phase1Master,
  phase2Master,
  phase3Master,
  phase4Master,
  phase5Master,
  phase6Master,
  phase7Master,
  phase8Master,
  phase9Master,
  phase10Master,
  phase11Master,
  phase12Master,
  
  // Speed achievements
  speedDemon,        // Complete worksheet in under 5 minutes
  quickThinker,      // Complete worksheet in under 10 minutes
  
  // Stars achievements
  fiftyStars,
  hundredStars,
  fiveHundredStars,
  thousandStars,
}

/// Achievement configuration with required values
class AchievementConfig {
  final String name;
  final String description;
  final String iconPath;
  final int? requiredValue;

  const AchievementConfig({
    required this.name,
    required this.description,
    required this.iconPath,
    this.requiredValue,
  });
}

/// Predefined achievement configurations
class Achievements {
  Achievements._();
  
  static const Map<AchievementType, AchievementConfig> configs = {
    AchievementType.streak3Days: AchievementConfig(
      name: '3 Day Streak',
      description: 'Complete worksheets 3 days in a row',
      iconPath: 'assets/icons/achievements/streak_3.png',
      requiredValue: 3,
    ),
    AchievementType.streak7Days: AchievementConfig(
      name: 'Week Warrior',
      description: 'Complete worksheets 7 days in a row',
      iconPath: 'assets/icons/achievements/streak_7.png',
      requiredValue: 7,
    ),
    AchievementType.streak14Days: AchievementConfig(
      name: 'Two Week Champion',
      description: 'Complete worksheets 14 days in a row',
      iconPath: 'assets/icons/achievements/streak_14.png',
      requiredValue: 14,
    ),
    AchievementType.streak30Days: AchievementConfig(
      name: 'Monthly Master',
      description: 'Complete worksheets 30 days in a row',
      iconPath: 'assets/icons/achievements/streak_30.png',
      requiredValue: 30,
    ),
    AchievementType.streak100Days: AchievementConfig(
      name: 'Century Hero',
      description: 'Complete worksheets 100 days in a row',
      iconPath: 'assets/icons/achievements/streak_100.png',
      requiredValue: 100,
    ),
    AchievementType.streak365Days: AchievementConfig(
      name: 'Year Legend',
      description: 'Complete worksheets 365 days in a row',
      iconPath: 'assets/icons/achievements/streak_365.png',
      requiredValue: 365,
    ),
    AchievementType.firstWorksheet: AchievementConfig(
      name: 'First Step',
      description: 'Complete your first worksheet',
      iconPath: 'assets/icons/achievements/first_worksheet.png',
      requiredValue: 1,
    ),
    AchievementType.tenWorksheets: AchievementConfig(
      name: 'Getting Started',
      description: 'Complete 10 worksheets',
      iconPath: 'assets/icons/achievements/worksheets_10.png',
      requiredValue: 10,
    ),
    AchievementType.fiftyWorksheets: AchievementConfig(
      name: 'Dedicated Learner',
      description: 'Complete 50 worksheets',
      iconPath: 'assets/icons/achievements/worksheets_50.png',
      requiredValue: 50,
    ),
    AchievementType.hundredWorksheets: AchievementConfig(
      name: 'Math Enthusiast',
      description: 'Complete 100 worksheets',
      iconPath: 'assets/icons/achievements/worksheets_100.png',
      requiredValue: 100,
    ),
    AchievementType.fiveHundredWorksheets: AchievementConfig(
      name: 'Math Legend',
      description: 'Complete 500 worksheets',
      iconPath: 'assets/icons/achievements/worksheets_500.png',
      requiredValue: 500,
    ),
    AchievementType.perfectScore: AchievementConfig(
      name: 'Perfect Score',
      description: 'Get 100% on a worksheet',
      iconPath: 'assets/icons/achievements/perfect.png',
      requiredValue: 1,
    ),
    AchievementType.tenPerfectScores: AchievementConfig(
      name: 'Perfectionist',
      description: 'Get 100% on 10 worksheets',
      iconPath: 'assets/icons/achievements/perfect_10.png',
      requiredValue: 10,
    ),
    AchievementType.fiftyPerfectScores: AchievementConfig(
      name: 'Flawless',
      description: 'Get 100% on 50 worksheets',
      iconPath: 'assets/icons/achievements/perfect_50.png',
      requiredValue: 50,
    ),
    AchievementType.speedDemon: AchievementConfig(
      name: 'Speed Demon',
      description: 'Complete a worksheet in under 5 minutes',
      iconPath: 'assets/icons/achievements/speed.png',
      requiredValue: 300, // in seconds
    ),
    AchievementType.quickThinker: AchievementConfig(
      name: 'Quick Thinker',
      description: 'Complete a worksheet in under 10 minutes',
      iconPath: 'assets/icons/achievements/quick.png',
      requiredValue: 600, // in seconds
    ),
    AchievementType.fiftyStars: AchievementConfig(
      name: 'Star Collector',
      description: 'Earn 50 stars',
      iconPath: 'assets/icons/achievements/stars_50.png',
      requiredValue: 50,
    ),
    AchievementType.hundredStars: AchievementConfig(
      name: 'Star Master',
      description: 'Earn 100 stars',
      iconPath: 'assets/icons/achievements/stars_100.png',
      requiredValue: 100,
    ),
    AchievementType.fiveHundredStars: AchievementConfig(
      name: 'Constellation',
      description: 'Earn 500 stars',
      iconPath: 'assets/icons/achievements/stars_500.png',
      requiredValue: 500,
    ),
    AchievementType.thousandStars: AchievementConfig(
      name: 'Galaxy',
      description: 'Earn 1000 stars',
      iconPath: 'assets/icons/achievements/stars_1000.png',
      requiredValue: 1000,
    ),
    // Level achievements...
    AchievementType.level5Complete: AchievementConfig(
      name: 'Level 5 Complete',
      description: 'Complete all worksheets in level 5',
      iconPath: 'assets/icons/achievements/level_5.png',
      requiredValue: 5,
    ),
    AchievementType.level10Complete: AchievementConfig(
      name: 'Double Digits',
      description: 'Complete all worksheets in level 10',
      iconPath: 'assets/icons/achievements/level_10.png',
      requiredValue: 10,
    ),
    AchievementType.level25Complete: AchievementConfig(
      name: 'Quarter Century',
      description: 'Complete all worksheets in level 25',
      iconPath: 'assets/icons/achievements/level_25.png',
      requiredValue: 25,
    ),
    AchievementType.level54Complete: AchievementConfig(
      name: 'Math Master',
      description: 'Complete all 54 levels',
      iconPath: 'assets/icons/achievements/level_54.png',
      requiredValue: 54,
    ),
    // Phase achievements...
    AchievementType.phase1Master: AchievementConfig(
      name: 'Phase 1 Master',
      description: 'Complete all levels in Phase 1: Tracing',
      iconPath: 'assets/icons/achievements/phase_1.png',
    ),
    AchievementType.phase2Master: AchievementConfig(
      name: 'Phase 2 Master',
      description: 'Complete all levels in Phase 2: Counting',
      iconPath: 'assets/icons/achievements/phase_2.png',
    ),
    AchievementType.phase3Master: AchievementConfig(
      name: 'Phase 3 Master',
      description: 'Complete all levels in Phase 3: Number Bonds',
      iconPath: 'assets/icons/achievements/phase_3.png',
    ),
    AchievementType.phase4Master: AchievementConfig(
      name: 'Phase 4 Master',
      description: 'Complete all levels in Phase 4: Addition',
      iconPath: 'assets/icons/achievements/phase_4.png',
    ),
    AchievementType.phase5Master: AchievementConfig(
      name: 'Phase 5 Master',
      description: 'Complete all levels in Phase 5: Subtraction',
      iconPath: 'assets/icons/achievements/phase_5.png',
    ),
    AchievementType.phase6Master: AchievementConfig(
      name: 'Phase 6 Master',
      description: 'Complete all levels in Phase 6: Multiplication',
      iconPath: 'assets/icons/achievements/phase_6.png',
    ),
    AchievementType.phase7Master: AchievementConfig(
      name: 'Phase 7 Master',
      description: 'Complete all levels in Phase 7: Division',
      iconPath: 'assets/icons/achievements/phase_7.png',
    ),
    AchievementType.phase8Master: AchievementConfig(
      name: 'Phase 8 Master',
      description: 'Complete all levels in Phase 8: Fractions & Decimals',
      iconPath: 'assets/icons/achievements/phase_8.png',
    ),
    AchievementType.phase9Master: AchievementConfig(
      name: 'Phase 9 Master',
      description: 'Complete all levels in Phase 9: Square Roots',
      iconPath: 'assets/icons/achievements/phase_9.png',
    ),
    AchievementType.phase10Master: AchievementConfig(
      name: 'Phase 10 Master',
      description: 'Complete all levels in Phase 10: Polynomials',
      iconPath: 'assets/icons/achievements/phase_10.png',
    ),
    AchievementType.phase11Master: AchievementConfig(
      name: 'Phase 11 Master',
      description: 'Complete all levels in Phase 11: Factorization',
      iconPath: 'assets/icons/achievements/phase_11.png',
    ),
    AchievementType.phase12Master: AchievementConfig(
      name: 'Phase 12 Master',
      description: 'Complete all levels in Phase 12: Geometry',
      iconPath: 'assets/icons/achievements/phase_12.png',
    ),
  };
}

/// Represents a child's earned achievement
class AchievementModel extends Equatable {
  final String id;
  final String childId;
  final AchievementType type;
  final DateTime earnedAt;
  final bool notified; // Whether child has seen the achievement popup
  final DateTime createdAt;

  const AchievementModel({
    required this.id,
    required this.childId,
    required this.type,
    required this.earnedAt,
    this.notified = false,
    required this.createdAt,
  });

  /// Get achievement configuration
  AchievementConfig get config => Achievements.configs[type]!;

  /// Create from JSON (Supabase response)
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.firstWorksheet,
      ),
      earnedAt: DateTime.parse(json['earned_at'] as String),
      notified: json['notified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'type': type.name,
      'earned_at': earnedAt.toIso8601String(),
      'notified': notified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  AchievementModel copyWith({
    String? id,
    String? childId,
    AchievementType? type,
    DateTime? earnedAt,
    bool? notified,
    DateTime? createdAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      type: type ?? this.type,
      earnedAt: earnedAt ?? this.earnedAt,
      notified: notified ?? this.notified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        type,
        earnedAt,
        notified,
        createdAt,
      ];
}
