import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/budget_viewmodel.dart';
import '../../../viewmodels/expense_viewmodel.dart';
import '../../screens/expense_form_screen.dart';
import '../expense_list_tile.dart';

/// Renders the 10 most recent expenses as a swipeable sliver list.
class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, expensesVm, _) {
        final recent = expensesVm.recentExpenses;

        if (recent.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: AppColors.textDisabled),
                    const SizedBox(height: 16),
                    const Text('No expenses yet',
                        style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the + button to add your first expense.',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final expense = recent[index];
                return Dismissible(
                  key: ValueKey(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                  ),
                  onDismissed: (direction) {
                    expensesVm.deleteExpense(expense.id);
                    context.read<BudgetViewModel>().refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense deleted')),
                    );
                  },
                  child: ExpenseListTile(
                    expense: expense,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExpenseFormScreen(existingExpense: expense),
                      ),
                    ),
                  ),
                );
              },
              childCount: recent.length,
            ),
          ),
        );
      },
    );
  }
}

/// Allows a plain Widget to be used as a [SliverPersistentHeader] delegate.
class SliverFixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const SliverFixedHeaderDelegate({
    required this.child,
    this.height = 48.0,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(covariant SliverFixedHeaderDelegate oldDelegate) => true;
}
