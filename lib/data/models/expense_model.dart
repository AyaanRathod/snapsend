import 'package:hive/hive.dart';

part 'expense_model.g.dart';

/// Represents a single spending transaction.
///
/// [typeId] 1 — must be unique across every @HiveType in the app.
///
/// [isScanned] lets the UI show a receipt icon badge on list tiles.
/// [receiptImagePath] is the absolute file path to the auto-cropped image
/// saved after a successful ML Kit Document Scanner session.  It is nullable
/// because manually-entered expenses have no associated image.
@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late String merchant;

  /// Stored as UTC to avoid daylight-saving bugs when filtering by month.
  @HiveField(3)
  late DateTime date;

  /// Foreign key → CategoryModel.id stored in the categories Hive box.
  @HiveField(4)
  late String categoryId;

  /// Whether this expense originated from a receipt scan (vs. manual entry).
  @HiveField(5)
  late bool isScanned;

  /// Absolute path to the saved receipt image on-device.
  /// Null when isScanned == false or if the image file was deleted externally.
  @HiveField(6)
  String? receiptImagePath;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.date,
    required this.categoryId,
    required this.isScanned,
    this.receiptImagePath,
  });
}
