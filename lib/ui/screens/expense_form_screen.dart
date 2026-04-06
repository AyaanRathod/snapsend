import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icons.dart';
import '../../data/models/expense_model.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'image_viewer_screen.dart';

/// Unified Add & Edit Expense form.
/// 
/// If [existingExpense] is provided, populates the form for editing.
class ExpenseFormScreen extends StatefulWidget {
  final ExpenseModel? existingExpense;
  final double? initialAmount;
  final String? receiptImagePath;

  const ExpenseFormScreen({
    super.key, 
    this.existingExpense,
    this.initialAmount,
    this.receiptImagePath,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;
    
    _amountController = TextEditingController(
      text: expense != null 
          ? expense.amount.toStringAsFixed(2) 
          : (widget.initialAmount != null ? widget.initialAmount!.toStringAsFixed(2) : ''),
    );
    _merchantController = TextEditingController(
      text: expense?.merchant ?? '',
    );
    _selectedDate = expense?.date ?? DateTime.now();
    _selectedCategoryId = expense?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final merchant = _merchantController.text.trim();

    final expenseVm = context.read<ExpenseViewModel>();
    
    if (_isEditing) {
      final updated = ExpenseModel(
        id: widget.existingExpense!.id,
        amount: amount,
        merchant: merchant,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        isScanned: widget.existingExpense!.isScanned,
        receiptImagePath: widget.existingExpense!.receiptImagePath,
      );
      expenseVm.updateExpense(updated);
    } else {
      expenseVm.addExpense(
        amount: amount,
        merchant: merchant,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        isScanned: widget.receiptImagePath != null,
        receiptImagePath: widget.receiptImagePath,
      );
    }

    // Refresh budgets to update the UI correctly!
    context.read<BudgetViewModel>().refresh();

    Navigator.of(context).pop();
  }

  void _deleteExpense() {
    if (!_isEditing) return;
    final expenseVm = context.read<ExpenseViewModel>();
    expenseVm.deleteExpense(widget.existingExpense!.id);
    context.read<BudgetViewModel>().refresh();
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)), // allow slight future
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    final categoryVm = context.watch<CategoryViewModel>();
    
    // Ensure the initial category is valid or clear it if it got deleted
    if (_selectedCategoryId != null && 
        categoryVm.getCategoryById(_selectedCategoryId!) == null) {
      _selectedCategoryId = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                style: AppTextStyles.displayMedium,
                decoration: InputDecoration(
                  prefixText: '${settingsVm.currencySymbol} ',
                  prefixStyle: AppTextStyles.displayMedium.copyWith(color: AppColors.textSecondary),
                  labelText: 'Amount',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 2. Merchant Field
              TextFormField(
                controller: _merchantController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name',
                  hintText: 'e.g. Starbucks, Amazon...',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter a merchant name';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 3. Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                hint: const Text('Select a category'),
                items: categoryVm.categories.map((c) {
                  final iconData = CategoryIcons.forKey(c.iconString);
                  final color = CategoryIcons.colorForKey(c.iconString);
                  return DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(iconData, color: color, size: 20),
                        const SizedBox(width: 12),
                        Text(c.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
              const SizedBox(height: 24),

              // 4. Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(
                              _formatFullDate(_selectedDate),
                              style: AppTextStyles.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Scanned Receipt Thumbnail (if applicable)
              if (_isEditing && widget.existingExpense?.receiptImagePath != null || (!_isEditing && widget.receiptImagePath != null)) ...[
                const Text('Attached Receipt', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    final path = _isEditing ? widget.existingExpense!.receiptImagePath! : widget.receiptImagePath!;
                    final tag = _isEditing ? 'receipt_image_${widget.existingExpense!.id}' : 'receipt_image_new';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageViewerScreen(
                          imagePath: path,
                          heroTag: tag,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: _isEditing ? 'receipt_image_${widget.existingExpense!.id}' : 'receipt_image_new',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(
                            File(_isEditing ? widget.existingExpense!.receiptImagePath! : widget.receiptImagePath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.zoom_in, color: Colors.white, size: 24),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 6. Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: const Text('Save Expense'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    // E.g. "Mon, Apr 6, 2026"
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
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

    if (result == true) {
      _deleteExpense();
    }
  }
}
