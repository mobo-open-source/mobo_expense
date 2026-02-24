import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/provider/common_provider.dart';
import 'package:provider/provider.dart';

import '../../../../model/montly_expense_model.dart';

class PivotWidget extends StatelessWidget {
  final List<MonthlyAmountModel> data;

  const PivotWidget({super.key, required this.data});

  static const double leftWidth = 150;
  static const double colWidth = 150;
  static const double rowHeight = 60;

  List<String> get months => data.map((e) => e.month).toList();

  double get grandTotal => data.fold(0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Consumer<CommonProvider>(
        builder: (context, commonProvider, child) {
          /// ---------------- LOADING ----------------
          if (commonProvider.isLoading) {
            return ListView(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CardLoading(
                    height: 100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            );
          }

          /// ---------------- EMPTY ----------------
          if (data.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                HugeIcon(icon: HugeIcons.strokeRoundedFileRemove, size: 60),
                SizedBox(height: 8),
                Text("No data found"),
              ],
            );
          }

          /// ---------------- TABLE ----------------
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(colWidth),
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  _buildHeaderRow(isDark),
                  _buildTotalRow(isDark),
                  ..._buildMonthRows(isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------- HEADER ROW ----------------

  TableRow _buildHeaderRow(bool isDark) {
    return TableRow(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey.shade400,
      ),
      children: [
        _headerCell("Total", leftWidth),
        ...months.map((m) => _headerCell(m, colWidth)),
        _headerCell("Total In Currency", colWidth),
      ],
    );
  }

  /// ---------------- TOTAL ROW ----------------

  TableRow _buildTotalRow(bool isDark) {
    return TableRow(
      children: [
        _cell(isDark, "Total", leftWidth, isBold: true),
        ...data.map(
          (e) => _cell(isDark, "₹ ${e.amount.toStringAsFixed(2)}", colWidth),
        ),
        _cell(
          isDark,
          "₹ ${grandTotal.toStringAsFixed(2)}",
          colWidth,
          isBold: true,
        ),
      ],
    );
  }

  /// ---------------- MONTH ROWS ----------------

  List<TableRow> _buildMonthRows(bool isDark) {
    return months.map((currentMonth) {
      final amount = data.firstWhere((e) => e.month == currentMonth).amount;

      return TableRow(
        children: [
          _cell(isDark, currentMonth, leftWidth),
          ...months.map(
            (m) => m == currentMonth
                ? _cell(isDark, "₹ ${amount.toStringAsFixed(2)}", colWidth)
                : _cell(isDark, "", colWidth),
          ),
          _cell(
            isDark,

            "₹ ${amount.toStringAsFixed(2)}",
            colWidth,
            isBold: true,
          ),
        ],
      );
    }).toList();
  }

  /// ---------------- CELL WIDGETS ----------------

  Widget _cell(bool isDark, String text, double width, {bool isBold = false}) {
    return SizedBox(
      width: width,
      height: rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      height: rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
