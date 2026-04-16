import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/budget_viewmodel.dart';
import '../../../viewmodels/expense_viewmodel.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import '../../screens/budget_screen.dart';

/// Main budget card on the Dashboard. Shows total spent vs monthly limit
/// with a colour-coded progress bar. Tapping navigates to BudgetScreen.
class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseViewModel, BudgetViewModel>(
      builder: (context, expenses, budget, _) {
        final settings = context.watch<SettingsViewModel>();
        final spent = expenses.totalThisMonth;
        final limit = budget.totalBudgetLimit;
        final hasLimit = limit > 0;
        final progress = budget.totalBudgetProgress;

        Color statusColor = Colors.white;
        if (hasLimit) {
          if (progress >= 1.0) {
            statusColor = AppColors.error;
          } else if (progress >= 0.8) {
            statusColor = AppColors.warning;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.elevated,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Spent (This Month)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasLimit)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}% Used',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        settings.formatAmount(spent),
                        style: AppTextStyles.displayMedium
                            .copyWith(color: Colors.white),
                      ),
                      if (hasLimit) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '/ ${settings.formatAmount(limit)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasLimit) ...[
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
