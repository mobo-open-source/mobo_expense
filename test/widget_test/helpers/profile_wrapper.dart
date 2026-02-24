import 'package:flutter/material.dart';
import 'package:mobo_expenses/core/services/session_service.dart';
import 'package:mobo_expenses/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

Widget profileWrapper({
  required Widget child,
  required ProfileProvider profileProvider,
  required SessionService sessionService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ChangeNotifierProvider<SessionService>.value(
        value: SessionService.instance,
      ),
    ],
    child: MaterialApp(home: child),
  );
}
