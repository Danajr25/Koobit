import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/handwriting_service.dart';

/// Canvas widget for handwriting input with real-time recognition
class HandwritingCanvas extends StatefulWidget {
  /// Callback when text is recognized
  final ValueChanged<String> onRecognized;
  
  /// Height of the canvas
  final double height;
  
  /// Whether the canvas is enabled
  final bool enabled;
  
  /// Current recognized text (for display)
  final String? recognizedText;

  /// Compact mode: skips the outer decoration and the
  /// recognized-text + clear-button controls row. Use when embedding the
  /// canvas inside another bordered container (e.g. an answer box).
  final bool compact;

  /// Hint text shown when the canvas is empty.
  final String? hintText;

  const HandwritingCanvas({
    super.key,
    required this.onRecognized,
    this.height = 200,
    this.enabled = true,
    this.recognizedText,
    this.compact = false,
    this.hintText,
  });

  @override
  State<HandwritingCanvas> createState() => HandwritingCanvasState();
}

/// State class for HandwritingCanvas
/// Made public so it can be accessed via GlobalKey for clearing
class HandwritingCanvasState extends State<HandwritingCanvas> {
  final HandwritingService _handwritingService = HandwritingService();
  final List<List<DrawPoint>> _strokes = [];
  List<DrawPoint> _currentStroke = [];
  
  bool _isInitializing = true;
  bool _isModelReady = false;
  bool _isRecognizing = false;
  String? _downloadStatus;
  Timer? _recognitionTimer;
  // ignore: unused_field - TODO: display error to user
  String? _initError;

  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid blocking the UI
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeService();
      }
    });
  }

  @override
  void dispose() {
    _recognitionTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeService() async {
    if (!mounted) return;
    
    setState(() {
      _isInitializing = true;
      _initError = null;
    });

    try {
      final isReady = await _handwritingService.initialize();
      
      if (!isReady && mounted) {
        // Try downloading model
        await _handwritingService.downloadModel(
          onProgress: (status) {
            if (mounted) {
              setState(() {
                _downloadStatus = status;
              });
            }
          },
        );
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isModelReady = _handwritingService.isReady;
        });
      }
    } catch (e) {
      debugPrint('HandwritingCanvas: Init error - $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isModelReady = false;
          _initError = e.toString();
        });
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled || !_isModelReady) return;

    _recognitionTimer?.cancel();
    
    setState(() {
      _currentStroke = [
        DrawPoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          t: DateTime.now().millisecondsSinceEpoch,
        ),
      ];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_isModelReady) return;

    setState(() {
      _currentStroke.add(
        DrawPoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          t: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || !_isModelReady) return;

    if (_currentStroke.isNotEmpty) {
      setState(() {
        _strokes.add(List.from(_currentStroke));
        _currentStroke = [];
      });

      // Debounce recognition - wait for user to finish writing
      _recognitionTimer?.cancel();
      _recognitionTimer = Timer(const Duration(milliseconds: 800), () {
        _performRecognition();
      });
    }
  }

  Future<void> _performRecognition() async {
    if (_strokes.isEmpty) return;

    setState(() {
      _isRecognizing = true;
    });

    final result = await _handwritingService.recognize(_strokes);
    
    if (mounted) {
      setState(() {
        _isRecognizing = false;
      });

      if (result != null) {
        widget.onRecognized(result);
      }
    }
  }

  void clear() {
    _recognitionTimer?.cancel();
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
    widget.onRecognized('');
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingState();
    }

    if (!_isModelReady) {
      return _buildModelDownloadState();
    }

    return _buildCanvas();
  }

  Widget _buildLoadingState() {
    if (widget.compact) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 12),
            Text(
              _downloadStatus ?? 'Initializing...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelDownloadState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_download_outlined,
              size: 48,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 12),
            Text(
              'Handwriting model required',
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to download (~20MB)',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeService,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    final canvasInner = ClipRRect(
      borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
      child: Stack(
        children: [
          // Drawing background with guide lines (skip in compact mode)
          if (!widget.compact)
            CustomPaint(
              size: Size.infinite,
              painter: _GuideLinesPainter(),
            ),
          // Drawing area
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              size: Size.infinite,
              painter: _StrokePainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
              ),
            ),
          ),
          // Hint text when empty
          if (_strokes.isEmpty && _currentStroke.isEmpty)
            IgnorePointer(
              child: Center(
                child: Text(
                  widget.hintText ?? 'Write your answer here',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: widget.compact ? 14 : 18,
                  ),
                ),
              ),
            ),
          // Recognition indicator
          if (_isRecognizing)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.compact) {
      // Borderless: parent provides the box decoration
      return SizedBox(height: widget.height, child: canvasInner);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Canvas
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.enabled ? Colors.blue[300]! : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: canvasInner,
        ),
        const SizedBox(height: 8),
        // Controls row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Recognition result
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Recognized: ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.recognizedText ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Clear button
            IconButton(
              onPressed: clear,
              icon: const Icon(Icons.clear),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
              ),
              tooltip: 'Clear',
            ),
          ],
        ),
      ],
    );
  }
}

/// Painter for guide lines on the canvas
class _GuideLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    // Horizontal guide lines
    final lineSpacing = size.height / 4;
    for (int i = 1; i < 4; i++) {
      final y = lineSpacing * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for drawing strokes
class _StrokePainter extends CustomPainter {
  final List<List<DrawPoint>> strokes;
  final List<DrawPoint> currentStroke;

  _StrokePainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[800]!
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<DrawPoint> points, Paint paint) {
    if (points.length < 2) {
      if (points.isNotEmpty) {
        canvas.drawCircle(
          Offset(points[0].x, points[0].y),
          paint.strokeWidth / 2,
          paint,
        );
      }
      return;
    }

    final path = Path();
    path.moveTo(points[0].x, points[0].y);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}
