import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../widgets/common/snapspend_app_bar.dart';
import 'budget_screen.dart';

class BudgetHealthScreen extends StatelessWidget {
  const BudgetHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetVm = context.watch<BudgetViewModel>();
    final expenseVm = context.watch<ExpenseViewModel>();
    final incomeVm = context.watch<IncomeViewModel>();
    final settings = context.watch<SettingsViewModel>();

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;

    final isOverBudget = budgetVm.isOverTotalBudget;
    final remaining = budgetVm.totalRemaining;
    final dailyAllowance = remaining > 0 ? remaining / daysRemaining : 0.0;

    return Scaffold(
      appBar: SnapSpendAppBar(
        title: 'Budget Health',
        showBackButton: true,
        onLogoPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onProfilePressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Health Status Card
            _buildStatusCard(context, isOverBudget, remaining, settings),

            const SizedBox(height: 24),

            // 2. Actionable Advice
            _buildAdviceSection(context, isOverBudget, dailyAllowance, daysRemaining, settings),

            const SizedBox(height: 32),

            // 3. Top Spending Categories (The "Culprits")
            const Text('Top Spending Categories', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            ...budgetVm.budgetSummaries.take(3).map((summary) => _buildCategoryTile(context, summary, settings)),

            const SizedBox(height: 32),

            // 4. Safe to Spend (Income Perspective)
            _buildIncomeInsight(context, incomeVm, expenseVm, settings),

            const SizedBox(height: 40),

            // Navigation to Management
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: SnapSpendAppBar(
                        title: 'Adjust Budgets', 
                        showBackButton: true,
                        onLogoPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                      body: const BudgetScreen(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Adjust Budget Limits'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isOver, double remaining, SettingsViewModel settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isOver ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isOver ? AppColors.error : AppColors.success, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            isOver ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            color: isOver ? AppColors.error : AppColors.success,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isOver ? 'Over Budget' : 'On Track',
            style: AppTextStyles.headlineLarge.copyWith(color: isOver ? AppColors.error : AppColors.success),
          ),
          const SizedBox(height: 8),
          Text(
            isOver
                ? 'You have exceeded your monthly limit by ${settings.formatAmount(remaining.abs())}'
                : 'You have ${settings.formatAmount(remaining)} remaining for this month.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection(BuildContext context, bool isOver, double allowance, int days, SettingsViewModel settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Strategy', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.warning),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isOver
                      ? "You've spent your full budget. Try to limit non-essential spending for the next $days days."
                      : "To stay under budget, you can spend up to ${settings.formatAmount(allowance)} per day.",
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, dynamic summary, SettingsViewModel settings) {
    final progress = summary.limit > 0 ? (summary.spent / summary.limit) : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(summary.categoryName, style: AppTextStyles.titleMedium),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progress >= 1.0 ? AppColors.error : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? AppColors.error : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeInsight(BuildContext context, IncomeViewModel incomeVm, ExpenseViewModel expenseVm, SettingsViewModel settings) {
    final totalIncome = incomeVm.totalIncomeThisMonth;
    final totalSpent = expenseVm.totalThisMonth;
    final savings = totalIncome - totalSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cash Flow Balance',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat('Income', settings.formatAmount(totalIncome)),
              _buildSimpleStat('Expenses', settings.formatAmount(totalSpent)),
              _buildSimpleStat('Balance', settings.formatAmount(savings)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
