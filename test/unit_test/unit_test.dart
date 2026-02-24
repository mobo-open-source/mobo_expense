import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import '../mocks/mock.dart';

void main() {
  late ExpenseProvider provider;
  late CommonProvider commonProvider;
  late MockServices mockServices;
  late MockCommonServices commonServices;

  setUp(() {
    mockServices = MockServices();
    provider = ExpenseProvider(services: mockServices);
    commonServices = MockCommonServices();
    commonProvider = CommonProvider(commonServices: commonServices);
  });

  test('changeEditable updates isEditable', () {
    provider.changeEditable(true);
    expect(provider.isEditable, true);
  });

  test('changeLoading updates isLoading', () {
    provider.changeLoading(true);
    expect(provider.isLoading, true);
  });

  test('changeErrorJournal updates errorJournal', () {
    provider.changeErrorJournal(true);
    expect(provider.errorJournal, true);
  });

  test('changeFkTogle updates fkTogle', () {
    provider.changeFkTogle(2);
    expect(provider.fkTogle, 2);
  });

  test('initialExpense clears expenses list', () {
    provider.expenses = [];
    provider.initialExpense();
    expect(provider.expenses.isEmpty, true);
  });

  test('reset clears provider state', () {
    provider.isLoading = true;
    provider.totalExpenses = 1000;
    provider.reset();
    expect(provider.isLoading, false);
    expect(provider.totalExpenses, 0);
  });

  test("dispose tax", () {
    commonProvider.taxAmount = 300;
    commonProvider.disposeInTax();
    expect(commonProvider.taxAmount, 0);
  });
}
