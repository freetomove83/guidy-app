import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/main.dart';

void main() {
  testWidgets('Guidy app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GuidyApp());
    expect(find.byType(GuidyApp), findsOneWidget);
  });
}
