import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_wrapper.dart';
import '../mocks/mock_provider.dart';

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

  testWidgets("Finding popMenu in Detail page in submitted state", (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'submitted',
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
    when(() => expenseProvider.odooVersion).thenReturn('19');

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
    expect(find.text('submitted'), findsWidgets);

    final popupmenu = find.byKey(Key("PopupMenuAdmin"));

    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();

    ///===>  popupmenu successfully getted
    await tester.pump(const Duration(seconds: 5));

    final popupdelete = find.byKey(Key('popupdelete'));
    expect(popupdelete, findsWidgets);
    expect(find.text("Delete"), findsWidgets);
    expect(find.text("Approve"), findsWidgets);
    expect(find.text("Refuse"), findsWidgets);
    expect(find.text("Reset"), findsWidgets);
    expect(find.text("Split"), findsWidgets);
  });

  testWidgets("Finding approve in Detail page in submitted state", (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'submitted',
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
    when(() => expenseProvider.odooVersion).thenReturn('19');
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
    final filterButton = find.byKey(const Key('details_button'));
    expect(filterButton, findsOneWidget);

    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);

    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('submitted'), findsWidgets);

    final popupmenu = find.byKey(Key("PopupMenuAdmin"));

    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final approve = find.byKey(Key('approve_19'));
    expect(approve, findsWidgets);
    expect(find.text("Delete"), findsWidgets);
    expect(find.text("Approve"), findsWidgets);
    expect(find.text("Refuse"), findsWidgets);

    await tester.tap(approve);
    await tester.pump();
    expect(find.text('Submit Approve?'), findsOneWidget);

    final susccess = find.byKey(Key("Success"));
    final fail = find.byKey(Key("fail"));
    expect(susccess, findsOneWidget);
    expect(fail, findsOneWidget);
    await tester.tap(susccess);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    verify(() => expenseProvider.buttonAction(any(), any(), any())).called(1);
  });

  testWidgets("Finding refuse in Detail page in submitted state", (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'submitted',
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
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(
      () => expenseProvider.refuseReasonController,
    ).thenReturn(TextEditingController());
    when(
      () => expenseProvider.refuseAction(any(), any(), any()),
    ).thenAnswer((_) async {});

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
    expect(find.text('submitted'), findsWidgets);

    final popupmenu = find.byKey(Key("PopupMenuAdmin"));

    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final refuse = find.byKey(Key('refuse_19'));
    expect(refuse, findsWidgets);
    expect(find.text("Delete"), findsWidgets);
    expect(find.text("Approve"), findsWidgets);
    expect(find.text("Refuse"), findsWidgets);

    await tester.tap(refuse);
    await tester.pump();
    expect(find.text('Submit refuse?'), findsOneWidget);

    final susccess = find.byKey(Key("Success"));
    final fail = find.byKey(Key("fail"));
    expect(susccess, findsOneWidget);
    expect(fail, findsOneWidget);
    await tester.tap(susccess);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    final refuseDailog = find.byKey(Key('refuse_dailog'));
    expect(refuseDailog, findsWidgets);

    ///==>opened refuse dailog box

    expect(find.text("Refuse Expense"), findsWidgets);
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    expect(find.text("Enter the reason"), findsOneWidget);
    await tester.enterText(textField, 'food');

    final refuseBtn = find.byKey(Key('refuse_btn'));

    expect(refuseBtn, findsOneWidget);

    ///getted refuse button and clicking---<>

    await tester.tap(refuseBtn);
    await tester.pump();

    verify(() => expenseProvider.refuseAction(any(), any(), any())).called(1);
  });

  testWidgets("Finding reset in Detail page in submitted state", (
    WidgetTester tester,
  ) async {
    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'Cash',
        totalAmount: 150,
        state: 'submitted',
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
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(
      () => expenseProvider.refuseReasonController,
    ).thenReturn(TextEditingController());
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
    final filterButton = find.byKey(const Key('details_button'));
    expect(filterButton, findsOneWidget);

    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);

    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('submitted'), findsWidgets);

    final popupmenu = find.byKey(Key("PopupMenuAdmin"));

    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final reset = find.byKey(Key('reset_19'));
    expect(reset, findsWidgets);
    expect(find.text("Delete"), findsWidgets);
    expect(find.text("Approve"), findsWidgets);
    expect(find.text("Refuse"), findsWidgets);

    await tester.tap(reset);
    await tester.pump();

    expect(find.text("reset"), findsWidgets);

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
