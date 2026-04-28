import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/worksheet_model.dart';
import '../../../data/repositories/worksheet_repository.dart';
import '../../widgets/cyber_widgets.dart';

/// Calendar screen showing worksheet history - Cyber Theme
class CalendarScreen extends StatefulWidget {
  final ChildModel child;

  const CalendarScreen({
    super.key,
    required this.child,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  final WorksheetRepository _worksheetRepo = WorksheetRepository();
  Map<DateTime, WorksheetModel> _worksheets = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    setState(() => _isLoading = true);
    
    try {
      final worksheets = await _worksheetRepo.getChildWorksheets(
        widget.child.id,
        limit: 100,
      );
      
      final Map<DateTime, WorksheetModel> worksheetMap = {};
      for (final ws in worksheets) {
        final date = DateTime(
          ws.worksheetDate.year,
          ws.worksheetDate.month,
          ws.worksheetDate.day,
        );
        worksheetMap[date] = ws;
      }
      
      setState(() {
        _worksheets = worksheetMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          l10n.calendar,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CyberGridBackground()),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Legend
                      _buildLegend(l10n),
                      const SizedBox(height: 20),
                      
                      // Calendar
                      _buildCalendar(context),
                      const SizedBox(height: 24),
                      
                      // Selected day info or monthly summary
                      _buildMonthlySummary(l10n),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppColors.success, l10n.completed),
        _legendItem(AppColors.error, l10n.missed),
        _legendItem(AppColors.warning, l10n.inProgress),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return GlowCard(
      glowColor: AppColors.primary,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month header
          _buildMonthHeader(),
          const SizedBox(height: 16),
          
          // Weekday headers
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthFormat = DateFormat('MMMM yyyy');
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.primary,
        ),
        Text(
          monthFormat.format(_focusedMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    List<Widget> rows = [];
    List<Widget> currentRow = [];
    
    // Add empty cells for days before the first of the month
    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(_buildEmptyDay());
    }
    
    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final worksheet = _worksheets[date];
      
      currentRow.add(_buildDayCell(day, date, worksheet, todayNormalized));
      
      if (currentRow.length == 7) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: currentRow,
        ));
        currentRow = [];
      }
    }
    
    // Complete the last row if needed
    while (currentRow.isNotEmpty && currentRow.length < 7) {
      currentRow.add(_buildEmptyDay());
    }
    if (currentRow.isNotEmpty) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: currentRow,
      ));
    }
    
    return Column(children: rows.map((row) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: row,
    )).toList());
  }

  Widget _buildEmptyDay() {
    return const SizedBox(width: 40, height: 40);
  }

  Widget _buildDayCell(int day, DateTime date, WorksheetModel? worksheet, DateTime today) {
    final isToday = date == today;
    final isFuture = date.isAfter(today);
    
    Color? bgColor;
    Color textColor = AppColors.textPrimary;
    
    if (worksheet != null) {
      switch (worksheet.status) {
        case WorksheetStatus.completed:
          bgColor = worksheet.passed ? AppColors.success : AppColors.success.withOpacity(0.6);
          textColor = Colors.white;
          break;
        case WorksheetStatus.inProgress:
        case WorksheetStatus.submitted:
        case WorksheetStatus.correcting:
          bgColor = AppColors.warning;
          textColor = Colors.white;
          break;
        case WorksheetStatus.notStarted:
          if (!isFuture) {
            bgColor = AppColors.error.withOpacity(0.7);
            textColor = Colors.white;
          }
          break;
      }
    } else if (!isFuture && !isToday) {
      // Past day with no worksheet = missed (only if child was active by then)
      // For now, leave it empty (gray)
    }
    
    return GestureDetector(
      onTap: worksheet != null ? () => _showWorksheetDetails(worksheet) : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isFuture ? AppColors.textSecondary.withOpacity(0.5) : textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showWorksheetDetails(WorksheetModel worksheet) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(worksheet.worksheetDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _detailRow('${l10n.level}:', '${worksheet.level}'),
            _detailRow('${l10n.score}:', '${worksheet.scorePercentage}%'),
            _detailRow('${l10n.correct}:', '${worksheet.correctCount}/${worksheet.totalQuestions}'),
            _detailRow(l10n.stars, '⭐' * worksheet.starsEarned),
            _detailRow(l10n.timeTaken, _formatTime(worksheet.timeSpentSeconds)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.close,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  Widget _buildMonthlySummary(AppLocalizations l10n) {
    final monthStart = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final monthEnd = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    int completed = 0;
    int totalScore = 0;
    int totalStars = 0;
    
    _worksheets.forEach((date, ws) {
      if (date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          date.isBefore(monthEnd.add(const Duration(days: 1)))) {
        if (ws.status == WorksheetStatus.completed) {
          completed++;
          totalScore += ws.scorePercentage;
          totalStars += ws.starsEarned;
        }
      }
    });
    
    final avgScore = completed > 0 ? (totalScore / completed).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.thisMonth,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  completed.toString(),
                  l10n.worksheetsCompleted,
                  Icons.check_circle_rounded,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  '$avgScore%',
                  l10n.averageScore,
                  Icons.analytics_rounded,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  totalStars.toString(),
                  l10n.stars,
                  Icons.star_rounded,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
