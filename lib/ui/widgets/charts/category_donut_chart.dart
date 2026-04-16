import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/category_icons.dart';
import '../../../viewmodels/category_viewmodel.dart';

/// Interactive donut chart showing spending proportions per category
/// for the current month. Tap a slice to see the dollar amount.
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

    final total =
        widget.spendingByCategory.values.fold(0.0, (a, b) => a + b);
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
        title: isTouched
            ? '${widget.currencySymbol}${e.value.toStringAsFixed(0)}'
            : '${((e.value / total) * 100).toStringAsFixed(0)}%',
        radius: isTouched ? 70 : 58,
        titleStyle: TextStyle(
          fontSize: isTouched ? 13 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black38)],
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (evt, res) => setState(() {
                  _touchedIndex =
                      res?.touchedSection?.touchedSectionIndex;
                }),
              ),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: ListView.builder(
            itemCount: sorted.length,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, i) {
              final e = sorted[i];
              final iconString =
                  widget.categoryVm.getIconStringForCategory(e.key);
              final name = widget.categoryVm.getNameForCategory(e.key);
              final color = CategoryIcons.colorForKey(iconString);
              final pct = ((e.value / total) * 100).toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                              '${widget.currencySymbol}${e.value.toStringAsFixed(2)} · $pct%',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
