import 'package:flutter/material.dart' show TextFormField, MaterialApp, Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/home/category/categories_screen.dart';
import 'package:mobo_expenses/model/categories_full.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
import 'package:mobo_expenses/model/tax_model.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_provider.dart';

void main() {
  late MockCommonProvider commonProvider;
  late MockExpenseProvider expenseProvider;
  setUp(() {
    commonProvider = MockCommonProvider();
    expenseProvider = MockExpenseProvider();

    registerFallbackValue(FakeBuildContext());

    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.productCategoryLoading).thenReturn(false);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.canGoPrevious).thenReturn(false);
    when(() => commonProvider.canGoNext).thenReturn(false);

    when(() => commonProvider.paginationText).thenReturn('0 of 0');

    when(() => commonProvider.categoryList).thenReturn([]);
    when(() => commonProvider.totalTaxWithoutCompany).thenReturn([]);
  });
  testWidgets("Navigate to editing screen", (WidgetTester tester) async {
    final categoryList = [ExpenseCategory(id: 1, name: "fakeCategory")];

    final fakeCategoryFullModel = CategoriesFullModel(
      id: 1,
      name: "fake",
      defaultCode: "sss",
      description: "sssds",
      listPrice: 22,
      standardPrice: 22,
      supplierTaxes: 'dfew',
      taxId: [1, 2],
      categId: 1,
      categName: 'sss',
    );

    final totalTax = [
      TaxModel(id: 1, name: "sample1"),
      TaxModel(id: 2, name: "sample2"),
    ];
    when(() => commonProvider.categoryList).thenReturn(categoryList);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.categoriesLoading).thenReturn(false);
    when(() => commonProvider.gettingfulltaxloading).thenReturn(false);
    when(() => commonProvider.totalTaxWithoutCompany).thenReturn(totalTax);
    when(
      () => commonProvider.categoriesFullModel,
    ).thenReturn(fakeCategoryFullModel);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
        ],
        child: MaterialApp(home: CategoriesScreen()),
      ),
    );
    expect(find.byType(CategoriesScreen), findsOneWidget);
    await tester.pump();
    expect(find.text('fakeCategory'), findsOneWidget);
    final btn = find.byKey(Key("push_btn"));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final editing = find.byKey(Key("editing_screen"));
    expect(editing, findsOneWidget);
    await tester.tap(editing);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);
    final button = find.byKey(Key("button_container"));
    expect(button, findsWidgets);

    ///getted submit button,
  });
}
