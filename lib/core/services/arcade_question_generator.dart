import 'dart:math';

/// A math question used in arcade mini-games.
class ArcadeQuestion {
  final String questionText;
  final int correctAnswer;
  final List<int> choices;

  const ArcadeQuestion({
    required this.questionText,
    required this.correctAnswer,
    required this.choices,
  });
}

/// Generates arithmetic questions scaled to [level] (1–10).
class ArcadeQuestionGenerator {
  final Random _rng;
  final int level;

  ArcadeQuestionGenerator({required this.level, int? seed})
      : _rng = Random(seed);

  /// Returns a question with [choiceCount] answer choices (default 4, min 2).
  ArcadeQuestion generate({int choiceCount = 4}) {
    final ops = level <= 2
        ? ['+', '-']
        : level <= 5
            ? ['+', '-', '×']
            : ['+', '-', '×', '÷'];
    final op = ops[_rng.nextInt(ops.length)];

    int a, b, ans;
    switch (op) {
      case '+':
        a = _rng.nextInt(level * 4 + 4) + 1;
        b = _rng.nextInt(level * 3 + 3) + 1;
        ans = a + b;
        break;
      case '-':
        b = _rng.nextInt(level * 3 + 2) + 1;
        ans = _rng.nextInt(level * 3 + 2) + 1;
        a = ans + b;
        break;
      case '×':
        a = _rng.nextInt(min(level + 3, 12)) + 1;
        b = _rng.nextInt(min(level + 2, 9)) + 1;
        ans = a * b;
        break;
      case '÷':
        b = _rng.nextInt(min(level + 2, 8)) + 2;
        ans = _rng.nextInt(min(level + 3, 9)) + 2;
        a = ans * b;
        break;
      default:
        a = 5;
        b = 3;
        ans = 8;
    }

    final choices = <int>{ans};
    while (choices.length < choiceCount) {
      final offset = _rng.nextInt(max(ans ~/ 2 + 1, 4)) + 1;
      final wrong = _rng.nextBool() ? ans + offset : (ans - offset).abs();
      if (wrong != ans && wrong > 0) choices.add(wrong);
    }

    return ArcadeQuestion(
      questionText: '$a $op $b = ?',
      correctAnswer: ans,
      choices: choices.toList()..shuffle(_rng),
    );
  }
}
