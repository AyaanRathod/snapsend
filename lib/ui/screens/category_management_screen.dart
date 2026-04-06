import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icons.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddCategoryDialog(),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) async {
    final expensesVm = context.read<ExpenseViewModel>();
    
    // Check if the category is used
    final usedInExpenses = expensesVm.getExpensesByCategory(id).isNotEmpty;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          usedInExpenses 
            ? 'There are expenses using "$name". They will not be deleted, but they might appear under an unknown category.\n\nAre you sure?'
            : 'Are you sure you want to delete "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final error = context.read<CategoryViewModel>().deleteCategory(id);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Consumer<CategoryViewModel>(
        builder: (context, categoryVm, _) {
          final categories = categoryVm.categories;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final iconData = CategoryIcons.forKey(cat.iconString);
              final iconColor = CategoryIcons.colorForKey(cat.iconString);
              final bgColor = CategoryIcons.backgroundColorForKey(cat.iconString);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(iconData, color: iconColor),
                  ),
                  title: Text(cat.name, style: AppTextStyles.titleMedium),
                  subtitle: cat.isDefault 
                      ? const Text('Default Category', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)) 
                      : const Text('Custom Category', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: cat.isDefault
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, cat.id, cat.name),
                        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  
  // We grab the available icon keys excluding 'other' if we just want a nice list
  final List<String> _availableIcons = CategoryIcons.allOptions.map((e) => e.key).toList();
  late String _selectedIconString;

  @override
  void initState() {
    super.initState();
    _selectedIconString = _availableIcons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final error = context.read<CategoryViewModel>().addCategory(
      name: name,
      iconString: _selectedIconString,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Subscriptions',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            const Text('Pick an Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconKey) {
                final isSelected = _selectedIconString == iconKey;
                final iconData = CategoryIcons.forKey(iconKey);
                final color = CategoryIcons.colorForKey(iconKey);
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconString = iconKey),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(iconData, color: isSelected ? color : Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
