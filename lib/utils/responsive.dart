import 'package:flutter/material.dart';

/// Responsive Sizing Utilities
///
/// Based on 8px spacing system as per Laapak Design Guidelines.
/// Provides consistent spacing and sizing across the app.
class Responsive {
  Responsive._();

  // ==================== Base Spacing Unit ====================

  /// Base spacing unit (8px)
  /// All spacing values should be multiples of this unit
  static const double baseUnit = 8.0;

  // ==================== Spacing Scale ====================

  /// 4px spacing (0.5x base unit)
  static const double xs = 4.0;

  /// 8px spacing (1x base unit)
  static const double sm = 8.0;

  /// 16px spacing (2x base unit)
  static const double md = 16.0;

  /// 24px spacing (3x base unit)
  static const double lg = 24.0;

  /// 32px spacing (4x base unit)
  static const double xl = 32.0;

  /// 40px spacing (5x base unit)
  static const double xxl = 40.0;

  /// 48px spacing (6x base unit)
  static const double xxxl = 48.0;

  /// 64px spacing (8x base unit)
  static const double huge = 64.0;

  // ==================== Screen Padding ====================

  /// Standard horizontal screen padding
  static const double screenPaddingHorizontal = md; // 16px

  /// Standard vertical screen padding
  static const double screenPaddingVertical = md; // 16px

  /// Standard screen padding (all sides)
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  /// Screen padding horizontal only
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(horizontal: md);

  /// Screen padding vertical only
  static const EdgeInsets screenPaddingV = EdgeInsets.symmetric(vertical: md);

  // ==================== Card Spacing ====================

  /// Card padding
  static const double cardPadding = md; // 16px

  /// Card padding as EdgeInsets
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(md);

  /// Card margin
  static const double cardMargin = md; // 16px

  /// Card margin as EdgeInsets
  static const EdgeInsets cardMarginInsets = EdgeInsets.all(md);

  /// Card border radius (12-16px as per guidelines)
  static const double cardRadius = 14.0;

  // ==================== Button Sizing ====================

  /// Button height (minimum touch target: 44px)
  static const double buttonHeight = 48.0;

  /// Button height small
  static const double buttonHeightSmall = 40.0;

  /// Button height large
  static const double buttonHeightLarge = 56.0;

  /// Button horizontal padding
  static const double buttonPaddingHorizontal = lg; // 24px

  /// Button vertical padding
  static const double buttonPaddingVertical = md; // 16px

  /// Button padding as EdgeInsets
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );

  /// Button border radius
  static const double buttonRadius = 12.0;

  // ==================== Input Field Sizing ====================

  /// Input field height
  static const double inputHeight = 56.0;

  /// Input field height small
  static const double inputHeightSmall = 48.0;

  /// Input field padding
  static const double inputPadding = md; // 16px

  /// Input field padding as EdgeInsets
  static const EdgeInsets inputPaddingInsets = EdgeInsets.all(md);

  /// Input field border radius
  static const double inputRadius = 12.0;

  // ==================== Icon Sizing ====================

  /// Icon size small
  static const double iconSizeSmall = 16.0;

  /// Icon size medium (default)
  static const double iconSizeMedium = 24.0;

  /// Icon size large
  static const double iconSizeLarge = 32.0;

  /// Icon size extra large
  static const double iconSizeXLarge = 48.0;

  // ==================== Avatar Sizing ====================

  /// Avatar size small
  static const double avatarSizeSmall = 32.0;

  /// Avatar size medium
  static const double avatarSizeMedium = 40.0;

  /// Avatar size large
  static const double avatarSizeLarge = 56.0;

  /// Avatar size extra large
  static const double avatarSizeXLarge = 80.0;

  // ==================== List Item Sizing ====================

  /// List item height
  static const double listItemHeight = 64.0;

  /// List item height small
  static const double listItemHeightSmall = 48.0;

  /// List item height large
  static const double listItemHeightLarge = 80.0;

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // ==================== App Bar Sizing ====================

  /// App bar height
  static const double appBarHeight = 56.0;

  /// App bar elevation
  static const double appBarElevation = 0.0;

  // ==================== Bottom Navigation Bar ====================

  /// Bottom navigation bar height
  static const double bottomNavBarHeight = 64.0;

  // ==================== Helper Methods ====================

  /// Get spacing value as multiple of base unit
  static double spacing(double multiplier) {
    return baseUnit * multiplier;
  }

  /// Get spacing as EdgeInsets (all sides)
  static EdgeInsets spacingInsets(double multiplier) {
    final value = spacing(multiplier);
    return EdgeInsets.all(value);
  }

  /// Get spacing as EdgeInsets (horizontal only)
  static EdgeInsets spacingH(double multiplier) {
    final value = spacing(multiplier);
    return EdgeInsets.symmetric(horizontal: value);
  }

  /// Get spacing as EdgeInsets (vertical only)
  static EdgeInsets spacingV(double multiplier) {
    final value = spacing(multiplier);
    return EdgeInsets.symmetric(vertical: value);
  }

  /// Get spacing as EdgeInsets (custom)
  static EdgeInsets spacingCustom({
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (top != null || bottom != null || left != null || right != null) {
      return EdgeInsets.only(
        top: spacing(top ?? 0),
        bottom: spacing(bottom ?? 0),
        left: spacing(left ?? 0),
        right: spacing(right ?? 0),
      );
    }
    return EdgeInsets.symmetric(
      horizontal: spacing(horizontal ?? 0),
      vertical: spacing(vertical ?? 0),
    );
  }

  // ==================== Responsive Breakpoints ====================

  /// Small screen breakpoint (phones)
  static const double breakpointSmall = 600.0;

  /// Medium screen breakpoint (tablets)
  static const double breakpointMedium = 960.0;

  /// Large screen breakpoint (desktop)
  static const double breakpointLarge = 1280.0;

  // ==================== Responsive Helpers ====================

  /// Check if screen is small (phone)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointSmall;
  }

  /// Check if screen is medium (tablet)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointSmall && width < breakpointMedium;
  }

  /// Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointMedium;
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T small,
    T? medium,
    T? large,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isLargeScreen(context)) {
      return large ?? medium ?? small;
    } else {
      return medium ?? small;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue<EdgeInsets>(
      context: context,
      small: screenPadding,
      medium: EdgeInsets.all(lg),
      large: EdgeInsets.all(xl),
    );
  }

  /// Get responsive font size multiplier
  static double responsiveFontMultiplier(BuildContext context) {
    return responsiveValue<double>(
      context: context,
      small: 1.0,
      medium: 1.1,
      large: 1.2,
    );
  }

  // ==================== Safe Area Helpers ====================

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  /// Get safe area top padding
  static double safeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get safe area bottom padding
  static double safeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // ==================== Screen Dimensions ====================

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get available height (excluding app bar, safe areas, etc.)
  static double availableHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  /// Get available width
  static double availableWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width -
        mediaQuery.padding.left -
        mediaQuery.padding.right;
  }
}
