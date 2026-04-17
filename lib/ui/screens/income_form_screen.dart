import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

class IncomeFormScreen extends StatefulWidget {
  const IncomeFormScreen({super.key});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _sourceController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _sourceController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _saveIncome() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.parse(_amountController.text.trim());
    final source = _sourceController.text.trim();

    context.read<IncomeViewModel>().addIncome(
      amount: amount,
      source: source,
      date: _selectedDate,
    );

    // Clear form after saving
    _amountController.clear();
    _sourceController.clear();
    setState(() => _selectedDate = DateTime.now());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    final incomeVm = context.watch<IncomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Management'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Income', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                      ],
                      style: AppTextStyles.displayMedium,
                      decoration: InputDecoration(
                        prefixText: '${settingsVm.currencySymbol} ',
                        labelText: 'Amount',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter an amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sourceController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                        hintText: 'e.g. Salary, Freelance...',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveIncome,
                        child: const Text('Save Income'),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text('Recent Income', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 16),
                    if (incomeVm.incomeList.isEmpty)
                      const Center(child: Text('No income recorded yet.'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: incomeVm.incomeList.length,
                        itemBuilder: (context, index) {
                          final income = incomeVm.incomeList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                              ),
                              title: Text(income.source.isEmpty ? 'Income' : income.source),
                              subtitle: Text('${income.date.day}/${income.date.month}/${income.date.year}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    settingsVm.formatAmount(income.amount),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => incomeVm.deleteIncome(income.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
