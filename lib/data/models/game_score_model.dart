import 'package:equatable/equatable.dart';

/// Available mini-games
enum GameType {
  flappyBird,
  balloonPop,
  platformer,
}

/// Game configuration
class GameConfig {
  final String name;
  final String description;
  final String iconPath;
  final int tokenCost; // Tokens needed to play

  const GameConfig({
    required this.name,
    required this.description,
    required this.iconPath,
    required this.tokenCost,
  });
}

/// Predefined game configurations
class Games {
  Games._();
  
  static const Map<GameType, GameConfig> configs = {
    GameType.flappyBird: GameConfig(
      name: 'Flappy Bird',
      description: 'Tap to fly through obstacles',
      iconPath: 'assets/icons/games/flappy_bird.png',
      tokenCost: 1,
    ),
    GameType.balloonPop: GameConfig(
      name: 'Balloon Pop',
      description: 'Pop balloons with math answers',
      iconPath: 'assets/icons/games/balloon_pop.png',
      tokenCost: 1,
    ),
    GameType.platformer: GameConfig(
      name: 'Adventure Run',
      description: 'Run and jump through levels',
      iconPath: 'assets/icons/games/platformer.png',
      tokenCost: 2,
    ),
  };

  /// Get token cost for a game
  static int getTokenCost(GameType type) {
    return configs[type]?.tokenCost ?? 1;
  }
}

/// Represents a child's game score
class GameScoreModel extends Equatable {
  final String id;
  final String childId;
  final GameType gameType;
  final int score;
  final int highScore;
  final int playtime; // in seconds
  final DateTime playedAt;
  final DateTime createdAt;

  const GameScoreModel({
    required this.id,
    required this.childId,
    required this.gameType,
    required this.score,
    required this.highScore,
    this.playtime = 0,
    required this.playedAt,
    required this.createdAt,
  });

  /// Check if this is a new high score
  bool get isNewHighScore => score > highScore;

  /// Get game configuration
  GameConfig get config => Games.configs[gameType]!;

  /// Create from JSON (Supabase response)
  factory GameScoreModel.fromJson(Map<String, dynamic> json) {
    return GameScoreModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      gameType: GameType.values.firstWhere(
        (e) => e.name == json['game_type'],
        orElse: () => GameType.flappyBird,
      ),
      score: json['score'] as int,
      highScore: json['high_score'] as int,
      playtime: json['playtime'] as int? ?? 0,
      playedAt: DateTime.parse(json['played_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'game_type': gameType.name,
      'score': score,
      'high_score': highScore,
      'playtime': playtime,
      'played_at': playedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  GameScoreModel copyWith({
    String? id,
    String? childId,
    GameType? gameType,
    int? score,
    int? highScore,
    int? playtime,
    DateTime? playedAt,
    DateTime? createdAt,
  }) {
    return GameScoreModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      gameType: gameType ?? this.gameType,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      playtime: playtime ?? this.playtime,
      playedAt: playedAt ?? this.playedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        gameType,
        score,
        highScore,
        playtime,
        playedAt,
        createdAt,
      ];
}

/// Represents aggregated game statistics for a child
class GameStatsModel extends Equatable {
  final String childId;
  final GameType gameType;
  final int highScore;
  final int totalPlays;
  final int totalPlaytime;
  final DateTime? lastPlayedAt;

  const GameStatsModel({
    required this.childId,
    required this.gameType,
    this.highScore = 0,
    this.totalPlays = 0,
    this.totalPlaytime = 0,
    this.lastPlayedAt,
  });

  /// Get average playtime per session
  int get averagePlaytime => 
      totalPlays > 0 ? totalPlaytime ~/ totalPlays : 0;

  /// Create from JSON (Supabase response)
  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      childId: json['child_id'] as String,
      gameType: GameType.values.firstWhere(
        (e) => e.name == json['game_type'],
        orElse: () => GameType.flappyBird,
      ),
      highScore: json['high_score'] as int? ?? 0,
      totalPlays: json['total_plays'] as int? ?? 0,
      totalPlaytime: json['total_playtime'] as int? ?? 0,
      lastPlayedAt: json['last_played_at'] != null
          ? DateTime.parse(json['last_played_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'game_type': gameType.name,
      'high_score': highScore,
      'total_plays': totalPlays,
      'total_playtime': totalPlaytime,
      'last_played_at': lastPlayedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        childId,
        gameType,
        highScore,
        totalPlays,
        totalPlaytime,
        lastPlayedAt,
      ];
}
