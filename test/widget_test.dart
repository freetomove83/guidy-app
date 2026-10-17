import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/main.dart';
import 'package:guidy_audio_guide/models/app_store.dart';
import 'package:guidy_audio_guide/models/user_store.dart';

void main() {
  testWidgets('Guidy app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GuidyRoot(appStore: AppStore(), userStore: UserStore()),
    );
    expect(find.byType(GuidyApp), findsOneWidget);

    // 스플래시 시퀀스가 예약한 타이머를 모두 소진시킨다 (pending timer 방지)
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  });
}
