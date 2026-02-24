import '../../../../model/expense_attachment_model.dart';

abstract class ExpenseRepository {
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
  });
}
