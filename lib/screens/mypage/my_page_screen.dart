// lib/screens/mypage/my_page_screen.dart
// 마이페이지 — 개인정보 / 이용내역 / 구매취소

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';
import 'notification_settings_screen.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import 'referral_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  int _tabIndex = 0;
  final _tabs = ['개인정보', '이용내역'];

  // 외부에서 탭을 전환할 수 있도록 콜백 제공
  void switchToHistory() => setState(() => _tabIndex = 1);

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgC     = isDark ? GuidyColors.darkBg    : GuidyColors.bg;
    final textC   = isDark ? GuidyColors.darkText   : GuidyColors.ink;
    final lineC   = isDark ? GuidyColors.darkLine   : GuidyColors.line;
    final muteC   = isDark ? GuidyColors.darkMute   : GuidyColors.mute;
    final primaryC= isDark ? GuidyColors.darkPrimary: GuidyColors.primary;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── 헤더 ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? GuidyColors.darkSurface : GuidyColors.surface,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('내 정보', style: GuidyText.h3(textC)),
                ],
              ),
            ),

            // ─── 탭 ────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineC)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final isA = i == _tabIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                            color: isA ? primaryC : Colors.transparent,
                            width: 2.5,
                          )),
                        ),
                        child: Text(_tabs[i], style: TextStyle(
                          fontFamily: GuidyText.fontFamily,
                          fontSize: 14,
                          fontWeight: isA ? FontWeight.w800 : FontWeight.w500,
                          color: isA ? textC : muteC,
                        )),
                      ),
                    );
                  }),
                ),
              ),
            ),

            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _ProfileTab(onGoHistory: () => setState(() => _tabIndex = 1)),
                  const _PurchaseHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 개인정보 탭 ─────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  final VoidCallback onGoHistory;
  const _ProfileTab({required this.onGoHistory});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    // didChangeDependencies에서 초기화하여 BuildContext 안전성 확보
    final userStore = context.read<UserStore>();
    _nameCtrl  = TextEditingController(text: userStore.userName);
    _emailCtrl = TextEditingController(text: userStore.userEmail);
  }

  @override
  void didUpdateWidget(covariant _ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _editing이 false일 때만 외부 변경값 동기화 (수정 중 덮어쓰기 방지)
    if (!_editing) {
      final userStore = context.read<UserStore>();
      _nameCtrl.text  = userStore.userName;
      _emailCtrl.text = userStore.userEmail;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userStore = context.read<UserStore>();
    await userStore.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보가 저장되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgC       = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC     = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC     = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC  = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC     = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final accentC   = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // 프로필 아바타
        Center(
          child: Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  color: GuidyColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userStore.userName.isNotEmpty
                        ? userStore.userName[0].toUpperCase() : 'G',
                    style: const TextStyle(
                      color: GuidyColors.primary,
                      fontSize: 32, fontWeight: FontWeight.w800,
                      fontFamily: GuidyText.fontFamily,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: accentC,
                    shape: BoxShape.circle,
                    border: Border.all(color: bgC, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 통계 카드 (각 항목 클릭 → 해당 화면 이동)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: surfaceC,
            borderRadius: GuidyRadius.lgBorder,
            border: Border.all(color: lineC),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 구매한 전시 → 이용내역 탭
              GestureDetector(
                onTap: widget.onGoHistory,
                child: _statItem(
                  '${userStore.purchases.where((p) => p.status != PurchaseStatus.cancelled).length}',
                  '구매한 전시', textC, muteC,
                ),
              ),
              Container(width: 1, height: 32, color: lineC),
              // 즐겨찾기 → 서재 즐겨찾기 탭 (index 2)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/library',
                    arguments: {'tab': 2}),
                child: _statItem(
                  '${userStore.favorites.length}', '즐겨찾기', textC, muteC,
                ),
              ),
              Container(width: 1, height: 32, color: lineC),
              // 팔로우 → 팔로잉 화면
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/following'),
                child: _statItem(
                  '${userStore.following.length}', '팔로우', textC, muteC,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 정보 입력 폼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('기본 정보', style: GuidyText.h3(textC)),
            GestureDetector(
              onTap: () {
                if (_editing) {
                  _save();
                } else {
                  setState(() => _editing = true);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _editing
                      ? accentC
                      : surfaceC,
                  borderRadius: GuidyRadius.pillBorder,
                  border: Border.all(
                    color: _editing ? accentC : lineC,
                  ),
                ),
                child: Text(
                  _editing ? '저장' : '수정',
                  style: GuidyText.small(
                    _editing ? Colors.white : muteC,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _infoField('이름', _nameCtrl, _editing, textC, subC, surfaceC, lineC, muteC),
        const SizedBox(height: 10),
        // 이메일: SSO 로그인 시 자동 입력, 항상 읽기전용
        _infoField('이메일', _emailCtrl, false, textC, subC, surfaceC, lineC, muteC,
          keyboardType: TextInputType.emailAddress,
          trailingHint: userStore.userEmail.isEmpty
              ? 'Google · Apple 로그인 시 자동으로 가져옵니다' : null),


        const SizedBox(height: 24),

        // 계정 관리
        Text('계정 관리', style: GuidyText.h3(textC)),
        const SizedBox(height: 12),
        // 초대 링크 (무료 이용권 배지 포함)
        _menuItemWithBadge(
          Icons.card_giftcard_rounded,
          '친구 초대',
          '초대하고 무료 이용권 받기',
          surfaceC, lineC, textC, subC,
          userStore.freeTickets,
          GuidyColors.ok,
          () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ReferralScreen(),
          )),
        ),
        const SizedBox(height: 8),
        _menuItem(Icons.notifications_outlined, '알림 설정', surfaceC, lineC, textC, subC, () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const NotificationSettingsScreen(),
          ));
        }),
        const SizedBox(height: 8),
        _menuItem(Icons.lock_outline_rounded, '비밀번호 변경', surfaceC, lineC, textC, subC, () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ChangePasswordScreen(),
          ));
        }),
        const SizedBox(height: 8),
        _menuItem(Icons.logout_rounded, '로그아웃', surfaceC, lineC, textC, subC, () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: surfaceC,
              title: Text('로그아웃', style: GuidyText.h3(textC)),
              content: Text('로그아웃 하시겠습니까?', style: GuidyText.body(subC)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소', style: GuidyText.body(muteC)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  child: Text('로그아웃',
                    style: GuidyText.body(Colors.red).copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _menuItem(Icons.delete_outline_rounded, '회원 탈퇴', surfaceC, lineC, textC, subC,
          () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const DeleteAccountScreen(),
          )), dangerous: true),
      ],
    );
  }

  Widget _statItem(String value, String label, Color textC, Color muteC) {
    return Column(
      children: [
        Text(value, style: GuidyText.h2(textC)),
        const SizedBox(height: 2),
        Text(label, style: GuidyText.kicker(muteC)),
      ],
    );
  }

  Widget _infoField(
    String label,
    TextEditingController ctrl,
    bool enabled,
    Color textC, Color subC, Color surfaceC, Color lineC, Color muteC, {
    TextInputType keyboardType = TextInputType.text,
    String? trailingHint,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: enabled ? surfaceC : surfaceC.withValues(alpha: 0.7),
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(
          color: enabled ? GuidyColors.primary.withValues(alpha: 0.4) : lineC,
          width: enabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: GuidyText.kicker(muteC)),
              if (!enabled && trailingHint != null) ...
                [const SizedBox(width: 6),
                Expanded(
                  child: Text(trailingHint,
                    style: GuidyText.kicker(muteC.withValues(alpha: 0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                )],
              if (!enabled && label == '이메일')
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: GuidyColors.primarySoft,
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Text('읽기전용',
                      style: GuidyText.kicker(GuidyColors.primary)
                          .copyWith(fontSize: 9)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          TextField(
            controller: ctrl,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GuidyText.body(
              enabled ? textC : muteC,
            ).copyWith(fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon, String title,
    Color surfaceC, Color lineC, Color textC, Color subC,
    VoidCallback? onTap, {bool dangerous = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: dangerous ? Colors.red : GuidyColors.mute),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: GuidyText.body(dangerous ? Colors.red : textC)
                  .copyWith(fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right_rounded, color: GuidyColors.mute, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _menuItemWithBadge(
    IconData icon, String title, String subtitle,
    Color surfaceC, Color lineC, Color textC, Color subC,
    int badgeCount, Color badgeColor,
    VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(
            color: badgeCount > 0
                ? badgeColor.withValues(alpha: 0.4)
                : lineC,
            width: badgeCount > 0 ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: GuidyRadius.mdBorder,
              ),
              child: Icon(icon, size: 18, color: badgeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GuidyText.body(textC)
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GuidyText.small(subC)),
                ],
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: GuidyRadius.pillBorder,
                ),
                child: Text('🎟 $badgeCount장',
                    style: GuidyText.kicker(Colors.white)
                        .copyWith(fontWeight: FontWeight.w700)),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: GuidyColors.mute, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── 이용내역 탭 ─────────────────────────────────────────
class _PurchaseHistoryTab extends StatelessWidget {
  const _PurchaseHistoryTab();

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final purchases = userStore.purchases;
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textC     = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC     = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC  = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC     = isDark ? GuidyColors.darkLine     : GuidyColors.line;

    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: muteC),
            const SizedBox(height: 12),
            Text('이용내역이 없습니다', style: GuidyText.body(muteC)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: purchases.length,
      itemBuilder: (context, i) => _PurchaseCard(
        purchase: purchases[i],
        isDark: isDark,
        textC: textC, subC: subC,
        muteC: muteC, surfaceC: surfaceC,
        lineC: lineC,
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final bool isDark;
  final Color textC, subC, muteC, surfaceC, lineC;

  const _PurchaseCard({
    required this.purchase,
    required this.isDark,
    required this.textC, required this.subC,
    required this.muteC, required this.surfaceC,
    required this.lineC,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch(purchase.status) {
      PurchaseStatus.active   => GuidyColors.ok,
      PurchaseStatus.unused   => const Color(0xFFF59E0B),
      PurchaseStatus.cancelled => GuidyColors.mute,
    };
    final statusLabel = switch(purchase.status) {
      PurchaseStatus.active   => '사용 중',
      PurchaseStatus.unused   => '미사용',
      PurchaseStatus.cancelled => '취소됨',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                GuidyCover(
                  seed: purchase.coverSeed,
                  width: 52, height: 52,
                  borderRadius: GuidyRadius.mdBorder,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(purchase.exhibitionTitle,
                              style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: GuidyRadius.pillBorder,
                            ),
                            child: Text(statusLabel,
                              style: GuidyText.kicker(statusColor)
                                  .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(purchase.venueName, style: GuidyText.small(subC)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(_formatPrice(purchase.pricePaid),
                            style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Text(_formatDate(purchase.purchasedAt),
                            style: GuidyText.kicker(muteC)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 취소 버튼 (미사용 상태만)
          if (purchase.isCancellable) ...[
            Divider(color: lineC, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('구매 후 미사용 시 취소 가능',
                    style: GuidyText.kicker(muteC)),
                  GestureDetector(
                    onTap: () => _confirmCancel(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text('구매 취소',
                        style: GuidyText.small(Colors.red)
                            .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 취소 일시 표시
          if (purchase.status == PurchaseStatus.cancelled && purchase.cancelledAt != null) ...[
            Divider(color: lineC, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: muteC),
                  const SizedBox(width: 4),
                  Text('취소일: ${_formatDate(purchase.cancelledAt!)}',
                    style: GuidyText.kicker(muteC)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final isDark2   = Theme.of(context).brightness == Brightness.dark;
    final surfaceC2 = isDark2 ? GuidyColors.darkSurface : GuidyColors.surface;
    final textC2    = isDark2 ? GuidyColors.darkText     : GuidyColors.ink;
    final subC2     = isDark2 ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC2    = isDark2 ? GuidyColors.darkMute     : GuidyColors.mute;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceC2,
        title: Text('구매 취소', style: GuidyText.h3(textC2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('「${purchase.exhibitionTitle}」 구매를 취소하시겠습니까?',
              style: GuidyText.body(subC2)),
            const SizedBox(height: 8),
            Text('• 미사용 구매에 한해 취소 가능\n• 취소 후 복구 불가',
              style: GuidyText.small(muteC2)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('돌아가기', style: GuidyText.body(muteC2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('취소 확인',
              style: GuidyText.body(Colors.red).copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<UserStore>().cancelPurchase(purchase.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '구매가 취소되었습니다' : '취소할 수 없는 구매입니다'),
            backgroundColor: success ? GuidyColors.ok : Colors.red,
          ),
        );
      }
    }
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₩${buf.toString()}';
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2,'0')}.${dt.day.toString().padLeft(2,'0')}';
}
