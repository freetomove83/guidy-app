import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guidy_audio_guide/models/app_store.dart';
import 'package:guidy_audio_guide/models/models.dart';
import 'package:guidy_audio_guide/models/user_store.dart';

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
}
