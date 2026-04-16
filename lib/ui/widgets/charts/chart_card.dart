import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Reusable chart card container with theme-aware background and border.
class ChartCard extends StatelessWidget {
  final double height;
  final Widget child;

  const ChartCard({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: child,
      ),
    );
  }
}

/// Three summary chips (This Month / All Time / Entries) shown at the
/// top of the Insights screen.
class InsightsSummaryRow extends StatelessWidget {
  final double totalThisMonth;
  final double totalAllTime;
  final String currencySymbol;
  final int expenseCount;

  const InsightsSummaryRow({
    super.key,
    required this.totalThisMonth,
    required this.totalAllTime,
    required this.currencySymbol,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _chip(cs, 'This Month',
              '$currencySymbol${totalThisMonth.toStringAsFixed(2)}',
              AppColors.primary),
          const SizedBox(width: 8),
          _chip(cs, 'All Time',
              '$currencySymbol${totalAllTime.toStringAsFixed(2)}',
              AppColors.primaryDark),
          const SizedBox(width: 8),
          _chip(cs, 'Entries', '$expenseCount',
              const Color(0xFF43A047)),
        ],
      ),
    );
  }

  Widget _chip(ColorScheme cs, String label, String value, Color accent) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      color: accent,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}
