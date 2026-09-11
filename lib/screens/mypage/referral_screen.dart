// lib/screens/mypage/referral_screen.dart
// 친구 초대 & 추천인 코드 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

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
    final primaryC  = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

    final myCode     = userStore.myReferralCode;
    final inviteLink = 'https://guidy.app/join?ref=$myCode';

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── 헤더 ─────────────────────────────────
            GuidyHeader(title: '친구 초대', showBack: true),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─── 히어로 배너 ─────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryC, primaryC.withValues(alpha: 0.7)],
                        ),
                        borderRadius: GuidyRadius.xlBorder,
                        boxShadow: GuidyShadow.pop,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: GuidyRadius.pillBorder,
                                ),
                                child: const Text('친구 초대 프로그램',
                                    style: TextStyle(
                                      fontFamily: GuidyText.fontFamily,
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('친구를 초대하고\n무료 이용권을 받으세요',
                              style: TextStyle(
                                fontFamily: GuidyText.fontFamily,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                                letterSpacing: -0.4,
                              )),
                          const SizedBox(height: 8),
                          Text('초대한 친구가 가입하면\n무료 오디오 가이드 이용권 1장을 드립니다',
                              style: TextStyle(
                                fontFamily: GuidyText.fontFamily,
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.5,
                              )),
                          const SizedBox(height: 16),
                          // 보상 변경 가능 안내
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: GuidyRadius.lgBorder,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.8)),
                                const SizedBox(width: 6),
                                Text('보상 정책은 운영 상황에 따라 변경될 수 있습니다',
                                    style: TextStyle(
                                      fontFamily: GuidyText.fontFamily,
                                      fontSize: 11,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── 내 초대 현황 ─────────────────────
                    Text('내 초대 현황', style: GuidyText.h3(textC)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_rounded,
                            label: '초대한 친구',
                            value: '${userStore.referralCount}명',
                            color: primaryC,
                            surfaceC: surfaceC,
                            lineC: lineC,
                            textC: textC,
                            subC: subC,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.confirmation_number_outlined,
                            label: '보유 이용권',
                            value: '${userStore.freeTickets}장',
                            color: GuidyColors.ok,
                            surfaceC: surfaceC,
                            lineC: lineC,
                            textC: textC,
                            subC: subC,
                            highlight: userStore.freeTickets > 0,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─── 내 초대 코드 ─────────────────────
                    Text('내 초대 코드', style: GuidyText.h3(textC)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Column(
                        children: [
                          // 코드 표시
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...myCode.split('').map((c) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: 38,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: primaryC.withValues(alpha: 0.08),
                                      borderRadius: GuidyRadius.mdBorder,
                                      border: Border.all(
                                          color: primaryC
                                              .withValues(alpha: 0.25)),
                                    ),
                                    child: Center(
                                      child: Text(c,
                                          style: TextStyle(
                                            fontFamily: GuidyText.fontFamily,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: primaryC,
                                            letterSpacing: 0,
                                          )),
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _CodeActionBtn(
                                  icon: Icons.copy_rounded,
                                  label: '코드 복사',
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: myCode));
                                    _showSnack(context, '초대 코드가 복사되었습니다');
                                  },
                                  primaryC: primaryC,
                                  surfaceC: surfaceC,
                                  lineC: lineC,
                                  textC: subC,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _CodeActionBtn(
                                  icon: Icons.share_rounded,
                                  label: '링크 공유',
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: inviteLink));
                                    _showSnack(context,
                                        '초대 링크가 복사되었습니다. 친구에게 전달해보세요 🎉');
                                  },
                                  primaryC: primaryC,
                                  surfaceC: surfaceC,
                                  lineC: lineC,
                                  textC: subC,
                                  filled: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 초대 링크 URL 미리보기
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: inviteLink));
                        _showSnack(context, '초대 링크가 복사되었습니다');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? GuidyColors.darkBgAlt
                              : GuidyColors.bgAlt,
                          borderRadius: GuidyRadius.lgBorder,
                          border: Border.all(color: lineC),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link_rounded,
                                size: 16, color: muteC),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                inviteLink,
                                style: GuidyText.small(subC),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryC.withValues(alpha: 0.1),
                                borderRadius: GuidyRadius.pillBorder,
                              ),
                              child: Text('복사',
                                  style: GuidyText.kicker(primaryC)
                                      .copyWith(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── 무료 이용권 섹션 ─────────────────
                    if (userStore.freeTickets > 0) ...[
                      Text('무료 이용권', style: GuidyText.h3(textC)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GuidyColors.ok.withValues(alpha: 0.06),
                          borderRadius: GuidyRadius.lgBorder,
                          border: Border.all(
                              color: GuidyColors.ok.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: GuidyColors.ok.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('🎟',
                                    style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '무료 이용권 ${userStore.freeTickets}장 보유 중',
                                    style: GuidyText.body(textC).copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '전시 상세 화면에서 유료 오디오 가이드를\n결제 없이 이용할 수 있습니다',
                                    style: GuidyText.small(subC)
                                        .copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ─── 이용 안내 ────────────────────────
                    Text('이용 안내', style: GuidyText.h3(textC)),
                    const SizedBox(height: 12),
                    _GuideStep(
                      step: '1',
                      title: '초대 코드 또는 링크 공유',
                      desc: '내 초대 코드나 링크를 친구에게 전달하세요',
                      primaryC: primaryC,
                      textC: textC,
                      subC: subC,
                      surfaceC: surfaceC,
                      lineC: lineC,
                    ),
                    const SizedBox(height: 8),
                    _GuideStep(
                      step: '2',
                      title: '친구가 코드 입력 후 가입',
                      desc: '친구가 회원가입 시 내 코드를 입력하면 연결됩니다',
                      primaryC: primaryC,
                      textC: textC,
                      subC: subC,
                      surfaceC: surfaceC,
                      lineC: lineC,
                    ),
                    const SizedBox(height: 8),
                    _GuideStep(
                      step: '3',
                      title: '무료 이용권 자동 지급',
                      desc: '가입 완료 후 내 계정에 무료 이용권 1장이 자동으로 지급됩니다',
                      primaryC: primaryC,
                      textC: textC,
                      subC: subC,
                      surfaceC: surfaceC,
                      lineC: lineC,
                    ),
                    const SizedBox(height: 8),
                    _GuideStep(
                      step: '4',
                      title: '무료 이용권으로 감상',
                      desc: '유료 오디오 가이드를 이용권 사용으로 무료 감상',
                      primaryC: GuidyColors.ok,
                      textC: textC,
                      subC: subC,
                      surfaceC: surfaceC,
                      lineC: lineC,
                    ),

                    // 테스트용 보상 추가 버튼 (개발 확인용)
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        await userStore.debugAddReward();
                        if (context.mounted) {
                          _showSnack(context, '🎟 테스트: 무료 이용권 1장이 지급되었습니다');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: surfaceC,
                          borderRadius: GuidyRadius.lgBorder,
                          border: Border.all(
                              color: lineC,
                              style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.science_outlined,
                                size: 14, color: muteC),
                            const SizedBox(width: 6),
                            Text('테스트: 초대 보상 받기 (개발 확인용)',
                                style: GuidyText.small(muteC)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: GuidyColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─── 통계 카드 ────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, surfaceC, lineC, textC, subC;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
    required this.subC,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.07) : surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(
          color: highlight ? color.withValues(alpha: 0.35) : lineC,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GuidyText.h3(highlight ? color : textC)),
              Text(label, style: GuidyText.small(subC)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 코드 액션 버튼 ───────────────────────────────────────
class _CodeActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primaryC, surfaceC, lineC, textC;
  final bool filled;

  const _CodeActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primaryC,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: filled ? primaryC : surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(
              color: filled ? primaryC : lineC),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15,
                color: filled ? Colors.white : primaryC),
            const SizedBox(width: 6),
            Text(label,
                style: GuidyText.small(filled ? Colors.white : primaryC)
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── 가이드 스텝 ──────────────────────────────────────────
class _GuideStep extends StatelessWidget {
  final String step, title, desc;
  final Color primaryC, textC, subC, surfaceC, lineC;

  const _GuideStep({
    required this.step,
    required this.title,
    required this.desc,
    required this.primaryC,
    required this.textC,
    required this.subC,
    required this.surfaceC,
    required this.lineC,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: primaryC,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                    fontFamily: GuidyText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GuidyText.body(textC)
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(desc,
                    style:
                        GuidyText.small(subC).copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
