import 'dart:async';
import 'package:mobo_expenses/model/employee.dart';
import 'package:mobo_expenses/model/department_model.dart';
import 'package:mobo_expenses/model/user_model.dart';

import '../core/services/odoo_session_manager.dart';

class UserServices {
  ///fetching user details
  Future<UserModel?> gettingUserDetails() async {
    try {
      final session = await OdooSessionManager.getCurrentSession();

      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final employees = await OdooSessionManager.callKwWithCompany(
        {
          'model': 'res.users',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', session!.userId],
            ],
            'fields': [
              'name',
              'job_title',
              'image_1920',
              'work_email',
              'work_phone',
              'employee_id',
              'id',
            ],
          },
        },
        companyId: companyId,
        allowedCompanyIds: [companyId!],
      );

      final Map<String, dynamic> emp = employees[0];

      final users = UserModel.fromJson(emp);

      return users;
    } catch (e) {
      rethrow;
    }
  }

  ///checking admin
  checkingAdmin() async {
    try {
      final client = await OdooSessionManager.getClient();

      final userId = client!.sessionId?.userId;

      if (userId == null) {
        return;
      }

      final session = await OdooSessionManager.getCurrentSession();

      final version = session!.odooSession.serverVersion;

      bool hasExpenseManager = false;

      if (version == '17') {
        hasExpenseManager = await client.callKw({
          'model': 'res.users',
          'method': 'has_group',
          'args': ['hr_expense.group_hr_expense_manager'],
          'kwargs': {},
        });
      } else {
        hasExpenseManager = await client.callKw({
          'model': 'res.users',
          'method': 'has_group',
          'args': [
            [userId],
            'hr_expense.group_hr_expense_manager',
          ],
          'kwargs': {},
        });
      }

      return hasExpenseManager;
    } catch (e) {
      rethrow;
    }
  }

  ///fetch department List
  Future getDepartmentList() async {
    try {
      final db = await OdooSessionManager.callKwWithCompany({
        'model': 'hr.department',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [],
          'fields': ['id', 'name'],
        },
      });

      List<Department> departments = (db as List)
          .map((e) => Department.fromJson(e))
          .toList();

      return departments;
    } catch (e) {
      rethrow;
    }
  }

  ///fetch current employee details
  Future gettingCurrentEmployee({bool selected = false, int id = 0}) async {
    try {
      final client = await OdooSessionManager.getClient();

      final companyId = await OdooSessionManager.getSelectedCompanyId();

      final userId = client!.sessionId?.userId;

      List<dynamic> res = [];

      if (!selected) {
        final resp = await OdooSessionManager.callKwWithCompany({
          'model': 'hr.employee',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['user_id', '=', userId],
              [
                'company_id',
                'in',
                [companyId, false],
              ],
            ],
            'fields': ['name', 'id', 'company_id', 'work_phone', 'image_1920'],
          },
        });
        res = resp;
      } else {
        final resp = await OdooSessionManager.callKwWithCompany({
          'model': 'hr.employee',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', id],
              [
                'company_id',
                'in',
                [companyId, false],
              ],
            ],
            'fields': ['name', 'id', 'company_id', 'work_phone', 'image_1920'],
          },
        });

        res = resp;
      }

      final Map<String, dynamic> emp = res[0];

      final employee = Employee.fromJson(emp);

      return employee;
    } catch (e) {
      rethrow;
    }
  }

  ///checking
  checkExpenseAccess() async {
    final client = await OdooSessionManager.getClient();

    final userId = client!.sessionId?.userId;

    if (userId == null) {
      return;
    }

    final bool hasExpenseUser = await client.callKw({
      'model': 'res.users',
      'method': 'has_group',
      'args': [
        [userId],
        'hr_expense.group_hr_expense_user',
      ],
      'kwargs': {},
    });

    final bool hasExpenseManager = await client.callKw({
      'model': 'res.users',
      'method': 'has_group',
      'args': [
        [userId],
        'hr_expense.group_hr_expense_manager',
      ],
      'kwargs': {},
    });

    final bool canAccessExpense = hasExpenseUser || hasExpenseManager;
  }
}
