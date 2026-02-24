import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/test_wrapper.dart';
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
    when(() => expenseProvider.odooVersion).thenReturn('18');
  });

  testWidgets("Finding popMenu in Detail page in reported state(18)", (
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
  });

  testWidgets("approving expense", (WidgetTester tester) async {
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
    final approving = find.byKey(Key("approving"));
    expect(approving, findsOneWidget);
    await tester.tap(approving);
    await tester.pump();

    ///===>  popupmenu successfully getted
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Submit Approve?"), findsOneWidget);
    final susccess = find.byKey(Key("Success"));
    final fail = find.byKey(Key("fail"));
    expect(susccess, findsOneWidget);
    expect(fail, findsOneWidget);
  });

  testWidgets("Refuse expense", (WidgetTester tester) async {
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
    final refusing = find.byKey(Key("refusing"));
    expect(refusing, findsOneWidget);
    await tester.tap(refusing);
    await tester.pump();
    expect(find.text('Submit refuse?'), findsOneWidget);
    final susccess = find.byKey(Key("Success"));
    final fail = find.byKey(Key("fail"));
    expect(susccess, findsOneWidget);
    expect(fail, findsOneWidget);
  });

  testWidgets("Refuse expense", (WidgetTester tester) async {
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
    final refusing = find.byKey(Key("refusing"));
    expect(refusing, findsOneWidget);
    await tester.tap(refusing);
    await tester.pump();
    expect(find.text('Submit refuse?'), findsOneWidget);
    final susccess = find.byKey(Key("Success"));
    final fail = find.byKey(Key("fail"));
    expect(susccess, findsOneWidget);
    expect(fail, findsOneWidget);
  });
}
