// 화면별 라이트/다크 골든 — 색상 리팩터링 전후 픽셀 비교용
// 기준 생성: flutter test --update-goldens test/goldens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/main.dart';
import '../screen_harness.dart';

void main() {
  setUpScreenHarness();

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final e in screens.entries) {
      testWidgets('${e.key} $mode', (tester) async {
        ignoreTestEnvErrors();
        await tester.binding.setSurfaceSize(const Size(402, 874));
        await pumpScreen(tester, e.value(), dark: dark);
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('png/${e.key}_$mode.png'));
        // 예약된 광고·애니메이션 타이머 소진
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpWidget(const SizedBox());
      });
    }

    // MainShell의 비공개 설정 탭(_SettingsPage)
    testWidgets('shell_settings $mode', (tester) async {
      ignoreTestEnvErrors();
      await tester.binding.setSurfaceSize(const Size(402, 874));
      await pumpScreen(tester, const MainShell(), dark: dark);
      await tester.tap(find.text('내 정보').last);
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('png/shell_settings_$mode.png'));
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
