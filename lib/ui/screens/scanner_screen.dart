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
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    // Start scan automatically when this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ScannerViewModel>();
      vm.startScan();
      setState(() => _hasStarted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerViewModel>(
      builder: (context, vm, child) {
        // State 1: Idle (meaning user cancelled the native intent)
        if (_hasStarted && vm.isIdle && !vm.isBusy) {
          // If the user backed out of the native Android scanner,
          // pop this screen as well to return to Dashboard.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return const Scaffold(backgroundColor: Colors.black);
        }

        // State 2: Done (scanning + OCR finished successfully)
        if (vm.isDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.parsedAmount == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No amount detected. Please enter manually.')),
              );
            }
            // Replace this intermediary screen with the parsed form.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ExpenseFormScreen(
                  initialAmount: vm.parsedAmount,
                  receiptImagePath: vm.scannedImagePath,
                ),
              ),
            );
            // Reset the ViewModel state so it's ready for the next scan.
            vm.reset();
          });
          return const Scaffold(backgroundColor: Colors.black);
        }

        // State 3: Error
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

        // State 4: Scanning or Processing
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  vm.isScanning ? 'Waiting for camera...' : 'Extracting data via AI...',
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
