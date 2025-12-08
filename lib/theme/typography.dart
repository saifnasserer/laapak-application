import 'package:flutter/material.dart';

/// Laapak Typography System
///
/// Typography must strictly follow Laapak Brand Guidelines.
///
/// Arabic (Primary Language): Noto Sans Arabic
/// English (Secondary): BDO Grotesk
class LaapakTypography {
  LaapakTypography._();

  // ==================== Font Families ====================

  /// Arabic font family (Primary)
  /// Matches the font family name declared in pubspec.yaml
  static const String arabicFontFamily = 'NotoSansArabic';

  /// English font family (Secondary)
  /// Note: Update this when BDO Grotesk fonts are added
  static const String englishFontFamily = 'BDO Grotesk';

  // ==================== Font Weights ====================

  /// Regular weight (Body text)
  static const FontWeight regular = FontWeight.w400;

  /// Medium weight (Labels)
  static const FontWeight medium = FontWeight.w500;

  /// Semi-Bold weight (Headings)
  static const FontWeight semiBold = FontWeight.w600;

  /// Bold weight (Critical highlights only)
  static const FontWeight bold = FontWeight.w700;

  // ==================== Text Styles ====================

  /// Display Large (for hero text, rarely used)
  static TextStyle displayLarge({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 32,
      fontWeight: semiBold,
      height: 1.4,
      letterSpacing: -0.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Display Medium
  static TextStyle displayMedium({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 28,
      fontWeight: semiBold,
      height: 1.4,
      letterSpacing: -0.25,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Display Small
  static TextStyle displaySmall({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 24,
      fontWeight: semiBold,
      height: 1.4,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Headline Large
  static TextStyle headlineLarge({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 22,
      fontWeight: semiBold,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Headline Medium
  static TextStyle headlineMedium({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: semiBold,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Headline Small
  static TextStyle headlineSmall({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: semiBold,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Title Large
  static TextStyle titleLarge({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: medium,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Title Medium
  static TextStyle titleMedium({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: medium,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Title Small
  static TextStyle titleSmall({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: medium,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Body Large
  static TextStyle bodyLarge({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: regular,
      height: 1.6, // Comfortable spacing for long Arabic reading
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Body Medium (Default body text)
  static TextStyle bodyMedium({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: regular,
      height: 1.6, // Comfortable spacing for long Arabic reading
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Body Small
  static TextStyle bodySmall({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: regular,
      height: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Label Large
  static TextStyle labelLarge({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: medium,
      height: 1.4,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Label Medium
  static TextStyle labelMedium({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: medium,
      height: 1.4,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Label Small
  static TextStyle labelSmall({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: medium,
      height: 1.4,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  // ==================== Specialized Text Styles ====================

  /// Button text style
  static TextStyle button({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: medium,
      height: 1.2,
      letterSpacing: 0.5,
      color: color ?? Colors.white,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Caption text (for metadata, timestamps, etc.)
  static TextStyle caption({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: regular,
      height: 1.4,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  /// Overline text (for labels, tags)
  static TextStyle overline({Color? color, String? fontFamily}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: medium,
      height: 1.4,
      letterSpacing: 1.5,
      color: color,
      fontFamily: fontFamily ?? arabicFontFamily,
    );
  }

  // ==================== English Text Styles ====================

  /// English text style (for technical terms, serial numbers, model names)
  static TextStyle english({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? regular,
      height: 1.5,
      color: color,
      fontFamily: englishFontFamily,
    );
  }
}
