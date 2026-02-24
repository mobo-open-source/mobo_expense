import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks/mock.dart';

void main() {
  late MockCommonServices mockCommonServices;
  late CommonProvider commonProvider;

  setUp(() {
    mockCommonServices = MockCommonServices();
    commonProvider = CommonProvider(commonServices: mockCommonServices);
  });

  ///===>Load category===================>

  test("load category data ", () async {
    final fakeCategory = [
      ExpenseCategory(id: 1, name: "fake 1"),
      ExpenseCategory(id: 2, name: "fake 2"),
      ExpenseCategory(id: 3, name: "fake 3"),
    ];

    when(
      () => mockCommonServices.getTotalCategory(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => fakeCategory);

    when(
      () => mockCommonServices.getCategoryCount(),
    ).thenAnswer((_) async => 3);

    await commonProvider.getAllCategory();
    expect(commonProvider.isLoading, false);
    expect(commonProvider.categoryList.length, 3);
    expect(commonProvider.totalRecords, 3);

    verify(
      () => mockCommonServices.getTotalCategory(
        limit: commonProvider.pageSize,
        offset: 0,
      ),
    ).called(1);
  });

  test("load category with no data ", () async {
    final fakeCategory = <ExpenseCategory>[];

    when(
      () => mockCommonServices.getTotalCategory(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => fakeCategory);
    when(
      () => mockCommonServices.getCategoryCount(),
    ).thenAnswer((_) async => 0);
    await commonProvider.getAllCategory();
    expect(commonProvider.isLoading, false);
    expect(commonProvider.categoryList.length, 0);
    expect(commonProvider.totalRecords, 0);
    verify(
      () => mockCommonServices.getTotalCategory(
        limit: commonProvider.pageSize,
        offset: 0,
      ),
    ).called(1);
  });

  test("return true when api succeeds", () async {
    when(() => mockCommonServices.addingCategory(any())).thenAnswer((_) async => true);
    final result = await commonProvider.submitCategory(
      data: {"name": 'fake'},
      name: "fake",
    );

    expect(result, true);
    verify(() => mockCommonServices.addingCategory(any())).called(1);
  });

  test("return false when no name", () async {
    final result = await commonProvider.submitCategory(
      data: {"name": 'fake'},
      name: "",
    );
    expect(result, false);
  });

  test("return true(update)  when API succeeds", () async {
    when(
      () => mockCommonServices.updateCategory(any(), any()),
    ).thenAnswer((_) {});

    final result = await commonProvider.updateCategory(id: 1, data: {});
    expect(result, true);
  });
  test("return false(update)  when data null", () async {
    final result = await commonProvider.updateCategory(id: 1, data: null);
    expect(result, false);
  });

  test("return false(update)  when api error", () async {
    when(
      () => mockCommonServices.updateCategory(any(), any()),
    ).thenThrow(Exception("server error"));
    final result = await commonProvider.updateCategory(id: 1, data: {});
    expect(result, false);
  });
}
