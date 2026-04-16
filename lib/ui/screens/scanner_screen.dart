import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/scanner_viewmodel.dart';
import 'expense_form_screen.dart';

/// Intermediary screen that triggers the ML Kit scanner intent and handles
/// the UI states (Processing, Error) before routing to the ExpenseFormScreen.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  /// Guards against the callback firing multiple times during consecutive rebuilds.
  bool _navigated = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ScannerViewModel>();
      vm.startScan();
      setState(() => _hasStarted = true);
    });
  }

  void _navigateToForm(ScannerViewModel vm) {
    if (_navigated || !mounted) return;
    _navigated = true;

    // Capture the values NOW before reset clears them.
    final double? amount = vm.parsedAmount;
    final String? imagePath = vm.scannedImagePath;
    final bool noAmount = amount == null;

    // Reset the VM first (safe now since we copied the values above).
    vm.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (noAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No amount detected — please enter it manually.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExpenseFormScreen(
            initialAmount: amount,
            receiptImagePath: imagePath,
          ),
        ),
      );
    });
  }

  void _navigateBack(ScannerViewModel vm) {
    if (_navigated || !mounted) return;
    _navigated = true;
    vm.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerViewModel>(
      builder: (context, vm, child) {
        // User cancelled the native scanner — go back to Dashboard.
        if (_hasStarted && vm.isIdle && !vm.isBusy) {
          _navigateBack(vm);
          return const Scaffold(backgroundColor: Colors.black);
        }

        // Scan + OCR finished — navigate to the expense form.
        if (vm.isDone) {
          _navigateToForm(vm);
          return const Scaffold(backgroundColor: Colors.black);
        }

        // Error state.
        if (vm.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Scan Failed')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage ?? 'Unknown error occurred.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        vm.reset();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Scanning / Processing loading state.
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  vm.isScanning
                      ? 'Waiting for camera...'
                      : 'Extracting data via AI...',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
