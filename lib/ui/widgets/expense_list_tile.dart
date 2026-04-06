import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icons.dart';
import '../../data/models/expense_model.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

/// A reusable list tile representing a single expense.
/// Displays the category icon, merchant name, formatted date, and formatted amount.
class ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;

  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.read<SettingsViewModel>();
    final categoryVm = context.read<CategoryViewModel>();

    final iconString = categoryVm.getIconStringForCategory(expense.categoryId);
    final categoryName = categoryVm.getNameForCategory(expense.categoryId);

    final iconData = CategoryIcons.forKey(iconString);
    final iconColor = CategoryIcons.colorForKey(iconString);
    final bgColor = CategoryIcons.backgroundColorForKey(iconString);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 1. Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              
              // 2. Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.merchant,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          categoryName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.circle, size: 4, color: AppColors.textDisabled),
                        ),
                        Text(
                          _formatDate(expense.date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 3. Amount & Receipt Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settingsVm.formatAmount(expense.amount),
                    style: AppTextStyles.amountMedium,
                  ),
                  if (expense.isScanned) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long, size: 10, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Scan',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    
    // Quick relative day formatting for current week
    if (local.year == now.year && local.month == now.month) {
      if (local.day == now.day) return 'Today';
      if (local.day == now.day - 1) return 'Yesterday';
    }
    
    // Simple fallback using basic substring (e.g. 2026-04-06)
    // In a real app we'd use intl package, but keeping dependencies minimal.
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}
