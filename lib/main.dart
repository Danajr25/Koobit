import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app/app_router.dart';
import 'core/constants/env.dart';
import 'core/constants/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/services/locale_notifier.dart';
import 'core/l10n/app_localizations.dart';
import 'data/repositories/repositories.dart';
import 'presentation/blocs/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  await SupabaseService.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Read stored locale before first frame
  final localeNotifier = await LocaleNotifier.create();

  // Run the app
  runApp(MathLearningApp(localeNotifier: localeNotifier));
}

/// Main app widget
class MathLearningApp extends StatelessWidget {
  final LocaleNotifier localeNotifier;
  const MathLearningApp({super.key, required this.localeNotifier});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<ChildRepository>(
          create: (_) => ChildRepository(),
        ),
        RepositoryProvider<WorksheetRepository>(
          create: (_) => WorksheetRepository(),
        ),
      ],
      child: ChangeNotifierProvider<LocaleNotifier>.value(
        value: localeNotifier,
        child: const AppView(),
      ),
    );
  }
}

/// App view with MaterialApp.router
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authRepository: AuthRepository(),
    );
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = context.watch<LocaleNotifier>();
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Math Learning App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        locale: localeNotifier.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}

