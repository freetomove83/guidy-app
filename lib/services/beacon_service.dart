// lib/services/beacon_service.dart
// 비콘 감지 — CMS 장치 관리에서 작품과 연결한 iBeacon(uuid·major·minor)에 가까이 가면 그 작품을 알려 줌

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:flutter/foundation.dart';

/// CMS beacons 문서 중 앱에 필요한 것만 (필드 이름은 CmsFirestoreService.saveBeacon과 같음)
class BeaconLink {
  final String uuid;
  final int major;
  final int minor;
  final String artworkId;
  final String range; // 'immediate' | 'near' | 'far'

  const BeaconLink({required this.uuid, required this.major, required this.minor,
      required this.artworkId, this.range = 'near'});

  /// 작품이 연결되지 않았거나 iBeacon 값이 빠진 문서는 null
  static BeaconLink? fromMap(Map<String, dynamic> d) {
    final uuid = (d['uuid'] as String?)?.trim();
    final major = (d['major'] as num?)?.toInt();
    final minor = (d['minor'] as num?)?.toInt();
    final artwork = d['linked_artwork_id'] as String?;
    if (uuid == null || uuid.isEmpty || major == null || minor == null ||
        artwork == null || artwork.isEmpty) {
      return null;
    }
    return BeaconLink(uuid: uuid.toUpperCase(), major: major, minor: minor,
        artworkId: artwork, range: d['detection_range'] as String? ?? 'near');
  }

  /// CMS에서 정한 감지 거리 안에 있는지
  bool inRange(Proximity p) => switch (range) {
    'immediate' => p == Proximity.immediate,
    'far' => p != Proximity.unknown,
    _ => p == Proximity.immediate || p == Proximity.near,
  };
}

class BeaconService {
  /// 앱(휴대폰)에서만 감지 — 웹은 블루투스 비콘을 못 읽음
  static bool get supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  static Future<List<BeaconLink>> load() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('beacons').get()
          .timeout(const Duration(seconds: 6));
      return snap.docs.map((d) => BeaconLink.fromMap(d.data())).nonNulls.toList();
    } catch (e) {
      debugPrint('[Beacon] 목록 불러오기 실패: $e');
      return const [];
    }
  }

  /// 감지된 비콘 중 감지 거리 안에서 가장 가까운 것에 연결된 작품
  static String? nearestArtwork(List<Beacon> seen, List<BeaconLink> links) {
    final hits = <(double, String)>[];
    for (final b in seen) {
      for (final l in links) {
        if (l.uuid == b.proximityUUID.toUpperCase() && l.major == b.major &&
            l.minor == b.minor && l.inRange(b.proximity)) {
          hits.add((b.accuracy, l.artworkId));
        }
      }
    }
    if (hits.isEmpty) return null;
    hits.sort((a, b) => a.$1.compareTo(b.$1));
    return hits.first.$2;
  }

  /// 권한을 묻고 감지 시작. 권한·블루투스가 꺼져 있으면 false (호출한 쪽이 안내)
  static Future<bool> start() async {
    try {
      return await flutterBeacon.initializeAndCheckScanning;
    } catch (e) {
      debugPrint('[Beacon] 시작 실패: $e');
      return false;
    }
  }

  /// 가까운 작품 id 흐름. iOS는 UUID를 알아야 찾을 수 있어 등록된 UUID마다 영역을 만듦
  static Stream<String> watch(List<BeaconLink> links) {
    final uuids = {for (final l in links) l.uuid};
    final regions = [for (final u in uuids) Region(identifier: 'guidy-$u', proximityUUID: u)];
    return flutterBeacon.ranging(regions)
        .map((r) => nearestArtwork(r.beacons, links))
        .where((id) => id != null)
        .cast<String>();
  }

  static Future<void> stop() async {
    try { await flutterBeacon.close; } catch (_) {}
  }
}
