// lib/models/app_store.dart — 앱 전역 데이터 상태 관리
import 'package:flutter/foundation.dart';
import 'models.dart';

class AppStore extends ChangeNotifier {
  // ── 전시 목록 ──────────────────────────────────────────
  final List<Exhibition> _exhibitions = List<Exhibition>.from(DummyData.exhibitions);

  // ── 작품 목록 ──────────────────────────────────────────
  final List<Artwork> _artworks = List<Artwork>.from(DummyData.artworks);

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

  // ── 작품 추가 (CMS 업로드 연동) ────────────────────────
  void addArtwork({
    required String exhibitionId,
    required String title,
    required String artist,
    String material = '',
    String description = '',
    String curatorNote = '',
    String? audioUrl,
    int durationSec = 180,
  }) {
    final newArtwork = Artwork(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      exhibitionId: exhibitionId,
      title: title,
      artist: artist,
      material: material,
      imageSeed: DateTime.now().millisecondsSinceEpoch % 999,
      audioUrl: audioUrl,
      durationSec: durationSec,
      description: description,
      curatorNote: curatorNote,
      captions: const [],
    );
    _artworks.add(newArtwork);
    notifyListeners();
  }

  void updateArtwork(Artwork updated) {
    final idx = _artworks.indexWhere((a) => a.id == updated.id);
    if (idx >= 0) {
      _artworks[idx] = updated;
      notifyListeners();
    }
  }

  void deleteArtwork(String id) {
    _artworks.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
