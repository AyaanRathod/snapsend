import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/chart_data.dart';

/// Line chart showing daily spending for the current ISO week (Mon–Sun).
class WeekLineChart extends StatelessWidget {
  final List<DailyTotal> weekData;
  final String currencySymbol;

  const WeekLineChart({
    super.key,
    required this.weekData,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labelColor = cs.onSurfaceVariant;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (weekData.isEmpty) {
      return Center(
          child: Text('No data this week',
              style: TextStyle(color: labelColor)));
    }

    double maxY = 0;
    for (final d in weekData) {
      if (d.total > maxY) maxY = d.total;
    }
    maxY = maxY == 0 ? 50 : maxY * 1.35;

    final spots = weekData.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.total))
        .toList();

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => cs.inverseSurface,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '$currencySymbol${s.y.toStringAsFixed(2)}',
                      TextStyle(
                          color: cs.onInverseSurface,
                          fontWeight: FontWeight.bold),
                    ))
                .toList(),
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
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= weekData.length) return const SizedBox();
                final dayIdx = weekData[i].date.weekday - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    days[dayIdx.clamp(0, 6)],
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, barData, idx) => FlDotCirclePainter(
                radius: spot.y > 0 ? 5 : 3,
                color: spot.y > 0
                    ? AppColors.primary
                    : cs.surfaceContainerHighest,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
