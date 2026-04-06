import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../services/hive_service.dart';

const _uuid = Uuid();

/// Single Source of Truth (SSOT) for all [CategoryModel] data.
///
/// Responsibilities:
///   - Seeds the 5 default categories on first launch via [ensureDefaults()].
///   - Provides CRUD for user-created custom categories.
///   - Prevents deletion of default categories.
class CategoryRepository {
  final HiveService _service;

  CategoryRepository(this._service);

  // ── Initialization ────────────────────────────────────────────────────

  /// Seeds the 5 built-in categories if the box is empty.
  ///
  /// Call this once from [main()] right after opening Hive boxes.
  /// It is idempotent — safe to call multiple times.
  void ensureDefaults() {
    if (_service.categories.isNotEmpty) return;

    final defaults = [
      CategoryModel(
        id: _uuid.v4(),
        name: 'Food',
        iconString: 'food',
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Shopping',
        iconString: 'shopping',
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Utilities',
        iconString: 'utilities',
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transport',
        iconString: 'transport',
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Entertainment',
        iconString: 'entertainment',
        isDefault: true,
      ),
    ];

    for (final category in defaults) {
      _service.categories.put(category.id, category);
    }
  }

  // ── Read Operations ───────────────────────────────────────────────────

  /// All categories: defaults first, then user-created (alphabetical).
  List<CategoryModel> getAllCategories() {
    final all = _service.categories.values.toList();
    all.sort((a, b) {
      // Defaults always come first.
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return a.name.compareTo(b.name);
    });
    return all;
  }

  /// Finds a category by its [id].  Returns null if not found.
  CategoryModel? getCategoryById(String id) {
    return _service.categories.get(id);
  }

  /// Finds a category by its [name] (case-insensitive).  Returns null if not found.
  CategoryModel? getCategoryByName(String name) {
    try {
      return _service.categories.values.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Write Operations ──────────────────────────────────────────────────

  /// Persists a new user-created category.
  ///
  /// Generates a fresh UUID and marks [isDefault] = false automatically —
  /// callers don't need to set those fields.
  void addCategory({required String name, required String iconString}) {
    final category = CategoryModel(
      id: _uuid.v4(),
      name: name,
      iconString: iconString,
      isDefault: false,
    );
    _service.categories.put(category.id, category);
  }

  /// Deletes a user-created category by [id].
  ///
  /// Throws [StateError] if you attempt to delete a default category —
  /// the UI layer should gate this with [CategoryModel.isDefault] first.
  void deleteCategory(String id) {
    final category = getCategoryById(id);
    if (category == null) return;

    if (category.isDefault) {
      throw StateError(
        'Cannot delete a default category. Use the UI to hide it instead.',
      );
    }
    _service.categories.delete(id);
  }

  /// Returns true if a non-default category with [name] already exists
  /// (case-insensitive).  Used to prevent duplicate names.
  bool categoryNameExists(String name) {
    return _service.categories.values.any(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
  }
}
