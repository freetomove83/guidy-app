// lib/screens/mypage/about_screen.dart
// Guidy 소개 — 앱 정보 + 버전 히스토리

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _currentVersion = '1.0.0';

  // 버전 히스토리 (최신순)
  static const _history = [
    (
      version: '1.0.0',
      date: '2025.06.20',
      label: '정식 출시',
      labelColor: _LabelType.launch,
      updates: [
        '오디오 가이드 마켓플레이스 정식 서비스 출시',
        '큐레이션 · 크리에이터 · 아카이브 3채널 운영',
        'QR 코드 기반 현장 가이드 재생',
        '크리에이터 신청 및 스튜디오 기능',
        '이용내역 · 즐겨찾기 · 팔로우 관리',
      ],
    ),
    (
      version: '0.9.5',
      date: '2025.05.30',
      label: '베타',
      labelColor: _LabelType.beta,
      updates: [
        '다크 모드 지원 추가',
        '오디오 플레이어 UI 개선 (배속 · 북마크)',
        '전시 섹션별 가이드 분리 재생 기능',
        '구매 취소 기능 (미사용 7일 이내)',
      ],
    ),
    (
      version: '0.9.0',
      date: '2025.05.01',
      label: '베타',
      labelColor: _LabelType.beta,
      updates: [
        '팔로우 피드 및 크리에이터 프로필 화면',
        '전시 즐겨찾기 · 좋아요 기능',
        '알림 설정 세분화 (구매/가이드/크리에이터/프로모션)',
        '비밀번호 강도 인디케이터',
      ],
    ),
    (
      version: '0.8.0',
      date: '2025.04.01',
      label: '알파',
      labelColor: _LabelType.alpha,
      updates: [
        '초기 알파 버전 — 내부 테스트 배포',
        '기본 홈 화면 및 전시 상세 페이지',
        '로그인 · 회원가입 플로우',
        '오디오 가이드 재생 기본 기능',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
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
                  Text('Guidy 소개', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 4),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                children: [
                  // ── 앱 정보 카드 ──────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceC,
                      borderRadius: GuidyRadius.lgBorder,
                      border: Border.all(color: lineC),
                    ),
                    child: Column(
                      children: [
                        // 앱 아이콘
                        ClipRRect(
                          borderRadius: GuidyRadius.lgBorder,
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 64, height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: primaryC.withOpacity(0.12),
                                borderRadius: GuidyRadius.lgBorder,
                              ),
                              child: Icon(Icons.headphones_rounded,
                                  size: 32, color: primaryC),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('guidy',
                            style: GuidyText.h2(textC)
                                .copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text('오디오 가이드 마켓플레이스',
                            style: GuidyText.small(subC)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryC.withOpacity(0.10),
                            borderRadius: GuidyRadius.pillBorder,
                          ),
                          child: Text('현재 버전 v$_currentVersion',
                              style: GuidyText.small(primaryC)
                                  .copyWith(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── 소개 텍스트 ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceC,
                      borderRadius: GuidyRadius.lgBorder,
                      border: Border.all(color: lineC),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.auto_stories_rounded,
                              size: 16, color: primaryC),
                          const SizedBox(width: 6),
                          Text('서비스 소개',
                              style: GuidyText.body(textC)
                                  .copyWith(fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 10),
                        Text(
                          'Guidy는 전시, 미술관, 문화 공간을 더 깊게 즐길 수 있도록 '
                          '오디오 가이드를 큐레이션하고 판매하는 플랫폼입니다.\n\n'
                          '전문 큐레이터부터 예술을 사랑하는 누구나 '
                          '크리에이터로 활동하며 오디오 가이드를 만들고 수익을 얻을 수 있습니다.',
                          style: GuidyText.body(subC).copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 업데이트 히스토리 헤더 ─────────────
                  Row(
                    children: [
                      Icon(Icons.history_rounded,
                          size: 18, color: primaryC),
                      const SizedBox(width: 6),
                      Text('업데이트 히스토리',
                          style: GuidyText.h3(textC)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── 버전 목록 ─────────────────────────
                  ..._history.asMap().entries.map((entry) {
                    final i   = entry.key;
                    final ver = entry.value;
                    final isLatest = i == 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(
                          color: isLatest
                              ? primaryC.withOpacity(0.3)
                              : lineC,
                          width: isLatest ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 버전 헤더
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Row(
                              children: [
                                Text('v${ver.version}',
                                    style: GuidyText.h3(textC)
                                        .copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                _VersionBadge(
                                    label: ver.label,
                                    type: ver.labelColor),
                                if (isLatest) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: GuidyColors.ok
                                          .withOpacity(0.12),
                                      borderRadius: GuidyRadius.pillBorder,
                                    ),
                                    child: Text('최신',
                                        style: GuidyText.kicker(GuidyColors.ok)
                                            .copyWith(
                                                fontWeight: FontWeight.w700)),
                                  ),
                                ],
                                const Spacer(),
                                Text(ver.date,
                                    style: GuidyText.small(muteC)),
                              ],
                            ),
                          ),
                          Divider(color: lineC, height: 1),
                          // 업데이트 항목
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 10, 16, 14),
                            child: Column(
                              children: ver.updates.map((u) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 5, height: 5,
                                      margin: const EdgeInsets.only(
                                          top: 7, right: 8),
                                      decoration: BoxDecoration(
                                        color: isLatest
                                            ? primaryC
                                            : muteC,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(u,
                                          style: GuidyText.body(subC)),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _LabelType { launch, beta, alpha }

class _VersionBadge extends StatelessWidget {
  final String label;
  final _LabelType type;
  const _VersionBadge({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    final (bgColor, textColor) = switch (type) {
      _LabelType.launch => (
          primaryC.withOpacity(0.12),
          primaryC,
        ),
      _LabelType.beta => (
          const Color(0xFFF59E0B).withOpacity(0.12),
          const Color(0xFFF59E0B),
        ),
      _LabelType.alpha => (
          GuidyColors.mute.withOpacity(0.12),
          GuidyColors.mute,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: GuidyRadius.pillBorder,
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: GuidyText.fontFamily,
            fontWeight: FontWeight.w700,
            color: textColor,
          )),
    );
  }
}
