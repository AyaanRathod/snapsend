import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import '../../../viewmodels/income_viewmodel.dart';
import '../../screens/income_form_screen.dart';

/// Greeting header shown at the top of the Dashboard tab.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final incomeVm = context.watch<IncomeViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${settings.userName} 👋',
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's your spending overview.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Small Income display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Monthly Income: ${settings.currencySymbol}${incomeVm.totalIncomeThisMonth.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IncomeFormScreen()),
                  ),
                  child: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
