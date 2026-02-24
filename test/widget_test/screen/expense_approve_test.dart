import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/expense/expenses_screen.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/model/journal_model.dart';
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
        state: 'approved',
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

  testWidgets("Finding postjournal in Detail page in approved state", (
    WidgetTester tester,
  ) async {
    when(() => expenseProvider.initialJournal()).thenAnswer((_) async {});
    when(() => expenseProvider.changeErrorJournal(false)).thenAnswer((_) {});
    when(
      () => expenseProvider.selectedJournal,
    ).thenReturn(JournalModel(id: 1, displayName: "fake Journal"));
    when(
      () => expenseProvider.totalJournal,
    ).thenReturn([JournalModel(id: 1, displayName: "fake Journal")]);
    when(
      () => expenseProvider.journalDateController,
    ).thenReturn(TextEditingController());
    when(
      () => expenseProvider.postJournalAction(any(), any(), any()),
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
    final detailbutton = find.byKey(const Key('details_button'));
    expect(detailbutton, findsOneWidget);
    await tester.tap(detailbutton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);
    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('approved'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Delete"), findsOneWidget);
    expect(find.text("Post Journal"), findsOneWidget);
    final journal = find.byKey(Key("journal_19"));
    expect(journal, findsOneWidget);
    await tester.tap(journal);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(() => expenseProvider.initialJournal()).called(1);
    verify(() => expenseProvider.changeErrorJournal(false)).called(1);
    expect(find.text("Submit Journal?"), findsOneWidget);
    final cancel = find.byKey(Key("fail"));
    expect(cancel, findsOneWidget);
    final success = find.byKey(Key("Success"));
    expect(success, findsOneWidget);
    await tester.tap(success);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final cancelPost = find.byKey(Key("post_cancel"));
    expect(cancelPost, findsOneWidget);
    final confirmPost = find.byKey(Key('post_confirm'));
    expect(confirmPost, findsOneWidget);
    await tester.tap(confirmPost);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(
      () => expenseProvider.postJournalAction(any(), any(), any()),
    ).called(1);
  });

  testWidgets("Finding refuse in Detail page in approved state", (
    WidgetTester tester,
  ) async {
    when(
      () => expenseProvider.refuseReasonController,
    ).thenReturn(TextEditingController());
    when(
      () => expenseProvider.refuseAction(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => expenseProvider.postJournalAction(any(), any(), any()),
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
    final detailbutton = find.byKey(const Key('details_button'));
    expect(detailbutton, findsOneWidget);
    await tester.tap(detailbutton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('ExpenseDetails screens')), findsOneWidget);
    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('approved'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Delete"), findsOneWidget);
    expect(find.text("Refuse"), findsOneWidget);
    final refuse = find.byKey(Key("refuse"));
    expect(refuse, findsOneWidget);
    await tester.tap(refuse);
    await tester.pump();
    expect(find.text("Submit refuse?"), findsOneWidget);
    final cancel = find.byKey(Key("fail"));
    expect(cancel, findsOneWidget);
    final success = find.byKey(Key("Success"));
    expect(success, findsOneWidget);
    await tester.tap(success);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final refusedailog = find.byKey(Key('refuse_dailog'));
    expect(refusedailog, findsOneWidget);
    expect(find.text("Refuse Expense"), findsWidgets);
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    expect(find.text("Enter the reason"), findsOneWidget);
    await tester.enterText(textField, 'food');
    final refusebtn = find.byKey(Key('refuse_btn'));
    expect(refusebtn, findsOneWidget);
    await tester.tap(refusebtn);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(() => expenseProvider.refuseAction(any(), any(), any())).called(1);
  });

  testWidgets("Finding reset in Detail page in approved state", (
    WidgetTester tester,
  ) async {
    when(() => expenseProvider.buttonAction(any(), any(), any())).thenAnswer((
      _,
    ) async {
      return true;
    });

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
    expect(find.text('approved'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Reset"), findsOneWidget);
    final reset = find.byKey(Key("reset_key"));
    expect(reset, findsOneWidget);
    await tester.tap(reset);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Submit reset?"), findsOneWidget);
    final cancel = find.byKey(Key("fail"));
    expect(cancel, findsOneWidget);
    final success = find.byKey(Key("Success"));
    expect(success, findsOneWidget);
    await tester.tap(success);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    verify(() => expenseProvider.buttonAction(any(), any(), any())).called(1);
  });

  testWidgets("Finding split in Detail page in approved state", (
    WidgetTester tester,
  ) async {
    when(() => expenseProvider.splitExpense(any())).thenAnswer((_) async {});
    when(() => expenseProvider.splitExpenseList).thenReturn([]);

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
    expect(find.text('approved'), findsWidgets);
    final popupmenu = find.byKey(Key("PopupMenuAdmin"));
    expect(popupmenu, findsOneWidget);
    await tester.tap(popupmenu);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Split"), findsOneWidget);
    final split = find.byKey(Key("split_approval"));
    expect(split, findsOneWidget);
    await tester.tap(split);
    await tester.pump();
    expect(find.text('Split Expense?'), findsOneWidget);
    final cancel = find.byKey(Key("fail"));
    expect(cancel, findsOneWidget);
    final success = find.byKey(Key("Success"));
    expect(success, findsOneWidget);
    await tester.tap(success);
    await tester.pump();
    expect(find.text('Split Expense'), findsOneWidget);
    final splitbtn = find.byKey(Key("split"));
    expect(splitbtn, findsOneWidget);
  });
}
