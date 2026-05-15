import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../data/repositories/child_repository.dart';
import '../../widgets/cyber_widgets.dart';

const List<String> _sharedItemKeys = [
  'building_blocks',
  'speed_boost',
  'shield',
  'double_points',
  'pet_food',
  'hint',
  'time_boost',
  'new_pet_egg',
  'fuel_cells',
  'spaceship_skin',
];

const List<_GameDefinition> _gameCatalog = [
  _GameDefinition(
    key: 'math_builder',
    title: 'Math Builder',
    subtitle: 'Build a city by solving math problems',
    description: 'Complete challenges to construct houses, schools, hospitals and more.',
    icon: Icons.domain_rounded,
    accent: Color(0xFF00D4FF),
    rewardPattern: [
      _RewardBand(1, 2, 'building_blocks', 'Building Blocks'),
      _RewardBand(3, 4, 'speed_boost', 'Speed Boost'),
      _RewardBand(5, 6, 'shield', 'Shield'),
      _RewardBand(7, 8, 'double_points', 'Double Points'),
      _RewardBand(9, 10, 'spaceship_skin', 'New World Theme'),
    ],
  ),
  _GameDefinition(
    key: 'number_pet_adventure',
    title: 'Number Pet Adventure',
    subtitle: 'Raise a pet that evolves as you progress',
    description: 'Feed, train and evolve your pet by answering math challenges correctly.',
    icon: Icons.pets_rounded,
    accent: Color(0xFFBF5AF2),
    rewardPattern: [
      _RewardBand(1, 2, 'pet_food', 'Pet Food'),
      _RewardBand(3, 4, 'hint', 'Hint'),
      _RewardBand(5, 6, 'shield', 'Shield'),
      _RewardBand(7, 8, 'time_boost', 'Time Boost'),
      _RewardBand(9, 10, 'new_pet_egg', 'New Pet Egg'),
    ],
  ),
  _GameDefinition(
    key: 'space_math_explorer',
    title: 'Space Math Explorer',
    subtitle: 'Travel through planets and solve missions',
    description: 'Launch into space, clear planets, and unlock new spaceship skins.',
    icon: Icons.rocket_launch_rounded,
    accent: Color(0xFFFF9500),
    rewardPattern: [
      _RewardBand(1, 2, 'fuel_cells', 'Fuel Cells'),
      _RewardBand(3, 4, 'time_boost', 'Time Boost'),
      _RewardBand(5, 6, 'hint', 'Hint'),
      _RewardBand(7, 8, 'shield', 'Shield'),
      _RewardBand(9, 10, 'spaceship_skin', 'New Spaceship Skin'),
    ],
  ),
];

const String _levelPrefix = 'games_level_';
const String _scorePrefix = 'games_high_score_';
const String _inventoryPrefix = 'games_inventory_';

class GamesHubScreen extends StatefulWidget {
  final ChildModel child;

  const GamesHubScreen({super.key, required this.child});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  bool _isLoading = true;
  bool _hasWorksheetAccess = false;
  Map<String, int> _unlockedLevels = {};
  Map<String, int> _highScores = {};
  Map<String, int> _inventory = {};
  late ChildModel _child;

  @override
  void initState() {
    super.initState();
    _child = widget.child;
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevels = <String, int>{};
    final highScores = <String, int>{};

    for (final game in _gameCatalog) {
      unlockedLevels[game.key] = prefs.getInt('$_levelPrefix${_child.id}_${game.key}') ?? _initialUnlockedLevel;
      highScores[game.key] = prefs.getInt('$_scorePrefix${_child.id}_${game.key}') ?? 0;
    }

    _inventory = _decodeInventory(prefs.getString('$_inventoryPrefix${_child.id}') ?? '{}');

    setState(() {
      _hasWorksheetAccess = kDebugMode || _child.currentLevel > 1 || _child.lastWorksheetDate != null;
      _unlockedLevels = unlockedLevels;
      _highScores = highScores;
      _isLoading = false;
    });
  }

  static const int _initialUnlockedLevel = 1;

  Map<String, int> _decodeInventory(String raw) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final key in _sharedItemKeys)
          key: decoded[key] as int? ?? 0,
      };
    } catch (_) {
      return {
        for (final key in _sharedItemKeys) key: 0,
      };
    }
  }

  int _maxUnlockedForGame() {
    if (kDebugMode) return 10; // dev: all game levels accessible
    final unlocked = _child.currentLevel + 1;
    return unlocked.clamp(1, 10);
  }

  Future<void> _startGame(_GameDefinition game) async {
    if (!_hasWorksheetAccess) {
      _showMessage('Complete at least one worksheet to unlock games.');
      return;
    }

    final maxUnlocked = _maxUnlockedForGame();
    final selectedLevel = _unlockedLevels[game.key] ?? 1;
    final levelToPlay = selectedLevel.clamp(1, maxUnlocked);

    final tokenCost = game.tokenCost;

    // Check if child has enough tokens
    if (_child.gameTokens < tokenCost) {
      _showMessage('Not enough game tokens!');
      return;
    }

    // Deduct tokens locally
    final updatedChild = _child.copyWith(gameTokens: _child.gameTokens - tokenCost);

    setState(() {
      _child = updatedChild;
    });

    // Launch game
    await context.push(
      GameRoutes.play,
      extra: {
        'child': updatedChild,
        'gameKey': game.key,
        'level': levelToPlay,
      },
    );

    if (!mounted) return;
    await _loadState();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          l10n.games,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CyberGridBackground()),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildInventorySection(),
                  const SizedBox(height: 20),
                  _buildRulesSection(),
                  const SizedBox(height: 20),
                  ..._gameCatalog.map((game) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGameCard(game),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    final maxUnlocked = _maxUnlockedForGame();
    return GlowCard(
      glowColor: AppColors.primary,
      glowIntensity: 0.18,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 16),
              ],
            ),
            child: const Icon(Icons.sports_esports_rounded, color: AppColors.textOnPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _child.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hasWorksheetAccess
                      ? 'Ready to play. Unlock up to Level $maxUnlocked.'
                      : 'Complete one worksheet to unlock mini-games.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TokenChip(value: _child.gameTokens),
        ],
      ),
    );
  }

  Widget _buildInventorySection() {
    final visibleItems = _sharedItemKeys.where((key) => (_inventory[key] ?? 0) > 0).toList();
    return GlowCard(
      glowColor: AppColors.accent,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared Item Inventory',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (visibleItems.isEmpty)
            Text(
              'No items yet. Finish game levels to collect shields, hints and more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: visibleItems
                  .map(
                    (key) => _InventoryPill(
                      label: _itemLabel(key),
                      count: _inventory[key] ?? 0,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return GlowCard(
      glowColor: AppColors.secondary,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Rules',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          _RuleLine(text: 'Games unlock after at least one worksheet.'),
          _RuleLine(text: 'Each game has 10 levels with increasing difficulty.'),
          _RuleLine(text: 'Items are shared between all games.'),
          _RuleLine(text: 'High scores and unlocked levels are saved locally.'),
        ],
      ),
    );
  }

  Widget _buildGameCard(_GameDefinition game) {
    final unlocked = _unlockedLevels[game.key] ?? 1;
    final maxUnlocked = _maxUnlockedForGame();
    final highScore = _highScores[game.key] ?? 0;
    final available = _hasWorksheetAccess;

    return GlowCard(
      glowColor: game.accent,
      glowIntensity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [game.accent.withOpacity(0.9), game.accent.withOpacity(0.35)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(game.icon, color: AppColors.textOnPrimary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (!available)
                const Icon(Icons.lock_rounded, color: AppColors.warning)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: game.accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: game.accent.withOpacity(0.35)),
                  ),
                  child: Text(
                    'Lv $unlocked/$maxUnlocked',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            game.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(10, (index) {
              final level = index + 1;
              final isUnlocked = available && level <= maxUnlocked;
              final isCurrent = level == unlocked;
              return Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? game.accent.withOpacity(isCurrent ? 0.95 : 0.2) : AppColors.surfaceDark,
                  border: Border.all(
                    color: isUnlocked ? game.accent : AppColors.border,
                  ),
                  boxShadow: isCurrent
                      ? [BoxShadow(color: game.accent.withOpacity(0.6), blurRadius: 10)]
                      : null,
                ),
                child: Text(
                  '$level',
                  style: TextStyle(
                    color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'High score: $highScore',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              CyberButton(
                text: available ? 'Play' : 'Locked',
                onPressed: available ? () => _startGame(game) : null,
                color: game.accent,
                height: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _itemLabel(String key) {
    switch (key) {
      case 'building_blocks':
        return 'Building Blocks';
      case 'speed_boost':
        return 'Speed Boost';
      case 'shield':
        return 'Shield';
      case 'double_points':
        return 'Double Points';
      case 'pet_food':
        return 'Pet Food';
      case 'hint':
        return 'Hint';
      case 'time_boost':
        return 'Time Boost';
      case 'new_pet_egg':
        return 'New Pet Egg';
      case 'fuel_cells':
        return 'Fuel Cells';
      case 'spaceship_skin':
        return 'Spaceship Skin';
      default:
        return key;
    }
  }
}

class GamePlayScreen extends StatefulWidget {
  final ChildModel child;
  final String gameKey;
  final int initialLevel;

  const GamePlayScreen({
    super.key,
    required this.child,
    required this.gameKey,
    this.initialLevel = 1,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late final _GameDefinition _game;
  late int _currentLevel;
  late List<_GameQuestion> _questions;
  late int _questionIndex;
  late int _correctCount;
  late int _score;
  late int _shieldCount;
  late int _hintCount;
  late int _doublePointsCount;
  bool _doublePointsActive = false;
  bool _levelFinished = false;
  bool _hintVisible = false;
  String? _feedback;
  String? _earnedItemLabel;

  @override
  void initState() {
    super.initState();
    _game = _gameCatalog.firstWhere((game) => game.key == widget.gameKey);
    _currentLevel = widget.initialLevel.clamp(1, 10);
    _questionIndex = 0;
    _correctCount = 0;
    _score = 0;
    _shieldCount = 0;
    _hintCount = 0;
    _doublePointsCount = 0;
    _loadInventory();
    _generateQuestions();
  }

  Future<void> _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final inventory = _decodeInventory(prefs.getString('$_inventoryPrefix${widget.child.id}') ?? '{}');
    if (!mounted) return;
    setState(() {
      _shieldCount = inventory['shield'] ?? 0;
      _hintCount = inventory['hint'] ?? 0;
      _doublePointsCount = inventory['double_points'] ?? 0;
    });
  }

  Map<String, int> _decodeInventory(String raw) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final key in _sharedItemKeys) key: decoded[key] as int? ?? 0,
      };
    } catch (_) {
      return {for (final key in _sharedItemKeys) key: 0};
    }
  }

  void _generateQuestions() {
    final random = Random(_currentLevel * 31 + _game.key.hashCode);
    _questions = List.generate(5, (index) {
      return _buildQuestion(random, index);
    });
    _questionIndex = 0;
    _correctCount = 0;
    _score = 0;
    _levelFinished = false;
    _hintVisible = false;
    _feedback = null;
    _earnedItemLabel = null;
    _doublePointsActive = false;
  }

  _GameQuestion _buildQuestion(Random random, int index) {
    final difficulty = _currentLevel;
    final base = difficulty <= 2
        ? 10
        : difficulty <= 4
            ? 20
            : difficulty <= 6
                ? 50
                : difficulty <= 8
                    ? 100
                    : 200;
    final op = difficulty <= 2
        ? random.nextBool()
            ? '+'
            : '-'
        : difficulty <= 4
            ? random.nextBool()
                ? '+'
                : '-'
            : difficulty <= 6
                ? random.nextBool()
                    ? '×'
                    : '+'
                : difficulty <= 8
                    ? random.nextBool()
                        ? '×'
                        : '÷'
                    : random.nextBool()
                        ? '×'
                        : '-';

    int left = random.nextInt(base) + 1;
    int right = random.nextInt(difficulty <= 4 ? 10 : 12) + 1;
    int answer;

    switch (op) {
      case '+':
        answer = left + right;
        break;
      case '-':
        if (left < right) {
          final temp = left;
          left = right;
          right = temp;
        }
        answer = left - right;
        break;
      case '×':
        left = random.nextInt(difficulty <= 6 ? 10 : 12) + 1;
        right = random.nextInt(difficulty <= 6 ? 5 : 8) + 2;
        answer = left * right;
        break;
      case '÷':
        right = random.nextInt(8) + 2;
        answer = random.nextInt(9) + 2;
        left = answer * right;
        break;
      default:
        answer = left + right;
    }

    final choices = <int>{answer};
    while (choices.length < 4) {
      final offset = random.nextInt(10) + 1;
      final variant = random.nextBool() ? answer + offset : answer - offset;
      if (variant > 0) choices.add(variant);
    }

    final shuffled = choices.toList()..shuffle(random);
    final prompt = switch (_game.key) {
      'math_builder' => 'Build this structure: $left $op $right',
      'number_pet_adventure' => 'Feed your pet: $left $op $right',
      'space_math_explorer' => 'Launch course: $left $op $right',
      _ => '$left $op $right',
    };

    return _GameQuestion(prompt: prompt, answer: answer, choices: shuffled);
  }

  Future<void> _selectAnswer(int choice) async {
    if (_levelFinished) return;

    final question = _questions[_questionIndex];
    final isCorrect = choice == question.answer;
    final usedShield = !isCorrect && _shieldCount > 0;

    if (isCorrect || usedShield) {
      if (usedShield) {
        await _consumeItem('shield');
        _showSnack('Shield protected the mistake.');
      }
      setState(() {
        _correctCount++;
        _score += _doublePointsActive ? 2 : 1;
        _feedback = isCorrect ? 'Correct!' : 'Shield saved the round!';
      });
    } else {
      setState(() {
        _feedback = 'Try again.';
      });
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    if (_questionIndex == _questions.length - 1) {
      await _finishLevel();
    } else {
      setState(() {
        _questionIndex++;
        _feedback = null;
        _hintVisible = false;
      });
    }
  }

  Future<void> _useHint() async {
    if (_hintCount <= 0 || _levelFinished) return;
    await _consumeItem('hint');
    setState(() {
      _hintVisible = true;
      _feedback = 'Hint revealed.';
    });
  }

  Future<void> _useDoublePoints() async {
    if (_doublePointsCount <= 0 || _levelFinished) return;
    await _consumeItem('double_points');
    setState(() {
      _doublePointsActive = true;
      _feedback = 'Double points activated.';
    });
  }

  Future<void> _consumeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final inventory = _decodeInventory(prefs.getString('$_inventoryPrefix${widget.child.id}') ?? '{}');
    inventory[key] = (inventory[key] ?? 0) - 1;
    await prefs.setString('$_inventoryPrefix${widget.child.id}', jsonEncode(inventory));
    if (!mounted) return;
    setState(() {
      _shieldCount = inventory['shield'] ?? 0;
      _hintCount = inventory['hint'] ?? 0;
      _doublePointsCount = inventory['double_points'] ?? 0;
    });
  }

  Future<void> _finishLevel() async {
    setState(() {
      _levelFinished = true;
    });

    final earned = _earnedItemForLevel(_currentLevel);
    _earnedItemLabel = earned.label;
    await _awardItem(earned.key);
    await _saveProgress();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Level $_currentLevel complete', style: const TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Correct answers: $_correctCount / ${_questions.length}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Earned: ${earned.label}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Back to Games', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentLevel = (_currentLevel + 1).clamp(1, 10);
              });
              _generateQuestions();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(_currentLevel >= 10 ? 'Replay' : 'Next Level'),
          ),
        ],
      ),
    );
  }

  Future<void> _awardItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final inventory = _decodeInventory(prefs.getString('$_inventoryPrefix${widget.child.id}') ?? '{}');
    inventory[key] = (inventory[key] ?? 0) + 1;
    await prefs.setString('$_inventoryPrefix${widget.child.id}', jsonEncode(inventory));
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUnlocked = prefs.getInt('$_levelPrefix${widget.child.id}_${_game.key}') ?? 1;
    if (_currentLevel + 1 > currentUnlocked) {
      await prefs.setInt('$_levelPrefix${widget.child.id}_${_game.key}', (_currentLevel + 1).clamp(1, 10));
    }
    final currentHighScore = prefs.getInt('$_scorePrefix${widget.child.id}_${_game.key}') ?? 0;
    if (_score > currentHighScore) {
      await prefs.setInt('$_scorePrefix${widget.child.id}_${_game.key}', _score);
    }
  }

  _RewardItem _earnedItemForLevel(int level) {
    for (final band in _game.rewardPattern) {
      if (level >= band.start && level <= band.end) {
        return _RewardItem(band.key, band.label);
      }
    }
    return const _RewardItem('building_blocks', 'Building Blocks');
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.surfaceDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_questionIndex];
    final progress = (_questionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(_game.title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CyberGridBackground()),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlowCard(
                  glowColor: _game.accent,
                  glowIntensity: 0.18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _game.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(_game.icon, color: _game.accent, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _game.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level $_currentLevel / 10',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          _TokenChip(value: _shieldCount + _hintCount + _doublePointsCount),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceDark,
                        color: _game.accent,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlowCard(
                  glowColor: AppColors.primary,
                  glowIntensity: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion.prompt,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (_hintVisible)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Text(
                            'Hint: ${currentQuestion.answer}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.2,
                        children: currentQuestion.choices.map((choice) {
                          final isHighlighted = _hintVisible && choice == currentQuestion.answer;
                          return GestureDetector(
                            onTap: () => _selectAnswer(choice),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isHighlighted ? AppColors.success.withOpacity(0.2) : AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isHighlighted ? AppColors.success : AppColors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isHighlighted ? AppColors.success : _game.accent).withOpacity(0.12),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$choice',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CyberButton(
                                text: 'Hint ($_hintCount)',
                              onPressed: _useHint,
                              color: AppColors.accent,
                                height: 44,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CyberButton(
                                text: 'Shield ($_shieldCount)',
                              onPressed: null,
                              color: AppColors.success,
                                height: 44,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CyberButton(
                                text: '2x ($_doublePointsCount)',
                              onPressed: _useDoublePoints,
                              color: AppColors.secondary,
                                height: 44,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_feedback != null)
                        Text(
                          _feedback!,
                          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'Score: $_score',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_earnedItemLabel != null)
                  GlowCard(
                    glowColor: AppColors.secondary,
                    glowIntensity: 0.12,
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard_rounded, color: AppColors.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Reward collected: $_earnedItemLabel',
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameDefinition {
  final String key;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final int tokenCost;
  final List<_RewardBand> rewardPattern;

  const _GameDefinition({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.rewardPattern,
  });
}

class _RewardBand {
  final int start;
  final int end;
  final String key;
  final String label;

  const _RewardBand(this.start, this.end, this.key, this.label);
}

class _RewardItem {
  final String key;
  final String label;

  const _RewardItem(this.key, this.label);
}

class _GameQuestion {
  final String prompt;
  final int answer;
  final List<int> choices;

  _GameQuestion({required this.prompt, required this.answer, required this.choices});
}

class _TokenChip extends StatelessWidget {
  final int value;

  const _TokenChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.neonGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.token_rounded, color: AppColors.textOnPrimary, size: 16),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: const TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InventoryPill extends StatelessWidget {
  final String label;
  final int count;

  const _InventoryPill({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label × $count',
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  final String text;

  const _RuleLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
