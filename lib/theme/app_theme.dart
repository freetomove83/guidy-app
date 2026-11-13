// lib/theme/app_theme.dart
// Guidy 디자인 시스템 v4 — 종이 아이보리 위에 딥 마린 하나 (unslop 방향, CMS docs/design/cms-direction.md와 같은 가족)
// 화면은 조용하게, 색은 작품 이미지·표지가 냄. 상태색은 의미가 있을 때만

import 'package:flutter/material.dart';

// ─── 컬러 토큰 ─────────────────────────────────────────────
class GuidyColors {
  // Light
  static const bg = Color(0xFFF5F1EA);       // 페이퍼 아이보리
  static const bgAlt = Color(0xFFEDE7DC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0B1F2E);      // 딥 마린 잉크
  static const sub = Color(0xFF4A5A66);
  static const mute = Color(0xFF6F7680);     // 아이보리 위에서도 4.5:1
  static const line = Color(0x140B1F2E);     // 글자색 8% 머리카락 선
  static const chip = Color(0xFFEDE7DC);

  // 포인트
  static const primary = Color(0xFF0B3D5C);   // 딥 마린
  static const primarySoft = Color(0xFFD8E5EF);
  static const accent = Color(0xFF0B3D5C);    // 예전 테라코타 자리 — 강조색은 하나
  static const accentSoft = Color(0xFFD8E5EF);

  // 3채널
  static const curation = Color(0xFF0B3D5C);
  static const curationSoft = Color(0xFFD8E5EF);
  static const creator = Color(0xFF0B3D5C);   // 채널은 색이 아니라 글자로 구분
  static const creatorSoft = Color(0xFFD8E5EF);
  static const archive = Color(0xFF4A5A66);
  static const archiveSoft = Color(0xFFE0E4E8);

  // 상태
  static const ok = Color(0xFF2F7A55);
  static const warn = Color(0xFFB45309);
  static const danger = Color(0xFFC13B3B);

  // Dark
  static const darkBg = Color(0xFF0A1620);
  static const darkBgAlt = Color(0xFF0F1E2A);
  static const darkSurface = Color(0xFF152535);
  static const darkText = Color(0xFFF0EDE5);
  static const darkSub = Color(0xFFA8B4BE);
  static const darkMute = Color(0xFF7E8A95);
  static const darkLine = Color(0x14F0EDE5);
  static const darkPrimary = Color(0xFF4A8BB0);
  static const darkAccent = Color(0xFF4A8BB0);
  static const darkCuration = Color(0xFF4A8BB0);
  static const darkCreator = Color(0xFF4A8BB0);
  static const darkArchive = Color(0xFFA8B4BE);
}

// ─── 라이트/다크 팔레트 ─────────────────────────────────────
// 화면에서 `isDark ? GuidyColors.darkX : GuidyColors.x`를 반복하지 않도록 한 곳에서 매핑
class GuidyPalette {
  final Color bg, bgAlt, surface, text, sub, mute, line;
  final Color primary, accent, curation, creator, archive;

  const GuidyPalette._({
    required this.bg, required this.bgAlt, required this.surface,
    required this.text, required this.sub, required this.mute, required this.line,
    required this.primary, required this.accent,
    required this.curation, required this.creator, required this.archive,
  });

  static const light = GuidyPalette._(
    bg: GuidyColors.bg, bgAlt: GuidyColors.bgAlt, surface: GuidyColors.surface,
    text: GuidyColors.ink, sub: GuidyColors.sub, mute: GuidyColors.mute, line: GuidyColors.line,
    primary: GuidyColors.primary, accent: GuidyColors.accent,
    curation: GuidyColors.curation, creator: GuidyColors.creator, archive: GuidyColors.archive,
  );

  static const dark = GuidyPalette._(
    bg: GuidyColors.darkBg, bgAlt: GuidyColors.darkBgAlt, surface: GuidyColors.darkSurface,
    text: GuidyColors.darkText, sub: GuidyColors.darkSub, mute: GuidyColors.darkMute, line: GuidyColors.darkLine,
    primary: GuidyColors.darkPrimary, accent: GuidyColors.darkAccent,
    curation: GuidyColors.darkCuration, creator: GuidyColors.darkCreator, archive: GuidyColors.darkArchive,
  );

  static GuidyPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// isDark를 인자로 넘겨받는 위젯용
  static GuidyPalette forDark(bool isDark) => isDark ? dark : light;
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

  // 위계는 크기와 색으로, 굵기는 400·500 (드물게 600), 16px 미만 자간 0
  static TextStyle h1(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w500,
    color: color, height: 1.25,
  );
  static TextStyle h2(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w500,
    color: color, height: 1.3,
  );
  static TextStyle h3(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500,
    color: color, height: 1.4,
  );
  static TextStyle body(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400,
    color: color, height: 1.5,
  );
  static TextStyle small(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    color: color, height: 1.4,
  );
  static TextStyle label(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    color: color,
  );
  // 예전엔 대문자·넓은 자간 라벨, 이제는 작은 보조 글자
  static TextStyle kicker(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    color: color,
  );

  /// 시그니처 — 벽 캡션처럼 쓰는 메타 정보 (장소·시간·가격·재생 시간). 고정폭 숫자
  static TextStyle meta(Color color) => TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    color: color, height: 1.4, fontFeatures: const [FontFeature.tabularFigures()],
  );
}

// ─── 그림자 — 작고 중립적인 것만 ─────────────────────────────
class GuidyShadow {
  static List<BoxShadow> card = [
    BoxShadow(color: const Color(0xFF0B1F2E).withValues(alpha: 0.05), offset: const Offset(0, 1), blurRadius: 2),
  ];
  static List<BoxShadow> up = [
    BoxShadow(color: const Color(0xFF0B1F2E).withValues(alpha: 0.06), offset: const Offset(0, -2), blurRadius: 8),
  ];
  static List<BoxShadow> pop = [
    BoxShadow(color: const Color(0xFF0B1F2E).withValues(alpha: 0.08), offset: const Offset(0, 8), blurRadius: 24),
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
    cardTheme: CardThemeData(
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
    cardTheme: CardThemeData(
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
