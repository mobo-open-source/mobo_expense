import 'package:flutter/material.dart';
import 'package:mobo_expenses/core/services/session_service.dart';
import 'package:mobo_expenses/features/company/providers/company_provider.dart';
import 'package:mobo_expenses/features/profile/providers/profile_provider.dart';
import 'package:mobo_expenses/provider/bottom_nav_provider.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';

Widget homeWrapper({
  required Widget child,
  required ExpenseProvider expenseProvider,
  required CommonProvider commonProvider,
  required UserProvider userProvider,
  required ProfileProvider profileProvider,
  required SessionService sessionService,
  required BottomNavProvider bottomNavProvider,
  required CompanyProvider companyProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
      ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
      ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ChangeNotifierProvider<BottomNavProvider>.value(value: bottomNavProvider),
      ChangeNotifierProvider<CompanyProvider>.value(value: companyProvider),

      ChangeNotifierProvider<SessionService>.value(
        value: SessionService.instance,
      ),
    ],
    child: MaterialApp(home: child),
  );
}
