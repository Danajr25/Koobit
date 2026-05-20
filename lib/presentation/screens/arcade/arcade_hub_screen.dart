import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/child_model.dart';
import '../../widgets/cyber_widgets.dart';

/// Hub showing all three arcade mini-games.
class ArcadeHubScreen extends StatefulWidget {
  final ChildModel child;

  const ArcadeHubScreen({super.key, required this.child});

  @override
  State<ArcadeHubScreen> createState() => _ArcadeHubScreenState();
}

class _ArcadeHubScreenState extends State<ArcadeHubScreen> {
  Map<String, int> _highScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _highScores = {
        'flappy': prefs.getInt('arcade_hs_flappy_${widget.child.id}') ?? 0,
        'balloon': prefs.getInt('arcade_hs_balloon_${widget.child.id}') ?? 0,
        'runner': prefs.getInt('arcade_hs_runner_${widget.child.id}') ?? 0,
      };
      _isLoading = false;
    });
  }

  static const _games = [
    _ArcadeGameDef(
      key: 'flappy',
      title: 'Flappy Math Bird',
      subtitle: 'Tap to flap — answer math questions for bonus points',
      icon: Icons.flutter_dash_rounded,
      color: Color(0xFF00D4FF),
      route: '/arcade/flappy',
      available: true,
    ),
    _ArcadeGameDef(
      key: 'balloon',
      title: 'Balloon Pop',
      subtitle: 'Pop the balloon with the correct answer before it escapes',
      icon: Icons.bubble_chart_rounded,
      color: Color(0xFFBF5AF2),
      route: '/arcade/balloon',
      available: true,
    ),
    _ArcadeGameDef(
      key: 'runner',
      title: 'Math Runner',
      subtitle: 'Jump over obstacles by answering correctly',
      icon: Icons.directions_run_rounded,
      color: Color(0xFFFF9500),
      route: '/arcade/runner',
      available: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Arcade Games',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CyberGridBackground()),
          if (_isLoading)
            const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
          else
            ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _games.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) =>
                  _buildCard(ctx, _games[i], _highScores[_games[i].key] ?? 0),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, _ArcadeGameDef game, int highScore) {
    final color = game.available ? game.color : AppColors.border;

    return GlowCard(
      glowColor: color,
      glowIntensity: game.available ? 0.22 : 0.04,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: game.available
            ? () async {
                await context.push(game.route, extra: widget.child);
                _loadScores();
              }
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                game.icon,
                color: game.available ? game.color : AppColors.textSecondary,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: TextStyle(
                      color: game.available
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        game.available
                            ? Icons.emoji_events_rounded
                            : Icons.lock_rounded,
                        color: game.available
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        game.available ? 'Best: $highScore pts' : 'Coming soon',
                        style: TextStyle(
                          color: game.available
                              ? AppColors.warning
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (game.available)
              Icon(Icons.play_circle_rounded, color: game.color, size: 44)
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Soon',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArcadeGameDef {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final bool available;

  const _ArcadeGameDef({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.available,
  });
}
