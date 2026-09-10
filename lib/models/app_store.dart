// lib/models/app_store.dart — 앱 전역 데이터 상태 관리 (localStorage 동기화)
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// CMS와 공유하는 localStorage key (같은 origin일 때 공유됨)
const _kSharedArtworks = 'guidy_shared_artworks';

class AppStore extends ChangeNotifier {
  final List<Exhibition> _exhibitions = List<Exhibition>.from(DummyData.exhibitions);
  final List<Artwork> _artworks = List<Artwork>.from(DummyData.artworks);

  // ── 초기화: localStorage에서 CMS 추가 항목 읽기 ──────────
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSharedArtworks);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        final existingIds = _artworks.map((a) => a.id).toSet();
        for (final item in list) {
          final j = item as Map<String, dynamic>;
          final artwork = _fromJson(j);
          if (!existingIds.contains(artwork.id)) {
            _artworks.add(artwork);
            existingIds.add(artwork.id);
          } else {
            // audioUrl 업데이트 (CMS에서 교체된 경우)
            final idx = _artworks.indexWhere((a) => a.id == artwork.id);
            if (idx >= 0) _artworks[idx] = artwork;
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Getters ────────────────────────────────────────────
  List<Exhibition> get exhibitions => List.unmodifiable(_exhibitions);
  List<Artwork> get artworks => List.unmodifiable(_artworks);

  List<Exhibition> get activeExhibitions =>
      _exhibitions.where((e) => e.isActive).toList();

  List<Artwork> artworksFor(String exhibitionId) =>
      _artworks.where((a) => a.exhibitionId == exhibitionId).toList();

  Exhibition? exhibitionById(String id) {
    try { return _exhibitions.firstWhere((e) => e.id == id); }
    catch (_) { return _exhibitions.isNotEmpty ? _exhibitions.first : null; }
  }

  Artwork? artworkById(String id) {
    try { return _artworks.firstWhere((a) => a.id == id); }
    catch (_) { return _artworks.isNotEmpty ? _artworks.first : null; }
  }

  // ── JSON 역직렬화 (CmsStore와 동일한 포맷) ───────────────
  static Artwork _fromJson(Map<String, dynamic> j) => Artwork(
    id: j['id'] as String,
    exhibitionId: j['exhibitionId'] as String,
    title: j['title'] as String,
    artist: j['artist'] as String? ?? '',
    material: j['material'] as String? ?? '',
    imageSeed: j['imageSeed'] as int? ?? 0,
    audioUrl: j['audioUrl'] as String?,
    durationSec: j['durationSec'] as int? ?? 180,
    description: j['description'] as String? ?? '',
    curatorNote: '',
    captions: const [],
  );
}
