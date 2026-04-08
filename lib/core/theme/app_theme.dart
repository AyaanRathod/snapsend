import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  APP COLORS
//  Single source of truth for every color value used in the app.
//  ─ Light mode values are fully defined.
//  ─ Dark mode values are stubs — teammates: fill in the dark* constants.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppColors {
  AppColors._();

  // ── Brand / Accent ─────────────────────────────────────────────────────
  /// Vibrant electric blue — primary action color (buttons, FAB, progress).
  static const Color primary = Color(0xFF43D7B5);

  /// Pressed / darker tint of primary.
  static const Color primaryDark = Color(0xFF1FA386);

  /// Very light blue — used as primary container backgrounds.
  static const Color primaryContainer = Color(0xFFD9FFF5);

  // ── Backgrounds (Light Mode) ────────────────────────────────────────────
  /// Page/scaffold background — soft off-white, easy on the eyes.
  static const Color background = Color(0xFFF5F7FA);

  /// Card / sheet surface — crisp white.
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly tinted surface — used for input fills, secondary containers.
  static const Color surfaceVariant = Color(0xFFEEF1F8);

  // ── Text (Light Mode) ───────────────────────────────────────────────────
  /// Bold charcoal — primary headers, amounts, important labels.
  static const Color textPrimary = Color(0xFF1A1D2E);

  /// Muted gray — dates, subtitles, secondary info.
  static const Color textSecondary = Color(0xFF8E92A4);

  /// Very faint — disabled states, placeholders.
  static const Color textDisabled = Color(0xFFBEC2D0);

  // ── Semantic / Status ──────────────────────────────────────────────────
  /// Soft light green — "under budget", success, positive balance.
  static const Color success = Color(0xFF4ADE80);

  /// Tinted green background for success badges/chips.
  static const Color successContainer = Color(0xFFDCFCE7);

  /// Dark green text on successContainer.
  static const Color onSuccessContainer = Color(0xFF14532D);

  /// Amber — spending approaching the budget limit (80–99%).
  static const Color warning = Color(0xFFFBBF24);

  /// Tinted amber background.
  static const Color warningContainer = Color(0xFFFEF9C3);

  /// Soft red — over-budget state.
  static const Color error = Color(0xFFF87171);

  /// Tinted red background.
  static const Color errorContainer = Color(0xFFFEE2E2);

  /// Dark red text on errorContainer.
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  // ── Structural ─────────────────────────────────────────────────────────
  /// Hairline divider color.
  static const Color divider = Color(0xFFEAEDF4);

  /// Shadow color for cards — very transparent so shadows read as "soft".
  static const Color cardShadow = Color(0x1A4B6097);

  // ── Dark Mode (STUB — teammates: replace Color(0xFF000000) values) ──────
  static const Color darkBackground = Color(0xFF0A0D14);
  static const Color darkSurface = Color(0xFF131A22);
  static const Color darkSurfaceVariant = Color(0xFF1A2230);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFF98A2B3);
  static const Color darkDivider = Color(0xFF263041);
  static const Color darkPrimaryContainer = Color(0xFF163D38);
}

// ═══════════════════════════════════════════════════════════════════════════
//  APP RADIUS
//  Named corner-radius tokens — use these instead of raw doubles so a
//  global design decision is a one-line change.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppRadius {
  AppRadius._();

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;  // Default card radius
  static const double xl = 28.0;  // Bottom sheets, modals
  static const double pill = 100.0; // Chips, badges
}

// ═══════════════════════════════════════════════════════════════════════════
//  APP SHADOWS
//  Pre-built BoxShadow lists so every card has identical depth.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppShadows {
  AppShadows._();

  /// Subtle card shadow — almost invisible but gives physical depth.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.cardShadow,
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Slightly more prominent shadow — used for modals and FABs.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.cardShadow,
      blurRadius: 32,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
//  APP TEXT STYLES
//  Named typography tokens.  These are raw TextStyle objects — they do NOT
//  include color so they can be used on any background.  Apply color at the
//  call site (or use copyWith).
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppTextStyles {
  AppTextStyles._();

  // ── Display ────────────────────────────────────────────────────────────
  /// Hero numbers — total balance, monthly spend.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  // ── Headline ───────────────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  /// Screen titles, section headers.
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // ── Title ──────────────────────────────────────────────────────────────
  /// Card title, list item primary text.
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // ── Body ───────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Dates, metadata, secondary labels.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ── Label ──────────────────────────────────────────────────────────────
  /// Button text, chip labels.
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // ── Amount ─────────────────────────────────────────────────────────────
  /// Expense amounts on list tiles — monospaced-feel bold digits.
  static const TextStyle amountLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  APP THEME
//  The single entry point used in MaterialApp.
//  Both themes are full ThemeData objects — teammates just need to update
//  the dark* color constants in AppColors above to complete dark mode.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        scaffoldBackgroundColor: AppColors.background,

        // ── App Bar ────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),

        // ── Card ───────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── Elevated Button ────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── Text Button ────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),

        // ── Outlined Button ────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── FAB ────────────────────────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          extendedTextStyle: AppTextStyles.labelLarge,
        ),

        // ── Input Decoration ───────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          labelStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textDisabled),
          errorStyle: AppTextStyles.bodySmall
              .copyWith(color: AppColors.error),
        ),

        // ── Bottom Navigation Bar ──────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(
                color: AppColors.textSecondary, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primary);
            }
            return AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondary);
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),

        // ── Chip ──────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          selectedColor: AppColors.primaryContainer,
          disabledColor: AppColors.surfaceVariant,
          labelStyle: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textPrimary),
          secondaryLabelStyle: AppTextStyles.labelMedium
              .copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        // ── Dialog ────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          titleTextStyle: AppTextStyles.headlineSmall
              .copyWith(color: AppColors.textPrimary),
          contentTextStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),

        // ── Bottom Sheet ──────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.textDisabled,
        ),

        // ── List Tile ─────────────────────────────────────────────────────
        listTileTheme: ListTileThemeData(
          tileColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          titleTextStyle: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textPrimary),
          subtitleTextStyle: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondary),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── Progress Indicator ────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primaryContainer,
          circularTrackColor: AppColors.primaryContainer,
        ),

        // ── Snack Bar ─────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: AppTextStyles.bodyMedium
              .copyWith(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 4,
        ),

        // ── Switch ────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor:
              WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppColors.textDisabled;
          }),
          trackColor:
              WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.surfaceVariant;
          }),
        ),

        // ── Text Theme ────────────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  //  DARK THEME  — STUB
  //  Structure is complete. Teammates: update AppColors.dark* constants
  //  above to match the design spec.  No structural changes needed here.
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        scaffoldBackgroundColor: AppColors.darkBackground,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
            letterSpacing: -0.3,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          margin: EdgeInsets.zero,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.darkTextSecondary),
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.darkTextSecondary),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          indicatorColor: AppColors.darkPrimaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(
                color: AppColors.darkTextSecondary, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primary);
            }
            return AppTextStyles.labelMedium
                .copyWith(color: AppColors.darkTextSecondary);
          }),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
          space: 1,
        ),

        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ).apply(
          bodyColor: AppColors.darkTextPrimary,
          displayColor: AppColors.darkTextPrimary,
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  //  PRIVATE COLOUR SCHEMES
  // ─────────────────────────────────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary (electric blue)
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    // Secondary (success green)
    secondary: AppColors.success,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.successContainer,
    onSecondaryContainer: AppColors.onSuccessContainer,
    // Error (soft red)
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    // Surface / background
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.divider,
    outlineVariant: AppColors.divider,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: Colors.white,
    secondary: AppColors.success,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.successContainer,
    onSecondaryContainer: AppColors.onSuccessContainer,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkDivider,
    outlineVariant: AppColors.darkDivider,
  );
}
