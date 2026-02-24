import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
import 'package:mobo_expenses/model/expense_attachment_model.dart';
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

  setUpAll(() {
    registerFallbackValue(FakeExpense());
    registerFallbackValue(FakeExpenseAttachment());
  });

  setUp(() {
    mockServices = MockServices();
    mockCommonServices = MockCommonServices();
    provider = ExpenseProvider(services: mockServices);
    commonProvider = CommonProvider(commonServices: mockCommonServices);
  });

  ///===> form validation===>

  test("Form ready when all fields are filled", () {
    commonProvider.selctedEmployee = Employee(
      id: 1,
      name: "fake",
      workPhone: "12345",
    );
    commonProvider.selectedCategory = ExpenseCategory(
      id: 1,
      name: 'fake category',
    );

    final result = commonProvider.isFormReady(
      title: "Taxi",
      amount: "100",
      date: "2025-01-20",
    );
    expect(result, true);
  });

  test("Form not ready when date is empty", () {
    commonProvider.selctedEmployee = Employee(
      id: 1,
      name: "fake",
      workPhone: "12345",
    );
    commonProvider.selectedCategory = ExpenseCategory(
      id: 1,
      name: 'fake category',
    );

    final result = commonProvider.isFormReady(
      title: "Taxi",
      amount: "100",
      date: "",
    );

    expect(result, false);
  });

  test("Form not ready when selected emplooyee is empty", () {
    commonProvider.selectedCategory = ExpenseCategory(
      id: 1,
      name: 'fake category',
    );

    final result = commonProvider.isFormReady(
      title: "Taxi",
      amount: "100",
      date: "",
    );
    expect(result, false);
  });

  ///======> add expense==========>
  ///======> add expense==========>
  ///======> add expense==========>
  ///======> add expense==========>

  test("returns true when API succeeds", () async {
    when(
      () => mockServices.addExpense(
        employeeId: any(named: 'employeeId'),
        name: any(named: 'name'),
        amount: any(named: 'amount'),
        taxId: any(named: 'taxId'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        paymentBy: any(named: 'paymentBy'),
        notes: any(named: 'notes'),
        attachment: any(named: 'attachment'),
      ),
    ).thenAnswer((_) async => true);

    final result = await provider.submitExpense(
      employeeId: 1,
      name: "Lunch",
      amount: 200,
      taxId: [1],
      date: "20-01-2025",
      categoryId: 2,
      paymentBy: "cash",
      attachment: null,
    );

    expect(result, true);

    verify(
      () => mockServices.addExpense(
        employeeId: 1,
        name: "Lunch",
        amount: 200,
        taxId: [1],
        date: "20-01-2025",
        categoryId: 2,
        paymentBy: "cash",
        notes: null,
        attachment: null,
      ),
    ).called(1);
  });

  test("returns false when API not  succeeds", () async {
    when(
      () => mockServices.addExpense(
        employeeId: any(named: 'employeeId'),
        name: any(named: 'name'),
        amount: any(named: 'amount'),
        taxId: any(named: 'taxId'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        paymentBy: any(named: 'paymentBy'),
        notes: any(named: 'notes'),
        attachment: any(named: 'attachment'),
      ),
    ).thenAnswer((_) async => false);
    final result = await provider.submitExpense(
      employeeId: 1,
      name: "Lunch",
      amount: 200,
      taxId: [1],
      date: "20-01-2025",
      categoryId: 2,
      paymentBy: "cash",
      attachment: null,
    );
    expect(result, false);
    verify(
      () => mockServices.addExpense(
        employeeId: 1,
        name: "Lunch",
        amount: 200,
        taxId: [1],
        date: "20-01-2025",
        categoryId: 2,
        paymentBy: "cash",
        notes: null,
        attachment: null,
      ),
    ).called(1);
  });

  test("returns false when validation fails if ", () async {
    final result = await provider.submitExpense(
      employeeId: 1,
      name: "",
      amount: 200,
      taxId: [1],
      date: "20-01-2025",
      categoryId: 2,
      paymentBy: "cash",
    );
    expect(result, false);
  });

  test("adds new category when not selected", () {
    commonProvider.selectedCategoryList = {
      ExpenseCategory(id: 1, name: 'fake 1'),
      ExpenseCategory(id: 2, name: 'fake 2'),
    };

    commonProvider.toggleSelection(ExpenseCategory(id: 3, name: 'fake 3'));
    commonProvider.toggleSelection(ExpenseCategory(id: 4, name: 'fake 4'));

    expect(commonProvider.selectedCategoryList.length, 4);
  });

  test("removing employee", () {
    commonProvider.selctedEmployee = Employee(
      id: 1,
      name: "fake",
      workPhone: "123",
    );

    expect(commonProvider.selctedEmployee!.name, "fake");
    commonProvider.removingEmployee();
    expect(commonProvider.selctedEmployee, null);
  });

  ///====>  update expense=============>
  ///====>  update expense=============>
  ///====>  update expense=============>

  test("updateExpense returns true when service succeeds", () async {
    when(() => mockServices.updateExpense(any())).thenAnswer((_) async {});
    final result = await provider.updateExpense(
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
    );
    expect(result, true);
    verify(() => mockServices.updateExpense(any())).called(1);
  });

  test("not updated returns false when service error ", () async {
    when(
      () => mockServices.updateExpense(any()),
    ).thenThrow(Exception("server error"));
    final result = await provider.updateExpense(
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
    );
    expect(result, false);
    verify(() => mockServices.updateExpense(any())).called(1);
  });

  test("updateExpense creates attachment when changed", () async {
    provider.isAttachmentChanged = true;
    when(
      () => mockServices.updateAttachment(any(), any()),
    ).thenAnswer((_) async {});

    final expense = Expense(
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
    );

    final result = await provider.updateExpense(
      expense,
      gettingAttachment: ExpenseAttachmentModel(
        id: 1,
        name: "file",
        datas: "base64",
        mimetype: "image/png",
      ),
    );

    expect(result, true);

    verify(() => mockServices.updateAttachment(any(), any())).called(1);
  });

  test("updateExpense deletes attachment when is deleted is true", () async {
    provider.isDeleted = true;
    provider.attachmentId = 10;

    when(
      () => mockServices.deleteExpenseAttachment(any()),
    ).thenAnswer((_) async {});
    when(() => mockServices.updateExpense(any())).thenAnswer((_) async {});

    final expense = Expense(
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
    );
    final result = await provider.updateExpense(expense);
    expect(result, true);
    verify(() => mockServices.deleteExpenseAttachment(10)).called(1);
  });

  test("updateExpense returns false when service throws", () async {
    when(
      () => mockServices.updateExpense(any()),
    ).thenThrow(Exception("server error"));
    final expense = Expense(
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
    );
    final result = await provider.updateExpense(expense);
    expect(result, false);
  });

  ///====> Load expense===================================>
  ///===> Load expense===================================>
  ///====> Load expense===================================>
  ///====> Load expense===================================>

  test("loadExpenses loads data ", () async {
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
      Expense(
        id: 2,
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
      ),
    ).thenAnswer((_) async => fakeExpenses);

    when(
      () => mockServices.getExpenseCount(
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => 2);

    await provider.loadExpenses();

    expect(provider.isLoading, false);
    expect(provider.loadedExpense.length, 2);
    expect(provider.totalRecords, 2);

    verify(
      () => mockServices.gettingExpensePagination(
        limit: provider.pageSize,
        offset: 0,
        isAdmin: false,
        isApproved: false,
        filter: const [],
      ),
    ).called(1);

    verify(
      () => mockServices.getExpenseCount(
        isAdmin: false,
        isApproved: false,
        filter: const [],
      ),
    ).called(1);
  });
  test("loadExpenses  with no data ", () async {
    final fakeExpenses = <Expense>[];

    when(
      () => mockServices.gettingExpensePagination(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => fakeExpenses);

    when(
      () => mockServices.getExpenseCount(
        isAdmin: any(named: 'isAdmin'),
        isApproved: any(named: 'isApproved'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => 0);

    await provider.loadExpenses();

    expect(provider.isLoading, false);
    expect(provider.loadedExpense.length, 0);
    expect(provider.totalRecords, 0);

    verify(
      () => mockServices.gettingExpensePagination(
        limit: provider.pageSize,
        offset: 0,
        isAdmin: false,
        isApproved: false,
        filter: const [],
      ),
    ).called(1);
    verify(
      () => mockServices.getExpenseCount(
        isAdmin: false,
        isApproved: false,
        filter: const [],
      ),
    ).called(1);
  });
}
