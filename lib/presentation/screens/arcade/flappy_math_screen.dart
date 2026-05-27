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

class FlappyMathScreen extends StatefulWidget {
  final ChildModel child;

  const FlappyMathScreen({super.key, required this.child});

  @override
  State<FlappyMathScreen> createState() => _FlappyMathScreenState();
}

class _FlappyMathScreenState extends State<FlappyMathScreen> {
  late FlappyMathGame _game;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _game = FlappyMathGame(
      level: widget.child.currentLevel.clamp(1, 10),
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _saveAndExit() async {
    _game.pauseEngine();
    await _saveHighScore();
    if (mounted) context.pop();
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'arcade_hs_flappy_${widget.child.id}';
    final prev = prefs.getInt(key) ?? 0;
    if (_game.score > prev) await prefs.setInt(key, _game.score);
  }

  void _restart() {
    setState(() => _newGame());
  }

  @override
  Widget build(BuildContext context) {
    final q = _game.currentQuestion;
    final showQuestion = _game.isStarted &&
        !_game.isGameOver &&
        q != null &&
        !_game.questionAnswered;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Flame game ─────────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _game.tap(),
            child: GameWidget(game: _game),
          ),

          // ── Top HUD ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Lives (hearts)
                  Row(
                    children: List.generate(3, (i) => Padding(
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
                    )),
                  ),
                  const Spacer(),
                  // Streak badge (only when 2+)
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
                  // Score pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${_game.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Exit button
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

          // ── Tap to start ───────────────────────────────────────────────
          if (!_game.isStarted && !_game.isGameOver)
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flutter_dash_rounded,
                        color: Color(0xFFFFE600), size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'FLAPPY MATH',
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'Tap anywhere to start',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fly through pipes  •  answer maths for +5 bonus',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // ── Question card (bottom overlay) ─────────────────────────────
          if (showQuestion)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _QuestionCard(
                question: q,
                onAnswer: (ans) => _game.answerQuestion(ans),
              ),
            ),

          // ── Feedback flash ─────────────────────────────────────────────
          if (_game.feedbackText != null && _game.isStarted && !_game.isGameOver)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _game.feedbackCorrect
                        ? AppColors.success.withValues(alpha: 0.85)
                        : AppColors.error.withValues(alpha: 0.85),
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
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports_score_rounded,
                  color: AppColors.primary, size: 48),
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
                        backgroundColor: AppColors.primary,
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
//  Question card widget
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final ArcadeQuestion question;
  final ValueChanged<int> onAnswer;

  const _QuestionCard({required this.question, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question.questionText,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: question.choices
                .take(2) // flappy uses 2 choices
                .map((c) => Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => onAnswer(c),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.85),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('$c',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Flame game
// ─────────────────────────────────────────────────────────────────────────────

class FlappyMathGame extends FlameGame {
  // ── public state (read by Flutter widget) ────────────────────────────────
  int score = 0;
  int streak = 0; // consecutive correct answers (resets on wrong/hit)
  int lives = 3;
  bool isGameOver = false;
  bool isStarted = false;
  bool questionAnswered = true;
  ArcadeQuestion? currentQuestion;
  String? feedbackText;
  bool feedbackCorrect = true;

  // ── private ───────────────────────────────────────────────────────────────
  final int level;
  final VoidCallback onStateChanged;
  late final ArcadeQuestionGenerator _qGen;
  final Random _rng = Random();

  late _BirdComponent _bird;
  final List<_PipeComponent> _pipes = [];

  double _pipeTimer = 0;
  double _questionTimer = 0;
  double _feedbackTimer = 0;
  double _hitCooldown = 0;

  static const double _pipeInterval = 2.2;
  static const double _questionInterval = 8.0;
  static const double _feedbackDuration = 1.2;
  static const double _hitCooldownDuration = 1.5;

  FlappyMathGame({required this.level, required this.onStateChanged});

  @override
  Color backgroundColor() => const Color(0xFF0A1628);

  @override
  Future<void> onLoad() async {
    _qGen = ArcadeQuestionGenerator(level: level);
    _bird = _BirdComponent(
      position: Vector2(size.x * 0.25, size.y * 0.5),
    );
    add(_bird);
  }

  // Called by Flutter GestureDetector
  void tap() {
    if (isGameOver) return;
    if (!isStarted) {
      isStarted = true;
      onStateChanged();
    }
    _bird.flap();
  }

  // Called by answer buttons
  void answerQuestion(int answer) {
    if (currentQuestion == null || questionAnswered) return;
    questionAnswered = true;
    if (answer == currentQuestion!.correctAnswer) {
      streak++;
      // Streak multiplier: +5, +7, +10, +15, +20...
      final bonus = 5 + (streak - 1) * 2 + (streak >= 3 ? 3 : 0);
      score += bonus;
      _bird.flap(); // bonus flap
      feedbackText = streak >= 2
          ? '+$bonus  ${streak}x streak!'
          : '+$bonus Correct!';
      feedbackCorrect = true;
    } else {
      streak = 0;
      feedbackText = 'Wrong! -1 life';
      feedbackCorrect = false;
      _applyHit();
    }
    _feedbackTimer = _feedbackDuration;
    onStateChanged();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Countdown timers
    if (_hitCooldown > 0) _hitCooldown -= dt;
    if (_feedbackTimer > 0) {
      _feedbackTimer -= dt;
      if (_feedbackTimer <= 0) {
        feedbackText = null;
        onStateChanged();
      }
    }

    if (!isStarted || isGameOver) return;

    // Spawn pipes
    _pipeTimer += dt;
    if (_pipeTimer >= _pipeInterval) {
      _pipeTimer = 0;
      _spawnPipe();
    }

    // Question timer
    if (questionAnswered) {
      _questionTimer += dt;
      if (_questionTimer >= _questionInterval) {
        _questionTimer = 0;
        questionAnswered = false;
        currentQuestion = _qGen.generate(choiceCount: 2);
        onStateChanged();
      }
    }

    // Pipe scoring + collision
    for (final pipe in List.of(_pipes)) {
      // Clean up off-screen pipes
      if (pipe.position.x < -(_PipeComponent.pipeWidth + 5)) {
        pipe.removeFromParent();
        _pipes.remove(pipe);
        continue;
      }
      // Score: bird passed this pipe
      if (!pipe.scored &&
          pipe.position.x + _PipeComponent.pipeWidth < _bird.position.x) {
        pipe.scored = true;
        score++;
        onStateChanged();
      }
      // Collision (shrink bird hitbox by 4px for fairness)
      if (_hitCooldown <= 0) {
        final bL = _bird.position.x + 4;
        final bR = _bird.position.x + _bird.size.x - 4;
        final bT = _bird.position.y + 4;
        final bB = _bird.position.y + _bird.size.y - 4;
        final pL = pipe.position.x;
        final pR = pipe.position.x + _PipeComponent.pipeWidth;
        final gapTop = pipe.gapCenter - _PipeComponent.gapHeight / 2;
        final gapBot = pipe.gapCenter + _PipeComponent.gapHeight / 2;

        if (bR > pL && bL < pR) {
          if (bT < gapTop || bB > gapBot) {
            feedbackText = 'Hit pipe!';
            feedbackCorrect = false;
            _feedbackTimer = _feedbackDuration;
            _applyHit();
            break;
          }
        }
      }
    }

    // Ground collision
    final ground = size.y - 55;
    if (_hitCooldown <= 0 && _bird.position.y > ground - _bird.size.y) {
      _bird.position.y = ground - _bird.size.y;
      _bird.velocity = 0;
      feedbackText = 'Hit ground!';
      feedbackCorrect = false;
      _feedbackTimer = _feedbackDuration;
      _applyHit();
    }

    // Ceiling bounce
    if (_bird.position.y < 0) {
      _bird.position.y = 0;
      _bird.velocity = 100;
    }
  }

  void _spawnPipe() {
    final gapCenter = size.y * 0.25 + _rng.nextDouble() * size.y * 0.45;
    final pipe = _PipeComponent(
      position: Vector2(size.x + 5, 0),
      gapCenter: gapCenter,
      screenHeight: size.y,
    );
    add(pipe);
    _pipes.add(pipe);
  }

  void _applyHit() {
    if (isGameOver || _hitCooldown > 0) return;
    _hitCooldown = _hitCooldownDuration;
    streak = 0; // hits break the streak
    lives--;
    if (lives <= 0) {
      lives = 0;
      isGameOver = true;
      onStateChanged();
      return;
    }
    // Reset bird to center, clear pipes
    _bird.position = Vector2(size.x * 0.25, size.y * 0.5);
    _bird.velocity = 0;
    for (final p in List.of(_pipes)) {
      p.removeFromParent();
    }
    _pipes.clear();
    _pipeTimer = 0;
    onStateChanged();
  }

  @override
  void render(Canvas canvas) {
    // Scrolling star-like dots (simple background detail)
    // Ground bar
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 55, size.x, 55),
      Paint()..color = const Color(0xFF1A2142),
    );
    // Ground top highlight
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 57, size.x, 3),
      Paint()..color = const Color(0xFF00FF88).withValues(alpha: 0.5),
    );
    super.render(canvas);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bird component
// ─────────────────────────────────────────────────────────────────────────────

class _BirdComponent extends PositionComponent {
  double velocity = 0;

  static const double _gravity = 520.0;
  static const double _flapVelocity = -290.0;
  static const double _birdRadius = 16.0;

  _BirdComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(_birdRadius * 2),
          anchor: Anchor.topLeft,
        );

  void flap() => velocity = _flapVelocity;

  @override
  void update(double dt) {
    velocity += _gravity * dt;
    position.y += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    // Body
    canvas.drawCircle(
      Offset(_birdRadius, _birdRadius),
      _birdRadius,
      Paint()..color = const Color(0xFFFFE600),
    );
    // Wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_birdRadius - 5, _birdRadius + 3),
        width: 14,
        height: 8,
      ),
      Paint()..color = const Color(0xFFFFB300),
    );
    // Eye
    canvas.drawCircle(
      Offset(_birdRadius + 7, _birdRadius - 4),
      4.5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(_birdRadius + 8, _birdRadius - 4),
      2.5,
      Paint()..color = Colors.black,
    );
    // Beak
    final beak = Path()
      ..moveTo(_birdRadius + _birdRadius - 2, _birdRadius)
      ..lineTo(_birdRadius + _birdRadius + 8, _birdRadius - 3)
      ..lineTo(_birdRadius + _birdRadius + 8, _birdRadius + 3)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFF6B00));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pipe component
// ─────────────────────────────────────────────────────────────────────────────

class _PipeComponent extends PositionComponent {
  final double gapCenter;
  final double screenHeight;
  bool scored = false;

  static const double pipeWidth = 64.0;
  static const double gapHeight = 165.0;
  static const double pipeSpeed = 155.0;

  _PipeComponent({
    required Vector2 position,
    required this.gapCenter,
    required this.screenHeight,
  }) : super(
          position: position,
          size: Vector2(pipeWidth, screenHeight),
          anchor: Anchor.topLeft,
        );

  @override
  void update(double dt) {
    position.x -= pipeSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final topH = gapCenter - gapHeight / 2;
    final botY = gapCenter + gapHeight / 2;

    final bodyPaint = Paint()..color = const Color(0xFF00C853);
    final capPaint = Paint()..color = const Color(0xFF00E676);
    final edgePaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // ── Top pipe ──────────────────────────────────────────────────────────
    if (topH > 0) {
      // Body
      canvas.drawRect(
          Rect.fromLTWH(6, 0, pipeWidth - 12, topH - 14), bodyPaint);
      // Cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, topH - 14, pipeWidth, 14),
          const Radius.circular(4),
        ),
        capPaint,
      );
      // Edge glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, topH - 14, pipeWidth, 14),
          const Radius.circular(4),
        ),
        edgePaint,
      );
    }

    // ── Bottom pipe ───────────────────────────────────────────────────────
    if (botY < screenHeight - 55) {
      // Cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, botY, pipeWidth, 14),
          const Radius.circular(4),
        ),
        capPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, botY, pipeWidth, 14),
          const Radius.circular(4),
        ),
        edgePaint,
      );
      // Body
      canvas.drawRect(
          Rect.fromLTWH(6, botY + 14, pipeWidth - 12, screenHeight - botY - 14),
          bodyPaint);
    }
  }
}
