import 'package:flutter/material.dart';

/// Laapak Brand Colors
/// 
/// This color system strictly follows Laapak Brand Guidelines.
/// No additional brand colors are allowed.
class LaapakColors {
  LaapakColors._();

  // ==================== Primary Brand Color ====================
  
  /// Laapak Green Gradient (Core Identity)
  /// 
  /// The primary brand expression of Laapak.
  /// Used for: Primary CTAs, Progress states, Key highlights, Brand moments
  /// 
  /// Rules:
  /// - Use gradients only in small, intentional areas
  /// - Never use gradient as full-screen background
  /// - Gradient direction should remain consistent across the app
  static const Color laapakGreenStart = Color(0xFF00C853); // Start of gradient
  static const Color laapakGreenEnd = Color(0xFF00E676); // End of gradient
  
  /// Laapak Green Gradient
  static const LinearGradient laapakGreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [laapakGreenStart, laapakGreenEnd],
  );
  
  /// Solid green variant (from brand gradient)
  /// Used for: Success states, Active warranty
  static const Color green = Color(0xFF00C853);
  
  // ==================== Base Colors ====================
  
  /// Pure White
  /// Primary background color for light mode
  static const Color white = Color(0xFFFFFFFF);
  
  /// Pure Black / Near Black
  /// Used for: Dark mode backgrounds, Emphasis sections, Premium moments
  static const Color black = Color(0xFF000000);
  static const Color nearBlack = Color(0xFF1A1A1A);
  
  // ==================== Neutral System ====================
  
  /// Dark Gray
  /// Primary text color (preferred over pure black for readability)
  static const Color darkGray = Color(0xFF2C2C2C);
  
  /// Medium Gray
  /// Secondary text, metadata, hints
  static const Color mediumGray = Color(0xFF6B6B6B);
  
  /// Light Gray
  /// Dividers, input borders, card backgrounds
  static const Color lightGray = Color(0xFFE0E0E0);
  
  /// Very Light Gray
  /// Card backgrounds, subtle dividers
  static const Color veryLightGray = Color(0xFFF5F5F5);
  
  // ==================== Functional States ====================
  
  /// Green (Solid Variant)
  /// Success states, Warranty active, Confirmed actions
  static const Color success = green;
  
  /// Yellow-Green / Amber (Muted)
  /// Near-expiry warnings, Requires attention (non-critical)
  static const Color warning = Color(0xFFFFB300);
  
  /// Red (Very Limited Use)
  /// Critical errors only, Warranty expired
  static const Color error = Color(0xFFD32F2F);
  
  // ==================== Semantic Colors ====================
  
  /// Primary color for the app
  static const Color primary = laapakGreenStart;
  
  /// Secondary color (neutral)
  static const Color secondary = mediumGray;
  
  /// Background color
  static const Color background = white;
  
  /// Surface color (for cards, etc.)
  static const Color surface = white;
  
  /// Surface variant (for subtle backgrounds)
  static const Color surfaceVariant = veryLightGray;
  
  /// Text colors
  static const Color textPrimary = darkGray;
  static const Color textSecondary = mediumGray;
  static const Color textDisabled = lightGray;
  
  /// Border colors
  static const Color border = lightGray;
  static const Color borderLight = veryLightGray;
  
  /// Divider color
  static const Color divider = lightGray;
  
  // ==================== Dark Mode Colors ====================
  
  /// Dark mode background
  static const Color darkBackground = nearBlack;
  
  /// Dark mode surface
  static const Color darkSurface = Color(0xFF2C2C2C);
  
  /// Dark mode text
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // ==================== Helper Methods ====================
  
  /// Get gradient for primary actions
  static LinearGradient getPrimaryGradient() {
    return laapakGreenGradient;
  }
  
  /// Get solid color from gradient (for non-gradient uses)
  static Color getPrimarySolid() {
    return laapakGreenStart;
  }
  
  /// Check if color is light (for determining text color)
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }
  
  /// Get appropriate text color for a background
  static Color getTextColorForBackground(Color backgroundColor) {
    return isLightColor(backgroundColor) ? textPrimary : darkTextPrimary;
  }
}

