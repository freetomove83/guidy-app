// 큰 글자(기기 글자 크기 설정) 대응 점검
// 모든 화면을 글자 배율 1.3(앱 상한, main.dart maxTextScale)과 2.0으로 그려
// 넘치는(overflow) 위젯의 소스 위치를 모은다.
//
// - 1.3배: 실제 사용자가 볼 수 있는 최대치. 알려진 목록(knownAtCap)과 달라지면 실패 →
//   새로 깨진 화면이 생기거나, 고쳐진 화면이 있으면 목록을 갱신하라는 신호.
// - 2.0배: 상한을 올리기 전에 고칠 곳을 보여주는 참고용(실패하지 않음).
// 테스트 폰트는 실제 폰트보다 글자 폭이 넓어(특히 영문) 실제보다 엄격하게 나올 수 있음.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/main.dart';
import 'screen_harness.dart';

/// 1.3배에서 현재 넘치는 위치 (화면 이름 → 소스 위치 목록). 고치면 여기서 지울 것
const _homeCreatorCard = 'lib/screens/home/home_screen.dart:287'; // 고정 높이 크리에이터 카드
const knownAtCap = <String, List<String>>{
  'home': [_homeCreatorCard],
  'shell_home': [_homeCreatorCard],
  'shell_settings': [_homeCreatorCard], // 탭 컨테이너가 숨은 홈 탭도 레이아웃함
  'following': ['lib/screens/following/following_screen.dart:65'], // 고정 높이 크리에이터 카드
  'signup': ['lib/screens/auth/signup_screen.dart:298'], // 초대 코드 안내 한 줄
  'referral': ['lib/screens/mypage/referral_screen.dart:409'], // 디버그 전용 테스트 버튼 (릴리즈엔 없음)
  'creator_guides': ['lib/screens/creator_guides/creator_guides_screen.dart:348'], // 재생시간·조회수 줄
  'creator_studio': ['lib/screens/creator/creator_studio_screen.dart:706'], // 라벨·값 정보 줄
};

final _site = RegExp(r'file://\S*?/(lib/[^\s:]+:\d+)');

Future<List<String>> _overflowSites(WidgetTester tester, String name, double scale) async {
  final sites = <String>{};
  ignoreTestEnvErrors(onOverflow: (d) {
    final m = _site.firstMatch(d.toString());
    sites.add(m?.group(1) ?? '(unknown)');
  });
  await tester.binding.setSurfaceSize(const Size(402, 874));
  if (name == 'shell_settings') {
    await pumpScreen(tester, const MainShell(), textScale: scale);
    await tester.tap(find.text('내 정보').last);
    await tester.pump(const Duration(milliseconds: 300));
  } else {
    await pumpScreen(tester, screens[name]!(), textScale: scale);
  }
  await tester.pump(const Duration(seconds: 10)); // 예약된 광고·애니메이션 타이머 소진
  await tester.pumpWidget(const SizedBox());
  return sites.toList()..sort();
}

void main() {
  setUpScreenHarness();
  final names = [...screens.keys, 'shell_settings'];

  test('app caps text scale at 1.3', () => expect(maxTextScale, 1.3));

  for (final name in names) {
    testWidgets('$name at 1.3x matches known overflows', (tester) async {
      final sites = await _overflowSites(tester, name, maxTextScale);
      // ignore: avoid_print
      if (sites.isNotEmpty) print('[1.3x] $name: ${sites.join(', ')}');
      expect(sites, knownAtCap[name] ?? const <String>[], reason: name);
    });
    testWidgets('$name at 2.0x (report only)', (tester) async {
      final sites = await _overflowSites(tester, name, 2.0);
      // ignore: avoid_print
      if (sites.isNotEmpty) print('[2.0x] $name: ${sites.join(', ')}');
    });
  }
}
