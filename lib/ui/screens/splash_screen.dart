import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';

/// The Splash Screen acts as the central routing hub on app launch.
///
/// It listens to [SettingsViewModel] to determine if the user has completed
/// the onboarding flow, and routes them accordingly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a tiny delay to allow the framework to build first,
    // and to show off the splash screen branding momentarily.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate(context);
    });
  }

  Future<void> _navigate(BuildContext context) async {
    // 500ms delay for aesthetics
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!context.mounted) return;

    final settings = context.read<SettingsViewModel>();
    
    if (settings.isFullyConfigured) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple, branded splash screen while routing is decided.
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'SnapSpend',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
