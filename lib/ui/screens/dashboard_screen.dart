import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../widgets/expense_list_tile.dart';
import 'budget_screen.dart';
import 'expense_form_screen.dart';
import 'insights_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

/// The main scaffold housing the BottomNavigationBar and the 3 core tabs.
/// Contains the Dashboard layout in the first tab.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _DashboardTab(),
    const BudgetScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
          );
        },
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            );
          },
          child: const Icon(Icons.camera_alt_rounded, size: 28),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 64.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? AppColors.primary : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.account_balance_wallet_rounded, color: _currentIndex == 1 ? AppColors.primary : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: Icon(Icons.bar_chart_rounded, color: _currentIndex == 2 ? AppColors.primary : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: Icon(Icons.settings_rounded, color: _currentIndex == 3 ? AppColors.primary : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

/// The actual Dashboard content (Home tab).
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _DashboardHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: _BudgetOverviewCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // "Recent Expenses" sticky header
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Recent Expenses',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
            ),
          ),
          
          // The actual list of most recent expenses
          const _RecentExpensesList(),
          
          // FAB padding allowance at bottom
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

/// "Hello, [Name]" header.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${settings.userName}',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Here is your spending overview.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Main budget card showing total spent vs budget limit for the month.
class _BudgetOverviewCard extends StatelessWidget {
  const _BudgetOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseViewModel, BudgetViewModel>(
      builder: (context, expenses, budget, _) {
        final settings = context.watch<SettingsViewModel>();
        final spent = expenses.totalThisMonth;
        final limit = budget.totalBudgetLimit;
        final hasLimit = limit > 0;
        final progress = budget.totalBudgetProgress;
        
        // Determine status colors based on usage
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetScreen()),
              );
            },
            child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.elevated,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      settings.formatAmount(spent),
                      style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                    ),
                    if (hasLimit) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '/ ${settings.formatAmount(limit)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ]
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
                ]
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

/// Renders the last 10 expenses.
class _RecentExpensesList extends StatelessWidget {
  const _RecentExpensesList();

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
                    Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textDisabled),
                    const SizedBox(height: 16),
                    const Text(
                      'No expenses yet',
                      style: AppTextStyles.titleLarge,
                    ),
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
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpenseFormScreen(existingExpense: expense),
                        ),
                      );
                    },
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

/// Helper to allow SliverPersistentHeader to use a simple regular Widget.
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverHeaderDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => true;
}
