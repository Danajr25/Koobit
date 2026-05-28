import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/child_model.dart';

/// Cannon Aim — drifting targets, tap the correct one to fire.
///
/// Level design:
///   L1 Count        — targets show numbers, tap the one that matches the
///                     count of dots in the prompt.
///   L2 Addition     — slow drift, single-digit sums.
///   L3 Subtraction  — faster drift.
///   L4 Sequence     — tap targets in ascending order from a scrambled wave.
///   L5 Rapid Fire   — mixed +/-/×, 10-second window to chain 3 correct.
class CannonAimScreen extends StatefulWidget {
  final ChildModel child;
  const CannonAimScreen({super.key, required this.child});

  @override
  State<CannonAimScreen> createState() => _CannonAimScreenState();
}

class _CannonAimScreenState extends State<CannonAimScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxLevel = 5;
  static const int _hitsPerLevel = 5;
  static const int _startingLives = 3;

  final _rng = Random();
  late final Ticker _ticker;

  int _level = 1;
  int _lives = _startingLives;
  int _score = 0;
  int _hitsThisLevel = 0;
  bool _gameOver = false;
  bool _won = false;

  // Wave state
  _Wave? _wave;
  int? _flashTargetId;
  bool _flashCorrect = false;

  // Sequence tracking (L4)
  int _seqIndex = 0;

  // Rapid-fire timer (L5)
  Timer? _rapidTimer;
  int _rapidRemaining = 0;
  int _rapidChain = 0;
  static const int _rapidChainTarget = 3;
  static const int _rapidWindowSeconds = 10;

  Duration _lastFrame = Duration.zero;
  Size _arenaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWave());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _rapidTimer?.cancel();
    super.dispose();
  }

  void _startWave() {
    _wave = _Wave.generate(_level, _rng, _arenaSize);
    _seqIndex = 0;
    if (_level == 5) {
      _rapidRemaining = _rapidWindowSeconds;
      _rapidChain = 0;
      _rapidTimer?.cancel();
      _rapidTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _gameOver) return;
        setState(() => _rapidRemaining--);
        if (_rapidRemaining <= 0) {
          _rapidTimer?.cancel();
          // Failed to chain in time → lose a life
          setState(() {
            _lives--;
            _rapidChain = 0;
            _rapidRemaining = _rapidWindowSeconds;
          });
          if (_lives <= 0) _endGame(won: false);
        }
      });
    } else {
      _rapidTimer?.cancel();
    }
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (_wave == null || _gameOver) {
      _lastFrame = elapsed;
      return;
    }
    final dt = (elapsed - _lastFrame).inMilliseconds / 1000.0;
    _lastFrame = elapsed;
    final w = _wave!;
    bool changed = false;
    for (final t in w.targets) {
      if (!t.alive) continue;
      t.x += t.vx * dt;
      t.y += t.vy * dt;
      // bounce horizontally
      if (t.x < 0) {
        t.x = 0;
        t.vx = t.vx.abs();
        changed = true;
      } else if (t.x > _arenaSize.width - _Wave.targetSize) {
        t.x = _arenaSize.width - _Wave.targetSize;
        t.vx = -t.vx.abs();
        changed = true;
      }
      // vertical drift down — if off the bottom, lose & respawn at top
      if (t.y > _arenaSize.height - _Wave.targetSize - 90) {
        t.y = -_Wave.targetSize.toDouble();
        t.x = _rng.nextDouble() *
            (_arenaSize.width - _Wave.targetSize).clamp(0, double.infinity);
        changed = true;
      }
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  void _tapTarget(_Target t) async {
    if (_gameOver || !t.alive || _wave == null) return;
    final w = _wave!;
    bool correct;
    if (_level == 4) {
      // Sequence: must tap targets in ascending value order
      final expectedValue = (w.sortedValues)[_seqIndex];
      correct = t.value == expectedValue;
    } else {
      correct = t.value == w.correctValue;
    }

    setState(() {
      _flashTargetId = t.id;
      _flashCorrect = correct;
      if (correct) {
        t.alive = false;
        _score += 10 * _level;
        if (_level == 5) {
          _rapidChain++;
          if (_rapidChain >= _rapidChainTarget) {
            _hitsThisLevel = _hitsPerLevel; // complete this wave
          }
        } else if (_level == 4) {
          _seqIndex++;
          if (_seqIndex >= w.sortedValues.length) {
            _hitsThisLevel++;
          }
        } else {
          _hitsThisLevel++;
        }
      } else {
        _lives--;
      }
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() {
      _flashTargetId = null;
    });

    if (_lives <= 0) {
      _endGame(won: false);
      return;
    }
    if (_hitsThisLevel >= _hitsPerLevel) {
      if (_level >= _maxLevel) {
        _endGame(won: true);
        return;
      }
      setState(() {
        _level++;
        _hitsThisLevel = 0;
      });
      _startWave();
      return;
    }
    // For non-sequence/non-rapid levels, a correct hit cues the next prompt
    if (correct && _level != 4) {
      _startWave();
    }
  }

  Future<void> _endGame({required bool won}) async {
    _rapidTimer?.cancel();
    setState(() {
      _gameOver = true;
      _won = won;
    });
    final prefs = await SharedPreferences.getInstance();
    final hsKey = 'arcade_hs_cannon_aim_${widget.child.id}';
    if (_score > (prefs.getInt(hsKey) ?? 0)) {
      await prefs.setInt(hsKey, _score);
    }
  }

  void _restart() {
    setState(() {
      _level = 1;
      _lives = _startingLives;
      _score = 0;
      _hitsThisLevel = 0;
      _gameOver = false;
      _won = false;
    });
    _startWave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11212C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11212C),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Cannon Aim',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, constraints) {
          _arenaSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // Decorative starry background
              const Positioned.fill(child: _StarField()),
              // Targets
              if (_wave != null && !_gameOver)
                ..._wave!.targets.where((t) => t.alive).map(_buildTarget),
              // Cannon
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCannon(),
              ),
              // HUD
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: _buildHud(),
              ),
              // Prompt banner
              if (_wave != null && !_gameOver)
                Positioned(
                  top: 64,
                  left: 16,
                  right: 16,
                  child: _buildPromptBanner(),
                ),
              if (_gameOver) Positioned.fill(child: _buildEndScreen()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHud() {
    return Row(
      children: [
        _hudChip(
            'Lv $_level/$_maxLevel', Icons.flag_rounded, AppColors.primary),
        const SizedBox(width: 8),
        _hudChip('$_score', Icons.star_rounded, AppColors.warning),
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
                      color: const Color(0xFFFF6B6B),
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
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPromptBanner() {
    final w = _wave!;
    String text = w.prompt;
    if (_level == 4) {
      text = 'Tap targets in order: ${w.sortedValues.join(', ')}';
    } else if (_level == 5) {
      text = '${w.prompt}   ·   Chain $_rapidChain/$_rapidChainTarget'
          '   ·   ${_rapidRemaining}s';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTarget(_Target t) {
    final isFlash = _flashTargetId == t.id;
    Color color = const Color(0xFFFFCB6B);
    Color border = Colors.white;
    if (isFlash) {
      color = _flashCorrect ? AppColors.success : AppColors.error;
    }
    return Positioned(
      left: t.x,
      top: t.y + 60,
      width: _Wave.targetSize.toDouble(),
      height: _Wave.targetSize.toDouble(),
      child: GestureDetector(
        onTap: () => _tapTarget(t),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            t.value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B2733),
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCannon() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF11212C)],
        ),
      ),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gps_fixed_rounded, color: Colors.white70, size: 28),
          SizedBox(width: 8),
          Text(
            'Tap a target to fire',
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen() {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _won ? Icons.emoji_events_rounded : Icons.gps_off_rounded,
            size: 96,
            color: _won ? AppColors.warning : Colors.white54,
          ),
          const SizedBox(height: 12),
          Text(
            _won ? 'Sharpshooter!' : 'Out of lives',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Score: $_score',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
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
                icon: const Icon(Icons.exit_to_app_rounded,
                    color: Colors.white),
                label: const Text('Exit',
                    style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Target {
  final int id;
  final int value;
  double x;
  double y;
  double vx;
  double vy;
  bool alive;
  _Target({
    required this.id,
    required this.value,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  }) : alive = true;
}

class _Wave {
  static const int targetSize = 64;

  final String prompt;
  final int correctValue;
  final List<_Target> targets;
  final List<int> sortedValues; // for level-4 sequence
  _Wave({
    required this.prompt,
    required this.correctValue,
    required this.targets,
    required this.sortedValues,
  });

  static _Wave generate(int level, Random rng, Size arena) {
    final w = arena.width <= 0 ? 320.0 : arena.width;
    final h = arena.height <= 0 ? 520.0 : arena.height;

    double rx() =>
        rng.nextDouble() * (w - targetSize).clamp(1, double.infinity);
    double ry() =>
        rng.nextDouble() * (h * 0.45).clamp(80, double.infinity) + 20;

    // Speed scales with level
    double speed() {
      final base = 25.0 + level * 12.0;
      return base + rng.nextDouble() * 20.0;
    }

    double vx() => (rng.nextBool() ? 1 : -1) * speed();
    double vy() => 15.0 + rng.nextDouble() * 10.0 + level * 3.0;

    switch (level) {
      case 1:
        {
          // Count of dots prompt → tap target with that number
          final n = rng.nextInt(8) + 2; // 2..9
          final values = <int>{n};
          while (values.length < 4) {
            final v = rng.nextInt(10) + 1;
            if (v != n) values.add(v);
          }
          final list = values.toList()..shuffle(rng);
          return _Wave(
            prompt: 'Shoot the target showing ${'●' * n}  ($n)',
            correctValue: n,
            sortedValues: list..sort(),
            targets: [
              for (int i = 0; i < list.length; i++)
                _Target(
                    id: i,
                    value: list[i],
                    x: rx(),
                    y: ry(),
                    vx: vx(),
                    vy: vy() * 0.4),
            ],
          );
        }
      case 2:
        {
          // Addition
          final a = rng.nextInt(8) + 1;
          final b = rng.nextInt(8) + 1;
          final ans = a + b;
          final values = _distractors(ans, rng, 4, maxDelta: 4);
          return _Wave(
            prompt: '$a + $b = ?',
            correctValue: ans,
            sortedValues: values..sort(),
            targets: [
              for (int i = 0; i < values.length; i++)
                _Target(
                    id: i,
                    value: values[i],
                    x: rx(),
                    y: ry(),
                    vx: vx(),
                    vy: vy() * 0.5),
            ],
          );
        }
      case 3:
        {
          // Subtraction, faster
          final b = rng.nextInt(7) + 2;
          final ans = rng.nextInt(7) + 2;
          final a = ans + b;
          final values = _distractors(ans, rng, 4, maxDelta: 4);
          return _Wave(
            prompt: '$a − $b = ?',
            correctValue: ans,
            sortedValues: values..sort(),
            targets: [
              for (int i = 0; i < values.length; i++)
                _Target(
                    id: i,
                    value: values[i],
                    x: rx(),
                    y: ry(),
                    vx: vx() * 1.3,
                    vy: vy() * 0.7),
            ],
          );
        }
      case 4:
        {
          // Sequence — tap ascending
          final start = rng.nextInt(8) + 1;
          final values = List.generate(5, (i) => start + i)..shuffle(rng);
          return _Wave(
            prompt: 'Tap in order!',
            correctValue: values.first,
            sortedValues: List<int>.from(values)..sort(),
            targets: [
              for (int i = 0; i < values.length; i++)
                _Target(
                    id: i,
                    value: values[i],
                    x: rx(),
                    y: ry(),
                    vx: vx() * 0.8,
                    vy: vy() * 0.5),
            ],
          );
        }
      case 5:
      default:
        {
          // Mixed +/-/×
          final ops = ['+', '−', '×'];
          final op = ops[rng.nextInt(ops.length)];
          int a, b, ans;
          switch (op) {
            case '+':
              a = rng.nextInt(9) + 1;
              b = rng.nextInt(9) + 1;
              ans = a + b;
              break;
            case '−':
              b = rng.nextInt(8) + 1;
              ans = rng.nextInt(8) + 1;
              a = ans + b;
              break;
            default: // ×
              a = rng.nextInt(5) + 2;
              b = rng.nextInt(5) + 2;
              ans = a * b;
          }
          final values = _distractors(ans, rng, 5, maxDelta: 5);
          return _Wave(
            prompt: '$a $op $b = ?',
            correctValue: ans,
            sortedValues: values..sort(),
            targets: [
              for (int i = 0; i < values.length; i++)
                _Target(
                    id: i,
                    value: values[i],
                    x: rx(),
                    y: ry(),
                    vx: vx() * 1.6,
                    vy: vy() * 0.9),
            ],
          );
        }
    }
  }

  static List<int> _distractors(int answer, Random rng, int count,
      {int maxDelta = 4}) {
    final s = <int>{answer};
    var safety = 0;
    while (s.length < count && safety++ < 60) {
      final d = rng.nextInt(maxDelta) + 1;
      final v = rng.nextBool() ? answer + d : answer - d;
      if (v >= 0) s.add(v);
    }
    var next = 0;
    while (s.length < count) {
      if (next != answer) s.add(next);
      next++;
    }
    return (s.toList()..shuffle(rng)).take(count).toList();
  }
}

/// Minimal frame ticker (avoids depending on Flame just for this).
class Ticker {
  final void Function(Duration) onTick;
  bool _running = false;
  Duration _start = Duration.zero;
  Ticker(this.onTick);
  void start() {
    _running = true;
    _start = Duration.zero;
    WidgetsBinding.instance.scheduleFrameCallback(_loop);
  }

  void _loop(Duration ts) {
    if (!_running) return;
    if (_start == Duration.zero) _start = ts;
    onTick(ts - _start);
    WidgetsBinding.instance.scheduleFrameCallback(_loop);
  }

  void dispose() {
    _running = false;
  }
}

class _StarField extends StatelessWidget {
  const _StarField();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  final List<Offset> _stars = List.generate(60, (i) {
    final r = Random(i * 31);
    return Offset(r.nextDouble(), r.nextDouble());
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (final s in _stars) {
      canvas.drawCircle(
          Offset(s.dx * size.width, s.dy * size.height), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
