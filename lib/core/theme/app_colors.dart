import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  APP COLORS  —  Single source of truth for every color in the app.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppColors {
  AppColors._();

  // ── Brand / Accent ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF43D7B5);
  static const Color primaryDark = Color(0xFF1FA386);
  static const Color primaryContainer = Color(0xFFD9FFF5);

  // ── Backgrounds (Light Mode) ────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF1F8);

  // ── Text (Light Mode) ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF8E92A4);
  static const Color textDisabled = Color(0xFFBEC2D0);

  // ── Semantic / Status ──────────────────────────────────────────────────
  static const Color success = Color(0xFF4ADE80);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF14532D);

  static const Color warning = Color(0xFFFBBF24);
  static const Color warningContainer = Color(0xFFFEF9C3);

  static const Color error = Color(0xFFF87171);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  // ── Structural ─────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEAEDF4);
  static const Color cardShadow = Color(0x1A4B6097);

  // ── Dark Mode ──────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0D14);
  static const Color darkSurface = Color(0xFF131A22);
  static const Color darkSurfaceVariant = Color(0xFF1A2230);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFF98A2B3);
  static const Color darkDivider = Color(0xFF263041);
  static const Color darkPrimaryContainer = Color(0xFF163D38);
}
