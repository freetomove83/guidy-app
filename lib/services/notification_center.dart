// lib/services/notification_center.dart
// 알림 목록과 읽음·지움 상태. 기기에 저장해 화면을 나갔다 와도 유지되고, 헤더 종 아이콘의 점도 이 값을 봄
// shortcut: 알림 내용은 앱에 들어 있는 예시, 푸시 서버가 생기면 서버에서 받은 알림으로 바꿈

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── 알림 데이터 모델 ─────────────────────────────────────
enum NotifType { newGuide, purchase, creator, system, promo }

class NotifItem {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final int? coverSeed;
  final String? routeTo;

  const NotifItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    this.coverSeed,
    this.routeTo,
  });
}

// ─── 더미 알림 데이터 ─────────────────────────────────────
const _dummyNotifs = [
  NotifItem(
    id: 'n1',
    type: NotifType.newGuide,
    title: '새 가이드가 등록되었어요',
    body: '\'빛과 표면\' 전시의 신규 오디오 가이드 3개가 추가되었습니다.',
    timeAgo: '방금 전',
    isRead: false,
    coverSeed: 0,
    routeTo: '/detail/e1',
  ),
  NotifItem(
    id: 'n2',
    type: NotifType.purchase,
    title: '구매가 완료되었습니다',
    body: '\'도시의 결\' 오디오 가이드 결제가 정상 처리되었습니다. ₩8,000',
    timeAgo: '1시간 전',
    isRead: false,
    coverSeed: 1,
    routeTo: '/library',
  ),
  NotifItem(
    id: 'n3',
    type: NotifType.creator,
    title: '팔로우한 크리에이터 업데이트',
    body: 'Art Lab Seoul 이 새로운 가이드를 공개했습니다.',
    timeAgo: '3시간 전',
    isRead: false,
    coverSeed: 2,
    routeTo: '/creator/c1',
  ),
  NotifItem(
    id: 'n4',
    type: NotifType.promo,
    title: '이번 주 특가 혜택',
    body: '선택한 가이드 30% 할인, 오늘까지',
    timeAgo: '어제',
    isRead: true,
    coverSeed: 3,
    routeTo: '/',
  ),
  NotifItem(
    id: 'n5',
    type: NotifType.newGuide,
    title: '큐레이션 오디오 가이드 공개',
    body: '\'기억의 지형\' 전시 큐레이터 해설이 업로드되었습니다.',
    timeAgo: '2일 전',
    isRead: true,
    coverSeed: 4,
    routeTo: '/detail/e3',
  ),
  NotifItem(
    id: 'n6',
    type: NotifType.system,
    title: 'Guidy 앱이 업데이트되었습니다',
    body: 'v1.1.0 — 검색 기능 개선, 버그 수정, 성능 향상.',
    timeAgo: '3일 전',
    isRead: true,
    routeTo: null,
  ),
  NotifItem(
    id: 'n7',
    type: NotifType.creator,
    title: '크리에이터가 회신했습니다',
    body: 'Sound Journey 가 당신의 리뷰에 감사 인사를 남겼습니다.',
    timeAgo: '4일 전',
    isRead: true,
    coverSeed: 5,
    routeTo: '/creator/c2',
  ),
];

class NotificationCenter extends ChangeNotifier {
  NotificationCenter._();
  static final instance = NotificationCenter._();

  static const _kRead = 'notif_read_ids';
  static const _kGone = 'notif_dismissed_ids';
  final Set<String> _read = {};
  final Set<String> _gone = {};

  /// 지우지 않은 알림 (최신순 그대로)
  List<NotifItem> get items => [for (final n in _dummyNotifs) if (!_gone.contains(n.id)) n];
  bool isRead(NotifItem n) => n.isRead || _read.contains(n.id);
  int get unreadCount => items.where((n) => !isRead(n)).length;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _read.addAll(prefs.getStringList(_kRead) ?? const []);
      _gone.addAll(prefs.getStringList(_kGone) ?? const []);
      notifyListeners();
    } catch (e) {
      debugPrint('[Notif] 상태 불러오기 실패: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kRead, _read.toList());
      await prefs.setStringList(_kGone, _gone.toList());
    } catch (e) {
      debugPrint('[Notif] 상태 저장 실패: $e');
    }
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  void markRead(String id) {
    if (_read.add(id)) _changed();
  }

  void markAllRead() {
    _read.addAll(items.map((n) => n.id));
    _changed();
  }

  void dismiss(String id) {
    if (_gone.add(id)) _changed();
  }

  /// 모두 지우기 — 되돌리기용으로 지운 id를 돌려줌
  List<String> clearAll() {
    final ids = items.map((n) => n.id).toList();
    _gone.addAll(ids);
    _changed();
    return ids;
  }

  void restore(Iterable<String> ids) {
    _gone.removeAll(ids);
    _changed();
  }
}
