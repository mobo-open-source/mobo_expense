import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks/mock_provider.dart';
import '../helpers/test_wrapper.dart';

void main() {
  late MockExpenseProvider expenseProvider;
  late MockCommonProvider commonProvider;
  late MockUserProvider userProvider;

  setUp(() {
    expenseProvider = MockExpenseProvider();
    commonProvider = MockCommonProvider();
    userProvider = MockUserProvider();
    registerFallbackValue(FakeBuildContext());
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.expenses).thenReturn([]);
    when(() => expenseProvider.loadedExpense).thenReturn([]);
    when(() => expenseProvider.fkTogle).thenReturn(0);
    when(() => expenseProvider.canGoNext).thenReturn(false);
    when(() => expenseProvider.canGoPrevious).thenReturn(false);
    when(() => expenseProvider.paginationText).thenReturn('1–0 of 0');
    when(() => commonProvider.domain).thenReturn([]);
    when(() => commonProvider.selectedCategoryList).thenReturn({});
    when(
      () => commonProvider.fromDateController,
    ).thenReturn(TextEditingController());
    when(() => userProvider.isAdmin).thenReturn(true);
    when(
      () => expenseProvider.gettingSearchedExpense(
        any(),
        admin: any(named: 'admin'),
        reset: any(named: 'reset'),
      ),
    ).thenAnswer((_) async {});
  });

  testWidgets('ExpensesScreen renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    expect(find.byType(ExpensesScreen), findsOneWidget);
  });

  testWidgets('Admin toggle not visible for non-admin', (
    WidgetTester tester,
  ) async {
    when(() => userProvider.isAdmin).thenReturn(false);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    expect(find.text('My'), findsNothing);
    expect(find.text('All'), findsNothing);
  });

  testWidgets('Admin toggle visible for admin', (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(true);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    expect(find.text('My'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets('Expense list is displayed when expenses are available', (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'paid',
        employeeId: [1, 'John'],
        splitExpense: [],
        activityIds: [],
        companyId: [],
        attachment: [],
        department: [],
        description: "naas",
        manager: [],
        productId: [],
        taxAmount: 22,
        taxIds: [],
        untaxAmount: 222,
      ),
    ];

    when(() => expenseProvider.expenses).thenReturn(fakeExpenses);
    when(() => expenseProvider.loadedExpense).thenReturn(fakeExpenses);
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    await tester.pump();
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('paid'), findsOneWidget);
  });

  testWidgets('checking refresh', (WidgetTester tester) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'paid',
        employeeId: [1, 'John'],
        splitExpense: [],
        activityIds: [],
        companyId: [],
        attachment: [],
        department: [],
        description: "naas",
        manager: [],
        productId: [],
        taxAmount: 22,
        taxIds: [],
        untaxAmount: 222,
      ),
    ];

    when(() => expenseProvider.expenses).thenReturn(fakeExpenses);
    when(() => expenseProvider.loadedExpense).thenReturn(fakeExpenses);
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => commonProvider.clearFilter()).thenAnswer((_) async {});
    when(() => expenseProvider.loadExpenses()).thenAnswer((_) async {});

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    await tester.pump();

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('paid'), findsOneWidget);
    final refresh = find.byType(RefreshIndicator);
    expect(refresh, findsOneWidget);
    await tester.drag(refresh, Offset(0, 300));
    await tester.pumpAndSettle();
    verify(() => commonProvider.clearFilter()).called(1);
    verify(() => expenseProvider.loadExpenses()).called(1);
  });

  testWidgets('Filter button opens bottom sheet apply', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.isShow).thenReturn(false);
    when(
      () => commonProvider.fromDateController,
    ).thenReturn(TextEditingController());

    when(
      () => commonProvider.employeeController,
    ).thenReturn(TextEditingController());

    final fakeEmplotee = [Employee(id: 1, name: 'dummy', workPhone: 'sss')];

    final fakeCategory = [ExpenseCategory(id: 1, name: "category")];
    when(() => commonProvider.employeeList).thenReturn(fakeEmplotee);
    when(() => commonProvider.categoryList).thenReturn(fakeCategory);
    when(() => commonProvider.clearFilter()).thenAnswer((_) {});
    when(
      () => expenseProvider.loadExpenses(reset: true),
    ).thenAnswer((_) async {});
    when(
      () => commonProvider.getFilteredItems(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => commonProvider.dateController,
    ).thenReturn(TextEditingController());
    when(() => commonProvider.selctedEmployee).thenReturn(fakeEmplotee[0]);
    when(() => commonProvider.selectedCategoryList).thenReturn({});

    /// Let initial frame complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    /// Find filter button by key
    final filterButton = find.byKey(const Key('filter_button'));
    expect(filterButton, findsOneWidget);
    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('filter_bottom_sheet_title')), findsOneWidget);

    expect(find.text("Date"), findsWidgets);

    expect(find.text("Clear all"), findsOneWidget);
    expect(find.text("Apply"), findsOneWidget);

    final filterApply = find.byKey(Key("filter_apply"));

    expect(filterApply, findsOneWidget);
  });

  testWidgets('Filter button opens bottom sheet cancel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.isShow).thenReturn(false);
    when(
      () => commonProvider.fromDateController,
    ).thenReturn(TextEditingController());

    when(
      () => commonProvider.employeeController,
    ).thenReturn(TextEditingController());

    final fakeEmplotee = [Employee(id: 1, name: 'dummy', workPhone: 'sss')];

    final fakeCategory = [ExpenseCategory(id: 1, name: "category")];

    when(() => commonProvider.employeeList).thenReturn(fakeEmplotee);
    when(() => commonProvider.categoryList).thenReturn(fakeCategory);
    when(() => commonProvider.clearFilter()).thenAnswer((_) {});
    when(
      () => expenseProvider.loadExpenses(reset: true),
    ).thenAnswer((_) async {});
    when(
      () => commonProvider.getFilteredItems(any(), any(), any()),
    ).thenAnswer((_) async {});

    /// Let initial frame complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    /// Find filter button by key
    final filterButton = find.byKey(const Key('filter_button'));
    expect(filterButton, findsOneWidget);
    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('filter_bottom_sheet_title')), findsOneWidget);

    expect(find.text("Date"), findsWidgets);
    expect(find.text("Clear all"), findsOneWidget);
    final filtercancel = find.byKey(Key("filter_cancel"));
    expect(filtercancel, findsOneWidget);
    await tester.tap(filtercancel);
    await tester.pump();
    verify(() => commonProvider.clearFilter()).called(2);
    verify(() => expenseProvider.loadExpenses(reset: true)).called(2);
  });

  testWidgets('Filter button opens bottom sheet apply', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    final fromDateController = TextEditingController();
    final employeeController = TextEditingController();
    final dateController = TextEditingController();
    when(
      () => commonProvider.fromDateController,
    ).thenReturn(fromDateController);
    when(
      () => commonProvider.employeeController,
    ).thenReturn(employeeController);
    when(() => commonProvider.dateController).thenReturn(dateController);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.isShow).thenReturn(false);
    final fakeEmplotee = [Employee(id: 1, name: 'dummy', workPhone: 'sss')];

    final fakeCategory = [ExpenseCategory(id: 1, name: "category")];
    when(() => commonProvider.employeeList).thenReturn(fakeEmplotee);
    when(() => commonProvider.categoryList).thenReturn(fakeCategory);
    when(() => commonProvider.clearFilter()).thenAnswer((_) {});
    when(
      () => expenseProvider.loadExpenses(reset: true),
    ).thenAnswer((_) async {});
    when(
      () => commonProvider.getFilteredItems(
        any(),
        any(),
        any(),
        id: any(named: 'id'),
      ),
    ).thenAnswer((_) async {});
    when(() => commonProvider.selctedEmployee).thenReturn(fakeEmplotee[0]);
    when(() => commonProvider.selectedCategoryList).thenReturn({});
    when(() => expenseProvider.changeFkTogle(0)).thenAnswer((_) {});

    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    final filterButton = find.byKey(const Key('filter_button'));
    expect(filterButton, findsOneWidget);
    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    expect(find.byKey(const Key('filter_bottom_sheet_title')), findsOneWidget);

    expect(find.text("Date"), findsWidgets);

    expect(find.text("Clear all"), findsOneWidget);
    expect(find.text("Apply"), findsOneWidget);

    final filterApply = find.byKey(Key("filter_apply"));

    expect(filterApply, findsOneWidget);

    await tester.tap(filterApply);
    await tester.pump(const Duration(seconds: 5));

    verify(() => expenseProvider.changeFkTogle(0)).called(1);
    verify(
      () => commonProvider.getFilteredItems(
        any(),
        any(),
        any(),
        id: any(named: 'id'),
      ),
    ).called(1);
  });
}
