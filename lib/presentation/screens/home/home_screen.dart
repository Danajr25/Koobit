import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../widgets/cyber_widgets.dart';

/// Home screen showing child's dashboard - Cyber Theme
class HomeScreen extends StatelessWidget {
  final ChildModel child;

  const HomeScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Grid background
          const Positioned.fill(
            child: CyberGridBackground(),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with child info
                  _buildHeader(context, l10n),
                  const SizedBox(height: 24),

                  // Stats bar
                  _buildStatsBar(context),
                  const SizedBox(height: 24),

                  // Today's worksheet card
                  _buildWorksheetCard(context, l10n),
                  const SizedBox(height: 24),

                  // Quick access grid
                  Text(
                    l10n.explore,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickAccessGrid(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // Avatar with glow
        GestureDetector(
          onTap: () => _showChildSwitcher(context),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.surface,
              backgroundImage:
                  child.avatarUrl != null ? NetworkImage(child.avatarUrl!) : null,
              child: child.avatarUrl == null
                  ? Text(
                      child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Greeting and level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.hello}, ${child.name}! 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${l10n.level} ${child.currentLevel}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Settings button
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return GlowCard(
      glowColor: AppColors.primary,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.star_rounded,
            child.totalStars.toString(),
            'Stars',
            AppColors.gold,
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            Icons.local_fire_department_rounded,
            '${child.currentStreak}',
            'Streak',
            child.isStreakActive ? AppColors.secondary : AppColors.textLight,
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            Icons.videogame_asset_rounded,
            child.gameTokens.toString(),
            'Tokens',
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildWorksheetCard(BuildContext context, AppLocalizations l10n) {
    final didToday = child.didWorksheetToday;

    return GestureDetector(
      onTap: didToday ? null : () => _startWorksheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: didToday
                ? [AppColors.success.withOpacity(0.8), AppColors.successDark]
                : [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (didToday ? AppColors.success : AppColors.primary).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (didToday ? AppColors.success : AppColors.primary)
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    didToday ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const Spacer(),
                if (!didToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '~10 min',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              didToday
                  ? l10n.worksheetCompleted
                  : l10n.todaysWorksheet,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              didToday
                  ? l10n.comeBackTomorrow
                  : l10n.worksheetDescription,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            if (!didToday) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  l10n.startNow,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, AppLocalizations l10n) {
    final items = [
      _QuickAccessItem(
        icon: Icons.map_rounded,
        label: l10n.levelMap,
        color: AppColors.primary,
        route: '/levels',
      ),
      _QuickAccessItem(
        icon: Icons.calendar_month_rounded,
        label: l10n.calendar,
        color: AppColors.accent,
        route: '/calendar',
      ),
      _QuickAccessItem(
        icon: Icons.bar_chart_rounded,
        label: l10n.performance,
        color: AppColors.secondary,
        route: '/performance',
      ),
      _QuickAccessItem(
        icon: Icons.sports_esports_rounded,
        label: l10n.games,
        color: AppColors.success,
        route: '/games',
        badge: child.gameTokens > 0 ? child.gameTokens.toString() : null,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildQuickAccessCard(context, item);
      },
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, _QuickAccessItem item) {
    return GestureDetector(
      onTap: () => context.push(item.route, extra: child),
      child: GlowCard(
        glowColor: item.color,
        glowIntensity: 0.2,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.color.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(item.icon, color: item.color),
                ),
                if (item.badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            Text(
              item.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChildSwitcher(BuildContext context) {
    context.go('/children');
  }

  void _startWorksheet(BuildContext context) {
    context.push('/worksheet', extra: {
      'child': child,
      'levelNumber': child.currentLevel,
    });
  }
}

class _QuickAccessItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final String? badge;

  _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    this.badge,
  });
}
