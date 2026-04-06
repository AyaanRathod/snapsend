import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Maps a category's [iconString] key to a real Material [IconData].
///
/// Add new entries here whenever a user creates a custom category with
/// a new icon key.  The [defaultIcon] is returned for unrecognized keys.
abstract final class CategoryIcons {
  CategoryIcons._();

  static const IconData defaultIcon = Icons.category_rounded;

  static const Map<String, IconData> _map = {
    'food': Icons.restaurant_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'utilities': Icons.bolt_rounded,
    'transport': Icons.directions_car_rounded,
    'entertainment': Icons.movie_filter_rounded,
    'health': Icons.favorite_rounded,
    'education': Icons.menu_book_rounded,
    'travel': Icons.flight_rounded,
    'home': Icons.home_rounded,
    'fitness': Icons.fitness_center_rounded,
    'beauty': Icons.spa_rounded,
    'coffee': Icons.local_cafe_rounded,
    'gaming': Icons.sports_esports_rounded,
    'gifts': Icons.card_giftcard_rounded,
    'pets': Icons.pets_rounded,
    'other': Icons.more_horiz_rounded,
  };

  /// Returns the [IconData] for [key], or [defaultIcon] if not found.
  static IconData forKey(String key) => _map[key] ?? defaultIcon;

  /// The full icon picker grid — shown when creating a custom category.
  /// Returns every available (key, icon) pair.
  static List<MapEntry<String, IconData>> get allOptions =>
      _map.entries.toList();

  // ── Category accent colors ──────────────────────────────────────────────
  // Each category gets a unique accent used on icon backgrounds / badges.
  static const Map<String, Color> _colors = {
    'food': Color(0xFFFFA726),
    'shopping': Color(0xFFEC407A),
    'utilities': Color(0xFF42A5F5),
    'transport': Color(0xFF26A69A),
    'entertainment': Color(0xFFAB47BC),
    'health': Color(0xFFEF5350),
    'education': Color(0xFF5C6BC0),
    'travel': Color(0xFF29B6F6),
    'home': Color(0xFF8D6E63),
    'fitness': Color(0xFF66BB6A),
    'beauty': Color(0xFFFF7043),
    'coffee': Color(0xFF795548),
    'gaming': Color(0xFF7E57C2),
    'gifts': Color(0xFFFF80AB),
    'pets': Color(0xFFFFCA28),
    'other': Color(0xFF78909C),
  };

  /// Returns the accent [Color] for [key], or [AppColors.primary] if not found.
  static Color colorForKey(String key) =>
      _colors[key] ?? AppColors.primary;

  /// Returns a 10% opacity version of the accent — used as icon backgrounds.
  static Color backgroundColorForKey(String key) =>
      Color.fromRGBO(colorForKey(key).r.toInt(), colorForKey(key).g.toInt(), colorForKey(key).b.toInt(), 0.12);
}
