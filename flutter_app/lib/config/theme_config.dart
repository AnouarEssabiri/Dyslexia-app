import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../presentation/providers/settings_provider.dart';

/// Premium Modern AI Assistant Theme Configuration
/// Inspired by Claude AI, ChatGPT Mobile, Linear, Notion, Perplexity AI
class ThemeConfig {
  // Primary Colors (Premium AI aesthetic - Deep Indigo & Violet)
  static const Color primaryColor = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4338CA); // Indigo 700
  static const Color primaryAccent = Color(0xFFA5B4FC); // Indigo 300

  // Secondary Colors (Soft Violet/Purple for gradients)
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet 500
  static const Color secondaryLight = Color(0xFFA78BFA); // Violet 400

  // Neutral Colors (Premium clean aesthetic - Slate/Gray)
  static const Color backgroundColor = Color(0xFFF9FAFB); // Slate 50
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray 100
  static const Color borderColor = Color(0xFFE5E7EB); // Gray 200
  static const Color dividerColor = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray 300

  // Semantic Colors
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color infoColor = Color(0xFF3B82F6); // Blue 500

  // Dark Mode (Premium dark aesthetic - Deep Zinc/Black)
  static const Color darkBackground = Color(0xFF09090B); // Zinc 950
  static const Color darkSurface = Color(0xFF18181B); // Zinc 900
  static const Color darkSurfaceVariant = Color(0xFF27272A); // Zinc 800
  static const Color darkBorder = Color(0xFF27272A); // Zinc 800
  static const Color darkDivider = Color(0xFF1E1E1E); // Custom deep dark
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Zinc 50
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color darkTextTertiary = Color(0xFF71717A); // Zinc 500
  static const Color darkTextDisabled = Color(0xFF3F3F46); // Zinc 700

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Font Configuration
  static const String dyslexiaFont = 'OpenDyslexic';
  static const String fontFamilyPrimary = dyslexiaFont;
  
  // Custom Typography Settings for Dyslexia
  static const double lineHeightXLarge = 1.8;
  static const double letterSpacingWide = 1.2;
  
  static TextStyle getPrimaryTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    bool? useDyslexiaFont,
  }) {
    if (useDyslexiaFont == true) {
      return TextStyle(
        fontFamily: dyslexiaFont,
        fontFamilyFallback: const ['sans-serif'],
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height ?? 1.4,
        letterSpacing: letterSpacing,
      );
    }
    
    // If useDyslexiaFont is explicitly false, use GoogleFonts.inter
    if (useDyslexiaFont == false) {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing ?? -0.2,
      );
    }

    // Default: Return a TextStyle without a fontFamily so it inherits from ThemeData
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Spacing (Modern tight grid)
  static const double spacingXXSmall = 2;
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;
  static const double spacingXXLarge = 48;

  // Border Radius (Premium ultra-rounded)
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 18;
  static const double radiusXLarge = 24;
  static const double radiusXXLarge = 32;
  static const double radiusFull = 9999;

  // Shadows (Soft, layered shadows)
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Build light theme
  static ThemeData buildTheme({required bool isDark, required bool useDyslexiaFont}) {
    final color = isDark ? darkTextPrimary : textPrimary;
    final bgColor = isDark ? darkBackground : backgroundColor;
    final surfColor = isDark ? darkSurface : surfaceColor;
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: useDyslexiaFont ? dyslexiaFont : GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfColor,
        background: bgColor,
        error: errorColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: _buildTextTheme(color, useDyslexiaFont),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: color, size: 22),
        titleTextStyle: getPrimaryTextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: color,
          useDyslexiaFont: useDyslexiaFont,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: isDark ? darkBorder : borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: getPrimaryTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            useDyslexiaFont: useDyslexiaFont,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurfaceVariant : surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: getPrimaryTextStyle(
          fontSize: 15,
          color: isDark ? darkTextTertiary : textTertiary,
          useDyslexiaFont: useDyslexiaFont,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color color, bool useDyslexiaFont) => TextTheme(
      displayLarge: getPrimaryTextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color, useDyslexiaFont: useDyslexiaFont),
      displayMedium: getPrimaryTextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, useDyslexiaFont: useDyslexiaFont),
      displaySmall: getPrimaryTextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, useDyslexiaFont: useDyslexiaFont),
      headlineLarge: getPrimaryTextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
      headlineMedium: getPrimaryTextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
      headlineSmall: getPrimaryTextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
      titleLarge: getPrimaryTextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
      titleMedium: getPrimaryTextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color, useDyslexiaFont: useDyslexiaFont),
      titleSmall: getPrimaryTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color, useDyslexiaFont: useDyslexiaFont),
      bodyLarge: getPrimaryTextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: color, height: 1.5, useDyslexiaFont: useDyslexiaFont),
      bodyMedium: getPrimaryTextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: color, height: 1.5, useDyslexiaFont: useDyslexiaFont),
      bodySmall: getPrimaryTextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: color, height: 1.4, useDyslexiaFont: useDyslexiaFont),
      labelLarge: getPrimaryTextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
      labelMedium: getPrimaryTextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
      labelSmall: getPrimaryTextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, useDyslexiaFont: useDyslexiaFont),
    );
}

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

final themeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  final settings = ref.watch(settingsProvider);
  return ThemeConfig.buildTheme(
    isDark: mode == ThemeMode.dark,
    useDyslexiaFont: settings.useDyslexiaFont,
  );
});
