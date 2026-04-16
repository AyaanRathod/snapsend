import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_icons.dart';
import '../../../data/models/chart_data.dart';

/// Horizontal progress bars comparing actual spending vs budget limit
/// per category. Over-budget entries render in red.
class BudgetBarsChart extends StatelessWidget {
  final List<CategoryBudgetSummary> summaries;
  final String currencySymbol;

  const BudgetBarsChart({
    super.key,
    required this.summaries,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: summaries.map((s) {
        final color = CategoryIcons.colorForKey(s.iconString);
        final progress = s.progress.clamp(0.0, 1.0);
        final isOver = s.isOverBudget;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CategoryIcons.forKey(s.iconString),
                      color: isOver ? AppColors.error : color, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(s.categoryName,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface)),
                  ),
                  Text(
                    '$currencySymbol${s.spent.toStringAsFixed(0)} / $currencySymbol${s.limit.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: isOver ? AppColors.error : cs.onSurfaceVariant,
                        fontWeight:
                            isOver ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOver ? AppColors.error : color,
                  ),
                ),
              ),
              if (isOver)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Over by $currencySymbol${(-s.remaining).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
