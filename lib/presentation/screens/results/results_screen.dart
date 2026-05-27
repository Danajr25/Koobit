import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/question_model.dart';
import '../../blocs/progress/progress.dart';
import '../../widgets/cyber_widgets.dart';

/// Results screen showing worksheet completion stats
class ResultsScreen extends StatefulWidget {
  final ChildModel child;
  final int levelNumber;
  final int correctCount;
  final int totalQuestions;
  final double percentage;
  final int stars;
  final bool passed;
  final String worksheetId;
  final List<QuestionModel> questions;
  final Map<int, String> answers;
  final Map<int, bool?> results;
  final int timeSpentSeconds;

  const ResultsScreen({
    super.key,
    required this.child,
    required this.levelNumber,
    required this.correctCount,
    required this.totalQuestions,
    required this.percentage,
    required this.stars,
    required this.passed,
    required this.worksheetId,
    required this.questions,
    required this.answers,
    required this.results,
    this.timeSpentSeconds = 0,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _scoreController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;
  bool _resultsSaved = false;
  ChildModel? _updatedChild;

  @override
  void initState() {
    super.initState();
    
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _starsController,
        curve: Curves.elasticOut,
      ),
    );
    
    _scoreAnimation = Tween<double>(begin: 0, end: widget.percentage).animate(
      CurvedAnimation(
        parent: _scoreController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _starsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scoreController.forward();
    });
    
    // Save results to database
    _saveResults();
  }
  
  void _saveResults() {
    if (_resultsSaved) return;
    _resultsSaved = true;
    
    context.read<ProgressBloc>().add(
      WorksheetResultSaveRequested(
        child: widget.child,
        levelNumber: widget.levelNumber,
        worksheetId: widget.worksheetId,
        questions: widget.questions,
        answers: widget.answers,
        results: widget.results,
        correctCount: widget.correctCount,
        totalQuestions: widget.totalQuestions,
        timeSpentSeconds: widget.timeSpentSeconds,
        stars: widget.stars,
        passed: widget.passed,
      ),
    );
  }

  @override
  void dispose() {
    _starsController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levelConfig = LevelConfiguration.getLevel(widget.levelNumber);

    return BlocListener<ProgressBloc, ProgressState>(
      listener: (context, state) {
        if (state.isSaved && state.updatedChild != null) {
          setState(() {
            _updatedChild = state.updatedChild;
          });
          // Show success message
          if (state.levelAdvanced) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Level ${widget.levelNumber + 1} unlocked!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to save progress'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
        backgroundColor: widget.passed
            ? AppColors.correctHighlight
            : AppColors.incorrectHighlight,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(l10n, levelConfig),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Stars animation
                      _buildStarsDisplay(),
                      const SizedBox(height: 32),
                      
                      // Score card
                      _buildScoreCard(),
                      const SizedBox(height: 24),
                      
                      // Result message
                      _buildResultMessage(l10n),
                      const SizedBox(height: 32),
                      
                      // Stats breakdown
                      _buildStatsBreakdown(l10n),
                      const SizedBox(height: 32),
                      
                      // Incorrect questions summary
                      if (!widget.passed) ...[
                        _buildIncorrectQuestions(),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              _buildActionButtons(l10n),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, LevelConfig? levelConfig) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Level ${widget.levelNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (levelConfig != null)
            Expanded(
              child: Text(
                levelConfig.topicEn,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStarsDisplay() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isEarned = index < widget.stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  isEarned ? Icons.star : Icons.star_border,
                  size: 64,
                  color: isEarned 
                      ? AppColors.gold 
                      : Colors.grey[300],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return Text(
                  '${_scoreAnimation.value.toInt()}%',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: widget.passed ? Colors.green : Colors.orange,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.correctCount} / ${widget.totalQuestions} correct',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultMessage(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.passed 
            ? Colors.green.withValues(alpha: 0.1) 
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.passed 
              ? Colors.green.withValues(alpha: 0.3) 
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.passed ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.passed ? Icons.celebration : Icons.refresh,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.passed ? 'Level Complete!' : 'Almost There!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.passed ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.passed
                      ? 'Great job! You\'ve unlocked the next level.'
                      : 'You need 95% to pass. Try correcting your mistakes!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBreakdown(AppLocalizations l10n) {
    final incorrectCount = widget.totalQuestions - widget.correctCount;
    
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            color: Colors.green,
            value: widget.correctCount.toString(),
            label: 'Correct',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel,
            color: Colors.red,
            value: incorrectCount.toString(),
            label: 'Incorrect',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            color: AppColors.gold,
            value: widget.stars.toString(),
            label: 'Stars',
          ),
        ),
      ],
    );
  }

  Widget _buildIncorrectQuestions() {
    final incorrectIndices = widget.results.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toList();

    if (incorrectIndices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questions to Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...incorrectIndices.take(5).map((index) {
          final question = widget.questions[index];
          final userAnswer = widget.answers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.questionText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Your answer: $userAnswer',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Correct: ${question.correctAnswer}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        if (incorrectIndices.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${incorrectIndices.length - 5} more questions',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    // Use updated child if available (after save), otherwise use original
    final childToUse = _updatedChild ?? widget.child;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CyberButton(
                text: 'Home',
                icon: Icons.home_rounded,
                color: AppColors.surface,
                textColor: AppColors.textPrimary,
                onPressed: () {
                  context.go('/home', extra: childToUse);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CyberButton(
                text: widget.passed ? 'Continue' : 'Do Corrections',
                icon: widget.passed
                    ? Icons.arrow_forward_rounded
                    : Icons.edit_rounded,
                color: widget.passed ? AppColors.success : AppColors.secondary,
                onPressed: () {
                  if (widget.passed) {
                    context.go('/levels', extra: childToUse);
                  } else {
                    final incorrectQuestions = widget.questions.where((q) {
                      return widget.results[q.questionNumber] != true;
                    }).toList();
                    final originalAnswers = Map<int, String>.fromEntries(
                      incorrectQuestions.map((q) => MapEntry(
                            q.questionNumber,
                            widget.answers[q.questionNumber] ?? '',
                          )),
                    );
                    context.push(
                      '/corrections',
                      extra: {
                        'child': childToUse,
                        'levelNumber': widget.levelNumber,
                        'worksheetId': widget.worksheetId,
                        'incorrectQuestions': incorrectQuestions,
                        'originalAnswers': originalAnswers,
                        'totalQuestions': widget.totalQuestions,
                        'originalCorrectCount': widget.correctCount,
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
