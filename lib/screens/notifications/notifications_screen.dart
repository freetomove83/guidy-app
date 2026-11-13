// lib/screens/notifications/notifications_screen.dart
// Guidy 알림 센터

import 'package:flutter/material.dart';
import '../../services/notification_center.dart';
import '../../theme/app_theme.dart';

// ─── 알림 화면 ────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _center = NotificationCenter.instance;

  void _undoable(String message, List<String> ids) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(label: '되돌리기', onPressed: () => _center.restore(ids)),
      ));
  }

  void _clearAll() => _undoable('알림을 모두 지웠어요', _center.clearAll());

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: _center, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pal = GuidyPalette.of(context);
    final notifs = _center.items;
    final unreadCount = _center.unreadCount;

    // 오늘 / 이전 분리
    final todayNotifs = notifs.where(
      (n) => n.timeAgo.contains('방금') || n.timeAgo.contains('시간') || n.timeAgo == '오늘',
    ).toList();
    final olderNotifs = notifs.where(
      (n) => !(n.timeAgo.contains('방금') || n.timeAgo.contains('시간') || n.timeAgo == '오늘'),
    ).toList();

    return Scaffold(
      backgroundColor: pal.bg,
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
                        color: pal.surface,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: pal.line),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: pal.text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text('알림', style: GuidyText.h2(pal.text)),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GuidyColors.accent,
                              borderRadius: GuidyRadius.pillBorder,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: GuidyText.label(Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: _center.markAllRead,
                      child: Text('모두 읽음',
                          style: GuidyText.small(pal.primary).copyWith(fontWeight: FontWeight.w500)),
                    ),
                  if (notifs.isNotEmpty)
                    IconButton(
                      tooltip: '모두 지우기',
                      onPressed: _clearAll,
                      icon: Icon(Icons.delete_sweep_outlined, size: 22, color: pal.sub),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── 알림 목록 ────────────────────────────────
            Expanded(
              child: notifs.isEmpty
                  ? _EmptyState(muteC: pal.mute, subC: pal.sub)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        if (todayNotifs.isNotEmpty) ...[
                          _SectionLabel(label: '오늘', muteC: pal.mute),
                          ...todayNotifs.map((n) => _SwipeToDismiss(
                            id: n.id,
                            onDismissed: () {
                              _center.dismiss(n.id);
                              _undoable('알림을 지웠어요', [n.id]);
                            },
                            child: _NotifTile(
                            notif: n,
                            read: _center.isRead(n),
                            isDark: isDark,
                            surfaceC: pal.surface,
                            lineC: pal.line,
                            textC: pal.text,
                            subC: pal.sub,
                            muteC: pal.mute,
                            onTap: () {
                              _center.markRead(n.id);
                              if (n.routeTo != null) {
                                Navigator.pushNamed(context, n.routeTo!);
                              }
                            },
                          ))),
                        ],
                        if (olderNotifs.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _SectionLabel(label: '이전 알림', muteC: pal.mute),
                          ...olderNotifs.map((n) => _SwipeToDismiss(
                            id: n.id,
                            onDismissed: () {
                              _center.dismiss(n.id);
                              _undoable('알림을 지웠어요', [n.id]);
                            },
                            child: _NotifTile(
                            notif: n,
                            read: _center.isRead(n),
                            isDark: isDark,
                            surfaceC: pal.surface,
                            lineC: pal.line,
                            textC: pal.text,
                            subC: pal.sub,
                            muteC: pal.mute,
                            onTap: () {
                              _center.markRead(n.id);
                              if (n.routeTo != null) {
                                Navigator.pushNamed(context, n.routeTo!);
                              }
                            },
                          ))),
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
  final bool read;
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
    required this.read,
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
    final unread = !read;
    final unreadBg = isDark
        ? GuidyColors.darkPrimary.withValues(alpha: 0.08)
        : GuidyColors.primarySoft.withValues(alpha: 0.45);

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
                ? GuidyColors.primary.withValues(alpha: 0.18)
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
                color: _iconBg.withValues(alpha: 0.15),
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

// ─── 왼쪽으로 밀어 지우기 ─────────────────────────────────
class _SwipeToDismiss extends StatelessWidget {
  final String id;
  final VoidCallback onDismissed;
  final Widget child;
  const _SwipeToDismiss({required this.id, required this.onDismissed, required this.child});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ValueKey('notif-$id'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: GuidyColors.danger.withValues(alpha: 0.12),
            borderRadius: GuidyRadius.lgBorder,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.delete_outline_rounded, size: 18, color: GuidyColors.danger),
            const SizedBox(width: 4),
            Text('지우기', style: GuidyText.small(GuidyColors.danger).copyWith(fontWeight: FontWeight.w500)),
          ]),
        ),
        child: child,
      );
}
