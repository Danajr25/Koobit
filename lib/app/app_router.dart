import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/models/child_model.dart';
import '../data/repositories/repositories.dart';
import '../presentation/blocs/auth/auth.dart';
import '../presentation/blocs/child/child.dart';
import '../presentation/blocs/progress/progress.dart';
import '../presentation/screens/auth/auth_screens.dart';
import '../presentation/screens/child_selection/child_selection_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/games/games_screen.dart';
import '../presentation/screens/level_map/level_map_screen.dart';
import '../presentation/screens/worksheet/worksheet_screen.dart';
import '../presentation/screens/results/results_screen.dart';
import '../presentation/screens/corrections/corrections_screen.dart';
import '../presentation/screens/calendar/calendar_screen.dart';
import '../presentation/screens/performance/performance_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/subscription/subscription_screen.dart';
import '../presentation/screens/parent_dashboard/parent_dashboard_screen.dart';
import '../presentation/screens/arcade/arcade_hub_screen.dart';
import '../presentation/screens/arcade/flappy_math_screen.dart';
import '../presentation/screens/arcade/balloon_pop_screen.dart';
import '../presentation/screens/arcade/math_runner_screen.dart';
import '../presentation/screens/arcade/animal_rescue_screen.dart';
import '../presentation/screens/arcade/cannon_aim_screen.dart';
import '../presentation/screens/arcade/snowball_fight_screen.dart';
import '../data/models/question_model.dart';

/// App route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String childSelection = '/children';
  static const String home = '/home';
  static const String levels = '/levels';
  static const String worksheet = '/worksheet';
  static const String results = '/results';
  static const String corrections = '/corrections';
  static const String calendar = '/calendar';
  static const String performance = '/performance';
  static const String games = '/games';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String parentDashboard = '/parent-dashboard';
  static const String arcade = '/arcade';
  static const String arcadeFlappy = '/arcade/flappy';
  static const String arcadeBalloon = '/arcade/balloon';
  static const String arcadeRunner = '/arcade/runner';
  static const String arcadeAnimalRescue = '/arcade/animal-rescue';
  static const String arcadeCannonAim = '/arcade/cannon-aim';
  static const String arcadeSnowball = '/arcade/snowball';
}

/// App router configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Create router instance
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState.status == AuthStatus.authenticated;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.forgotPassword;
        final isSplash = state.matchedLocation == AppRoutes.splash;

        // While loading, stay on splash
        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return isSplash ? null : AppRoutes.splash;
        }

        // Not authenticated, redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return AppRoutes.login;
        }

        // Authenticated but on auth route, redirect to child selection
        if (isAuthenticated && (isAuthRoute || isSplash)) {
          return AppRoutes.childSelection;
        }

        return null;
      },
      routes: [
        // Splash screen
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const _SplashScreen(),
        ),
        // Auth routes
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => LoginScreen(
            onRegisterTap: () => context.go(AppRoutes.register),
            onForgotPasswordTap: () => context.go(AppRoutes.forgotPassword),
            onLoginSuccess: () => context.go(AppRoutes.childSelection),
          ),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => RegisterScreen(
            onLoginTap: () => context.go(AppRoutes.login),
            onRegisterSuccess: () => context.go(AppRoutes.childSelection),
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => ForgotPasswordScreen(
            onBackTap: () => context.go(AppRoutes.login),
            onResetSuccess: () => context.go(AppRoutes.login),
          ),
        ),
        // Child selection
        GoRoute(
          path: AppRoutes.childSelection,
          builder: (context, state) => BlocProvider(
            create: (context) => ChildBloc(
              childRepository: context.read<ChildRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
            child: ChildSelectionScreen(
              onChildSelected: (child) {
                // TODO: Navigate to home with selected child
                context.go(AppRoutes.home, extra: child);
              },
              onLogout: () => context.go(AppRoutes.login),
            ),
          ),
        ),
        // Home
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              // Redirect to child selection if no child
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return HomeScreen(child: child);
          },
        ),
        // Placeholder routes for other screens
        GoRoute(
          path: AppRoutes.levels,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return LevelMapScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.worksheet,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) {
              return const _PlaceholderScreen(title: 'No Worksheet Data');
            }
            final child = extra['child'] as ChildModel?;
            final levelNumber = extra['levelNumber'] as int?;
            if (child == null || levelNumber == null) {
              return const _PlaceholderScreen(title: 'Invalid Worksheet Data');
            }
            return WorksheetScreen(child: child, levelNumber: levelNumber);
          },
        ),
        GoRoute(
          path: AppRoutes.results,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) {
              return const _PlaceholderScreen(title: 'No Results Data');
            }
            return BlocProvider(
              create: (context) => ProgressBloc(
                childRepository: context.read<ChildRepository>(),
                worksheetRepository: context.read<WorksheetRepository>(),
              ),
              child: ResultsScreen(
                child: extra['child'] as ChildModel,
                levelNumber: extra['levelNumber'] as int,
                correctCount: extra['correctCount'] as int,
                totalQuestions: extra['totalQuestions'] as int,
                percentage: extra['percentage'] as double,
                stars: extra['stars'] as int,
                passed: extra['passed'] as bool,
                worksheetId: extra['worksheetId'] as String,
                questions: extra['questions'] as List<QuestionModel>,
                answers: extra['answers'] as Map<int, String>,
                results: extra['results'] as Map<int, bool?>,
                timeSpentSeconds: extra['timeSpentSeconds'] as int? ?? 0,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.corrections,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) {
              return const _PlaceholderScreen(title: 'No Corrections Data');
            }
            return CorrectionsScreen(
              child: extra['child'] as ChildModel,
              levelNumber: extra['levelNumber'] as int,
              worksheetId: extra['worksheetId'] as String,
              incorrectQuestions: extra['incorrectQuestions'] as List<QuestionModel>,
              originalAnswers: extra['originalAnswers'] as Map<int, String>,
              totalQuestions: extra['totalQuestions'] as int,
              originalCorrectCount: extra['originalCorrectCount'] as int,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.calendar,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return CalendarScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.performance,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return PerformanceScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.games,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return GamesHubScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.subscription,
          builder: (context, state) => const SubscriptionScreen(),
        ),
        GoRoute(
          path: AppRoutes.parentDashboard,
          builder: (context, state) => const ParentDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.arcade,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return ArcadeHubScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.arcadeFlappy,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return FlappyMathScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.arcadeBalloon,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return BalloonPopScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.arcadeRunner,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return MathRunnerScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.arcadeAnimalRescue,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return AnimalRescueScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.arcadeCannonAim,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return CannonAimScreen(child: child);
          },
        ),
        GoRoute(
          path: AppRoutes.arcadeSnowball,
          builder: (context, state) {
            final child = state.extra as ChildModel?;
            if (child == null) {
              return const _PlaceholderScreen(title: 'No Child Selected');
            }
            return SnowballFightScreen(child: child);
          },
        ),
      ],
    );
  }
}

/// Stream wrapper for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}

/// Splash screen widget
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF9D8DFF),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate_rounded,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Math Learning',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Fun math for kids',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontFamily: 'Nunito',
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for unimplemented routes
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
