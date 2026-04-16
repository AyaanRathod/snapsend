import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';
import '../../../data/models/chart_data.dart';

/// Spider/radar chart where each spoke is a category with a budget set.
/// The filled area represents spending as a % of the budget limit.
/// Requires at least 3 categories to render meaningfully.
class CategoryRadarChart extends StatelessWidget {
  final List<CategoryBudgetSummary> summaries;
  final String currencySymbol;

  const CategoryRadarChart({
    super.key,
    required this.summaries,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = summaries.take(8).toList();

    final radarEntries = data
        .map((s) => RadarEntry(value: s.progress.clamp(0.0, 1.2)))
        .toList();

    return Column(
      children: [
        Expanded(
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  dataEntries: radarEntries,
                  fillColor: AppColors.primary.withValues(alpha: 0.2),
                  borderColor: AppColors.primary,
                  borderWidth: 2,
                  entryRadius: 4,
                ),
              ],
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: const TextStyle(
                  fontSize: 0, color: Colors.transparent),
              tickBorderData: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  width: 1),
              gridBorderData: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                  width: 1),
              radarBorderData: BorderSide(color: cs.outline, width: 1.5),
              getTitle: (index, angle) {
                if (index < 0 || index >= data.length) {
                  return RadarChartTitle(text: '');
                }
                final s = data[index];
                final name = s.categoryName.length > 8
                    ? '${s.categoryName.substring(0, 7)}..'
                    : s.categoryName;
                return RadarChartTitle(
                  text: name,
                  angle: 0,
                  positionPercentageOffset: s.isOverBudget ? 0.08 : 0.1,
                );
              },
              titleTextStyle: TextStyle(
                  color: cs.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
              titlePositionPercentageOffset: 0.15,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: data.map((s) {
            final color =
                s.isOverBudget ? AppColors.error : AppColors.primary;
            final pct = (s.progress * 100).toStringAsFixed(0);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CategoryIcons.forKey(s.iconString),
                    color: color, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${s.categoryName} $pct%',
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: s.isOverBudget
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
