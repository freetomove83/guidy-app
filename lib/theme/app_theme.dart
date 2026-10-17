// lib/theme/app_theme.dart
// Guidy 디자인 시스템 v3 · Deep Marine 팔레트

import 'package:flutter/material.dart';

// ─── 컬러 토큰 ─────────────────────────────────────────────
class GuidyColors {
  // Light
  static const bg = Color(0xFFF5F1EA);       // 페이퍼 아이보리
  static const bgAlt = Color(0xFFEDE7DC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0B1F2E);      // 딥 마린 잉크
  static const sub = Color(0xFF4A5A66);
  static const mute = Color(0xFF8B9099);
  static const line = Color(0xFFE4DED4);
  static const chip = Color(0xFFEDE7DC);

  // 포인트
  static const primary = Color(0xFF0B3D5C);   // 딥 마린
  static const primarySoft = Color(0xFFD8E5EF);
  static const accent = Color(0xFFD97757);    // 테라코타
  static const accentSoft = Color(0xFFF7E4DA);

  // 3채널
  static const curation = Color(0xFF0B3D5C);
  static const curationSoft = Color(0xFFD8E5EF);
  static const creator = Color(0xFFD97757);
  static const creatorSoft = Color(0xFFF7E4DA);
  static const archive = Color(0xFF4A5A66);
  static const archiveSoft = Color(0xFFE0E4E8);

  // 상태
  static const ok = Color(0xFF2F8F5C);
  static const warn = Color(0xFFD97706);
  static const danger = Color(0xFFC13B3B);

  // Dark
  static const darkBg = Color(0xFF0A1620);
  static const darkBgAlt = Color(0xFF0F1E2A);
  static const darkSurface = Color(0xFF152535);
  static const darkText = Color(0xFFF0EDE5);
  static const darkSub = Color(0xFFA8B4BE);
  static const darkMute = Color(0xFF6E7A85);
  static const darkLine = Color(0xFF1F2E3D);
  static const darkPrimary = Color(0xFF4A8BB0);
  static const darkAccent = Color(0xFFE89575);
  static const darkCuration = Color(0xFF4A8BB0);
  static const darkCreator = Color(0xFFE89575);
  static const darkArchive = Color(0xFFA8B4BE);
}

// ─── 라디우스 ───────────────────────────────────────────────
class GuidyRadius {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(20);
  static const xxl = Radius.circular(24);
  static const pill = Radius.circular(999);

  static const smBorder = BorderRadius.all(sm);
  static const mdBorder = BorderRadius.all(md);
  static const lgBorder = BorderRadius.all(lg);
  static const xlBorder = BorderRadius.all(xl);
  static const xxlBorder = BorderRadius.all(xxl);
  static const pillBorder = BorderRadius.all(pill);
}

// ─── 타이포그래피 ──────────────────────────────────────────
class GuidyText {
  static const String fontFamily = 'Noto Sans KR';

  static TextStyle h1(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w800,
    letterSpacing: -0.84, color: color, height: 1.25,
  );
  static TextStyle h2(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w800,
    letterSpacing: -0.4, color: color, height: 1.3,
  );
  static TextStyle h3(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700,
    letterSpacing: -0.32, color: color, height: 1.4,
  );
  static TextStyle body(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500,
    letterSpacing: -0.14, color: color, height: 1.5,
  );
  static TextStyle small(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    letterSpacing: -0.12, color: color, height: 1.4,
  );
  static TextStyle label(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w800,
    letterSpacing: 0.22, color: color,
  );
  static TextStyle kicker(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 10, fontWeight: FontWeight.w800,
    letterSpacing: 1.5, color: color,
  );
}

// ─── 그림자 ────────────────────────────────────────────────
class GuidyShadow {
  static List<BoxShadow> card = [
    BoxShadow(color: const Color(0xFF0B1F2E).withOpacity(0.04), offset: const Offset(0, 1), blurRadius: 2),
    BoxShadow(color: const Color(0xFF0B1F2E).withOpacity(0.06), offset: const Offset(0, 8), blurRadius: 24),
  ];
  static List<BoxShadow> up = [
    BoxShadow(color: const Color(0xFF0B1F2E).withOpacity(0.06), offset: const Offset(0, -4), blurRadius: 24),
  ];
  static List<BoxShadow> pop = [
    BoxShadow(color: const Color(0xFF0B1F2E).withOpacity(0.18), offset: const Offset(0, 12), blurRadius: 40),
  ];
}

// ─── ThemeData ─────────────────────────────────────────────
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: GuidyText.fontFamily,
    scaffoldBackgroundColor: GuidyColors.bg,
    colorScheme: const ColorScheme.light(
      primary: GuidyColors.primary,
      secondary: GuidyColors.accent,
      surface: GuidyColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: GuidyColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: GuidyColors.bg,
      foregroundColor: GuidyColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(color: GuidyColors.line, thickness: 1),
    cardTheme: CardTheme(
      color: GuidyColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GuidyRadius.lgBorder,
        side: const BorderSide(color: GuidyColors.line),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: GuidyColors.surface,
      selectedItemColor: GuidyColors.primary,
      unselectedItemColor: GuidyColors.mute,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: GuidyText.fontFamily,
    scaffoldBackgroundColor: GuidyColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: GuidyColors.darkPrimary,
      secondary: GuidyColors.darkAccent,
      surface: GuidyColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: GuidyColors.darkText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: GuidyColors.darkBg,
      foregroundColor: GuidyColors.darkText,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: GuidyColors.darkLine, thickness: 1),
    cardTheme: CardTheme(
      color: GuidyColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GuidyRadius.lgBorder,
        side: const BorderSide(color: GuidyColors.darkLine),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
