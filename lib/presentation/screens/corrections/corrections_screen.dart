import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/question_model.dart';
import '../../widgets/handwriting_canvas.dart';

/// Corrections screen for fixing wrong answers
class CorrectionsScreen extends StatefulWidget {
  final ChildModel child;
  final int levelNumber;
  final String worksheetId;
  final List<QuestionModel> incorrectQuestions;
  final Map<int, String> originalAnswers;
  final int totalQuestions;
  final int originalCorrectCount;

  const CorrectionsScreen({
    super.key,
    required this.child,
    required this.levelNumber,
    required this.worksheetId,
    required this.incorrectQuestions,
    required this.originalAnswers,
    required this.totalQuestions,
    required this.originalCorrectCount,
  });

  @override
  State<CorrectionsScreen> createState() => _CorrectionsScreenState();
}

class _CorrectionsScreenState extends State<CorrectionsScreen> {
  final Map<int, String> _correctionAnswers = {};
  final Map<int, bool> _correctionResults = {};
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey();
  
  int _currentIndex = 0;
  bool _allCorrected = false;
  // Handwriting only — keyboard input removed
  String _handwritingText = '';

  @override
  void initState() {
    super.initState();
    _answerFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  QuestionModel get _currentQuestion => widget.incorrectQuestions[_currentIndex];

  void _submitCorrection() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final questionNumber = _currentQuestion.questionNumber;
    final isCorrect = _checkAnswer(answer, _currentQuestion.correctAnswer);

    setState(() {
      _correctionAnswers[questionNumber] = answer;
      _correctionResults[questionNumber] = isCorrect;
    });

    // Move to next uncorrected question or finish
    _moveToNextUncorrected();
  }

  bool _checkAnswer(String userAnswer, String correctAnswer) {
    final normalized = userAnswer
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .trim();
    
    final normalizedCorrect = correctAnswer
        .toLowerCase()
        .replaceAll(' ', '')
        .trim();

    return normalized == normalizedCorrect;
  }

  void _moveToNextUncorrected() {
    // Find next question that hasn't been correctly answered
    for (int i = 0; i < widget.incorrectQuestions.length; i++) {
      final q = widget.incorrectQuestions[i];
      final result = _correctionResults[q.questionNumber];
      if (result != true) {
        setState(() {
          _currentIndex = i;
          _answerController.clear();
          _handwritingText = '';
        });
        // Clear canvas
        _canvasKey.currentState?.clear();
        return;
      }
    }

    // All questions have been corrected
    setState(() {
      _allCorrected = true;
    });
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentIndex = index;
      final questionNumber = widget.incorrectQuestions[index].questionNumber;
      final savedAnswer = _correctionAnswers[questionNumber] ?? '';
      _answerController.text = savedAnswer;
      _handwritingText = savedAnswer;
    });
    // Clear canvas for new question
    _canvasKey.currentState?.clear();
  }

  int get _correctedCount => 
      _correctionResults.values.where((r) => r == true).length;

  void _finishCorrections() {
    // Navigate back to home with updated child
    context.go('/home', extra: widget.child);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_allCorrected) {
      return _buildCompletionScreen(l10n);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: AppBar(
          title: Text('Corrections - Level ${widget.levelNumber}'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitDialog,
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '$_correctedCount/${widget.incorrectQuestions.length} fixed',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicators
            _buildProgressIndicators(),
            
            // Question card
            Expanded(
              child: _buildQuestionCard(),
            ),
            
            // Answer input
            _buildAnswerInput(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(widget.incorrectQuestions.length, (index) {
          final q = widget.incorrectQuestions[index];
          final result = _correctionResults[q.questionNumber];
          final isCurrent = index == _currentIndex;
          
          Color color;
          IconData? icon;
          
          if (result == true) {
            color = Colors.green;
            icon = Icons.check;
          } else if (result == false) {
            color = Colors.red;
            icon = Icons.close;
          } else {
            color = Colors.grey[300]!;
            icon = null;
          }
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _goToQuestion(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: isCurrent
                      ? Border.all(color: Colors.orange, width: 3)
                      : null,
                ),
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 16)
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Original answer (wrong)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Your answer was wrong',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'You wrote: ${widget.originalAnswers[_currentQuestion.questionNumber] ?? "?"}',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Question
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${widget.incorrectQuestions.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuestion.questionText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Hint
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Try again! Think carefully about the answer.',
                    style: TextStyle(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Show result if answered incorrectly again
          if (_correctionResults[_currentQuestion.questionNumber] == false) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Still incorrect. The correct answer is: ${_currentQuestion.correctAnswer}',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerInput(AppLocalizations l10n) {
    final isCorrect = _correctionResults[_currentQuestion.questionNumber] == true;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandwritingInput(isCorrect),
          ],
        ),
      ),
    );
  }

  Widget _buildHandwritingInput(bool isCorrect) {
    return Column(
      children: [
        HandwritingCanvas(
          key: _canvasKey,
          height: 150,
          enabled: !isCorrect,
          recognizedText: _handwritingText,
          onRecognized: (text) {
            setState(() {
              _handwritingText = text;
              _answerController.text = text;
            });
          },
        ),
        const SizedBox(height: 12),
        // Buttons
        Row(
          children: [
            if (isCorrect)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _moveToNextUncorrected,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handwritingText.isEmpty ? null : _submitCorrection,
                  icon: const Icon(Icons.check),
                  label: const Text('Check Answer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionScreen(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Corrections Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'You fixed all ${widget.incorrectQuestions.length} mistakes.\nGreat job learning from your errors!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Summary card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          Icons.assignment,
                          'Original Score',
                          '${widget.originalCorrectCount}/${widget.totalQuestions}',
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          Icons.edit,
                          'Corrections Made',
                          '${widget.incorrectQuestions.length}',
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          Icons.check_circle,
                          'Status',
                          'Worksheet Complete',
                          valueColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _finishCorrections,
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Corrections?'),
        content: const Text(
          'You still have questions to correct. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/home', extra: widget.child);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
