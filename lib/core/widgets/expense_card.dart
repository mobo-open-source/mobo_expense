import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/home/expense/expense_details_screen.dart';
import '../../model/expense_model.dart';
import '../constants/constants.dart';

Widget expenseCardWidget(
  BuildContext context, {

  required String name,
  required String description,
  required String date,
  required String paidBy,
  required String status,
  required String amount,
  required Expense expense,
}) {
  Color bgColor;
  Color textColor;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  switch (status) {
    case 'approved':
      bgColor = isDark ? Colors.green : Colors.green.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.green.shade800;
      break;

    case 'draft':
      bgColor = isDark ? Colors.blue : Colors.blue.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.blue.shade800;
      break;
    case 'submitted':
      bgColor = isDark ? Colors.orange : Colors.orange.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.orange.shade800;
      break;
    case 'refused':
      bgColor = isDark ? Colors.red : Colors.red.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.red.shade800;
      break;
    case 'posted':
      bgColor = isDark ? Colors.green : Colors.green.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.green.shade800;
      break;
    case 'paid':
      bgColor = isDark ? Colors.green : Colors.green.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.green.shade800;
      break;
    case 'done':
      bgColor = isDark ? Colors.green : Colors.green.withAlpha(30);
      textColor = isDark ? Colors.white : Colors.green.shade800;
      break;
    default:
      bgColor = Colors.black26;
      textColor = Colors.black;
  }

  return GestureDetector(
    key: const Key('details_button'),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExpenseDetailsScreen(
            key: Key('ExpenseDetails screens'),
            expense: expense,
            bgColor: bgColor,
            statusColor: textColor,
          ),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.11) : Colors.white,
        borderRadius: BorderRadius.circular(MoboRadius.card),
        boxShadow: [MoboShadows.soft],
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : MoboColor.redColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(
                              MoboRadius.button,
                            ),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    paidBy == "own_account"
                        ? "Paid By Self"
                        : "Paid By company",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Text(
                "\$ $amount",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
