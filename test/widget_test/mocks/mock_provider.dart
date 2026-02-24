import 'package:flutter/material.dart';
import 'package:mobo_expenses/core/services/session_service.dart';
import 'package:mobo_expenses/features/company/providers/company_provider.dart';
import 'package:mobo_expenses/features/profile/providers/profile_provider.dart';
import 'package:mobo_expenses/provider/bottom_nav_provider.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';

class MockExpenseProvider extends Mock implements ExpenseProvider {}

class MockCommonProvider extends Mock implements CommonProvider {}

class MockProfileProvider extends Mock implements ProfileProvider {}

class MockBottomProvider extends Mock implements BottomNavProvider {}

class MockCompanyProvider extends Mock implements CompanyProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockSessionService extends Mock implements SessionService {}
