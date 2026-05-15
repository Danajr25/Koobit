import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../data/models/question_model.dart';
import '../constants/level_config.dart';

/// Question generator service for creating math questions
class QuestionGenerator {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  /// Generate questions for a specific level and worksheet
  List<QuestionModel> generateQuestions({
    required int levelNumber,
    required String worksheetId,
    int count = 20,
  }) {
    final levelConfig = LevelConfiguration.getLevel(levelNumber);
    if (levelConfig == null) {
      throw Exception('Level $levelNumber not found');
    }

    final questions = <QuestionModel>[];
    for (int i = 0; i < count; i++) {
      questions.add(_generateQuestion(
        config: levelConfig,
        worksheetId: worksheetId,
        questionNumber: i + 1,
        pageNumber: (i ~/ 10) + 1, // 10 questions per page
      ));
    }
    return questions;
  }

  QuestionModel _generateQuestion({
    required LevelConfig config,
    required String worksheetId,
    required int questionNumber,
    required int pageNumber,
  }) {
    switch (config.type) {
      case LevelType.tracing:
        return _generateTracingQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.numberWriting:
        return _generateNumberWritingQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.sequences:
        return _generateSequenceQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.addition:
        return _generateAdditionQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.subtraction:
        return _generateSubtractionQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.multiplication:
        return _generateMultiplicationQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.division:
        return _generateDivisionQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.fractions:
        return _generateFractionQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.algebra:
        return _generateAlgebraQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.signedNumbers:
        return _generateSignedNumberQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.inequalities:
        return _generateInequalityQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.powers:
        return _generatePowerQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.roots:
        return _generateRootQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.monomials:
        return _generateMonomialQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.polynomials:
        return _generatePolynomialQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.factorization:
        return _generateFactorizationQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.quadratic:
        return _generateQuadraticQuestion(config, worksheetId, questionNumber, pageNumber);
      case LevelType.pythagorean:
        return _generatePythagoreanQuestion(config, worksheetId, questionNumber, pageNumber);
    }
  }

  // ===== TRACING QUESTIONS (Levels 1-3, 5, 7) =====
  QuestionModel _generateTracingQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    String questionText;
    String correctAnswer;

    switch (config.level) {
      case 1: // Line tracing
        questionText = 'Trace the line';
        correctAnswer = 'line';
        break;
      case 2: // Curve tracing
        questionText = 'Trace the curve';
        correctAnswer = 'curve';
        break;
      case 3: // Number tracing 1-10
        final number = (questionNumber % 10) + 1;
        questionText = 'Trace: $number';
        correctAnswer = number.toString();
        break;
      case 5: // Number tracing 11-50
        final number = 10 + _random.nextInt(40) + 1;
        questionText = 'Trace: $number';
        correctAnswer = number.toString();
        break;
      case 7: // Number tracing 51-100
        final number = 50 + _random.nextInt(50) + 1;
        questionText = 'Trace: $number';
        correctAnswer = number.toString();
        break;
      default:
        questionText = 'Trace';
        correctAnswer = '';
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.tracing,
      questionText: questionText,
      correctAnswer: correctAnswer,
    );
  }

  // ===== NUMBER WRITING QUESTIONS (Levels 4, 6, 8) =====
  QuestionModel _generateNumberWritingQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    int number;
    switch (config.level) {
      case 4: // 1-10
        number = (questionNumber % 10) + 1;
        break;
      case 6: // 11-50
        number = 10 + _random.nextInt(40) + 1;
        break;
      case 8: // 51-100
        number = 50 + _random.nextInt(50) + 1;
        break;
      default:
        number = _random.nextInt(100) + 1;
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.tracing, // Use tracing for number writing
      questionText: 'Write: $number',
      correctAnswer: number.toString(),
    );
  }

  // ===== SEQUENCE QUESTIONS (Level 9) =====
  QuestionModel _generateSequenceQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final start = _random.nextInt(90) + 1;
    final step = _random.nextInt(3) + 1; // Step of 1, 2, or 3
    final sequenceLength = 5;
    final missingIndex = _random.nextInt(sequenceLength);
    
    final sequence = List.generate(sequenceLength, (i) => start + (step * i));
    final missingValue = sequence[missingIndex];
    
    final displaySequence = sequence.map((n) {
      return n == missingValue ? '?' : n.toString();
    }).join(', ');

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.counting, // Use counting for sequences
      questionText: displaySequence,
      correctAnswer: missingValue.toString(),
    );
  }

  // ===== ADDITION QUESTIONS (Levels 10-13) =====
  QuestionModel _generateAdditionQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    int a, b;
    
    switch (config.level) {
      case 10: // +1, +2
        a = _random.nextInt(9) + 1;
        b = _random.nextInt(2) + 1;
        break;
      case 11: // +3 to +5
        a = _random.nextInt(9) + 1;
        b = _random.nextInt(3) + 3;
        break;
      case 12: // +6 to +9
        a = _random.nextInt(9) + 1;
        b = _random.nextInt(4) + 6;
        break;
      case 13: // 2-digit
        a = _random.nextInt(90) + 10;
        b = _random.nextInt(90) + 10;
        break;
      default:
        a = _random.nextInt(10);
        b = _random.nextInt(10);
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.addition,
      questionText: '$a + $b = ',
      correctAnswer: (a + b).toString(),
    );
  }

  // ===== SUBTRACTION QUESTIONS (Levels 14-16) =====
  QuestionModel _generateSubtractionQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    int a, b;
    
    switch (config.level) {
      case 14: // -1 to -5
        b = _random.nextInt(5) + 1;
        a = b + _random.nextInt(10);
        break;
      case 15: // -6 to -9
        b = _random.nextInt(4) + 6;
        a = b + _random.nextInt(10);
        break;
      case 16: // 2-digit
        a = _random.nextInt(90) + 10;
        b = _random.nextInt(a - 10) + 1;
        break;
      default:
        b = _random.nextInt(10);
        a = b + _random.nextInt(10);
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.subtraction,
      questionText: '$a - $b = ',
      correctAnswer: (a - b).toString(),
    );
  }

  // ===== MULTIPLICATION QUESTIONS (Levels 17-18) =====
  QuestionModel _generateMultiplicationQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    int a, b;
    
    switch (config.level) {
      case 17: // ×1 to ×5
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(5) + 1;
        break;
      case 18: // ×6 to ×12
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(7) + 6;
        break;
      default:
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(10) + 1;
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.multiplication,
      questionText: '$a × $b = ',
      correctAnswer: (a * b).toString(),
    );
  }

  // ===== DIVISION QUESTIONS (Levels 19-20) =====
  QuestionModel _generateDivisionQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    int divisor, quotient, dividend;
    
    switch (config.level) {
      case 19: // ÷1 to ÷5
        divisor = _random.nextInt(5) + 1;
        quotient = _random.nextInt(10) + 1;
        dividend = divisor * quotient;
        break;
      case 20: // ÷6 to ÷12
        divisor = _random.nextInt(7) + 6;
        quotient = _random.nextInt(10) + 1;
        dividend = divisor * quotient;
        break;
      default:
        divisor = _random.nextInt(10) + 1;
        quotient = _random.nextInt(10) + 1;
        dividend = divisor * quotient;
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.division,
      questionText: '$dividend ÷ $divisor = ',
      correctAnswer: quotient.toString(),
    );
  }

  // ===== FRACTION QUESTIONS (Levels 21-22) =====
  QuestionModel _generateFractionQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    switch (config.level) {
      case 21: // Basic fractions
        final numerator = _random.nextInt(9) + 1;
        final denominator = _random.nextInt(9) + 2;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.fraction,
          questionText: 'Simplify: $numerator/$denominator',
          correctAnswer: _simplifyFraction(numerator, denominator),
        );
      case 22: // Fraction operations
        final n1 = _random.nextInt(4) + 1;
        final d1 = _random.nextInt(4) + 2;
        final n2 = _random.nextInt(4) + 1;
        final d2 = d1; // Same denominator for simplicity
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.fraction,
          questionText: '$n1/$d1 + $n2/$d2 = ',
          correctAnswer: _simplifyFraction(n1 + n2, d1),
        );
      default:
        return _generateBasicFractionQuestion(config, worksheetId, questionNumber, pageNumber);
    }
  }

  String _simplifyFraction(int numerator, int denominator) {
    final gcd = _gcd(numerator, denominator);
    final simplifiedNum = numerator ~/ gcd;
    final simplifiedDen = denominator ~/ gcd;
    if (simplifiedDen == 1) return simplifiedNum.toString();
    return '$simplifiedNum/$simplifiedDen';
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  QuestionModel _generateBasicFractionQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final numerator = _random.nextInt(5) + 1;
    final denominator = _random.nextInt(5) + 2;
    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.fraction,
      questionText: 'What fraction is shaded? $numerator/$denominator',
      correctAnswer: '$numerator/$denominator',
    );
  }

  // ===== ALGEBRA QUESTIONS (Levels 23-32) =====
  QuestionModel _generateAlgebraQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    switch (config.level) {
      case 23: // Intro to variables
        final a = _random.nextInt(10) + 1;
        final b = _random.nextInt(10) + 1;
        final c = a + b;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.polynomial,
          questionText: 'x + $b = $c, x = ',
          correctAnswer: a.toString(),
        );
      case 24: // Linear equations basic
        final x = _random.nextInt(10) + 1;
        final b = _random.nextInt(10) + 1;
        final ops = ['+', '-', '×', '÷'];
        final op = ops[_random.nextInt(4)];
        String question;
        String answer = x.toString();
        switch (op) {
          case '+':
            question = 'x + $b = ${x + b}';
            break;
          case '-':
            question = 'x - $b = ${x - b}';
            break;
          case '×':
            question = '${b}x = ${x * b}';
            break;
          case '÷':
            question = 'x ÷ $b = ${x ~/ b}';
            answer = (x ~/ b * b).toString();
            break;
          default:
            question = 'x + $b = ${x + b}';
        }
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.polynomial,
          questionText: '$question, x = ',
          correctAnswer: answer,
        );
      case 25: // Multi-step
        final x = _random.nextInt(5) + 1;
        final a = _random.nextInt(5) + 2;
        final b = _random.nextInt(10) + 1;
        final result = a * x + b;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.polynomial,
          questionText: '${a}x + $b = $result, x = ',
          correctAnswer: x.toString(),
        );
      default:
        return _generateLinearEquation(config, worksheetId, questionNumber, pageNumber);
    }
  }

  QuestionModel _generateLinearEquation(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final x = _random.nextInt(10) + 1;
    final a = _random.nextInt(5) + 1;
    final b = _random.nextInt(10);
    final result = a * x + b;
    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.polynomial,
      questionText: '${a}x + $b = $result, x = ',
      correctAnswer: x.toString(),
    );
  }

  // ===== SIGNED NUMBER QUESTIONS (Levels 33-36) =====
  QuestionModel _generateSignedNumberQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final a = _random.nextInt(20) - 10;
    final b = _random.nextInt(20) - 10;
    String question;
    int answer;

    switch (config.level) {
      case 33: // Add/subtract
        if (_random.nextBool()) {
          question = '($a) + ($b)';
          answer = a + b;
        } else {
          question = '($a) - ($b)';
          answer = a - b;
        }
        break;
      case 34: // Multiply
        question = '($a) × ($b)';
        answer = a * b;
        break;
      case 35: // Divide
        final divisor = _random.nextInt(9) + 1;
        if (_random.nextBool()) {
          final dividend = divisor * (_random.nextInt(10) + 1);
          question = '($dividend) ÷ ($divisor)';
          answer = dividend ~/ divisor;
        } else {
          final dividend = -divisor * (_random.nextInt(10) + 1);
          question = '($dividend) ÷ ($divisor)';
          answer = dividend ~/ divisor;
        }
        break;
      case 36: // Combined
        final c = _random.nextInt(10) - 5;
        question = '($a) + ($b) - ($c)';
        answer = a + b - c;
        break;
      default:
        question = '($a) + ($b)';
        answer = a + b;
    }

    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.negative,
      questionText: '$question = ',
      correctAnswer: answer.toString(),
    );
  }

  // ===== INEQUALITY QUESTIONS (Level 37) =====
  QuestionModel _generateInequalityQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final x = _random.nextInt(10) + 1;
    final b = _random.nextInt(10);
    final operators = ['>', '<', '≥', '≤'];
    final op = operators[_random.nextInt(4)];
    
    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.polynomial,
      questionText: 'Solve: x + $b $op ${x + b + 1}',
      correctAnswer: 'x $op ${1}',
    );
  }

  // ===== POWER QUESTIONS (Levels 38, 40, 42) =====
  QuestionModel _generatePowerQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    switch (config.level) {
      case 38: // Powers of 2
        final base = _random.nextInt(10) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.power,
          questionText: '$base² = ',
          correctAnswer: (base * base).toString(),
        );
      case 40: // Powers of 3
        final base = _random.nextInt(5) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.power,
          questionText: '$base³ = ',
          correctAnswer: (base * base * base).toString(),
        );
      case 42: // Index laws
        final base = _random.nextInt(5) + 2;
        final exp1 = _random.nextInt(3) + 1;
        final exp2 = _random.nextInt(3) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.power,
          questionText: '$base^$exp1 × $base^$exp2 = $base^',
          correctAnswer: (exp1 + exp2).toString(),
        );
      default:
        final base = _random.nextInt(10) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.power,
          questionText: '$base² = ',
          correctAnswer: (base * base).toString(),
        );
    }
  }

  // ===== ROOT QUESTIONS (Levels 39, 41) =====
  QuestionModel _generateRootQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    switch (config.level) {
      case 39: // Square roots
        final perfectSquares = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100];
        final value = perfectSquares[_random.nextInt(perfectSquares.length)];
        final root = sqrt(value.toDouble()).toInt();
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.squareRoot,
          questionText: '√$value = ',
          correctAnswer: root.toString(),
        );
      case 41: // Cube roots
        final perfectCubes = [1, 8, 27, 64, 125];
        final value = perfectCubes[_random.nextInt(perfectCubes.length)];
        final root = pow(value.toDouble(), 1 / 3).round();
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.squareRoot,
          questionText: '∛$value = ',
          correctAnswer: root.toString(),
        );
      default:
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.squareRoot,
          questionText: '√4 = ',
          correctAnswer: '2',
        );
    }
  }

  // ===== MONOMIAL QUESTIONS (Level 43) =====
  QuestionModel _generateMonomialQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final coefficients = [2, 3, 4, 5];
    final a = coefficients[_random.nextInt(coefficients.length)];
    final b = coefficients[_random.nextInt(coefficients.length)];
    
    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.polynomial,
      questionText: '${a}x + ${b}x = ',
      correctAnswer: '${a + b}x',
    );
  }

  // ===== POLYNOMIAL QUESTIONS (Levels 44-45) =====
  QuestionModel _generatePolynomialQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    switch (config.level) {
      case 44:
        final b = _random.nextInt(5) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.polynomial,
          questionText: 'Expand: x(x + $b)',
          correctAnswer: 'x² + ${b}x',
        );
      case 45:
        final a = _random.nextInt(5) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.polynomial,
          questionText: '(x + $a)² = ',
          correctAnswer: 'x² + ${2 * a}x + ${a * a}',
        );
      default:
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.polynomial,
          questionText: 'x + x = ',
          correctAnswer: '2x',
        );
    }
  }

  // ===== FACTORIZATION QUESTIONS (Levels 46-53) =====
  QuestionModel _generateFactorizationQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    switch (config.level) {
      case 46: // GCF
        final gcf = _random.nextInt(5) + 2;
        final a = gcf * (_random.nextInt(5) + 1);
        final b = gcf * (_random.nextInt(5) + 1);
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.factorization,
          questionText: 'Factor: ${a}x + $b',
          correctAnswer: '$gcf(${a ~/ gcf}x + ${b ~/ gcf})',
        );
      case 47: // Simple trinomials
        final p = _random.nextInt(5) + 1;
        final q = _random.nextInt(5) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.factorization,
          questionText: 'Factor: x² + ${p + q}x + ${p * q}',
          correctAnswer: '(x + $p)(x + $q)',
        );
      case 49: // Difference of squares
        final a = _random.nextInt(5) + 1;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.factorization,
          questionText: 'Factor: x² - ${a * a}',
          correctAnswer: '(x + $a)(x - $a)',
        );
      default:
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.factorization,
          questionText: 'Factor: 2x + 4',
          correctAnswer: '2(x + 2)',
        );
    }
  }

  // ===== QUADRATIC QUESTIONS (Level 54+) =====
  QuestionModel _generateQuadraticQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    final p = _random.nextInt(5) + 1;
    final q = _random.nextInt(5) + 1;
    return QuestionModel(
      id: _uuid.v4(),
      worksheetId: worksheetId,
      questionNumber: questionNumber,
      pageNumber: pageNumber,
      type: QuestionType.factorization,
      questionText: 'Solve: x² - ${p + q}x + ${p * q} = 0',
      correctAnswer: 'x = $p or x = $q',
    );
  }

  // ===== PYTHAGOREAN QUESTIONS (Levels 57-62) =====
  QuestionModel _generatePythagoreanQuestion(
    LevelConfig config,
    String worksheetId,
    int questionNumber,
    int pageNumber,
  ) {
    // Pythagorean triples pool
    const triples = [
      [3, 4, 5], [5, 12, 13], [8, 15, 17], [7, 24, 25],
      [6, 8, 10], [9, 12, 15], [12, 16, 20], [15, 20, 25],
    ];

    switch (config.level) {
      case 57: // Find hypotenuse from perfect triple
        final t = triples[_random.nextInt(triples.length)];
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: 'a=${t[0]}, b=${t[1]}. Find c (a² + b² = c²):',
          correctAnswer: t[2].toString(),
        );
      case 58: // Find hypotenuse — perfect squares
        final t = triples[_random.nextInt(triples.length)];
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: '${t[0]}² + ${t[1]}² = c². Find c:',
          correctAnswer: t[2].toString(),
        );
      case 59: // Non-perfect: find missing leg
        final t = triples[_random.nextInt(triples.length)];
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: 'a=${t[0]}, c=${t[2]}. Find b (c² - a² = b²):',
          correctAnswer: t[1].toString(),
        );
      case 60: // Word problems
        final t = triples[_random.nextInt(triples.length)];
        final problems = [
          'A ladder ${t[2]}m long leans against a wall. Its foot is ${t[0]}m from the wall. How high does it reach?',
          'A ${t[2]}m rope goes from the top of a pole to a point ${t[0]}m from the base. Find the pole height.',
        ];
        final q = problems[_random.nextInt(problems.length)];
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: q,
          correctAnswer: t[1].toString(),
        );
      case 61: // Algebraic: find x given expressions for sides
        final k = _random.nextInt(4) + 1;
        final a = 3 * k;
        final b = 4 * k;
        final c = 5 * k;
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: 'Sides are (${3}x), (${4}x), $c. Find x:',
          correctAnswer: k.toString(),
        );
      case 62: // Distance formula
        final x1 = _random.nextInt(5);
        final y1 = _random.nextInt(5);
        final t = triples[_random.nextInt(4)]; // use small triples
        final x2 = x1 + t[0];
        final y2 = y1 + t[1];
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: 'Distance from ($x1,$y1) to ($x2,$y2):',
          correctAnswer: t[2].toString(),
        );
      default:
        final t = triples[_random.nextInt(triples.length)];
        return QuestionModel(
          id: _uuid.v4(),
          worksheetId: worksheetId,
          questionNumber: questionNumber,
          pageNumber: pageNumber,
          type: QuestionType.geometry,
          questionText: 'a=${t[0]}, b=${t[1]}. Find c:',
          correctAnswer: t[2].toString(),
        );
    }
  }
}
