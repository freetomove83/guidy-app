// 알림 읽음·지움 상태 — 기기에 저장되고 되돌릴 수 있는지
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/services/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('swipe removes one alert, clear all can be undone, read state survives a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final c = NotificationCenter.instance;
    await c.load();
    final all = c.items.length;
    expect(c.unreadCount, greaterThan(0));

    final first = c.items.first.id;
    c.dismiss(first);
    expect(c.items.map((n) => n.id), isNot(contains(first)));
    expect(c.items.length, all - 1);

    c.markAllRead();
    expect(c.unreadCount, 0);

    final cleared = c.clearAll();
    expect(c.items, isEmpty);
    c.restore(cleared);
    expect(c.items.length, all - 1);

    await Future<void>.delayed(Duration.zero); // 저장이 끝나도록
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('notif_dismissed_ids'), [first]);
    expect(prefs.getStringList('notif_read_ids'), hasLength(all - 1));
  });
}
