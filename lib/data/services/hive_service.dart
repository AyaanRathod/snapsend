import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';

/// Stateless wrapper around the three Hive boxes used by this app.
///
/// Responsibilities:
///   - Know the box names (only this class does — no magic strings elsewhere).
///   - Provide typed box accessors.
///   - Provide a single static [openBoxes] method called once from main.dart.
///
/// This class does NOT contain any business logic.
/// It does NOT store application state.
/// Every repository receives a [HiveService] instance via constructor injection.
class HiveService {
  // ── Box name constants (private — no raw strings outside this class) ────
  static const String _expensesBoxName = 'expenses';
  static const String _categoriesBoxName = 'categories';
  static const String _budgetsBoxName = 'budgets';

  // ── Typed box accessors ────────────────────────────────────────────────
  Box<ExpenseModel> get expenses =>
      Hive.box<ExpenseModel>(_expensesBoxName);

  Box<CategoryModel> get categories =>
      Hive.box<CategoryModel>(_categoriesBoxName);

  Box<BudgetModel> get budgets =>
      Hive.box<BudgetModel>(_budgetsBoxName);

  // ── Initialization ─────────────────────────────────────────────────────
  /// Opens all Hive boxes.  Must be called after [Hive.initFlutter()] and
  /// after all adapters have been registered.
  ///
  /// Call once from [main()] before constructing any repository.
  static Future<void> openBoxes() async {
    await Hive.openBox<ExpenseModel>(_expensesBoxName);
    await Hive.openBox<CategoryModel>(_categoriesBoxName);
    await Hive.openBox<BudgetModel>(_budgetsBoxName);
  }
}
