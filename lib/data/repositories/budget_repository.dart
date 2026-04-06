import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../models/chart_data.dart';
import '../services/hive_service.dart';
import 'category_repository.dart';

const _uuid = Uuid();

// Sentinel value used as [BudgetModel.categoryId] for the overall budget.
const String kTotalBudgetKey = 'TOTAL';

/// Single Source of Truth (SSOT) for all [BudgetModel] data.
///
/// Design:
///   - Each category (and TOTAL) has AT MOST one budget record.
///   - [setBudget] is always an upsert — it creates or updates as needed.
///   - Budgets are timeless: the monthly spend comparison happens in
///     [ExpenseRepository], not here.
class BudgetRepository {
  final HiveService _service;
  final CategoryRepository _categoryRepository;

  BudgetRepository(this._service, this._categoryRepository);

  // ── Helpers ────────────────────────────────────────────────────────────

  /// The Hive box key for a budget record is the [categoryId] itself.
  /// This makes look-ups O(1) and guarantees one budget per category.
  String _keyFor(String categoryId) => categoryId;

  // ── Write Operations ───────────────────────────────────────────────────

  /// Creates or updates the budget for [categoryId].
  ///
  /// Pass [kTotalBudgetKey] as [categoryId] to set the overall budget.
  void setBudget(String categoryId, double monthlyLimit) {
    final existing = _service.budgets.get(_keyFor(categoryId));
    final budget = BudgetModel(
      id: existing?.id ?? _uuid.v4(),
      categoryId: categoryId,
      monthlyLimit: monthlyLimit,
    );
    _service.budgets.put(_keyFor(categoryId), budget);
  }

  /// Shortcut to set the overall monthly spending cap.
  void setTotalBudget(double monthlyLimit) {
    setBudget(kTotalBudgetKey, monthlyLimit);
  }

  /// Removes the budget for [categoryId].
  ///
  /// After this call, the category has no spending limit (unlimited).
  void deleteBudget(String categoryId) {
    _service.budgets.delete(_keyFor(categoryId));
  }

  // ── Read Operations ────────────────────────────────────────────────────

  /// Returns the budget for [categoryId], or null if none is set.
  BudgetModel? getBudgetForCategory(String categoryId) {
    return _service.budgets.get(_keyFor(categoryId));
  }

  /// Returns the overall monthly budget, or null if the user hasn't set one.
  BudgetModel? getTotalBudget() {
    return getBudgetForCategory(kTotalBudgetKey);
  }

  /// Returns all stored budgets.
  List<BudgetModel> getAllBudgets() {
    return _service.budgets.values.toList();
  }

  /// Returns all per-category budgets (excludes the TOTAL budget).
  List<BudgetModel> getCategoryBudgets() {
    return _service.budgets.values
        .where((b) => b.categoryId != kTotalBudgetKey)
        .toList();
  }

  /// Builds a [CategoryBudgetSummary] for every category that HAS a budget
  /// and whose spending data is provided via [spentByCategory].
  ///
  /// `spentByCategory` — `Map&lt;categoryId, amountSpentThisMonth&gt;`
  /// Typically sourced from [ExpenseRepository.getSpendingByCategoryForCurrentMonth()].
  ///
  /// Used directly by the BudgetViewModel to build the progress-bar list.
  List<CategoryBudgetSummary> buildBudgetSummaries(
    Map<String, double> spentByCategory,
  ) {
    final summaries = <CategoryBudgetSummary>[];

    for (final budget in getCategoryBudgets()) {
      final category =
          _categoryRepository.getCategoryById(budget.categoryId);
      if (category == null) continue; // orphaned budget — skip

      summaries.add(CategoryBudgetSummary(
        categoryId: budget.categoryId,
        categoryName: category.name,
        iconString: category.iconString,
        spent: spentByCategory[budget.categoryId] ?? 0.0,
        limit: budget.monthlyLimit,
      ));
    }

    // Sort: over-budget first, then by % used descending.
    summaries.sort((a, b) {
      if (a.isOverBudget && !b.isOverBudget) return -1;
      if (!a.isOverBudget && b.isOverBudget) return 1;
      return b.progress.compareTo(a.progress);
    });

    return summaries;
  }
}
