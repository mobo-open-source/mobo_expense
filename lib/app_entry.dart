import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/widgets/loaders/loading_indicator.dart';
import '../features/login/pages/server_setup_screen.dart';
import '../features/login/pages/app_lock_screen.dart';
import '../core/services/session_service.dart';
import '../core/services/odoo_session_manager.dart';
import '../core/services/biometric_context_service.dart';
import '../core/routing/page_transition.dart';
import '../core/services/connectivity_service.dart';
import 'core/utils/module_not_installed.dart';
import 'features/home/loading.dart';

class AppEntry extends StatefulWidget {
  final bool skipBiometric;

  const AppEntry({super.key, this.skipBiometric = false});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late Future<Map<String, dynamic>> _initFuture;

  @override
  void initState() {
    super.initState();

    /// Start monitoring connectivity centrally
    ConnectivityService.instance.startMonitoring();
    _initFuture = _checkAuthStatus();
  }

  ///checking authenticated status
  Future<Map<String, dynamic>> _checkAuthStatus() async {
    await SessionService.instance.initialize();

    final prefs = await SharedPreferences.getInstance();
    final session = SessionService.instance.currentSession;

    final isLoggedIn = session != null;
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    bool sessionValid = false;

    if (isLoggedIn) {
      sessionValid = await OdooSessionManager.isSessionValid();
      if (!sessionValid) {
      } else {
        try {
          final client = await OdooSessionManager.getClientEnsured();

          final sessionInfo = await client.callRPC(
            '/web/session/get_session_info',
            'call',
            {},
          );

          final currentCompany = sessionInfo;
        } catch (e) {
          Navigator.pushReplacement(
            context,
            dynamicRoute(context, const ServerSetupScreen()),
          );
        }
      }
    }
    bool expenseInstalled = false;

    ///cheking session is valid and module is installed or not

    if (isLoggedIn && sessionValid) {
      try {
        final client = await OdooSessionManager.getClientEnsured();
        final count = await client.callKw({
          'model': 'ir.module.module',
          'method': 'search_count',
          'args': [
            [
              ['name', '=', 'hr_expense'],
              ['state', '=', 'installed'],
            ],
          ],
          'kwargs': {},
        });
        expenseInstalled = (count is int) ? count > 0 : (count as num) > 0;
      } catch (e) {
        Navigator.pushReplacement(
          context,
          dynamicRoute(context, const ServerSetupScreen()),
        );
      }
    }

    return {
      'isLoggedIn': isLoggedIn && sessionValid,
      'biometricEnabled': biometricEnabled,
      'expenseInstalled': expenseInstalled,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const ServerSetupScreen();
        }

        final isLoggedIn = snapshot.data!['isLoggedIn'] as bool;
        final biometricEnabled = snapshot.data!['biometricEnabled'] as bool;
        final expenseInstalled =
            snapshot.data!['expenseInstalled'] as bool? ?? false;

        /// Check if biometric should be skipped
        final biometricContext = BiometricContextService();
        final shouldSkipBiometric =
            widget.skipBiometric || biometricContext.shouldSkipBiometric;

        ///Show biometric lock screen if enabled and logged in
        if (biometricEnabled &&
            isLoggedIn &&
            !shouldSkipBiometric &&
            expenseInstalled) {
          return AppLockScreen(
            onAuthenticationSuccess: () {
              /// After biometric unlock, re-enter AppEntry (skipping biometric)
              /// so that startup checks (including inventory module check)
              /// can run and route either to HomeScaffold or MissingInventoryScreen.
              Navigator.pushReplacement(
                context,
                dynamicRoute(context, const AppEntry(skipBiometric: true)),
              );
            },
          );
        } else if (isLoggedIn) {
          if (!expenseInstalled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const ModuleMissingDialog(),
              );
            });

            ///  Login screen stays in the background
            return const ServerSetupScreen();
          }

          return const Loading();
        }

        /// Not logged in, show login screen
        return const ServerSetupScreen();
      },
    );
  }
}
