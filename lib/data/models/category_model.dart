import 'package:hive/hive.dart';

part 'category_model.g.dart';

/// Represents a spending category (e.g. Food, Shopping, Transport).
///
/// [typeId] 0 — must be unique across every @HiveType in the app.
///
/// [iconString] stores a simple key like "food" or "shopping" that the
/// UI layer maps to an actual IconData.  This avoids storing int codepoints
/// directly and keeps the model readable.
@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  /// A short string key used to look up the icon in the UI.
  /// e.g. "food", "shopping", "utilities", "transport", "entertainment"
  @HiveField(2)
  late String iconString;

  /// True for the 5 app-bundled categories; false for user-created ones.
  /// Default categories cannot be deleted by the user.
  @HiveField(3)
  late bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconString,
    required this.isDefault,
  });
}
