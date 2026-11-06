// lib/main.dart
// Guidy 오디오 가이드 앱 메인

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
  await _initFirebase();
  final appStore  = AppStore();
  final userStore = UserStore();
  await Future.wait([
    appStore.init(),   // localStorage에서 CMS 추가 항목 불러오기
    userStore.init(),  // localStorage에서 사용자 개인화 데이터 복원
  ]);
  runApp(GuidyRoot(appStore: appStore, userStore: userStore));
}

/// Firebase 기본 앱 초기화 — 설정은 네이티브 파일에서 읽음
/// (iOS: ios/Runner/GoogleService-Info.plist, Android: android/app/google-services.json)
// shortcut: 웹은 Firebase 웹 앱 미등록이라 건너뜀, 웹에서 Firebase 쓸 때 FirebaseOptions 추가
Future<void> _initFirebase() async {
  if (kIsWeb) return;
  try {
    final app = await Firebase.initializeApp();
    debugPrint('[Firebase] initialized: ${app.options.projectId}');
  } catch (e) {
    // 아직 Firebase 기능을 쓰는 화면이 없으므로 설정 누락 시 앱은 계속 실행
    debugPrint('[Firebase] init skipped: $e');
  }
}

/// 앱 루트 — Provider 구성만 담당 (테스트에서 동일하게 재사용)
class GuidyRoot extends StatelessWidget {
  final AppStore appStore;
  final UserStore userStore;

  const GuidyRoot({
    super.key,
    required this.appStore,
    required this.userStore,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // 싱글톤이므로 Provider가 dispose하지 않도록 .value 사용
        ChangeNotifierProvider.value(value: GuidyAudioService()),
        ChangeNotifierProvider.value(value: appStore),
        ChangeNotifierProvider.value(value: userStore),
      ],
      child: const GuidyApp(),
    );
  }
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

  final List<Widget> _pages = const [
    HomeScreen(),
    SizedBox.shrink(), // 스캔 탭은 /scan 라우트로 push (상주 화면 불필요)
    LibraryScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final pal = GuidyPalette.of(context);

    // 현재 재생 중인 작품 → 미니플레이어 표시
    final audio = context.watch<GuidyAudioService>();
    final store = context.watch<AppStore>();
    final playingId = audio.currentId;
    final nowPlaying = playingId == null ? null : store.artworkById(playingId);
    final nowPlayingExhibition = nowPlaying == null
        ? null
        : store.exhibitionById(nowPlaying.exhibitionId);


    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: pal.surface,
          border: Border(top: BorderSide(color: pal.line)),
          boxShadow: GuidyShadow.up,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 미니 플레이어 — GuidyAudioService 실제 재생 상태 연동
              if (nowPlaying != null)
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context, '/player/${nowPlaying.id}'),
                  child: MiniPlayer(
                    artworkTitle: nowPlaying.title,
                    exhibitionTitle: nowPlayingExhibition?.title ?? '',
                    coverSeed: nowPlaying.imageSeed,
                    isPlaying: audio.isPlaying,
                    onPlayPause: () {
                      final url = nowPlaying.audioUrl;
                      if (url == null) return;
                      audio.togglePlay(url, artworkId: nowPlaying.id);
                    },
                    onSkipBackward: () => audio.skipBackward(10),
                    onSkipForward: () => audio.skipForward(10),
                  ),
                ),
              // 탭바
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.home_rounded, Icons.home_outlined, '홈', 0, pal.primary, pal.mute, pal.text),
                    _navItemScan(pal.primary),
                    _navItem(Icons.library_books_rounded, Icons.library_books_outlined, '서재', 2, pal.primary, pal.mute, pal.text),
                    _navItem(Icons.person_rounded, Icons.person_outline_rounded, '내 정보', 3, pal.primary, pal.mute, pal.text),
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
    final pal = GuidyPalette.of(context);

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
                color: pal.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.qr_code_scanner_rounded, color: pal.accent, size: 20),
            ),
            const SizedBox(height: 2),
            Text('스캔', style: TextStyle(
              fontFamily: GuidyText.fontFamily, fontSize: 10,
              fontWeight: FontWeight.w700,
              color: pal.accent,
            )),
          ],
        ),
      ),
    );
  }
}
