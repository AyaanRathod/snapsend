import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icons.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

/// Screen to manage total monthly budget and individual category limits.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _totalBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate the form if a total budget is already set.
    final budgetVm = context.read<BudgetViewModel>();
    if (budgetVm.totalBudgetLimit > 0) {
      _totalBudgetController.text = budgetVm.totalBudgetLimit.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
    super.dispose();
  }

  void _saveTotalBudget() {
    final raw = _totalBudgetController.text.trim();
    if (raw.isEmpty) return;
    final parsed = double.tryParse(raw);
    if (parsed != null && parsed >= 0) {
      context.read<BudgetViewModel>().setTotalBudget(parsed);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total budget updated')),
      );
      FocusScope.of(context).unfocus();
    }
  }

  void _showCategoryBudgetDialog(BuildContext context, String categoryId, String categoryName, double currentLimit) {
    final controller = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final settings = context.watch<SettingsViewModel>();
        return AlertDialog(
          title: Text('Budget for $categoryName'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
            decoration: InputDecoration(
              hintText: 'Unlimited',
              prefixText: '${settings.currencySymbol} ',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<BudgetViewModel>().removeCategoryBudget(categoryId);
                Navigator.pop(ctx);
              },
              child: const Text('Clear Limit', style: TextStyle(color: AppColors.error)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text.trim());
                if (val != null && val >= 0) {
                  context.read<BudgetViewModel>().setCategoryBudget(categoryId, val);
                } else {
                   context.read<BudgetViewModel>().removeCategoryBudget(categoryId);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final budgetVm = context.watch<BudgetViewModel>();
    final categoryVm = context.watch<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Budgets'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Total Budget Form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overall Monthly Limit', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'This dictates the main progress bar on your dashboard.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _totalBudgetController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: InputDecoration(
                              labelText: 'Limit',
                              prefixText: '${settings.currencySymbol} ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveTotalBudget,
                          child: const Text('Set'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('Category Limits', style: AppTextStyles.headlineMedium),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                'Optionally enforce stricter tracking on individual spending categories.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),

          // Categories List
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categoryVm.categories[index];
                  final summary = budgetVm.getSummaryForCategory(category.id);
                  
                  final hasLimit = summary != null && summary.limit > 0;
                  final spent = summary?.spent ?? 0;
                  final limit = summary?.limit ?? 0;
                  
                  // Compute bar usage
                  final progress = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                  Color progressColor = AppColors.primary;
                  if (hasLimit) {
                    if (spent >= limit) {
                      progressColor = AppColors.error;
                    } else if (progress >= 0.8) {
                      progressColor = AppColors.warning;
                    }
                  }

                  final iconData = CategoryIcons.forKey(category.iconString);
                  final color = CategoryIcons.colorForKey(category.iconString);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => _showCategoryBudgetDialog(context, category.id, category.name, limit),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  child: Icon(iconData, color: color, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(category.name, style: AppTextStyles.titleMedium),
                                ),
                                if (hasLimit)
                                  Text(
                                    '${settings.formatAmount(spent)} / ${settings.formatAmount(limit)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )
                                else
                                  TextButton(
                                    onPressed: () => _showCategoryBudgetDialog(context, category.id, category.name, limit),
                                    child: const Text('Add Limit'),
                                  )
                              ],
                            ),
                            if (hasLimit) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: AppColors.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: categoryVm.categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
