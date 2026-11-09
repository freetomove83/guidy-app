// lib/models/app_store.dart — 앱 전역 데이터 상태 관리 (localStorage 동기화)
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// 앱 안에서만 쓰는 저장 key (CMS 콘텐츠는 ContentService가 Firestore에서 읽음)
const _kCreatorActivities = 'guidy_creator_activities';  // 크리에이터 활동 데이터

class AppStore extends ChangeNotifier {
  final List<Exhibition> _exhibitions = List<Exhibition>.from(DummyData.exhibitions);
  final List<Artwork> _artworks = List<Artwork>.from(DummyData.artworks);
  final List<ExhibitionSection> _sections = List<ExhibitionSection>.from(DummyData.sections);
  final List<CreatorGuide> _creatorGuides = List<CreatorGuide>.from(DummyData.creatorGuides);
  // 크리에이터 데이터 (activities 편집 가능하도록 mutable copy)
  final List<Creator> _creators = List<Creator>.from(DummyData.creators);
  // 기기에 저장된 활동 — Firestore 크리에이터는 init 뒤에 들어오므로 mergeCreators에서 붙임
  Map<String, List<CreatorActivity>> _savedActivities = {};

  // ── 초기화: 기기에 저장한 크리에이터 활동 읽기 ──────────
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 크리에이터 활동 복원
      final rawActivities = prefs.getString(_kCreatorActivities);
      if (rawActivities != null) {
        final Map<String, dynamic> map = jsonDecode(rawActivities);
        _savedActivities = {
          for (final e in map.entries)
            if (e.value is List)
              e.key: [for (final a in e.value as List) CreatorActivity.fromJson(a as Map<String, dynamic>)],
        };
        for (final e in _savedActivities.entries) {
          final idx = _creators.indexWhere((c) => c.id == e.key);
          if (idx >= 0) _creators[idx] = _creators[idx].copyWith(activities: e.value);
        }
      }

      notifyListeners();
    } catch (e) {
      // 일부만 복원돼도 앱은 계속 동작. 원인 추적용 로그만 남김
      debugPrint('[AppStore] 저장 데이터 복원 실패: $e');
      notifyListeners();
    }
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
    catch (_) { return null; }
  }

  Artwork? artworkById(String id) {
    try { return _artworks.firstWhere((a) => a.id == id); }
    catch (_) { return null; }
  }

  ExhibitionSection? sectionById(String id) {
    try { return _sections.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }

  Creator? creatorById(String id) {
    try { return _creators.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  /// CMS(Firestore)에서 받은 콘텐츠로 교체 — 크리에이터·크리에이터 가이드는 앱 기본 데이터 유지
  void replaceContent({
    required List<Exhibition> exhibitions,
    required List<Artwork> artworks,
    required List<ExhibitionSection> sections,
  }) {
    _exhibitions..clear()..addAll(exhibitions);
    _artworks..clear()..addAll(artworks);
    _sections..clear()..addAll(sections);
    notifyListeners();
  }

  /// CMS에서 승인한 크리에이터 반영 — 같은 id는 바꾸고(앱에서 편집한 활동은 유지) 새 사람은 뒤에 붙임
  void mergeCreators(List<Creator> creators) {
    for (final c in creators) {
      final idx = _creators.indexWhere((x) => x.id == c.id);
      if (idx >= 0) {
        _creators[idx] = c.copyWith(activities: _creators[idx].activities);
      } else {
        _creators.add(c.copyWith(activities: _savedActivities[c.id]));
      }
    }
    notifyListeners();
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
}
