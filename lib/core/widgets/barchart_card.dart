import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/department_expense.dart';
import '../constants/constants.dart';

Widget barChartCard(List<DepartmentExpens> data, BuildContext context) {
  final maxExpense = data
      .map((d) => d.expense)
      .fold<double>(0, (prev, e) => e > prev ? e : prev);

  final maxY = (maxExpense == 0) ? 1000.0 : (maxExpense * 1.2);

  double yInterval = maxY / 4;
  if (yInterval <= 0) yInterval = 1;

  String shortLabel(String name) {
    if (name.length <= 4) return name;
    return '${name.substring(0, 4)}..';
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    width: double.infinity,
    height: 300,
    padding: EdgeInsets.only(left: 10, top: 10),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      borderRadius: BorderRadius.circular(MoboRadius.card),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.grey.shade200,
          blurRadius: 3,
          spreadRadius: 3,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Department Expense", style: TextStyle(fontSize: 14)),

          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                groupsSpace: 18,

                titlesData: FlTitlesData(
                  show: true,

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final dep = shortLabel(data[index].name);
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            dep,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 8),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        if (value < 0) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 8),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                ),

                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    top: BorderSide.none,
                    right: BorderSide.none,
                    left: BorderSide(width: 0.5, color: Colors.grey),
                    bottom: BorderSide(width: 0.5, color: Colors.grey),
                  ),
                ),

                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dep = data[group.x.toInt()].name;
                      return BarTooltipItem(
                        "$dep\n${rod.toY.toStringAsFixed(2)}",
                        GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),

                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final d = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: d.expense,
                        width: 25,
                        color: MoboColor.redColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
