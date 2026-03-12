import 'package:flutter/material.dart';
import 'package:mobo_expenses/provider/auth_provider.dart';
import 'package:mobo_expenses/provider/bottom_nav_provider.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/split_expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:mobo_expenses/services/common_service.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/constants/keys/global_keys.dart';
import 'core/providers/logout_view_model.dart';
import 'core/services/session_service.dart';
import 'core/theme/theme_provider.dart';
import 'features/company/providers/company_provider.dart';
import 'features/home/home_screen.dart';
import 'features/login/pages/credentials_screen.dart';
import 'features/login/pages/server_setup_screen.dart';
import 'features/login/providers/login_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/review/services/review_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/splash_screen/splash_screen.dart';

void main({bool isTest = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ValueListenableBuilder<int>(
      valueListenable: providerResetKey,
      builder: (_, value, _) {
        return MultiProvider(
          providers: [
            Provider<ExpenseServices>(create: (_) => ExpenseServices()),
            Provider<CommonServices>(create: (_) => CommonServices()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => BottomNavProvider()),
            ChangeNotifierProvider(
              create: (context) =>
                  ExpenseProvider(services: context.read<ExpenseServices>()),
            ),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(
              create: (context) => CommonProvider(
                commonServices: context.read<CommonServices>(),
              ),
            ),
            ChangeNotifierProvider<LoginProvider>(
              create: (_) => LoginProvider(),
            ),
            ChangeNotifierProvider(create: (_) => SplitExpenseProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LogoutViewModel()),
            ChangeNotifierProvider<SessionService>.value(
              value: SessionService.instance,
            ),

            /// Provide CompanyProvider globally and initialize companies on app start
            ChangeNotifierProvider(
              create: (_) {
                final p = CompanyProvider();

                /// Kick off initial load from server; will show loading in selector
                p.initialize();
                return p;
              },
            ),
          ],
          child: MyApp(isTest: isTest),
        );
      },
    ),
  );
}

final ValueNotifier<int> providerResetKey = ValueNotifier(0);

class MyApp extends StatefulWidget {
  final bool isTest;
  const MyApp({super.key, this.isTest = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
    // Track app open for review system after a delay to ensure activity is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        ReviewService().trackAppOpen();
      });
    });
  }
  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,

          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.themeMode,
          routes: {
            '/server_setup': (_) => const ServerSetupScreen(),
            '/home': (_) => const HomeScreen(),
          },

          home: SplashScreen(isTest: widget.isTest),
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => CredentialsScreen(
                  url: (args?['url'] ?? '') as String,
                  database: (args?['database'] ?? '') as String,
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
