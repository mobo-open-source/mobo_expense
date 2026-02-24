import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../features/home/add_expense/add_expenses_screen.dart';
import '../constants/constants.dart';

Widget floatingActionButtonAddingExpense(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpensesScreen()),
    ),
    child: Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : MoboColor.redColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [MoboShadows.medium, MoboShadows.medium],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedFileAdd,
          color: isDark ? Colors.black : Colors.white,
          strokeWidth: 1,
        ),
      ),
    ),
  );
}
