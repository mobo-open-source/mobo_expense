import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/approval_screen.dart';
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
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => expenseProvider.loadedExpense).thenReturn([]);
    when(() => expenseProvider.expenses).thenReturn([]);
    when(() => expenseProvider.approvalExpense).thenReturn([]);
    when(() => expenseProvider.fkTogle).thenReturn(0);
    when(() => expenseProvider.canGoNextApproval).thenReturn(false);
    when(() => expenseProvider.canGoPreviousApproval).thenReturn(false);
    when(() => expenseProvider.paginationTextApproval).thenReturn('1–0 of 0');
    when(() => commonProvider.domain).thenReturn([]);
    when(() => commonProvider.selectedCategoryList).thenReturn({});
    when(() => userProvider.isAdmin).thenReturn(false);
  });

  testWidgets("Expense Approval render", (WidgetTester tester) async {
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
    when(() => expenseProvider.approvalExpense).thenReturn(fakeExpenses);

    await tester.pumpWidget(
      wrapWithProviders(
        child: ApprovalScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(ApprovalScreen), findsOneWidget);

    await tester.pump();
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets("Expense details", (WidgetTester tester) async {
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
    when(() => expenseProvider.approvalExpense).thenReturn(fakeExpenses);

    await tester.pumpWidget(
      wrapWithProviders(
        child: ApprovalScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(ApprovalScreen), findsOneWidget);

    await tester.pump();
    expect(find.text('Lunch'), findsOneWidget);
    final detailsButton = find.byKey(const Key('details_button'));
    expect(detailsButton, findsOneWidget);
    await tester.tap(detailsButton);
    await tester.pump();
  });
}
