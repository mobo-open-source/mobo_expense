import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/constants.dart';
import '../../../../model/montly_expense_model.dart';

class PieChartWidget extends StatefulWidget {
  final List<MonthlyAmountModel> data;
  const PieChartWidget({super.key, required this.data});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  List<Color> colorsList = [
    MoboColor.redColor,
    Colors.grey,
    Colors.green,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.cyan,
    Colors.yellow,
    Colors.blueGrey,
    Colors.brown,
    Colors.red,
    Colors.cyanAccent,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedFileRemove),
              Text("No data found", style: MoboText.h4),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    touchedIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: _buildSections(),
            ),
          ),
        ),
        _buildLegend(isDark),
      ],
    );
  }

  /// ---------------- PIE SECTIONS ----------------
  List<PieChartSectionData> _buildSections() {
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.amount);

    return List.generate(widget.data.length, (i) {
      final item = widget.data[i];
      final isTouched = i == touchedIndex;

      final percentage = total == 0 ? 0 : (item.amount / total) * 100;

      return PieChartSectionData(
        color: colorsList[i],
        value: item.amount,
        title: '',
        radius: isTouched ? 125 : 115,
        badgeWidget: isTouched
            ? _Tooltip(
                title: item.month,
                value: item.amount,
                percent: percentage.toDouble(),
              )
            : null,
        badgePositionPercentageOffset: .98,
      );
    });
  }

  /// ---------------- LEGEND ----------------
  Widget _buildLegend(bool isDark) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(widget.data.length, (i) {
        final item = widget.data[i];

        return Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colorsList[i],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              item.month.split(' ').first,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// ---------------- TOOLTIP WIDGET ----------------
class _Tooltip extends StatelessWidget {
  final String title;
  final double value;
  final double percent;

  const _Tooltip({
    required this.title,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            Text(
              '₹ ${value.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
