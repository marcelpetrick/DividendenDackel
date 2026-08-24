import 'package:dividendendackel/app/localization/localized_material.dart';

/// Brand and semantic colours (Vision.md §24, §26, §27).
///
/// The palette is calm and low-contrast by intent: the vision explicitly rejects
/// flashing green and red, casino-like visual language and fake urgency. Colour
/// carries emphasis, never meaning on its own — every status that matters is
/// also expressed as an icon or a word, which §27 requires.
abstract final class AppColors {
  /// The Dackel's green, taken from the app icon.
  static const Color brandGreen = Color(0xFF12503F);

  /// Lighter brand green, used for large surfaces and the dark scheme seed.
  static const Color brandGreenLight = Color(0xFF1F7A63);

  /// The coin gold, reserved for dividend-related emphasis.
  static const Color coinGold = Color(0xFFE3A81B);

  /// Muted positive tone. Deliberately not a vivid green.
  static const Color positiveLight = Color(0xFF2E6B4F);

  /// Muted positive tone for dark surfaces.
  static const Color positiveDark = Color(0xFF7FC8A4);

  /// Muted negative tone. Deliberately not a vivid red.
  static const Color negativeLight = Color(0xFF9A3B2E);

  /// Muted negative tone for dark surfaces.
  static const Color negativeDark = Color(0xFFE8A08F);

  /// Tone for estimated, unconfirmed values.
  static const Color estimateLight = Color(0xFF6B5E3A);

  /// Tone for estimated values on dark surfaces.
  static const Color estimateDark = Color(0xFFD8C48A);
}

/// Semantic colours resolved for the active theme.
///
/// Attached to [ThemeData] as an extension so widgets ask for meaning
/// ("this is an estimate") rather than picking a raw colour.
@immutable
final class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  /// Creates the semantic palette.
  const AppSemanticColors({
    required this.positive,
    required this.negative,
    required this.estimate,
    required this.accent,
  });

  /// Values that increased.
  final Color positive;

  /// Values that decreased.
  final Color negative;

  /// Values that are estimated rather than confirmed.
  final Color estimate;

  /// Dividend emphasis.
  final Color accent;

  /// The light-theme palette.
  static const AppSemanticColors light = AppSemanticColors(
    positive: AppColors.positiveLight,
    negative: AppColors.negativeLight,
    estimate: AppColors.estimateLight,
    accent: AppColors.brandGreen,
  );

  /// The dark-theme palette.
  static const AppSemanticColors dark = AppSemanticColors(
    positive: AppColors.positiveDark,
    negative: AppColors.negativeDark,
    estimate: AppColors.estimateDark,
    accent: AppColors.coinGold,
  );

  @override
  AppSemanticColors copyWith({
    Color? positive,
    Color? negative,
    Color? estimate,
    Color? accent,
  }) => AppSemanticColors(
    positive: positive ?? this.positive,
    negative: negative ?? this.negative,
    estimate: estimate ?? this.estimate,
    accent: accent ?? this.accent,
  );

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      estimate: Color.lerp(estimate, other.estimate, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

/// Reads the semantic palette from the active theme.
extension AppSemanticColorsOf on BuildContext {
  /// The semantic colours for the current theme.
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
