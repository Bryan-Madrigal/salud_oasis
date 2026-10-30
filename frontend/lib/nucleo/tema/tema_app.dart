import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de espaciado unificado (escala 4).
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Sistema de radios unificado.
class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double full = 999;
}

/// Colores personalizados adaptados al tema.
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color accent;
  final Color accentDark;
  final Color accentSoft;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color divider;
  final Color danger;
  final Color warning;
  final Color info;
  final Color success;
  final List<BoxShadow> shadowSoft;
  final List<BoxShadow> shadowMedium;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.accent,
    required this.accentDark,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.divider,
    required this.danger,
    required this.warning,
    required this.info,
    required this.success,
    required this.shadowSoft,
    required this.shadowMedium,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? accent,
    Color? accentDark,
    Color? accentSoft,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? divider,
    Color? danger,
    Color? warning,
    Color? info,
    Color? success,
    List<BoxShadow>? shadowSoft,
    List<BoxShadow>? shadowMedium,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      accentSoft: accentSoft ?? this.accentSoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      success: success ?? this.success,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowMedium: shadowMedium ?? this.shadowMedium,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      shadowSoft: shadowSoft,
      shadowMedium: shadowMedium,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

/// Gradientes reutilizables para la marca.
class AppGradients {
  static LinearGradient ocean = const LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient coral = const LinearGradient(
    colors: [Color(0xFFFF7A7A), Color(0xFFEA5A5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroSoft = LinearGradient(
    colors: [
      const Color(0xFF0EA5E9).withValues(alpha: 0.12),
      const Color(0xFF0EA5E9).withValues(alpha: 0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient mix = const LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFFFF7A7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ===== Paleta clara =====
final _lightColors = AppColors(
  primary: const Color(0xFF0EA5E9),
  primaryDark: const Color(0xFF0369A1),
  primarySoft: const Color(0xFFE0F2FE),
  accent: const Color(0xFFFF6B6B),
  accentDark: const Color(0xFFE11D48),
  accentSoft: const Color(0xFFFFE4E6),
  background: const Color(0xFFFAFBFC),
  surface: Colors.white,
  surfaceAlt: const Color(0xFFF6F8FA),
  textPrimary: const Color(0xFF0F172A),
  textSecondary: const Color(0xFF64748B),
  textTertiary: const Color(0xFF94A3B8),
  border: const Color(0xFFE2E8F0),
  divider: const Color(0xFFF1F5F9),
  danger: const Color(0xFFEF4444),
  warning: const Color(0xFFF59E0B),
  info: const Color(0xFF3B82F6),
  success: const Color(0xFF10B981),
  shadowSoft: [
    BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 2)),
  ],
  shadowMedium: [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ],
);

// ===== Paleta oscura =====
final _darkColors = AppColors(
  primary: const Color(0xFF38BDF8),
  primaryDark: const Color(0xFF0EA5E9),
  primarySoft: const Color(0xFF0C2A3F),
  accent: const Color(0xFFFB7185),
  accentDark: const Color(0xFFE11D48),
  accentSoft: const Color(0xFF2E1620),
  background: const Color(0xFF0B1220),
  surface: const Color(0xFF131C2E),
  surfaceAlt: const Color(0xFF1C2639),
  textPrimary: const Color(0xFFF1F5F9),
  textSecondary: const Color(0xFF94A3B8),
  textTertiary: const Color(0xFF64748B),
  border: const Color(0xFF26334D),
  divider: const Color(0xFF1C2639),
  danger: const Color(0xFFF87171),
  warning: const Color(0xFFFBBF24),
  info: const Color(0xFF60A5FA),
  success: const Color(0xFF34D399),
  shadowSoft: [
    BoxShadow(color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 2)),
  ],
  shadowMedium: [
    BoxShadow(color: Color(0x50000000), blurRadius: 24, offset: Offset(0, 8)),
  ],
);

class TemaApp {
  static const Color primario = Color(0xFF0EA5E9);
  static const Color secundario = Color(0xFFFF6B6B);
  static const Color fondo = Color(0xFFFAFBFC);
  static const Color textoPrimario = Color(0xFF0F172A);
  static const Color textoSecundario = Color(0xFF64748B);

  static TextTheme _textTheme(Color colorTexto, Color colorSecundario) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, color: colorTexto, letterSpacing: -0.8, height: 1.15),
      headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: colorTexto, letterSpacing: -0.6, height: 1.2),
      headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: colorTexto, letterSpacing: -0.4, height: 1.25),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colorTexto, letterSpacing: -0.2),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: colorTexto, letterSpacing: -0.1),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colorTexto),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: colorTexto, height: 1.5, letterSpacing: -0.1),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: colorTexto, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: colorSecundario, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: colorTexto, letterSpacing: -0.1),
      labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colorSecundario),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colorSecundario, letterSpacing: 0.4),
    );
  }

  static ThemeData get claro => _construirTema(colores: _lightColors, brillo: Brightness.light);
  static ThemeData get oscuro => _construirTema(colores: _darkColors, brillo: Brightness.dark);

  static ThemeData _construirTema({required AppColors colores, required Brightness brillo}) {
    final textTheme = _textTheme(colores.textPrimary, colores.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      scaffoldBackgroundColor: colores.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colores.primary, brightness: brillo, primary: colores.primary,
        secondary: colores.accent, surface: colores.surface, error: colores.danger,
      ),
      textTheme: textTheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colores.background, foregroundColor: colores.textPrimary,
        elevation: 0, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent,
        centerTitle: false, titleTextStyle: textTheme.headlineMedium?.copyWith(fontSize: 18),
        iconTheme: IconThemeData(color: colores.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colores.surface, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: colores.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: colores.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: colores.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: colores.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: colores.danger, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: colores.danger, width: 2)),
        labelStyle: TextStyle(color: colores.textSecondary), hintStyle: TextStyle(color: colores.textTertiary),
        prefixIconColor: colores.textTertiary, suffixIconColor: colores.textTertiary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colores.primary, foregroundColor: Colors.white,
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colores.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colores.textPrimary, minimumSize: const Size(0, 50),
          side: BorderSide(color: colores.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colores.surface, selectedColor: colores.primary,
        side: BorderSide(color: colores.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colores.textPrimary),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colores.surface, indicatorColor: colores.primary.withValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: colores.primary);
          return IconThemeData(color: colores.textTertiary);
        }),
      ),
      dividerTheme: DividerThemeData(color: colores.divider, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: colores.surface, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colores.textPrimary,
        contentTextStyle: GoogleFonts.inter(color: colores.surface, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 0,
      ),
      extensions: [colores],
    );
  }
}