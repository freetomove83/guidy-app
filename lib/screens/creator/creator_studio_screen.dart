// lib/screens/creator/creator_studio_screen.dart
// 크리에이터 스튜디오 화면 (대시보드 + 가이드 편집 + 온보딩 + 프로필 활동 편집)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../widgets/common_widgets.dart';

// ─── 크리에이터 스튜디오 메인 ─────────────────────────────
class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({super.key});

  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> {
  bool _isApproved = false; // 심사 상태 시뮬

  @override
  Widget build(BuildContext context) {
    if (!_isApproved) return _CreatorOnboardingScreen(onApproved: () => setState(() => _isApproved = true));
    return const _CreatorDashboard();
  }
}

// ─── 대시보드 ─────────────────────────────────────────────
class _CreatorDashboard extends StatelessWidget {
  const _CreatorDashboard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? GuidyColors.darkCreator.withOpacity(0.2) : GuidyColors.creatorSoft,
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Text('크리에이터 스튜디오', style: GuidyText.kicker(isDark ? GuidyColors.darkCreator : GuidyColors.creator)),
                  ),
                  const Spacer(),
                  Icon(Icons.notifications_outlined, color: textC, size: 22),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(DummyData.creators.first.name, style: GuidyText.h2(textC)),
            ),

            // 이달 예상 수익 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? GuidyColors.darkSurface : GuidyColors.ink,
                  borderRadius: GuidyRadius.xlBorder,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이달 예상 수익', style: GuidyText.small(Colors.white.withOpacity(0.6))),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('₩428,000', style: TextStyle(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800,
                          letterSpacing: -0.8, fontFamily: GuidyText.fontFamily,
                        )),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GuidyColors.ok.withOpacity(0.2),
                              borderRadius: GuidyRadius.pillBorder,
                            ),
                            child: const Text('+18%', style: TextStyle(
                              color: GuidyColors.ok, fontSize: 12, fontWeight: FontWeight.w800,
                              fontFamily: GuidyText.fontFamily,
                            )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 미니 차트
                    SizedBox(
                      height: 40,
                      child: CustomPaint(
                        painter: _MiniChartPainter(color: accentC),
                        size: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('다음 정산: 매월 15일', style: GuidyText.small(Colors.white.withOpacity(0.6))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KPI 3개
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _kpiCard('청취', '8,420', Icons.headphones_outlined, accentC, surfaceC, lineC, textC, subC),
                  const SizedBox(width: 10),
                  _kpiCard('판매', '142건', Icons.shopping_bag_outlined, isDark ? GuidyColors.darkPrimary : GuidyColors.primary, surfaceC, lineC, textC, subC),
                  const SizedBox(width: 10),
                  _kpiCard('팔로워', '12.4k', Icons.people_outline_rounded, GuidyColors.ok, surfaceC, lineC, textC, subC),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 내 가이드
            SectionHeader(title: '내 가이드', action: '새 가이드 +',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideEditScreen()))),
            ...DummyData.exhibitions.take(3).toList().asMap().entries.map((e) {
              final ex = e.value;
              final statusLabels = ['공개', '심사중', '초안'];
              final statusColors = [GuidyColors.ok, GuidyColors.warn, muteC];
              final idx = e.key % 3;
              return Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surfaceC,
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: lineC),
                ),
                child: Row(
                  children: [
                    GuidyCover(seed: ex.coverSeed, width: 52, height: 52, borderRadius: GuidyRadius.lgBorder),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColors[idx].withOpacity(0.15),
                                  borderRadius: GuidyRadius.pillBorder,
                                ),
                                child: Text(statusLabels[idx],
                                  style: GuidyText.kicker(statusColors[idx])),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(ex.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('청취 ${e.key * 324 + 89}회 · 수익 ₩${(e.key + 1) * 34200}',
                            style: GuidyText.small(subC)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideEditScreen())),
                      child: Icon(Icons.edit_outlined, color: muteC, size: 18),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // ── 프로필 활동 관리 ───────────────────────────
            _ActivityManagementSection(
              bgC: bgC, textC: textC, subC: subC,
              muteC: muteC, surfaceC: surfaceC, lineC: lineC,
            ),

            const SizedBox(height: 20),

            // 정산 안내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? GuidyColors.darkBgAlt : GuidyColors.bgAlt,
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: lineC),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: accentC.withOpacity(0.15),
                        borderRadius: GuidyRadius.lgBorder,
                      ),
                      child: Icon(Icons.account_balance_wallet_outlined, color: accentC, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('수수료 20% · 80% 정산', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                          Text('매월 15일 자동 정산', style: GuidyText.small(subC)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: muteC),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, Color surface, Color line, Color textC, Color subC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: GuidyText.h3(textC)),
            Text(label, style: GuidyText.small(subC)),
          ],
        ),
      ),
    );
  }
}

// ─── 가이드 편집 ─────────────────────────────────────────
class GuideEditScreen extends StatefulWidget {
  const GuideEditScreen({super.key});

  @override
  State<GuideEditScreen> createState() => _GuideEditScreenState();
}

class _GuideEditScreenState extends State<GuideEditScreen> {
  int _step = 2; // 0:기본정보, 1:섹션/작품, 2:오디오, 3:가격
  final _steps = ['기본정보', '작품', '오디오', '가격'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textC),
                  ),
                  const Spacer(),
                  Text('자동저장됨', style: GuidyText.small(muteC)),
                  const SizedBox(width: 12),
                  PillButton(label: '미리보기', size: 'sm'),
                  const SizedBox(width: 8),
                  PillButton(label: '출시', size: 'sm', primary: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 프로그레스 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_steps.length, (i) {
                  final isDone = i < _step;
                  final isActive = i == _step;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _step = i),
                            child: Column(
                              children: [
                                Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: isDone || isActive ? primaryC : lineC,
                                    borderRadius: GuidyRadius.pillBorder,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(_steps[i], style: GuidyText.kicker(isActive ? primaryC : muteC)),
                              ],
                            ),
                          ),
                        ),
                        if (i < _steps.length - 1) const SizedBox(width: 4),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // 콘텐츠 (3단계: 오디오 녹음)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text('오디오 녹음', style: GuidyText.h3(textC)),
                  const SizedBox(height: 4),
                  Text('각 작품의 오디오 해설을 녹음하거나 AI TTS로 생성하세요', style: GuidyText.body(subC)),
                  const SizedBox(height: 16),

                  // 작품별 오디오 상태
                  ...DummyData.artworks.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final a = entry.value;
                    final statuses = ['완료', '녹음 중', '없음'];
                    final st = statuses[idx % 3];
                    final stColor = st == '완료' ? GuidyColors.ok : st == '녹음 중' ? GuidyColors.danger : muteC;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: st == '없음' ? GuidyColors.warn.withOpacity(0.08) : surfaceC,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: st == '없음' ? GuidyColors.warn.withOpacity(0.3) : lineC),
                      ),
                      child: Row(
                        children: [
                          GuidyCover(seed: a.imageSeed, width: 44, height: 44, borderRadius: GuidyRadius.lgBorder),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                                Row(children: [
                                  Container(
                                    width: 6, height: 6,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(color: stColor, shape: BoxShape.circle),
                                  ),
                                  Text(st, style: GuidyText.small(stColor).copyWith(fontWeight: FontWeight.w700)),
                                ]),
                              ],
                            ),
                          ),
                          if (st == '완료')
                            Icon(Icons.play_circle_outlined, color: GuidyColors.ok, size: 24)
                          else if (st == '녹음 중')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: GuidyColors.danger, borderRadius: GuidyRadius.pillBorder),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                                SizedBox(width: 4),
                                Text('REC', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: GuidyText.fontFamily)),
                              ]),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: surfaceC,
                                borderRadius: GuidyRadius.pillBorder,
                                border: Border.all(color: lineC),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.add, color: muteC, size: 12),
                                const SizedBox(width: 2),
                                Text('녹음', style: GuidyText.kicker(muteC)),
                              ]),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // AI TTS 배너
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryC.withOpacity(0.1), accentC.withOpacity(0.1)],
                      ),
                      borderRadius: GuidyRadius.lgBorder,
                      border: Border.all(color: primaryC.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: primaryC, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI TTS로 자동 생성', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w800)),
                              Text('스크립트만 있으면 자연스러운 낭독을 생성합니다', style: GuidyText.small(subC)),
                            ],
                          ),
                        ),
                        PillButton(label: '사용하기', primary: true, size: 'sm'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 하단 네비
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: bgC,
                border: Border(top: BorderSide(color: lineC)),
              ),
              child: Row(
                children: [
                  PillButton(label: '← 이전', onPressed: _step > 0 ? () => setState(() => _step--) : null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _step < 3 ? () => setState(() => _step++) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: textC,
                          borderRadius: GuidyRadius.pillBorder,
                        ),
                        child: Text(
                          _step < 3 ? '다음 단계 →' : '출시하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: bgC, fontSize: 15, fontWeight: FontWeight.w800,
                            fontFamily: GuidyText.fontFamily),
                        ),
                      ),
                    ),
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

// ─── 크리에이터 온보딩 (심사) ─────────────────────────────
class _CreatorOnboardingScreen extends StatelessWidget {
  final VoidCallback onApproved;
  const _CreatorOnboardingScreen({required this.onApproved});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        backgroundColor: bgC,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textC),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('크리에이터 신청 · 진행 상황', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 히어로 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentC,
              borderRadius: GuidyRadius.xlBorder,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _HeroBgPainterStudio()),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: GuidyRadius.pillBorder,
                      ),
                      child: const Text('PENDING', style: TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800,
                        letterSpacing: 1, fontFamily: GuidyText.fontFamily,
                      )),
                    ),
                    const SizedBox(height: 12),
                    const Text('거의 다 왔어요!', style: TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
                      fontFamily: GuidyText.fontFamily,
                    )),
                    const SizedBox(height: 4),
                    Text('평균 3~5일 내에 결과를 알려드립니다', style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 13,
                      fontFamily: GuidyText.fontFamily,
                    )),
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.calendar_today_outlined, color: Colors.white.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Text('신청일: 2026.09.01', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: GuidyText.fontFamily)),
                    ]),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 심사 타임라인
          Text('심사 진행 상황', style: GuidyText.h3(textC)),
          const SizedBox(height: 12),
          ..._timelineItems(textC, subC, muteC, surfaceC, lineC, accentC, isDark ? GuidyColors.darkPrimary : GuidyColors.primary),

          const SizedBox(height: 24),

          // 제출 정보
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
                Text('제출한 정보', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _infoRow('활동명', '김도슨트', textC, subC),
                _infoRow('전문 분야', '미술사, 현대미술', textC, subC),
                _infoRow('포트폴리오', 'portfolio.com/kim', textC, subC),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 문의 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? GuidyColors.darkBgAlt : GuidyColors.bgAlt,
              borderRadius: GuidyRadius.lgBorder,
            ),
            child: Row(
              children: [
                Icon(Icons.mail_outline_rounded, color: muteC, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('문의사항이 있으신가요?', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                      Text('creator@guidy.app', style: GuidyText.small(subC)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 개발 모드: 승인 버튼
          GestureDetector(
            onTap: onApproved,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: GuidyColors.ok.withOpacity(0.15),
                borderRadius: GuidyRadius.pillBorder,
                border: Border.all(color: GuidyColors.ok),
              ),
              child: const Text('[개발 모드] 심사 승인 시뮬레이션',
                textAlign: TextAlign.center,
                style: TextStyle(color: GuidyColors.ok, fontWeight: FontWeight.w700,
                  fontFamily: GuidyText.fontFamily)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _timelineItems(Color textC, Color subC, Color muteC, Color surfaceC, Color lineC, Color accentC, Color primaryC) {
    final items = [
      {'label': '신청서 제출', 'sub': '2026.09.01', 'done': true, 'active': false},
      {'label': '기본 요건 확인', 'sub': '통과 · 인증됨', 'done': true, 'active': false},
      {'label': '포트폴리오 심사', 'sub': '진행 중', 'done': false, 'active': true},
      {'label': '최종 승인 · 스튜디오 개설', 'sub': '대기 중', 'done': false, 'active': false},
    ];

    return items.asMap().entries.map((e) {
      final i = e.key;
      final item = e.value;
      final isDone = item['done'] as bool;
      final isActive = item['active'] as bool;
      final dotColor = isDone ? GuidyColors.ok : isActive ? accentC : lineC;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(isDone || isActive ? 1 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : isActive
                      ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                      : Container(width: 6, height: 6, decoration: BoxDecoration(color: muteC, shape: BoxShape.circle)),
                ),
              ),
              if (i < items.length - 1)
                Container(width: 1.5, height: 36, color: isDone ? GuidyColors.ok.withOpacity(0.3) : lineC),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['label'] as String, style: GuidyText.body(textC).copyWith(
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                )),
                Text(item['sub'] as String, style: GuidyText.small(subC)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _infoRow(String label, String value, Color textC, Color subC) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: GuidyText.small(subC))),
          Text(value, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HeroBgPainterStudio extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 60, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _MiniChartPainter extends CustomPainter {
  final Color color;
  const _MiniChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75, 0.9];
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // 그라디언트 채우기
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}


// ─── 프로필 활동 관리 섹션 ────────────────────────────────
class _ActivityManagementSection extends StatelessWidget {
  final Color bgC, textC, subC, muteC, surfaceC, lineC;

  const _ActivityManagementSection({
    required this.bgC,
    required this.textC,
    required this.subC,
    required this.muteC,
    required this.surfaceC,
    required this.lineC,
  });

  static const String _mockCreatorId = 'c1';

  @override
  Widget build(BuildContext context) {
    final appStore = context.watch<AppStore>();
    final creator  = appStore.creatorById(_mockCreatorId);
    if (creator == null) return const SizedBox.shrink();

    final activities = creator.activities;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Text('프로필 활동', style: GuidyText.h3(textC)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddDialog(context, creator),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryC.withOpacity(0.1),
                    borderRadius: GuidyRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: primaryC, size: 14),
                      const SizedBox(width: 4),
                      Text('추가', style: GuidyText.kicker(primaryC)
                          .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, color: muteC, size: 18),
                  const SizedBox(width: 10),
                  Text('유튜브, 인스타그램, 강연 등 활동을 추가하세요',
                      style: GuidyText.small(subC)),
                ],
              ),
            ),
          )
        else
          ...activities.asMap().entries.map((entry) {
            final i = entry.key;
            final act = entry.value;
            return Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC),
              ),
              child: Row(
                children: [
                  Icon(_iconFor(act.type), size: 18, color: muteC),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(act.label,
                            style: GuidyText.body(textC)
                                .copyWith(fontWeight: FontWeight.w600)),
                        if (act.detail.isNotEmpty)
                          Text(act.detail, style: GuidyText.small(subC)),
                        if (act.url != null && act.url!.isNotEmpty)
                          Text(act.url!,
                              style: GuidyText.kicker(muteC),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showEditDialog(context, creator, act, i),
                    child: Icon(Icons.edit_outlined, size: 16, color: muteC),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      final newList = List<CreatorActivity>.from(activities)
                        ..removeAt(i);
                      context.read<AppStore>()
                          .updateCreatorActivities(_mockCreatorId, newList);
                    },
                    child: Icon(Icons.delete_outline_rounded,
                        size: 16, color: GuidyColors.danger),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  IconData _iconFor(ActivityType type) {
    switch (type) {
      case ActivityType.youtube:   return Icons.smart_display_outlined;
      case ActivityType.instagram: return Icons.camera_alt_outlined;
      case ActivityType.blog:      return Icons.article_outlined;
      case ActivityType.podcast:   return Icons.podcasts_rounded;
      case ActivityType.lecture:   return Icons.mic_external_on_outlined;
      case ActivityType.career:    return Icons.work_outline_rounded;
      case ActivityType.other:     return Icons.link_rounded;
    }
  }

  void _showAddDialog(BuildContext ctx, Creator creator) => showDialog(
    context: ctx,
    builder: (_) => _ActivityDialog(
      creatorId: creator.id,
      existing: null,
      existingList: creator.activities,
    ),
  );

  void _showEditDialog(BuildContext ctx, Creator creator, CreatorActivity act, int idx) =>
    showDialog(
      context: ctx,
      builder: (_) => _ActivityDialog(
        creatorId: creator.id,
        existing: act,
        existingList: creator.activities,
        editIndex: idx,
      ),
    );
}

// ─── 활동 추가/수정 다이얼로그 ───────────────────────────
class _ActivityDialog extends StatefulWidget {
  final String creatorId;
  final CreatorActivity? existing;
  final List<CreatorActivity> existingList;
  final int? editIndex;

  const _ActivityDialog({
    required this.creatorId,
    required this.existing,
    required this.existingList,
    this.editIndex,
  });

  @override
  State<_ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<_ActivityDialog> {
  late ActivityType _type;
  late TextEditingController _labelCtrl;
  late TextEditingController _detailCtrl;
  late TextEditingController _urlCtrl;

  static const _typeLabels = {
    ActivityType.youtube:   'YouTube',
    ActivityType.instagram: 'Instagram',
    ActivityType.blog:      '블로그',
    ActivityType.podcast:   '팟캐스트',
    ActivityType.lecture:   '강연',
    ActivityType.career:    '경력',
    ActivityType.other:     '기타',
  };

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _type       = ex?.type   ?? ActivityType.youtube;
    _labelCtrl  = TextEditingController(text: ex?.label  ?? '');
    _detailCtrl = TextEditingController(text: ex?.detail ?? '');
    _urlCtrl    = TextEditingController(text: ex?.url    ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _detailCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_labelCtrl.text.trim().isEmpty) return;
    final activity = CreatorActivity(
      id: widget.existing?.id ?? 'act_${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      label: _labelCtrl.text.trim(),
      detail: _detailCtrl.text.trim(),
      url: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
    );
    final newList = List<CreatorActivity>.from(widget.existingList);
    if (widget.editIndex != null) {
      newList[widget.editIndex!] = activity;
    } else {
      newList.add(activity);
    }
    context.read<AppStore>().updateCreatorActivities(widget.creatorId, newList);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;
    final bgC      = isDark ? GuidyColors.darkBg       : GuidyColors.bg;
    final isEdit   = widget.existing != null;

    return Dialog(
      backgroundColor: surfaceC,
      shape: RoundedRectangleBorder(borderRadius: GuidyRadius.xlBorder),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEdit ? '활동 수정' : '활동 추가', style: GuidyText.h3(textC)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: GuidyColors.mute, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('종류', style: GuidyText.small(subC)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: ActivityType.values.map((t) {
                final selected = _type == t;
                return GestureDetector(
                  onTap: () => setState(() {
                    _type = t;
                    if (_labelCtrl.text.isEmpty ||
                        _typeLabels.values.contains(_labelCtrl.text)) {
                      _labelCtrl.text = _typeLabels[t] ?? '';
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected ? primaryC.withOpacity(0.12) : bgC,
                      borderRadius: GuidyRadius.pillBorder,
                      border: Border.all(
                        color: selected ? primaryC : lineC,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(_typeLabels[t] ?? '',
                      style: GuidyText.kicker(selected ? primaryC : subC)
                          .copyWith(fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text('표시 이름 *', style: GuidyText.small(subC)),
            const SizedBox(height: 6),
            _field(_labelCtrl, '예: YouTube', bgC, lineC, textC, subC),
            const SizedBox(height: 12),

            Text('부제 (구독자 수, 방문 수 등)', style: GuidyText.small(subC)),
            const SizedBox(height: 6),
            _field(_detailCtrl, '예: 구독자 3.7만명', bgC, lineC, textC, subC),
            const SizedBox(height: 12),

            Text('링크 URL (선택)', style: GuidyText.small(subC)),
            const SizedBox(height: 6),
            _field(_urlCtrl, 'https://...', bgC, lineC, textC, subC),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: surfaceC,
                      borderRadius: GuidyRadius.mdBorder,
                      border: Border.all(color: lineC),
                    ),
                    child: Text('취소', style: GuidyText.small(textC)
                        .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: primaryC,
                      borderRadius: GuidyRadius.mdBorder,
                    ),
                    child: Text(isEdit ? '저장' : '추가',
                        style: GuidyText.small(Colors.white)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      Color bgC, Color lineC, Color textC, Color subC) {
    return Container(
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: GuidyRadius.mdBorder,
        border: Border.all(color: lineC),
      ),
      child: TextField(
        controller: ctrl,
        style: GuidyText.body(textC),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GuidyText.body(subC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
