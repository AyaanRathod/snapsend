import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';
import '../../../viewmodels/category_viewmodel.dart';

/// Modern, clean donut chart with a central total display.
class CategoryDonutChart extends StatefulWidget {
  final Map<String, double> spendingByCategory;
  final CategoryViewModel categoryVm;
  final String currencySymbol;

  const CategoryDonutChart({
    super.key,
    required this.spendingByCategory,
    required this.categoryVm,
    required this.currencySymbol,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.spendingByCategory.isEmpty) {
      return Center(
          child: Text('No spending this month',
              style: TextStyle(color: cs.onSurfaceVariant)));
    }

    final total = widget.spendingByCategory.values.fold(0.0, (a, b) => a + b);
    final sorted = widget.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final iconString = widget.categoryVm.getIconStringForCategory(e.key);
      final color = CategoryIcons.colorForKey(iconString);
      final isTouched = _touchedIndex == i;

      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '', // Titles hidden for a cleaner look, info in legend/center
        radius: isTouched ? 22 : 18,
        showTitle: false,
        badgeWidget: isTouched ? _Badge(color) : null,
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (evt, res) {
                      setState(() {
                        _touchedIndex = res?.touchedSection?.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: sections,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL',
                    style: AppTextStyles.labelSmall.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1),
                  ),
                  Text(
                    '${widget.currencySymbol}${total.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineMedium.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sorted.length.clamp(0, 5), (i) {
              final e = sorted[i];
              final iconString = widget.categoryVm.getIconStringForCategory(e.key);
              final name = widget.categoryVm.getNameForCategory(e.key);
              final color = CategoryIcons.colorForKey(iconString);
              final pct = ((e.value / total) * 100).toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  const _Badge(this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }
}
