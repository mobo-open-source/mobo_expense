import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobo_expenses/model/categories_full.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/model/montly_expense_model.dart';
import 'package:mobo_expenses/model/tax_model.dart';
import 'package:mobo_expenses/provider/expense_provider.dart';
import 'package:mobo_expenses/services/common_service.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:mobo_expenses/services/user_services.dart';
import 'package:provider/provider.dart';

import '../core/services/odoo_session_manager.dart';

class CommonProvider extends ChangeNotifier {
  final CommonServices commonServices;
  CommonProvider({required this.commonServices});

  final discriptionController = TextEditingController();
  final employeeController = TextEditingController();
  final dateController = TextEditingController();
  final employee = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final paidBy = TextEditingController();
  final manager = TextEditingController();
  final company = TextEditingController();
  final tax = TextEditingController();
  final note = TextEditingController();
  List<ExpenseCategory> categoryList = [];
  ExpenseCategory? selectedCategory;
  bool isShow = false;
  bool categoryShow = false;
  bool isLoading = true;

  ///domain
  List<dynamic> domain = [];
  List<int> selectedIds = [];

  ///tax amount
  double taxAmount = 0.0;
  List<TaxModel> selectedTax = [];
  CategoriesFullModel? categoriesFullModel;
  bool categoriesLoading = false;

  List<dynamic> productCategory = [];

  List<MonthlyAmountModel> monthlyExpenseList = [];
  List<MonthlyAmountModel> paidExpenseList = [];
  List<dynamic> categoryReportList = [];
  List<dynamic> companyCategoryReportList = [];
  List<dynamic> companyDepartmentList = [];
  List<dynamic> employeesReportLis = [];
  List<MonthlyAmountModel> companyMonthlyExpense = [];

  @override
  void dispose() {
    /// TODO: implement dispose
    super.dispose();
    dateController.dispose();
    tax.dispose();
    paidBy.dispose();
    employeeController.dispose();
    note.dispose();
    tax.dispose();
    company.dispose();
  }

  Set<ExpenseCategory> selectedCategoryList = {};

  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  List<TaxModel> totalTax = [];

  List<TaxModel> totalTaxWithoutCompany = [];

  bool isFormReady({
    required String title,
    required String amount,
    required String date,
  }) {
    return title.isNotEmpty &&
        amount.isNotEmpty &&
        date.isNotEmpty &&
        selctedEmployee != null &&
        selectedCategory != null;
  }

  final expenseService = ExpenseServices();
  final userServices = UserServices();

  Employee? selctedEmployee;
  Employee? filterEmployee;
  List<Employee> employeeList = [];

  ///++++++++++++++++++++Category ++++++++++++++

  getCategoryDetails(int categoryId) async {
    try {
      categoriesLoading = true;
      categoriesFullModel = null;

      final result = await commonServices.getSingleCategory(categoryId);
      categoriesFullModel = result;

      notifyListeners();
    } catch (e) {
    } finally {
      categoriesLoading = false;
      notifyListeners();
    }
  }

  ///++++++++ProductCategory++++++++

  bool productCategoryLoading = false;
  gettingProductCategory() async {
    try {
      isLoading = true;
      productCategory = [];

      final result = await commonServices.gettingTypedCategory();
      productCategory = result as List;
      notifyListeners();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///get filtered category

  getFilteredItems(
    Set<ExpenseCategory> filterCategory,
    String date,
    BuildContext? context, {
    int? id,
  }) async {
    try {
      selectedIds = filterCategory.map((c) => c.id).toList();

      final List<List<dynamic>> built = [];

      if (id != null && id != 0) {
        built.add(["employee_id", "=", id]);
      }

      if (date.isNotEmpty) {
        try {
          final parsed = DateFormat("d-M-yyyy").parse(date);
          final formatted = DateFormat("yyyy-MM-dd").format(parsed);
          built.add(["date", "=", formatted]);
        } catch (e) {}
      }

      if (selectedIds.isNotEmpty) {
        if (selectedIds.length == 1) {
          built.add(["product_id", "=", selectedIds.first]);
        } else {
          built.add(["product_id", "in", selectedIds]);
        }
      }
      domain = built;

      if (domain.isNotEmpty || context != null) {
        final expenseProvider = context!.read<ExpenseProvider>();
        await expenseProvider.loadExpenses(
          filter: domain.isEmpty ? const [] : domain,
          reset: true,
        );
      }

      notifyListeners();
    } catch (e) {}
  }

  changePaidBy(String changed) {
    paidBy.text = changed;
    notifyListeners();
  }

  ///fetch current expense of employee
  currentExpenseEmployee({bool selected = false, int id = 0}) async {
    try {
      isLoading = true;
      selctedEmployee = await userServices.gettingCurrentEmployee(
        selected: selected,
        id: id,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///initial

  initial(Expense expense) {
    discriptionController.text = expense.name;
    dateController.text = expense.date;

    selectedCategory = categoryList.firstWhere(
      (cat) => cat.id == expense.productId[0],
    );

    priceController.text = expense.totalAmount.toString();

    manager.text = expense.manager.length > 1 ? expense.manager[1] : '';

    paidBy.text = expense.paymentMode;

    company.text = expense.companyId.length > 1 ? expense.companyId[1] : '';
    note.text = expense.description.length > 1 ? expense.description : '';

    tax.text = expense.taxAmount.toString();
    isShow = false;
    categoryShow = false;

    notifyListeners();
  }

  ///typed employee List
  gettingTypedList(String value) async {
    try {
      isLoading = true;

      isShow = true;

      employeeList = await commonServices.getSearchEmployee(typed: value);

      notifyListeners();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///get employee list when type
  Future<List<Employee>> gettingTypedListEmployee(String value) async {
    try {
      return await commonServices.getSearchEmployee(typed: value);
    } catch (e) {
      return [];
    }
  }

  getSelectedCategory(ExpenseCategory category) {
    selectedCategory = category;
    notifyListeners();
  }

  ///dispose tax

  disposeInTax() {
    selectedTax = [];
    selectedCategory = null;
    taxAmount = 0.0;
    isShow = false;
    paidBy.text = 'company_account';
    notifyListeners();
  }

  void addTax(TaxModel tax) {
    if (!selectedTax.contains(tax)) {
      selectedTax.add(tax);
      notifyListeners();
    }
  }

  void removeTax(TaxModel tax) {
    selectedTax.remove(tax);
    notifyListeners();
  }

  selectTax(List<TaxModel> tax) {
    selectedTax = tax;
    notifyListeners();
  }

  initialTax(List<dynamic> selectedTaxId) {
    final List<TaxModel> taxList = [];

    for (final id in selectedTaxId) {
      final tax = totalTax.firstWhere((t) => t.id == id);

      if (tax != null) {
        taxList.add(tax);
      }
    }

    selectedTax = taxList;
    notifyListeners();
  }

  bool gettingfulltaxloading = false;

  /// fetching all the tax
  getFullTaxWithoutCompany() async {
    try {
      isLoading = true;

      final taxes = await commonServices.gettingTaxByFullCompany();

      totalTaxWithoutCompany = taxes;
      notifyListeners();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///fetching tax by company
  getFullTax() async {
    try {
      isLoading = true;

      final taxes = await commonServices.gettingTaxByCompany();

      totalTax = taxes;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///  fetch tax amount
  gettingTaxAmount(List<TaxModel> taxId, String amount) async {
    double amountInDouble = 0.0;

    if (amount.isNotEmpty) {
      amountInDouble = double.parse(amount);
    }

    try {
      taxAmount = 0.0;
      final result = await commonServices.calculateTax(taxId, amountInDouble);

      taxAmount = result;
      notifyListeners();
    } catch (e) {}
  }

  changeDate(TextEditingController controller, String date) {
    controller.text = date;
    notifyListeners();
  }

  removingEmployee() {
    selctedEmployee = null;

    isShow = true;
    notifyListeners();
  }

  changeToFalse() {
    isShow = false;
    notifyListeners();
  }

  changeToFalseCategory() {
    categoryShow = false;
    notifyListeners();
  }

  ///changing category
  changingCategory(bool change) {
    categoryShow = !change;
    notifyListeners();
  }

  ///changing
  changing(bool change) {
    isShow = !change;
    notifyListeners();
  }

  /// loading
  changingLoading(bool change) {
    isLoading = change;
    notifyListeners();
  }

  ///adding employee
  addEmployee(Employee initial) {
    selctedEmployee = initial;
    isShow = false;
    notifyListeners();
  }

  ///filter clear
  clearFilter() {
    domain = [];
    selectedCategoryList = {};
    fromDateController.text = '';
    notifyListeners();
  }

  ///togle
  void toggleSelection(ExpenseCategory c) {
    if (selectedCategoryList.contains(c)) {
      selectedCategoryList.remove(c);
      notifyListeners();
    } else {
      selectedCategoryList.add(c);
      notifyListeners();
    }
  }

  /// remove selected categoryList
  void removeSelected(ExpenseCategory c) {
    if (!selectedCategoryList.contains(c)) return;
    selectedCategoryList.remove(c);
  }

  ///report section

  getPaidExpenseReport() async {
    try {
      final client = await OdooSessionManager.getClient();

      final userId = client!.sessionId?.userId;

      paidExpenseList = [];
      final groupDomain = [
        ['employee_id.user_id', '=', userId],
        ['state', '=', 'paid'],
      ];
      final fields = ['total_amount', 'employee_id'];
      final groupBy = ['date:month', 'employee_id'];

      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );
      paidExpenseList = (result as List)
          .map((items) => MonthlyAmountModel.fromJson(items))
          .toList();

      notifyListeners();
    } catch (e) {}
  }

  ///get monthly report
  getMonthlyBasisReport() async {
    try {
      final client = await OdooSessionManager.getClient();

      final userId = client!.sessionId?.userId;

      monthlyExpenseList = [];

      final groupDomain = [
        ['employee_id.user_id', '=', userId],
      ];

      final fields = ['total_amount', 'date'];
      final groupBy = ['date:month'];

      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );

      monthlyExpenseList = (result as List)
          .map((items) => MonthlyAmountModel.fromJson(items))
          .toList();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  ///get company employees report
  getCompanyEmployees() async {
    try {
      employeesReportLis = [];
      final groupDomain = [];

      final fields = ['total_amount', 'employee_id'];
      final groupBy = ['employee_id'];

      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );
      employeesReportLis = result as List;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  ///  fetch company wise department report
  getCompanyWiseDepartment() async {
    try {
      companyDepartmentList = [];
      final groupDomain = [];

      final fields = ['total_amount'];
      final groupBy = ['department_id'];

      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );
      companyDepartmentList = result as List;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// fetch category report
  getCompanyWiseCategories() async {
    try {
      companyCategoryReportList = [];

      final groupDomain = [];

      final fields = ['total_amount'];
      final groupBy = ['product_id'];

      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );
      companyCategoryReportList = result as List;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// fetch monthly expense report
  getCompanyMonthlyExpense() async {
    try {
      companyMonthlyExpense = [];

      final groupDomain = [];

      final fields = ['total_amount'];
      final groupBy = ['date:month', 'employee_id'];
      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );

      companyMonthlyExpense = (result as List)
          .map((items) => MonthlyAmountModel.fromJson(items))
          .toList();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  ///fetch category report
  getCategoryReport() async {
    try {
      final client = await OdooSessionManager.getClient();

      final userId = client!.sessionId?.userId;
      categoryReportList = [];

      final groupDomain = [
        ['employee_id.user_id', '=', userId],
      ];

      final fields = ['total_amount'];
      final groupBy = ['product_id'];

      final result = await commonServices.readGroupCommon(
        domain: groupDomain,
        fields: fields,
        groupBy: groupBy,
      );
      categoryReportList = result as List;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  ///pagination

  int currentPage = 1;
  final int pageSize = 40;
  int totalRecords = 0;

  int get startCount =>
      totalRecords == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;

  int get endCount {
    final end = currentPage * pageSize;
    return end > totalRecords ? totalRecords : end;
  }

  String get paginationText =>
      totalRecords == 0 ? '0 of 0' : '$startCount–$endCount/$totalRecords';

  bool get canGoPrevious => currentPage > 1;
  bool get canGoNext => endCount < totalRecords;

  ///fetch all category by pagination

  Future<void> getAllCategory({bool reset = false}) async {
    try {
      isLoading = true;

      if (reset) {
        currentPage = 1;
        categoryList.clear();
      }

      notifyListeners();

      final offset = (currentPage - 1) * pageSize;

      final res = await commonServices.getTotalCategory(
        offset: offset,
        limit: pageSize,
      );

      categoryList = res ?? [];

      totalRecords = await commonServices.getCategoryCount();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void nextPage() {
    if (!canGoNext) return;
    currentPage++;
    getAllCategory();
  }

  void previousPage() {
    if (!canGoPrevious) return;
    currentPage--;
    getAllCategory();
  }

  /// reset method

  void reset() {
    /// Clear controllers
    discriptionController.clear();
    employeeController.clear();
    dateController.clear();
    employee.clear();
    categoryController.clear();
    priceController.clear();
    paidBy.clear();
    manager.clear();
    company.clear();
    tax.clear();
    note.clear();
    fromDateController.clear();
    toDateController.clear();

    /// Clear selections & flags
    selectedCategory = null;
    selctedEmployee = null;
    selectedCategoryList.clear();
    selectedTax.clear();
    totalTax.clear();

    taxAmount = 0.0;
    isShow = false;
    categoryShow = false;
    isLoading = false;
    categoriesLoading = false;
    productCategoryLoading = false;
    gettingfulltaxloading = false;

    /// Clear lists
    categoryList.clear();
    productCategory.clear();
    employeeList.clear();
    monthlyExpenseList.clear();
    paidExpenseList.clear();
    categoryReportList.clear();
    companyCategoryReportList.clear();
    companyDepartmentList.clear();
    employeesReportLis.clear();
    companyMonthlyExpense.clear();

    /// Clear filters
    domain.clear();
    selectedIds.clear();

    /// Pagination reset
    currentPage = 1;
    totalRecords = 0;

    notifyListeners();
  }

  ///update category
  Future<bool> updateCategory({required int id, required dynamic data}) async {
    try {
      if (data == null) {
        return false;
      }
      await commonServices.updateCategory(data, id);

      return true;
    } catch (e) {
      return false;
    }
  }

  ///submit category

  Future<bool> submitCategory({
    required dynamic data,
    required String name,
  }) async {
    try {
      if (name.isEmpty) {
        return false;
      }
      await commonServices.addingCategory(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
