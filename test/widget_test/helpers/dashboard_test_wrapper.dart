import 'package:flutter/material.dart';
import 'package:mobo_expenses/features/profile/providers/profile_provider.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';

Widget dashBoardWrapper({
  required Widget child,
  required ExpenseProvider expenseProvider,
  required CommonProvider commonProvider,
  required UserProvider userProvider,
  required ProfileProvider profileProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
      ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
      ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
    ],
    child: MaterialApp(home: child),
  );
}
