// 큰 글자(기기 글자 크기 설정) 대응 점검
// 모든 화면을 앱 상한 배율(main.dart maxTextScale, 현재 2.0)과 2.5로 그려
// 넘치는(overflow) 위젯의 소스 위치를 모은다.
//
// - 상한 배율: 실제 사용자가 볼 수 있는 최대치. 알려진 목록(knownAtCap)과 달라지면 실패 →
//   새로 깨진 화면이 생기거나, 고쳐진 화면이 있으면 목록을 갱신하라는 신호.
// - 2.5배: 상한을 더 올리기 전에 고칠 곳을 보여주는 참고용(실패하지 않음).
// 테스트 폰트는 실제 폰트보다 글자 폭이 넓어(특히 영문) 실제보다 엄격하게 나올 수 있음.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/main.dart';
import 'screen_harness.dart';

/// 상한 배율에서 현재 넘치는 위치 (화면 이름 → 소스 위치 목록). 새로 생기면 고치거나 이유와 함께 여기 기록
const knownAtCap = <String, List<String>>{};

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

  test('app caps text scale at 2.0', () => expect(maxTextScale, 2.0));

  for (final name in names) {
    testWidgets('$name at cap (${maxTextScale}x) matches known overflows', (tester) async {
      final sites = await _overflowSites(tester, name, maxTextScale);
      // ignore: avoid_print
      if (sites.isNotEmpty) print('[cap ${maxTextScale}x] $name: ${sites.join(', ')}');
      expect(sites, knownAtCap[name] ?? const <String>[], reason: name);
    });
    for (final scale in [2.5]) {
      testWidgets('$name at ${scale}x (report only)', (tester) async {
        final sites = await _overflowSites(tester, name, scale);
        // ignore: avoid_print
        if (sites.isNotEmpty) print('[${scale}x] $name: ${sites.join(', ')}');
      });
    }
  }
}
