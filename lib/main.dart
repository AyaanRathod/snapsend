import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/models/budget_model.dart';
import 'data/models/category_model.dart';
import 'data/models/expense_model.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/hive_service.dart';
import 'viewmodels/budget_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'viewmodels/scanner_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter engine is firmly initialized before async plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Init Hive & Register Adapters ──────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryModelAdapter()); // TypeId: 0
  Hive.registerAdapter(ExpenseModelAdapter());  // TypeId: 1
  Hive.registerAdapter(BudgetModelAdapter());   // TypeId: 2

  // Open all boxes via the HiveService utility.
  await HiveService.openBoxes();

  // ── 2. Init SharedPreferences ───────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  // ── 3. Build Dependency Tree (Repositories) ───────────────────────────
  final hiveService = HiveService();
  
  final settingsRepo = SettingsRepository(prefs);
  final expenseRepo = ExpenseRepository(hiveService);
  final categoryRepo = CategoryRepository(hiveService);
  final budgetRepo = BudgetRepository(hiveService, categoryRepo);

  // Seed default categories if this is the first launch.
  categoryRepo.ensureDefaults();

  // ── 4. Boot App with Providers ──────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(repository: settingsRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseViewModel(repository: expenseRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(repository: categoryRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetViewModel(
            budgetRepository: budgetRepo,
            expenseRepository: expenseRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ScannerViewModel(),
        ),
      ],
      child: const SnapSpendApp(),
    ),
  );
}

class SnapSpendApp extends StatelessWidget {
  const SnapSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapSpend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // The app respects system theme (light/dark mode) by default.
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
