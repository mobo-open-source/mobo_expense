import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_expenses/model/montly_expense_model.dart';

import '../../../../core/constants/constants.dart';

Widget barChartExpense(
  List<MonthlyAmountModel> data,
  String title,
  bool isDark,
) {
  final maxExpense = data
      .map((d) => d.amount)
      .fold<double>(0, (prev, e) => e > prev ? e : prev);

  final maxY = (maxExpense == 0) ? 1000.0 : (maxExpense * 1.2);

  double yInterval = maxY / 4;
  if (yInterval <= 0) yInterval = 1;

  String shortLabel(String name) {
    if (name.split(' ').first.length <= 8) return name.split(' ').first;
    return '${name.split(' ').first.substring(0, 8)}..';
  }

  return Container(
    width: double.infinity,
    height: 300,
    padding: EdgeInsets.only(left: 10, top: 10),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[800] : Colors.white,
      borderRadius: BorderRadius.circular(MoboRadius.card),
      boxShadow: [MoboShadows.soft],
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 20),
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
                        final dep = shortLabel(
                          data[index].month.replaceAll("2026", "").trim(),
                        );
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            dep,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 8,
                              color: isDark ? Colors.white : Colors.black,
                            ),
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
                            style: GoogleFonts.manrope(
                              fontSize: 8,
                              color: isDark ? Colors.white : Colors.black,
                            ),
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
                      final dep = data[group.x.toInt()].month;
                      return BarTooltipItem(
                        "$dep\n${rod.toY.toStringAsFixed(2)}",
                        GoogleFonts.manrope(
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
                        toY: d.amount,
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
