import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/question_generator.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/question_model.dart';
import '../../widgets/handwriting_canvas.dart';
import '../../widgets/tracing_canvas.dart';
import '../../widgets/number_tracing_canvas.dart';

/// Worksheet screen for answering questions
class WorksheetScreen extends StatefulWidget {
  final ChildModel child;
  final int levelNumber;

  const WorksheetScreen({
    super.key,
    required this.child,
    required this.levelNumber,
  });

  @override
  State<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends State<WorksheetScreen>
    with TickerProviderStateMixin {
  late final QuestionGenerator _generator;
  late final List<QuestionModel> _questions;
  late final String _worksheetId;
  late final LevelConfig? _levelConfig;

  final Map<int, String> _answers = {};
  final Map<int, bool?> _results = {};
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey();
  // ignore: unused_field - reserved for future tracing feature
  final GlobalKey<TracingCanvasState> _tracingKey = GlobalKey();
  
  int _currentQuestion = 0;
  int _currentPage = 0; // Track current page (0-9 for 10 pages)
  bool _isSubmitting = false;
  Timer? _timer;
  int _secondsRemaining = kDebugMode ? 120 : 900; // dev: 2 min | prod: 15 min
  bool _worksheetCompleted = false;
  // ignore: unused_field - reserved for analytics
  DateTime? _startTime;
  final bool _useHandwriting = true; // Handwriting only — keyboard mode removed
  String _handwritingText = '';
  final Map<int, bool> _tracingCompleted = {};
  
  // Constants for worksheet structure
  static const int questionsPerPage = 10;
  static const int totalPages = 5; // 5 pages × 10 = 50 questions per worksheet

  // Actual pages based on generated question count (may be fewer in debug mode)
  int get _actualTotalPages => (_questions.length / questionsPerPage).ceil().clamp(1, totalPages);

  @override
  void initState() {
    super.initState();
    _generator = QuestionGenerator();
    _worksheetId = const Uuid().v4();
    _levelConfig = LevelConfiguration.getLevel(widget.levelNumber);
    
    _questions = _generator.generateQuestions(
      levelNumber: widget.levelNumber,
      worksheetId: _worksheetId,
      // Each page has `questionsPerPage` questions; total pages comes from the
      // level config (defaults to 5) → 5 × 10 = 50 questions per worksheet.
      count: (_levelConfig?.pages ?? totalPages) * questionsPerPage,
    );
    
    _startTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _submitWorksheet();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      setState(() {
        _currentQuestion = index;
        final savedAnswer = _answers[index] ?? '';
        _answerController.text = savedAnswer;
        _handwritingText = savedAnswer;
      });
      // Clear the canvas for new question
      if (_canvasKey.currentState != null) {
        _canvasKey.currentState!.clear();
      }
      // Handwriting is always on; no keyboard focus needed.
    }
  }

  void _submitAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final question = _questions[_currentQuestion];
    final isCorrect = _normalizeAnswer(answer) == _normalizeAnswer(question.correctAnswer);

    setState(() {
      _answers[_currentQuestion] = answer;
      _results[_currentQuestion] = isCorrect;
    });

    // Move to next unanswered question
    if (_currentQuestion < _questions.length - 1) {
      _goToQuestion(_currentQuestion + 1);
    } else if (_allQuestionsAnswered()) {
      _submitWorksheet();
    }
  }

  String _normalizeAnswer(String answer) {
    return answer
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .trim();
  }

  bool _allQuestionsAnswered() {
    return _answers.length == _questions.length;
  }

  int _correctAnswers() {
    return _results.values.where((r) => r == true).length;
  }

  double _scorePercentage() {
    if (_results.isEmpty) return 0;
    return (_correctAnswers() / _questions.length) * 100;
  }

  int _calculateStars() {
    final percentage = _scorePercentage();
    if (percentage >= 95) return 3;
    if (percentage >= 80) return 2;
    if (percentage >= 60) return 1;
    return 0;
  }

  Future<void> _submitWorksheet() async {
    if (_worksheetCompleted) return;
    
    _timer?.cancel();
    
    setState(() {
      _isSubmitting = true;
    });

    // Calculate results
    final correctCount = _correctAnswers();
    final percentage = _scorePercentage();
    final stars = _calculateStars();
    final passed = percentage >= 95;

    // Simulate saving to database
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSubmitting = false;
      _worksheetCompleted = true;
    });

    if (mounted) {
      // Calculate time spent (600 seconds total - remaining)
      final timeSpentSeconds = 600 - _secondsRemaining;
      
      // Navigate to results
      context.push('/results', extra: {
        'child': widget.child,
        'levelNumber': widget.levelNumber,
        'correctCount': correctCount,
        'totalQuestions': _questions.length,
        'percentage': percentage,
        'stars': stars,
        'passed': passed,
        'worksheetId': _worksheetId,
        'questions': _questions,
        'answers': _answers,
        'results': _results,
        'timeSpentSeconds': timeSpentSeconds,
      });
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Worksheet?'),
        content: const Text(
          'Your progress will be lost if you exit now. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final question = _questions[_currentQuestion];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(l10n),
        body: SafeArea(
          child: _isTracingLevel
              ? _buildTracingLayout(question)
              : _buildGridLayout(question),
        ),
      ),
    );
  }
  
  // Layout for tracing levels (single question view)
  Widget _buildTracingLayout(QuestionModel question) {
    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),
        
        // Question display
        Expanded(
          child: _buildQuestionArea(question),
        ),
        
        // Answer input
        _buildAnswerInput(question),
        
        // Navigation
        _buildNavigationBar(),
      ],
    );
  }
  
  // Grid layout for math levels (10 questions per page)
  Widget _buildGridLayout(QuestionModel question) {
    final pageQuestions = _currentPageQuestions;
    final instruction = _instructionForLevel();

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),

        // Single instruction for the page (e.g. "Factor each expression")
        if (instruction != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Grid of questions (or vertical list of sequence rows)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _isSequenceLevel
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: pageQuestions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, localIndex) {
                      final globalIndex = _getGlobalIndex(localIndex);
                      final q = pageQuestions[localIndex];
                      return _buildSequenceRow(q, globalIndex);
                    },
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: pageQuestions.length,
                    itemBuilder: (context, localIndex) {
                      final globalIndex = _getGlobalIndex(localIndex);
                      final q = pageQuestions[localIndex];
                      return _buildQuestionCard(q, globalIndex, localIndex);
                    },
                  ),
          ),
        ),
        
        // Selected question input area
        _buildSelectedQuestionInput(question),
        
        // Page navigation
        _buildPageNavigation(),
      ],
    );
  }
  
  // Question card for grid view
  Widget _buildQuestionCard(QuestionModel question, int globalIndex, int localIndex) {
    final isAnswered = _results[globalIndex] != null;
    final isCorrect = _results[globalIndex] == true;
    final isSelected = globalIndex == _currentQuestion;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentQuestion = globalIndex;
          _answerController.text = _answers[globalIndex] ?? '';
          _handwritingText = _answers[globalIndex] ?? '';
        });
        if (!_useHandwriting) {
          _answerFocusNode.requestFocus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isAnswered
              ? (isCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1))
              : (isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question number badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${globalIndex + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isAnswered)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
            // Question text (or boxed sequence prompt)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: question.questionText.startsWith('AFTER:')
                      ? _buildSequenceBoxes(
                          question.questionText.substring(6),
                          _answers[globalIndex],
                          isAnswered,
                          isCorrect,
                        )
                      : Text(
                          _displayQuestionText(question.questionText),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isAnswered
                                ? (isCorrect
                                    ? Colors.green[800]
                                    : Colors.red[800])
                                : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
            ),
            // Answer if answered (skip for sequence boxes - already shown inside)
            if (isAnswered && !question.questionText.startsWith('AFTER:'))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _answers[globalIndex] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isCorrect ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Input area for selected question in grid view
  Widget _buildSelectedQuestionInput(QuestionModel question) {
    final isAnswered = _results[_currentQuestion] != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected question label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q${_currentQuestion + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _displayQuestionText(question.questionText),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Handwriting canvas (skipped on sequence levels - canvas is inline
          // inside the selected row's answer box).
          if (!_isSequenceLevel)
            HandwritingCanvas(
              key: _canvasKey,
              height: 110,
              enabled: !isAnswered,
              recognizedText: _handwritingText,
              onRecognized: (text) {
                setState(() {
                  _handwritingText = text;
                  _answerController.text = text;
                });
              },
            ),
          if (!_isSequenceLevel) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isAnswered || _handwritingText.trim().isEmpty)
                  ? null
                  : _submitAnswer,
              icon: const Icon(Icons.check, size: 20),
              label: Text(isAnswered ? 'Answered' : 'Submit answer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Page navigation for grid view
  Widget _buildPageNavigation() {
    final pageAnsweredCount = _currentPageQuestions.asMap().entries
        .where((e) => _answers[_getGlobalIndex(e.key)] != null)
        .length;
    final allPageAnswered = pageAnsweredCount == questionsPerPage;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Previous page button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Prev Page'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Page indicator or submit button
          if (_allQuestionsAnswered())
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitWorksheet,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.done_all, size: 18),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Worksheet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          else
            // Page dots – wrapped in Flexible so they never overflow the Row
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_actualTotalPages, (i) {
                    final isCurrentPage = i == _currentPage;
                    final pageStart = i * questionsPerPage;
                    final pageAnswered = List.generate(questionsPerPage, (j) => pageStart + j)
                        .where((idx) => idx < _questions.length && _answers[idx] != null)
                        .length;
                    final pageComplete = pageAnswered == questionsPerPage;

                    return GestureDetector(
                      onTap: () => _goToPage(i),
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: pageComplete
                              ? Colors.green
                              : (isCurrentPage ? AppColors.primary : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCurrentPage || pageComplete ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          const SizedBox(width: 12),
          // Next page button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentPage < _actualTotalPages - 1 ? () => _goToPage(_currentPage + 1) : null,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Next Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: allPageAnswered ? Colors.green : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _showExitDialog,
      ),
      title: Column(
        children: [
          Text(
            'Level ${widget.levelNumber}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_levelConfig != null)
            Text(
              _levelConfig.topicEn,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        // Timer
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _secondsRemaining < 60 
                ? Colors.red.withValues(alpha: 0.1) 
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: _secondsRemaining < 60 ? Colors.red : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(_secondsRemaining),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _secondsRemaining < 60 ? Colors.red : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Check if current level uses tracing (needs single question view)
  bool get _isTracingLevel {
    return widget.levelNumber <= 3 || widget.levelNumber == 5 || widget.levelNumber == 7;
  }

  /// Sequence level: each question is "What comes after N?" rendered as
  /// a vertical list of [N] → [answer box] rows with inline handwriting.
  bool get _isSequenceLevel => widget.levelNumber == 9;
  
  // Get questions for the current page
  List<QuestionModel> get _currentPageQuestions {
    final startIndex = _currentPage * questionsPerPage;
    final endIndex = (startIndex + questionsPerPage).clamp(0, _questions.length);
    return _questions.sublist(startIndex, endIndex);
  }
  
  // Get global question index from page-local index
  int _getGlobalIndex(int localIndex) {
    return _currentPage * questionsPerPage + localIndex;
  }
  
  void _goToPage(int page) {
    if (page >= 0 && page < _actualTotalPages) {
      setState(() {
        _currentPage = page;
        // Set current question to first unanswered on the page, or first question
        final startIndex = page * questionsPerPage;
        int firstUnanswered = startIndex;
        for (int i = startIndex; i < startIndex + questionsPerPage && i < _questions.length; i++) {
          if (_answers[i] == null) {
            firstUnanswered = i;
            break;
          }
        }
        _currentQuestion = firstUnanswered;
        _answerController.text = _answers[_currentQuestion] ?? '';
        _handwritingText = _answers[_currentQuestion] ?? '';
      });
    }
  }

  /// Strip redundant English prefixes that are now shown once in the page
  /// instruction header instead of on every question card.
  String _displayQuestionText(String text) {
    // Sequence prompts are rendered as boxes; collapse the raw form here.
    if (text.startsWith('AFTER:')) {
      final n = text.substring(6);
      return '$n → ?';
    }
    const prefixes = ['Solve: ', 'Factor: ', 'Simplify: ', 'Expand: ', 'Write: '];
    for (final p in prefixes) {
      if (text.startsWith(p)) return text.substring(p.length);
    }
    return text;
  }

  /// Renders a sequence prompt as two boxes: [N] → [answer/?]
  Widget _buildSequenceBoxes(
    String startNumber,
    String? answer,
    bool isAnswered,
    bool isCorrect,
  ) {
    Color answerColor = AppColors.textLight;
    Color answerBorder = AppColors.border;
    String answerText = '?';
    if (isAnswered) {
      answerText = answer ?? '?';
      answerColor = isCorrect ? AppColors.success : AppColors.error;
      answerBorder = answerColor;
    }
    Widget box(String text, {required Color textColor, required Color border, Color? fill}) {
      return Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill ?? AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor,
            fontFamily: 'Nunito',
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        box(startNumber,
            textColor: AppColors.textPrimary,
            border: AppColors.border,
            fill: AppColors.background),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
        box(answerText, textColor: answerColor, border: answerBorder),
      ],
    );
  }

  /// Full row for sequence levels (level 9): [N] -> [answer box].
  /// The selected row's answer box embeds a live HandwritingCanvas so the
  /// child writes the answer directly inside it.
  Widget _buildSequenceRow(QuestionModel question, int globalIndex) {
    final isAnswered = _results[globalIndex] != null;
    final isCorrect = _results[globalIndex] == true;
    final isSelected = globalIndex == _currentQuestion;
    final startNumber = question.questionText.startsWith('AFTER:')
        ? question.questionText.substring(6)
        : question.questionText;
    final answer = _answers[globalIndex];

    Color boxBorder;
    if (isAnswered) {
      boxBorder = isCorrect ? AppColors.success : AppColors.error;
    } else if (isSelected) {
      boxBorder = AppColors.primary;
    } else {
      boxBorder = AppColors.border;
    }

    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        setState(() {
          _currentQuestion = globalIndex;
          _answerController.text = _answers[globalIndex] ?? '';
          _handwritingText = _answers[globalIndex] ?? '';
        });
        // Clear the canvas state so the new row starts fresh
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _canvasKey.currentState?.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            // Question number badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAnswered
                    ? (isCorrect ? AppColors.success : AppColors.error)
                    : AppColors.textLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${globalIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Start number box
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Text(
                startNumber,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textSecondary, size: 26),
            ),
            // Answer box (inline canvas if selected, else static)
            Expanded(
              child: SizedBox(
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: boxBorder, width: 2),
                    ),
                    child: isSelected && !isAnswered
                        ? HandwritingCanvas(
                            key: _canvasKey,
                            height: 76,
                            enabled: true,
                            compact: true,
                            hintText: 'Write here',
                            recognizedText: _handwritingText,
                            onRecognized: (text) {
                              setState(() {
                                _handwritingText = text;
                                _answerController.text = text;
                              });
                            },
                          )
                        : Center(
                            child: Text(
                              answer == null || answer.isEmpty ? '?' : answer,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Nunito',
                                color: isAnswered
                                    ? (isCorrect
                                        ? AppColors.success
                                        : AppColors.error)
                                    : AppColors.textLight,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            if (isAnswered) ...[
              const SizedBox(width: 8),
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// One-line instruction shown above the question grid, based on level.
  /// Returns null when no banner is needed (questions are already self-explanatory).
  String? _instructionForLevel() {
    final type = _levelConfig?.type;
    final levelNum = _levelConfig?.level;
    if (type == null) return null;
    // Level-specific overrides (beginner-friendly wording)
    if (levelNum == 9) return 'Write the number that comes next';
    if (levelNum == 21) return 'Write the fraction';
    switch (type) {
      case LevelType.factorization:
        return 'Factor each expression';
      case LevelType.quadratic:
        return 'Solve each equation';
      case LevelType.algebra:
        return 'Solve for x';
      case LevelType.fractions:
        return 'Add the fractions';
      case LevelType.polynomials:
        return 'Expand each expression';
      case LevelType.numberWriting:
        return 'Write each number';
      case LevelType.inequalities:
        return 'Solve each inequality';
      case LevelType.powers:
        return 'Evaluate each expression';
      case LevelType.roots:
        return 'Find each root';
      default:
        return null;
    }
  }

  Widget _buildProgressIndicator() {
    final answeredCount = _answers.length;
    final progress = answeredCount / _questions.length;
    
    // For tracing levels, show question progress
    // For math levels, show page progress
    final progressText = _isTracingLevel
        ? 'Question ${_currentQuestion + 1} of ${_questions.length}'
        : 'Page ${_currentPage + 1} of $_actualTotalPages';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$answeredCount of ${_questions.length} answered',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(QuestionModel question) {
    // Check if this is a tracing question
    final isTracingQuestion = question.type == QuestionType.tracing;
    
    if (isTracingQuestion) {
      return _buildTracingQuestionArea(question);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(question.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getQuestionTypeLabel(question.type),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getQuestionTypeColor(question.type),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Question text
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Result indicator if answered
                if (_results[_currentQuestion] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _results[_currentQuestion]!
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _results[_currentQuestion]!
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _results[_currentQuestion]!
                              ? Colors.green
                              : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _results[_currentQuestion]!
                              ? 'Correct!'
                              : 'Your answer: ${_answers[_currentQuestion]}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _results[_currentQuestion]!
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTracingQuestionArea(QuestionModel question) {
    // Check if this is a number tracing level (3, 5, 7)
    if (widget.levelNumber == 3 || widget.levelNumber == 5 || widget.levelNumber == 7) {
      return _buildNumberTracingArea(question);
    }
    
    // Determine tracing pattern based on level and question
    TracingPattern pattern;
    String instruction;
    
    switch (widget.levelNumber) {
      case 1: // Line tracing - straight lines
        final patterns = [
          TracingPattern.horizontalLine,
          TracingPattern.verticalLine,
          TracingPattern.diagonalLine,
          TracingPattern.zigzag,
        ];
        pattern = patterns[_currentQuestion % patterns.length];
        instruction = 'Trace the line from START to END';
        break;
      case 2: // Curve tracing
        final patterns = [
          TracingPattern.curve,
          TracingPattern.wave,
          TracingPattern.circle,
          TracingPattern.spiral,
        ];
        pattern = patterns[_currentQuestion % patterns.length];
        instruction = 'Trace the curve from START to END';
        break;
      default:
        pattern = TracingPattern.horizontalLine;
        instruction = question.questionText;
    }
    
    final isComplete = _tracingCompleted[_currentQuestion] == true;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction text
          Text(
            instruction,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Tracing canvas
          Flexible(
            child: TracingCanvas(
              key: ValueKey('tracing_$_currentQuestion'),
              height: 180,
              pattern: pattern,
              questionNumber: _currentQuestion + 1,
              enabled: !isComplete,
              onComplete: () {
                _onTracingComplete();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberTracingArea(QuestionModel question) {
    final isComplete = _tracingCompleted[_currentQuestion] == true;
    
    // Get the number to trace from the question
    int numberToTrace;
    if (question.correctAnswer.isNotEmpty) {
      numberToTrace = int.tryParse(question.correctAnswer) ?? (_currentQuestion % 10) + 1;
    } else {
      // Fallback: cycle through 1-10 based on question number
      numberToTrace = (_currentQuestion % 10) + 1;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NumberTracingCanvas(
        key: ValueKey('number_tracing_${_currentQuestion}_$numberToTrace'),
        height: 200,
        numberToTrace: numberToTrace,
        enabled: !isComplete,
        onComplete: () {
          _onTracingComplete();
        },
      ),
    );
  }
  
  void _onTracingComplete() {
    setState(() {
      _tracingCompleted[_currentQuestion] = true;
      _answers[_currentQuestion] = 'traced';
      _results[_currentQuestion] = true;
    });
    // No auto-advance - user must tap "Next" button
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.tracing:
      case QuestionType.counting:
        return Colors.blue;
      case QuestionType.addition:
        return Colors.green;
      case QuestionType.subtraction:
        return Colors.orange;
      case QuestionType.multiplication:
        return Colors.purple;
      case QuestionType.division:
        return Colors.red;
      case QuestionType.fraction:
      case QuestionType.decimal:
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.tracing:
        return 'Tracing';
      case QuestionType.counting:
        return 'Counting';
      case QuestionType.numberBond:
        return 'Number Bond';
      case QuestionType.addition:
        return 'Addition';
      case QuestionType.subtraction:
        return 'Subtraction';
      case QuestionType.multiplication:
        return 'Multiplication';
      case QuestionType.division:
        return 'Division';
      case QuestionType.fraction:
        return 'Fractions';
      case QuestionType.decimal:
        return 'Decimals';
      case QuestionType.percentage:
        return 'Percentage';
      case QuestionType.negative:
        return 'Negative Numbers';
      case QuestionType.power:
        return 'Powers';
      case QuestionType.squareRoot:
        return 'Square Roots';
      case QuestionType.polynomial:
        return 'Algebra';
      case QuestionType.factorization:
        return 'Factorization';
      case QuestionType.geometry:
        return 'Geometry';
      case QuestionType.mixed:
        return 'Mixed';
    }
  }

  Widget _buildAnswerInput(QuestionModel question) {
    // For tracing questions, input is handled in the tracing canvas
    if (question.type == QuestionType.tracing) {
      final isComplete = _tracingCompleted[_currentQuestion] == true;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isComplete)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Well done!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Next question button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_currentQuestion < _questions.length - 1) {
                          _goToQuestion(_currentQuestion + 1);
                        } else if (_allQuestionsAnswered()) {
                          _submitWorksheet();
                        }
                      },
                      icon: Icon(
                        _currentQuestion < _questions.length - 1
                            ? Icons.arrow_forward
                            : Icons.done_all,
                      ),
                      label: Text(
                        _currentQuestion < _questions.length - 1
                            ? 'Next Question'
                            : 'Submit Worksheet',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentQuestion < _questions.length - 1
                            ? AppColors.primary
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Use your finger to trace the pattern',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
          ],
        ),
      );
    }
    
    final isAnswered = _results[_currentQuestion] != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildHandwritingInput(isAnswered),
    );
  }

  Widget _buildHandwritingInput(bool isAnswered) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HandwritingCanvas(
          key: _canvasKey,
          height: 130,
          enabled: !isAnswered,
          recognizedText: _handwritingText,
          onRecognized: (text) {
            setState(() {
              _handwritingText = text;
              _answerController.text = text;
            });
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isAnswered || _handwritingText.trim().isEmpty
                ? null
                : _submitAnswer,
            icon: const Icon(Icons.check, size: 20),
            label: Text(isAnswered ? 'Answered' : 'Submit answer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question dots
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final isAnswered = _results[index] != null;
                final isCorrect = _results[index] == true;
                final isCurrent = index == _currentQuestion;

                return GestureDetector(
                  onTap: () => _goToQuestion(index),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isAnswered
                          ? (isCorrect ? Colors.green : Colors.red)
                          : (isCurrent ? AppColors.primary : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(6),
                      border: isCurrent
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAnswered || isCurrent
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentQuestion > 0
                      ? () => _goToQuestion(_currentQuestion - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Prev'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_allQuestionsAnswered())
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitWorksheet,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.done_all, size: 18),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestion < _questions.length - 1
                        ? () => _goToQuestion(_currentQuestion + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
