import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../widgets/charts/chart_card.dart';
import '../widgets/charts/monthly_bar_chart.dart';
import '../widgets/charts/week_line_chart.dart';
import '../widgets/charts/category_donut_chart.dart';
import '../widgets/charts/category_radar_chart.dart';
import '../widgets/charts/income_vs_expense_chart.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../widgets/common/snapspend_app_bar.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Consumer5<ExpenseViewModel, CategoryViewModel, SettingsViewModel,
          BudgetViewModel, IncomeViewModel>(
        builder: (context, expenses, categories, settings, budgets, income, _) {
          final sym = settings.currencySymbol;

          if (!expenses.hasExpenses) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_outlined,
                      size: 72,
                      color: cs.onSurfaceVariant.withOpacity(0.4)),
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

              _header(context, 'Monthly Cash Flow (Income vs Spending)'),
              SliverToBoxAdapter(
                child: ChartCard(
                  height: 220,
                  child: IncomeVsExpenseChart(
                    totalIncome: income.totalIncomeThisMonth,
                    totalExpense: expenses.totalThisMonth,
                    currencySymbol: sym,
                  ),
                ),
              ),

              if (budgets.hasCategoryBudgets && budgets.budgetSummaries.length >= 3) ...[
                _header(context, 'Budget Discipline (Category Balance)'),
                SliverToBoxAdapter(
                  child: ChartCard(
                    height: 320,
                    child: CategoryRadarChart(
                      summaries: budgets.budgetSummaries,
                      totalIncome: income.totalIncomeThisMonth,
                      currencySymbol: sym,
                    ),
                  ),
                ),
              ],

              _header(context, 'Weekly Activity'),
              SliverToBoxAdapter(
                child: ChartCard(
                  height: 200,
                  child: WeekLineChart(
                    weekData: expenses.currentWeekDailyTotals,
                    currencySymbol: sym,
                  ),
                ),
              ),

              _header(context, 'Spending Trend (6-Months)'),
              SliverToBoxAdapter(
                child: ChartCard(
                  height: 230,
                  child: MonthlyBarChart(
                    monthlyData: expenses.lastSixMonths,
                    currencySymbol: sym,
                  ),
                ),
              ),

              _header(context, 'Spending Breakdown (Categories)'),
              if (expenses.hasExpensesThisMonth)
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
