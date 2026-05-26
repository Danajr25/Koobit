import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';

/// Level status for display
enum LevelStatus {
  locked,
  unlocked,
  inProgress,
  completed,
}

/// Level map screen showing all 54 levels in their phases
class LevelMapScreen extends StatefulWidget {
  final ChildModel child;
  final Map<int, LevelProgress>? levelProgress;

  const LevelMapScreen({
    super.key,
    required this.child,
    this.levelProgress,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedPhase;

  @override
  void initState() {
    super.initState();
    // Find and set the current phase as expanded
    final currentLevel = widget.child.currentLevel;
    final currentPhase = LevelConfiguration.getPhaseForLevel(currentLevel);
    if (currentPhase != null) {
      _expandedPhase = currentPhase.phaseNumber;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.levelMap),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Current level indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${l10n.level} ${widget.child.currentLevel}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: LevelConfiguration.phases.length,
        itemBuilder: (context, index) {
          final phase = LevelConfiguration.phases[index];
          final isExpanded = _expandedPhase == phase.phaseNumber;
          
          return _buildPhaseCard(context, phase, isExpanded, languageCode, l10n);
        },
      ),
    );
  }

  Widget _buildPhaseCard(
    BuildContext context,
    LearningPhase phase,
    bool isExpanded,
    String languageCode,
    AppLocalizations l10n,
  ) {
    // Check if any level in phase is accessible
    final firstLevelInPhase = phase.levels.first.level;
    final isPhaseAccessible = widget.child.currentLevel >= firstLevelInPhase ||
        firstLevelInPhase == 1;

    // Calculate phase progress
    int completedInPhase = 0;
    for (final level in phase.levels) {
      if (level.level < widget.child.currentLevel) {
        completedInPhase++;
      }
    }
    final progressPercent = phase.levels.isEmpty
        ? 0.0
        : completedInPhase / phase.levels.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded 
              ? phase.color.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Phase header
          InkWell(
            onTap: () {
              setState(() {
                _expandedPhase = isExpanded ? null : phase.phaseNumber;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Phase icon/number
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPhaseAccessible
                          ? phase.color.withValues(alpha: 0.2)
                          : AppColors.levelLocked.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${phase.phaseNumber}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPhaseAccessible
                              ? phase.color
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Phase info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.getName(languageCode),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPhaseAccessible
                                ? AppColors.textPrimary
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${phase.levels.length} ${l10n.levels.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            backgroundColor: AppColors.backgroundDark,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPhaseAccessible 
                                  ? phase.color 
                                  : AppColors.levelLocked,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Levels (expanded)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildLevelGrid(context, phase, languageCode, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(
    BuildContext context,
    LearningPhase phase,
    String languageCode,
    AppLocalizations l10n,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: phase.levels.length,
      itemBuilder: (context, index) {
        final level = phase.levels[index];
        final status = _getLevelStatus(level.level);

        return _buildLevelNode(
          context,
          level,
          status,
          phase.color,
          languageCode,
          l10n,
        );
      },
    );
  }

  Widget _buildLevelNode(
    BuildContext context,
    LevelConfig level,
    LevelStatus status,
    Color phaseColor,
    String languageCode,
    AppLocalizations l10n,
  ) {
    Color backgroundColor;
    Color iconColor;
    IconData? icon;

    switch (status) {
      case LevelStatus.completed:
        backgroundColor = AppColors.levelCompleted;
        iconColor = Colors.white;
        icon = Icons.check;
        break;
      case LevelStatus.inProgress:
        backgroundColor = AppColors.levelInProgress;
        iconColor = Colors.white;
        icon = Icons.play_arrow;
        break;
      case LevelStatus.unlocked:
        backgroundColor = phaseColor;
        iconColor = Colors.white;
        icon = null;
        break;
      case LevelStatus.locked:
        backgroundColor = AppColors.levelLocked;
        iconColor = Colors.white;
        icon = Icons.lock;
        break;
    }

    final isAccessible = status != LevelStatus.locked;

    return GestureDetector(
      onTap: isAccessible 
          ? () => _showLevelDetails(context, level, status, phaseColor, languageCode, l10n)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isAccessible
              ? [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Level number or icon
            if (icon != null)
              Icon(icon, color: iconColor, size: 24)
            else
              Text(
                '${level.level}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),

            // Progress badge for completed levels
            if (status == LevelStatus.completed)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LevelStatus _getLevelStatus(int levelNumber) {
    return LevelStatus.unlocked; // all levels accessible
  }

  void _showLevelDetails(
    BuildContext context,
    LevelConfig level,
    LevelStatus status,
    Color phaseColor,
    String languageCode,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LevelDetailSheet(
        level: level,
        status: status,
        phaseColor: phaseColor,
        languageCode: languageCode,
        l10n: l10n,
        onStart: () {
                Navigator.pop(context);
                context.push('/worksheet', extra: {
                  'child': widget.child,
                  'levelNumber': level.level,
                });
              },
      ),
    );
  }
}

/// Level progress data
class LevelProgress {
  final int level;
  final int bestScore;
  final int attempts;
  final bool isPassed;
  final DateTime? lastAttempt;

  const LevelProgress({
    required this.level,
    this.bestScore = 0,
    this.attempts = 0,
    this.isPassed = false,
    this.lastAttempt,
  });
}

/// Bottom sheet showing level details
class _LevelDetailSheet extends StatelessWidget {
  final LevelConfig level;
  final LevelStatus status;
  final Color phaseColor;
  final String languageCode;
  final AppLocalizations l10n;
  final VoidCallback? onStart;

  const _LevelDetailSheet({
    required this.level,
    required this.status,
    required this.phaseColor,
    required this.languageCode,
    required this.l10n,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Level header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: phaseColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${level.level}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.getTopic(languageCode),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            level.getDescription(languageCode),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _buildStat(Icons.help_outline, '${level.questionsPerWorksheet} ${l10n.question.toLowerCase()}s'),
              const SizedBox(width: 24),
              _buildStat(Icons.timer_outlined, '${level.timeMinutes} min'),
              const SizedBox(width: 24),
              _buildStat(Icons.check_circle_outline, '${(level.passPercentage * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 24),

          // Action button
          if (status == LevelStatus.inProgress && onStart != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: phaseColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.startWorksheet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color color;

    switch (status) {
      case LevelStatus.completed:
        text = l10n.completed;
        color = AppColors.levelCompleted;
        break;
      case LevelStatus.inProgress:
        text = l10n.inProgress;
        color = AppColors.levelInProgress;
        break;
      case LevelStatus.unlocked:
        text = l10n.unlocked;
        color = AppColors.levelUnlocked;
        break;
      case LevelStatus.locked:
        text = l10n.locked;
        color = AppColors.levelLocked;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
