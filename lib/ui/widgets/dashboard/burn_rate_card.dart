import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/budget_viewmodel.dart';
import '../../../viewmodels/expense_viewmodel.dart';
import '../../../viewmodels/settings_viewmodel.dart';

/// Displays a line chart projecting cumulative spending vs.
/// the monthly budget limit. Only renders when a budget limit is set.
class BurnRateCard extends StatelessWidget {
  const BurnRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer3<ExpenseViewModel, BudgetViewModel, SettingsViewModel>(
      builder: (context, expenses, budget, settings, _) {
        if (!budget.hasTotalBudget || budget.totalBudgetLimit <= 0) {
          return const SizedBox.shrink();
        }

        final sym = settings.currencySymbol;
        final limit = budget.totalBudgetLimit;
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final dayOfMonth = now.day;

        // Build cumulative spending per day
        final dailyMap = <int, double>{};
        for (final e in expenses.currentMonthExpenses) {
          final day = e.date.toLocal().day;
          dailyMap[day] = (dailyMap[day] ?? 0) + e.amount;
        }

        final actualSpots = <FlSpot>[];
        double cumulative = 0;
        for (int d = 1; d <= dayOfMonth; d++) {
          cumulative += dailyMap[d] ?? 0;
          actualSpots.add(FlSpot(d.toDouble(), cumulative));
        }

        final avgDaily = dayOfMonth > 0 ? cumulative / dayOfMonth : 0.0;
        final projectedTotal =
            cumulative + avgDaily * (daysInMonth - dayOfMonth);

        final projectedSpots = <FlSpot>[
          FlSpot(dayOfMonth.toDouble(), cumulative),
          FlSpot(daysInMonth.toDouble(), projectedTotal),
        ];

        // Forecast label logic
        final String forecastLabel;
        final Color forecastColor;
        if (cumulative >= limit) {
          forecastLabel = 'Budget already exceeded!';
          forecastColor = AppColors.error;
        } else if (projectedTotal >= limit && avgDaily > 0) {
          final daysUntilHit = ((limit - cumulative) / avgDaily).ceil();
          final hitDate = now.add(Duration(days: daysUntilHit));
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          forecastLabel =
              "At this rate you'll hit $sym${limit.toStringAsFixed(0)} around ${months[hitDate.month - 1]} ${hitDate.day}";
          forecastColor = AppColors.warning;
        } else {
          final remaining = limit - projectedTotal;
          forecastLabel =
              'On track! Projected $sym${projectedTotal.toStringAsFixed(0)} — $sym${remaining.toStringAsFixed(0)} under budget';
          forecastColor = const Color(0xFF43A047);
        }

        final maxY = (limit * 1.2).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('Burn Rate Forecast',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: cs.onSurface)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: forecastColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    forecastLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: forecastColor),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: daysInMonth.toDouble(),
                      minY: 0,
                      maxY: maxY,
                      clipData: const FlClipData.all(),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => cs.inverseSurface,
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    'Day ${s.x.toInt()}\n$sym${s.y.toStringAsFixed(2)}',
                                    TextStyle(
                                        color: cs.onInverseSurface,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ))
                              .toList(),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: cs.outlineVariant.withValues(alpha: 0.35),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (daysInMonth / 4).roundToDouble(),
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}',
                              style: TextStyle(
                                  fontSize: 10, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: limit,
                            color: AppColors.error.withValues(alpha: 0.7),
                            strokeWidth: 1.5,
                            dashArray: [6, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              labelResolver: (_) =>
                                  'Budget $sym${limit.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: actualSpots,
                          isCurved: true,
                          curveSmoothness: 0.2,
                          color: AppColors.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.22),
                                AppColors.primary.withValues(alpha: 0.02),
                              ],
                            ),
                          ),
                        ),
                        LineChartBarData(
                          spots: projectedSpots,
                          isCurved: false,
                          color: forecastColor.withValues(alpha: 0.8),
                          barWidth: 2,
                          dashArray: [5, 4],
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, pct, bar, idx) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: forecastColor,
                              strokeWidth: 0,
                              strokeColor: Colors.transparent,
                            ),
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _dot(AppColors.primary, 'Actual'),
                    const SizedBox(width: 16),
                    _dot(forecastColor, 'Projected'),
                    const SizedBox(width: 16),
                    _dash(AppColors.error, 'Budget limit'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      );

  Widget _dash(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 2, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      );
}
