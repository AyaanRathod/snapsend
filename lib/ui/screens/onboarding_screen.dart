import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final settingsVm = context.read<SettingsViewModel>();
    final budgetVm = context.read<BudgetViewModel>();
    final budgetText = _budgetController.text.trim();
    if (budgetText.isNotEmpty) {
      final parsed = double.tryParse(budgetText);
      if (parsed != null && parsed > 0) budgetVm.setTotalBudget(parsed);
    }
    await settingsVm.completeOnboarding(
      name: _nameController.text.trim(),
      currencySymbol: _currencyController.text.trim(),
    );
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header (Dots and Skip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: List.generate(3, (index) => _buildIndicator(index))),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: () => _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            // Content Area (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(isLandscape),
                  _buildProfilePage(isLandscape),
                  _buildBudgetPage(isLandscape),
                ],
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
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.textDisabled.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }

  Widget _buildWelcomePage(bool isLandscape) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32.0),
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(isLandscape ? 12 : 24),
              decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome, size: isLandscape ? 32 : 64, color: AppColors.primary),
            ),
            SizedBox(height: isLandscape ? 16 : 40),
            const Text('Smart Expense Tracking', style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text(
              'Keep an eye on your spending effortlessly with AI-powered receipt scanning.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildProfilePage(bool isLandscape) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32.0),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Make it yours', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              const Text('How should we address you?', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              SizedBox(height: isLandscape ? 20 : 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'First Name', hintText: 'e.g. Alex', prefixIcon: Icon(Icons.person_outline)),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _currencyController.text.isNotEmpty && ['\$', 'US\$', 'C\$', '€', '£', '¥', '₹', 'A\$'].contains(_currencyController.text) ? _currencyController.text : '\$',
                decoration: const InputDecoration(labelText: 'Currency', prefixIcon: Icon(Icons.payments_outlined)),
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
                onChanged: (val) { if (val != null) setState(() => _currencyController.text = val); },
              ),
              const SizedBox(height: 40),
              _buildContinueButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetPage(bool isLandscape) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set your goals', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            const Text('Want to keep your spending in check? Set a monthly budget to track your progress.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            SizedBox(height: isLandscape ? 20 : 32),
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
              decoration: InputDecoration(
                labelText: 'Monthly Budget (Optional)',
                prefixText: '${_currencyController.text.trim()} ',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextPage,
        child: Text(_currentPage == 2 ? 'Get Started' : 'Continue'),
      ),
    );
  }
}
