// lib/screens/notifications/notifications_screen.dart
// Guidy 알림 센터

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
final _dummyNotifs = [
  const NotifItem(
    id: 'n1',
    type: NotifType.newGuide,
    title: '새 가이드가 등록되었어요',
    body: '\'빛과 표면\' 전시의 신규 오디오 가이드 3개가 추가되었습니다.',
    timeAgo: '방금 전',
    isRead: false,
    coverSeed: 0,
    routeTo: '/detail/e1',
  ),
  const NotifItem(
    id: 'n2',
    type: NotifType.purchase,
    title: '구매가 완료되었습니다',
    body: '\'도시의 결\' 오디오 가이드 결제가 정상 처리되었습니다. ₩8,000',
    timeAgo: '1시간 전',
    isRead: false,
    coverSeed: 1,
    routeTo: '/library',
  ),
  const NotifItem(
    id: 'n3',
    type: NotifType.creator,
    title: '팔로우한 크리에이터 업데이트',
    body: 'Art Lab Seoul 이 새로운 가이드를 공개했습니다.',
    timeAgo: '3시간 전',
    isRead: false,
    coverSeed: 2,
    routeTo: '/creator/c1',
  ),
  const NotifItem(
    id: 'n4',
    type: NotifType.promo,
    title: '이번 주 특가 혜택',
    body: '선택된 가이드 30% 할인 — 오늘까지만!',
    timeAgo: '어제',
    isRead: true,
    coverSeed: 3,
    routeTo: '/',
  ),
  const NotifItem(
    id: 'n5',
    type: NotifType.newGuide,
    title: '큐레이션 오디오 가이드 공개',
    body: '\'기억의 지형\' 전시 큐레이터 해설이 업로드되었습니다.',
    timeAgo: '2일 전',
    isRead: true,
    coverSeed: 4,
    routeTo: '/detail/e3',
  ),
  const NotifItem(
    id: 'n6',
    type: NotifType.system,
    title: 'Guidy 앱이 업데이트되었습니다',
    body: 'v1.1.0 — 검색 기능 개선, 버그 수정, 성능 향상.',
    timeAgo: '3일 전',
    isRead: true,
    routeTo: null,
  ),
  const NotifItem(
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

// ─── 알림 화면 ────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotifItem> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = List.from(_dummyNotifs);
  }

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifs = _notifs.map((n) => NotifItem(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        timeAgo: n.timeAgo,
        isRead: true,
        coverSeed: n.coverSeed,
        routeTo: n.routeTo,
      )).toList();
    });
  }

  void _markRead(String id) {
    setState(() {
      _notifs = _notifs.map((n) => n.id == id
          ? NotifItem(
              id: n.id, type: n.type, title: n.title,
              body: n.body, timeAgo: n.timeAgo, isRead: true,
              coverSeed: n.coverSeed, routeTo: n.routeTo,
            )
          : n).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC     = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC   = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC    = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC   = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC= isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC   = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC= isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

    // 오늘 / 이전 분리
    final todayNotifs = _notifs.where(
      (n) => n.timeAgo.contains('방금') || n.timeAgo.contains('시간') || n.timeAgo == '오늘',
    ).toList();
    final olderNotifs = _notifs.where(
      (n) => !(n.timeAgo.contains('방금') || n.timeAgo.contains('시간') || n.timeAgo == '오늘'),
    ).toList();

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 헤더 ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text('알림', style: GuidyText.h2(textC)),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GuidyColors.accent,
                              borderRadius: GuidyRadius.pillBorder,
                            ),
                            child: Text(
                              '$_unreadCount',
                              style: GuidyText.label(Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Text(
                        '모두 읽음',
                        style: GuidyText.small(primaryC)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── 알림 목록 ────────────────────────────────
            Expanded(
              child: _notifs.isEmpty
                  ? _EmptyState(muteC: muteC, subC: subC)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        if (todayNotifs.isNotEmpty) ...[
                          _SectionLabel(label: '오늘', muteC: muteC),
                          ...todayNotifs.map((n) => _NotifTile(
                            notif: n,
                            isDark: isDark,
                            surfaceC: surfaceC,
                            lineC: lineC,
                            textC: textC,
                            subC: subC,
                            muteC: muteC,
                            onTap: () {
                              _markRead(n.id);
                              if (n.routeTo != null) {
                                Navigator.pushNamed(context, n.routeTo!);
                              }
                            },
                          )),
                        ],
                        if (olderNotifs.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _SectionLabel(label: '이전 알림', muteC: muteC),
                          ...olderNotifs.map((n) => _NotifTile(
                            notif: n,
                            isDark: isDark,
                            surfaceC: surfaceC,
                            lineC: lineC,
                            textC: textC,
                            subC: subC,
                            muteC: muteC,
                            onTap: () {
                              _markRead(n.id);
                              if (n.routeTo != null) {
                                Navigator.pushNamed(context, n.routeTo!);
                              }
                            },
                          )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 섹션 레이블 ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color muteC;
  const _SectionLabel({required this.label, required this.muteC});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: GuidyText.label(muteC),
      ),
    );
  }
}

// ─── 알림 타일 ───────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final NotifItem notif;
  final bool isDark;
  final Color surfaceC, lineC, textC, subC, muteC;
  final VoidCallback onTap;

  const _NotifTile({
    required this.notif,
    required this.isDark,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
    required this.subC,
    required this.muteC,
    required this.onTap,
  });

  // 타입별 아이콘 & 색상
  IconData get _icon {
    switch (notif.type) {
      case NotifType.newGuide:  return Icons.headphones_rounded;
      case NotifType.purchase:  return Icons.receipt_long_rounded;
      case NotifType.creator:   return Icons.person_rounded;
      case NotifType.system:    return Icons.info_outline_rounded;
      case NotifType.promo:     return Icons.local_offer_rounded;
    }
  }

  Color get _iconBg {
    switch (notif.type) {
      case NotifType.newGuide:  return GuidyColors.primary;
      case NotifType.purchase:  return GuidyColors.ok;
      case NotifType.creator:   return GuidyColors.accent;
      case NotifType.system:    return GuidyColors.sub;
      case NotifType.promo:     return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notif.isRead;
    final unreadBg = isDark
        ? GuidyColors.darkPrimary.withOpacity(0.08)
        : GuidyColors.primarySoft.withOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? unreadBg : surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(
            color: unread
                ? GuidyColors.primary.withOpacity(0.18)
                : lineC,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _iconBg.withOpacity(0.15),
                borderRadius: GuidyRadius.mdBorder,
              ),
              child: Icon(_icon, size: 20, color: _iconBg),
            ),
            const SizedBox(width: 12),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GuidyText.body(textC).copyWith(
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 7, height: 7,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: GuidyColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: GuidyText.small(subC),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.timeAgo,
                    style: GuidyText.small(muteC).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 빈 상태 ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final Color muteC, subC;
  const _EmptyState({required this.muteC, required this.subC});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: GuidyColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined,
                size: 32, color: GuidyColors.primary),
          ),
          const SizedBox(height: 16),
          Text('새로운 알림이 없어요',
              style: GuidyText.h3(muteC)),
          const SizedBox(height: 6),
          Text('새 가이드, 구매, 크리에이터 소식을\n여기서 확인할 수 있어요',
              style: GuidyText.small(subC),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
