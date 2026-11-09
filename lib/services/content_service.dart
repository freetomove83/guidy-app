// lib/services/content_service.dart — CMS(Firestore)에서 게시한 전시·작품·섹션 불러오기
// 필드 이름은 guidy-cms의 CmsFirestoreService와 같음 (exhibitions / artworks / sections)
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_store.dart';
import '../models/models.dart';

/// CMS 설정 > 플랫폼 설정 (app_config/settings). 못 읽으면 기본값(모두 열림) 유지
class AppSettings {
  static bool maintenance = false;
  static bool signupOpen = true;
  static bool creatorApplyOpen = true;

  static Future<void> load({Duration timeout = const Duration(seconds: 6)}) async {
    try {
      final d = (await FirebaseFirestore.instance
              .collection('app_config').doc('settings').get()
              .timeout(timeout))
          .data();
      if (d == null) return;
      maintenance = d['maintenance'] == true;
      signupOpen = d['signup_open'] != false;
      creatorApplyOpen = d['creator_apply_open'] != false;
    } catch (e) {
      debugPrint('[Settings] 불러오기 실패 → 기본값: $e');
    }
  }
}

class ContentService {
  /// CMS 약관 관리에서 저장한 약관 (app_config/terms의 'service' 또는 'creator').
  /// 아직 등록 안 됨·오프라인·Firebase 없음 → null
  static Future<String?> terms(String field) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config').doc('terms').get()
          .timeout(const Duration(seconds: 6));
      final text = doc.data()?[field];
      return text is String && text.trim().isNotEmpty ? text : null;
    } catch (e) {
      debugPrint('[Content] 약관 불러오기 실패: $e');
      return null;
    }
  }

  /// Firestore에 게시된 전시가 있으면 앱 데이터를 그것으로 바꿈.
  /// 오프라인·권한 오류·게시된 전시 없음 → 앱에 들어 있는 기본 데이터를 그대로 씀.
  static Future<void> load(AppStore store, {Duration timeout = const Duration(seconds: 6)}) async {
    try {
      final db = FirebaseFirestore.instance;
      final results = await Future.wait([
        db.collection('exhibitions').where('status', isEqualTo: 'published').get(),
        db.collection('artworks').get(),
        db.collection('sections').get(),
      ]).timeout(timeout);
      final exhibitions = results[0].docs.map((d) => exhibitionFromMap(d.id, d.data())).toList();
      if (exhibitions.isEmpty) {
        debugPrint('[Content] Firestore에 게시된 전시 없음 → 기본 데이터 사용');
        return;
      }
      final ids = exhibitions.map((e) => e.id).toSet();
      bool published(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
          ids.contains(d.data()['exhibition_id']);
      final artworkDocs = results[1].docs.where(published).toList()
        ..sort((a, b) => _int(a.data()['order']).compareTo(_int(b.data()['order'])));
      store.replaceContent(
        exhibitions: exhibitions,
        artworks: [for (final d in artworkDocs) artworkFromMap(d.id, d.data())],
        sections: [for (final d in results[2].docs.where(published)) sectionFromMap(d.id, d.data())],
      );
      debugPrint('[Content] Firestore 전시 ${exhibitions.length}개 사용');
    } on TimeoutException {
      debugPrint('[Content] Firestore 응답 없음 → 기본 데이터 사용');
    } catch (e) {
      debugPrint('[Content] Firestore 불러오기 실패 → 기본 데이터 사용: $e');
    }
  }

  /// CMS에서 승인한 크리에이터를 앱 목록에 더함 (같은 id면 Firestore 값으로 바꿈)
  static Future<void> loadCreators(AppStore store, {Duration timeout = const Duration(seconds: 6)}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('creators').where('status', isEqualTo: 'approved').get()
          .timeout(timeout);
      store.mergeCreators([for (final d in snap.docs) creatorFromMap(d.id, d.data())]);
      debugPrint('[Content] 승인된 크리에이터 ${snap.docs.length}명');
    } catch (e) {
      debugPrint('[Content] 크리에이터 불러오기 실패 → 기본 데이터 사용: $e');
    }
  }

  // ── Firestore map ↔ 모델 ──────────────────────────────────

  static Exhibition exhibitionFromMap(String id, Map<String, dynamic> d) {
    final channel = _channel(d['channel'] as String?);
    return Exhibition(
      id: id,
      title: d['title'] as String? ?? '',
      venue: d['venue'] as String? ?? '',
      description: d['description'] as String? ?? '',
      coverUrl: d['cover_url'] as String?,
      coverSeed: _int(d['cover_seed']),
      channel: channel,
      creatorId: d['creator_id'] as String?,
      creatorName: d['creator_name'] as String?,
      workCount: _int(d['work_count']),
      price: _int(d['price']),
      duration: d['duration'] as String? ?? '',
      // CMS에서 새로 만든 전시에는 is_active가 없음 → 아카이브 채널이 아니면 진행 중
      isActive: d['is_active'] as bool? ?? channel != ChannelType.archive,
      archivedAt: (d['archived_at'] as Timestamp?)?.toDate(),
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: _int(d['review_count']),
      isFreeAccess: d['is_free_access'] as bool? ?? false,
    );
  }

  static const _avatarColors = ['#0B3D5C', '#D97757', '#2F8F5C', '#7D6A94', '#B5523B', '#3E6E8E'];

  /// 필드 이름은 CmsFirestoreService._creatorToMap과 같음. 크리에이터 신청서는 name·title·bio만 있음
  static Creator creatorFromMap(String id, Map<String, dynamic> d) => Creator(
    id: id,
    name: d['name'] as String? ?? '',
    title: d['title'] as String? ?? '',
    bio: d['bio'] as String? ?? '',
    avatarUrl: d['avatar_url'] as String?,
    // 사진이 없을 때 원 색 — id로 정해서 매번 같은 색
    avatarColor: _avatarColors[id.codeUnits.fold(0, (a, c) => a + c) % _avatarColors.length],
    followerCount: _int(d['follower_count']),
    totalPlays: _int(d['total_plays']),
    guideCount: _int(d['guide_count']),
    isVerified: d['is_verified'] as bool? ?? false,
  );

  static Artwork artworkFromMap(String id, Map<String, dynamic> d) => Artwork(
    id: id,
    exhibitionId: d['exhibition_id'] as String? ?? '',
    title: d['title'] as String? ?? '',
    artist: d['artist'] as String? ?? '',
    material: d['material'] as String? ?? '',
    imageUrl: d['image_url'] as String?,
    imageSeed: _int(d['image_seed']),
    audioUrl: d['audio_url'] as String?,
    durationSec: _int(d['duration_sec']),
    captions: [
      for (final c in (d['captions'] as List<dynamic>? ?? const []))
        Caption(
          startSec: ((c as Map)['start_sec'] as num?)?.toDouble() ?? 0,
          endSec: (c['end_sec'] as num?)?.toDouble() ?? 0,
          text: c['text'] as String? ?? '',
        ),
    ],
    description: d['description'] as String? ?? '',
    curatorNote: d['curator_note'] as String? ?? '',
  );

  static ExhibitionSection sectionFromMap(String id, Map<String, dynamic> d) => ExhibitionSection(
    id: id,
    exhibitionId: d['exhibition_id'] as String? ?? '',
    order: _int(d['order']),
    title: d['title'] as String? ?? '',
    description: d['description'] as String? ?? '',
    imageUrl: d['image_url'] as String?,
    imageSeed: _int(d['image_seed']),
    artworkIds: [for (final a in (d['artwork_ids'] as List<dynamic>? ?? const [])) a as String],
  );

  /// 시드용 (tool/export_content.dart). archived_at은 ISO 문자열 — 업로드 스크립트가 Timestamp로 바꿈
  static Map<String, dynamic> exhibitionToMap(Exhibition e) => {
    'title': e.title,
    'venue': e.venue,
    'description': e.description,
    'cover_url': e.coverUrl,
    'cover_seed': e.coverSeed,
    'channel': e.channel.name,
    'creator_id': e.creatorId,
    'creator_name': e.creatorName,
    'work_count': e.workCount,
    'price': e.price,
    'duration': e.duration,
    'status': 'published',
    'is_active': e.isActive,
    'archived_at': e.archivedAt?.toUtc().toIso8601String(),
    'rating': e.rating,
    'review_count': e.reviewCount,
    'is_free_access': e.isFreeAccess,
    'plays': 0,
  };

  static Map<String, dynamic> artworkToMap(Artwork a, int order) => {
    'exhibition_id': a.exhibitionId,
    'title': a.title,
    'artist': a.artist,
    'material': a.material,
    'image_url': a.imageUrl,
    'image_seed': a.imageSeed,
    'audio_url': a.audioUrl,
    'duration_sec': a.durationSec,
    'description': a.description,
    'curator_note': a.curatorNote,
    'captions': [
      for (final c in a.captions) {'start_sec': c.startSec, 'end_sec': c.endSec, 'text': c.text}
    ],
    'order': order,
  };

  static Map<String, dynamic> sectionToMap(ExhibitionSection s) => {
    'exhibition_id': s.exhibitionId,
    'order': s.order,
    'title': s.title,
    'description': s.description,
    'image_url': s.imageUrl,
    'image_seed': s.imageSeed,
    'artwork_ids': s.artworkIds,
  };

  static ChannelType _channel(String? s) =>
      ChannelType.values.firstWhere((c) => c.name == s, orElse: () => ChannelType.curation);

  static int _int(Object? v) => (v as num?)?.toInt() ?? 0;
}
