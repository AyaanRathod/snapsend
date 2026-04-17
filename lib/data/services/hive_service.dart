import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../models/income_model.dart';

/// Stateless wrapper around the Hive boxes used by this app.
class HiveService {
  // ── Box name constants ────
  static const String _expensesBoxName = 'expenses';
  static const String _categoriesBoxName = 'categories';
  static const String _budgetsBoxName = 'budgets';
  static const String _incomeBoxName = 'income';

  // ── Typed box accessors ────────────────────────────────────────────────
  Box<ExpenseModel> get expenses =>
      Hive.box<ExpenseModel>(_expensesBoxName);

  Box<CategoryModel> get categories =>
      Hive.box<CategoryModel>(_categoriesBoxName);

  Box<BudgetModel> get budgets =>
      Hive.box<BudgetModel>(_budgetsBoxName);

  Box<IncomeModel> get income =>
      Hive.box<IncomeModel>(_incomeBoxName);

  // ── Initialization ─────────────────────────────────────────────────────
  static Future<void> openBoxes() async {
    await Hive.openBox<ExpenseModel>(_expensesBoxName);
    await Hive.openBox<CategoryModel>(_categoriesBoxName);
    await Hive.openBox<BudgetModel>(_budgetsBoxName);
    await Hive.openBox<IncomeModel>(_incomeBoxName);
  }
}
