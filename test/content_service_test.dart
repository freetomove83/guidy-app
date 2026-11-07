// CMS(Firestore) 문서 ↔ 앱 모델 변환 점검 — Firestore에 접속하지 않음
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/models/app_store.dart';
import 'package:guidy_audio_guide/models/models.dart';
import 'package:guidy_audio_guide/services/content_service.dart';

/// 업로드 스크립트처럼 ISO 문자열을 Timestamp로 바꿔 Firestore에서 읽은 값과 같은 모양으로
Map<String, dynamic> asStored(Map<String, dynamic> m) => {
  for (final e in m.entries)
    e.key: e.key == 'archived_at' && e.value is String ? Timestamp.fromDate(DateTime.parse(e.value)) : e.value,
};

void main() {
  test('bundled exhibitions survive the Firestore round trip', () {
    for (final e in DummyData.exhibitions) {
      final back = ContentService.exhibitionFromMap(e.id, asStored(ContentService.exhibitionToMap(e)));
      expect([back.title, back.venue, back.channel, back.price, back.isActive, back.archivedAt, back.isFreeAccess, back.creatorId],
          [e.title, e.venue, e.channel, e.price, e.isActive, e.archivedAt, e.isFreeAccess, e.creatorId], reason: e.id);
    }
  });

  test('bundled artworks and sections survive the round trip', () {
    for (final a in DummyData.artworks) {
      final back = ContentService.artworkFromMap(a.id, ContentService.artworkToMap(a, 0));
      expect([back.exhibitionId, back.title, back.audioUrl, back.durationSec, back.captions.length, back.curatorNote],
          [a.exhibitionId, a.title, a.audioUrl, a.durationSec, a.captions.length, a.curatorNote], reason: a.id);
      for (var i = 0; i < a.captions.length; i++) {
        expect(back.captions[i].text, a.captions[i].text);
        expect(back.captions[i].startSec, a.captions[i].startSec);
      }
    }
    for (final s in DummyData.sections) {
      final back = ContentService.sectionFromMap(s.id, ContentService.sectionToMap(s));
      expect([back.exhibitionId, back.order, back.title, back.artworkIds], [s.exhibitionId, s.order, s.title, s.artworkIds]);
    }
  });

  test('exhibition created in the CMS (no app-only fields) gets sensible defaults', () {
    // CmsFirestoreService._exhibitionToMap가 쓰는 필드만 있는 문서
    final cms = {
      'title': '새 전시', 'venue': '서울시립미술관', 'description': '', 'cover_url': null, 'cover_seed': 3,
      'channel': 'creator', 'creator_id': 'c1', 'creator_name': '김도슨트', 'work_count': 4, 'price': 3000,
      'duration': '40분', 'status': 'published', 'created_at': Timestamp.now(), 'plays': 0, 'rating': 4, 'review_count': 2,
    };
    final e = ContentService.exhibitionFromMap('x1', cms);
    expect(e.channel, ChannelType.creator);
    expect(e.isActive, isTrue);
    expect(e.rating, 4.0);
    expect(ContentService.exhibitionFromMap('x2', {...cms, 'channel': 'archive'}).isActive, isFalse);
    expect(ContentService.exhibitionFromMap('x3', {}).channel, ChannelType.curation);
  });

  test('replaceContent swaps exhibitions, artworks and sections but keeps creators', () {
    final store = AppStore();
    final creators = store.creators.length;
    store.replaceContent(
      exhibitions: [ContentService.exhibitionFromMap('x1', {'title': 'CMS 전시', 'status': 'published'})],
      artworks: const [],
      sections: const [],
    );
    expect(store.exhibitions.map((e) => e.title), ['CMS 전시']);
    expect(store.artworks, isEmpty);
    expect(store.creators.length, creators);
  });
}
