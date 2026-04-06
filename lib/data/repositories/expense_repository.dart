import '../models/expense_model.dart';
import '../models/chart_data.dart';
import '../services/hive_service.dart';

/// Single Source of Truth (SSOT) for all [ExpenseModel] data.
///
/// **Web dev analogy:** Think of this as a Redux store slice for expenses.
/// ViewModels read from here and dispatch commands to here — they never
/// touch Hive directly.
///
/// All write operations are synchronous because Hive is an in-memory store
/// (it flushes to disk in the background automatically).
class ExpenseRepository {
  final HiveService _service;

  ExpenseRepository(this._service);

  // ── Write Operations ──────────────────────────────────────────────────

  /// Persists a new expense.  The [expense.id] is used as the Hive box key
  /// for O(1) reads/writes/deletes.
  void addExpense(ExpenseModel expense) {
    _service.expenses.put(expense.id, expense);
  }

  /// Overwrites the stored expense with the same [expense.id].
  void updateExpense(ExpenseModel expense) {
    _service.expenses.put(expense.id, expense);
  }

  /// Permanently removes the expense with [id] from storage.
  void deleteExpense(String id) {
    _service.expenses.delete(id);
  }

  // ── Read Operations ───────────────────────────────────────────────────

  /// Returns all stored expenses, newest first.
  List<ExpenseModel> getAllExpenses() {
    final list = _service.expenses.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Returns a single expense by its [id], or null if not found.
  ExpenseModel? getExpenseById(String id) {
    return _service.expenses.get(id);
  }

  /// Returns all expenses recorded in the given calendar month, newest first.
  ///
  /// Month comparison is done in local time to match what the user sees.
  List<ExpenseModel> getExpensesByMonth(int year, int month) {
    final list = _service.expenses.values.where((e) {
      final local = e.date.toLocal();
      return local.year == year && local.month == month;
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Shortcut: expenses for the current calendar month.
  List<ExpenseModel> getExpensesForCurrentMonth() {
    final now = DateTime.now();
    return getExpensesByMonth(now.year, now.month);
  }

  /// Shortcut: the N most recent expenses across all time, newest first.
  List<ExpenseModel> getRecentExpenses({int limit = 10}) {
    final all = getAllExpenses();
    return all.take(limit).toList();
  }

  /// Returns all expenses belonging to [categoryId], newest first.
  List<ExpenseModel> getExpensesByCategory(String categoryId) {
    final list = _service.expenses.values
        .where((e) => e.categoryId == categoryId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // ── Aggregate / Analytics ─────────────────────────────────────────────

  /// Sum of all expenses in the current month.
  double getTotalForCurrentMonth() {
    return getExpensesForCurrentMonth()
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Sum of all expenses for a specific [categoryId] in the current month.
  double getMonthlySpendForCategory(String categoryId) {
    return getExpensesForCurrentMonth()
        .where((e) => e.categoryId == categoryId)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Returns a map of categoryId → total spent for the current month.
  Map<String, double> getSpendingByCategoryForCurrentMonth() {
    final result = <String, double>{};
    for (final expense in getExpensesForCurrentMonth()) {
      result[expense.categoryId] =
          (result[expense.categoryId] ?? 0) + expense.amount;
    }
    return result;
  }

  /// Returns [MonthlyTotal] records for the last [months] calendar months,
  /// ordered oldest → newest (left to right on a bar chart).
  ///
  /// Used by the Insights screen monthly bar chart.
  List<MonthlyTotal> getLastNMonthsTotals(int months) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      // Start from (months-1) months ago and work towards current month.
      final target = DateTime(now.year, now.month - (months - 1 - i), 1);
      final expenses = getExpensesByMonth(target.year, target.month);
      return MonthlyTotal(
        month: target,
        total: expenses.fold(0.0, (sum, e) => sum + e.amount),
      );
    });
  }

  /// Returns [DailyTotal] records for the current ISO week (Mon → Sun).
  ///
  /// Used by the Insights screen weekly bar chart.
  List<DailyTotal> getCurrentWeekDailyTotals() {
    final now = DateTime.now();
    // Dart's weekday: 1=Mon … 7=Sun.  Subtract (weekday-1) to get Monday.
    final monday = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final dayExpenses = _service.expenses.values.where((e) {
        final local = e.date.toLocal();
        return local.year == day.year &&
            local.month == day.month &&
            local.day == day.day;
      }).toList();
      return DailyTotal(
        date: day,
        total: dayExpenses.fold(0.0, (sum, e) => sum + e.amount),
      );
    });
  }
}
