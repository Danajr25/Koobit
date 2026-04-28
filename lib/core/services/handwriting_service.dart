import 'package:flutter/foundation.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

/// Service for handwriting recognition using Google ML Kit Digital Ink
class HandwritingService {
  static final HandwritingService _instance = HandwritingService._internal();
  factory HandwritingService() => _instance;
  HandwritingService._internal();

  DigitalInkRecognizer? _recognizer;
  final DigitalInkRecognizerModelManager _modelManager = 
      DigitalInkRecognizerModelManager();
  
  bool _isModelDownloaded = false;
  bool _isInitializing = false;
  
  /// Language code for handwriting recognition
  /// Using 'en' for English which handles digits and basic math symbols
  static const String _languageTag = 'en';

  /// Check if the model is ready for recognition
  bool get isReady => _isModelDownloaded && _recognizer != null;

  /// Initialize the handwriting recognition service
  Future<bool> initialize() async {
    if (_isInitializing) return false;
    if (isReady) return true;

    _isInitializing = true;
    
    try {
      // Check if model is already downloaded
      _isModelDownloaded = await _modelManager.isModelDownloaded(_languageTag);
      
      if (!_isModelDownloaded) {
        debugPrint('HandwritingService: Downloading model for $_languageTag...');
        _isModelDownloaded = await _modelManager.downloadModel(_languageTag);
        
        if (!_isModelDownloaded) {
          debugPrint('HandwritingService: Failed to download model');
          _isInitializing = false;
          return false;
        }
        debugPrint('HandwritingService: Model downloaded successfully');
      }

      // Create recognizer
      _recognizer = DigitalInkRecognizer(languageCode: _languageTag);
      
      debugPrint('HandwritingService: Initialized successfully');
      _isInitializing = false;
      return true;
    } catch (e) {
      debugPrint('HandwritingService: Error initializing - $e');
      _isInitializing = false;
      return false;
    }
  }

  /// Check if model is downloaded (for showing download UI)
  Future<bool> checkModelDownloaded() async {
    return await _modelManager.isModelDownloaded(_languageTag);
  }

  /// Download the model if not already downloaded
  Future<bool> downloadModel({Function(String)? onProgress}) async {
    try {
      onProgress?.call('Checking model...');
      
      if (await _modelManager.isModelDownloaded(_languageTag)) {
        _isModelDownloaded = true;
        onProgress?.call('Model ready');
        return true;
      }

      onProgress?.call('Downloading handwriting model...');
      _isModelDownloaded = await _modelManager.downloadModel(_languageTag);
      
      if (_isModelDownloaded) {
        onProgress?.call('Model downloaded');
      } else {
        onProgress?.call('Download failed');
      }
      
      return _isModelDownloaded;
    } catch (e) {
      debugPrint('HandwritingService: Download error - $e');
      onProgress?.call('Download error');
      return false;
    }
  }

  /// Recognize handwriting from a list of strokes
  /// Each stroke is a list of points with timestamps
  Future<String?> recognize(List<List<DrawPoint>> strokes) async {
    if (!isReady) {
      debugPrint('HandwritingService: Not ready for recognition');
      final initialized = await initialize();
      if (!initialized) return null;
    }

    if (strokes.isEmpty) return null;

    try {
      // Convert strokes to ML Kit format
      final ink = Ink();
      
      for (final strokePoints in strokes) {
        final stroke = Stroke();
        for (final point in strokePoints) {
          stroke.points.add(StrokePoint(
            x: point.x,
            y: point.y,
            t: point.t,
          ));
        }
        ink.strokes.add(stroke);
      }

      // Perform recognition
      final results = await _recognizer!.recognize(ink);
      
      if (results.isEmpty) {
        debugPrint('HandwritingService: No recognition results');
        return null;
      }

      // Return best candidate
      final bestResult = results.first.text;
      debugPrint('HandwritingService: Recognized as "$bestResult"');
      
      // Post-process for math answers
      return _postProcessResult(bestResult);
    } catch (e) {
      debugPrint('HandwritingService: Recognition error - $e');
      return null;
    }
  }

  /// Post-process recognition result for math answers
  String _postProcessResult(String result) {
    // Clean up the result
    String cleaned = result.trim();
    
    // Handle common misrecognitions for numbers
    cleaned = cleaned
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('l', '1')
        .replaceAll('I', '1')
        .replaceAll('S', '5')
        .replaceAll('s', '5')
        .replaceAll('Z', '2')
        .replaceAll('z', '2')
        .replaceAll('B', '8');
    
    // Handle math operators
    cleaned = cleaned
        .replaceAll('x', '×')
        .replaceAll('X', '×')
        .replaceAll('*', '×');
    
    return cleaned;
  }

  /// Clean up resources
  void dispose() {
    _recognizer?.close();
    _recognizer = null;
    _isModelDownloaded = false;
  }
}

/// Data class for a stroke point with coordinates and timestamp
class DrawPoint {
  final double x;
  final double y;
  final int t; // timestamp in milliseconds

  DrawPoint({
    required this.x,
    required this.y,
    required this.t,
  });
}
