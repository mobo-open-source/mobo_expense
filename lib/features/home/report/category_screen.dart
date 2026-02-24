import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:mobo_expenses/features/home/report/widget/barchart_expense.dart';
import 'package:mobo_expenses/features/home/report/widget/create_exel.dart';
import 'package:mobo_expenses/features/home/report/widget/pei_chart.dart';
import 'package:mobo_expenses/features/home/report/widget/pivot_widget.dart';
import 'package:mobo_expenses/model/montly_expense_model.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../provider/common_provider.dart';

///  Dropdown actions
enum ReportAction { graph, pivot, download }

class CategoryScreen extends StatefulWidget {
  final List<dynamic> categoryReport;

  const CategoryScreen({super.key, required this.categoryReport});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int screen = 0;
  ReportAction _selectedAction = ReportAction.graph;

  @override
  Widget build(BuildContext context) {
    final commonProvider = context.watch<CommonProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ///  Convert category data once
    final categoryData = widget.categoryReport
        .map(
          (item) => MonthlyAmountModel(
            month: item['product_id'][1]
                .toString()
                .replaceAll(RegExp(r'\[[^\]]*\]'), '')
                .trim(),
            amount: item['total_amount'],
          ),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await commonProvider.getCategoryReport();
      },
      child: ListView(
        shrinkWrap: true,
        physics: screen == 0
            ? const ScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          ///  Header Row
          Row(
            children: [
              ///  DROPDOWN (Graph / Pivot / Download)
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<ReportAction>(
                    value: _selectedAction,
                    dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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

                      ...(categoryData.isNotEmpty
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
                          : []),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;

                      if (value == ReportAction.download) {
                        if (categoryData.isNotEmpty) {
                          await createExcel(categoryData);
                        }
                        return;
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
                : Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: barChartExpense(
                      categoryData,
                      "Category-wise Expense",
                      isDark,
                    ),
                  ),

            const SizedBox(height: 20),

            commonProvider.isLoading
                ? CardLoading(
                    height: 300,
                    borderRadius: BorderRadius.circular(10),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: simpleCardWidget(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Category-wise Expense",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          PieChartWidget(data: categoryData),
                        ],
                      ),
                    ),
                  ),
          ]
          ///  PIVOT VIEW
          else
            PivotWidget(data: categoryData),
        ],
      ),
    );
  }
}
