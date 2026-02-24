import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mime/mime.dart';
import 'package:mobo_expenses/model/department_expense.dart';
import 'package:mobo_expenses/model/expense_attachment_model.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/model/invoice_model.dart';
import 'package:mobo_expenses/model/journal_model.dart';
import 'package:mobo_expenses/model/split_list_model.dart';
import 'package:mobo_expenses/model/user_model.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:mobo_expenses/services/expense_services.dart';
import 'package:mobo_expenses/services/invoice_services.dart';
import 'package:mobo_expenses/services/user_services.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import '../core/constants/constants.dart';
import '../core/services/odoo_session_manager.dart';
import '../core/utils/custom_snackbar.dart';
import '../core/utils/loading.dart';
import '../core/utils/snackbar.dart';
import '../features/home/home_screen.dart';
import '../model/account_move_line_model.dart';
import '../model/company_expense_model.dart';
import '../model/department_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseServices services;

  ExpenseProvider({required this.services});

  bool _initialLoaded = false;
  bool _isInitialLoading = true;

  bool get isInitialLoading => _isInitialLoading;

  void setInitialLoading(bool v) {
    if (_initialLoaded) return;
    _isInitialLoading = v;
    notifyListeners();
  }

  void markInitialLoaded() {
    _initialLoaded = true;
  }

  List<Expense> expenses = [];
  bool isLoading = false;
  double totalAmountToSubmit = 0.0;
  double totalAmountWaiting = 0.0;
  int totalNoDraft = 0;
  int totalNoSubmitted = 0;
  int totalNoRefused = 0;
  int totalApproved = 0;
  int totalApprovedMy = 0;
  int totalPosted = 0;
  int totalNoPaid = 0;
  int pendingApprovalNo = 0;
  double waitingReimbursement = 0.0;
  double totalExpenses = 0;
  double totalCompanyExpense = 0.0;
  int totalCompanyRefused = 0;
  List<CompanyExpenseModel> companyExpense = [];
  List<Department> departmentList = [];
  List<DepartmentExpens> departmentExpense = [];
  int fkTogle = 0;
  ExpenseAttachmentModel? attachment;
  int? attachmentId;
  bool isAttachmentChanged = false;
  bool isServerLoading = false;
  bool isDeleted = false;
  Invoice? invoice;
  bool invoiceLoading = false;
  AccountMoveLine? moveLine;
  bool popUpLoading = false;
  String odooVersion = '';

  List<Expense> approvalExpense = [];

  /// fetching odoo version
  getOdooVersion() async {
    final session = await OdooSessionManager.getCurrentSession();

    final version = session!.odooSession.serverVersion;

    odooVersion = version;
    notifyListeners();
  }

  List<JournalModel> totalJournal = [];
  JournalModel? selectedJournal;

  bool errorJournal = false;
  List<SplitExpense> splitExpenseList = [];
  int wizardId = 0;
  bool isEditable = false;

  dynamic paySlip;

  ///addExpenseInitial
  expenseInitial() {
    attachment = null;

    notifyListeners();
  }

  initialExpense() {
    loadedExpense = [];
  }

  final journalDateController = TextEditingController();
  final refuseReasonController = TextEditingController();
  final userService = UserServices();
  final invoiceService = InvoiceServices();

  changeEditable(bool value) {
    isEditable = value;
    notifyListeners();
  }

  changeErrorJournal(bool change) {
    errorJournal = change;
    notifyListeners();
  }

  initialJournal() {
    selectedJournal = totalJournal[0];
    journalDateController.text =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
    notifyListeners();
  }

  clearRefuseReason() {
    refuseReasonController.text = '';
    notifyListeners();
  }

  ///splitExpense
  splitExpense(int expenseId) async {
    try {
      for (final e in splitExpenseList) {
        e.dispose();
      }

      final response = await services.splitExpense(expenseId);
      splitExpenseList = response;

      wizardId = splitExpenseList[0].wizardId!;
      notifyListeners();
    } catch (e) {}
  }

  changeLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  ///gettingSearchExpense

  gettingSearchedExpense(
    String searchText, {
    bool reset = false,
    bool admin = false,
    List<dynamic> filter = const [],
  }) async {
    try {
      isLoading = true;

      if (reset) currentPage = 1;

      isLoading = true;
      notifyListeners();

      final offset = (currentPage - 1) * pageSize;

      final res = await services.gettingExpensePagination(
        filter: filter,

        limit: pageSize,
        offset: offset,
        search: searchText,
        isAdmin: admin,
      );
      expenses = res;
      totalRecords = await services.getExpenseCount(
        search: searchText,
        isAdmin: admin,
        filter: filter,
      );

      notifyListeners();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///fetching purchase journal

  gettingPurchaseJournal() async {
    try {
      final result = await services.gettingPurchaseJournal();
      totalJournal = result;
    } catch (e) {}
  }

  deleteAttachment() {
    attachment = null;
    isDeleted = true;

    notifyListeners();
  }

  ///download invoice

  downloadInvoice(int moveId) async {
    try {
      popUpLoading = true;
      notifyListeners();

      final pdfFile = await invoiceService.downloadInvoice(moveId);

      return pdfFile;
    } catch (e) {
    } finally {
      popUpLoading = false;
      notifyListeners();
    }
  }

  ///fetch invoice

  Future<void> gettingInvoice(int id, BuildContext context) async {
    try {
      invoiceLoading = true;
      invoice = null;
      moveLine = null;
      notifyListeners();

      /// Get invoice / payment data
      final response = await invoiceService.getInvoice(id);

      if (response == null || response.isEmpty) {
        throw Exception("No invoice data found");
      }

      if (response[0]["partner_id"] == false) {
        paySlip = response[0];
        notifyListeners();

        return;
      }

      invoice = Invoice.fromJson(response.first);

      if (invoice!.invoiceLineIds.isEmpty) {
        throw Exception("Invoice has no lines");
      }

      final lineId = invoice!.invoiceLineIds.first;

      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'account.move.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', '=', lineId],
          ],
          'fields': ['id', 'quantity', 'price_unit', 'name', 'price_subtotal'],
        },
      });

      if (res != null && res.isNotEmpty) {
        moveLine = AccountMoveLine.fromJson(res.first);
      }

      notifyListeners();
    } on OdooException catch (e) {
      final msg = e.toString().split("message:").last.split(",").first.trim();

      showSnackBar(context, msg, backgroundColor: Colors.red);
    } finally {
      invoiceLoading = false;
      notifyListeners();
    }
  }

  ///deleting expense

  Future<bool> deleteExpense(int expenseId) async {
    try {
      final response = await services.deleteItems(expenseId, 'hr.expense');

      return response;
    } on OdooException catch (e) {
      rethrow;
    }
  }

  ///update expesnes

  Future<bool> updateExpense(
    Expense expense, {
    ExpenseAttachmentModel? gettingAttachment,
  }) async {
    try {
      isServerLoading = true;
      notifyListeners();

      if (isAttachmentChanged) {
        if (expense.attachment.isEmpty) {
          await services.updateAttachment(gettingAttachment!, expense);
        } else {
          await services.updateAttachment(
            gettingAttachment!,
            expense,
            attachmentId: expense.attachment[0],
          );
        }
      } else {
        if (isDeleted) {
          await services.deleteExpenseAttachment(attachmentId!);
          await services.updateExpense(expense);
        } else {
          if (expense.attachment.isEmpty) {
            await services.updateExpense(expense);
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    } finally {
      isServerLoading = false;
      isAttachmentChanged = false;
      isDeleted = false;

      notifyListeners();
    }
  }

  selectFileFromDevice({int? id}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    isAttachmentChanged = true;
    final pf = result.files.first;
    final String name = pf.name;
    final Uint8List bytes = pf.bytes ?? await File(pf.path!).readAsBytes();
    final String mimeType =
        lookupMimeType(name, headerBytes: bytes) ?? 'application/octet-stream';
    final String base64Str = base64Encode(bytes);
    attachment = ExpenseAttachmentModel(
      id: id ?? 0,
      name: name,
      mimetype: mimeType,
      datas: base64Str,
    );

    notifyListeners();
  }

  filteredExpenseList(List<Expense> list) {
    expenses = list;
    notifyListeners();
  }

  ///fetch expense attachment
  getExpenseAttachment(int expenseId) async {
    try {
      isLoading = true;

      final response = await services.getAttachmentOfExpense(expenseId);

      attachment = response;

      attachmentId = attachment!.id;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;

      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  changeFkTogle(int value) {
    fkTogle = value;

    notifyListeners();
  }

  ///pagination of approval

  int currentPageApproval = 1;
  final int pageSizeApproval = 40;
  int totalRecordsApproval = 0;

  int get startCountApproval => totalRecordsApproval == 0
      ? 0
      : ((currentPageApproval - 1) * pageSizeApproval) + 1;

  int get endCountApproval {
    final end = currentPageApproval * pageSizeApproval;
    return end > totalRecordsApproval ? totalRecordsApproval : end;
  }

  String get paginationTextApproval => totalRecordsApproval == 0
      ? '0 of 0'
      : '$startCountApproval–$endCountApproval / $totalRecordsApproval';

  int get totalPagesApproval => totalRecordsApproval == 0
      ? 1
      : (totalRecordsApproval / pageSizeApproval).ceil();

  bool get canGoPreviousApproval => currentPageApproval > 1;

  bool get canGoNextApproval => currentPageApproval < totalPagesApproval;

  emptyApproval() {
    approvalExpense = [];
    notifyListeners();
  }

  /// fetching expense by pagination
  Future<void> loadExpensesApproval({
    bool reset = false,
    bool admin = false,
    bool isApproved = false,
    List<dynamic> filter = const [],
  }) async {
    if (reset) currentPageApproval = 1;

    isLoading = true;
    notifyListeners();

    final offset = (currentPageApproval - 1) * pageSizeApproval;

    approvalExpense = await services.gettingExpensePagination(
      limit: pageSizeApproval,
      offset: offset,
      isAdmin: admin,
      isApproved: isApproved,
      filter: filter,
    );

    totalRecordsApproval = await services.getExpenseCount(
      isAdmin: admin,
      isApproved: isApproved,
      filter: filter,
    );

    isLoading = false;
    notifyListeners();
  }

  /// next button

  void nextPageApproval({bool admin = false, bool isApproved = false}) {
    if (!canGoNextApproval) return;
    currentPageApproval++;
    loadExpensesApproval(admin: admin, isApproved: isApproved);
  }

  ///previous button
  void previousPageApproval({bool isAdmin = false, bool isApproved = false}) {
    if (!canGoPreviousApproval) return;
    currentPageApproval--;
    loadExpensesApproval(admin: isAdmin, isApproved: isApproved);
  }

  ///getting user expense

  int currentPage = 1;
  final int pageSize = 40;
  int totalRecords = 0;

  ///start count
  int get startCount =>
      totalRecords == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;

  /// end count
  int get endCount {
    final end = currentPage * pageSize;
    return end > totalRecords ? totalRecords : end;
  }

  ///pagination text
  String get paginationText =>
      totalRecords == 0 ? '0/0' : '$startCount–$endCount / $totalRecords';

  /// total page
  int get totalPages =>
      totalRecords == 0 ? 1 : (totalRecords / pageSize).ceil();

  /// can go previous
  bool get canGoPrevious => currentPage > 1;

  /// can go next
  bool get canGoNext => currentPage < totalPages;

  List<Expense> loadedExpense = [];

  ///load expense
  Future<void> loadExpenses({
    bool reset = false,
    bool admin = false,
    bool isApproved = false,
    List<dynamic> filter = const [],
  }) async {
    if (reset) currentPage = 1;

    isLoading = true;
    notifyListeners();
    initialExpense();

    final offset = (currentPage - 1) * pageSize;

    loadedExpense = await services.gettingExpensePagination(
      limit: pageSize,
      offset: offset,
      isAdmin: admin,
      isApproved: isApproved,
      filter: filter,
    );

    totalRecords = await services.getExpenseCount(
      isAdmin: admin,
      isApproved: isApproved,
      filter: filter,
    );

    isLoading = false;
    notifyListeners();
  }

  void nextPage({bool admin = false, bool isApproved = false}) {
    if (!canGoNext) return;
    currentPage++;
    loadExpenses(admin: admin, isApproved: isApproved);
  }

  void previousPage({bool isAdmin = false, bool isApproved = false}) {
    if (!canGoPrevious) return;
    currentPage--;
    loadExpenses(admin: isAdmin, isApproved: isApproved);
  }

  ///get expense
  getExpenses(BuildContext context, bool isAdmin) async {
    try {
      isLoading = true;
      totalAmountToSubmit = 0.0;
      totalAmountWaiting = 0.0;
      totalNoDraft = 0;
      totalNoSubmitted = 0;
      totalNoRefused = 0;
      totalPosted = 0;
      totalExpenses = 0;
      totalNoPaid = 0;
      waitingReimbursement = 0;
      totalCompanyExpense = 0;
      totalCompanyRefused = 0;
      totalApproved = 0;
      totalApprovedMy = 0;
      departmentExpense = [];
      pendingApprovalNo = 0;

      final result = await services.gettingExpense();
      expenses = result;

      if (expenses.isEmpty) {
        companyExpense = [];
        notifyListeners();

        return;
      }

      for (final exp in expenses) {
        switch (exp.state) {
          case 'approved':
            waitingReimbursement += exp.totalAmount;
            totalExpenses += exp.totalAmount;
            totalApprovedMy += 1;
            notifyListeners();
            break;

          case 'reported':
            totalAmountToSubmit += exp.totalAmount;
            totalExpenses += exp.totalAmount;
            notifyListeners();
            break;

          case 'draft':
            totalNoDraft += 1;
            totalAmountToSubmit += exp.totalAmount;
            totalExpenses += exp.totalAmount;
            notifyListeners();
            break;

          case 'submitted':
            totalNoSubmitted += 1;
            totalAmountWaiting += exp.totalAmount;
            totalExpenses += exp.totalAmount;
            notifyListeners();
            break;

          case 'refused':
            totalNoRefused += 1;
            totalExpenses += exp.totalAmount;
            notifyListeners();
            break;

          case 'posted':
            totalNoPaid += 1;
            totalPosted += 1;
            totalExpenses += exp.totalAmount;
            notifyListeners();
            break;
          case 'paid':
            totalNoPaid += 1;
            totalExpenses += exp.totalAmount;
            notifyListeners();
            break;

          default:
            totalExpenses += exp.totalAmount;
            notifyListeners();
        }
      }

      ///getting company expense if admin
      await getCompanyExpense(isAdmin);

      notifyListeners();
    } on OdooException catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///refuse action button
  refuseAction(int id, BuildContext context, String msg) async {
    loadingDialog(
      context,
      "Refusing expense",
      "Please wait while refusing expense",
      LoadingAnimationWidget.fourRotatingDots(
        color: MoboColor.redColor,
        size: 30,
      ),
    );

    try {
      final response = await services.refuseExpense(id, msg);

      if (response) {
        emptyApproval();
        await getExpenses(
          context,
          Provider.of<UserProvider>(context, listen: false).isAdmin,
        );

        await loadExpenses();
        CustomSnackBar.showSuccess(context, 'Refused expense successfully');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on OdooException catch (e) {
      CustomSnackBar.showError(
        context,
        ' ${e.toString().split("message:").last.split(",").first.trim()}',
      );
    }
  }

  ///post journal
  Future<bool> postJournalAction(
    int expenseId,
    int journalId,
    String date, {
    bool isPaidBySelf = true,
  }) async {
    if (date.isEmpty) {
      return false;
    }
    final parsed = DateFormat("d-M-yyyy").parse(date);
    final formatted = DateFormat("yyyy-MM-dd").format(parsed);

    try {
      final response = await services.postJournal(
        'action_post',
        'hr.expense',
        expenseId,
        formatted,
        journalId,
        isPaidBySelf,
      );

      return response;
    } on OdooException catch (e) {
      rethrow;
    }
  }

  /// action button method

  Future<bool> buttonAction(String method, String model, int id) async {
    try {
      if (method.isEmpty || model.isEmpty) {
        return false;
      }

      final response = await services.buttonAction(id, model, method);
      return response;
    } on OdooException catch (e) {
      rethrow;
    }
  }

  ///getting expense approval only
  gettingApprovalList(OdooClient client) async {
    try {
      isLoading = true;

      expenses = [];

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///getting adminFull expense
  getAdminFullExpense() async {
    try {
      isLoading = true;

      final res = await services.gettingFullExpenseByAdmin();
      expenses = [];

      expenses = res;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///getting all expense if admin
  getCompanyExpense(bool isAdmin) async {
    try {
      if (isAdmin) {
        final res = await services.getTotalCompany();
        departmentList = await userService.getDepartmentList();

        companyExpense = res;
        for (final exp in companyExpense) {
          totalCompanyExpense += exp.totalAmount;

          switch (exp.state) {
            case 'approved':
              totalApproved += 1;
              notifyListeners();
              break;

            case 'draft':
              pendingApprovalNo += 1;
              notifyListeners();
              break;

            case 'submitted':
              pendingApprovalNo += 1;
              notifyListeners();
              break;

            case 'refused':
              totalCompanyRefused += 1;

              notifyListeners();
              break;

            case 'posted':
              totalApproved += 1;
              notifyListeners();
              break;
            case 'paid':
              totalApproved += 1;
              notifyListeners();
              break;
          }
        }

        departmentExpense = departmentList.map((department) {
          final matches = companyExpense.where(
            (exp) => exp.departmentId == department.id,
          );

          final totalAmount = matches.fold<double>(
            0.0,
            (sum, item) => sum + item.totalAmount,
          );

          return DepartmentExpens(
            id: department.id,
            name: department.name,
            expense: totalAmount,
          );
        }).toList();

        notifyListeners();
        return;
      } else {
        companyExpense = [];
        departmentExpense = [];
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  ///reset
  void reset() {
    /// -------- Core Lists --------
    expenses.clear();
    companyExpense.clear();
    departmentList.clear();
    departmentExpense.clear();
    splitExpenseList.forEach((e) => e.dispose());
    splitExpenseList.clear();
    approvalExpense.clear();
    _initialLoaded = false;
    _isInitialLoading = true;
    loadedExpense = [];

    /// -------- Totals & Counters --------
    totalAmountToSubmit = 0.0;
    totalAmountWaiting = 0.0;
    waitingReimbursement = 0.0;
    totalExpenses = 0.0;
    totalCompanyExpense = 0.0;

    totalNoDraft = 0;
    totalNoSubmitted = 0;
    totalNoRefused = 0;
    totalApproved = 0;
    totalApprovedMy = 0;
    totalPosted = 0;
    totalNoPaid = 0;
    pendingApprovalNo = 0;
    totalCompanyRefused = 0;

    ///-------- Flags --------
    isLoading = false;
    isServerLoading = false;
    invoiceLoading = false;
    popUpLoading = false;
    isAttachmentChanged = false;
    isDeleted = false;
    isEditable = false;
    errorJournal = false;

    /// -------- Attachment / Invoice --------
    attachment = null;
    attachmentId = null;
    invoice = null;
    moveLine = null;
    paySlip = null;

    /// -------- Journal --------
    totalJournal.clear();
    selectedJournal = null;
    journalDateController.clear();
    refuseReasonController.clear();

    /// -------- Pagination --------
    currentPage = 1;
    totalRecords = 0;

    /// -------- Version --------
    odooVersion = '';

    notifyListeners();
  }

  ///submit expenses

  Future<bool> submitExpense({
    ExpenseAttachmentModel? attachment,
    required int employeeId,
    required String name,
    required double amount,
    required List<int> taxId,
    required String date,
    required int categoryId,
    required String paymentBy,
    String? notes,
  }) async {
    if (name.isEmpty || amount <= 0 || date.isEmpty) {
      return false;
    }

    return services.addExpense(
      attachment: attachment,
      employeeId: employeeId,
      name: name,
      amount: amount,
      taxId: taxId,
      date: date,
      categoryId: categoryId,
      paymentBy: paymentBy,
      notes: notes,
    );
  }
}
