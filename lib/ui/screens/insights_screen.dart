import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icons.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer3<ExpenseViewModel, CategoryViewModel, SettingsViewModel>(
        builder: (context, expenses, categories, settings, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Insights',
                    style: AppTextStyles.headlineLarge,
                  ),
                ),
              ),

              if (!expenses.hasExpenses)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Not enough data to show insights.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else ...[
                // Monthly Trend Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '6-Month Trend',
                            style: AppTextStyles.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _MonthlyBarChart(
                              monthlyData: expenses.lastSixMonths,
                              currencySymbol: settings.currencySymbol,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category Breakdown title
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'This Month by Category',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ),
                ),

                // Pie Chart
                if (expenses.hasExpensesThisMonth)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _CategoryPieChart(
                                spendingByCategory: expenses.spendingByCategory,
                                // Provide category access so the chart can lookup colors
                                categoryVm: categories,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _CategoryLegend(
                                spendingByCategory: expenses.spendingByCategory,
                                categoryVm: categories,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                if (!expenses.hasExpensesThisMonth)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                         'No expenses logged this month yet.',
                         style: TextStyle(color: AppColors.textSecondary),
                         textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<dynamic> monthlyData; // Dynamic to avoid specific type imports on the shell
  final String currencySymbol;

  const _MonthlyBarChart({
    required this.monthlyData,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) return const SizedBox();

    // Find the max value to scale the Y axis properly
    double maxY = 0;
    for (final data in monthlyData) {
      if (data.total > maxY) maxY = data.total;
    }
    // Pad the top of the chart by 35% to make room for text
    maxY = maxY == 0 ? 100 : maxY * 1.35;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            // Use primary color for tooltip background
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '$currencySymbol${rod.toY.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthlyData.length) return const SizedBox();
                final data = monthlyData[index];
                if (data.total == 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    data.total.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthlyData.length) return const SizedBox();
                final data = monthlyData[index];
                
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                final monthName = months[data.month - 1];

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(monthlyData.length, (index) {
          final data = monthlyData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.total,
                width: 28,
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> spendingByCategory;
  final CategoryViewModel categoryVm;

  const _CategoryPieChart({
    required this.spendingByCategory,
    required this.categoryVm,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingByCategory.isEmpty) return const SizedBox();

    final total = spendingByCategory.values.fold(0.0, (a, b) => a + b);

    // Sort by spending
    final sortedEntries = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<PieChartSectionData> sections = [];
    
    // Create sections dynamically based on amount
    for (int i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        final catId = entry.key;
        final amount = entry.value;
        final percentage = (amount / total) * 100;
        
        // Grab Category context
        final iconString = categoryVm.getIconStringForCategory(catId);
        final color = CategoryIcons.colorForKey(iconString);

        sections.add(
          PieChartSectionData(
            color: color,
            value: amount,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: sections,
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final Map<String, double> spendingByCategory;
  final CategoryViewModel categoryVm;

  const _CategoryLegend({
    required this.spendingByCategory,
    required this.categoryVm,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by spending
    final sortedEntries = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      itemCount: sortedEntries.length,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final catId = entry.key;
        
        final name = categoryVm.getNameForCategory(catId);
        final iconString = categoryVm.getIconStringForCategory(catId);
        final color = CategoryIcons.colorForKey(iconString);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
