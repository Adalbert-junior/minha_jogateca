import 'package:flutter/material.dart';

import '../models/jogo.dart';

/// Paleta e componentes do app. Cores de texto foram escolhidas para manter
/// contraste de pelo menos 4,5:1 sobre as superfícies (conferido em teste).
abstract final class AppTheme {
  static const _fonteTitulo = 'ChakraPetch';
  static const _fonteCorpo = 'Barlow';

  static ThemeData get escuro => _montar(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFB6FF3C),
      onPrimary: Color(0xFF0B0D12),
      primaryContainer: Color(0xFF26330F),
      onPrimaryContainer: Color(0xFFD9FF8F),
      secondary: Color(0xFF5CC8FF),
      onSecondary: Color(0xFF06131C),
      error: Color(0xFFFF7A8A),
      onError: Color(0xFF2B0710),
      surface: Color(0xFF14171F),
      onSurface: Color(0xFFECEFF4),
      onSurfaceVariant: Color(0xFFA3ACBB),
      outline: Color(0xFF3A4150),
      outlineVariant: Color(0xFF262B37),
      surfaceContainerLowest: Color(0xFF0B0D12),
      surfaceContainerLow: Color(0xFF10131A),
      surfaceContainer: Color(0xFF181C25),
      surfaceContainerHigh: Color(0xFF1E232E),
      surfaceContainerHighest: Color(0xFF262C39),
      inverseSurface: Color(0xFFECEFF4),
      onInverseSurface: Color(0xFF14171F),
    ),
  );

  static ThemeData get claro => _montar(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2C6E00),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD5F5A8),
      onPrimaryContainer: Color(0xFF173800),
      secondary: Color(0xFF0B6BA8),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFB3243A),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF14171F),
      onSurfaceVariant: Color(0xFF4B5363),
      outline: Color(0xFF8B93A3),
      outlineVariant: Color(0xFFDAD9D0),
      surfaceContainerLowest: Color(0xFFF4F3EE),
      surfaceContainerLow: Color(0xFFF9F8F4),
      surfaceContainer: Color(0xFFFFFFFF),
      surfaceContainerHigh: Color(0xFFEFEEE7),
      surfaceContainerHighest: Color(0xFFE6E5DC),
      inverseSurface: Color(0xFF14171F),
      onInverseSurface: Color(0xFFF4F3EE),
    ),
  );

  static ThemeData _montar(ColorScheme cores) {
    final escuro = cores.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cores,
      fontFamily: _fonteCorpo,
      scaffoldBackgroundColor: cores.surfaceContainerLowest,
      visualDensity: VisualDensity.standard,
    );

    TextStyle titulo(TextStyle? s, {FontWeight peso = FontWeight.w700}) =>
        (s ?? const TextStyle()).copyWith(
          fontFamily: _fonteTitulo,
          fontWeight: peso,
          color: cores.onSurface,
        );

    // Corpo em peso médio: o Barlow regular é fino demais para textos de 13 a
    // 14 px e perdia contraste real (medido nos testes de acessibilidade).
    TextStyle? corpo(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w500);

    final texto = base.textTheme.copyWith(
      bodyLarge: corpo(base.textTheme.bodyLarge),
      bodyMedium: corpo(base.textTheme.bodyMedium),
      bodySmall: corpo(base.textTheme.bodySmall),
      labelLarge: corpo(base.textTheme.labelLarge),
      labelMedium: corpo(base.textTheme.labelMedium),
      displaySmall: titulo(base.textTheme.displaySmall),
      headlineMedium: titulo(base.textTheme.headlineMedium),
      headlineSmall: titulo(base.textTheme.headlineSmall),
      titleLarge: titulo(base.textTheme.titleLarge),
      titleMedium: titulo(base.textTheme.titleMedium, peso: FontWeight.w600),
      titleSmall: titulo(base.textTheme.titleSmall, peso: FontWeight.w600),
    );

    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cores.outline),
    );

    return base.copyWith(
      textTheme: texto,
      appBarTheme: AppBarTheme(
        backgroundColor: cores.surfaceContainerLowest,
        foregroundColor: cores.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: titulo(texto.titleLarge),
      ),
      cardTheme: CardThemeData(
        color: cores.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surfaceContainerHigh,
        border: borda,
        enabledBorder: borda,
        focusedBorder: borda.copyWith(
          borderSide: BorderSide(color: cores.primary, width: 2),
        ),
        errorBorder: borda.copyWith(borderSide: BorderSide(color: cores.error)),
        focusedErrorBorder: borda.copyWith(
          borderSide: BorderSide(color: cores.error, width: 2),
        ),
        labelStyle: TextStyle(color: cores.onSurfaceVariant),
        helperStyle: TextStyle(color: cores.onSurfaceVariant),
        errorStyle: TextStyle(color: cores.error, fontWeight: FontWeight.w600),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: _fonteTitulo,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          side: BorderSide(color: cores.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: _fonteTitulo,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
        extendedTextStyle: const TextStyle(
          fontFamily: _fonteTitulo,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cores.surfaceContainerHigh,
        selectedColor: cores.primaryContainer,
        side: BorderSide(color: cores.outlineVariant),
        labelStyle: TextStyle(
          color: cores.onSurface,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: cores.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: cores.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.inverseSurface,
        contentTextStyle: TextStyle(
          color: cores.onInverseSurface,
          fontSize: 15,
          fontFamily: _fonteCorpo,
        ),
        actionTextColor: escuro
            ? const Color(0xFF2C6E00)
            : const Color(0xFFB6FF3C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: cores.outlineVariant, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: cores.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Cor de destaque de cada status, com variante para cada brilho.
  static Color corDoStatus(BuildContext context, StatusJogo status) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return switch (status) {
      StatusJogo.queroJogar =>
        escuro ? const Color(0xFFB9A6FF) : const Color(0xFF4A2FB8),
      StatusJogo.jogando =>
        escuro ? const Color(0xFF5CC8FF) : const Color(0xFF07557F),
      StatusJogo.zerado =>
        escuro ? const Color(0xFFB6FF3C) : const Color(0xFF245C00),
      StatusJogo.abandonado =>
        escuro ? const Color(0xFFFF7A8A) : const Color(0xFFA01B30),
    };
  }

  static IconData iconeDoStatus(StatusJogo status) => switch (status) {
    StatusJogo.queroJogar => Icons.bookmark_border,
    StatusJogo.jogando => Icons.sports_esports_outlined,
    StatusJogo.zerado => Icons.check_circle_outline,
    StatusJogo.abandonado => Icons.do_not_disturb_alt_outlined,
  };
}
