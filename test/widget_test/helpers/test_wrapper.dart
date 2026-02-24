import 'package:flutter/material.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';

Widget wrapWithProviders({
  required Widget child,
  required ExpenseProvider expenseProvider,
  required CommonProvider commonProvider,
  required UserProvider userProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
      ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
      ChangeNotifierProvider<UserProvider>.value(value: userProvider),
    ],
    child: MaterialApp(home: child),
  );
}
