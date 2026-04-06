/// Plain Dart models used by the chart screens.
/// These are NOT Hive entities — they are ephemeral, computed at read time
/// by the repositories and consumed directly by ViewModels.

/// Represents the total expenditure for a single calendar month.
///
/// Used by the bar chart on the Insights screen (last N months).
class MonthlyTotal {
  /// The first day of the represented month (day = 1).
  final DateTime month;

  /// Sum of all expenses recorded in [month].
  final double total;

  const MonthlyTotal({required this.month, required this.total});

  /// Convenience: true when no expenses were logged in this month.
  bool get isEmpty => total == 0;
}

/// Represents the total expenditure for a single calendar day.
///
/// Used by the weekly bar chart on the Insights screen.
class DailyTotal {
  final DateTime date;
  final double total;

  const DailyTotal({required this.date, required this.total});

  bool get isEmpty => total == 0;
}

/// Snapshot of spending and budget for a single category.
///
/// Consumed by budget progress-bar widgets.
class CategoryBudgetSummary {
  final String categoryId;
  final String categoryName;
  final String iconString;
  final double spent;
  final double limit;

  const CategoryBudgetSummary({
    required this.categoryId,
    required this.categoryName,
    required this.iconString,
    required this.spent,
    required this.limit,
  });

  /// 0.0 → 1.0+ (can exceed 1.0 when over-budget).
  double get progress => limit > 0 ? spent / limit : 0;

  bool get isOverBudget => spent > limit;

  /// Remaining allowance; negative when over-budget.
  double get remaining => limit - spent;
}
