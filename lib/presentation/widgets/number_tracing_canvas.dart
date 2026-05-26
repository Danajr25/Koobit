import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Canvas widget for number tracing exercises (Levels 3, 5, 7)
class NumberTracingCanvas extends StatefulWidget {
  final double height;
  final int numberToTrace;
  final bool enabled;
  final VoidCallback? onComplete;

  const NumberTracingCanvas({
    super.key,
    this.height = 200,
    required this.numberToTrace,
    this.enabled = true,
    this.onComplete,
  });

  @override
  State<NumberTracingCanvas> createState() => NumberTracingCanvasState();
}

class NumberTracingCanvasState extends State<NumberTracingCanvas> {
  final List<Offset> _userPoints = [];
  List<Offset> _guidePoints = [];
  bool _isComplete = false;
  double _accuracy = 0.0;
  bool _startedCorrectly = false;
  bool _showWrongStartWarning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(NumberTracingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numberToTrace != widget.numberToTrace) {
      clear();
      _guidePoints = [];
    }
  }

  List<Offset> _generateNumberPoints(Size size, int number) {
    final points = <Offset>[];
    final w = size.width;
    final h = size.height;
    final cx = w / 2;  // center X
    final cy = h / 2;  // center Y
    
    // Bounds
    final top = h * 0.1;
    final bottom = h * 0.9;
    final left = w * 0.25;
    final right = w * 0.75;
    final height = bottom - top;
    // ignore: unused_local_variable
    final width = right - left;

    switch (number) {
      case 1:
        // "1" - small serif at top, then straight down
        points.add(Offset(cx - 15, top + 20));
        for (double y = top; y <= bottom; y += 3) {
          points.add(Offset(cx, y));
        }
        break;

      case 2:
        // "2" - start top-left, curve over, diagonal down, horizontal bottom
        // Single continuous stroke
        for (double t = 0; t <= 1.0; t += 0.03) {
          final angle = pi * (1.0 - t);  // from pi to 0
          final x = cx + cos(angle) * 35;
          final y = top + 45 - sin(angle) * 30;
          points.add(Offset(x, y));
        }
        // Diagonal to bottom-left
        for (double t = 0; t <= 1.0; t += 0.03) {
          points.add(Offset(
            cx + 35 - 70 * t,
            top + 45 + (bottom - top - 45) * t,
          ));
        }
        // Horizontal at bottom
        for (double x = left; x <= right; x += 3) {
          points.add(Offset(x, bottom));
        }
        break;

      case 3:
        // "3" - two bumps, continuous C shapes
        // Top bump - arc from upper-left to middle
        for (double t = 0; t <= 1.0; t += 0.04) {
          final angle = pi * 0.7 - t * 1.2 * pi;
          final x = cx - 5 + cos(angle) * 38;
          final y = top + height * 0.28 + sin(angle) * 32;
          points.add(Offset(x, y));
        }
        // Bottom bump - arc from middle to lower-left  
        for (double t = 0; t <= 1.0; t += 0.04) {
          final angle = pi * 0.5 - t * 1.3 * pi;
          final x = cx - 5 + cos(angle) * 42;
          final y = bottom - height * 0.28 + sin(angle) * 36;
          points.add(Offset(x, y));
        }
        break;

      case 4:
        // "4" - down diagonal, horizontal, then vertical stroke
        final crossY = cy + 10;
        // Start top-right, diagonal to mid-left
        for (double t = 0; t <= 1.0; t += 0.03) {
          points.add(Offset(
            right - (right - left) * t,
            top + (crossY - top) * t,
          ));
        }
        // Horizontal across
        for (double x = left; x <= right; x += 3) {
          points.add(Offset(x, crossY));
        }
        // Vertical from top to bottom (on right side)
        for (double y = top; y <= bottom; y += 3) {
          points.add(Offset(right - 5, y));
        }
        break;

      case 5:
        // "5" - top horizontal, down, then curved belly
        // Top line (right to left)
        for (double x = right; x >= left; x -= 3) {
          points.add(Offset(x, top));
        }
        // Down stroke
        for (double y = top; y <= cy - 10; y += 3) {
          points.add(Offset(left, y));
        }
        // Belly curve - connect smoothly from left side
        for (double t = 0; t <= 1.0; t += 0.04) {
          final angle = pi * 0.5 - t * pi * 1.2;
          final x = cx + cos(angle) * 40;
          final y = cy + 30 + sin(angle) * 38;
          points.add(Offset(x, y));
        }
        break;

      case 6:
        // "6" - single continuous stroke: curved tail from top into circle
        // Start at top-right, curve down into a circle
        // Spiral down from top
        for (double t = 0; t <= 1.0; t += 0.025) {
          final angle = -pi * 0.3 + t * pi * 1.8;
          final radius = 25 + t * 20;
          final x = cx + cos(angle) * radius;
          final y = top + 20 + t * (cy - top);
          points.add(Offset(x.clamp(left - 10, right + 10), y));
        }
        // Continue into bottom circle (complete the loop)
        final circleR = 42.0;
        final circleY = bottom - circleR - 10;
        for (double t = 0; t <= 1.0; t += 0.03) {
          final angle = pi * 0.5 + t * 2 * pi;
          points.add(Offset(cx + cos(angle) * circleR, circleY + sin(angle) * circleR));
        }
        break;

      case 7:
        // "7" - simple: horizontal then diagonal
        for (double x = left; x <= right; x += 3) {
          points.add(Offset(x, top));
        }
        for (double t = 0; t <= 1.0; t += 0.025) {
          points.add(Offset(
            right - (right - cx) * t,
            top + (bottom - top) * t,
          ));
        }
        break;

      case 8:
        // "8" - single stroke figure-8 (continuous S curve connecting two loops)
        // Start at center, go up and around top loop, cross at middle, bottom loop
        final topY = top + height * 0.28;
        final bottomY = bottom - height * 0.28;
        final r1 = 30.0;  // top radius
        final r2 = 35.0;  // bottom radius
        
        // Top loop (clockwise from center-bottom of top circle)
        for (double t = 0; t <= 1.0; t += 0.03) {
          final angle = pi * 0.5 + t * 2 * pi;
          points.add(Offset(cx + cos(angle) * r1, topY + sin(angle) * r1));
        }
        // Cross to bottom loop and complete it (clockwise)
        for (double t = 0; t <= 1.0; t += 0.03) {
          final angle = -pi * 0.5 + t * 2 * pi;
          points.add(Offset(cx + cos(angle) * r2, bottomY + sin(angle) * r2));
        }
        break;

      case 9:
        // "9" - top circle then straight tail down
        final circleY = top + 55;
        final circleR = 40.0;
        // Circle (start from right, go counter-clockwise)
        for (double t = 0; t <= 1.0; t += 0.03) {
          final angle = 0 - t * 2 * pi;
          points.add(Offset(cx + cos(angle) * circleR, circleY + sin(angle) * circleR));
        }
        // Tail straight down (from right side of circle)
        for (double y = circleY; y <= bottom; y += 3) {
          points.add(Offset(cx + circleR, y));
        }
        break;

      case 10:
        // "10" - "1" then "0" as separate but sequential traces
        final oneX = cx - 45;
        final zeroX = cx + 30;
        
        // "1"
        points.add(Offset(oneX - 12, top + 18));
        for (double y = top; y <= bottom; y += 3) {
          points.add(Offset(oneX, y));
        }
        // "0" - oval (start from left, go counter-clockwise)
        for (double t = 0; t <= 1.0; t += 0.03) {
          final angle = pi - t * 2 * pi;
          final rx = 28.0;
          final ry = height * 0.4;
          points.add(Offset(zeroX + cos(angle) * rx, cy + sin(angle) * ry));
        }
        break;

      default:
        for (double a = 0; a <= pi * 2; a += 0.1) {
          points.add(Offset(cx + cos(a) * 40, cy + sin(a) * 40));
        }
    }

    return points;
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled || _isComplete) return;
    
    // Check if user started near the START point
    if (_guidePoints.isNotEmpty && _userPoints.isEmpty) {
      final startPoint = _guidePoints.first;
      final distance = (startPoint - details.localPosition).distance;
      
      if (distance > 50) {
        // User started too far from START
        setState(() {
          _showWrongStartWarning = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showWrongStartWarning = false;
            });
          }
        });
        return;
      }
      _startedCorrectly = true;
    }
    
    setState(() {
      _userPoints.add(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _isComplete) return;
    if (!_startedCorrectly && _userPoints.isEmpty) return;
    
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
    if (!_startedCorrectly) return;

    int coveredPoints = 0;
    const threshold = 35.0; // Increased tolerance for easier completion

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
      // Check if any of the last 20 user points are near the END
      for (int i = _userPoints.length - 1; i >= 0 && i >= _userPoints.length - 20; i--) {
        if ((endPoint - _userPoints[i]).distance < 45) {
          reachedEnd = true;
          break;
        }
      }
    }

    // Numbers need 85% coverage AND must reach end
    if (_accuracy >= 0.85 && reachedEnd && !_isComplete) {
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
        // Number display header
        Text(
          'Trace the number: ${widget.numberToTrace}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
                  _guidePoints = _generateNumberPoints(size, widget.numberToTrace);
                }
                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: size,
                    painter: _NumberTracingPainter(
                      guidePoints: _guidePoints,
                      userPoints: _userPoints,
                      isComplete: _isComplete,
                      number: widget.numberToTrace,
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
                            'Start from the green START dot!',
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
                              'Great job!',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _userPoints.isEmpty
                              ? 'Trace from green START to red END'
                              : 'Progress: ${(_accuracy * 100).toInt()}% - finish at red dot',
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

class _NumberTracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> userPoints;
  final bool isComplete;
  final int number;

  _NumberTracingPainter({
    required this.guidePoints,
    required this.userPoints,
    required this.isComplete,
    required this.number,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guide as the actual numeral glyph (rendered as text) for a clean,
    // readable shape rather than hand-built point lists.
    if (guidePoints.isNotEmpty) {
      final numText = number == 10 ? '10' : '$number';
      final glyphHeight = size.height * 0.85;
      final fontSize = glyphHeight; // text height ~= font size
      final glyphPainter = TextPainter(
        text: TextSpan(
          text: numText,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: isComplete
                ? Colors.green.withValues(alpha: 0.30)
                : Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      glyphPainter.paint(
        canvas,
        Offset(
          (size.width - glyphPainter.width) / 2,
          (size.height - glyphPainter.height) / 2,
        ),
      );

      // Draw START dot (green)
      final startDotPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(guidePoints.first, 14, startDotPaint);

      // Draw END dot (red)
      final endDotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(guidePoints.last, 10, endDotPaint);

      // START label
      final startLabel = TextPainter(
        text: TextSpan(
          text: 'START',
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 9,
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
      
      // END label
      final endLabel = TextPainter(
        text: TextSpan(
          text: 'END',
          style: TextStyle(
            color: Colors.red[700],
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      endLabel.layout();
      endLabel.paint(
        canvas,
        Offset(guidePoints.last.dx - endLabel.width / 2, guidePoints.last.dy + 14),
      );
    }

    // Draw user's traced path
    if (userPoints.isNotEmpty) {
      final userPaint = Paint()
        ..color = isComplete ? Colors.green : AppColors.primary
        ..strokeWidth = 8
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
  bool shouldRepaint(_NumberTracingPainter oldDelegate) {
    return oldDelegate.userPoints.length != userPoints.length ||
        oldDelegate.isComplete != isComplete ||
        oldDelegate.number != number;
  }
}
