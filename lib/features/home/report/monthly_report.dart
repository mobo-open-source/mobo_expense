import 'package:card_loading/card_loading.dart' show CardLoading;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/simple_card.dart';
import '../../../provider/common_provider.dart';
import 'widget/barchart_expense.dart';
import 'widget/create_exel.dart';
import 'widget/pei_chart.dart';
import 'widget/pivot_widget.dart';

///  Dropdown Actions
enum ReportAction { graph, pivot, download }

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({super.key});

  @override
  State<MonthlyReport> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  ReportAction _selectedAction = ReportAction.graph;

  bool get isGraph => _selectedAction == ReportAction.graph;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final commonProvider = context.watch<CommonProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await commonProvider.getMonthlyBasisReport();
      },
      child: ListView(
        padding: const EdgeInsets.only(right: 10),
        physics: isGraph
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          /// HEADER
          if (commonProvider.isLoading)
            CardLoading(height: 44, borderRadius: BorderRadius.circular(14))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _actionDropdown(isDark: isDark, commonProvider: commonProvider),
              ],
            ),

          const SizedBox(height: 16),

          ///  CONTENT
          if (isGraph)
            ..._buildGraph(commonProvider, isDark)
          else
            PivotWidget(data: commonProvider.monthlyExpenseList),
        ],
      ),
    );
  }

  ///  GRAPH SECTION
  List<Widget> _buildGraph(CommonProvider provider, bool isDark) {
    if (provider.isLoading) {
      return [
        CardLoading(height: 300, borderRadius: BorderRadius.circular(12)),
        const SizedBox(height: 20),
        CardLoading(height: 300, borderRadius: BorderRadius.circular(12)),
      ];
    }

    return [
      SizedBox(
        height: 300,
        child: barChartExpense(
          provider.monthlyExpenseList,
          "Monthly Expense",
          isDark,
        ),
      ),
      const SizedBox(height: 20),
      simpleCardWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Expense",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            PieChartWidget(data: provider.monthlyExpenseList),
          ],
        ),
      ),
    ];
  }

  ///  DROPDOWN
  Widget _actionDropdown({
    required bool isDark,
    required CommonProvider commonProvider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        key: Key("dropdown ME"),
        child: DropdownButton<ReportAction>(
          value: _selectedAction,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          items: [
            _menuItem(ReportAction.graph, Icons.bar_chart_rounded, "Graph"),
            _menuItem(ReportAction.pivot, Icons.table_chart_rounded, "Pivot"),
            if (commonProvider.monthlyExpenseList.isNotEmpty)
              _menuItem(
                ReportAction.download,
                Icons.download_rounded,
                "Download",
              ),
          ],
          onChanged: commonProvider.isLoading
              ? null
              : (value) async {
                  if (value == null) return;

                  if (value == ReportAction.download) {
                    await createExcel(commonProvider.monthlyExpenseList);
                    return;
                  }

                  setState(() => _selectedAction = value);
                },
        ),
      ),
    );
  }

  DropdownMenuItem<ReportAction> _menuItem(
    ReportAction value,
    IconData icon,
    String label,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}
