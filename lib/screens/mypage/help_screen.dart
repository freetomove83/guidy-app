// lib/screens/mypage/help_screen.dart
// 도움말 — 사용방법 / FAQ 2탭

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _tabIndex = 0;
  final _tabs = ['사용 방법', 'FAQ'];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  Text('도움말', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 탭 바
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineC)),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isA = i == _tabIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isA ? primaryC : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(_tabs[i],
                          style: TextStyle(
                            fontFamily: GuidyText.fontFamily,
                            fontSize: 14,
                            fontWeight: isA
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isA ? textC : muteC,
                          )),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: const [
                  _HowToUseTab(),
                  _FaqTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 사용 방법 탭 ──────────────────────────────────────────
class _HowToUseTab extends StatelessWidget {
  const _HowToUseTab();

  static const _steps = [
    (
      icon: Icons.search_rounded,
      title: '전시 탐색',
      desc: '홈 화면에서 큐레이션 전시, 크리에이터 채널, 아카이브를 둘러보세요. '
          '검색창에서 전시명이나 장소명으로 바로 찾을 수도 있습니다.',
    ),
    (
      icon: Icons.headphones_rounded,
      title: '오디오 가이드 미리듣기',
      desc: '전시 상세 페이지에서 작품별 오디오 가이드를 미리 들어볼 수 있습니다. '
          '미리듣기는 30초까지 무료로 제공됩니다.',
    ),
    (
      icon: Icons.shopping_bag_rounded,
      title: '가이드 구매',
      desc: '전시 전체 가이드 또는 개별 작품 가이드를 구매하세요. '
          '결제 후 기간 제한 없이 반복 감상할 수 있습니다.',
    ),
    (
      icon: Icons.place_rounded,
      title: '현장에서 감상',
      desc: '전시 현장에서 앱을 열고 QR 코드를 스캔하면 '
          '해당 작품의 오디오 가이드가 자동으로 재생됩니다.',
    ),
    (
      icon: Icons.bookmark_rounded,
      title: '즐겨찾기 & 팔로우',
      desc: '마음에 드는 전시를 즐겨찾기하고, 크리에이터를 팔로우하면 '
          '새 가이드 업로드 시 알림을 받을 수 있습니다.',
    ),
    (
      icon: Icons.mic_rounded,
      title: '크리에이터 되기',
      desc: '직접 오디오 가이드를 제작하고 판매하고 싶다면 '
          '크리에이터 신청을 통해 채널을 개설할 수 있습니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _steps.length,
      itemBuilder: (context, i) {
        final s = _steps[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceC,
            borderRadius: GuidyRadius.lgBorder,
            border: Border.all(color: lineC),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: primaryC.withOpacity(0.10),
                  borderRadius: GuidyRadius.mdBorder,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(s.icon, size: 18, color: primaryC),
                    ),
                    Positioned(
                      right: 4, bottom: 4,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: primaryC,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        style: GuidyText.body(textC)
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(s.desc, style: GuidyText.small(subC)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── FAQ 탭 ────────────────────────────────────────────────
class _FaqTab extends StatefulWidget {
  const _FaqTab();

  @override
  State<_FaqTab> createState() => _FaqTabState();
}

class _FaqTabState extends State<_FaqTab> {
  int? _expanded;

  static const _faqs = [
    (
      q: '오디오 가이드는 어떤 기기에서 사용할 수 있나요?',
      a: 'iOS(iPhone/iPad)와 Android 스마트폰, 그리고 웹 브라우저에서 모두 사용할 수 있습니다. '
         '오프라인 저장 기능을 통해 인터넷 연결이 없는 환경에서도 감상할 수 있습니다.',
    ),
    (
      q: '구매한 가이드는 얼마나 오래 사용할 수 있나요?',
      a: '구매 후 유효 기간 없이 영구적으로 사용할 수 있습니다. '
         '전시 종료 후에도 구매하신 가이드는 계속 이용 가능합니다.',
    ),
    (
      q: '환불은 가능한가요?',
      a: '가이드를 한 번도 재생하지 않은 경우에 한해 구매 후 7일 이내 환불이 가능합니다. '
         '이용내역에서 \'구매 취소\' 버튼을 눌러 직접 신청하거나, '
         '고객센터에 문의하시면 됩니다.',
    ),
    (
      q: 'QR 코드 스캔은 어떻게 하나요?',
      a: '하단 메뉴의 QR 스캔 버튼(중앙)을 탭하면 카메라가 열립니다. '
         '전시 현장에 부착된 QR 코드에 카메라를 가져다 대면 자동으로 해당 작품의 가이드가 실행됩니다.',
    ),
    (
      q: '크리에이터 신청 자격이 있나요?',
      a: '예술, 문화, 역사 분야에 관심과 지식이 있는 누구나 신청할 수 있습니다. '
         '전문 자격증은 필요하지 않으며, 열정과 콘텐츠 제작 의지가 가장 중요합니다.',
    ),
    (
      q: '수익 정산은 어떻게 이루어지나요?',
      a: '크리에이터 판매 수익의 70%가 정산됩니다. 정산은 매월 말일 기준으로 집계되며, '
         '다음 달 15일 이내에 등록하신 계좌로 입금됩니다. 최소 정산 금액은 10,000원입니다.',
    ),
    (
      q: '비밀번호를 잊어버렸어요.',
      a: '로그인 화면에서 \'비밀번호 찾기\'를 탭하면 이메일 인증을 통해 재설정할 수 있습니다. '
         '소셜 로그인(Google/Apple)으로 가입하신 경우 해당 계정으로 로그인해주세요.',
    ),
    (
      q: '앱 알림이 오지 않아요.',
      a: '기기 설정 > 알림 > Guidy에서 알림 허용이 켜져 있는지 확인해주세요. '
         '앱 내 알림 설정(내 정보 > 알림 설정)에서도 원하는 알림 종류를 켤 수 있습니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _faqs.length,
      itemBuilder: (context, i) {
        final faq      = _faqs[i];
        final isOpen   = _expanded == i;

        return GestureDetector(
          onTap: () => setState(() => _expanded = isOpen ? null : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: surfaceC,
              borderRadius: GuidyRadius.lgBorder,
              border: Border.all(
                color: isOpen ? primaryC.withOpacity(0.4) : lineC,
                width: isOpen ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22, height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? primaryC
                              : primaryC.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('Q',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isOpen ? Colors.white : primaryC,
                              )),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(faq.q,
                            style: GuidyText.body(textC).copyWith(
                              fontWeight: isOpen
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            )),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: muteC),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(48, 0, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22, height: 22,
                          margin: const EdgeInsets.only(right: 10, top: 1),
                          decoration: BoxDecoration(
                            color: GuidyColors.ok.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('A',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: GuidyColors.ok,
                                )),
                          ),
                        ),
                        Expanded(
                          child: Text(faq.a,
                              style: GuidyText.body(subC)
                                  .copyWith(height: 1.6)),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
