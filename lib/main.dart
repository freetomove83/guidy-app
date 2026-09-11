// lib/main.dart
// Guidy 오디오 가이드 앱 메인

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'services/audio_service.dart';
import 'models/app_store.dart';
import 'models/user_store.dart';
import 'screens/home/home_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/player/player_screen.dart';
import 'screens/following/following_screen.dart';
import 'screens/creator/creator_profile_screen.dart';
import 'screens/creator/creator_studio_screen.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/creator_guides/creator_guides_screen.dart';
import 'screens/section/section_detail_screen.dart';
import 'screens/mypage/my_page_screen.dart';
import 'screens/mypage/notification_settings_screen.dart';
import 'screens/mypage/change_password_screen.dart';
import 'screens/mypage/delete_account_screen.dart';
import 'screens/mypage/help_screen.dart';
import 'screens/mypage/about_screen.dart';
import 'screens/creator/creator_apply_screen.dart';
import 'widgets/common_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appStore  = AppStore();
  final userStore = UserStore();
  await Future.wait([
    appStore.init(),   // localStorage에서 CMS 추가 항목 불러오기
    userStore.init(),  // localStorage에서 사용자 개인화 데이터 복원
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GuidyAudioService()),
        ChangeNotifierProvider.value(value: appStore),
        ChangeNotifierProvider.value(value: userStore),
      ],
      child: const GuidyApp(),
    ),
  );
}

class GuidyApp extends StatelessWidget {
  const GuidyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Guidy',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/splash',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';


    Widget page;

    if (name == '/splash') {
      // 스플래시는 전환 애니메이션 없이 즉시 표시
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => const SplashScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      );
    }

    if (name == '/' || name == '/home') {
      page = const MainShell();
    } else if (name.startsWith('/detail/')) {
      final id = name.replaceFirst('/detail/', '');
      page = DetailScreen(exhibitionId: id);
    } else if (name.startsWith('/player/')) {
      final id = name.replaceFirst('/player/', '');
      page = PlayerScreen(artworkId: id);
    } else if (name == '/following') {
      page = const FollowingScreen();
    } else if (name.startsWith('/creator/')) {
      final id = name.replaceFirst('/creator/', '');
      page = CreatorProfileScreen(creatorId: id);
    } else if (name == '/creator-studio') {
      page = const CreatorStudioScreen();
    } else if (name.startsWith('/archive/')) {
      final id = name.replaceFirst('/archive/', '');
      page = ArchiveScreen(exhibitionId: id);
    } else if (name == '/library') {
      final args = settings.arguments;
      final initialTab = (args is Map && args['tab'] is int)
          ? args['tab'] as int : 0;
      page = LibraryScreen(initialTab: initialTab);
    } else if (name == '/scan') {
      page = const ScanScreen();
    } else if (name == '/login') {
      page = const LoginScreen();
    } else if (name == '/signup') {
      page = const SignupScreen();
    } else if (name == '/search') {
      page = const SearchScreen();
    } else if (name == '/notifications') {
      page = const NotificationsScreen();
    } else if (name.startsWith('/creator-guides/')) {
      final id = name.replaceFirst('/creator-guides/', '');
      page = CreatorGuidesScreen(exhibitionId: id);
    } else if (name.startsWith('/section/')) {
      final id = name.replaceFirst('/section/', '');
      page = SectionDetailScreen(sectionId: id);
    } else if (name == '/mypage') {
      page = const MyPageScreen();
    } else if (name == '/notification-settings') {
      page = const NotificationSettingsScreen();
    } else if (name == '/change-password') {
      page = const ChangePasswordScreen();
    } else if (name == '/delete-account') {
      page = const DeleteAccountScreen();
    } else if (name == '/help') {
      page = const HelpScreen();
    } else if (name == '/about') {
      page = const AboutScreen();
    } else if (name == '/creator-apply') {
      page = const CreatorApplyScreen();
    } else {
      page = const MainShell();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// ─── 메인 쉘 (바텀 탭) ───────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;
  final bool _showMiniPlayer = true;
  bool _isPlaying = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    ScanScreen(),
    LibraryScreen(),
    _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;

    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceC,
          border: Border(top: BorderSide(color: lineC)),
          boxShadow: GuidyShadow.up,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 미니 플레이어
              if (_showMiniPlayer)
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/player/a1'),
                  child: MiniPlayer(
                    artworkTitle: '무제 #7',
                    exhibitionTitle: '빛과 표면',
                    coverSeed: 0,
                    isPlaying: _isPlaying,
                    onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                  ),
                ),
              // 탭바
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.home_rounded, Icons.home_outlined, '홈', 0, primaryC, muteC, textC),
                    _navItemScan(primaryC),
                    _navItem(Icons.library_books_rounded, Icons.library_books_outlined, '서재', 2, primaryC, muteC, textC),
                    _navItem(Icons.person_rounded, Icons.person_outline_rounded, '내 정보', 3, primaryC, muteC, textC),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData activeIcon, IconData inactiveIcon, String label, int idx, Color primaryC, Color muteC, Color textC) {
    final isActive = _navIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, size: 24,
              color: isActive ? primaryC : muteC),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontFamily: GuidyText.fontFamily, fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? primaryC : muteC,
            )),
          ],
        ),
      ),
    );
  }

  Widget _navItemScan(Color primaryC) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/scan'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: accentC.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.qr_code_scanner_rounded, color: accentC, size: 20),
            ),
            const SizedBox(height: 2),
            Text('스캔', style: TextStyle(
              fontFamily: GuidyText.fontFamily, fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accentC,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── 설정 페이지 ─────────────────────────────────────────
class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Text('내 정보', style: GuidyText.h2(textC)),
            const SizedBox(height: 20),

            // 프로필 카드 (탭 시 로그인 화면)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/mypage'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceC,
                  borderRadius: GuidyRadius.xlBorder,
                  border: Border.all(color: lineC),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: const BoxDecoration(
                        color: GuidyColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('G', style: TextStyle(
                          color: GuidyColors.primary, fontSize: 24, fontWeight: FontWeight.w800,
                          fontFamily: GuidyText.fontFamily,
                        )),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Guidy 사용자', style: GuidyText.h3(textC)),
                          Text('로그인하여 더 많은 기능을 이용하세요', style: GuidyText.small(subC)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: muteC, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 설정 메뉴
            _settingItem(Icons.mic_rounded, '크리에이터 되기', '오디오 가이드를 만들어 수익을 창출하세요', context, surfaceC, lineC, textC, subC, () {
              final userStore = context.read<UserStore>();
              if (userStore.isCreator) {
                // 이미 크리에이터 → 스튜디오로
                Navigator.pushNamed(context, '/creator-studio');
              } else {
                // 신청 전 or 대기 중 → 신청/진행 화면으로
                Navigator.pushNamed(context, '/creator-apply');
              }
            }),
            const SizedBox(height: 8),

            // 다크 모드 토글
            Consumer<ThemeProvider>(
              builder: (context, themeP, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceC,
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: lineC),
                ),
                child: Row(
                  children: [
                    Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: muteC, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('다크 모드', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
                          Text(isDark ? '현재 다크 모드' : '현재 라이트 모드', style: GuidyText.small(subC)),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (_) => themeP.toggle(),
                      activeThumbColor: GuidyColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            _settingItem(Icons.help_outline_rounded, '도움말', '사용 방법 및 FAQ', context, surfaceC, lineC, textC, subC, () {
              Navigator.pushNamed(context, '/help');
            }),
            const SizedBox(height: 8),
            _settingItem(Icons.info_outline_rounded, 'Guidy 소개', '버전 1.0.0', context, surfaceC, lineC, textC, subC, () {
              Navigator.pushNamed(context, '/about');
            }),

            const SizedBox(height: 40),

            // 앱 정보
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      borderRadius: GuidyRadius.lgBorder,
                    ),
                    child: ClipRRect(
                      borderRadius: GuidyRadius.lgBorder,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 48, height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('guidy', style: GuidyText.h3(textC)),
                  Text('오디오 가이드 마켓플레이스', style: GuidyText.small(subC)),
                  const SizedBox(height: 4),
                  Text('v1.0.0', style: GuidyText.kicker(muteC)),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, String sub, BuildContext context, Color surfaceC, Color lineC, Color textC, Color subC, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: GuidyColors.mute),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
                  Text(sub, style: GuidyText.small(subC)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: GuidyColors.mute, size: 18),
          ],
        ),
      ),
    );
  }
}
