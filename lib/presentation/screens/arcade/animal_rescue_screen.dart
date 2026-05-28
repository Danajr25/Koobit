import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/child_model.dart';
import '../../widgets/cyber_widgets.dart';

/// Animal Rescue — 5-level math mini-game.
///
/// Level progression:
///   L1 Counting        — match the number of animals in one cage
///   L2 Addition        — total of two cages
///   L3 Subtraction     — how many are left after some run away
///   L4 Multiplication  — equal cages, find the total
///   L5 Fractions       — half / quarter of the animals
class AnimalRescueScreen extends StatefulWidget {
  final ChildModel child;
  const AnimalRescueScreen({super.key, required this.child});

  @override
  State<AnimalRescueScreen> createState() => _AnimalRescueScreenState();
}

class _AnimalRescueScreenState extends State<AnimalRescueScreen> {
  static const int _maxLevel = 5;
  static const int _questionsPerLevel = 5;
  static const int _startingLives = 3;
  static const List<String> _animals = [
    '🐰', '🦊', '🐻', '🦁', '🐼', '🐯', '🐵', '🐨', '🐸', '🐹'
  ];

  final _rng = Random();

  int _level = 1;
  int _lives = _startingLives;
  int _score = 0;
  int _correctThisLevel = 0;
  bool _gameOver = false;
  bool _won = false;
  _RescuePuzzle? _puzzle;
  int? _picked;
  bool? _pickedCorrect;

  @override
  void initState() {
    super.initState();
    _nextPuzzle();
  }

  void _nextPuzzle() {
    setState(() {
      _picked = null;
      _pickedCorrect = null;
      _puzzle = _RescuePuzzle.generate(_level, _rng, _animals);
    });
  }

  void _pick(int choice) async {
    if (_picked != null || _gameOver) return;
    final correct = choice == _puzzle!.answer;
    setState(() {
      _picked = choice;
      _pickedCorrect = correct;
      if (correct) {
        _score += 10 * _level;
        _correctThisLevel++;
      } else {
        _lives--;
      }
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    if (_lives <= 0) {
      _endGame(won: false);
      return;
    }
    if (_correctThisLevel >= _questionsPerLevel) {
      if (_level >= _maxLevel) {
        _endGame(won: true);
        return;
      }
      setState(() {
        _level++;
        _correctThisLevel = 0;
      });
    }
    _nextPuzzle();
  }

  Future<void> _endGame({required bool won}) async {
    setState(() {
      _gameOver = true;
      _won = won;
    });
    final prefs = await SharedPreferences.getInstance();
    final hsKey = 'arcade_hs_animal_rescue_${widget.child.id}';
    if (_score > (prefs.getInt(hsKey) ?? 0)) {
      await prefs.setInt(hsKey, _score);
    }
  }

  void _restart() {
    setState(() {
      _level = 1;
      _lives = _startingLives;
      _score = 0;
      _correctThisLevel = 0;
      _gameOver = false;
      _won = false;
    });
    _nextPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Animal Rescue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CyberGridBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHud(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _gameOver ? _buildEndScreen() : _buildPuzzleView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHud() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Level $_level / $_maxLevel',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: List.generate(_startingLives, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                i < _lives
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppColors.error,
                size: 24,
              ),
            );
          }),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 4),
              Text(
                '$_score',
                style: const TextStyle(
                    color: AppColors.warning, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPuzzleView() {
    final p = _puzzle!;
    return Column(
      children: [
        // Progress dots for current level
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_questionsPerLevel, (i) {
            final done = i < _correctThisLevel;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: done ? 18 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: done ? AppColors.success : AppColors.border,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          p.prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: SingleChildScrollView(child: _buildCages(p)),
          ),
        ),
        const SizedBox(height: 14),
        _buildChoices(p),
      ],
    );
  }

  Widget _buildCages(_RescuePuzzle p) {
    return Column(
      children: [
        for (int i = 0; i < p.cages.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                p.connector,
                size: 26,
                color: AppColors.textSecondary,
              ),
            ),
          _buildCage(p.cages[i], p.runAway[i]),
        ],
      ],
    );
  }

  Widget _buildCage(List<String> animals, int crossedOut) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9B26B), width: 2),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          for (int i = 0; i < animals.length; i++)
            Stack(
              alignment: Alignment.center,
              children: [
                Text(animals[i], style: const TextStyle(fontSize: 30)),
                if (i >= animals.length - crossedOut)
                  const Icon(Icons.close_rounded,
                      color: AppColors.error, size: 26),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChoices(_RescuePuzzle p) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: p.choices.map((c) {
        final isPicked = _picked == c;
        Color bg = AppColors.surface;
        Color border = AppColors.primary;
        Color text = AppColors.primary;
        if (isPicked) {
          if (_pickedCorrect == true) {
            bg = AppColors.success;
            border = AppColors.success;
            text = Colors.white;
          } else {
            bg = AppColors.error;
            border = AppColors.error;
            text = Colors.white;
          }
        } else if (_picked != null && c == p.answer) {
          bg = AppColors.success.withValues(alpha: 0.2);
          border = AppColors.success;
          text = AppColors.success;
        }
        return GestureDetector(
          onTap: () => _pick(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 3),
            ),
            child: Text(
              p.formatChoice(c),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: text,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEndScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _won ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied,
            size: 96,
            color: _won ? AppColors.warning : AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            _won ? 'All animals rescued!' : 'Out of lives',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Score: $_score',
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.exit_to_app_rounded),
                label: const Text('Exit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single puzzle for the Animal Rescue game.
class _RescuePuzzle {
  final String prompt;
  final List<List<String>> cages; // animals shown per cage
  final List<int> runAway; // how many in each cage are "removed"
  final IconData connector; // icon between cages (+ or =)
  final int answer;
  final List<int> choices;

  _RescuePuzzle({
    required this.prompt,
    required this.cages,
    required this.runAway,
    required this.connector,
    required this.answer,
    required this.choices,
  });

  String formatChoice(int c) => c.toString();

  static _RescuePuzzle generate(
      int level, Random rng, List<String> animalPool) {
    String pickAnimal() => animalPool[rng.nextInt(animalPool.length)];
    List<String> fill(int n, String a) => List<String>.filled(n, a);

    switch (level) {
      case 1:
        {
          // Count the animals in one cage
          final n = rng.nextInt(5) + 1; // 1-5
          final a = pickAnimal();
          return _RescuePuzzle(
            prompt: 'How many animals are in the cage?',
            cages: [fill(n, a)],
            runAway: [0],
            connector: Icons.add_rounded,
            answer: n,
            choices: _makeChoices(n, rng, max: 9, count: 4),
          );
        }
      case 2:
        {
          // Two cages — total
          final n1 = rng.nextInt(5) + 1;
          final n2 = rng.nextInt(5) + 1;
          return _RescuePuzzle(
            prompt: 'How many animals all together?',
            cages: [fill(n1, pickAnimal()), fill(n2, pickAnimal())],
            runAway: [0, 0],
            connector: Icons.add_rounded,
            answer: n1 + n2,
            choices: _makeChoices(n1 + n2, rng, max: 15, count: 4),
          );
        }
      case 3:
        {
          // Subtraction — some run away
          final total = rng.nextInt(6) + 4; // 4-9
          final gone = rng.nextInt(total - 1) + 1; // 1..total-1
          final a = pickAnimal();
          return _RescuePuzzle(
            prompt: '$gone ran away. How many are left?',
            cages: [fill(total, a)],
            runAway: [gone],
            connector: Icons.add_rounded,
            answer: total - gone,
            choices: _makeChoices(total - gone, rng, max: 12, count: 4),
          );
        }
      case 4:
        {
          // Multiplication — equal cages
          final cages = rng.nextInt(3) + 2; // 2-4 cages
          final per = rng.nextInt(3) + 2; // 2-4 each
          final a = pickAnimal();
          return _RescuePuzzle(
            prompt: '$cages cages of $per animals — how many total?',
            cages: List.generate(cages, (_) => fill(per, a)),
            runAway: List<int>.filled(cages, 0),
            connector: Icons.add_rounded,
            answer: cages * per,
            choices: _makeChoices(cages * per, rng, max: 24, count: 4),
          );
        }
      case 5:
      default:
        {
          // Fraction — half or quarter of the cage
          final useQuarter = rng.nextBool();
          final base = useQuarter ? 4 : 2;
          final multiplier = rng.nextInt(3) + 1; // 1-3
          final total = base * multiplier; // 2,4,6 or 4,8,12
          final a = pickAnimal();
          final answer = total ~/ base;
          final fracText = useQuarter ? '¼' : '½';
          return _RescuePuzzle(
            prompt: '$fracText of the animals get food. How many is that?',
            cages: [fill(total, a)],
            runAway: [0],
            connector: Icons.add_rounded,
            answer: answer,
            choices: _makeChoices(answer, rng, max: total, count: 4),
          );
        }
    }
  }

  static List<int> _makeChoices(int answer, Random rng,
      {required int max, int count = 4}) {
    final set = <int>{answer};
    var safety = 0;
    while (set.length < count && safety++ < 50) {
      final offset = rng.nextInt(4) + 1;
      final v = rng.nextBool() ? answer + offset : answer - offset;
      if (v >= 0 && v <= max + 4) set.add(v);
    }
    // Fallback if not enough unique values gathered
    var next = 0;
    while (set.length < count) {
      if (next != answer) set.add(next);
      next++;
    }
    final list = set.toList()..shuffle(rng);
    return list.take(count).toList();
  }
}
