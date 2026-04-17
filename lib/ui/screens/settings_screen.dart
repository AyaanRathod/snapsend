import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'category_management_screen.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showNameEditDialog(BuildContext context, SettingsViewModel vm) {
    final controller = TextEditingController(text: vm.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Display Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.setUserName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyEditDialog(BuildContext context, SettingsViewModel vm) {
    String currentSymbol = vm.currencySymbol;
    if (!['\$', 'US\$', 'C\$', 'A\$', '€', '£', '¥', '₹'].contains(currentSymbol)) {
        currentSymbol = '\$';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Currency'),
            content: DropdownButtonFormField<String>(
              initialValue: currentSymbol,
              decoration: const InputDecoration(labelText: 'Currency Symbol'),
              items: const [
                DropdownMenuItem(value: '\$', child: Text('\$ (Generic)')),
                DropdownMenuItem(value: 'US\$', child: Text('US\$ (USD)')),
                DropdownMenuItem(value: 'C\$', child: Text('C\$ (CAD)')),
                DropdownMenuItem(value: 'A\$', child: Text('A\$ (AUD)')),
                DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
                DropdownMenuItem(value: '¥', child: Text('¥ (JPY)')),
                DropdownMenuItem(value: '₹', child: Text('₹ (INR)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => currentSymbol = val);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  vm.setCurrencySymbol(currentSymbol);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _confirmRerunSetup(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Setup?'),
        content: const Text(
          'This will flag the app as if it is opening for the first time, bringing you back to the intro screens. Existing expenses will NOT be wiped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await context.read<SettingsViewModel>().resetOnboarding();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Settings',
                    style: AppTextStyles.headlineLarge,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Profile'),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Display Name'),
                              subtitle: Text(settings.userName),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () => _showNameEditDialog(context, settings),
                            ),
                            const Divider(height: 1, indent: 56),
                            ListTile(
                              leading: const Icon(Icons.payments_outlined),
                              title: const Text('Currency Symbol'),
                              subtitle: Text(settings.currencySymbol),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () => _showCurrencyEditDialog(context, settings),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('App Configuration'),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.category_outlined),
                              title: const Text('Manage Categories'),
                              subtitle: const Text('Add or remove custom categories'),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                                );
                              },
                            ),
                            // NOTE: Budget config is accessed from the Dashboard.
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Advanced'),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.restart_alt_outlined, color: AppColors.error),
                              title: const Text('Rerun Setup Flow', style: TextStyle(color: AppColors.error)),
                              subtitle: const Text('Goes back to welcome screen'),
                              onTap: () => _confirmRerunSetup(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
