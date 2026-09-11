// lib/models/user_store.dart
// 사용자 개인화 상태 관리 (즐겨찾기/좋아요/팔로우/구매내역 + localStorage)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

const _kFavorites        = 'guidy_user_favorites';
const _kLikes            = 'guidy_user_likes';
const _kFollowing        = 'guidy_user_following';
const _kPurchases        = 'guidy_user_purchases';
const _kUserName         = 'guidy_user_name';
const _kUserEmail        = 'guidy_user_email';
const _kCreatorStatus    = 'guidy_creator_status';
const _kCreatorAppliedAt  = 'guidy_creator_applied_at';
const _kCreatorApprovedAt = 'guidy_creator_approved_at';

// 크리에이터 신청 상태 enum
enum CreatorApplyStatus {
  none,      // 신청 전
  pending,   // 접수 → 승인 대기
  approved,  // 승인 완료
}

class UserStore extends ChangeNotifier {
  // ── 개인 정보 ────────────────────────────────────────
  String _userName  = 'Guidy 사용자';
  String _userEmail = '';

  // ── 크리에이터 신청 상태 ──────────────────────────────
  CreatorApplyStatus _creatorStatus    = CreatorApplyStatus.none;
  DateTime?          _creatorAppliedAt;
  DateTime?          _creatorApprovedAt;

  // ── 개인화 데이터 ────────────────────────────────────
  final Set<String> _favorites  = {};
  final Set<String> _likes      = {};
  final Set<String> _following  = {};
  final List<Purchase> _purchases = List.from(DummyData.purchases);

  // ── Getters ─────────────────────────────────────────
  String get userName  => _userName;
  String get userEmail => _userEmail;

  CreatorApplyStatus get creatorStatus    => _creatorStatus;
  DateTime?          get creatorAppliedAt  => _creatorAppliedAt;
  DateTime?          get creatorApprovedAt => _creatorApprovedAt;
  bool get isCreator => _creatorStatus == CreatorApplyStatus.approved;

  Set<String> get favorites  => Set.unmodifiable(_favorites);
  Set<String> get likes      => Set.unmodifiable(_likes);
  Set<String> get following  => Set.unmodifiable(_following);
  List<Purchase> get purchases => List.unmodifiable(_purchases);

  List<Purchase> get activePurchases =>
      _purchases.where((p) => p.status != PurchaseStatus.cancelled).toList();

  List<Purchase> get guidePurchases =>
      _purchases.where((p) => p.isGuide).toList();

  bool hasPurchasedGuide(String guideId) => _purchases.any(
    (p) => p.guideId == guideId && p.status != PurchaseStatus.cancelled,
  );

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

      // 크리에이터 신청 상태 복원
      final statusIdx = prefs.getInt(_kCreatorStatus) ?? 0;
      _creatorStatus = CreatorApplyStatus.values[statusIdx.clamp(0, 2)];
      final appliedStr  = prefs.getString(_kCreatorAppliedAt);
      final approvedStr = prefs.getString(_kCreatorApprovedAt);
      if (appliedStr  != null) _creatorAppliedAt  = DateTime.parse(appliedStr);
      if (approvedStr != null) _creatorApprovedAt = DateTime.parse(approvedStr);

      notifyListeners();
    } catch (_) {}
  }

  // ── 크리에이터 신청 ──────────────────────────────────
  Future<void> applyCreator() async {
    _creatorStatus    = CreatorApplyStatus.pending;
    _creatorAppliedAt = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCreatorStatus, _creatorStatus.index);
    await prefs.setString(_kCreatorAppliedAt, _creatorAppliedAt!.toIso8601String());
  }

  // (관리자 승인 시뮬레이션 — 테스트용)
  Future<void> approveCreator() async {
    _creatorStatus     = CreatorApplyStatus.approved;
    _creatorApprovedAt = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCreatorStatus, _creatorStatus.index);
    await prefs.setString(_kCreatorApprovedAt, _creatorApprovedAt!.toIso8601String());
  }

  Future<void> resetCreatorStatus() async {
    _creatorStatus     = CreatorApplyStatus.none;
    _creatorAppliedAt  = null;
    _creatorApprovedAt = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCreatorStatus);
    await prefs.remove(_kCreatorAppliedAt);
    await prefs.remove(_kCreatorApprovedAt);
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
    'type': p.type.index,
    'guideId': p.guideId,
    'guideTitle': p.guideTitle,
    'creatorName': p.creatorName,
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
    type: PurchaseType.values[j['type'] as int? ?? 0],
    guideId: j['guideId'] as String?,
    guideTitle: j['guideTitle'] as String?,
    creatorName: j['creatorName'] as String?,
  );
}
