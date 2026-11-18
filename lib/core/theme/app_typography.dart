import 'package:flutter/material.dart';

/// Defines the application's typography scale by mapping custom text styles
/// to Flutter's standard [TextTheme] properties.
class AppTypography {
  const AppTypography._();

  static const String? fontFamily = null;

  // Sizes
  static const double displaySize = 44;
  static const double headingSize = 28;
  static const double subheadingSize = 18;
  static const double bodySize = 16;
  static const double captionSize = 13;

  // Weights
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: displaySize,
    fontWeight: bold,
    height: 1.1,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: headingSize,
    fontWeight: bold,
    height: 1.25,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: fontFamily,
    fontSize: subheadingSize,
    fontWeight: semiBold,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: bodySize,
    fontWeight: normal,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: bodySize,
    fontWeight: semiBold,
    height: 1.5,
  );

  static const TextStyle bodyItalic = TextStyle(
    fontFamily: fontFamily,
    fontSize: bodySize,
    fontWeight: normal,
    fontStyle: FontStyle.italic,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: captionSize,
    fontWeight: normal,
    height: 1.4,
  );

  static const TextStyle captionItalic = TextStyle(
    fontFamily: fontFamily,
    fontSize: captionSize,
    fontWeight: normal,
    fontStyle: FontStyle.italic,
    height: 1.4,
  );

  /// Theme.of(context).textTheme calls pick these sizes up automatically.
  static const TextTheme textTheme = TextTheme(
    displayMedium: display,
    headlineMedium: heading,
    titleMedium: subheading,
    titleSmall: bodyBold,
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: subheadingSize,
      fontWeight: normal,
      height: 1.5,
    ),
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: bodyBold,
  );
}