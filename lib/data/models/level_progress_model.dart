import 'package:equatable/equatable.dart';

/// Level status enumeration
enum LevelStatus {
  locked,       // Cannot access
  unlocked,     // Can access but not started
  inProgress,   // Working on this level
  completed,    // Passed with 95%+
  mastered,     // Perfect score achieved
}

/// Represents a child's progress in a specific level
class LevelProgressModel extends Equatable {
  final String id;
  final String childId;
  final int level;
  final int phase;
  final LevelStatus status;
  final int worksheetsCompleted;
  final int bestScore;
  final int totalStarsEarned;
  final bool parentUnlocked;     // If parent manually unlocked this level
  final DateTime? unlockedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LevelProgressModel({
    required this.id,
    required this.childId,
    required this.level,
    required this.phase,
    this.status = LevelStatus.locked,
    this.worksheetsCompleted = 0,
    this.bestScore = 0,
    this.totalStarsEarned = 0,
    this.parentUnlocked = false,
    this.unlockedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if level is accessible
  bool get isAccessible => 
      status != LevelStatus.locked || parentUnlocked;

  /// Check if progress has started
  bool get hasStarted => worksheetsCompleted > 0;

  /// Create from JSON (Supabase response)
  factory LevelProgressModel.fromJson(Map<String, dynamic> json) {
    return LevelProgressModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      level: json['level'] as int,
      phase: json['phase'] as int,
      status: LevelStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LevelStatus.locked,
      ),
      worksheetsCompleted: json['worksheets_completed'] as int? ?? 0,
      bestScore: json['best_score'] as int? ?? 0,
      totalStarsEarned: json['total_stars_earned'] as int? ?? 0,
      parentUnlocked: json['parent_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'level': level,
      'phase': phase,
      'status': status.name,
      'worksheets_completed': worksheetsCompleted,
      'best_score': bestScore,
      'total_stars_earned': totalStarsEarned,
      'parent_unlocked': parentUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  LevelProgressModel copyWith({
    String? id,
    String? childId,
    int? level,
    int? phase,
    LevelStatus? status,
    int? worksheetsCompleted,
    int? bestScore,
    int? totalStarsEarned,
    bool? parentUnlocked,
    DateTime? unlockedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LevelProgressModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      level: level ?? this.level,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      worksheetsCompleted: worksheetsCompleted ?? this.worksheetsCompleted,
      bestScore: bestScore ?? this.bestScore,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      parentUnlocked: parentUnlocked ?? this.parentUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        level,
        phase,
        status,
        worksheetsCompleted,
        bestScore,
        totalStarsEarned,
        parentUnlocked,
        unlockedAt,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
