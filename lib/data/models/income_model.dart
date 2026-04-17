import 'package:hive/hive.dart';

part 'income_model.g.dart';

/// Represents a source of income (e.g., Salary, Freelance, Gift).
///
/// [typeId] 3 — must be unique across every @HiveType in the app.
@HiveType(typeId: 3)
class IncomeModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String source;

  @HiveField(2)
  late double amount;

  /// The date the income was received.
  @HiveField(3)
  late DateTime date;

  IncomeModel({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
  });
}
