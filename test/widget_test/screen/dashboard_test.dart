import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/dashboard_screen.dart';
import 'package:mobo_expenses/features/profile/providers/profile_provider.dart';
import 'package:mobo_expenses/model/company_expense_model.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/user_model.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart'
    show MultiProvider, ChangeNotifierProvider;

import '../../mocks/mock.dart';
import '../helpers/dashboard_test_wrapper.dart';
import '../mocks/mock_provider.dart';

class MockServices extends Mock implements ExpenseServices {}

void main() {
  late MockExpenseProvider expenseProvider;
  late MockCommonProvider commonProvider;
  late MockProfileProvider profileProvider;
  late MockUserProvider userProvider;
  late MockServices mockServices;
  late MockCommonServices mockCommonServices;

  setUp(() {
    expenseProvider = MockExpenseProvider();
    commonProvider = MockCommonProvider();
    userProvider = MockUserProvider();
    profileProvider = MockProfileProvider();
    mockCommonServices = MockCommonServices();
    mockServices = MockServices();
    registerFallbackValue(FakeBuildContext());

    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => userProvider.isLoading).thenReturn(false);
    when(() => profileProvider.isLoading).thenReturn(false);
    when(() => userProvider.getGreeting()).thenReturn("good morning");
    when(() => expenseProvider.loadedExpense).thenReturn([]);
    when(() => expenseProvider.expenses).thenReturn([]);
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => profileProvider.userData).thenReturn({'name': "fake"});

    when(
      () => userProvider.currentEmployee,
    ).thenReturn(Employee(id: 1, name: "fake", workPhone: "122"));
  });

  testWidgets("dashBoard screen renders without crashing", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dashBoardWrapper(
        child: DashboardScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
        profileProvider: profileProvider,
      ),
    );

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets("dashboard - employee not get", (WidgetTester tester) async {
    final profile = ProfileProvider();
    profile.setUserData({'name': 'fake'});

    final userProvider = UserProvider();
    userProvider.isLoading = false;

    userProvider.user = null;

    final expenseProvider = ExpenseProvider(services: mockServices);
    expenseProvider.changeLoading(false);
    expenseProvider.setInitialLoading(false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profile),
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: expenseProvider),
          ChangeNotifierProvider(
            create: (_) => CommonProvider(commonServices: mockCommonServices),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen(istest: true)),
      ),
    );

    await tester.pump();

    expect(find.text("Employee  not founded"), findsOneWidget);
  });

  testWidgets("dashboard - loading state", (WidgetTester tester) async {
    final profile = ProfileProvider();
    profile.setUserData({'name': 'fake'});

    final userProvider = UserProvider();
    userProvider.isLoading = true;
    userProvider.user = null;

    final expenseProvider = ExpenseProvider(services: mockServices);
    expenseProvider.changeLoading(true);
    expenseProvider.setInitialLoading(false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profile),
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: expenseProvider),
          ChangeNotifierProvider(
            create: (_) => CommonProvider(commonServices: mockCommonServices),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen(istest: true)),
      ),
    );

    await tester.pump();

    expect(find.byType(CardLoading), findsWidgets);
  });

  testWidgets("User view", (WidgetTester tester) async {
    when(() => profileProvider.userData).thenReturn({'name': 'fake'});
    when(() => userProvider.isLoading).thenReturn(false);
    when(() => userProvider.user).thenReturn(UserModel(id: 1, name: "fake"));
    when(() => userProvider.isAdmin).thenReturn(false);
    when(() => expenseProvider.totalExpenses).thenReturn(0);
    when(() => expenseProvider.totalAmountToSubmit).thenReturn(0);
    when(() => expenseProvider.waitingReimbursement).thenReturn(0);
    when(() => expenseProvider.totalApproved).thenReturn(0);
    when(() => expenseProvider.totalApprovedMy).thenReturn(0);
    when(() => expenseProvider.totalNoRefused).thenReturn(0);
    when(() => expenseProvider.totalNoSubmitted).thenReturn(0);
    when(() => expenseProvider.totalNoPaid).thenReturn(0);
    when(() => expenseProvider.companyExpense).thenReturn([]);

    await tester.pumpWidget(
      dashBoardWrapper(
        child: DashboardScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
        profileProvider: profileProvider,
      ),
    );
    await tester.pump();

    expect(find.text("Expense Analytics"), findsOneWidget);
    expect(find.text("Bussiness Overview"), findsNothing);
    expect(find.text("Analytics & Insights"), findsNothing);
    expect(find.text("To Submit"), findsOneWidget);
  });
  testWidgets("Admin view", (WidgetTester tester) async {
    when(() => profileProvider.userData).thenReturn({'name': 'fake'});
    when(() => userProvider.isLoading).thenReturn(false);
    when(() => userProvider.user).thenReturn(UserModel(id: 1, name: "fake"));
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => expenseProvider.totalExpenses).thenReturn(0);
    when(() => expenseProvider.totalAmountToSubmit).thenReturn(0);
    when(() => expenseProvider.waitingReimbursement).thenReturn(0);
    when(() => expenseProvider.totalApproved).thenReturn(0);
    when(() => expenseProvider.totalApprovedMy).thenReturn(0);
    when(() => expenseProvider.totalNoRefused).thenReturn(0);
    when(() => expenseProvider.totalNoSubmitted).thenReturn(0);
    when(() => expenseProvider.totalNoPaid).thenReturn(0);
    when(() => expenseProvider.totalAmountWaiting).thenReturn(0);
    when(() => expenseProvider.totalPosted).thenReturn(0);
    when(() => expenseProvider.totalCompanyExpense).thenReturn(0);
    when(() => expenseProvider.totalCompanyRefused).thenReturn(0);
    when(() => expenseProvider.pendingApprovalNo).thenReturn(0);
    when(() => expenseProvider.departmentExpense).thenReturn([]);
    when(() => expenseProvider.companyExpense).thenReturn([
      CompanyExpenseModel(
        id: 1,
        totalAmount: 0,
        departmentId: 1,
        departmentName: 'fakedepartment',
        companyId: 1,
        companyName: "fake company",
        state: "approve",
      ),
    ]);

    await tester.pumpWidget(
      dashBoardWrapper(
        child: DashboardScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
        profileProvider: profileProvider,
      ),
    );
    await tester.pump();
    expect(find.text("Expense Analytics"), findsOneWidget);
    expect(find.text("To Submit"), findsOneWidget);
    expect(find.text("Business Overview"), findsOneWidget);
    expect(find.text("Analytics & Insights"), findsOneWidget);
  });
}
