// CMS 비콘 문서 → 작품 연결, 감지 거리·가장 가까운 비콘 고르기 점검 (블루투스·Firestore 없이)
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/services/beacon_service.dart';

const _uuid = 'e2c56db5-dffb-48d2-b060-d0f5a71096e0';

Beacon _seen(int minor, double accuracy, Proximity p) =>
    Beacon(proximityUUID: _uuid, major: 1, minor: minor, accuracy: accuracy, proximity: p);

void main() {
  test('CMS beacon docs without iBeacon ids or artwork are skipped', () {
    final ok = BeaconLink.fromMap({'uuid': _uuid, 'major': 1, 'minor': 2, 'linked_artwork_id': 'a1'})!;
    expect([ok.uuid, ok.major, ok.minor, ok.artworkId, ok.range], [_uuid.toUpperCase(), 1, 2, 'a1', 'near']);
    expect(BeaconLink.fromMap({'uuid': _uuid, 'major': 1, 'minor': 2}), isNull);
    expect(BeaconLink.fromMap({'uuid': '', 'major': 1, 'minor': 2, 'linked_artwork_id': 'a1'}), isNull);
    expect(BeaconLink.fromMap({'mac': '48:87:2D:76:00:3E', 'linked_artwork_id': 'a1'}), isNull);
  });

  test('detection range follows the CMS setting', () {
    BeaconLink link(String r) => BeaconLink(uuid: _uuid, major: 1, minor: 1, artworkId: 'a', range: r);
    expect(Proximity.values.where(link('immediate').inRange), [Proximity.immediate]);
    expect(Proximity.values.where(link('near').inRange), [Proximity.immediate, Proximity.near]);
    expect(Proximity.values.where(link('far').inRange), [Proximity.immediate, Proximity.near, Proximity.far]);
  });

  test('nearest in-range linked beacon wins', () {
    final links = [
      for (final (minor, id) in [(1, 'a1'), (2, 'a2'), (3, 'a3')])
        BeaconLink.fromMap({'uuid': _uuid, 'major': 1, 'minor': minor, 'linked_artwork_id': id})!,
    ];
    expect(BeaconService.nearestArtwork([_seen(1, 2.0, Proximity.near), _seen(2, 0.4, Proximity.immediate)], links), 'a2');
    expect(BeaconService.nearestArtwork([_seen(3, 6.0, Proximity.far)], links), isNull); // 기본 감지 거리는 near
    expect(BeaconService.nearestArtwork([_seen(9, 0.1, Proximity.immediate)], links), isNull); // 등록 안 된 비콘
    expect(BeaconService.nearestArtwork(const [], links), isNull);
  });
}
