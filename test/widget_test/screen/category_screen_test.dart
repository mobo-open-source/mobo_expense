import 'package:flutter/material.dart';
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

  setUp(() {
    commonProvider = MockCommonProvider();
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

  testWidgets("Category Screen Renders without crashing", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CommonProvider>.value(value: commonProvider),
        ],
        child: MaterialApp(home: CategoriesScreen()),
      ),
    );
    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets("checking empty category", (WidgetTester tester) async {
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

    expect(find.text("No categories found"), findsOneWidget);
  });

  testWidgets("checking with  category", (WidgetTester tester) async {
    final categoryList = [ExpenseCategory(id: 1, name: "fakeCategory")];

    when(() => commonProvider.categoryList).thenReturn(categoryList);

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
  });

  testWidgets("cheking navigation to detail screen", (
    WidgetTester tester,
  ) async {
    final categoryList = [ExpenseCategory(id: 1, name: "fakeCategory")];

    final fakeCategoryFullModel = CategoriesFullModel(
      id: 1,
      name: "fake",
      defaultCode: "sss",
      description: "sssds",
      listPrice: 22,
      standardPrice: 22,
      supplierTaxes: 'dfew',
    );

    when(() => commonProvider.categoryList).thenReturn(categoryList);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.categoriesLoading).thenReturn(false);

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

    expect(find.text('Category Details'), findsOneWidget);
    expect(find.text('fake'), findsOneWidget);
    expect(find.text('Guidelines'), findsOneWidget);
  });
  testWidgets("finding editing screen", (WidgetTester tester) async {
    final categoryList = [ExpenseCategory(id: 1, name: "fakeCategory")];
    final fakeCategoryFullModel = CategoriesFullModel(
      id: 1,
      name: "fake",
      defaultCode: "sss",
      description: "sssds",
      listPrice: 22,
      standardPrice: 22,
      supplierTaxes: 'dfew',
    );
    when(() => commonProvider.categoryList).thenReturn(categoryList);
    when(() => commonProvider.isLoading).thenReturn(false);
    when(() => commonProvider.categoriesLoading).thenReturn(false);
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
    expect(find.text("Edit Category"), findsOneWidget);
    expect(find.text("Category Information"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Internal Code"), findsOneWidget);
    expect(find.text("Parent Category"), findsOneWidget);
    expect(find.text("Pricing"), findsOneWidget);
  });

  testWidgets("finding edit screen ", (WidgetTester tester) async {
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
    expect(find.text("Edit Category"), findsOneWidget);
    expect(find.text("Category Information"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Internal Code"), findsOneWidget);
    expect(find.text("Parent Category"), findsOneWidget);
    expect(find.text("Pricing"), findsOneWidget);
  });
}
