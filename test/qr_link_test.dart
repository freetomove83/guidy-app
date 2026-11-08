import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/models/app_store.dart';
import 'package:guidy_audio_guide/services/qr_link.dart';

void main() {
  final store = AppStore();
  String? route(String raw) => qrRoute(raw, store);

  test('CMS deep links open the matching screen', () {
    expect(route('guidy://artwork/a1'), '/player/a1');
    expect(route(' guidy://exhibition/e1 '), '/detail/e1');
    expect(route('guidy://creator/c1'), '/creator/c1');
  });

  test('web app links work with path or hash routes', () {
    expect(route('https://guidy-app.pages.dev/#/detail/e1'), '/detail/e1');
    expect(route('https://guidy.kr/player/a1'), '/player/a1');
  });

  test('unknown content and foreign codes are rejected', () {
    expect(route('guidy://artwork/nope'), isNull);
    expect(route('guidy://artwork'), isNull);
    expect(route('guidy://ticket/a1'), isNull);
    expect(route('https://evil.example/#/detail/e1'), isNull);
    expect(route('hello world'), isNull);
    expect(route(''), isNull);
  });
}
