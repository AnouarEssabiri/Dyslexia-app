import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Premium Modern AI Assistant Theme Configuration
/// Inspired by Claude AI, ChatGPT Mobile, Linear, Notion, Perplexity AI
class ThemeConfig {
  // Primary Colors (Premium AI aesthetic - Warm orange/amber accent)
  static const Color primaryColor = Color(0xFFE07A5F); // Warm terracotta orange
  static const Color primaryLight = Color(0xFFEFA08B);
  static const Color primaryDark = Color(0xFFC45E42);
  static const Color primaryAccent = Color(0xFF3D5A80); // Complementary blue

  // Neutral Colors (Premium clean aesthetic)
  static const Color backgroundColor = Color(0xFFFEFEFE); // Pure white
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Very light gray
  static const Color borderColor = Color(0xFFE9ECEF); // Subtle border
  static const Color dividerColor = Color(0xFFDEE2E6); // Divider
  static const Color textPrimary = Color(0xFF212529); // Near black
  static const Color textSecondary = Color(0xFF6C757D); // Medium gray
  static const Color textTertiary = Color(0xFFADB5BD); // Light gray
  static const Color textDisabled = Color(0xFFDEE2E6); // Disabled

  // Semantic Colors
  static const Color successColor = Color(0xFF10B981); // Emerald green
  static const Color warningColor = Color(0xFFF59E0B); // Warm amber
  static const Color errorColor = Color(0xFFEF4444); // Soft red
  static const Color infoColor = Color(0xFF3B82F6); // Clear blue

  // Dark Mode (Premium dark aesthetic)
  static const Color darkBackground = Color(0xFF0A0A0A); // Deep black
  static const Color darkSurface = Color(0xFF141414); // Rich dark
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A); // Dark gray
  static const Color darkBorder = Color(0xFF2A2A2A); // Subtle border
  static const Color darkDivider = Color(0xFF333333); // Divider
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Pure white
  static const Color darkTextSecondary = Color(0xFFA0A0A0); // Light gray
  static const Color darkTextTertiary = Color(0xFF6B6B6B); // Medium gray
  static const Color darkTextDisabled = Color(0xFF404040); // Disabled

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Font Configuration (Dyslexia-friendly + Modern)
  static const String fontFamilyPrimary = 'OpenDyslexic'; // Dyslexia-friendly
  static const String fontFamilySecondary = 'SF Pro Display'; // Modern iOS
  static const String fontFamilyTertiary = 'Inter'; // Clean web

  // Typography (Modern scale)
  static const double fontSizeXSmall = 11.0;
  static const double fontSizeSmall = 13.0;
  static const double fontSizeMedium = 15.0;
  static const double fontSizeLarge = 17.0;
  static const double fontSizeXLarge = 19.0;
  static const double fontSizeXXLarge = 21.0;
  static const double fontSizeHeading3 = 23.0;
  static const double fontSizeHeading2 = 27.0;
  static const double fontSizeHeading1 = 31.0;

  // Line Height (Optimized for readability)
  static const double lineHeightTight = 1.2;
  static const double lineHeightSmall = 1.3;
  static const double lineHeightMedium = 1.5; // Default for body
  static const double lineHeightLarge = 1.7;
  static const double lineHeightXLarge = 1.9;

  // Letter Spacing (Modern tight spacing)
  static const double letterSpacingTight = -0.3;
  static const double letterSpacingSmall = -0.2;
  static const double letterSpacingNormal = -0.1;
  static const double letterSpacingWide = 0.0;
  static const double letterSpacingExtraWide = 0.2;

  // Spacing (8pt grid system)
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Border Radius (Premium rounded corners)
  static const double radiusXSmall = 6.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 28.0;
  static const double radiusFull = 9999.0; // Pill shape

  // Shadows (Premium soft shadows)
  static const BoxShadow shadowXSmall = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x10000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x15000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const BoxShadow shadowXLarge = BoxShadow(
    color: Color(0x20000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  // Glassmorphism effect (Premium)
  static BoxDecoration glassmorphismDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );

  static BoxDecoration darkGlassmorphismDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );

  // Build light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: spacingMedium,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: lineHeightSmall,
          letterSpacing: letterSpacingSmall,
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeHeading1,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: lineHeightTight,
          letterSpacing: letterSpacingTight,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeHeading2,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: lineHeightTight,
          letterSpacing: letterSpacingSmall,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeHeading3,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: lineHeightSmall,
          letterSpacing: letterSpacingSmall,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          color: textPrimary,
          height: lineHeightLarge,
          letterSpacing: letterSpacingNormal,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeSmall,
          color: textSecondary,
          height: lineHeightLarge,
          letterSpacing: letterSpacingNormal,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          color: textTertiary,
          height: lineHeightMedium,
          letterSpacing: letterSpacingWide,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: surfaceColor,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: surfaceColor,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w600,
          color: surfaceColor,
          height: lineHeightMedium,
          letterSpacing: letterSpacingNormal,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          color: textTertiary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
            letterSpacing: letterSpacingNormal,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
            letterSpacing: letterSpacingNormal,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: borderColor, width: 1),
          padding: EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
            letterSpacing: letterSpacingNormal,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: spacingMedium,
      ),
    );
  }

  // Build dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      dividerColor: darkDivider,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: spacingMedium,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: lineHeightSmall,
          letterSpacing: letterSpacingSmall,
        ),
        iconTheme: IconThemeData(
          color: darkTextPrimary,
          size: 24,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryLight,
        unselectedItemColor: darkTextTertiary,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeHeading1,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          height: lineHeightTight,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeHeading2,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          height: lineHeightTight,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeHeading3,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          height: lineHeightSmall,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: lineHeightMedium,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: lineHeightMedium,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: lineHeightMedium,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: lineHeightMedium,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: lineHeightMedium,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          color: darkTextPrimary,
          height: lineHeightLarge,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeSmall,
          color: darkTextSecondary,
          height: lineHeightLarge,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          color: darkTextTertiary,
          height: lineHeightMedium,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: darkBackground,
          height: lineHeightMedium,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: darkBackground,
          height: lineHeightMedium,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w600,
          color: darkBackground,
          height: lineHeightMedium,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: primaryColor,
        surface: darkSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: fontSizeMedium,
          color: darkTextTertiary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: BorderSide(color: darkBorder, width: 1),
          padding: EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: spacingMedium,
      ),
    );
  }
}

/// Theme Provider - allows switching between light/dark modes
final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() {
    return ThemeConfig.lightTheme;
  }

  void toggleTheme() {
    final isDark = state.brightness == Brightness.dark;
    if (isDark) {
      state = ThemeConfig.lightTheme;
    } else {
      state = ThemeConfig.darkTheme;
    }
  }

  void setLightTheme() {
    state = ThemeConfig.lightTheme;
  }

  void setDarkTheme() {
    state = ThemeConfig.darkTheme;
  }
}
