import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/company/widgets/company_selector_widget.dart';
import 'package:mobo_expenses/features/home/home_screen.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/home_wrapper.dart';
import '../mocks/mock_provider.dart';

void main() {
  late MockExpenseProvider expenseProvider;
  late MockCommonProvider commonProvider;
  late MockUserProvider userProvider;
  late MockProfileProvider profileProvider;
  late MockSessionService sessionService;
  late MockBottomProvider bottomProvider;
  late MockCompanyProvider companyProvider;

  setUp(() {
    profileProvider = MockProfileProvider();
    sessionService = MockSessionService();
    commonProvider = MockCommonProvider();
    userProvider = MockUserProvider();
    expenseProvider = MockExpenseProvider();
    bottomProvider = MockBottomProvider();
    companyProvider = MockCompanyProvider();

    registerFallbackValue(FakeBuildContext());

    when(() => userProvider.isAdmin).thenReturn(true);
    when(() => bottomProvider.index).thenReturn(0);
    when(() => profileProvider.isLoading).thenReturn(false);
    when(() => userProvider.getGreeting()).thenReturn("Goodmorning");
    when(() => expenseProvider.loadedExpense).thenReturn([]);
    when(() => expenseProvider.expenses).thenReturn([]);
    when(() => expenseProvider.isInitialLoading).thenReturn(false);
    when(() => expenseProvider.isLoading).thenReturn(false);

    when(() => userProvider.isLoading).thenReturn(false);

    when(() => profileProvider.userData).thenReturn({'name': "fake"});

    when(
      () => userProvider.currentEmployee,
    ).thenReturn(Employee(id: 1, name: "fake", workPhone: "122"));
    when(() => commonProvider.categoryList).thenReturn([]);
    when(() => commonProvider.employeeList).thenReturn([]);
    when(() => companyProvider.isLoading).thenReturn(false);
    when(() => companyProvider.companies).thenReturn([]);
  });

  testWidgets("Home screen rendering", (WidgetTester tester) async {
    await tester.pumpWidget(
      homeWrapper(
        child: HomeScreen(isTest: true),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
        profileProvider: profileProvider,
        sessionService: sessionService,
        bottomNavProvider: bottomProvider,
        companyProvider: companyProvider,
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets(
    "getting selection of company Widget with no company and loading",
    (WidgetTester tester) async {
      when(() => companyProvider.isLoading).thenReturn(true);
      await tester.pumpWidget(
        homeWrapper(
          child: HomeScreen(isTest: true),
          expenseProvider: expenseProvider,
          commonProvider: commonProvider,
          userProvider: userProvider,
          profileProvider: profileProvider,
          sessionService: sessionService,
          bottomNavProvider: bottomProvider,
          companyProvider: companyProvider,
        ),
      );
      expect(find.byType(CompanySelectorWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    },
  );

  testWidgets("getting dropdown with company list", (
    WidgetTester tester,
  ) async {
    when(() => companyProvider.selectedCompany).thenReturn({'name': "fake 1"});

    when(() => companyProvider.isSwitching).thenReturn(false);

    when(() => companyProvider.companies).thenReturn([
      {"name": "fake 1", 'id': 1},
      {'name': 'fake 2', 'id': 2},
    ]);

    when(() => companyProvider.initialize()).thenAnswer((_) async {});

    when(() => companyProvider.selectedAllowedCompanyIds).thenReturn([1, 2]);
    when(() => companyProvider.selectedCompanyId).thenReturn(1);
    when(() => companyProvider.switchCompany(any())).thenAnswer((_) async {
      return true;
    });

    await tester.pumpWidget(
      homeWrapper(
        child: HomeScreen(isTest: true),
        expenseProvider: expenseProvider,
        commonProvider: commonProvider,
        userProvider: userProvider,
        profileProvider: profileProvider,
        sessionService: sessionService,
        bottomNavProvider: bottomProvider,
        companyProvider: companyProvider,
      ),
    );
    expect(find.byType(CompanySelectorWidget), findsOneWidget);
    expect(find.text("fake 1"), findsOneWidget);
    await tester.tap(find.text("fake 1"));
    await tester.pumpAndSettle();
    verify(() => companyProvider.initialize()).called(1);
    expect(find.byType(ListView), findsOneWidget);
    final list = find.byKey(Key("listview"));
    expect(list, findsOneWidget);
    expect(find.text("fake 1"), findsWidgets);
    expect(find.text("fake 2"), findsOneWidget);
    await tester.tap(find.text("fake 2"));
    await tester.pumpAndSettle();
    expect(find.text("Confirm"), findsOneWidget);
    await tester.tap(find.text("Confirm"));
    await tester.pumpAndSettle();
    verify(() => companyProvider.switchCompany(any())).called(1);
  });
}
