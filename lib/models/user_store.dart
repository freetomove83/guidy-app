// lib/models/user_store.dart
// 사용자 개인화 상태 관리 (즐겨찾기/좋아요/팔로우/구매내역 + localStorage)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

const _kFavorites    = 'guidy_user_favorites';    // 즐겨찾기 전시 ID Set
const _kLikes        = 'guidy_user_likes';         // 좋아요 전시 ID Set
const _kFollowing    = 'guidy_user_following';     // 팔로우 크리에이터 ID Set
const _kPurchases    = 'guidy_user_purchases';     // 구매 내역 JSON
const _kUserName     = 'guidy_user_name';
const _kUserEmail    = 'guidy_user_email';

class UserStore extends ChangeNotifier {
  // ── 개인 정보 ────────────────────────────────────────
  String _userName  = 'Guidy 사용자';
  String _userEmail = '';

  // ── 개인화 데이터 ────────────────────────────────────
  final Set<String> _favorites  = {};   // exhibitionId
  final Set<String> _likes      = {};   // exhibitionId
  final Set<String> _following  = {};   // creatorId
  final List<Purchase> _purchases = List.from(DummyData.purchases);

  // ── Getters ─────────────────────────────────────────
  String get userName  => _userName;
  String get userEmail => _userEmail;

  Set<String> get favorites  => Set.unmodifiable(_favorites);
  Set<String> get likes      => Set.unmodifiable(_likes);
  Set<String> get following  => Set.unmodifiable(_following);
  List<Purchase> get purchases => List.unmodifiable(_purchases);

  List<Purchase> get activePurchases =>
      _purchases.where((p) => p.status != PurchaseStatus.cancelled).toList();

  bool isFavorite(String exhibitionId) => _favorites.contains(exhibitionId);
  bool isLiked(String exhibitionId)    => _likes.contains(exhibitionId);
  bool isFollowing(String creatorId)   => _following.contains(creatorId);

  // ── 초기화: localStorage 복원 ────────────────────────
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _userName  = prefs.getString(_kUserName)  ?? 'Guidy 사용자';
      _userEmail = prefs.getString(_kUserEmail) ?? '';

      final favRaw = prefs.getStringList(_kFavorites);
      if (favRaw != null) _favorites.addAll(favRaw);

      final likesRaw = prefs.getStringList(_kLikes);
      if (likesRaw != null) _likes.addAll(likesRaw);

      final followRaw = prefs.getStringList(_kFollowing);
      if (followRaw != null) _following.addAll(followRaw);

      final purchasesRaw = prefs.getString(_kPurchases);
      if (purchasesRaw != null) {
        final List<dynamic> list = jsonDecode(purchasesRaw);
        _purchases.clear();
        _purchases.addAll(list.map((e) => _purchaseFromJson(e as Map<String, dynamic>)));
      }

      notifyListeners();
    } catch (_) {}
  }

  // ── 개인 정보 업데이트 ───────────────────────────────
  Future<void> updateProfile({String? name, String? email}) async {
    if (name  != null) _userName  = name;
    if (email != null) _userEmail = email;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName,  _userName);
    await prefs.setString(_kUserEmail, _userEmail);
  }

  // ── 즐겨찾기 토글 ────────────────────────────────────
  Future<void> toggleFavorite(String exhibitionId) async {
    if (_favorites.contains(exhibitionId)) {
      _favorites.remove(exhibitionId);
    } else {
      _favorites.add(exhibitionId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFavorites, _favorites.toList());
  }

  // ── 좋아요 토글 ──────────────────────────────────────
  Future<void> toggleLike(String exhibitionId) async {
    if (_likes.contains(exhibitionId)) {
      _likes.remove(exhibitionId);
    } else {
      _likes.add(exhibitionId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kLikes, _likes.toList());
  }

  // ── 팔로우/언팔로우 토글 ─────────────────────────────
  Future<void> toggleFollow(String creatorId) async {
    if (_following.contains(creatorId)) {
      _following.remove(creatorId);
    } else {
      _following.add(creatorId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFollowing, _following.toList());
  }

  // ── 구매 추가 ────────────────────────────────────────
  Future<void> addPurchase(Purchase purchase) async {
    _purchases.add(purchase);
    notifyListeners();
    await _savePurchases();
  }

  // ── 구매 취소 (미사용 상태만 가능) ───────────────────
  Future<bool> cancelPurchase(String purchaseId) async {
    final idx = _purchases.indexWhere((p) => p.id == purchaseId);
    if (idx < 0) return false;
    final p = _purchases[idx];
    if (!p.isCancellable) return false;

    _purchases[idx] = p.copyWith(
      status: PurchaseStatus.cancelled,
      cancelledAt: DateTime.now(),
    );
    notifyListeners();
    await _savePurchases();
    return true;
  }

  // ── localStorage 저장 ────────────────────────────────
  Future<void> _savePurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _purchases.map(_purchaseToJson).toList();
      await prefs.setString(_kPurchases, jsonEncode(list));
    } catch (_) {}
  }

  // ── JSON 직렬화 ──────────────────────────────────────
  static Map<String, dynamic> _purchaseToJson(Purchase p) => {
    'id': p.id,
    'exhibitionId': p.exhibitionId,
    'exhibitionTitle': p.exhibitionTitle,
    'venueName': p.venueName,
    'coverSeed': p.coverSeed,
    'pricePaid': p.pricePaid,
    'purchasedAt': p.purchasedAt.toIso8601String(),
    'status': p.status.index,
    'cancelledAt': p.cancelledAt?.toIso8601String(),
  };

  static Purchase _purchaseFromJson(Map<String, dynamic> j) => Purchase(
    id: j['id'] as String,
    exhibitionId: j['exhibitionId'] as String,
    exhibitionTitle: j['exhibitionTitle'] as String,
    venueName: j['venueName'] as String? ?? '',
    coverSeed: j['coverSeed'] as int? ?? 0,
    pricePaid: j['pricePaid'] as int? ?? 0,
    purchasedAt: DateTime.parse(j['purchasedAt'] as String),
    status: PurchaseStatus.values[j['status'] as int? ?? 0],
    cancelledAt: j['cancelledAt'] != null
        ? DateTime.parse(j['cancelledAt'] as String)
        : null,
  );
}
