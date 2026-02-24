import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/features/home/expense/payment_slip.dart';
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
        paymentMode: 'company',
        totalAmount: 150,
        state: 'paid',
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

  testWidgets(
    "not finding payment slip  in detail page in paid state(own_account)",
    (WidgetTester tester) async {
      final fakeExpenses = [
        Expense(
          id: 1,
          name: 'Lunch',
          date: '2025-01-10',
          paymentMode: 'own_account',
          totalAmount: 150,
          state: 'paid',
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

      await tester.pumpWidget(
        wrapWithProviders(
          child: ExpensesScreen(),
          expenseProvider: expenseProvider,
          commonProvider: commonProvider,
          userProvider: userProvider,
        ),
      );
      await tester.pump();
      expect(find.text("Lunch"), findsOneWidget);
      expect(find.text('paid'), findsOneWidget);
      final detailbutton = find.byKey(const Key('details_button'));
      expect(detailbutton, findsOneWidget);
      await tester.tap(detailbutton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);
      expect(find.text('Expense Details'), findsOneWidget);
      expect(find.text('paid'), findsWidgets);
      final paymentSlip = find.byKey(Key('payment_slip'));
      expect(paymentSlip, findsNothing);
    },
  );

  testWidgets("finding payment slip  in detail page in paid state", (
    WidgetTester tester,
  ) async {
    when(() => expenseProvider.invoiceLoading).thenReturn(false);
    when(
      () => expenseProvider.gettingInvoice(any(), any()),
    ).thenAnswer((_) async {});
    when(() => expenseProvider.paySlip).thenReturn({'name': 'Test Slip', 'state': 'paid', 'amount': 150.0});

    await tester.pumpWidget(
      wrapWithProviders(
        child: ExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    await tester.pump();
    expect(find.text("Lunch"), findsOneWidget);
    expect(find.text('paid'), findsOneWidget);
    final detailbutton = find.byKey(const Key('details_button'));
    expect(detailbutton, findsOneWidget);
    await tester.tap(detailbutton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);
    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('paid'), findsWidgets);
    final paymentSlip = find.byKey(Key('payment_slip'));
    expect(paymentSlip, findsOneWidget);
    await tester.tap(paymentSlip);
    await tester.pumpAndSettle();

    ///load the payment slip page
    expect(find.byType(PaymentSlipPage), findsOneWidget);
  });
}
