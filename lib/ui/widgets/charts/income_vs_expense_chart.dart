import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class IncomeVsExpenseChart extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final String currencySymbol;

  const IncomeVsExpenseChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0.0;
    
    final maxValue = (totalIncome > totalExpense ? totalIncome : totalExpense);
    // Standard headroom since we removed top labels
    final maxY = maxValue == 0 ? 100.0 : maxValue * 1.1;

    return Column(
      children: [
        // 1. Value Summary Header
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('INCOME', '$currencySymbol${totalIncome.toStringAsFixed(0)}', AppColors.primary),
              _buildStat('EXPENSES', '$currencySymbol${totalExpense.toStringAsFixed(0)}', AppColors.error),
              _buildStat(
                'SAVINGS', 
                '$currencySymbol${savings.toStringAsFixed(0)}', 
                savings >= 0 ? Colors.blue : AppColors.error
              ),
            ],
          ),
        ),

        // 2. The Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        );
                        if (value == 0) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Earned', style: style));
                        if (value == 1) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Spent', style: style));
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, totalIncome, AppColors.primary),
                  _buildBarGroup(1, totalExpense, AppColors.error.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
        ),

        // 3. Savings Rate Footer
        if (totalIncome > 0 || totalExpense > 0)
          Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (savings >= 0 ? AppColors.primary : AppColors.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              savings >= 0 
                ? 'You kept ${savingsRate.toStringAsFixed(1)}% of your income! 👏'
                : 'You are spending ${savingsRate.abs().toStringAsFixed(1)}% over your income! ⚠️',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: savings >= 0 ? AppColors.primaryDark : AppColors.error,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 50, // Slightly wider for impact
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1, color: AppColors.textSecondary, fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    );
  }
}
