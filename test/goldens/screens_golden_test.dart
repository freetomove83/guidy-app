// 화면별 라이트/다크 골든 — 색상 리팩터링 전후 픽셀 비교용
// 기준 생성: flutter test --update-goldens test/goldens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guidy_audio_guide/main.dart';
import 'package:guidy_audio_guide/theme/app_theme.dart';
import 'package:guidy_audio_guide/theme/theme_provider.dart';
import 'package:guidy_audio_guide/services/audio_service.dart';
import 'package:guidy_audio_guide/models/app_store.dart';
import 'package:guidy_audio_guide/models/user_store.dart';
import 'package:guidy_audio_guide/screens/home/home_screen.dart';
import 'package:guidy_audio_guide/screens/detail/detail_screen.dart';
import 'package:guidy_audio_guide/screens/player/player_screen.dart';
import 'package:guidy_audio_guide/screens/following/following_screen.dart';
import 'package:guidy_audio_guide/screens/creator/creator_profile_screen.dart';
import 'package:guidy_audio_guide/screens/creator/creator_studio_screen.dart';
import 'package:guidy_audio_guide/screens/creator/creator_apply_screen.dart';
import 'package:guidy_audio_guide/screens/archive/archive_screen.dart';
import 'package:guidy_audio_guide/screens/library/library_screen.dart';
import 'package:guidy_audio_guide/screens/scan/scan_screen.dart';
import 'package:guidy_audio_guide/screens/auth/login_screen.dart';
import 'package:guidy_audio_guide/screens/auth/signup_screen.dart';
import 'package:guidy_audio_guide/screens/auth/email_login_screen.dart';
import 'package:guidy_audio_guide/screens/search/search_screen.dart';
import 'package:guidy_audio_guide/screens/notifications/notifications_screen.dart';
import 'package:guidy_audio_guide/screens/creator_guides/creator_guides_screen.dart';
import 'package:guidy_audio_guide/screens/section/section_detail_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/my_page_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/notification_settings_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/change_password_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/delete_account_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/help_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/about_screen.dart';
import 'package:guidy_audio_guide/screens/mypage/referral_screen.dart';

final screens = <String, Widget Function()>{
  'shell_home': () => const MainShell(),
  'home': () => const HomeScreen(),
  'detail_e1': () => const DetailScreen(exhibitionId: 'e1'),
  'detail_e5': () => const DetailScreen(exhibitionId: 'e5'),
  'player_a1': () => const PlayerScreen(artworkId: 'a1'),
  'following': () => const FollowingScreen(),
  'creator_profile': () => const CreatorProfileScreen(creatorId: 'c1'),
  'creator_studio': () => const CreatorStudioScreen(),
  'guide_edit': () => const GuideEditScreen(),
  'creator_apply': () => const CreatorApplyScreen(),
  'archive_e3': () => const ArchiveScreen(exhibitionId: 'e3'),
  'library': () => const LibraryScreen(),
  'scan': () => const ScanScreen(),
  'login': () => const LoginScreen(),
  'signup': () => const SignupScreen(),
  'email_login': () => const EmailLoginScreen(),
  'search': () => const SearchScreen(),
  'notifications': () => const NotificationsScreen(),
  'creator_guides': () => const CreatorGuidesScreen(exhibitionId: 'e1'),
  'section_s1': () => const SectionDetailScreen(sectionId: 's1'),
  'mypage': () => const MyPageScreen(),
  'notification_settings': () => const NotificationSettingsScreen(),
  'change_password': () => const ChangePasswordScreen(),
  'delete_account': () => const DeleteAccountScreen(),
  'help': () => const HelpScreen(),
  'about': () => const AboutScreen(),
  'referral': () => const ReferralScreen(),
};

Future<void> _pump(WidgetTester tester, Widget screen, bool dark) async {
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: GuidyAudioService()),
      ChangeNotifierProvider(create: (_) => AppStore()),
      ChangeNotifierProvider(create: (_) => UserStore()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: screen,
    ),
  ));
  // 반복 애니메이션이 있어 pumpAndSettle 대신 고정 시간만 진행
  await tester.pump(const Duration(milliseconds: 600));
  // 이미지 디코딩은 비동기라, 캐시 여부(테스트 실행 순서)에 따라 결과가 달라지지 않게 모두 로드 후 캡처
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
}

// 골든 전용: 테스트 환경에서만 생기는 오류는 무시
// - 테스트 폰트(Ahem)가 실제 폰트보다 넓어 생기는 overflow
// - audioplayers 플레이어별 이벤트 채널(이름이 매번 달라 mock 불가)
void _ignoreOverflow() {
  final orig = FlutterError.onError;
  FlutterError.onError = (d) {
    final msg = d.exceptionAsString();
    if (msg.contains('overflowed') || d.exception is MissingPluginException) return;
    orig?.call(d);
  };
  addTearDown(() => FlutterError.onError = orig);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // audioplayers 네이티브 채널 없음 → 빈 응답으로 대체
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final ch in ['xyz.luan/audioplayers', 'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events']) {
    messenger.setMockMethodCallHandler(MethodChannel(ch), (_) async => null);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // 홈 팝업 광고가 화면을 가리지 않도록
      'guidy_popup_ad_hidden_on': DateTime.now().toIso8601String().substring(0, 10),
    });
    // 오디오 서비스는 싱글톤이라 플레이어 테스트의 재생 상태(미니플레이어)가 다음 테스트로 새지 않게 초기화
    await GuidyAudioService().stop();
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final e in screens.entries) {
      testWidgets('${e.key} $mode', (tester) async {
        _ignoreOverflow();
        await tester.binding.setSurfaceSize(const Size(402, 874));
        await _pump(tester, e.value(), dark);
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('png/${e.key}_$mode.png'));
        // 예약된 광고·애니메이션 타이머 소진
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpWidget(const SizedBox());
      });
    }

    // MainShell의 비공개 설정 탭(_SettingsPage)
    testWidgets('shell_settings $mode', (tester) async {
      _ignoreOverflow();
      await tester.binding.setSurfaceSize(const Size(402, 874));
      await _pump(tester, const MainShell(), dark);
      await tester.tap(find.text('내 정보').last);
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('png/shell_settings_$mode.png'));
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
