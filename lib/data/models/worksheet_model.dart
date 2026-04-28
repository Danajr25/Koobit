import 'package:equatable/equatable.dart';
import 'question_model.dart';

/// Worksheet status enumeration
enum WorksheetStatus {
  notStarted,   // Created but not started
  inProgress,   // Child is working on it
  submitted,    // First submission done
  correcting,   // Child is doing corrections
  completed,    // All done (passed or corrections done)
}

/// Represents a daily worksheet for a child
class WorksheetModel extends Equatable {
  final String id;
  final String childId;
  final int level;
  final int phase;
  final DateTime worksheetDate;
  final WorksheetStatus status;
  final int totalQuestions;      // Always 100
  final int correctCount;        // First submission correct count
  final int incorrectCount;      // First submission incorrect count
  final int correctedCount;      // Questions corrected
  final int scorePercentage;     // First submission score (0-100)
  final bool passed;             // >= 95% on first submission
  final int starsEarned;         // 0-3 stars
  final int timeLimitSeconds;    // 900 (15 minutes)
  final int timeSpentSeconds;    // Actual time taken
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionModel>? questions; // Optional - loaded separately

  const WorksheetModel({
    required this.id,
    required this.childId,
    required this.level,
    required this.phase,
    required this.worksheetDate,
    this.status = WorksheetStatus.notStarted,
    this.totalQuestions = 100,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.correctedCount = 0,
    this.scorePercentage = 0,
    this.passed = false,
    this.starsEarned = 0,
    this.timeLimitSeconds = 900,
    this.timeSpentSeconds = 0,
    this.startedAt,
    this.submittedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.questions,
  });

  /// Check if worksheet is for today
  bool get isToday {
    final now = DateTime.now();
    return worksheetDate.year == now.year &&
        worksheetDate.month == now.month &&
        worksheetDate.day == now.day;
  }

  /// Get remaining time in seconds
  int get remainingSeconds {
    if (status != WorksheetStatus.inProgress) return 0;
    final remaining = timeLimitSeconds - timeSpentSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if time is up
  bool get isTimeUp => timeSpentSeconds >= timeLimitSeconds;

  /// Get questions that need correction
  List<QuestionModel> get questionsNeedingCorrection {
    return questions?.where((q) => q.needsCorrection).toList() ?? [];
  }

  /// Calculate stars based on score:
  /// 100% = 3 stars
  /// 95-99% = 2 stars
  /// 90-94% = 1 star
  /// < 90% = 0 stars
  static int calculateStars(int percentage) {
    if (percentage >= 100) return 3;
    if (percentage >= 95) return 2;
    if (percentage >= 90) return 1;
    return 0;
  }

  /// Create from JSON (Supabase response)
  factory WorksheetModel.fromJson(Map<String, dynamic> json) {
    return WorksheetModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      level: json['level'] as int,
      phase: json['phase'] as int,
      worksheetDate: DateTime.parse(json['worksheet_date'] as String),
      status: WorksheetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorksheetStatus.notStarted,
      ),
      totalQuestions: json['total_questions'] as int? ?? 100,
      correctCount: json['correct_count'] as int? ?? 0,
      incorrectCount: json['incorrect_count'] as int? ?? 0,
      correctedCount: json['corrected_count'] as int? ?? 0,
      scorePercentage: json['score_percentage'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      starsEarned: json['stars_earned'] as int? ?? 0,
      timeLimitSeconds: json['time_limit_seconds'] as int? ?? 900,
      timeSpentSeconds: json['time_spent_seconds'] as int? ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
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
      'worksheet_date': worksheetDate.toIso8601String().split('T')[0],
      'status': status.name,
      'total_questions': totalQuestions,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'corrected_count': correctedCount,
      'score_percentage': scorePercentage,
      'passed': passed,
      'stars_earned': starsEarned,
      'time_limit_seconds': timeLimitSeconds,
      'time_spent_seconds': timeSpentSeconds,
      'started_at': startedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  WorksheetModel copyWith({
    String? id,
    String? childId,
    int? level,
    int? phase,
    DateTime? worksheetDate,
    WorksheetStatus? status,
    int? totalQuestions,
    int? correctCount,
    int? incorrectCount,
    int? correctedCount,
    int? scorePercentage,
    bool? passed,
    int? starsEarned,
    int? timeLimitSeconds,
    int? timeSpentSeconds,
    DateTime? startedAt,
    DateTime? submittedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuestionModel>? questions,
  }) {
    return WorksheetModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      level: level ?? this.level,
      phase: phase ?? this.phase,
      worksheetDate: worksheetDate ?? this.worksheetDate,
      status: status ?? this.status,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      correctedCount: correctedCount ?? this.correctedCount,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      passed: passed ?? this.passed,
      starsEarned: starsEarned ?? this.starsEarned,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        level,
        phase,
        worksheetDate,
        status,
        totalQuestions,
        correctCount,
        incorrectCount,
        correctedCount,
        scorePercentage,
        passed,
        starsEarned,
        timeLimitSeconds,
        timeSpentSeconds,
        startedAt,
        submittedAt,
        completedAt,
        createdAt,
        updatedAt,
        questions,
      ];
}
