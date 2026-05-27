import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../widgets/cyber_widgets.dart';

/// Games hub – shows the three arcade mini-games.
///
/// (The old Math Builder / Number Pet / Space Math Explorer scene-based games
/// and the shared item inventory have been removed in favor of the more
/// engaging arcade experiences.)
class GamesHubScreen extends StatefulWidget {
  final ChildModel child;

  const GamesHubScreen({super.key, required this.child});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  bool _isLoading = true;
  Map<String, int> _highScores = const {};

  static const _games = <_ArcadeGameDef>[
    _ArcadeGameDef(
      key: 'flappy',
      title: 'Flappy Math Bird',
      subtitle: 'Tap to flap, dodge pipes and answer for bonus points',
      icon: Icons.flutter_dash_rounded,
      color: Color(0xFF38C7E5),
      route: AppRoutes.arcadeFlappy,
    ),
    _ArcadeGameDef(
      key: 'balloon',
      title: 'Balloon Pop',
      subtitle: 'Pop the balloon showing the correct answer before it escapes',
      icon: Icons.bubble_chart_rounded,
      color: Color(0xFFE56DD3),
      route: AppRoutes.arcadeBalloon,
    ),
    _ArcadeGameDef(
      key: 'runner',
      title: 'Math Runner',
      subtitle: 'Run, jump and slide – pick the right answer to score',
      icon: Icons.directions_run_rounded,
      color: Color(0xFFFF8A3D),
      route: AppRoutes.arcadeRunner,
    ),
  ];

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
        for (final g in _games)
          g.key: prefs.getInt('arcade_hs_${g.key}_${widget.child.id}') ?? 0,
      };
      _isLoading = false;
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
        title: Text(
          l10n.games,
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  ..._games.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGameCard(g),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return GlowCard(
      glowColor: AppColors.primary,
      glowIntensity: 0.18,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.textOnPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a game and beat your high score!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(_ArcadeGameDef game) {
    final highScore = _highScores[game.key] ?? 0;

    return GlowCard(
      glowColor: game.color,
      glowIntensity: 0.22,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.push(game.route, extra: widget.child);
          _loadScores();
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: game.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(game.icon, color: game.color, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.emoji_events_rounded,
                          size: 14, color: game.color),
                      const SizedBox(width: 4),
                      Text(
                        'Best: $highScore',
                        style: TextStyle(
                          color: game.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: game.color, size: 18),
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

  const _ArcadeGameDef({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
