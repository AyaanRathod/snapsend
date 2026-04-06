import 'package:flutter/foundation.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

/// Manages the category list shared across Add/Edit Expense forms,
/// the Category Management screen, and the Insights chart.
class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repo;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  CategoryViewModel({required CategoryRepository repository})
      : _repo = repository {
    _loadCategories();
  }

  // ── Public State ───────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// All categories: defaults first, then user-created (alphabetical).
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  /// Only the 5 default categories.
  List<CategoryModel> get defaultCategories =>
      _categories.where((c) => c.isDefault).toList();

  /// Only user-created categories.
  List<CategoryModel> get customCategories =>
      _categories.where((c) => !c.isDefault).toList();

  bool get hasCustomCategories => customCategories.isNotEmpty;

  // ── Look-ups ──────────────────────────────────────────────────────────

  /// Returns the [CategoryModel] for [id], or null if not found.
  CategoryModel? getCategoryById(String id) =>
      _repo.getCategoryById(id);

  /// Returns the display name for [categoryId], or "Unknown" if not found.
  String getNameForCategory(String categoryId) =>
      _repo.getCategoryById(categoryId)?.name ?? 'Unknown';

  /// Returns the iconString for [categoryId], or "other" as fallback.
  String getIconStringForCategory(String categoryId) =>
      _repo.getCategoryById(categoryId)?.iconString ?? 'other';

  // ── Commands ──────────────────────────────────────────────────────────

  /// Creates a new user-defined category.
  ///
  /// Returns null on success, or an error string to show in the UI.
  String? addCategory({required String name, required String iconString}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Category name cannot be empty.';
    if (trimmed.length > 30) return 'Name must be 30 characters or less.';
    if (_repo.categoryNameExists(trimmed)) {
      return '"$trimmed" already exists.';
    }
    _repo.addCategory(name: trimmed, iconString: iconString);
    _loadCategories();
    return null; // success
  }

  /// Deletes a user-created category.
  ///
  /// Returns null on success, or an error string (e.g. on default category).
  String? deleteCategory(String id) {
    final category = getCategoryById(id);
    if (category == null) return 'Category not found.';
    if (category.isDefault) {
      return 'Default categories cannot be deleted.';
    }
    try {
      _repo.deleteCategory(id);
      _loadCategories();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Private ───────────────────────────────────────────────────────────

  void _loadCategories() {
    _isLoading = true;
    _categories = _repo.getAllCategories();
    _isLoading = false;
    notifyListeners();
  }
}
