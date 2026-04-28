import 'package:equatable/equatable.dart';

/// Question type enumeration
enum QuestionType {
  tracing,        // Number/letter tracing
  counting,       // Count objects
  numberBond,     // Number bonds (part-whole)
  addition,       // Addition problems
  subtraction,    // Subtraction problems
  multiplication, // Multiplication problems
  division,       // Division problems
  fraction,       // Fraction operations
  decimal,        // Decimal operations
  percentage,     // Percentage problems
  negative,       // Negative number operations
  power,          // Powers and exponents
  squareRoot,     // Square roots
  polynomial,     // Polynomial operations
  factorization,  // Factorization problems
  geometry,       // Geometry problems
  mixed,          // Mixed operations
}

/// Represents a single question in a worksheet
class QuestionModel extends Equatable {
  final String id;
  final String worksheetId;
  final int questionNumber; // 1-100
  final int pageNumber;     // 1-10
  final QuestionType type;
  final String questionText;    // The math problem (e.g., "5 + 3 = ")
  final String correctAnswer;   // The expected answer
  final String? userAnswer;     // Child's first submission
  final String? correctedAnswer; // Answer after correction (if needed)
  final bool? isCorrect;        // null if not submitted
  final bool? isCorrected;      // Whether correction was done
  final String? handwritingData; // JSON string of ink strokes
  final DateTime? submittedAt;
  final DateTime? correctedAt;

  const QuestionModel({
    required this.id,
    required this.worksheetId,
    required this.questionNumber,
    required this.pageNumber,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    this.userAnswer,
    this.correctedAnswer,
    this.isCorrect,
    this.isCorrected,
    this.handwritingData,
    this.submittedAt,
    this.correctedAt,
  });

  /// Check if question needs correction
  bool get needsCorrection => isCorrect == false && isCorrected != true;

  /// Get display answer (corrected if available, otherwise user answer)
  String? get displayAnswer => correctedAnswer ?? userAnswer;

  /// Check if question has been answered
  bool get isAnswered => userAnswer != null;

  /// Create from JSON (Supabase response)
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      worksheetId: json['worksheet_id'] as String,
      questionNumber: json['question_number'] as int,
      pageNumber: json['page_number'] as int,
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.addition,
      ),
      questionText: json['question_text'] as String,
      correctAnswer: json['correct_answer'] as String,
      userAnswer: json['user_answer'] as String?,
      correctedAnswer: json['corrected_answer'] as String?,
      isCorrect: json['is_correct'] as bool?,
      isCorrected: json['is_corrected'] as bool?,
      handwritingData: json['handwriting_data'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      correctedAt: json['corrected_at'] != null
          ? DateTime.parse(json['corrected_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worksheet_id': worksheetId,
      'question_number': questionNumber,
      'page_number': pageNumber,
      'type': type.name,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'user_answer': userAnswer,
      'corrected_answer': correctedAnswer,
      'is_correct': isCorrect,
      'is_corrected': isCorrected,
      'handwriting_data': handwritingData,
      'submitted_at': submittedAt?.toIso8601String(),
      'corrected_at': correctedAt?.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  QuestionModel copyWith({
    String? id,
    String? worksheetId,
    int? questionNumber,
    int? pageNumber,
    QuestionType? type,
    String? questionText,
    String? correctAnswer,
    String? userAnswer,
    String? correctedAnswer,
    bool? isCorrect,
    bool? isCorrected,
    String? handwritingData,
    DateTime? submittedAt,
    DateTime? correctedAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      worksheetId: worksheetId ?? this.worksheetId,
      questionNumber: questionNumber ?? this.questionNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      type: type ?? this.type,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      correctedAnswer: correctedAnswer ?? this.correctedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      isCorrected: isCorrected ?? this.isCorrected,
      handwritingData: handwritingData ?? this.handwritingData,
      submittedAt: submittedAt ?? this.submittedAt,
      correctedAt: correctedAt ?? this.correctedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        worksheetId,
        questionNumber,
        pageNumber,
        type,
        questionText,
        correctAnswer,
        userAnswer,
        correctedAnswer,
        isCorrect,
        isCorrected,
        handwritingData,
        submittedAt,
        correctedAt,
      ];
}
