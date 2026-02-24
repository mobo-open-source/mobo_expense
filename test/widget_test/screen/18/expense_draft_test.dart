import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/test_wrapper.dart' show wrapWithProviders;
import '../../mocks/mock_provider.dart';

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
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => expenseProvider.loadedExpense).thenReturn([]);
    when(() => expenseProvider.expenses).thenReturn([]);
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

  testWidgets("Finding popMenu in Detail page in draft state(18)", (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'draft',
        employeeId: [1, 'John'],
        splitExpense: [],
        activityIds: [],
        companyId: [1, 'My Company'],
        manager: [1, 'Manager'],
        attachment: [],
        department: [],
        description: "naas",
        productId: [],
        taxAmount: 22,
        taxIds: [],
        untaxAmount: 222,
      ),
    ];

    when(() => expenseProvider.loadedExpense).thenReturn(fakeExpenses);
    when(() => expenseProvider.expenses).thenReturn(fakeExpenses);
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => expenseProvider.odooVersion).thenReturn('18');

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
    final filterButton = find.byKey(const Key('details_button'));
    expect(filterButton, findsOneWidget);

    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);

    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('draft'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();

    ///===>  popupmenu successfully getted
    await tester.pump(const Duration(seconds: 5));
    final popupdelete = find.byKey(Key('popupdelete'));
    expect(popupdelete, findsWidgets);
    expect(find.text("Delete"), findsWidgets);
    expect(find.text("Create Report"), findsWidgets);
    expect(find.text("Split"), findsWidgets);
  });

  testWidgets("finding create Report in Detail page in draft state(18)", (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'draft',
        employeeId: [1, 'John'],
        splitExpense: [],
        activityIds: [],
        companyId: [1, 'My Company'],
        manager: [1, 'Manager'],
        attachment: [],
        department: [],
        description: "naas",
        productId: [],
        taxAmount: 22,
        taxIds: [],
        untaxAmount: 222,
      ),
    ];

    when(() => expenseProvider.loadedExpense).thenReturn(fakeExpenses);
    when(() => expenseProvider.expenses).thenReturn(fakeExpenses);
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => expenseProvider.odooVersion).thenReturn('18');
    when(
      () => expenseProvider.buttonAction(any(), any(), any()),
    ).thenAnswer((_) async => true);

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
    final detialsButton = find.byKey(const Key('details_button'));
    expect(detialsButton, findsOneWidget);

    await tester.tap(detialsButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);

    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('draft'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();

    ///===>  popupmenu successfully getted
    await tester.pump(const Duration(seconds: 5));
    final popupdelete = find.byKey(Key('popupdelete'));
    expect(popupdelete, findsWidgets);

    expect(find.text("Create Report"), findsWidgets);
    final report = find.byKey(Key("report"));
    expect(report, findsOneWidget);
    await tester.tap(report);
    await tester.pump();
    expect(find.text("Create report?"), findsOneWidget);
    final susccess = find.byKey(Key("Success"));
    final fail = find.byKey(Key("fail"));
    expect(susccess, findsOneWidget);
    expect(fail, findsOneWidget);
    await tester.tap(susccess);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(() => expenseProvider.buttonAction(any(), any(), any())).called(1);
  });
}
