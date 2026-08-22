import 'package:dividendendackel/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Light and dark themes (Vision.md §24, §26).
///
/// Both are generated from the brand seed so the two stay in step, and both are
/// built for the tone the vision asks for: calm, legible and trustworthy rather
/// than dense or urgent.
abstract final class AppTheme {
  /// Corner radius used by cards and surfaces.
  static const double cardRadius = 16;

  /// Standard spacing unit.
  static const double space = 8;

  /// The light theme.
  static ThemeData light() => _build(Brightness.light);

  /// The dark theme.
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandGreen,
      brightness: brightness,
    );
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // A visible focus ring is required for keyboard navigation on Linux
      // (Vision.md §27).
      focusColor: scheme.primary.withValues(alpha: 0.24),
      extensions: <ThemeExtension<AppSemanticColors>>[
        isDark ? AppSemanticColors.dark : AppSemanticColors.light,
      ],
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        // Labels always visible: an icon alone is not a sufficient cue.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: space * 2),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius / 2),
        ),
      ),
    );
  }
}
