import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';
import '../../../data/models/chart_data.dart';

/// Spider/radar chart comparing spending per category against budget limits.
/// Also shows an "Income Boundary" to visualize how much of your total 
/// earnings these budgets represent.
class CategoryRadarChart extends StatelessWidget {
  final List<CategoryBudgetSummary> summaries;
  final double totalIncome;
  final String currencySymbol;

  const CategoryRadarChart({
    super.key,
    required this.summaries,
    required this.totalIncome,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = summaries.take(8).toList();

    // Spending as % of Budget (0.0 to 1.0+)
    final spendingEntries = data
        .map((s) => RadarEntry(value: s.progress.clamp(0.0, 1.2)))
        .toList();

    // Budget Limit as % of Income (visual reference)
    final incomeRefEntries = data.map((s) {
      if (totalIncome <= 0) return const RadarEntry(value: 1.0);
      final budgetVsIncome = s.limit / totalIncome;
      return RadarEntry(value: budgetVsIncome.clamp(0.1, 1.0));
    }).toList();

    return Column(
      children: [
        Expanded(
          child: RadarChart(
            RadarChartData(
              dataSets: [
                // Layer 1: Income/Safety Boundary (Static reference) - Darker Blue
                RadarDataSet(
                  dataEntries: incomeRefEntries,
                  fillColor: const Color(0xFF1976D2).withValues(alpha: 0.15),
                  borderColor: const Color(0xFF0D47A1),
                  borderWidth: 2,
                  entryRadius: 0,
                ),
                // Layer 2: Actual Spending (The "Web") - Bolder Primary
                RadarDataSet(
                  dataEntries: spendingEntries,
                  fillColor: AppColors.primary.withValues(alpha: 0.35),
                  borderColor: AppColors.primaryDark,
                  borderWidth: 3,
                  entryRadius: 5,
                ),
              ],
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
              tickBorderData: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
              gridBorderData: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3), width: 1),
              radarBorderData: BorderSide(color: cs.outline, width: 1.5),
              getTitle: (index, angle) {
                if (index < 0 || index >= data.length) return RadarChartTitle(text: '');
                return RadarChartTitle(
                  text: data[index].categoryName,
                  angle: 0,
                );
              },
              titleTextStyle: TextStyle(
                color: cs.onSurface, 
                fontSize: 10, 
                fontWeight: FontWeight.w800 // Bold type
              ),
              titlePositionPercentageOffset: 0.15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(AppColors.primaryDark, 'Spending', isWeb: true),
            const SizedBox(width: 20),
            _legendItem(const Color(0xFF0D47A1), 'Budget vs Income', isWeb: false),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, {required bool isWeb}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label, 
          style: const TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.bold // Bold type
          )
        ),
      ],
    );
  }
}
