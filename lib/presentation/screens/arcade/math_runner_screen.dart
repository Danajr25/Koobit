import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/arcade_question_generator.dart';
import '../../../../data/models/child_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Screen widget
// ─────────────────────────────────────────────────────────────────────────────

class MathRunnerScreen extends StatefulWidget {
  final ChildModel child;

  const MathRunnerScreen({super.key, required this.child});

  @override
  State<MathRunnerScreen> createState() => _MathRunnerScreenState();
}

class _MathRunnerScreenState extends State<MathRunnerScreen> {
  late MathRunnerGame _game;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _game = MathRunnerGame(
      level: widget.child.currentLevel.clamp(1, 10),
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _saveAndExit() async {
    _game.pauseEngine();
    final prefs = await SharedPreferences.getInstance();
    final key = 'arcade_hs_runner_${widget.child.id}';
    final prev = prefs.getInt(key) ?? 0;
    if (_game.score > prev) await prefs.setInt(key, _game.score);
    if (mounted) context.pop();
  }

  void _restart() => setState(() => _newGame());

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final q = _game.currentQuestion;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Flame game ─────────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final p = d.localPosition;
              _game.handleTap(Vector2(p.dx, p.dy));
            },
            child: GameWidget(game: _game),
          ),

          // ── Top HUD ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          i < _game.lives
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: i < _game.lives
                              ? const Color(0xFFFF3B5C)
                              : Colors.grey.shade700,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_game.streak >= 2)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9500), Color(0xFFFF3B5C)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_game.streak}x',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      '${_game.score}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _saveAndExit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white60, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Question card ──────────────────────────────────────────────
          if (_game.isStarted && !_game.isGameOver && q != null)
            Positioned(
              top: topPad + 68,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color:
                            const Color(0xFFFF9500).withValues(alpha: 0.55)),
                    boxShadow: [
                      BoxShadow(
                          color:
                              const Color(0xFFFF9500).withValues(alpha: 0.2),
                          blurRadius: 20)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Stay on ground for correct answer!',
                        style: TextStyle(
                            color: Color(0xFFFF9500),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        q.questionText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Feedback flash ─────────────────────────────────────────────
          if (_game.feedbackText != null &&
              _game.isStarted &&
              !_game.isGameOver)
            Positioned(
              top: topPad + 155,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_game.feedbackCorrect
                            ? AppColors.success
                            : AppColors.error)
                        .withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _game.feedbackText!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ),

          // ── Tap to start ───────────────────────────────────────────────
          if (!_game.isStarted && !_game.isGameOver)
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_run_rounded,
                        color: Color(0xFFFF9500), size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'MATH RUNNER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFF9500).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFF9500)
                                .withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'Tap anywhere to start',
                        style: TextStyle(
                            color: Color(0xFFFF9500),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InstructionRow(
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFFFF3B5C),
                        text: 'JUMP over wrong answers'),
                    const SizedBox(height: 6),
                    _InstructionRow(
                        icon: Icons.radio_button_unchecked_rounded,
                        color: const Color(0xFF30D158),
                        text: 'STAY for the correct answer'),
                  ],
                ),
              ),
            ),

          // ── Game over ─────────────────────────────────────────────────
          if (_game.isGameOver) _buildGameOver(),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFFF9500).withValues(alpha: 0.35),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                  blurRadius: 30)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_run_rounded,
                  color: Color(0xFFFF9500), size: 48),
              const SizedBox(height: 12),
              const Text(
                'GAME OVER',
                style: TextStyle(
                    color: AppColors.error,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: ${_game.score}',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveAndExit,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Exit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9500),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Small instruction row helper
// ─────────────────────────────────────────────────────────────────────────────

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InstructionRow(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Flame game
// ─────────────────────────────────────────────────────────────────────────────

class MathRunnerGame extends FlameGame {
  // ── public state ──────────────────────────────────────────────────────────
  int score = 0;
  int streak = 0;
  int lives = 3;
  bool isGameOver = false;
  bool isStarted = false;
  ArcadeQuestion? currentQuestion;
  String? feedbackText;
  bool feedbackCorrect = true;

  // ── private ───────────────────────────────────────────────────────────────
  final int level;
  final VoidCallback onStateChanged;
  late final ArcadeQuestionGenerator _qGen;
  final Random _rng = Random();

  late _RunnerComponent _runner;
  _ObstacleComponent? _obstacle;
  bool _obstacleHandled = false;

  double _feedbackTimer = 0;
  double _nextObstacleTimer = -1; // -1 = not scheduled
  double _obstacleSpeed = 200.0;
  double _scrollOffset = 0;
  late double _groundY;
  int _consecutiveWrong = 0;

  MathRunnerGame({required this.level, required this.onStateChanged});

  @override
  Color backgroundColor() => const Color(0xFF0A1020);

  @override
  Future<void> onLoad() async {
    _qGen = ArcadeQuestionGenerator(level: level);
    _groundY = size.y - 70;
    _obstacleSpeed = (180.0 + level * 10.0).clamp(180.0, 280.0);

    _runner = _RunnerComponent(
      groundY: _groundY,
      position:
          Vector2(size.x * 0.18, _groundY - _RunnerComponent.runnerHeight),
    );
    add(_runner);
    _generateQuestion();
  }

  void handleTap(Vector2 tapPos) {
    if (isGameOver) return;
    if (!isStarted) {
      isStarted = true;
      _nextObstacleTimer = 1.4;
      onStateChanged();
      return;
    }
    _runner.jump();
  }

  void _generateQuestion() {
    currentQuestion = _qGen.generate(choiceCount: 4);
  }

  void _spawnObstacle() {
    _obstacleHandled = false;

    // Ensure a correct obstacle appears at least every 4 obstacles
    final bool isCorrect;
    if (_consecutiveWrong >= 3) {
      isCorrect = true;
      _consecutiveWrong = 0;
    } else {
      isCorrect = _rng.nextDouble() < 0.42;
      if (isCorrect) {
        _consecutiveWrong = 0;
      } else {
        _consecutiveWrong++;
      }
    }

    final int number;
    if (isCorrect) {
      number = currentQuestion!.correctAnswer;
    } else {
      final wrongs = currentQuestion!.choices
          .where((c) => c != currentQuestion!.correctAnswer)
          .toList();
      number = wrongs.isNotEmpty
          ? wrongs[_rng.nextInt(wrongs.length)]
          : currentQuestion!.correctAnswer + _rng.nextInt(7) + 1;
    }

    _obstacle = _ObstacleComponent(
      position: Vector2(
          size.x + 20, _groundY - _ObstacleComponent.obstacleHeight),
      number: number,
      isCorrect: isCorrect,
      speed: _obstacleSpeed,
    );
    add(_obstacle!);
  }

  void _onCorrectObstacle() {
    if (_obstacleHandled) return;
    _obstacleHandled = true;
    streak++;
    final bonus = 1 + (streak >= 3 ? 1 : 0) + (streak >= 5 ? 1 : 0) + (streak >= 8 ? 2 : 0);
    score += bonus;
    _obstacleSpeed = (_obstacleSpeed + 4).clamp(180.0, 360.0);
    feedbackText = streak >= 2 ? '+$bonus  ${streak}x streak!' : 'Correct! +$bonus';
    feedbackCorrect = true;
    _feedbackTimer = 0.8;
    _runner.cheer();
    _obstacle?.removeFromParent();
    _obstacle = null;
    _generateQuestion();
    _nextObstacleTimer = 1.0;
    onStateChanged();
  }

  void _onWrongObstacle() {
    if (_obstacleHandled) return;
    _obstacleHandled = true;
    streak = 0;
    lives--;
    feedbackText = lives > 0 ? 'Oops! -1 life' : 'Game Over!';
    feedbackCorrect = false;
    _feedbackTimer = 0.9;
    _runner.stumble();
    _obstacle?.removeFromParent();
    _obstacle = null;
    if (lives <= 0) {
      lives = 0;
      isGameOver = true;
      onStateChanged();
      return;
    }
    _nextObstacleTimer = 1.2;
    onStateChanged();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _scrollOffset += _obstacleSpeed * dt;
    if (_scrollOffset > 80) _scrollOffset -= 80;

    if (_feedbackTimer > 0) {
      _feedbackTimer -= dt;
      if (_feedbackTimer <= 0) {
        feedbackText = null;
        onStateChanged();
      }
    }

    if (!isStarted || isGameOver) return;

    // Spawn countdown
    if (_obstacle == null && _nextObstacleTimer > 0) {
      _nextObstacleTimer -= dt;
      if (_nextObstacleTimer <= 0) {
        _nextObstacleTimer = -1;
        _spawnObstacle();
      }
    }

    // Collision check
    final ob = _obstacle;
    if (ob != null && !_obstacleHandled) {
      final rLeft = _runner.position.x + 6; // slight inset for fairness
      final rRight = _runner.position.x + _RunnerComponent.runnerWidth - 6;
      final oLeft = ob.position.x + 4;
      final oRight = ob.position.x + _ObstacleComponent.obstacleWidth - 4;

      if (rRight > oLeft && rLeft < oRight) {
        final runnerBottom =
            _runner.position.y + _RunnerComponent.runnerHeight;
        final obstacleTop = _groundY - _ObstacleComponent.obstacleHeight;

        if (runnerBottom > obstacleTop + 12) {
          // Runner is at obstacle level — collision
          if (ob.isCorrect) {
            _onCorrectObstacle();
          } else {
            _onWrongObstacle();
          }
        }
        // Else runner is jumping above obstacle — pass safely
      }

      // Obstacle scrolled past the runner (jumped over / missed)
      if (ob.position.x + _ObstacleComponent.obstacleWidth <
          _runner.position.x - 10) {
        ob.removeFromParent();
        _obstacle = null;
        _nextObstacleTimer = 0.9;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Sky gradient (two-tone for depth)
    final skyRect = Rect.fromLTWH(0, 0, size.x, _groundY);
    canvas.drawRect(skyRect, Paint()..color = const Color(0xFF0A1020));

    // Distant "city" silhouette
    _drawSilhouette(canvas);

    // Ground fill
    canvas.drawRect(
      Rect.fromLTWH(0, _groundY, size.x, size.y - _groundY),
      Paint()..color = const Color(0xFF1A2A44),
    );

    // Ground top glow
    canvas.drawRect(
      Rect.fromLTWH(0, _groundY, size.x, 3),
      Paint()..color = const Color(0xFFFF9500).withValues(alpha: 0.6),
    );

    // Scrolling dashes on ground
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2;
    final dashSpacing = 80.0;
    final dashStart = -((_scrollOffset) % dashSpacing);
    for (double x = dashStart; x < size.x; x += dashSpacing) {
      canvas.drawLine(
        Offset(x, _groundY + 18),
        Offset(x + 40, _groundY + 18),
        dashPaint,
      );
    }

    super.render(canvas);
  }

  void _drawSilhouette(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF0D1830);
    final buildingCount = 8;
    final bWidth = size.x / buildingCount;
    for (int i = 0; i < buildingCount; i++) {
      final h = 40.0 + (i * 31 % 60);
      canvas.drawRect(
        Rect.fromLTWH(
            i * bWidth + 4, _groundY - h, bWidth - 8, h),
        paint,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Runner component
// ─────────────────────────────────────────────────────────────────────────────

class _RunnerComponent extends PositionComponent {
  static const double runnerWidth = 44.0;
  static const double runnerHeight = 54.0;

  double _velocity = 0;
  bool _isOnGround = true;
  double _animTimer = 0;
  bool _isCheer = false;
  bool _isStumble = false;
  double _effectTimer = 0;

  final double groundY;

  static const double _gravity = 920.0;
  static const double _jumpVelocity = -480.0;

  _RunnerComponent({required this.groundY, required Vector2 position})
      : super(
          position: position,
          size: Vector2(runnerWidth, runnerHeight),
          anchor: Anchor.topLeft,
        );

  bool get isOnGround => _isOnGround;

  void jump() {
    if (!_isOnGround) return;
    _velocity = _jumpVelocity;
    _isOnGround = false;
  }

  void cheer() {
    _isCheer = true;
    _effectTimer = 0.5;
  }

  void stumble() {
    _isStumble = true;
    _effectTimer = 0.5;
  }

  @override
  void update(double dt) {
    _animTimer += dt;
    if (!_isOnGround) {
      _velocity += _gravity * dt;
      position.y += _velocity * dt;
      if (position.y + height >= groundY) {
        position.y = groundY - height;
        _velocity = 0;
        _isOnGround = true;
      }
    }
    if (_effectTimer > 0) {
      _effectTimer -= dt;
      if (_effectTimer <= 0) {
        _isCheer = false;
        _isStumble = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final bodyColor = _isCheer
        ? const Color(0xFF30D158)
        : _isStumble
            ? const Color(0xFFFF3B5C)
            : const Color(0xFF00AAFF);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(width / 2 + 2, height + 4), width: 28, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(8, 6, width - 16, height - 22),
          const Radius.circular(8)),
      Paint()..color = bodyColor,
    );

    // Head
    canvas.drawCircle(
      Offset(width / 2, 8),
      10,
      Paint()..color = const Color(0xFFFFD7B0),
    );

    // Eyes
    canvas.drawCircle(
      Offset(width / 2 - 4, 6),
      2.5,
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      Offset(width / 2 + 4, 6),
      2.5,
      Paint()..color = Colors.black87,
    );

    // Mouth
    if (_isCheer) {
      // Big smile
      canvas.drawArc(
        Rect.fromCenter(center: Offset(width / 2, 10), width: 10, height: 6),
        0,
        pi,
        false,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Legs (animated running, or still when in air)
    final legPaint = Paint()
      ..color = const Color(0xFF0077BB)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (_isOnGround) {
      final phase = _animTimer * 7;
      final leg1OffY = sin(phase) * 5;
      final leg2OffY = sin(phase + pi) * 5;
      canvas.drawLine(
        Offset(width / 2 - 5, height - 20),
        Offset(width / 2 - 7, height - 8 + leg1OffY),
        legPaint,
      );
      canvas.drawLine(
        Offset(width / 2 + 5, height - 20),
        Offset(width / 2 + 7, height - 8 + leg2OffY),
        legPaint,
      );
    } else {
      // Legs tucked for jump
      canvas.drawLine(
        Offset(width / 2 - 5, height - 20),
        Offset(width / 2 - 10, height - 12),
        legPaint,
      );
      canvas.drawLine(
        Offset(width / 2 + 5, height - 20),
        Offset(width / 2 + 10, height - 12),
        legPaint,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Obstacle component
// ─────────────────────────────────────────────────────────────────────────────

class _ObstacleComponent extends PositionComponent {
  static const double obstacleWidth = 58.0;
  static const double obstacleHeight = 82.0;

  final int number;
  final bool isCorrect;
  double speed;

  _ObstacleComponent({
    required Vector2 position,
    required this.number,
    required this.isCorrect,
    required this.speed,
  }) : super(
          position: position,
          size: Vector2(obstacleWidth, obstacleHeight),
          anchor: Anchor.topLeft,
        );

  @override
  void update(double dt) {
    position.x -= speed * dt;
  }

  @override
  void render(Canvas canvas) {
    // Wall body
    final wallPaint = Paint()..color = const Color(0xFF3A3A5C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, obstacleWidth, obstacleHeight),
          const Radius.circular(6)),
      wallPaint,
    );

    // Brick grid lines
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    // Horizontal mortar
    for (int r = 1; r < 5; r++) {
      final y = r * (obstacleHeight / 5);
      canvas.drawLine(Offset(0, y), Offset(obstacleWidth, y), linePaint);
    }
    // Vertical mortar (staggered rows)
    for (int r = 0; r < 5; r++) {
      final y0 = r * (obstacleHeight / 5);
      final y1 = y0 + obstacleHeight / 5;
      final offset = r.isEven ? 0.0 : obstacleWidth / 2;
      canvas.drawLine(
          Offset(offset, y0), Offset(offset, y1), linePaint);
      if (offset + obstacleWidth / 2 < obstacleWidth) {
        canvas.drawLine(
          Offset(offset + obstacleWidth / 2, y0),
          Offset(offset + obstacleWidth / 2, y1),
          linePaint,
        );
      }
    }

    // Edge highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, obstacleWidth, obstacleHeight),
          const Radius.circular(6)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Number label
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: number > 99 ? 16 : (number > 9 ? 22 : 26),
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
                color: Colors.black,
                blurRadius: 6,
                offset: Offset(1, 2))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        obstacleWidth / 2 - tp.width / 2,
        obstacleHeight / 2 - tp.height / 2,
      ),
    );
  }
}
