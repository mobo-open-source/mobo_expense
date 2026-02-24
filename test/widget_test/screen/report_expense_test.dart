import 'package:card_loading/card_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/report/monthly_report.dart';
import 'package:mobo_expenses/features/home/report/report_screen.dart';
import 'package:mobo_expenses/features/home/report/widget/pei_chart.dart';
import 'package:mobo_expenses/features/home/report/widget/pivot_widget.dart';
import 'package:mobo_expenses/model/montly_expense_model.dart';
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
    when(() => expenseProvider.odooVersion).thenReturn('19');
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.categoryReportList).thenReturn([]);
    when(() => commonProvider.companyCategoryReportList).thenReturn([]);
    when(() => commonProvider.employeesReportLis).thenReturn([]);
    when(() => commonProvider.monthlyExpenseList).thenReturn([]);
    when(() => commonProvider.paidExpenseList).thenReturn([]);
    when(() => commonProvider.companyMonthlyExpense).thenReturn([]);
    when(() => commonProvider.changingLoading(any())).thenAnswer((_) {});
  });
  testWidgets("report rendering", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(true);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.byType(ReportScreen), findsOneWidget);
  });
  testWidgets(" admin view", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(true);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );

    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Reimbursement'), findsOneWidget);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('All category'), findsOneWidget);
  });
  testWidgets("user view", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(false);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Reimbursement'), findsOneWidget);
    expect(find.text('Company'), findsNothing);
    expect(find.text('All category'), findsNothing);
    expect(find.byType(MonthlyReport), findsOneWidget);
  });

  testWidgets("monthly report loading", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(false);
    when(() => commonProvider.isLoading).thenReturn(true);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Monthly Expense'), findsNothing);
    expect(find.byType(CardLoading), findsWidgets);
  });

  testWidgets("monthly report no data", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(false);
    when(() => commonProvider.isLoading).thenReturn(false);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Monthly Expense'), findsWidgets);
    expect(find.text('No data found'), findsOneWidget);
  });

  testWidgets("monthly expense with data", (WidgetTester tester) async {
    when(
      () => commonProvider.monthlyExpenseList,
    ).thenReturn([MonthlyAmountModel(month: "january", amount: 1000)]);

    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.companyDepartmentList).thenReturn([]);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Monthly Expense'), findsWidgets);
    expect(find.text('january'), findsWidgets);
    expect(find.byType(MonthlyReport), findsOneWidget);
    expect(find.byType(PieChartWidget), findsOneWidget);
    final dropdown = find.byKey(Key("dropdown ME"));
    expect(dropdown, findsOneWidget);
    await tester.tap(dropdown);
    await tester.pump();

    expect(find.text('Graph'), findsWidgets);
    expect(find.text('Pivot'), findsWidgets);
    expect(find.text('Download'), findsWidgets);
    expect(find.byIcon(Icons.table_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsWidgets);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    final pivot = find.text('Pivot');
    await tester.tap(pivot);
    await tester.pump();
    expect(find.byType(PivotWidget), findsOneWidget);
  });

  testWidgets("category report screen with no data", (
    WidgetTester tester,
  ) async {
    when(() => userProvider.isAdmin).thenReturn(false);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    final category = find.text('Category');
    await tester.tap(category);
    await tester.pump();
    expect(find.text("Category-wise Expense"), findsWidgets);
    expect(find.text("No data found"), findsOneWidget);
  });

  testWidgets("category report screen with  data", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(false);
    when(() => commonProvider.categoryReportList).thenReturn([
      {
        'product_id': [2, "Fake"],
        'total_amount': 222.0,
      },
    ]);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    final category = find.text('Category');
    await tester.tap(category);
    await tester.pump();
    expect(find.text("Category-wise Expense"), findsWidgets);
    expect(find.text("No data found"), findsNothing);
    expect(find.text('Fake'), findsNWidgets(2));
    expect(find.byType(PieChartWidget), findsOneWidget);
  });

  testWidgets("company report screen with no data", (
    WidgetTester tester,
  ) async {
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => commonProvider.companyDepartmentList).thenReturn([]);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Company'), findsOneWidget);
    final category = find.text('Company');
    await tester.tap(category);
    await tester.pump();
    expect(find.text("Company Monthly Expense"), findsWidgets);
    expect(find.text("No data found"), findsOneWidget);
  });

  testWidgets("company report screen with  data", (WidgetTester tester) async {
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => commonProvider.companyDepartmentList).thenReturn([]);
    when(
      () => commonProvider.companyMonthlyExpense,
    ).thenReturn([MonthlyAmountModel(month: "january", amount: 100)]);
    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('Company'), findsOneWidget);
    final category = find.text('Company');
    await tester.tap(category);
    await tester.pump();
    expect(find.text("Company Monthly Expense"), findsNWidgets(2));
    expect(find.text("No data found"), findsNothing);
    expect(find.byType(PieChartWidget), findsOneWidget);
  });

  testWidgets("All Category report screen with no data", (
    WidgetTester tester,
  ) async {
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => commonProvider.companyDepartmentList).thenReturn([]);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('All category'), findsOneWidget);
    final category = find.text('All category');
    final list = find.byKey(Key('top List'));
    await tester.drag(list, const Offset(-300, 0));
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(category);
    await tester.pump();
    expect(find.text("Company Category-wise Expense"), findsWidgets);
    expect(find.text("No data found"), findsOneWidget);
  });

  testWidgets("All Category report screen with  data", (
    WidgetTester tester,
  ) async {
    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => commonProvider.companyDepartmentList).thenReturn([]);
    when(() => commonProvider.companyCategoryReportList).thenReturn([
      {
        'product_id': [0, 'fake'],
        'total_amount': 100.0,
      },
    ]);

    await tester.pumpWidget(
      wrapWithProviders(
        child: const ReportScreen(),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
      ),
    );
    expect(find.text('All category'), findsOneWidget);
    final category = find.text('All category');
    final list = find.byKey(Key('top List'));
    await tester.drag(list, const Offset(-300, 0));
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(category);
    await tester.pump();
    expect(find.text("Company Category-wise Expense"), findsNWidgets(2));
    expect(find.text("No data found"), findsNothing);
    expect(find.byType(PieChartWidget), findsOneWidget);
  });
}
