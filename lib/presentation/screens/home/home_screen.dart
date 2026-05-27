import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../widgets/cyber_widgets.dart';

/// Home screen — cartoony kid-friendly dashboard.
class HomeScreen extends StatelessWidget {
  final ChildModel child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Soft polka-dot wash + a couple of pastel blob accents
          const Positioned.fill(child: CyberGridBackground()),
          Positioned(
            top: -40,
            right: -40,
            child: _blob(180, AppColors.accent.withValues(alpha: 0.25)),
          ),
          Positioned(
            top: 220,
            left: -60,
            child: _blob(160, AppColors.primaryLight.withValues(alpha: 0.18)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, l10n),
                  const SizedBox(height: 22),
                  _buildStatsBar(context),
                  const SizedBox(height: 24),
                  _buildWorksheetCard(context, l10n),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      l10n.explore,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildQuickAccessGrid(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // Avatar with rainbow ring (no neon glow)
        GestureDetector(
          onTap: () => context.go('/children'),
          child: Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.surface,
              backgroundImage: child.avatarUrl != null
                  ? NetworkImage(child.avatarUrl!)
                  : null,
              child: child.avatarUrl == null
                  ? Text(
                      child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontFamily: 'Nunito',
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.hello}, ${child.name}!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '${l10n.level} ${child.currentLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return GlowCard(
      glowColor: AppColors.primary,
      glowIntensity: 0.1,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(Icons.star_rounded, child.totalStars.toString(), 'Stars',
              AppColors.gold),
          _divider(),
          _stat(
            Icons.local_fire_department_rounded,
            '${child.currentStreak}',
            'Streak',
            child.isStreakActive ? AppColors.secondary : AppColors.textLight,
          ),
          _divider(),
          _stat(Icons.videogame_asset_rounded, child.gameTokens.toString(),
              'Tokens', AppColors.accent),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        height: 50,
        width: 1.2,
        color: AppColors.border,
      );

  Widget _buildWorksheetCard(BuildContext context, AppLocalizations l10n) {
    final didToday = child.didWorksheetToday;
    final accent = didToday ? AppColors.success : AppColors.secondary;

    return GestureDetector(
      onTap: didToday ? null : () => _startWorksheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: didToday
                ? const [Color(0xFF6BD3A3), Color(0xFF4CD964)]
                : const [Color(0xFFFFB07A), Color(0xFFFF8A3D)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
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
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    didToday
                        ? Icons.check_circle_rounded
                        : Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const Spacer(),
                if (!didToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          '~10 min',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              didToday ? l10n.worksheetCompleted : l10n.todaysWorksheet,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              didToday ? l10n.comeBackTomorrow : l10n.worksheetDescription,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
              ),
            ),
            if (!didToday) ...[
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: CyberButton(
                  text: l10n.startNow,
                  icon: Icons.play_arrow_rounded,
                  color: Colors.white,
                  textColor: AppColors.secondaryDark,
                  height: 50,
                  onPressed: () => _startWorksheet(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, AppLocalizations l10n) {
    final items = <_QuickAccessItem>[
      _QuickAccessItem(
        icon: Icons.map_rounded,
        label: l10n.levelMap,
        color: AppColors.primary,
        route: '/levels',
      ),
      _QuickAccessItem(
        icon: Icons.calendar_month_rounded,
        label: l10n.calendar,
        color: AppColors.accentDark,
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
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _buildQuickAccessCard(context, items[index]),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, _QuickAccessItem item) {
    return GlowCard(
      glowColor: item.color,
      glowIntensity: 0.14,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push(item.route, extra: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color,
                      Color.lerp(item.color, Colors.white, 0.35)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.35),
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(item.icon, color: Colors.white, size: 28),
              ),
              if (item.badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
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
