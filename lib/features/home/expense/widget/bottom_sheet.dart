import 'package:flutter/material.dart';
import '../../../../model/expense_model.dart';

///expense bottom sheet
class ExpenseBottomSheet extends StatelessWidget {
  final Expense expense;

  const ExpenseBottomSheet({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,

      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _row("Untaxed Amount", expense.untaxAmount, context),
          _row("Tax Amount", expense.taxAmount, context),
          SizedBox(height: 10),

          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primary,

              child: _row(
                "Total Amount",
                expense.totalAmount,
                context,
                isWhite: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    dynamic value,
    BuildContext context, {
    bool isWhite = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isWhite
                  ? Colors.white
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isWhite
                  ? Colors.white
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
