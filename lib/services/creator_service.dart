// lib/services/creator_service.dart
// 크리에이터 신청 — creators/{uid}(공개)·creator_private/{uid}(이메일)에 저장, CMS가 심사

import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Firestore의 심사 상태 (문서 없음 → none)
enum CreatorReview { none, pending, approved, rejected }

class CreatorService {
  static final _db = FirebaseFirestore.instance;

  /// 신청서 제출. 반려된 적이 있으면 같은 문서를 다시 심사 대기로 바꿈 (규칙이 허용)
  static Future<void> apply({
    required String name,
    required String field,
    required String intro,
    String link = '',
  }) async {
    final user = AuthService.currentUser!;
    final batch = _db.batch();
    batch.set(_db.collection('creators').doc(user.uid), {
      'name': name,
      'title': field,
      'field': field,
      'bio': intro,
      'portfolio_url': link,
      'status': 'pending',
      'joined_at': FieldValue.serverTimestamp(), // CMS 목록의 신청일
    }, SetOptions(merge: true));
    batch.set(_db.collection('creator_private').doc(user.uid), {
      'email': user.email ?? '',
    }, SetOptions(merge: true));
    await batch.commit();
  }

  /// 내 심사 상태와 반려 사유
  static Future<(CreatorReview, String)> myReview() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return (CreatorReview.none, '');
    final doc = await _db.collection('creators').doc(uid).get();
    final review = switch (doc.data()?['status']) {
      'pending' => CreatorReview.pending,
      'approved' => CreatorReview.approved,
      'rejected' => CreatorReview.rejected,
      _ => CreatorReview.none,
    };
    if (review != CreatorReview.rejected) return (review, '');
    final private = await _db.collection('creator_private').doc(uid).get();
    return (review, (private.data()?['reject_reason'] as String?) ?? '');
  }
}
