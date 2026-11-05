import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guidy_audio_guide/models/app_store.dart';
import 'package:guidy_audio_guide/models/models.dart';
import 'package:guidy_audio_guide/models/user_store.dart';
import 'package:guidy_audio_guide/widgets/ad_overlay.dart';
import 'package:guidy_audio_guide/widgets/common_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('unknown IDs return null instead of the first item', () {
    final store = AppStore();
    expect(store.exhibitionById('expo_001'), isNull);
    expect(store.artworkById('nope'), isNull);
    expect(store.exhibitionById('e2')?.id, 'e2');
  });

  test('canAccess: free, purchased, or nothing', () async {
    final app = AppStore();
    final user = UserStore();
    final e4 = app.exhibitionById('e4')!; // 유료, 구매 없음

    expect(user.canAccess(app.exhibitionById('e7')!), isTrue); // isFreeAccess
    expect(user.canAccess(e4), isFalse);

    await user.addPurchase(Purchase(
      id: 'p_test', exhibitionId: 'e4', exhibitionTitle: e4.title,
      venueName: e4.venue, coverSeed: 0, pricePaid: e4.price,
      purchasedAt: DateTime(2026), status: PurchaseStatus.unused,
    ));
    expect(user.canAccess(e4), isTrue);
  });

  test('new users start with no purchases; clearAll wipes saved data', () async {
    final user = UserStore();
    expect(user.purchases, isEmpty);
    await user.toggleFavorite('e1');
    await user.addPurchase(Purchase(
      id: 'p1', exhibitionId: 'e1', exhibitionTitle: 't', venueName: 'v',
      coverSeed: 0, pricePaid: 8000, purchasedAt: DateTime(2026),
      status: PurchaseStatus.unused,
    ));
    await user.clearAll();
    expect(user.purchases, isEmpty);
    expect(user.favorites, isEmpty);

    final restored = UserStore();
    await restored.init();
    expect(restored.purchases, isEmpty);
    expect(restored.favorites, isEmpty);
  });

  test('corrupt purchase entries are skipped, valid ones restored', () async {
    SharedPreferences.setMockInitialValues({
      'guidy_user_purchases':
          '[{"bad":1},{"id":"p1","exhibitionId":"e1","exhibitionTitle":"t","purchasedAt":"2026-01-01T00:00:00.000"}]',
      'guidy_user_favorites': ['e2'],
    });
    final user = UserStore();
    await user.init();
    expect(user.purchases.map((p) => p.id), ['p1']);
    expect(user.favorites, {'e2'});
  });

  test('popup "hide today" persists', () async {
    expect(await AdDataStore.isPopupHiddenToday(), isFalse);
    await AdDataStore.hidePopupToday();
    expect(await AdDataStore.isPopupHiddenToday(), isTrue);
  });

  test('formatPrice adds thousand separators', () {
    expect(formatPrice(0), '0');
    expect(formatPrice(800), '800');
    expect(formatPrice(8000), '8,000');
    expect(formatPrice(1234567), '1,234,567');
  });
}
