import 'package:hive/hive.dart';

part 'budget_model.g.dart';

/// Represents a monthly spending limit, either for a specific category
/// or for the overall total across all categories.
///
/// [typeId] 2 — must be unique across every @HiveType in the app.
///
/// Convention for [categoryId]:
///   - Use the string literal `"TOTAL"` to represent the overall monthly budget.
///   - Use a CategoryModel.id string to represent a per-category budget.
///
/// Design note: budgets are NOT date-bound in the Hive record itself.
/// The monthly reset logic lives in the repositories/viewmodels: when
/// querying "how much have I spent against this budget?", we always filter
/// ExpenseModel records by the current calendar month.  This means one
/// BudgetModel row covers every month — the user sets a limit once and it
/// rolls over automatically.
@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  /// The category this budget applies to.
  /// Use the sentinel value "TOTAL" for the overall monthly limit.
  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double monthlyLimit;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.monthlyLimit,
  });

  /// Convenience: true when this is the overall (not per-category) budget.
  bool get isTotal => categoryId == 'TOTAL';
}
