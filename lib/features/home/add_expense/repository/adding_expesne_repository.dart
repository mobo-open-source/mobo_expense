import 'package:intl/intl.dart';
import '../../../../core/services/odoo_session_manager.dart';
import '../../../../model/expense_attachment_model.dart';
import 'expense_repository.dart';

class AddExpenseRepository implements ExpenseRepository {
  @override
  Future<bool> addExpense({
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
    try {
      final formated = DateFormat("dd-MM-yyyy").parse(date);
      final formattedDate =
          '${formated.year}-${formated.month}-${formated.day}';
      final taxIdDomain = taxId.map((id) => [4, id]).toList();
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
              'tax_ids': taxIdDomain,
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
}
