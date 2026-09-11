// lib/models/app_store.dart — 앱 전역 데이터 상태 관리 (localStorage 동기화)
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// CMS와 공유하는 localStorage key (같은 origin일 때 공유됨)
const _kSharedArtworks   = 'guidy_shared_artworks';
const _kCmsSections      = 'guidy_cms_sections';
const _kCreatorActivities = 'guidy_creator_activities';  // 크리에이터 활동 데이터

class AppStore extends ChangeNotifier {
  final List<Exhibition> _exhibitions = List<Exhibition>.from(DummyData.exhibitions);
  final List<Artwork> _artworks = List<Artwork>.from(DummyData.artworks);
  final List<ExhibitionSection> _sections = List<ExhibitionSection>.from(DummyData.sections);
  final List<CreatorGuide> _creatorGuides = List<CreatorGuide>.from(DummyData.creatorGuides);
  // 크리에이터 데이터 (activities 편집 가능하도록 mutable copy)
  final List<Creator> _creators = List<Creator>.from(DummyData.creators);

  // ── 초기화: localStorage에서 CMS 추가 항목 읽기 ──────────
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 아트워크 동기화 (CMS 업로드 오디오)
      final rawArtworks = prefs.getString(_kSharedArtworks);
      if (rawArtworks != null) {
        final List<dynamic> list = jsonDecode(rawArtworks);
        final existingIds = _artworks.map((a) => a.id).toSet();
        for (final item in list) {
          final j = item as Map<String, dynamic>;
          final artwork = _artworkFromJson(j);
          if (!existingIds.contains(artwork.id)) {
            _artworks.add(artwork);
            existingIds.add(artwork.id);
          } else {
            final idx = _artworks.indexWhere((a) => a.id == artwork.id);
            if (idx >= 0) _artworks[idx] = artwork;
          }
        }
      }

      // 2. 섹션 동기화 (CMS 섹션 imageBase64 포함)
      final rawSections = prefs.getString(_kCmsSections);
      if (rawSections != null) {
        final List<dynamic> list = jsonDecode(rawSections);
        final cmsData = list.map((e) => e as Map<String, dynamic>).toList();

        for (final j in cmsData) {
          final sectionId   = j['id'] as String;
          final imageBase64 = j['imageBase64'] as String?;
          final idx = _sections.indexWhere((s) => s.id == sectionId);

          if (idx >= 0) {
            final existing = _sections[idx];
            _sections[idx] = ExhibitionSection(
              id:            existing.id,
              exhibitionId:  existing.exhibitionId,
              order:         j['order'] as int? ?? existing.order,
              title:         j['title'] as String? ?? existing.title,
              description:   j['description'] as String? ?? existing.description,
              imageSeed:     j['imageSeed'] as int? ?? existing.imageSeed,
              imageBase64:   imageBase64,
              artworkIds:    (j['artworkIds'] as List<dynamic>?)
                              ?.map((e) => e as String).toList()
                             ?? existing.artworkIds,
            );
          } else {
            _sections.add(ExhibitionSection(
              id:           sectionId,
              exhibitionId: j['exhibitionId'] as String,
              order:        j['order'] as int? ?? 99,
              title:        j['title'] as String? ?? '',
              description:  j['description'] as String? ?? '',
              imageSeed:    j['imageSeed'] as int? ?? 0,
              imageBase64:  imageBase64,
              artworkIds:   (j['artworkIds'] as List<dynamic>?)
                              ?.map((e) => e as String).toList() ?? [],
            ));
          }
        }
      }

      // 3. 크리에이터 활동 동기화
      final rawActivities = prefs.getString(_kCreatorActivities);
      if (rawActivities != null) {
        final Map<String, dynamic> map = jsonDecode(rawActivities);
        map.forEach((creatorId, activitiesJson) {
          final idx = _creators.indexWhere((c) => c.id == creatorId);
          if (idx >= 0) {
            final activities = (activitiesJson as List<dynamic>)
                .map((e) => CreatorActivity.fromJson(e as Map<String, dynamic>))
                .toList();
            _creators[idx] = _creators[idx].copyWith(activities: activities);
          }
        });
      }

      notifyListeners();
    } catch (_) {}
  }

  // ── Getters ────────────────────────────────────────────
  List<Exhibition> get exhibitions => List.unmodifiable(_exhibitions);
  List<Artwork> get artworks => List.unmodifiable(_artworks);
  List<ExhibitionSection> get sections => List.unmodifiable(_sections);
  List<CreatorGuide> get creatorGuides => List.unmodifiable(_creatorGuides);
  List<Creator> get creators => List.unmodifiable(_creators);

  List<Exhibition> get activeExhibitions =>
      _exhibitions.where((e) => e.isActive).toList();

  List<Artwork> artworksFor(String exhibitionId) =>
      _artworks.where((a) => a.exhibitionId == exhibitionId).toList();

  List<ExhibitionSection> sectionsFor(String exhibitionId) {
    final list = _sections.where((s) => s.exhibitionId == exhibitionId).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<CreatorGuide> creatorGuidesFor(String exhibitionId) =>
      _creatorGuides.where((g) => g.exhibitionId == exhibitionId).toList();

  Exhibition? exhibitionById(String id) {
    try { return _exhibitions.firstWhere((e) => e.id == id); }
    catch (_) { return _exhibitions.isNotEmpty ? _exhibitions.first : null; }
  }

  Artwork? artworkById(String id) {
    try { return _artworks.firstWhere((a) => a.id == id); }
    catch (_) { return _artworks.isNotEmpty ? _artworks.first : null; }
  }

  ExhibitionSection? sectionById(String id) {
    try { return _sections.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }

  Creator? creatorById(String id) {
    try { return _creators.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  // ── 크리에이터 활동 업데이트 ─────────────────────────────
  Future<void> updateCreatorActivities(
    String creatorId,
    List<CreatorActivity> activities,
  ) async {
    final idx = _creators.indexWhere((c) => c.id == creatorId);
    if (idx < 0) return;
    _creators[idx] = _creators[idx].copyWith(activities: activities);
    notifyListeners();
    await _saveCreatorActivities();
  }

  Future<void> _saveCreatorActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> map = {};
      for (final c in _creators) {
        if (c.activities.isNotEmpty) {
          map[c.id] = c.activities.map((a) => a.toJson()).toList();
        }
      }
      await prefs.setString(_kCreatorActivities, jsonEncode(map));
    } catch (_) {}
  }

  // ── JSON 역직렬화 ────────────────────────────────────────
  static Artwork _artworkFromJson(Map<String, dynamic> j) => Artwork(
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
