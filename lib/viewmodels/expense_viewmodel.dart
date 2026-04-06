import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/expense_model.dart';
import '../data/models/chart_data.dart';
import '../data/repositories/expense_repository.dart';

const _uuid = Uuid();

/// **Web dev analogy:**
/// This is your Redux store slice + Context value for expenses.
/// - `addExpense()` = dispatch(addExpenseAction)
/// - `notifyListeners()` = setState() / store.emit()
/// - `Consumer<ExpenseViewModel>` in the UI = useSelector(state => state.expenses)
///
/// Every screen that cares about expenses wraps itself in a [Consumer]
/// and reads from this ViewModel's getters.
class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repo;

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  ExpenseViewModel({required ExpenseRepository repository})
      : _repo = repository {
    // Load immediately — Hive is in-memory so this is synchronous.
    _loadExpenses();
  }

  // ── Public State (read-only via getters) ──────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// All expenses, newest first (all time).
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  /// The 10 most recent expenses — used by the Dashboard recent list.
  List<ExpenseModel> get recentExpenses =>
      _expenses.take(10).toList();

  /// Expenses for the current calendar month.
  List<ExpenseModel> get currentMonthExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.toLocal().year == now.year &&
            e.date.toLocal().month == now.month)
        .toList();
  }

  /// Total amount spent this calendar month.
  double get totalThisMonth =>
      currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Map of categoryId → total spent this month per category.
  /// Fed into BudgetViewModel.refresh() and the Insights chart.
  Map<String, double> get spendingByCategory =>
      _repo.getSpendingByCategoryForCurrentMonth();

  /// Data for the Insights monthly bar chart (last 6 months).
  List<MonthlyTotal> get lastSixMonths => _repo.getLastNMonthsTotals(6);

  /// Data for the Insights weekly bar chart (current ISO week).
  List<DailyTotal> get currentWeekDailyTotals =>
      _repo.getCurrentWeekDailyTotals();

  bool get hasExpenses => _expenses.isNotEmpty;

  bool get hasExpensesThisMonth => currentMonthExpenses.isNotEmpty;

  // ── Commands (mutate state + call notifyListeners) ────────────────────

  /// Adds a new expense.  A fresh UUID is generated here — callers
  /// provide only the domain data, not the ID.
  void addExpense({
    required double amount,
    required String merchant,
    required DateTime date,
    required String categoryId,
    bool isScanned = false,
    String? receiptImagePath,
  }) {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      amount: amount,
      merchant: merchant,
      date: date,
      categoryId: categoryId,
      isScanned: isScanned,
      receiptImagePath: receiptImagePath,
    );
    _repo.addExpense(expense);
    _loadExpenses();
  }

  /// Persists changes to an existing expense (the ID on [expense] is used
  /// as the lookup key — never change it).
  void updateExpense(ExpenseModel expense) {
    _repo.updateExpense(expense);
    _loadExpenses();
  }

  /// Removes the expense with [id] from storage.
  void deleteExpense(String id) {
    _repo.deleteExpense(id);
    _loadExpenses();
  }

  /// Returns a single expense by [id], or null.
  ExpenseModel? getExpenseById(String id) => _repo.getExpenseById(id);

  /// Returns all expenses for a given [categoryId].
  List<ExpenseModel> getExpensesByCategory(String categoryId) =>
      _repo.getExpensesByCategory(categoryId);

  // ── Private Helpers ───────────────────────────────────────────────────

  void _loadExpenses() {
    _isLoading = true;
    _errorMessage = null;
    // Hive reads are synchronous — no await needed.
    _expenses = _repo.getAllExpenses();
    _isLoading = false;
    notifyListeners();
  }
}
