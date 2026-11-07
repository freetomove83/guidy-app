// 앱 기본 콘텐츠(DummyData)를 Firestore 업로드용 JSON으로 내보냄 — 일반 테스트에는 포함되지 않음
//   flutter test tool/export_content_test.dart   → build/seed/content.json
//   python3 tool/upload_content.py ...           (업로드는 이 파일을 읽음)
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/models/models.dart';
import 'package:guidy_audio_guide/services/content_service.dart';

void main() {
  test('export bundled content for Firestore', () {
    final artworkOrder = <String, int>{};
    for (final a in DummyData.artworks) {
      artworkOrder[a.id] = DummyData.artworks.where((x) => x.exhibitionId == a.exhibitionId).toList().indexOf(a);
    }
    final content = {
      'exhibitions': {for (final e in DummyData.exhibitions) e.id: ContentService.exhibitionToMap(e)},
      'artworks': {for (final a in DummyData.artworks) a.id: ContentService.artworkToMap(a, artworkOrder[a.id]!)},
      'sections': {for (final s in DummyData.sections) s.id: ContentService.sectionToMap(s)},
    };
    final out = File('build/seed/content.json')..createSync(recursive: true);
    out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(content));
    // ignore: avoid_print
    print('wrote ${out.path}: ${DummyData.exhibitions.length} exhibitions, '
        '${DummyData.artworks.length} artworks, ${DummyData.sections.length} sections');
  });
}
