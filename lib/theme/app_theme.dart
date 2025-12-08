import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Laapak App Theme
/// 
/// Main theme configuration following Laapak Brand Guidelines.
/// Supports both light and dark modes with RTL support for Arabic.
class LaapakTheme {
  LaapakTheme._();

  // ==================== Light Theme ====================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: LaapakColors.primary,
        secondary: LaapakColors.secondary,
        surface: LaapakColors.surface,
        background: LaapakColors.background,
        error: LaapakColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LaapakColors.textPrimary,
        onBackground: LaapakColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: LaapakColors.background,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: LaapakColors.background,
        foregroundColor: LaapakColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: LaapakTypography.titleLarge(
          color: LaapakColors.textPrimary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: LaapakColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Soft radius (12-16px)
          side: BorderSide(
            color: LaapakColors.borderLight,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LaapakColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LaapakTypography.button(),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LaapakColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LaapakTypography.button(
            color: LaapakColors.textPrimary,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LaapakColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: LaapakColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LaapakTypography.button(
            color: LaapakColors.textPrimary,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LaapakColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: LaapakTypography.bodyMedium(
          color: LaapakColors.textSecondary,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: LaapakTypography.displayLarge(),
        displayMedium: LaapakTypography.displayMedium(),
        displaySmall: LaapakTypography.displaySmall(),
        headlineLarge: LaapakTypography.headlineLarge(),
        headlineMedium: LaapakTypography.headlineMedium(),
        headlineSmall: LaapakTypography.headlineSmall(),
        titleLarge: LaapakTypography.titleLarge(),
        titleMedium: LaapakTypography.titleMedium(),
        titleSmall: LaapakTypography.titleSmall(),
        bodyLarge: LaapakTypography.bodyLarge(),
        bodyMedium: LaapakTypography.bodyMedium(),
        bodySmall: LaapakTypography.bodySmall(),
        labelLarge: LaapakTypography.labelLarge(),
        labelMedium: LaapakTypography.labelMedium(),
        labelSmall: LaapakTypography.labelSmall(),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: LaapakColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: LaapakColors.textPrimary,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: LaapakColors.surfaceVariant,
        labelStyle: LaapakTypography.labelMedium(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LaapakColors.surface,
        selectedItemColor: LaapakColors.primary,
        unselectedItemColor: LaapakColors.textSecondary,
        selectedLabelStyle: LaapakTypography.labelMedium(),
        unselectedLabelStyle: LaapakTypography.labelMedium(),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: LaapakColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: LaapakTypography.titleLarge(),
        contentTextStyle: LaapakTypography.bodyMedium(),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LaapakColors.darkGray,
        contentTextStyle: LaapakTypography.bodyMedium(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // ==================== Dark Theme ====================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: LaapakColors.primary,
        secondary: LaapakColors.secondary,
        surface: LaapakColors.darkSurface,
        background: LaapakColors.darkBackground,
        error: LaapakColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LaapakColors.darkTextPrimary,
        onBackground: LaapakColors.darkTextPrimary,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: LaapakColors.darkBackground,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: LaapakColors.darkBackground,
        foregroundColor: LaapakColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: LaapakTypography.titleLarge(
          color: LaapakColors.darkTextPrimary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: LaapakColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: LaapakColors.mediumGray.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LaapakColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LaapakTypography.button(),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LaapakColors.darkTextPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LaapakTypography.button(
            color: LaapakColors.darkTextPrimary,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LaapakColors.darkTextPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: LaapakColors.mediumGray.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LaapakTypography.button(
            color: LaapakColors.darkTextPrimary,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LaapakColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.mediumGray.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.mediumGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LaapakColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: LaapakTypography.bodyMedium(
          color: LaapakColors.darkTextSecondary,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: LaapakTypography.displayLarge(
          color: LaapakColors.darkTextPrimary,
        ),
        displayMedium: LaapakTypography.displayMedium(
          color: LaapakColors.darkTextPrimary,
        ),
        displaySmall: LaapakTypography.displaySmall(
          color: LaapakColors.darkTextPrimary,
        ),
        headlineLarge: LaapakTypography.headlineLarge(
          color: LaapakColors.darkTextPrimary,
        ),
        headlineMedium: LaapakTypography.headlineMedium(
          color: LaapakColors.darkTextPrimary,
        ),
        headlineSmall: LaapakTypography.headlineSmall(
          color: LaapakColors.darkTextPrimary,
        ),
        titleLarge: LaapakTypography.titleLarge(
          color: LaapakColors.darkTextPrimary,
        ),
        titleMedium: LaapakTypography.titleMedium(
          color: LaapakColors.darkTextPrimary,
        ),
        titleSmall: LaapakTypography.titleSmall(
          color: LaapakColors.darkTextPrimary,
        ),
        bodyLarge: LaapakTypography.bodyLarge(
          color: LaapakColors.darkTextPrimary,
        ),
        bodyMedium: LaapakTypography.bodyMedium(
          color: LaapakColors.darkTextPrimary,
        ),
        bodySmall: LaapakTypography.bodySmall(
          color: LaapakColors.darkTextSecondary,
        ),
        labelLarge: LaapakTypography.labelLarge(
          color: LaapakColors.darkTextPrimary,
        ),
        labelMedium: LaapakTypography.labelMedium(
          color: LaapakColors.darkTextPrimary,
        ),
        labelSmall: LaapakTypography.labelSmall(
          color: LaapakColors.darkTextSecondary,
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: LaapakColors.mediumGray.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: LaapakColors.darkTextPrimary,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: LaapakColors.darkSurface,
        labelStyle: LaapakTypography.labelMedium(
          color: LaapakColors.darkTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LaapakColors.darkSurface,
        selectedItemColor: LaapakColors.primary,
        unselectedItemColor: LaapakColors.darkTextSecondary,
        selectedLabelStyle: LaapakTypography.labelMedium(),
        unselectedLabelStyle: LaapakTypography.labelMedium(),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: LaapakColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: LaapakTypography.titleLarge(
          color: LaapakColors.darkTextPrimary,
        ),
        contentTextStyle: LaapakTypography.bodyMedium(
          color: LaapakColors.darkTextPrimary,
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LaapakColors.mediumGray,
        contentTextStyle: LaapakTypography.bodyMedium(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

