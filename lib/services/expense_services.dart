import 'dart:convert' show base64Decode;
import 'package:intl/intl.dart';
import 'package:mobo_expenses/model/company_expense_model.dart';
import 'package:mobo_expenses/model/expense_attachment_model.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/model/journal_model.dart';
import '../core/services/odoo_session_manager.dart';
import '../model/split_list_model.dart';

class ExpenseServices {
  ///search expense
  Future gettingSearchExpense(int id, {String typed = ''}) async {
    try {
      final List domain = [];

      domain.add(['employee_id', '=', id]);

      if (typed.trim().isNotEmpty) {
        final amount = double.tryParse(typed);

        if (amount != null) {
          domain.addAll([
            '|',
            ['name', 'ilike', typed],
            ['total_amount', '=', amount],
          ]);
        } else {
          domain.add(['name', 'ilike', typed]);
        }
      }

      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': domain,
          'fields': [
            'employee_id',
            'description',
            'name',
            'date',
            'tax_ids',
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",

            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'untaxed_amount',
            'manager_id',
            'message_main_attachment_id',
            'split_expense_origin_id',
          ],
        },
      });

      final list = List<Map<String, dynamic>>.from(res as List);

      final expenseList = list.map((item) => Expense.fromJson(item)).toList();

      return expenseList;
    } catch (e) {
      rethrow;
    }
  }

  ///get expense count
  Future<int> getExpenseCount({
    String search = '',
    bool isAdmin = false,
    bool isApproved = false,
    List<dynamic> filter = const [],
  }) async {
    final client = await OdooSessionManager.getClient();

    final userId = client!.sessionId?.userId;
    final List domain = [];

    if (filter.isEmpty) {
      if (!isAdmin) {
        domain.add(['employee_id.user_id', '=', userId]);
      }

      if (!isApproved) {
        if (search.trim().isNotEmpty) {
          final amount = double.tryParse(search);

          if (amount != null) {
            domain.addAll([
              '|',
              ['name', 'ilike', search],
              ['total_amount', '=', amount],
            ]);
          } else {
            domain.add(['name', 'ilike', search]);
          }
        }
      } else {
        domain.add([
          'state',
          'in',
          ['submitted'],
        ]);
      }
    } else {
      domain.addAll(filter);
    }

    final count = await OdooSessionManager.callKwWithCompany({
      'model': 'hr.expense',
      'method': 'search_count',
      'args': [domain],
      'kwargs': {},
    });

    return count as int;
  }

  ///getting expense sheet

  gettingIdExpenseSheet(int expenseId) async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'hr.expense',
      'method': 'action_view_sheet',
      'args': [
        [expenseId],
      ],
      'kwargs': {},
    });

    return result['res_id'];
  }

  ///get expense by pagination

  Future gettingExpensePagination({
    required int limit,
    required int offset,
    String search = '',
    bool isAdmin = false,
    bool isApproved = false,
    List<dynamic> filter = const [],
  }) async {
    final client = await OdooSessionManager.getClient();
    final userId = client!.sessionId?.userId;

    try {
      final List domain = [];

      if (filter.isEmpty) {
        if (!isAdmin) {
          domain.add(['employee_id.user_id', '=', userId]);
        }

        if (!isApproved) {
          if (search.trim().isNotEmpty) {
            final amount = double.tryParse(search);

            if (amount != null) {
              domain.addAll([
                '|',
                ['name', 'ilike', search],
                ['total_amount', '=', amount],
              ]);
            } else {
              domain.add(['name', 'ilike', search]);
            }
          }
        } else {
          domain.add([
            'state',
            'in',
            ['submitted'],
          ]);
        }
      } else {
        domain.addAll(filter);
        if (search.trim().isNotEmpty) {
          final amount = double.tryParse(search);

          if (amount != null) {
            domain.addAll([
              '|',
              ['name', 'ilike', search],
              ['total_amount', '=', amount],
            ]);
          } else {
            domain.add(['name', 'ilike', search]);
          }
        }
      }

      final session = await OdooSessionManager.getCurrentSession();

      final version = await session!.odooSession.serverVersion;

      if (version == '18' || version == '17') {
        var res = await await OdooSessionManager.callKwWithCompany({
          'model': 'hr.expense',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': domain,
            'limit': limit,
            'offset': offset,
            'order': 'date desc',
          },
        });
        final list = res as List;
        return list.map((e) => Expense.fromJson(e)).toList();
      }

      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': domain,
          'fields': [
            'employee_id',
            'description',
            'name',
            'date',
            'tax_ids',
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",
            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'untaxed_amount',
            'manager_id',
            'message_main_attachment_id',
            'split_expense_origin_id',
          ],
          'limit': limit,
          'offset': offset,
          'order': 'date desc',
        },
      });

      final list = res as List;
      return list.map((e) => Expense.fromJson(e)).toList();
    } catch (e) {}
  }

  ///getting expense
  Future gettingExpense() async {
    try {
      final session = await OdooSessionManager.getCurrentSession();

      final version = session!.odooSession.serverVersion;

      final client = await OdooSessionManager.getClient();

      final id = client!.sessionId?.userId;

      if (version == '18' || version == '17') {
        var res = await OdooSessionManager.callKwWithCompany({
          'model': 'hr.expense',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['employee_id.user_id', '=', id],
            ],
            'fields': [
              'employee_id',
              'description',
              'name',
              'date',
              'tax_ids',
              'product_id',
              "payment_mode",
              "activity_ids",
              "company_id",
              "total_amount",
              "state",

              'tax_amount',
              'untaxed_amount_currency',
              'message_main_attachment_id',
            ],
          },
        });
        final list = List<Map<String, dynamic>>.from(res as List);
        final expenseList = list.map((item) => Expense.fromJson(item)).toList();

        return expenseList;
      }

      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['employee_id.user_id', '=', id],
          ],
          'fields': [
            'employee_id',
            'description',
            'name',
            'date',
            'tax_ids',
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",
            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'untaxed_amount',
            'manager_id',
            'message_main_attachment_id',
            'split_expense_origin_id',
          ],
        },
      });

      final list = List<Map<String, dynamic>>.from(res as List);
      final expenseList = list.map((item) => Expense.fromJson(item)).toList();

      return expenseList;
    } catch (e) {
      rethrow;
    }
  }

  ///detailed expense
  Future gettingSingleExpense(int id) async {
    try {
      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', '=', id],
          ],
          'fields': [
            'employee_id',
            'description',
            'name',
            'tax_ids',
            'date',
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",
            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'untaxed_amount',
            'manager_id',
            'message_main_attachment_id',
            'split_expense_origin_id',
          ],
        },
      });

      final Map<String, dynamic> result = res[0];

      final expense = Expense.fromJson(result);

      return expense;
    } catch (e) {
      rethrow;
    }
  }

  ///getting approved Expense
  gettingFullApprovalExpense() async {
    try {
      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            [
              'state',
              'in',
              ['submitted'],
            ],
          ],
          'fields': [
            'employee_id',
            'description',
            'tax_ids',
            'name',
            'date',
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",
            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'untaxed_amount',
            'manager_id',
            'message_main_attachment_id',
            'split_expense_origin_id',
          ],
        },
      });

      final list = List<Map<String, dynamic>>.from(res as List);
      final expenseList = list.map((item) => Expense.fromJson(item)).toList();

      return expenseList;
    } catch (e) {
      rethrow;
    }
  }

  ///getting full expense for admin

  Future gettingFullExpenseByAdmin() async {
    try {
      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [],
          'fields': [
            'employee_id',
            'description',
            'tax_ids',
            'name',
            'date',
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",
            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'untaxed_amount',
            'manager_id',
            'message_main_attachment_id',
            'split_expense_origin_id',
          ],
        },
      });

      final list = List<Map<String, dynamic>>.from(res as List);
      final expenseList = list.map((item) => Expense.fromJson(item)).toList();

      return expenseList;
    } catch (e) {
      rethrow;
    }
  }

  ///   total company list
  Future<List<CompanyExpenseModel>> getTotalCompany() async {
    try {
      final session = await OdooSessionManager.getCurrentSession();
      final version = session!.odooSession.serverVersion;
      final bool isOdoo18 = version == '18' || version == '17';

      /// Fetch expenses
      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [],
          'fields': [
            'id',
            'total_amount',
            'state',
            'employee_id',

            if (!isOdoo18) 'department_id',
            if (!isOdoo18) 'company_id',
          ],
        },
      });

      if (res == null || res is! List) return [];

      List<CompanyExpenseModel> expenses = res
          .map<CompanyExpenseModel>((e) => CompanyExpenseModel.fromJson(e))
          .toList();

      /// Odoo 18 → inject department from hr.employee
      if (isOdoo18) {
        final deptMap = await _getDepartmentsByEmployee(expenses);

        expenses = expenses.map((e) {
          final dept = deptMap[e.id] ?? const {'id': 0, 'name': ''};
          return CompanyExpenseModel(
            id: e.id,
            totalAmount: e.totalAmount,
            state: e.state,
            departmentId: dept['id'],
            departmentName: dept['name'],
            companyId: e.companyId,
            companyName: e.companyName,
          );
        }).toList();
      }

      return expenses;
    } catch (e, st) {
      rethrow;
    }
  }

  /// get department by employee
  Future<Map<int, Map<String, dynamic>>> _getDepartmentsByEmployee(
    List<CompanyExpenseModel> expenses,
  ) async {
    final employeeIds = expenses.map((e) => e.id).toSet().toList();

    if (employeeIds.isEmpty) return {};

    ///calling
    final res = await OdooSessionManager.callKwWithCompany({
      'model': 'hr.employee',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', 'in', employeeIds],
        ],
        'fields': ['department_id'],
      },
    });

    if (res == null || res is! List) return {};

    final Map<int, Map<String, dynamic>> map = {};

    for (final e in res) {
      final dept = e['department_id'];
      map[e['id']] = {
        'id': (dept is List && dept.isNotEmpty) ? dept[0] : 0,
        'name': (dept is List && dept.length > 1) ? dept[1] : '',
      };
    }

    return map;
  }

  /// fetching attachment of expense
  getAttachmentOfExpense(int id) async {
    try {
      var result = await OdooSessionManager.callKwWithCompany({
        'model': 'ir.attachment',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['res_model', '=', 'hr.expense'],
            ['res_id', '=', id],
          ],
          'fields': ['id', 'name', 'mimetype', 'datas', 'file_size'],
        },
      });

      final data = result as List;

      if (data.isEmpty) {
        return null;
      }
      final attachment = data
          .map((item) => ExpenseAttachmentModel.fromJson(item))
          .toList();
      return attachment[0];
    } catch (e) {
      rethrow;
    }
  }

  /// updating  attachment of expense
  updateAttachment(
    ExpenseAttachmentModel attachment,

    Expense expense, {
    int? attachmentId,
  }) async {
    try {
      if (attachmentId == null) {
        final res = await OdooSessionManager.callKwWithCompany({
          'model': 'ir.attachment',
          'method': 'create',
          'args': [
            {
              'name': attachment.name,
              'datas': attachment.datas,
              'mimetype': attachment.mimetype,
              'res_model': 'hr.expense',
              'type': 'binary',
              'res_id': expense.id,
            },
          ],
          'kwargs': [],
        });
        await updateExpense(expense);
      } else {
        await updateExpense(expense);

        final res = await OdooSessionManager.callKwWithCompany({
          'model': 'ir.attachment',
          'method': 'write',
          'args': [
            [attachmentId],
            {
              'name': attachment.name,
              'datas': attachment.datas,
              'mimetype': attachment.mimetype,
              'type': 'binary',
              'file_size': base64Decode(attachment.datas!).length,
              'res_model': 'hr.expense',
              'res_id': expense.id,
            },
          ],
          'kwargs': [],
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  ///update expense details
  updateExpense(Expense expense) async {
    try {
      final date = expense.date!.split('-');
      final updated = "${date[2]}-${date[1]}-${date[0]}";
      final taxIdDomain = expense.taxIds.map((id) => id).toList();
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final res = await OdooSessionManager.callKwWithCompany(
        {
          'model': 'hr.expense',
          'method': 'write',
          'args': [
            [expense.id],
            {
              'employee_id': expense.employeeId[0],

              'name': expense.name,
              'product_id': expense.productId[0],
              'date': updated,
              'payment_mode': expense.paymentMode,
              'description': expense.description,
              'tax_ids': [
                [6, 0, taxIdDomain],
              ],

              'total_amount': expense.totalAmount,
            },
          ],
          'kwargs': [],
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      return res;
    } catch (e) {
      rethrow;
    }
  }

  /// create  new expense
  Future<bool> addExpense({
    ExpenseAttachmentModel? attachment,
    required int employeeId,
    required String name,
    required double amount,
    required List<int> taxId,
    required String date,
    required categoryId,
    required String paymentBy,
    String? notes,
  }) async {
    try {
      final formated = DateFormat("dd-MM-yyyy").parse(date);

      final formattedDate =
          '${formated.year}-${formated.month}-${formated.day}';

      final taxIdDOmain = taxId.map((id) => [4, id]).toList();

      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final res = await OdooSessionManager.callKwWithCompany(
        {
          'model': 'hr.expense',
          'method': 'create',
          'args': [
            {
              'employee_id': employeeId,
              'name': name,
              'product_id': categoryId,
              'date': formattedDate,
              'description': notes,
              'total_amount_currency': amount,
              'total_amount': amount,
              'payment_mode': paymentBy,
              'tax_ids': taxIdDOmain,
            },
          ],
          'kwargs': {},
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      if (attachment != null) {
        await OdooSessionManager.callKwWithCompany({
          'model': 'ir.attachment',
          'method': 'create',
          'args': [
            {
              'name': attachment.name,
              'datas': attachment.datas,
              'mimetype': attachment.mimetype,
              'res_model': 'hr.expense',
              'type': 'binary',
              'res_id': res,
            },
          ],
          'kwargs': [],
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// split the expense
  gettingSplitExpense(int id) async {
    try {
      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'action_open_split_expense',
        'args': [
          [id],
        ],
        'kwargs': {},
      });
      var domain = res["domain"];

      List<int> ids = List<int>.from(domain[0][2]);

      return ids;
    } catch (e) {
      rethrow;
    }
  }

  ///delete expense attachment
  deleteExpenseAttachment(int id) async {
    final res = await OdooSessionManager.callKwWithCompany({
      'model': 'ir.attachment',
      'method': 'unlink',
      'args': [
        [id],
      ],
      'kwargs': {},
    });
  }

  /// delete items
  Future deleteItems(int id, String model) async {
    try {
      final res = await OdooSessionManager.callKwWithCompany({
        'model': model,
        'method': 'unlink',
        'args': [
          [id],
        ],
        'kwargs': {},
      });

      return true;
    } catch (e) {
      rethrow;
    }
  }

  ///refuse expense

  Future<bool> refuseExpense(int expenseId, String msg) async {
    try {
      final createRes = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense.refuse.wizard',
        'method': 'create',
        'args': [
          {'reason': msg},
        ],
        'kwargs': {
          'context': {
            'active_id': expenseId,
            'active_ids': [expenseId],
          },
        },
      });
      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense.refuse.wizard',
        'method': 'action_refuse',
        'args': [
          [createRes],
        ],
        'kwargs': {
          'context': {
            'active_id': expenseId,
            'active_ids': [expenseId],
          },
        },
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  ///button actions
  buttonAction(int id, String model, String method) async {
    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final res = await OdooSessionManager.callKwWithCompany(
        {
          'model': model,
          'method': method,
          'args': [
            [id],
          ],
          'kwargs': {},
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  ///post journal
  postJournal(
    String method,
    String model,
    int expensId,
    String date,
    int journalId,
    bool isPaidBySelf,
  ) async {
    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final res = await OdooSessionManager.callKwWithCompany(
        {
          'model': model,
          'method': method,
          'args': [
            [expensId],
          ],
          'kwargs': {},
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      if (isPaidBySelf) {
        final String wizardModel = res['res_model'];
        final dynamic resId = res['res_id'];
        final Map context = res['context'] ?? {};

        final r = await OdooSessionManager.callKwWithCompany({
          'model': wizardModel,
          'method': 'write',
          'args': [
            [resId],
            {'employee_journal_id': journalId, 'accounting_date': date},
          ],
          'kwargs': {},
        });

        final postingJournal = await OdooSessionManager.callKwWithCompany(
          {
            'model': wizardModel,
            'method': 'action_post_entry',
            'args': [
              [resId],
            ],
            'kwargs': {'context': context},
          },
          companyId: companyId,
          allowedCompanyIds: [companyId],
        );
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  ///split expense
  splitExpense(int id) async {
    try {
      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'action_split_wizard',
        'args': [
          [id],
        ],
        'kwargs': {},
      });

      final String wizardModel = res['res_model'];
      final int wizardId = res['res_id'];
      final Map context = res['context'];

      final lines = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense.split',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['wizard_id', '=', wizardId],
          ],
          'fields': [
            'id',
            'name',
            'employee_id',
            'total_amount_currency',
            'wizard_id',
          ],
          'context': context,
        },
      });

      final result = lines as List;

      final splitExpenses = result
          .map((line) => SplitExpense.fromJson(line))
          .toList();

      return splitExpenses;
    } catch (e) {}
  }

  ///submit the splitting expense
  submitSplitting(int wizardId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense.split.wizard',
        'method': 'action_split_expense',
        'args': [
          [wizardId],
        ],
        'kwargs': {},
      });
    } catch (e) {
      rethrow;
    }
  }

  ///editing split expense
  Future<bool> editingSplitLines(List<SplitExpense> list) async {
    try {
      for (final line in list) {
        await OdooSessionManager.callKwWithCompany({
          'model': 'hr.expense.split',
          'method': 'write',
          'args': [
            [line.id],
            {'employee_id': line.employeeId},
          ],
          'kwargs': {},
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// fetch purchase journal
  gettingPurchaseJournal() async {
    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final res = await OdooSessionManager.callKwWithCompany(
        {
          'model': "account.journal",
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ["type", '=', 'purchase'],
            ],
            'fields': [
              'code',
              'type',
              'display_name',
              'id',
              'default_account_id',
            ],
          },
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );
      final result = res as List;
      final journal = result
          .map((single) => JournalModel.fromJson(single))
          .toList();

      return journal;
    } catch (e) {}
  }

  ///fetching state of expense

  gettingState(int expenseId) async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'hr.expense',
      'method': 'action_view_sheet',
      'args': [
        [expenseId],
      ],
      'kwargs': {},
    });

    final id = result['res_id'];

    final expenseState = await OdooSessionManager.callKwWithCompany({
      'model': 'hr.expense.sheet',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', '=', id],
        ],
        'fields': ['state'],
      },
    });

    final exState = expenseState as List;

    final state = exState[0]['state'];

    return state;
  }
}
