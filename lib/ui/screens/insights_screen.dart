import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../widgets/charts/chart_card.dart';
import '../widgets/charts/monthly_bar_chart.dart';
import '../widgets/charts/week_line_chart.dart';
import '../widgets/charts/category_donut_chart.dart';
import '../widgets/charts/budget_bars_chart.dart';
import '../widgets/charts/category_radar_chart.dart';
import '../../viewmodels/category_viewmodel.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Consumer4<ExpenseViewModel, CategoryViewModel, SettingsViewModel,
          BudgetViewModel>(
        builder: (context, expenses, categories, settings, budgets, _) {
          final sym = settings.currencySymbol;

          if (!expenses.hasExpenses) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_outlined,
                      size: 72,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Add your first expense\nto see insights here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Summary chips
              SliverPadding(
                padding: const EdgeInsets.only(top: 16),
                sliver: SliverToBoxAdapter(
                  child: InsightsSummaryRow(
                    totalThisMonth: expenses.totalThisMonth,
                    totalAllTime:
                        expenses.expenses.fold(0.0, (s, e) => s + e.amount),
                    currencySymbol: sym,
                    expenseCount: expenses.expenses.length,
                  ),
                ),
              ),

              _header(context, '6-Month Spending'),
              SliverToBoxAdapter(
                child: ChartCard(
                  height: 230,
                  child: MonthlyBarChart(
                    monthlyData: expenses.lastSixMonths,
                    currencySymbol: sym,
                  ),
                ),
              ),

              _header(context, 'This Week'),
              SliverToBoxAdapter(
                child: ChartCard(
                  height: 200,
                  child: WeekLineChart(
                    weekData: expenses.currentWeekDailyTotals,
                    currencySymbol: sym,
                  ),
                ),
              ),

              if (expenses.hasExpensesThisMonth) ...[
                _header(context, 'Spending by Category'),
                SliverToBoxAdapter(
                  child: ChartCard(
                    height: 280,
                    child: CategoryDonutChart(
                      spendingByCategory: expenses.spendingByCategory,
                      categoryVm: categories,
                      currencySymbol: sym,
                    ),
                  ),
                ),
              ],

              if (budgets.hasCategoryBudgets) ...[
                _header(context, 'Budget vs Actual'),
                SliverToBoxAdapter(
                  child: ChartCard(
                    height: (budgets.budgetSummaries.length * 66.0)
                        .clamp(120, 400),
                    child: BudgetBarsChart(
                      summaries: budgets.budgetSummaries,
                      currencySymbol: sym,
                    ),
                  ),
                ),

                if (budgets.budgetSummaries.length >= 3) ...[
                  _header(context, 'Category Budget Radar'),
                  SliverToBoxAdapter(
                    child: ChartCard(
                      height: 300,
                      child: CategoryRadarChart(
                        summaries: budgets.budgetSummaries,
                        currencySymbol: sym,
                      ),
                    ),
                  ),
                ],
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          );
        },
      ),
    );
  }

  static SliverPadding _header(BuildContext context, String title) =>
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        sliver: SliverToBoxAdapter(
          child: Text(title,
              style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
        ),
      );
}
