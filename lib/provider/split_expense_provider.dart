import 'package:flutter/material.dart';
import 'package:mobo_expenses/model/expense_model.dart';
import 'package:mobo_expenses/services/expense_services.dart';

import '../core/utils/snackbar.dart';

class SplitExpenseProvider extends ChangeNotifier {
  bool isLoading = false;
  List<int> idList = [];
  final expenseServices = ExpenseServices();

  List<Expense> expenseList = [];

  ///initial loading
  initialLoading(BuildContext context, int id) async {
    try {
      isLoading = true;

      idList = [];

      idList = await expenseServices.gettingSplitExpense(id);

      notifyListeners();

      expenseList = [];

      if (idList.isNotEmpty) {
        for (int id in idList) {
          final result = await expenseServices.gettingSingleExpense(id);
          expenseList.add(result);
        }
      }
    } catch (e) {
      showSnackBar(
        context,
        'error,fetching single expense error',
        backgroundColor: Colors.red,
      );

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
