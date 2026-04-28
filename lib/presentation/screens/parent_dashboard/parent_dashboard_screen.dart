import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/worksheet_model.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/worksheet_repository.dart';
import '../../blocs/auth/auth.dart';
import '../../widgets/cyber_widgets.dart';

/// Parent Dashboard screen for monitoring children's progress - Cyber Theme
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final ChildRepository _childRepo = ChildRepository();
  final WorksheetRepository _worksheetRepo = WorksheetRepository();
  
  List<ChildModel> _children = [];
  Map<String, List<WorksheetModel>> _childWorksheets = {};
  bool _isLoading = true;
  int _selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.status == AuthStatus.authenticated && authState.user != null) {
        final children = await _childRepo.getChildren(authState.user!.id);
        
        final Map<String, List<WorksheetModel>> worksheets = {};
        for (final child in children) {
          worksheets[child.id] = await _worksheetRepo.getChildWorksheets(
            child.id,
            limit: 30,
          );
        }
        
        setState(() {
          _children = children;
          _childWorksheets = worksheets;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  ChildModel? get _selectedChild =>
      _children.isNotEmpty ? _children[_selectedChildIndex] : null;

  List<WorksheetModel> get _selectedChildWorksheets =>
      _selectedChild != null ? _childWorksheets[_selectedChild!.id] ?? [] : [];

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
          l10n.parentDashboard,
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
              : _children.isEmpty
                  ? _buildEmptyState(l10n)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Child selector
                          if (_children.length > 1) ...[
                            _buildChildSelector(),
                            const SizedBox(height: 24),
                          ],
                          
                          // Child overview card
                          _buildChildOverview(l10n),
                          const SizedBox(height: 24),
                          
                          // Quick stats
                          _buildQuickStats(l10n),
                          const SizedBox(height: 24),
                          
                          // Level management
                          _buildLevelManagement(l10n),
                          const SizedBox(height: 24),
                          
                          // Recent activity
                          _buildRecentActivity(l10n),
                          const SizedBox(height: 24),
                          
                          // Weekly summary
                          _buildWeeklySummary(l10n),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No children profiles yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a child profile to get started',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          final isSelected = index == _selectedChildIndex;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedChildIndex = index),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    child: Text(
                      child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    child.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChildOverview(AppLocalizations l10n) {
    final child = _selectedChild;
    if (child == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.level} ${child.currentLevel}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _overviewBadge(
                      Icons.local_fire_department_rounded,
                      '${child.currentStreak} day streak',
                    ),
                    const SizedBox(width: 12),
                    _overviewBadge(
                      Icons.star_rounded,
                      '${child.totalStars} stars',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations l10n) {
    final worksheets = _selectedChildWorksheets;
    final completed = worksheets.where((w) => w.status == WorksheetStatus.completed).toList();
    
    final thisWeekCompleted = completed.where((w) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return w.worksheetDate.isAfter(weekAgo);
    }).length;
    
    final avgScore = completed.isNotEmpty
        ? (completed.map((w) => w.scorePercentage).reduce((a, b) => a + b) / completed.length).round()
        : 0;
    
    return Row(
      children: [
        Expanded(
          child: _statCard(
            thisWeekCompleted.toString(),
            l10n.thisWeek,
            Icons.calendar_today_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            '$avgScore%',
            l10n.averageScore,
            Icons.analytics_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            completed.length.toString(),
            'Total',
            Icons.check_circle_rounded,
            AppColors.secondary,
          ),
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
      child: Column(
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
      ),
    );
  }

  Widget _buildLevelManagement(AppLocalizations l10n) {
    final child = _selectedChild;
    if (child == null) return const SizedBox.shrink();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.levelManagement,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current Level: ${child.currentLevel}',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showUnlockLevelDialog(child),
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: const Text('Unlock Level'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: child.currentLevel / 56, // Total levels
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '${child.currentLevel}/56 levels completed',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlockLevelDialog(ChildModel child) {
    final l10n = AppLocalizations.of(context);
    final levelController = TextEditingController();
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlock Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the level number you want to unlock for this child.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: levelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Level Number (1-56)',
                border: const OutlineInputBorder(),
                hintText: 'e.g., ${child.currentLevel + 1}',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Parent PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final level = int.tryParse(levelController.text);
              if (level != null && level >= 1 && level <= 56) {
                // TODO: Implement actual level unlock
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Level $level unlocked for ${child.name}')),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AppLocalizations l10n) {
    final worksheets = _selectedChildWorksheets.take(5).toList();
    
    if (worksheets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

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
        ...worksheets.map((ws) => _activityTile(ws)),
      ],
    );
  }

  Widget _activityTile(WorksheetModel ws) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                  fontSize: 14,
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
                  'Level ${ws.level}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  dateFormat.format(ws.worksheetDate),
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
                size: 16,
                color: index < ws.starsEarned ? AppColors.warning : AppColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(AppLocalizations l10n) {
    final worksheets = _selectedChildWorksheets;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Get worksheets for each day of the week
    final weekData = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final ws = worksheets.where((w) =>
        w.worksheetDate.year == day.year &&
        w.worksheetDate.month == day.month &&
        w.worksheetDate.day == day.day
      ).toList();
      return ws.isNotEmpty ? ws.first : null;
    });

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
            l10n.weeklyReport,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final ws = weekData[index];
              final isToday = index == now.weekday - 1;
              final isPast = index < now.weekday - 1;
              
              Color bgColor;
              IconData? icon;
              
              if (ws != null && ws.status == WorksheetStatus.completed) {
                bgColor = ws.passed ? AppColors.success : AppColors.warning;
                icon = Icons.check_rounded;
              } else if (isPast) {
                bgColor = AppColors.error.withOpacity(0.7);
                icon = Icons.close_rounded;
              } else if (isToday) {
                bgColor = AppColors.primary;
                icon = Icons.today_rounded;
              } else {
                bgColor = AppColors.border;
                icon = null;
              }
              
              return Column(
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: icon != null
                        ? Icon(icon, color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
