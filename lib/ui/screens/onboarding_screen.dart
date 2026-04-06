import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'dashboard_screen.dart';

/// The 3-page Onboarding Flow shown on first launch.
/// 
/// Collects user name, preferred currency, and an optional initial monthly budget.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form states and controllers
  final _nameController = TextEditingController();
  final _currencyController = TextEditingController(text: '\$');
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _currencyController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return; // Don't proceed if name/currency form is invalid
      }
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final settingsVm = context.read<SettingsViewModel>();
    final budgetVm = context.read<BudgetViewModel>();

    // 1. If an initial budget was provided, set it up.
    final budgetText = _budgetController.text.trim();
    if (budgetText.isNotEmpty) {
      final parsed = double.tryParse(budgetText);
      if (parsed != null && parsed > 0) {
        budgetVm.setTotalBudget(parsed);
      }
    }

    // 2. Complete onboarding and save settings.
    await settingsVm.completeOnboarding(
      name: _nameController.text.trim(),
      currencySymbol: _currencyController.text.trim(),
    );

    // 3. Navigate to Dashboard!
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicator & Skip button header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(3, (index) => _buildIndicator(index)),
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          2, // Skip to last page
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(height: 48), // Spacer to balance header
                ],
              ),
            ),
            
            // The Scrollable Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                  _buildBudgetPage(),
                ],
              ),
            ),

            // Bottom Navigation Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == 2 ? 'Get Started' : 'Continue',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? AppColors.primary 
            : AppColors.textDisabled.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Smart Expense Tracking',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Keep an eye on your spending effortlessly with AI-powered receipt scanning.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5), // Manually merged bodyLarge properties
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Make it yours',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'How should we address you?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'e.g. Alex',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'This symbol will be used everywhere. We support major formats:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            // Replace TextField with DropdownButtonFormField
            DropdownButtonFormField<String>(
              initialValue: _currencyController.text.isNotEmpty && ['\$', 'US\$', 'C\$', '€', '£', '¥', '₹', 'A\$'].contains(_currencyController.text) 
                  ? _currencyController.text 
                  : '\$',
              decoration: const InputDecoration(
                labelText: 'Currency',
                hintText: 'Select your currency',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
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
                if (val != null) setState(() => _currencyController.text = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Set your goals',
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Want to keep your spending in check? Set a monthly budget to track your progress.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: 'Monthly Budget (Optional)',
              hintText: 'e.g. 500',
              prefixText: '${_currencyController.text.trim()} ',
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can always skip this and set a budget later in Settings.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
