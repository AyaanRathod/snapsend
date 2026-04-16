import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/chart_data.dart';

/// 6-month bar chart for the Insights screen.
class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyTotal> monthlyData;
  final String currencySymbol;

  const MonthlyBarChart({
    super.key,
    required this.monthlyData,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labelColor = cs.onSurfaceVariant;

    if (monthlyData.isEmpty) {
      return Center(
          child:
              Text('No data yet', style: TextStyle(color: labelColor)));
    }

    double maxY = 0;
    for (final d in monthlyData) {
      if (d.total > maxY) maxY = d.total;
    }
    maxY = maxY == 0 ? 100 : maxY * 1.4;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => cs.inverseSurface,
            getTooltipItem: (grp, grpIdx, rod, rodIdx) => BarTooltipItem(
              '$currencySymbol${rod.toY.toStringAsFixed(2)}',
              TextStyle(
                  color: cs.onInverseSurface, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= monthlyData.length) return const SizedBox();
                final d = monthlyData[i];
                if (d.total == 0) return const SizedBox();
                return Text(
                  '$currencySymbol${d.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= monthlyData.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    months[monthlyData[i].month.month - 1],
                    style: TextStyle(
                        color: labelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(monthlyData.length, (i) {
          final d = monthlyData[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: d.total,
                width: 24,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.7),
                    AppColors.primary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: cs.surfaceContainerHighest,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
