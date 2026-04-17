import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/common/snapspend_app_bar.dart';
import '../widgets/dashboard/budget_overview_card.dart';
import '../widgets/dashboard/burn_rate_card.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/recent_expenses_list.dart';
import 'budget_screen.dart';
import 'expense_form_screen.dart';
import 'insights_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

/// Root scaffold with BottomAppBar navigation and a central FAB.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: DashboardHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: BudgetOverviewCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: BurnRateCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // "Recent Expenses" sticky header
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverFixedHeaderDelegate(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Recent Expenses',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
            ),
          ),

          const RecentExpensesList(),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  String get _currentTitle {
    switch (_currentIndex) {
      case 0:
        return 'SnapSpend';
      case 1:
        return 'Budgets';
      case 2:
        return 'Insights';
      case 3:
        return 'Settings';
      default:
        return 'SnapSpend';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SnapSpendAppBar(
        title: _currentTitle,
        onLogoPressed: () => setState(() => _currentIndex = 0),
        onProfilePressed: () => setState(() => _currentIndex = 3),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          BudgetScreen(),
          InsightsScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onLongPress: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
        ),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          ),
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
            _navBtn(Icons.dashboard_rounded, 0),
            _navBtn(Icons.account_balance_wallet_rounded, 1),
            const SizedBox(width: 48), // FAB notch gap
            _navBtn(Icons.bar_chart_rounded, 2),
            _navBtn(Icons.settings_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, int index) => IconButton(
        icon: Icon(icon,
            color: _currentIndex == index ? AppColors.primary : Colors.grey),
        onPressed: () => setState(() => _currentIndex = index),
      );
}

class SliverFixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  SliverFixedHeaderDelegate({required this.child});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
