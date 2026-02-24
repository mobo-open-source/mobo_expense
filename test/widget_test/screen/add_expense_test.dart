import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/add_expense/add_expenses_screen.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
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
    when(() => commonProvider.isShow).thenReturn(false);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.categoryShow).thenReturn(false);
    when(
      () => commonProvider.employeeController,
    ).thenReturn(TextEditingController());
    when(
      () => commonProvider.paidBy,
    ).thenReturn(TextEditingController(text: 'company_account'));
    when(() => commonProvider.employeeList).thenReturn([]);
    when(() => commonProvider.categoryList).thenReturn([]);
    when(() => commonProvider.selectedTax).thenReturn([]);
    when(() => commonProvider.totalTax).thenReturn([]);
    when(() => commonProvider.taxAmount).thenReturn(0.0);

    when(
      () => commonProvider.currentExpenseEmployee(),
    ).thenAnswer((_) async {});

    when(() => commonProvider.disposeInTax()).thenReturn(null);

    when(() => commonProvider.getFullTax()).thenAnswer((_) async {});
    when(() => expenseProvider.isLoading).thenReturn(false);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => expenseProvider.expenseInitial()).thenReturn(null);
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => commonProvider.isFormReady(
          amount: any(named: 'amount'),
          date: any(named: 'date'),
          title: any(named: 'title'),
        )).thenReturn(false);
    when(() => commonProvider.selctedEmployee).thenReturn(null);
  });

  testWidgets("Add Expense screen loads", (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const AddExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(AddExpensesScreen), findsOneWidget);
  });

  testWidgets("Add Expense screen cheking", (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const AddExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(AddExpensesScreen), findsOneWidget);
    expect(find.text("Create Expense"), findsNWidgets(2));
    expect(find.text("Employee Details"), findsWidgets);
    expect(find.text("Expense Details"), findsOneWidget);
  });

  testWidgets("checking the employee by adding ", (WidgetTester tester) async {
    final employee = Employee(id: 1, name: 'fake', workPhone: '2232');

    when(() => commonProvider.selctedEmployee).thenReturn(employee);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const AddExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(AddExpensesScreen), findsOneWidget);
    expect(find.text("Create Expense"), findsWidgets);
    expect(find.text("Employee Details"), findsWidgets);
    expect(find.text("Expense Details"), findsOneWidget);
    expect(find.text("fake"), findsOneWidget);

    final remove = find.byKey(Key("employee_remove"));
    expect(remove, findsOneWidget);
  });

  testWidgets("checking the adding expense selected employee not", (
    WidgetTester tester,
  ) async {
    final expenseCategory = ExpenseCategory(id: 1, name: "fakecategory");
    when(() => commonProvider.selctedEmployee).thenReturn(null);
    when(() => commonProvider.selctedEmployee).thenReturn(null);
    when(() => commonProvider.selectedCategory).thenReturn(expenseCategory);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const AddExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(AddExpensesScreen), findsOneWidget);
    expect(find.text("Create Expense"), findsWidgets);
    expect(find.text("Employee Details"), findsWidgets);
    expect(find.text("Notes (Optional)"), findsOneWidget);
    expect(find.text("Type to search  employees"), findsOneWidget);
  });

  testWidgets("checking the adding expense selected ", (
    WidgetTester tester,
  ) async {
    final employee = Employee(id: 1, name: 'fake', workPhone: '2232');
    final expenseCategory = ExpenseCategory(id: 1, name: "fakecategory");

    when(() => commonProvider.selctedEmployee).thenReturn(employee);
    when(() => commonProvider.selectedCategory).thenReturn(expenseCategory);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const AddExpensesScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(AddExpensesScreen), findsOneWidget);
    expect(find.text("Create Expense"), findsWidgets);
    expect(find.text("Employee Details"), findsWidgets);
    expect(find.text("Expense Details"), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text("Enter Expense Title"), findsOneWidget);
    expect(find.text("Expense Amount"), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Lunch');
    await tester.enterText(fields.at(1), '150');
    await tester.enterText(fields.at(2), '13-06-2025');
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Notes (Optional)"), findsOneWidget);
    expect(find.text("Type to search  employees"), findsNothing);
    final submitButton = find.byKey(Key("button_container"));
    expect(submitButton, findsOneWidget);
  });
}
