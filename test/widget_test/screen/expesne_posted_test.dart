import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/features/home/invoice/invoice_screen.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/model/invoice_model.dart';
import 'package:mobo_expenses/services/invoice_services.dart';
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

    final fakeExpenses = [
      Expense(
        id: 1,
        name: 'Lunch',
        date: '2025-01-10',
        paymentMode: 'own_account',
        totalAmount: 150,
        state: 'posted',
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
  });
  testWidgets("Finding reset and delete in Detail page in posted state", (
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
    final detailbutton = find.byKey(const Key('details_button'));
    expect(detailbutton, findsOneWidget);

    await tester.tap(detailbutton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);
    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('posted'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Reset"), findsOneWidget);
    expect(find.text("Delete"), findsOneWidget);
  });

  testWidgets(
    "Invoice screen injected into the Detail page when in the Posted state",
    (WidgetTester tester) async {
      when(() => expenseProvider.invoice).thenReturn(null);
      when(
        () => expenseProvider.gettingInvoice(any(), any()),
      ).thenAnswer((_) async {});

      when(() => expenseProvider.invoiceLoading).thenReturn(false);

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
      final detailbutton = find.byKey(const Key('details_button'));
      expect(detailbutton, findsOneWidget);

      await tester.tap(detailbutton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);
      expect(find.text('Expense Details'), findsOneWidget);
      expect(find.text('posted'), findsWidgets);
      final invoice = find.byKey(Key("invoice"));
      expect(invoice, findsOneWidget);
      await tester.tap(invoice);
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(InvoiceScreen), findsOneWidget);
    },
  );
}
