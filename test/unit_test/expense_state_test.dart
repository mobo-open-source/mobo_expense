import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/model/split_list_model.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks/mock.dart';

void main() {
  late ExpenseProvider provider;
  late MockServices mockServices;

  setUp(() {
    mockServices = MockServices();
    provider = ExpenseProvider(services: mockServices);
  });

  test("Expense state delete method succesfully deleted", () async {
    when(() => mockServices.deleteItems(any(), any())).thenAnswer((_) async {
      return true;
    });
    final result = await provider.deleteExpense(1);
    expect(result, true);
    verify(() => mockServices.deleteItems(1, any())).called(1);
  });

  test("Expense state delete method  not  succesfully deleted", () async {
    when(() => mockServices.deleteItems(any(), any())).thenAnswer((_) async {
      return false;
    });
    final result = await provider.deleteExpense(1);
    expect(result, false);
    verify(() => mockServices.deleteItems(1, any())).called(1);
  });

  test("action Button on state change updated succesfully ", () async {
    when(
      () => mockServices.buttonAction(any(), any(), any()),
    ).thenAnswer((_) async => true);
    final result = await provider.buttonAction(
      "action_submit_expenses",
      "hr.expense",
      1,
    );
    expect(result, true);
    verify(
      () =>
          mockServices.buttonAction(1, "hr.expense", "action_submit_expenses"),
    ).called(1);
  });

  test("action Button on state change updated not  succesfully ", () async {
    when(
      () => mockServices.buttonAction(any(), any(), any()),
    ).thenAnswer((_) async => false);
    final result = await provider.buttonAction(
      "action_submit_expenses",
      "hr.expense",
      1,
    );
    expect(result, false);
    verify(
      () =>
          mockServices.buttonAction(1, "hr.expense", "action_submit_expenses"),
    ).called(1);
  });

  test(
    "action Button on state change updated not  succesfully if no method ",
    () async {
      final result = await provider.buttonAction("", "hr.expense", 1);
      expect(result, false);
    },
  );

  test("split expesne gettting List of wizard id", () async {
    when(() => mockServices.splitExpense(any())).thenAnswer(
      (_) async => [
        SplitExpense(
          id: 1,
          name: "expense",
          totalAmountCurrency: 12.0,
          wizardId: 3,
        ),
      ],
    );
    await provider.splitExpense(1);
    expect(provider.splitExpenseList.length, 1);
    expect(provider.wizardId, 3);
  });

  test("post journal expense  succesfully posted in api", () async {
    when(
      () => mockServices.postJournal(any(), any(), any(), any(), any(), any()),
    ).thenAnswer((_) async => true);

    final result = await provider.postJournalAction(1, 2, "2024-01-20");
    expect(result, true);
  });

  test(
    "post journal expense  date is empty succesfully posted in api",
    () async {
      when(
        () =>
            mockServices.postJournal(any(), any(), any(), any(), any(), any()),
      ).thenAnswer((_) async => true);

      final result = await provider.postJournalAction(1, 2, "");
      expect(result, false);
    },
  );
  test("post journal expense  date is empty false posted in api", () async {
    when(
      () => mockServices.postJournal(any(), any(), any(), any(), any(), any()),
    ).thenAnswer((_) async => false);
    final result = await provider.postJournalAction(1, 2, "2024-01-20");
    expect(result, false);
  });
}
