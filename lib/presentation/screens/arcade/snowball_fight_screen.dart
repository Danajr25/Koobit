import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/child_model.dart';

/// Snowball Fight — knock out the number(s) that don't belong.
///
/// Level design (5 levels, 4 waves each):
///   L1 Sequence break  — find the number that breaks 1,2,3...
///   L2 Wrong sum       — sign shows "5+3=8", knock out the snowman whose
///                        number isn't the right sum.
///   L3 Wrong fraction  — sign shows "1/2", knock out the one ≠ 1/2.
///   L4 Wrong product   — sign shows "3×2=6", faster wave timer.
///   L5 Two intruders   — two wrong answers hidden per wave, tight timer.
class SnowballFightScreen extends StatefulWidget {
  final ChildModel child;
  const SnowballFightScreen({super.key, required this.child});

  @override
  State<SnowballFightScreen> createState() => _SnowballFightScreenState();
}

class _SnowballFightScreenState extends State<SnowballFightScreen> {
  static const int _maxLevel = 5;
  static const int _wavesPerLevel = 4;
  static const int _startingLives = 3;

  final _rng = Random();

  int _level = 1;
  int _wavesCleared = 0;
  int _lives = _startingLives;
  int _score = 0;
  bool _gameOver = false;
  bool _won = false;

  _Wave? _wave;
  Timer? _waveTimer;
  int _secondsLeft = 0;
  final Set<int> _knockedOut = {};

  // Brief shake feedback
  int? _flashIndex;
  bool _flashCorrect = false;

  @override
  void initState() {
    super.initState();
    _startWave();
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }

  int get _waveSeconds {
    // tighter on higher levels
    switch (_level) {
      case 1:
        return 15;
      case 2:
        return 13;
      case 3:
        return 12;
      case 4:
        return 10;
      case 5:
      default:
        return 9;
    }
  }

  void _startWave() {
    _waveTimer?.cancel();
    _knockedOut.clear();
    _wave = _Wave.generate(_level, _rng);
    _secondsLeft = _waveSeconds;
    _waveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _gameOver) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _waveTimer?.cancel();
        // Timed out — lose a life
        setState(() => _lives--);
        if (_lives <= 0) {
          _endGame(won: false);
        } else {
          _startWave();
        }
      }
    });
    setState(() {});
  }

  void _knock(int index) async {
    if (_gameOver || _wave == null) return;
    if (_knockedOut.contains(index)) return;
    final w = _wave!;
    final isIntruder = w.intruderIndices.contains(index);

    setState(() {
      _flashIndex = index;
      _flashCorrect = isIntruder;
      if (isIntruder) {
        _knockedOut.add(index);
        _score += 10 * _level;
      } else {
        _lives--;
      }
    });
    await Future.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;
    setState(() {
      _flashIndex = null;
    });

    if (_lives <= 0) {
      _endGame(won: false);
      return;
    }
    if (_knockedOut.length >= w.intruderIndices.length) {
      _waveTimer?.cancel();
      setState(() {
        _wavesCleared++;
        _score += 5 * _level; // wave bonus
      });
      if (_wavesCleared >= _wavesPerLevel) {
        if (_level >= _maxLevel) {
          _endGame(won: true);
          return;
        }
        setState(() {
          _level++;
          _wavesCleared = 0;
        });
      }
      _startWave();
    }
  }

  Future<void> _endGame({required bool won}) async {
    _waveTimer?.cancel();
    setState(() {
      _gameOver = true;
      _won = won;
    });
    final prefs = await SharedPreferences.getInstance();
    final hsKey = 'arcade_hs_snowball_${widget.child.id}';
    if (_score > (prefs.getInt(hsKey) ?? 0)) {
      await prefs.setInt(hsKey, _score);
    }
  }

  void _restart() {
    setState(() {
      _level = 1;
      _wavesCleared = 0;
      _lives = _startingLives;
      _score = 0;
      _gameOver = false;
      _won = false;
    });
    _startWave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Snowball Fight',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _SnowBackdrop()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHud(),
                  const SizedBox(height: 12),
                  if (_wave != null) _buildSignBoard(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: _gameOver
                        ? _buildEndScreen()
                        : (_wave == null
                            ? const SizedBox()
                            : _buildSnowmen(_wave!)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHud() {
    return Row(
      children: [
        _hudChip(
            'Lv $_level/$_maxLevel', Icons.flag_rounded, AppColors.primary),
        const SizedBox(width: 8),
        _hudChip('Wave ${_wavesCleared + 1}/$_wavesPerLevel',
            Icons.waves_rounded, AppColors.primary),
        const SizedBox(width: 8),
        _hudChip('${_secondsLeft}s', Icons.timer_rounded,
            _secondsLeft <= 3 ? AppColors.error : AppColors.warning),
        const Spacer(),
        Row(
          children: List.generate(
              _startingLives,
              (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      i < _lives
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                  )),
        ),
      ],
    );
  }

  Widget _hudChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSignBoard() {
    final w = _wave!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8D6E63), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            w.instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            w.signText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnowmen(_Wave w) {
    return GridView.builder(
      itemCount: w.values.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (ctx, i) {
        final isOut = _knockedOut.contains(i);
        final isFlash = _flashIndex == i;
        Color bg = Colors.white;
        Color border = const Color(0xFF90A4AE);
        if (isFlash) {
          bg = _flashCorrect ? AppColors.success : AppColors.error;
          border = bg;
        }
        if (isOut) {
          bg = const Color(0xFFB0BEC5);
          border = const Color(0xFF607D8B);
        }
        return GestureDetector(
          onTap: () => _knock(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 3),
              boxShadow: [
                if (!isOut)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isOut ? '💥' : '⛄',
                  style: const TextStyle(fontSize: 44),
                ),
                const SizedBox(height: 4),
                Text(
                  w.values[i],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isOut
                        ? Colors.white
                        : (isFlash ? Colors.white : AppColors.textPrimary),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEndScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _won ? Icons.emoji_events_rounded : Icons.ac_unit_rounded,
            size: 96,
            color: _won ? AppColors.warning : AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            _won ? 'Snow King!' : 'Out of lives',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text('Score: $_score',
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
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

class _Wave {
  final String instruction;
  final String signText;
  final List<String> values; // displayed labels (number / fraction)
  final Set<int> intruderIndices;
  _Wave({
    required this.instruction,
    required this.signText,
    required this.values,
    required this.intruderIndices,
  });

  static _Wave generate(int level, Random rng) {
    switch (level) {
      case 1:
        return _genSequence(rng);
      case 2:
        return _genWrongSum(rng);
      case 3:
        return _genWrongFraction(rng);
      case 4:
        return _genWrongProduct(rng);
      case 5:
      default:
        return _genTwoIntruders(rng);
    }
  }

  // ── Level 1 ────────────────────────────────────────────────────────────
  static _Wave _genSequence(Random rng) {
    final start = rng.nextInt(8) + 1;
    final values =
        List.generate(6, (i) => (start + i).toString()); // sequence
    final intruderIdx = rng.nextInt(6);
    // replace with a value that is NOT in the sequence
    int candidate;
    do {
      candidate = start + rng.nextInt(14);
    } while (candidate >= start && candidate <= start + 5);
    values[intruderIdx] = candidate.toString();
    return _Wave(
      instruction: 'Knock out the one that breaks the count!',
      signText: '$start, ${start + 1}, ${start + 2}, ...',
      values: values,
      intruderIndices: {intruderIdx},
    );
  }

  // ── Level 2 ────────────────────────────────────────────────────────────
  static _Wave _genWrongSum(Random rng) {
    final a = rng.nextInt(8) + 1;
    final b = rng.nextInt(8) + 1;
    final ans = a + b;
    final values = <String>[ans.toString()];
    while (values.length < 6) {
      values.add(ans.toString());
    }
    final intruderIdx = rng.nextInt(6);
    int wrong;
    do {
      wrong = ans + (rng.nextInt(4) + 1) * (rng.nextBool() ? 1 : -1);
    } while (wrong == ans || wrong < 0);
    values[intruderIdx] = wrong.toString();
    return _Wave(
      instruction: 'Knock out the snowman with the WRONG answer.',
      signText: '$a + $b = $ans',
      values: values,
      intruderIndices: {intruderIdx},
    );
  }

  // ── Level 3 ────────────────────────────────────────────────────────────
  static _Wave _genWrongFraction(Random rng) {
    // Pick a base fraction with simple equivalents
    final fractions = <List<int>>[
      [1, 2],
      [1, 3],
      [1, 4],
      [2, 3],
      [3, 4],
    ];
    final base = fractions[rng.nextInt(fractions.length)];
    final n = base[0];
    final d = base[1];
    // Build 6 equivalent fractions (n/d, 2n/2d, 3n/3d ...)
    final values = <String>[];
    for (int k = 1; k <= 6; k++) {
      values.add('${n * k}/${d * k}');
    }
    final intruderIdx = rng.nextInt(6);
    // Replace with a non-equivalent fraction
    int wn, wd;
    do {
      wn = rng.nextInt(5) + 1;
      wd = rng.nextInt(5) + 2;
    } while (wn * d == n * wd); // make sure not equivalent
    values[intruderIdx] = '$wn/$wd';
    values.shuffle(rng);
    // recompute intruder index after shuffle
    final intruderValue = '$wn/$wd';
    final newIntruder = values.indexOf(intruderValue);
    return _Wave(
      instruction: 'Knock out the fraction that is NOT equal to $n/$d.',
      signText: '$n/$d',
      values: values,
      intruderIndices: {newIntruder},
    );
  }

  // ── Level 4 ────────────────────────────────────────────────────────────
  static _Wave _genWrongProduct(Random rng) {
    final a = rng.nextInt(5) + 2; // 2..6
    final b = rng.nextInt(5) + 2;
    final ans = a * b;
    final values = List<String>.filled(6, ans.toString());
    final intruderIdx = rng.nextInt(6);
    int wrong;
    do {
      wrong = ans + (rng.nextInt(5) + 1) * (rng.nextBool() ? 1 : -1);
    } while (wrong == ans || wrong < 0);
    values[intruderIdx] = wrong.toString();
    return _Wave(
      instruction: 'Knock out the WRONG product. Quick!',
      signText: '$a × $b = $ans',
      values: values,
      intruderIndices: {intruderIdx},
    );
  }

  // ── Level 5 ────────────────────────────────────────────────────────────
  static _Wave _genTwoIntruders(Random rng) {
    // Mixed: addition target with TWO wrong answers
    final a = rng.nextInt(9) + 2;
    final b = rng.nextInt(9) + 2;
    final ans = a + b;
    final values = List<String>.filled(6, ans.toString());
    final indices = <int>{};
    while (indices.length < 2) {
      indices.add(rng.nextInt(6));
    }
    for (final i in indices) {
      int wrong;
      do {
        wrong = ans + (rng.nextInt(5) + 1) * (rng.nextBool() ? 1 : -1);
      } while (wrong == ans || wrong < 0);
      values[i] = wrong.toString();
    }
    return _Wave(
      instruction: 'Two intruders! Knock out BOTH wrong answers.',
      signText: '$a + $b = $ans',
      values: values,
      intruderIndices: indices,
    );
  }
}

class _SnowBackdrop extends StatelessWidget {
  const _SnowBackdrop();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SnowPainter());
  }
}

class _SnowPainter extends CustomPainter {
  final List<Offset> _flakes = List.generate(50, (i) {
    final r = Random(i * 47);
    return Offset(r.nextDouble(), r.nextDouble());
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (final f in _flakes) {
      canvas.drawCircle(
          Offset(f.dx * size.width, f.dy * size.height), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
