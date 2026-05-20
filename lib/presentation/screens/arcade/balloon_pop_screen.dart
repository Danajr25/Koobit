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

class BalloonPopScreen extends StatefulWidget {
  final ChildModel child;

  const BalloonPopScreen({super.key, required this.child});

  @override
  State<BalloonPopScreen> createState() => _BalloonPopScreenState();
}

class _BalloonPopScreenState extends State<BalloonPopScreen> {
  late BalloonPopGame _game;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _game = BalloonPopGame(
      level: widget.child.currentLevel.clamp(1, 10),
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _saveAndExit() async {
    _game.pauseEngine();
    final prefs = await SharedPreferences.getInstance();
    final key = 'arcade_hs_balloon_${widget.child.id}';
    final prev = prefs.getInt(key) ?? 0;
    if (_game.score > prev) await prefs.setInt(key, _game.score);
    if (mounted) context.pop();
  }

  void _restart() => setState(() => _newGame());

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Flame game with Flutter tap forwarding ─────────────────────
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              const Color(0xFFBF5AF2).withValues(alpha: 0.45)),
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

          // ── Question bubble ────────────────────────────────────────────
          if (_game.isStarted &&
              !_game.isGameOver &&
              _game.currentQuestion != null)
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
                            const Color(0xFFBF5AF2).withValues(alpha: 0.55)),
                    boxShadow: [
                      BoxShadow(
                          color:
                              const Color(0xFFBF5AF2).withValues(alpha: 0.25),
                          blurRadius: 20)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pop the correct balloon!',
                        style: TextStyle(
                            color: Color(0xFFBF5AF2),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _game.currentQuestion!.questionText,
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
                    const Icon(Icons.bubble_chart_rounded,
                        color: Color(0xFFBF5AF2), size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'BALLOON POP',
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
                            const Color(0xFFBF5AF2).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFBF5AF2)
                                .withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'Tap anywhere to start',
                        style: TextStyle(
                            color: Color(0xFFBF5AF2),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pop the balloon with the right answer  •  3 lives',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
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
                color: const Color(0xFFBF5AF2).withValues(alpha: 0.35),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFBF5AF2).withValues(alpha: 0.25),
                  blurRadius: 30)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bubble_chart_rounded,
                  color: Color(0xFFBF5AF2), size: 48),
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
                        backgroundColor: const Color(0xFFBF5AF2),
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
//  Flame game
// ─────────────────────────────────────────────────────────────────────────────

class BalloonPopGame extends FlameGame {
  // ── public state ──────────────────────────────────────────────────────────
  int score = 0;
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

  final List<_BalloonComponent> _balloons = [];
  bool _questionAnswered = false;

  double _feedbackTimer = 0;
  double _roundTimer = -1; // -1 = not waiting
  double _baseSpeed = 85.0;

  BalloonPopGame({required this.level, required this.onStateChanged});

  @override
  Color backgroundColor() => const Color(0xFF0D1B2A);

  @override
  Future<void> onLoad() async {
    _qGen = ArcadeQuestionGenerator(level: level);
    _baseSpeed = (80.0 + level * 5.0).clamp(80.0, 160.0);
  }

  // Called when player taps the screen (forwarded from Flutter GestureDetector)
  void handleTap(Vector2 tapPos) {
    if (!isStarted) {
      isStarted = true;
      _spawnRound();
      onStateChanged();
      return;
    }
    if (isGameOver || _questionAnswered || _roundTimer > 0) return;

    for (final balloon in List.of(_balloons)) {
      final center = Vector2(
        balloon.position.x + _BalloonComponent.radius,
        balloon.position.y + _BalloonComponent.radius,
      );
      // Slightly enlarged hitbox (+10) for forgiving mobile taps
      if (tapPos.distanceTo(center) <= _BalloonComponent.radius + 10) {
        if (balloon.isCorrect) {
          _onCorrectTap();
        } else {
          _onWrongTap(balloon);
        }
        return;
      }
    }
  }

  void _spawnRound() {
    _questionAnswered = false;
    currentQuestion = _qGen.generate(choiceCount: 4);

    final spacing = size.x / 5.0;
    final xPositions = [spacing, spacing * 2, spacing * 3, spacing * 4];
    xPositions.shuffle(_rng);

    const colors = [
      Color(0xFFFF3B5C),
      Color(0xFF00C8FF),
      Color(0xFF30D158),
      Color(0xFFFF9F0A),
    ];

    final choices = List<int>.from(currentQuestion!.choices);

    for (int i = 0; i < 4; i++) {
      final yOffset = _rng.nextDouble() * 60;
      final balloon = _BalloonComponent(
        position: Vector2(
          xPositions[i] - _BalloonComponent.radius,
          size.y + 30 + yOffset,
        ),
        number: choices[i],
        isCorrect: choices[i] == currentQuestion!.correctAnswer,
        color: colors[i],
        speed: _baseSpeed,
      );
      add(balloon);
      _balloons.add(balloon);
    }
    onStateChanged();
  }

  void _onCorrectTap() {
    if (_questionAnswered || isGameOver) return;
    _questionAnswered = true;
    score++;
    _baseSpeed = (_baseSpeed + 3).clamp(80.0, 260.0);
    feedbackText = 'Correct! +1';
    feedbackCorrect = true;
    _feedbackTimer = 0.8;
    _removeBalloons();
    _roundTimer = 0.5;
    onStateChanged();
  }

  void _onWrongTap(_BalloonComponent balloon) {
    if (_questionAnswered || isGameOver) return;
    lives--;
    feedbackText = 'Wrong! -1 life';
    feedbackCorrect = false;
    _feedbackTimer = 0.8;
    balloon.flashWrong();
    if (lives <= 0) {
      lives = 0;
      isGameOver = true;
    }
    onStateChanged();
  }

  void _onCorrectEscape() {
    if (_questionAnswered || isGameOver) return;
    _questionAnswered = true;
    lives--;
    feedbackText = 'Too slow! -1 life';
    feedbackCorrect = false;
    _feedbackTimer = 0.8;
    _removeBalloons();
    if (lives <= 0) {
      lives = 0;
      isGameOver = true;
      onStateChanged();
      return;
    }
    _roundTimer = 0.6;
    onStateChanged();
  }

  void _removeBalloons() {
    for (final b in List.of(_balloons)) {
      b.removeFromParent();
    }
    _balloons.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_feedbackTimer > 0) {
      _feedbackTimer -= dt;
      if (_feedbackTimer <= 0) {
        feedbackText = null;
        onStateChanged();
      }
    }

    if (!isStarted || isGameOver) return;

    if (_roundTimer > 0) {
      _roundTimer -= dt;
      if (_roundTimer <= 0) {
        _roundTimer = -1;
        _spawnRound();
      }
      return;
    }

    // Check balloon escapes
    if (!_questionAnswered) {
      for (final b in List.of(_balloons)) {
        // Balloon fully off the top of the screen
        if (b.position.y + _BalloonComponent.radius * 2 < 0) {
          if (b.isCorrect) {
            _onCorrectEscape();
            break;
          } else {
            b.removeFromParent();
            _balloons.remove(b);
          }
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Ground bar
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 40, size.x, 40),
      Paint()..color = const Color(0xFF1A2040),
    );
    // Ground glow line
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 42, size.x, 2),
      Paint()..color = const Color(0xFFBF5AF2).withValues(alpha: 0.4),
    );
    super.render(canvas);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Balloon component
// ─────────────────────────────────────────────────────────────────────────────

class _BalloonComponent extends PositionComponent {
  static const double radius = 40.0;

  final int number;
  final bool isCorrect;
  Color color;
  final double speed;

  bool _isFlashing = false;
  double _flashTimer = 0;

  // Gentle sway
  double _swayTimer = 0;
  final double _swayFreq;
  final double _swayAmp;

  _BalloonComponent({
    required Vector2 position,
    required this.number,
    required this.isCorrect,
    required this.color,
    required this.speed,
  })  : _swayFreq = 0.6 + Random().nextDouble() * 0.8,
        _swayAmp = 4 + Random().nextDouble() * 6,
        super(
          position: position,
          size: Vector2.all(radius * 2),
          anchor: Anchor.topLeft,
        );

  void flashWrong() {
    _isFlashing = true;
    _flashTimer = 0.4;
  }

  @override
  void update(double dt) {
    position.y -= speed * dt;
    _swayTimer += dt;
    position.x += _swayAmp * _swayFreq * dt * cos(_swayFreq * _swayTimer * 2 * pi);
    if (_isFlashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) _isFlashing = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final displayColor = _isFlashing ? const Color(0xFFFF3B5C) : color;
    final center = Offset(radius, radius);

    // Shadow
    canvas.drawCircle(
      center.translate(3, 5),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    // Body gradient (drawn as two circles)
    canvas.drawCircle(center, radius, Paint()..color = displayColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.8,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            displayColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Shine highlight
    canvas.drawCircle(
      Offset(radius - radius * 0.32, radius - radius * 0.32),
      radius * 0.26,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // Knot at bottom
    canvas.drawCircle(
      Offset(radius, radius * 2 - 5),
      4,
      Paint()..color = displayColor.withValues(alpha: 0.85),
    );

    // String
    canvas.drawLine(
      Offset(radius, radius * 2 - 1),
      Offset(radius + 5, radius * 2 + 28),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.5,
    );

    // Number
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: number > 99 ? 15 : (number > 9 ? 20 : 22),
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(1, 1))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(radius - tp.width / 2, radius - tp.height / 2));
  }
}
