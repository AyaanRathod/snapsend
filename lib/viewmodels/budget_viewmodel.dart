import 'package:flutter/foundation.dart';
import '../data/models/budget_model.dart';
import '../data/models/chart_data.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/expense_repository.dart';

/// Manages all budget state — both the overall monthly cap and
/// per-category limits.
///
/// Includes "Rollover" logic: leftover budget from the previous month
/// is added to the current month's available funds.
class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepo;
  final ExpenseRepository _expenseRepo;

  BudgetModel? _totalBudget;
  double _totalSpentThisMonth = 0;
  double _rolloverFromLastMonth = 0;
  List<CategoryBudgetSummary> _summaries = [];
  String? _errorMessage;

  BudgetViewModel({
    required BudgetRepository budgetRepository,
    required ExpenseRepository expenseRepository,
  })  : _budgetRepo = budgetRepository,
        _expenseRepo = expenseRepository {
    refresh();
  }

  // ── Public State ───────────────────────────────────────────────────────

  String? get errorMessage => _errorMessage;

  /// The user's overall monthly budget record, or null if not set yet.
  BudgetModel? get totalBudget => _totalBudget;

  /// The monthly spending cap as a plain double (0 if none set).
  double get totalBudgetLimit => _totalBudget?.monthlyLimit ?? 0;

  /// Total amount spent in the current calendar month (across all categories).
  double get totalSpentThisMonth => _totalSpentThisMonth;

  /// Leftover amount from the previous month (Total Limit - Total Spent).
  double get rolloverFromLastMonth => _rolloverFromLastMonth;

  /// The "Effective" budget for this month: Base Limit + Rollover.
  double get effectiveTotalLimit => totalBudgetLimit + _rolloverFromLastMonth;

  /// 0.0 → 1.0+ budget utilisation.  Can exceed 1.0 when over-budget.
  /// Now accounts for rollover.
  double get totalBudgetProgress {
    final limit = effectiveTotalLimit;
    return limit > 0 ? totalSpentThisMonth / limit : 0.0;
  }

  bool get isOverTotalBudget =>
      effectiveTotalLimit > 0 && totalSpentThisMonth > effectiveTotalLimit;

  bool get hasTotalBudget => _totalBudget != null;

  double get totalRemaining => effectiveTotalLimit - totalSpentThisMonth;

  /// Per-category budget summaries, sorted (over-budget first).
  List<CategoryBudgetSummary> get budgetSummaries =>
      List.unmodifiable(_summaries);

  bool get hasCategoryBudgets => _summaries.isNotEmpty;

  // ── Commands ──────────────────────────────────────────────────────────

  /// Re-reads all budget limits + live expense data and recomputes progress.
  void refresh() {
    _errorMessage = null;
    _totalBudget = _budgetRepo.getTotalBudget();
    _totalSpentThisMonth = _expenseRepo.getTotalForCurrentMonth();

    // Calculate Rollover from last month
    _calculateRollover();

    final spent = _expenseRepo.getSpendingByCategoryForCurrentMonth();
    _summaries = _budgetRepo.buildBudgetSummaries(spent);

    notifyListeners();
  }

  void _calculateRollover() {
    final now = DateTime.now();
    // Get last month's date
    final lastMonthDate = DateTime(now.year, now.month - 1, 1);
    
    // We assume the budget limit was the same last month (Set and Forget system)
    final limit = totalBudgetLimit;
    if (limit <= 0) {
      _rolloverFromLastMonth = 0;
      return;
    }

    final spentLastMonth = _expenseRepo.getExpensesByMonth(
      lastMonthDate.year, 
      lastMonthDate.month,
    ).fold(0.0, (sum, e) => sum + e.amount);

    final leftover = limit - spentLastMonth;
    
    // Only rollover POSITIVE leftover. We don't "punish" by carrying over debt
    // unless you want a strict system. Usually, rollover is a bonus.
    _rolloverFromLastMonth = leftover > 0 ? leftover : 0.0;
  }

  /// Sets or updates the overall monthly spending cap.
  void setTotalBudget(double limit) {
    if (limit < 0) return;
    _budgetRepo.setTotalBudget(limit);
    refresh();
  }

  /// Sets or updates a per-category spending limit.
  void setCategoryBudget(String categoryId, double limit) {
    if (limit < 0) return;
    _budgetRepo.setBudget(categoryId, limit);
    refresh();
  }

  /// Removes the spending limit for a category (set to unlimited).
  void removeCategoryBudget(String categoryId) {
    _budgetRepo.deleteBudget(categoryId);
    refresh();
  }

  /// Returns the raw [BudgetModel] for [categoryId], or null if none set.
  BudgetModel? getBudgetForCategory(String categoryId) =>
      _budgetRepo.getBudgetForCategory(categoryId);

  /// Returns the summary (with live progress) for [categoryId], or null.
  CategoryBudgetSummary? getSummaryForCategory(String categoryId) {
    try {
      return _summaries.firstWhere((s) => s.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }
}
