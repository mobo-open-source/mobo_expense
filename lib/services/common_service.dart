import 'package:mobo_expenses/model/categories_full.dart';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/expenseCategory.dart';
import '../core/services/odoo_session_manager.dart';
import '../model/expense_model.dart';
import '../model/tax_model.dart';

class CommonServices {
  ///fetch tax by company
  gettingTaxByCompany() async {
    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final records = await OdooSessionManager.callKwWithCompany(
        {
          'model': "account.tax",
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['type_tax_use', '=', 'purchase'],
            ],
            'fields': ['id', 'display_name'],
          },
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      final result = records as List;

      final taxes = result.map((item) => TaxModel.fromJson(item)).toList();

      return taxes;
    } catch (e) {}
  }

  ///fetch complete tax
  gettingTaxByFullCompany() async {
    try {
      final records = await OdooSessionManager.callKwWithCompany({
        'model': "account.tax",
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['type_tax_use', '=', 'purchase'],
          ],
          'fields': ['id', 'display_name'],
        },
      });

      final result = records as List;

      final taxes = result.map((item) => TaxModel.fromJson(item)).toList();

      return taxes;
    } catch (e) {}
  }

  ///fetch single category
  Future<CategoriesFullModel?> getSingleCategory(int id) async {
    try {
      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', '=', id],
          ],
        },
      });

      if (res is! List || res.isEmpty) return null;

      final raw = res[0] as Map<String, dynamic>;

      final categories = CategoriesFullModel.fromJson(raw);

      String tax = '';

      List<dynamic> taxId = [];

      if (raw['supplier_taxes_id'] is List &&
          (raw['supplier_taxes_id'] as List).isNotEmpty) {
        taxId = raw['supplier_taxes_id'] as List;

        final taxRes = await OdooSessionManager.callKwWithCompany({
          'model': 'account.tax',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', 'in', taxId],
            ],
            'fields': ['id', 'display_name'],
          },
        });

        if (taxRes is List && taxRes.isNotEmpty) {
          tax = taxRes.map((single) => single['display_name']).join(' , ');
        }
      }

      final newCategory = categories.copyWith(supplierTaxes: tax, taxId: taxId);

      return newCategory;
    } catch (e, st) {
      return null;
    }
  }

  ///update category
  updateCategory(dynamic data, int id) async {
    try {
      var result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'write',
        'args': [
          [id],
          data,
        ],
        'kwargs': {},
      });
    } catch (e) {
      rethrow;
    }
  }

  ///fetch category count

  Future<int> getCategoryCount() async {
    final count = await OdooSessionManager.callKwWithCompany({
      'model': 'product.product',
      'method': 'search_count',
      'args': [
        [
          ['can_be_expensed', '=', true],
        ],
      ],
      'kwargs': {},
    });

    return count as int;
  }

  /// fetch total category
  getTotalCategory({required int limit, required int offset}) async {
    try {
      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['can_be_expensed', '=', true],
          ],
          'fields': ['id', 'name', 'image_1920', "default_code"],
          'limit': limit,
          'offset': offset,
        },
      });
      final data = res as List;
      final category = data
          .map((data) => ExpenseCategory.fromJson(data))
          .toList();

      return category;
    } catch (e) {}
  }

  ///fetch search employee
  getSearchEmployee({int limit = 3, int offset = 0, String typed = ''}) async {
    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();
      final domain = typed == ''
          ? [
              [
                'company_id',
                'in',
                [companyId, false],
              ],
            ]
          : [
              [
                'company_id',
                'in',
                [companyId, false],
              ],
              ['name', 'ilike', typed],
            ];

      var res = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.employee',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': domain,
          'fields': ['name', 'id', 'work_phone', 'image_1920'],
          'limit': limit,
          'offset': offset,
        },
      });

      final data = res as List;

      final empl = data.map((data) => Employee.fromJson(data)).toList();

      return empl;
    } catch (e) {}
  }

  /// filtering
  filtering(List<dynamic> domain) async {
    try {
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
            'product_id',
            "payment_mode",
            "activity_ids",
            "company_id",
            "total_amount",
            "state",
            "department_id",
            'manager_id',
            'tax_amount',
            'tax_ids',
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
    } catch (e) {}
  }

  ///calculate tax
  calculateTax(List<TaxModel> taxId, double amount) async {
    final taxIds = taxId.map((tax) => tax.id).toList();

    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final result = await OdooSessionManager.callKwWithCompany(
        {
          'model': 'account.tax',
          'method': 'compute_all',
          'args': [taxIds],
          'kwargs': {'price_unit': amount},
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      double totalTax = 0.0;

      for (final tax in result['taxes']) {
        totalTax += (tax['amount'] as num).toDouble();
      }

      return totalTax;
    } catch (e) {}
  }

  /// adding category
  Future<void> addingCategory(dynamic data) async {
    try {
      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final res = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'create',
        'args': [data],
        'kwargs': {
          'context': {'default_can_be_expensed': 1},
        },
      });
    } catch (e) {
      rethrow;
    }
  }

  ///getting   productCategory

  gettingTypedCategory() async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.category',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ["id", 'display_name'],
        },
      });

      final response = result as List;
      return result;
    } catch (e) {}
  }

  ///groupByServices

  readGroupCommon({
    required List domain,
    required List<String> fields,
    required List<String> groupBy,
    Map<String, dynamic>? context,
  }) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.expense',
        'method': 'read_group',
        'args': [],
        'kwargs': {
          'domain': domain,
          'fields': fields,
          'groupby': groupBy,
          'context': context ?? {},
        },
      });

      return result as List;
    } catch (e) {
      rethrow;
    }
  }
}
