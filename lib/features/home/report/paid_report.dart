import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:mobo_expenses/features/home/report/widget/barchart_expense.dart';
import 'package:mobo_expenses/features/home/report/widget/create_exel.dart';
import 'package:mobo_expenses/features/home/report/widget/pei_chart.dart';
import 'package:mobo_expenses/features/home/report/widget/pivot_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../provider/common_provider.dart';

///  Dropdown actions
enum ReportAction { graph, pivot, download }

class PaidReport extends StatefulWidget {
  const PaidReport({super.key});

  @override
  State<PaidReport> createState() => _PaidReportState();
}

class _PaidReportState extends State<PaidReport> {
  int screen = 0;
  ReportAction _selectedAction = ReportAction.graph;

  @override
  Widget build(BuildContext context) {
    final commonProvider = context.watch<CommonProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await commonProvider.getPaidExpenseReport();
      },
      child: ListView(
        shrinkWrap: true,
        physics: screen == 0
            ? const ScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          ///  Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///  DROPDOWN (Graph / Pivot / Download)
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<ReportAction>(
                    value: _selectedAction,
                    dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ReportAction.graph,
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart, size: 18),
                            SizedBox(width: 8),
                            Text("Graph"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: ReportAction.pivot,
                        child: Row(
                          children: [
                            Icon(Icons.table_chart, size: 18),
                            SizedBox(width: 8),
                            Text("Pivot"),
                          ],
                        ),
                      ),
                      ...commonProvider.paidExpenseList.isNotEmpty
                          ? [
                              DropdownMenuItem(
                                value: ReportAction.download,
                                child: Row(
                                  children: const [
                                    Icon(Icons.download, size: 18),
                                    SizedBox(width: 8),
                                    Text("Download"),
                                  ],
                                ),
                              ),
                            ]
                          : [],
                    ],
                    onChanged: (value) async {
                      if (value == null) return;

                      ///  Download Excel
                      if (value == ReportAction.download) {
                        if (commonProvider.paidExpenseList.isNotEmpty) {
                          await createExcel(commonProvider.paidExpenseList);
                        }
                        return;

                        /// screen change
                      }

                      setState(() {
                        _selectedAction = value;
                        screen = value == ReportAction.graph ? 0 : 1;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ///  GRAPH VIEW
          if (screen == 0) ...[
            commonProvider.isLoading
                ? CardLoading(
                    height: 300,
                    borderRadius: BorderRadius.circular(10),
                  )
                : barChartExpense(
                    commonProvider.paidExpenseList,
                    "Reimbursement Expense",
                    isDark,
                  ),

            const SizedBox(height: 20),

            commonProvider.isLoading
                ? CardLoading(
                    height: 300,
                    borderRadius: BorderRadius.circular(10),
                  )
                : simpleCardWidget(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reimbursement Expense",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PieChartWidget(data: commonProvider.paidExpenseList),
                      ],
                    ),
                  ),
          ]
          ///  PIVOT VIEW
          else
            PivotWidget(data: commonProvider.paidExpenseList),
        ],
      ),
    );
  }
}
