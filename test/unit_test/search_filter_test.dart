import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mock.dart';

void main() {
  late ExpenseProvider provider;
  late CommonProvider commonProvider;
  late MockServices mockServices;
  late MockCommonServices mockCommonServices;

  setUp(() {
    mockServices = MockServices();
    mockCommonServices = MockCommonServices();
    provider = ExpenseProvider(services: mockServices);
    commonProvider = CommonProvider(commonServices: mockCommonServices);
  });

  test("filter ==>employee_id when id is provided", () async {
    await commonProvider.getFilteredItems({}, "", null, id: 1);
    expect(commonProvider.domain, [
      ["employee_id", "=", 1],
    ]);
  });

  test("filter ==>employee_id 0 when id is provided", () async {
    await commonProvider.getFilteredItems({}, "", null, id: 0);
    expect(commonProvider.domain.length, 0);
  });

  test("filter ==>adds employee_id, and date  when id is provided", () async {
    await commonProvider.getFilteredItems({}, "01-02-2026", null, id: 1);
    expect(commonProvider.domain, [
      ["employee_id", "=", 1],
      ['date', '=', '2026-02-01'],
    ]);
  });

  test("seraching method getted one expense", () async {
    final fakeExpenses = [
      Expense(
        id: 1,
        employeeId: [],
        taxIds: [],
        name: 'ss',
        date: '',
        productId: [],
        paymentMode: 'ss',
        activityIds: [],
        companyId: [],
        totalAmount: 0.0,
        taxAmount: 0.0,
        untaxAmount: 0.0,
        state: '',
        description: '',
        department: [],
        manager: [],
        attachment: [],
        splitExpense: [],
      ),
    ];

    when(
      () => mockServices.gettingExpensePagination(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => fakeExpenses);

    when(
      () => mockServices.getExpenseCount(
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => 1);

    await provider.gettingSearchedExpense('s');
    expect(provider.expenses.length, 1);
    expect(provider.totalRecords, 1);
  });

  test("seraching method getted no expense", () async {
    final fakeExpenses = <Expense>[];
    when(
      () => mockServices.gettingExpensePagination(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => fakeExpenses);
    when(
      () => mockServices.getExpenseCount(
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => 0);
    await provider.gettingSearchedExpense('s');
    expect(provider.expenses.length, 0);
    expect(provider.totalRecords, 0);
  });
}
