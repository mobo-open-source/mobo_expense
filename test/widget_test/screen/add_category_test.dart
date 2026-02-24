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
  testWidgets("Navigate to add Category", (WidgetTester tester) async {
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
    when(() => commonProvider.productCategory).thenReturn([]);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
          ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
        ],
        child: MaterialApp(home: CategoriesScreen()),
      ),
    );
    expect(find.byType(CategoriesScreen), findsOneWidget);
    await tester.pump();
    expect(find.text('fakeCategory'), findsOneWidget);
    final fab = find.byKey(Key("fab"));

    ///====>floating action button
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Create Category"), findsWidgets);
    expect(find.text("Category Information"), findsWidgets);
    expect(find.text("Name"), findsWidgets);
    expect(find.text("Category Name"), findsWidgets);
    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);
    await tester.enterText(fields.at(0), 'Lunch');
    await tester.pump();
    expect(find.text("Lunch"), findsOneWidget);

    ///===> cheking typed  in the textform is correct
    final submitBtn = find.byKey(Key("button_container"));
    expect(submitBtn, findsOneWidget);
    await tester.ensureVisible(submitBtn);
    await tester.pump();
    await tester.tap(submitBtn);
    await tester.pump();
  });
}
