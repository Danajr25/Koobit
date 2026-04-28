import 'package:equatable/equatable.dart';

/// Child profile model representing a child user within a family account
class ChildModel extends Equatable {
  final String id;
  final String userId; // Parent's user ID
  final String name;
  final String? avatarUrl;
  final int currentLevel;
  final int currentStreak; // Days in a row
  final int longestStreak;
  final int totalStars;
  final int gameTokens;
  final DateTime? lastWorksheetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChildModel({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.currentLevel = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalStars = 0,
    this.gameTokens = 0,
    this.lastWorksheetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if child did worksheet today
  bool get didWorksheetToday {
    if (lastWorksheetDate == null) return false;
    final now = DateTime.now();
    return lastWorksheetDate!.year == now.year &&
        lastWorksheetDate!.month == now.month &&
        lastWorksheetDate!.day == now.day;
  }

  /// Check if streak is still active (did worksheet yesterday or today)
  bool get isStreakActive {
    if (lastWorksheetDate == null) return false;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    // Check if last worksheet was today
    if (lastWorksheetDate!.year == now.year &&
        lastWorksheetDate!.month == now.month &&
        lastWorksheetDate!.day == now.day) {
      return true;
    }
    
    // Check if last worksheet was yesterday
    if (lastWorksheetDate!.year == yesterday.year &&
        lastWorksheetDate!.month == yesterday.month &&
        lastWorksheetDate!.day == yesterday.day) {
      return true;
    }
    
    return false;
  }

  /// Create from JSON (Supabase response)
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      currentLevel: json['current_level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalStars: json['total_stars'] as int? ?? 0,
      gameTokens: json['game_tokens'] as int? ?? 0,
      lastWorksheetDate: json['last_worksheet_date'] != null
          ? DateTime.parse(json['last_worksheet_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'current_level': currentLevel,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_stars': totalStars,
      'game_tokens': gameTokens,
      'last_worksheet_date': lastWorksheetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  ChildModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatarUrl,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    int? totalStars,
    int? gameTokens,
    DateTime? lastWorksheetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStars: totalStars ?? this.totalStars,
      gameTokens: gameTokens ?? this.gameTokens,
      lastWorksheetDate: lastWorksheetDate ?? this.lastWorksheetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        avatarUrl,
        currentLevel,
        currentStreak,
        longestStreak,
        totalStars,
        gameTokens,
        lastWorksheetDate,
        createdAt,
        updatedAt,
      ];
}
