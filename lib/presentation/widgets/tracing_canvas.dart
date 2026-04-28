import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Types of tracing patterns
enum TracingPattern {
  horizontalLine,
  verticalLine,
  diagonalLine,
  zigzag,
  curve,
  wave,
  circle,
  spiral,
}

/// Canvas widget for tracing exercises (Levels 1-3)
class TracingCanvas extends StatefulWidget {
  final double height;
  final TracingPattern pattern;
  final bool enabled;
  final VoidCallback? onComplete;
  final int questionNumber;

  const TracingCanvas({
    super.key,
    this.height = 200,
    this.pattern = TracingPattern.horizontalLine,
    this.enabled = true,
    this.onComplete,
    this.questionNumber = 1,
  });

  @override
  State<TracingCanvas> createState() => TracingCanvasState();
}

class TracingCanvasState extends State<TracingCanvas> {
  final List<Offset> _userPoints = [];
  List<Offset> _guidePoints = [];
  bool _isComplete = false;
  double _accuracy = 0.0;
  bool _startedCorrectly = false;
  bool _showWrongStartWarning = false;

  @override
  void initState() {
    super.initState();
    _generateGuidePoints();
  }

  @override
  void didUpdateWidget(TracingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pattern != widget.pattern ||
        oldWidget.questionNumber != widget.questionNumber) {
      clear();
      _generateGuidePoints();
    }
  }

  void _generateGuidePoints() {
    // Will be generated in build after we have size
    _guidePoints = [];
  }

  List<Offset> _generatePatternPoints(Size size) {
    final points = <Offset>[];
    final padding = 30.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;
    final centerY = size.height / 2;
    final centerX = size.width / 2;

    // Use question number to vary the pattern
    final variation = widget.questionNumber % 5;

    switch (widget.pattern) {
      case TracingPattern.horizontalLine:
        // Straight horizontal line with slight variation based on question
        final yOffset = (variation - 2) * 15.0;
        for (double x = padding; x <= size.width - padding; x += 5) {
          points.add(Offset(x, centerY + yOffset));
        }
        break;

      case TracingPattern.verticalLine:
        final xOffset = (variation - 2) * 20.0;
        for (double y = padding; y <= size.height - padding; y += 5) {
          points.add(Offset(centerX + xOffset, y));
        }
        break;

      case TracingPattern.diagonalLine:
        final steps = 40;
        final isReverse = variation % 2 == 1;
        for (int i = 0; i <= steps; i++) {
          final t = i / steps;
          final x = padding + width * t;
          final y = isReverse
              ? padding + height * (1 - t)
              : padding + height * t;
          points.add(Offset(x, y));
        }
        break;

      case TracingPattern.zigzag:
        final segments = 3 + variation;
        final segmentWidth = width / segments;
        for (int seg = 0; seg <= segments; seg++) {
          final x = padding + seg * segmentWidth;
          final y = seg % 2 == 0 ? padding + 10 : size.height - padding - 10;
          points.add(Offset(x, y));
          // Add intermediate points for smooth drawing
          if (seg < segments) {
            final nextX = padding + (seg + 1) * segmentWidth;
            final nextY = (seg + 1) % 2 == 0 ? padding + 10 : size.height - padding - 10;
            for (double t = 0.1; t < 1.0; t += 0.1) {
              points.add(Offset(
                x + (nextX - x) * t,
                y + (nextY - y) * t,
              ));
            }
          }
        }
        break;

      case TracingPattern.curve:
        // S-curve or simple curve
        final isSCurve = variation % 2 == 0;
        for (double t = 0; t <= 1.0; t += 0.02) {
          final x = padding + width * t;
          double y;
          if (isSCurve) {
            y = centerY + sin(t * pi * 2) * (height * 0.3);
          } else {
            y = padding + height * (1 - pow(2 * t - 1, 2));
          }
          points.add(Offset(x, y));
        }
        break;

      case TracingPattern.wave:
        final waves = 2 + (variation % 3);
        for (double t = 0; t <= 1.0; t += 0.02) {
          final x = padding + width * t;
          final y = centerY + sin(t * pi * 2 * waves) * (height * 0.25);
          points.add(Offset(x, y));
        }
        break;

      case TracingPattern.circle:
        final radius = min(width, height) * 0.35;
        for (double angle = 0; angle <= 2 * pi; angle += 0.1) {
          final x = centerX + cos(angle) * radius;
          final y = centerY + sin(angle) * radius;
          points.add(Offset(x, y));
        }
        break;

      case TracingPattern.spiral:
        final maxRadius = min(width, height) * 0.4;
        final turns = 2 + variation * 0.5;
        for (double angle = 0; angle <= 2 * pi * turns; angle += 0.1) {
          final radius = maxRadius * (angle / (2 * pi * turns));
          final x = centerX + cos(angle) * radius;
          final y = centerY + sin(angle) * radius;
          points.add(Offset(x, y));
        }
        break;
    }

    return points;
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled || _isComplete) return;
    
    // Check if user started near the START dot
    if (_guidePoints.isNotEmpty && _userPoints.isEmpty) {
      final startPoint = _guidePoints.first;
      final distance = (startPoint - details.localPosition).distance;
      
      if (distance > 40) {
        // User started too far from START - show warning
        setState(() {
          _showWrongStartWarning = true;
        });
        // Hide warning after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showWrongStartWarning = false;
            });
          }
        });
        return; // Don't start tracing
      }
      _startedCorrectly = true;
    }
    
    setState(() {
      _userPoints.add(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _isComplete) return;
    setState(() {
      _userPoints.add(details.localPosition);
      _checkCompletion();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || _isComplete) return;
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_guidePoints.isEmpty || _userPoints.length < 10) return;
    if (!_startedCorrectly) return; // Must start from START dot

    // Calculate how many guide points are covered
    int coveredPoints = 0;
    const threshold = 25.0; // Distance threshold

    for (final guidePoint in _guidePoints) {
      for (final userPoint in _userPoints) {
        if ((guidePoint - userPoint).distance < threshold) {
          coveredPoints++;
          break;
        }
      }
    }

    _accuracy = coveredPoints / _guidePoints.length;

    // Check if user reached the END dot
    bool reachedEnd = false;
    if (_userPoints.isNotEmpty && _guidePoints.isNotEmpty) {
      final endPoint = _guidePoints.last;
      // Check last few user points to see if they're near the end
      for (int i = _userPoints.length - 1; i >= 0 && i >= _userPoints.length - 10; i--) {
        if ((endPoint - _userPoints[i]).distance < 35) {
          reachedEnd = true;
          break;
        }
      }
    }

    // Consider complete if 100% coverage AND reached end dot
    if (_accuracy >= 0.98 && reachedEnd && !_isComplete) {
      setState(() {
        _isComplete = true;
      });
      widget.onComplete?.call();
    }
  }

  void clear() {
    setState(() {
      _userPoints.clear();
      _isComplete = false;
      _accuracy = 0.0;
      _startedCorrectly = false;
      _showWrongStartWarning = false;
    });
  }

  bool get isComplete => _isComplete;
  double get accuracy => _accuracy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tracing area
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isComplete ? Colors.green : Colors.grey[300]!,
              width: _isComplete ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                if (_guidePoints.isEmpty) {
                  _guidePoints = _generatePatternPoints(size);
                }
                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: size,
                    painter: _TracingPainter(
                      guidePoints: _guidePoints,
                      userPoints: _userPoints,
                      isComplete: _isComplete,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Status and clear button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _showWrongStartWarning
                  ? Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Start from the START dot!',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _isComplete
                      ? Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Complete!',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _userPoints.isEmpty 
                              ? 'Trace from START to END'
                              : 'Progress: ${(_accuracy * 100).toInt()}% - finish at END',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
            ),
            TextButton.icon(
              onPressed: widget.enabled ? clear : null,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> userPoints;
  final bool isComplete;

  _TracingPainter({
    required this.guidePoints,
    required this.userPoints,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guide path (dotted line)
    if (guidePoints.isNotEmpty) {
      final guidePaint = Paint()
        ..color = isComplete ? Colors.green.withValues(alpha: 0.3) : Colors.grey[300]!
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final guidePath = Path();
      guidePath.moveTo(guidePoints.first.dx, guidePoints.first.dy);
      for (int i = 1; i < guidePoints.length; i++) {
        guidePath.lineTo(guidePoints[i].dx, guidePoints[i].dy);
      }
      canvas.drawPath(guidePath, guidePaint);

      // Draw START dot (green)
      final startDotPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(guidePoints.first, 14, startDotPaint);
      
      // Draw END dot (red)
      final endDotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(guidePoints.last, 14, endDotPaint);

      // Draw "START" label
      final startLabel = TextPainter(
        text: TextSpan(
          text: 'START',
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      startLabel.layout();
      startLabel.paint(
        canvas,
        Offset(guidePoints.first.dx - startLabel.width / 2, guidePoints.first.dy + 18),
      );
      
      // Draw "END" label
      final endLabel = TextPainter(
        text: TextSpan(
          text: 'END',
          style: TextStyle(
            color: Colors.red[700],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      endLabel.layout();
      endLabel.paint(
        canvas,
        Offset(guidePoints.last.dx - endLabel.width / 2, guidePoints.last.dy + 18),
      );
    }

    // Draw user's traced path
    if (userPoints.isNotEmpty) {
      final userPaint = Paint()
        ..color = isComplete ? Colors.green : AppColors.primary
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final userPath = Path();
      userPath.moveTo(userPoints.first.dx, userPoints.first.dy);
      for (int i = 1; i < userPoints.length; i++) {
        userPath.lineTo(userPoints[i].dx, userPoints[i].dy);
      }
      canvas.drawPath(userPath, userPaint);
    }
  }

  @override
  bool shouldRepaint(_TracingPainter oldDelegate) {
    return oldDelegate.userPoints.length != userPoints.length ||
        oldDelegate.isComplete != isComplete;
  }
}
