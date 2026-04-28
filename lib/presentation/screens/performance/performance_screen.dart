import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/worksheet_model.dart';
import '../../../data/repositories/worksheet_repository.dart';
import '../../widgets/cyber_widgets.dart';

/// Performance screen showing statistics and charts - Cyber Theme
class PerformanceScreen extends StatefulWidget {
  final ChildModel child;

  const PerformanceScreen({
    super.key,
    required this.child,
  });

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final WorksheetRepository _worksheetRepo = WorksheetRepository();
  List<WorksheetModel> _worksheets = [];
  bool _isLoading = true;
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: All Time

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final worksheets = await _worksheetRepo.getChildWorksheets(
        widget.child.id,
        limit: 365, // Up to a year of data
      );
      
      setState(() {
        _worksheets = worksheets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<WorksheetModel> get _filteredWorksheets {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 0: // This Week
        final weekStart = now.subtract(Duration(days: now.weekday % 7));
        return _worksheets.where((ws) =>
          ws.worksheetDate.isAfter(weekStart.subtract(const Duration(days: 1)))
        ).toList();
      case 1: // This Month
        return _worksheets.where((ws) =>
          ws.worksheetDate.year == now.year &&
          ws.worksheetDate.month == now.month
        ).toList();
      default: // All Time
        return _worksheets;
    }
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
          l10n.performance,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector
                      _buildPeriodSelector(l10n),
                      const SizedBox(height: 24),
                      
                      // Stats cards
                      _buildStatsCards(l10n),
                      const SizedBox(height: 24),
                      
                      // Score chart
                      _buildScoreChart(l10n),
                      const SizedBox(height: 24),
                      
                      // Recent worksheets
                      _buildRecentWorksheets(l10n),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    final periods = [l10n.thisWeek, l10n.thisMonth, l10n.allTime];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsCards(AppLocalizations l10n) {
    final filtered = _filteredWorksheets;
    final completed = filtered.where((ws) => ws.status == WorksheetStatus.completed).toList();
    
    final totalCompleted = completed.length;
    final avgScore = completed.isNotEmpty
        ? (completed.map((ws) => ws.scorePercentage).reduce((a, b) => a + b) / completed.length).round()
        : 0;
    final totalStars = completed.map((ws) => ws.starsEarned).fold(0, (a, b) => a + b);
    final totalTime = completed.map((ws) => ws.timeSpentSeconds).fold(0, (a, b) => a + b);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                totalCompleted.toString(),
                l10n.worksheetsCompleted,
                Icons.check_circle_rounded,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                '$avgScore%',
                l10n.averageScore,
                Icons.analytics_rounded,
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                totalStars.toString(),
                l10n.stars,
                Icons.star_rounded,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                '${widget.child.currentStreak}',
                l10n.currentStreak,
                Icons.local_fire_department_rounded,
                AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                _formatDuration(totalTime),
                l10n.timeTaken,
                Icons.timer_rounded,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                '${widget.child.longestStreak}',
                l10n.longestStreak,
                Icons.emoji_events_rounded,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChart(AppLocalizations l10n) {
    final filtered = _filteredWorksheets
        .where((ws) => ws.status == WorksheetStatus.completed)
        .toList()
        .reversed
        .take(10)
        .toList();
    
    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            l10n.noWorksheetToday,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    
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
            l10n.progressChart,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('d/M').format(filtered[index].worksheetDate),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      filtered.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        filtered[index].scorePercentage.toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  // Pass line at 95%
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 95),
                      FlSpot(filtered.length - 1.0, 95),
                    ],
                    isCurved: false,
                    color: AppColors.success.withOpacity(0.5),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 2,
                color: AppColors.success.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                '95% ${l10n.passed}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorksheets(AppLocalizations l10n) {
    final recent = _filteredWorksheets.take(5).toList();
    
    if (recent.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scoreHistory,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recent.map((ws) => _worksheetTile(ws)),
      ],
    );
  }

  Widget _worksheetTile(WorksheetModel ws) {
    final dateFormat = DateFormat('EEE, MMM d');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ws.passed
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${ws.scorePercentage}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ws.passed ? AppColors.success : AppColors.error,
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
                  dateFormat.format(ws.worksheetDate),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Level ${ws.level}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              3,
              (index) => Icon(
                Icons.star_rounded,
                size: 18,
                color: index < ws.starsEarned
                    ? AppColors.warning
                    : AppColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }
}
