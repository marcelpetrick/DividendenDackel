import 'package:dividendendackel/app/localization/app_localizations.dart';
import 'package:flutter/material.dart' as material;

/// Drop-in text widget that resolves canonical English copy in the live locale.
class Text extends material.StatelessWidget {
  /// Creates localized plain text.
  const Text(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.translate = true,
  }) : textSpan = null,
       values = null;

  /// Creates localized text from a message pattern in [data] and its [values].
  ///
  /// The catalog is keyed by the pattern, so `Text.format('Line {line}', ...)`
  /// stays one translatable message for every line number.
  const Text.format(
    String this.data,
    Map<String, Object?> this.values, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.translate = true,
  }) : textSpan = null;

  /// Creates localized rich text. Text spans remain caller-owned.
  const Text.rich(
    material.InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.translate = true,
  }) : data = null,
       values = null;

  /// Canonical English plain text.
  final String? data;

  /// Rich text supplied by the caller.
  final material.InlineSpan? textSpan;

  /// Placeholder values for [Text.format]; null for a plain literal.
  final Map<String, Object?>? values;

  final material.TextStyle? style;
  final material.StrutStyle? strutStyle;
  final material.TextAlign? textAlign;
  final material.TextDirection? textDirection;
  final material.Locale? locale;
  final bool? softWrap;
  final material.TextOverflow? overflow;
  final material.TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final material.TextWidthBasis? textWidthBasis;
  final material.TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  /// Whether [data] is application copy. Disable for user/provider content.
  final bool translate;

  @override
  material.Widget build(material.BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String? source = data;
    final String? semantics = semanticsLabel;
    if (source != null) {
      final Map<String, Object?>? arguments = values;
      final String resolved = !translate
          ? source
          : arguments == null
          ? localizations.text(source)
          : localizations.format(source, arguments);
      return material.Text(
        resolved,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semantics == null
            ? null
            : localizations.text(semantics),
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return material.Text.rich(
      textSpan!,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semantics == null ? null : localizations.text(semantics),
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
