import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../widgets/cyber_widgets.dart';
import '../../../app/app_router.dart';

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
      _hasWorksheetAccess = true;
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
    return 10; // all game levels accessible
  }

  Future<void> _startGame(_GameDefinition game) async {
    if (!_hasWorksheetAccess) {
      _showMessage('Complete at least one worksheet to unlock games.');
      return;
    }

    final maxUnlocked = _maxUnlockedForGame();
    final selectedLevel = _unlockedLevels[game.key] ?? 1;
    final levelToPlay = selectedLevel.clamp(1, maxUnlocked);

    // Launch game
    await context.push(
      GameRoutes.play,
      extra: {
        'child': _child,
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
                  const SizedBox(height: 8),
                  _buildArcadeSection(),
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
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 16),
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

  Widget _buildArcadeSection() {
    return GlowCard(
      glowColor: const Color(0xFF00D4FF),
      glowIntensity: 0.18,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.arcade, extra: _child),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0088CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.videogame_asset_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arcade Games',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Flappy Math, Balloon Pop, Math Runner',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF00D4FF), size: 20),
          ],
        ),
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
                    colors: [game.accent.withValues(alpha: 0.9), game.accent.withValues(alpha: 0.35)],
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
                    color: game.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: game.accent.withValues(alpha: 0.35)),
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
                  color: isUnlocked ? game.accent.withValues(alpha: isCurrent ? 0.95 : 0.2) : AppColors.surfaceDark,
                  border: Border.all(
                    color: isUnlocked ? game.accent : AppColors.border,
                  ),
                  boxShadow: isCurrent
                      ? [BoxShadow(color: game.accent.withValues(alpha: 0.6), blurRadius: 10)]
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

  Widget _powerupBtn({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final active = count > 0 && onTap != null;
    return Expanded(
      child: GestureDetector(
        onTap: active ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? color : AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? color : AppColors.textSecondary, size: 20),
              const SizedBox(height: 2),
              Text(
                '$label ($count)',
                style: TextStyle(
                  color: active ? color : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
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
                              color: _game.accent.withValues(alpha: 0.2),
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
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: _GameScene(
                      gameKey: _game.key,
                      accent: _game.accent,
                      correctCount: _correctCount,
                      totalQuestions: _questions.length,
                      level: _currentLevel,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
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
                                color: isHighlighted ? AppColors.success.withValues(alpha: 0.2) : AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isHighlighted ? AppColors.success : AppColors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isHighlighted ? AppColors.success : _game.accent).withValues(alpha: 0.12),
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
                          _powerupBtn(
                            icon: Icons.lightbulb_outline_rounded,
                            label: 'Hint',
                            count: _hintCount,
                            color: AppColors.accent,
                            onTap: _useHint,
                          ),
                          const SizedBox(width: 8),
                          _powerupBtn(
                            icon: Icons.shield_outlined,
                            label: 'Shield',
                            count: _shieldCount,
                            color: AppColors.success,
                            onTap: null,
                          ),
                          const SizedBox(width: 8),
                          _powerupBtn(
                            icon: Icons.close_fullscreen_rounded,
                            label: '2x',
                            count: _doublePointsCount,
                            color: AppColors.secondary,
                            onTap: _useDoublePoints,
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
  final int tokenCost = 1;
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
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 10),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Animated game scene visuals (CustomPainter-based)
// ─────────────────────────────────────────────────────────────────────────────

class _GameScene extends StatefulWidget {
  final String gameKey;
  final Color accent;
  final int correctCount;
  final int totalQuestions;
  final int level;

  const _GameScene({
    required this.gameKey,
    required this.accent,
    required this.correctCount,
    required this.totalQuestions,
    required this.level,
  });

  @override
  State<_GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<_GameScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final CustomPainter painter;
        switch (widget.gameKey) {
          case 'number_pet_adventure':
            painter = _PetPainter(
              t: _ctrl.value,
              correctCount: widget.correctCount,
              accent: widget.accent,
              level: widget.level,
            );
          case 'space_math_explorer':
            painter = _SpacePainter(
              t: _ctrl.value,
              correctCount: widget.correctCount,
              total: widget.totalQuestions,
              accent: widget.accent,
            );
          default:
            painter = _CityPainter(
              t: _ctrl.value,
              correctCount: widget.correctCount,
              accent: widget.accent,
              level: widget.level,
            );
        }
        return CustomPaint(painter: painter, size: Size.infinite);
      },
    );
  }
}

// ── Math Builder – City skyline (varies per level) ──────────────────────────
class _CityPainter extends CustomPainter {
  final double t;
  final int correctCount;
  final Color accent;
  final int level;

  const _CityPainter({
    required this.t,
    required this.correctCount,
    required this.accent,
    required this.level,
  });

  // 10 hand-picked themes keyed by level (1..10).
  // [skyTop, skyBottom, groundColor, isNight (0/1), sunOrMoonX (0..1)]
  static const List<List<dynamic>> _themes = [
    // L1 – early dawn
    [Color(0xFF1B1530), Color(0xFFE96A8C), Color(0xFF2A1A2E), 0, 0.15],
    // L2 – sunrise
    [Color(0xFF2A1A40), Color(0xFFFFB066), Color(0xFF3A2535), 0, 0.20],
    // L3 – morning
    [Color(0xFF87B8E8), Color(0xFFFFE6B0), Color(0xFF335060), 0, 0.30],
    // L4 – clear day
    [Color(0xFF4FA8F0), Color(0xFFB8E0FF), Color(0xFF3A5A70), 0, 0.50],
    // L5 – cloudy day
    [Color(0xFF6F8FB0), Color(0xFFD0DCE8), Color(0xFF40556A), 0, 0.55],
    // L6 – afternoon
    [Color(0xFF3D7CC9), Color(0xFFFFC58A), Color(0xFF38485C), 0, 0.70],
    // L7 – sunset
    [Color(0xFF402060), Color(0xFFFF7050), Color(0xFF2A1530), 0, 0.82],
    // L8 – dusk
    [Color(0xFF15123A), Color(0xFFB04580), Color(0xFF1A0F2A), 0, 0.88],
    // L9 – night with moon
    [Color(0xFF070B20), Color(0xFF1A1040), Color(0xFF111128), 1, 0.85],
    // L10 – deep night, snow
    [Color(0xFF02030F), Color(0xFF0E0B30), Color(0xFF181B30), 1, 0.20],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final lvl = level.clamp(1, 10);
    final theme = _themes[lvl - 1];
    final Color skyTop = theme[0] as Color;
    final Color skyBottom = theme[1] as Color;
    final Color ground = theme[2] as Color;
    final bool isNight = (theme[3] as int) == 1;
    final double bodyX = theme[4] as double;

    // Building layout: deterministic per level, 5-9 buildings.
    final rng = Random(lvl * 73 + 1);
    final buildingCount = 5 + rng.nextInt(5);
    final buildings = <List<double>>[];
    double cursor = 0.01;
    for (int i = 0; i < buildingCount; i++) {
      final bw = 0.07 + rng.nextDouble() * 0.08;
      final bh = 0.30 + rng.nextDouble() * 0.45;
      buildings.add([cursor, bw, bh]);
      cursor += bw + 0.005 + rng.nextDouble() * 0.025;
      if (cursor > 0.95) break;
    }

    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBottom],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Stars (only at night/dusk)
    if (isNight || lvl == 1 || lvl == 8) {
      const starCoords = [
        [0.08, 0.08], [0.22, 0.12], [0.40, 0.06], [0.55, 0.14],
        [0.68, 0.07], [0.80, 0.10], [0.92, 0.05], [0.15, 0.22],
        [0.35, 0.18], [0.60, 0.20], [0.78, 0.17], [0.95, 0.22],
      ];
      for (int i = 0; i < starCoords.length; i++) {
        final alpha =
            (0.4 + 0.6 * ((sin(t * 2 * pi + i * 0.9) + 1) / 2))
                .clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(w * starCoords[i][0], h * starCoords[i][1]),
          i % 4 == 0 ? 2.0 : 1.2,
          Paint()..color = Colors.white.withValues(alpha: alpha),
        );
      }
    }

    // Sun or Moon
    final bodyCenter = Offset(w * bodyX, h * 0.16);
    if (isNight) {
      canvas.drawCircle(
          bodyCenter, 16, Paint()..color = const Color(0xFFECE9C8));
      canvas.drawCircle(
          bodyCenter.translate(4, -2), 13, Paint()..color = skyTop);
    } else {
      // Sun with soft glow
      canvas.drawCircle(
        bodyCenter,
        24,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
          bodyCenter, 14, Paint()..color = const Color(0xFFFFE082));
    }

    // Clouds (days 4 and 5)
    if (lvl == 4 || lvl == 5 || lvl == 6) {
      final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
      void cloud(double cx, double cy, double cs) {
        canvas.drawCircle(Offset(w * cx, h * cy), cs, cloudPaint);
        canvas.drawCircle(
            Offset(w * cx + cs * 0.9, h * cy + 1), cs * 0.9, cloudPaint);
        canvas.drawCircle(
            Offset(w * cx - cs * 0.85, h * cy + 1), cs * 0.85, cloudPaint);
      }

      final drift = (t * 0.2) % 1.0;
      cloud(0.1 + drift * 0.3, 0.18, 9);
      cloud(0.55 + drift * 0.2, 0.10, 7);
    }

    // Snow (L10)
    if (lvl == 10) {
      final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (int i = 0; i < 18; i++) {
        final fx = ((i * 137 + t * 80) % w);
        final fy = ((i * 53 + t * 140) % (h * 0.8));
        canvas.drawCircle(Offset(fx, fy), i % 3 == 0 ? 1.8 : 1.2, snowPaint);
      }
    }

    // Ground
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.76, w, h * 0.24), Paint()..color = ground);

    // Buildings
    final baseBuildingColor =
        isNight ? const Color(0xFF161630) : const Color(0xFF1F2A3C);
    for (int i = 0; i < buildings.length; i++) {
      final def = buildings[i];
      final bx = w * def[0];
      final bw = w * def[1];
      final bh = h * def[2];
      final by = h * 0.76 - bh;
      final isLit = i < correctCount;

      canvas.drawRect(
        Rect.fromLTWH(bx, by, bw, bh),
        Paint()
          ..color = isLit
              ? Color.lerp(baseBuildingColor, accent, 0.30)!
              : baseBuildingColor,
      );
      if (isLit) {
        canvas.drawRect(
          Rect.fromLTWH(bx, by, bw, bh),
          Paint()
            ..color = accent.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Windows
      const ws = 3.5;
      const wp = 4.0;
      final cols = max(1, (bw / (ws + wp)).floor());
      final rows = (bh / (ws + wp)).floor().clamp(1, 10);
      for (int r = 1; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final wx =
              bx + (bw - cols * (ws + wp) + wp) / 2 + c * (ws + wp);
          final wy = by + wp + r * (ws + wp);
          final lit = isLit && (r + c + i) % 3 != 0;
          final winAlpha = lit
              ? (0.5 +
                      0.5 *
                          ((sin(t * 2 * pi + i * 0.6 + r * 0.3) + 1) / 2))
                  .clamp(0.0, 1.0)
              : 0.0;
          canvas.drawRect(
            Rect.fromLTWH(wx, wy, ws, ws),
            Paint()
              ..color = lit
                  ? accent.withValues(alpha: winAlpha)
                  : (isNight
                      ? const Color(0xFF0D0E20)
                      : const Color(0xFF18233A)),
          );
        }
      }
    }

    // Level label badge (top-right)
    final lblTp = TextPainter(
      text: TextSpan(
        text: 'L$lvl',
        style: TextStyle(
            color: accent.withValues(alpha: 0.9),
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    lblTp.paint(canvas, Offset(w - lblTp.width - 8, 6));

    // Score label
    final tp = TextPainter(
      text: TextSpan(
        text: '$correctCount correct',
        style: TextStyle(
            color: accent, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, h - 18));
  }

  @override
  bool shouldRepaint(_CityPainter old) =>
      old.t != t || old.correctCount != correctCount || old.level != level;
}

// ── Number Pet Adventure – Pet character ────────────────────────────────────
class _PetPainter extends CustomPainter {
  final double t;
  final int correctCount;
  final Color accent;
  final int level;

  const _PetPainter({
    required this.t,
    required this.correctCount,
    required this.accent,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1A2A), Color(0xFF0A1F0A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Ground
    canvas.drawRect(Rect.fromLTWH(0, h * 0.76, w, h * 0.24),
        Paint()..color = const Color(0xFF0F2F0F));

    // Grass tufts
    for (double gx = 5; gx < w; gx += 28) {
      canvas.drawRect(Rect.fromLTWH(gx, h * 0.74, 5, 7),
          Paint()..color = const Color(0xFF1E5C1E));
      canvas.drawRect(Rect.fromLTWH(gx + 9, h * 0.75, 3, 5),
          Paint()..color = const Color(0xFF1E5C1E));
    }

    // Fireflies
    for (int i = 0; i < 6; i++) {
      final fx = w * (0.05 + i * 0.18);
      final fy = h * (0.15 + 0.1 * sin(t * 2 * pi + i * 1.1));
      final fa =
          (0.3 + 0.7 * ((sin(t * 3 * pi + i * 1.7) + 1) / 2)).clamp(0.0, 1.0);
      canvas.drawCircle(
          Offset(fx, fy), 2.5, Paint()..color = Colors.yellow.withValues(alpha: fa));
    }

    // Pet – walks left/right across the scene, bounces, occasionally blinks
    final petR = 44.0 * (0.65 + correctCount * 0.07).clamp(0.65, 1.0);
    // Horizontal walk: smooth back-and-forth between left and right margins
    final walkPhase = sin(t * 2 * pi); // -1..1
    final walkX = w * 0.5 + walkPhase * (w * 0.32);
    // Direction (+1 right, -1 left) — used to flip features
    final facing = cos(t * 2 * pi) >= 0 ? 1.0 : -1.0;
    // Walk-cycle bounce (twice per cycle, like footsteps)
    final stepBob = (sin(t * 4 * pi)).abs() * 6.0;
    // Slight forward lean in the direction of motion
    final tilt = 0.10 * cos(t * 2 * pi);
    final pc = Offset(walkX, h * 0.50 - stepBob);

    // Shadow follows feet
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(pc.dx, h * 0.75),
          width: petR * 1.3,
          height: petR * 0.25),
      Paint()..color = Colors.black38,
    );

    // Apply tilt + facing transform around the pet center
    canvas.save();
    canvas.translate(pc.dx, pc.dy);
    canvas.rotate(tilt);
    canvas.scale(facing, 1.0);
    canvas.translate(-pc.dx, -pc.dy);

    // Ears (behind body)
    for (final side in [-1.0, 1.0]) {
      // Ear wiggle
      final earWiggle = 0.05 * sin(t * 4 * pi + side);
      canvas.drawPath(
        Path()
          ..moveTo(pc.dx + side * petR * 0.55,
              pc.dy - petR * (0.45 + earWiggle))
          ..lineTo(pc.dx + side * petR * 0.28,
              pc.dy - petR * (0.95 + earWiggle))
          ..lineTo(pc.dx + side * petR * 0.08, pc.dy - petR * 0.58)
          ..close(),
        Paint()..color = accent,
      );
      canvas.drawPath(
        Path()
          ..moveTo(pc.dx + side * petR * 0.48, pc.dy - petR * 0.50)
          ..lineTo(pc.dx + side * petR * 0.28, pc.dy - petR * 0.82)
          ..lineTo(pc.dx + side * petR * 0.12, pc.dy - petR * 0.60)
          ..close(),
        Paint()..color = const Color(0xFFF48FB1),
      );
    }

    // Body
    canvas.drawCircle(pc, petR, Paint()..color = accent);
    canvas.drawCircle(
        pc - Offset(petR * 0.22, petR * 0.22),
        petR * 0.38,
        Paint()..color = Colors.white.withValues(alpha: 0.12));

    // Feet (alternating step lift)
    final leftLift = max(0.0, sin(t * 4 * pi)) * 4.0;
    final rightLift = max(0.0, -sin(t * 4 * pi)) * 4.0;
    final footPaint = Paint()..color = Color.lerp(accent, Colors.black, 0.35)!;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(pc.dx - petR * 0.35, pc.dy + petR * 0.95 - leftLift),
          width: petR * 0.5,
          height: petR * 0.22),
      footPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(pc.dx + petR * 0.35, pc.dy + petR * 0.95 - rightLift),
          width: petR * 0.5,
          height: petR * 0.22),
      footPaint,
    );

    // Eyes – blink every ~4 seconds
    final blinkPhase = (t * 2.0) % 1.0; // 0..1 every 2s of anim cycle
    final isBlinking = blinkPhase < 0.06;
    final eyeY = pc.dy - petR * 0.12;
    for (final ex in [-petR * 0.28, petR * 0.28]) {
      // Eye whites
      canvas.drawCircle(
          Offset(pc.dx + ex, eyeY), petR * 0.22, Paint()..color = Colors.white);
      if (isBlinking) {
        // Closed eyelid line
        canvas.drawLine(
          Offset(pc.dx + ex - petR * 0.22, eyeY),
          Offset(pc.dx + ex + petR * 0.22, eyeY),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      } else {
        // Pupils track walk direction slightly
        final pupilShift = facing * 1.5;
        canvas.drawCircle(
            Offset(pc.dx + ex + pupilShift, eyeY + 1.5),
            petR * 0.12,
            Paint()..color = Colors.black);
        canvas.drawCircle(
            Offset(pc.dx + ex - 2.5 + pupilShift, eyeY - 2.5),
            petR * 0.04,
            Paint()..color = Colors.white);
      }
    }

    // Mouth
    final my = pc.dy + petR * 0.28;
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (correctCount > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(pc.dx - petR * 0.2, my)
          ..quadraticBezierTo(
              pc.dx, my + petR * 0.14, pc.dx + petR * 0.2, my),
        mouthPaint,
      );
    } else {
      canvas.drawLine(Offset(pc.dx - petR * 0.15, my),
          Offset(pc.dx + petR * 0.15, my), mouthPaint);
    }

    canvas.restore();

    // Hearts when doing well
    if (correctCount >= 2) {
      for (int i = 0; i < 3; i++) {
        final hx = pc.dx + (i - 1) * petR * 0.9;
        final hy = pc.dy - petR * 1.3 - 8 * sin(t * 2 * pi + i * 1.4);
        final ha = (0.5 + 0.5 * sin(t * 2 * pi + i)).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(hx, hy), 4,
            Paint()..color = Colors.pinkAccent.withValues(alpha: ha));
        canvas.drawCircle(Offset(hx + 5, hy), 4,
            Paint()..color = Colors.pinkAccent.withValues(alpha: ha));
      }
    }

    // Level badge
    final tp = TextPainter(
      text: TextSpan(
        text: 'Lv.$level',
        style:
            TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w - tp.width - 8, h - 18));
  }

  @override
  bool shouldRepaint(_PetPainter old) =>
      old.t != t || old.correctCount != correctCount;
}

// ── Space Math Explorer – Space scene ────────────────────────────────────────
class _SpacePainter extends CustomPainter {
  final double t;
  final int correctCount;
  final int total;
  final Color accent;

  const _SpacePainter({
    required this.t,
    required this.correctCount,
    required this.total,
    required this.accent,
  });

  static const List<List<double>> _stars = [
    [0.05, 0.10], [0.12, 0.28], [0.18, 0.08], [0.25, 0.42],
    [0.30, 0.15], [0.38, 0.60], [0.45, 0.08], [0.52, 0.35],
    [0.58, 0.18], [0.65, 0.72], [0.70, 0.05], [0.76, 0.48],
    [0.82, 0.22], [0.88, 0.65], [0.94, 0.12], [0.10, 0.55],
    [0.22, 0.72], [0.33, 0.30], [0.48, 0.80], [0.60, 0.50],
    [0.72, 0.35], [0.85, 0.40], [0.92, 0.78], [0.04, 0.85],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Space background
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF04060F));

    // Stars
    for (int i = 0; i < _stars.length; i++) {
      final alpha =
          (0.3 + 0.7 * ((sin(t * 2 * pi + i * 0.8) + 1) / 2)).clamp(0.0, 1.0);
      final r = i % 5 == 0 ? 2.5 : (i % 3 == 0 ? 1.8 : 1.0);
      canvas.drawCircle(
        Offset(w * _stars[i][0], h * _stars[i][1]),
        r,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }

    // Nebula glow
    canvas.drawCircle(Offset(w * 0.3, h * 0.4), 60,
        Paint()..color = accent.withValues(alpha: 0.04));
    canvas.drawCircle(Offset(w * 0.7, h * 0.6), 50,
        Paint()..color = Colors.purple.withValues(alpha: 0.05));

    // Planet (top right)
    final pc = Offset(w * 0.80, h * 0.22);
    canvas.drawCircle(
      pc,
      28,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [Color(0xFFE8C46A), Color(0xFF8B6010)],
        ).createShader(Rect.fromCircle(center: pc, radius: 28)),
    );
    canvas.save();
    canvas.translate(pc.dx, pc.dy);
    canvas.scale(1.0, 0.22);
    canvas.drawCircle(
        Offset.zero,
        40,
        Paint()
          ..color = const Color(0xFFD4A850).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7);
    canvas.restore();
    canvas.drawCircle(pc - const Offset(8, 8), 10,
        Paint()..color = Colors.white.withValues(alpha: 0.10));

    // Rocket
    final progress = correctCount / max(1, total);
    final rx = w * 0.08 + (w * 0.60) * progress;
    final ry = h * 0.52 + 4 * sin(t * 2 * pi);

    // Engine trail
    for (int i = 1; i <= 8; i++) {
      canvas.drawCircle(
        Offset(rx - 18 - i * 7.0, ry + 8),
        max(1.0, 7.0 - i),
        Paint()..color = accent.withValues(alpha: max(0.0, 0.65 - i * 0.07)),
      );
    }

    // Fins
    canvas.drawPath(
      Path()
        ..moveTo(rx - 12, ry + 4)
        ..lineTo(rx - 22, ry + 15)
        ..lineTo(rx - 12, ry + 10)
        ..close(),
      Paint()..color = accent,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rx - 12, ry - 4)
        ..lineTo(rx - 22, ry - 15)
        ..lineTo(rx - 12, ry - 10)
        ..close(),
      Paint()..color = accent,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(rx - 12, ry - 10, 20, 20), const Radius.circular(4)),
      Paint()..color = const Color(0xFFB0B0C0),
    );

    // Nose cone
    for (final dy in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(rx + 8, ry)
          ..lineTo(rx + 22, ry)
          ..lineTo(rx + 8, ry + dy * 10)
          ..close(),
        Paint()..color = const Color(0xFFE0E0F0),
      );
    }

    // Window
    canvas.drawCircle(Offset(rx - 2, ry), 5,
        Paint()..color = const Color(0xFF1DE9B6));
    canvas.drawCircle(
        Offset(rx - 2, ry),
        5,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Exhaust flame
    canvas.drawPath(
      Path()
        ..moveTo(rx - 12, ry - 6)
        ..quadraticBezierTo(
            rx - 30 - 5 * sin(t * 8 * pi), ry, rx - 12, ry + 6),
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 + 2 * sin(t * 6 * pi).abs()
        ..strokeCap = StrokeCap.round,
    );

    // ===== Shooting action =====
    // Asteroid target drifts in from the right
    final astCycle = (t * 0.6) % 1.0; // one asteroid per ~1.67s of anim
    final astStartX = w + 20;
    final astEndX = rx + 40;
    final astX = astStartX + (astEndX - astStartX) * astCycle;
    final astY = ry + sin(astCycle * pi * 2 + 1.0) * 10;
    final astR = 8.0;
    // Laser fires when asteroid is in front of the rocket (mid cycle)
    final laserActive = astCycle > 0.35 && astCycle < 0.75;
    // Asteroid explodes near the end of cycle
    final exploding = astCycle > 0.72 && astCycle < 0.88;
    final gone = astCycle >= 0.88;

    if (!gone && !exploding) {
      // Asteroid body
      canvas.drawCircle(
        Offset(astX, astY),
        astR,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: const [Color(0xFFB07050), Color(0xFF402010)],
          ).createShader(Rect.fromCircle(
              center: Offset(astX, astY), radius: astR)),
      );
      // Crater specks
      canvas.drawCircle(Offset(astX - 2, astY - 1), 1.5,
          Paint()..color = Colors.black.withValues(alpha: 0.4));
      canvas.drawCircle(Offset(astX + 2.5, astY + 2), 1.0,
          Paint()..color = Colors.black.withValues(alpha: 0.4));
    }

    if (laserActive && !exploding && !gone) {
      // Bright laser beam from nose cone to asteroid
      final laserStart = Offset(rx + 22, ry);
      final laserEnd = Offset(astX, astY);
      // Outer glow
      canvas.drawLine(
        laserStart,
        laserEnd,
        Paint()
          ..color = accent.withValues(alpha: 0.35)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
      // Core beam
      canvas.drawLine(
        laserStart,
        laserEnd,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      // Muzzle flash at nose
      canvas.drawCircle(
        laserStart,
        3 + 2 * sin(t * 30).abs(),
        Paint()..color = accent.withValues(alpha: 0.9),
      );
    }

    if (exploding) {
      // Explosion at asteroid position
      final explodeT = ((astCycle - 0.72) / 0.16).clamp(0.0, 1.0);
      final boomR = 6 + 18 * explodeT;
      canvas.drawCircle(
        Offset(astX, astY),
        boomR,
        Paint()
          ..color = const Color(0xFFFFB347)
              .withValues(alpha: (1.0 - explodeT) * 0.9),
      );
      canvas.drawCircle(
        Offset(astX, astY),
        boomR * 0.55,
        Paint()
          ..color = const Color(0xFFFFF59D)
              .withValues(alpha: 1.0 - explodeT),
      );
      // Debris specks flying out
      for (int i = 0; i < 6; i++) {
        final ang = i * (pi / 3);
        final d = boomR * 0.9;
        canvas.drawCircle(
          Offset(astX + cos(ang) * d, astY + sin(ang) * d),
          1.8,
          Paint()
            ..color = const Color(0xFFFFCC80)
                .withValues(alpha: 1.0 - explodeT),
        );
      }
    }

    // Mission label
    final tp = TextPainter(
      text: TextSpan(
        text: 'Mission: $correctCount / $total',
        style: const TextStyle(
            color: Color(0xFF7BFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, h - 18));
  }

  @override
  bool shouldRepaint(_SpacePainter old) =>
      old.t != t || old.correctCount != correctCount;
}
