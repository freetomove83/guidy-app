// lib/screens/creator/creator_studio_screen.dart
// 크리에이터 스튜디오 화면 (대시보드 + 가이드 편집 + 온보딩 + 프로필 활동 편집)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';

// ─── 크리에이터 스튜디오 메인 ─────────────────────────────
class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({super.key});

  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> {
  // 내 정보 화면이 승인된 크리에이터만 여기로 보냄 (UserStore.isCreator)
  @override
  Widget build(BuildContext context) => const _CreatorDashboard();
}

// ─── 대시보드 ─────────────────────────────────────────────
class _CreatorDashboard extends StatelessWidget {
  const _CreatorDashboard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pal = GuidyPalette.of(context);
    final store = context.watch<AppStore>();
    final uid = AuthService.currentUser?.uid;
    final me = uid == null ? null : store.creatorById(uid);
    final myGuides = store.exhibitions.where((e) => uid != null && e.creatorId == uid).toList();

    return Scaffold(
      backgroundColor: pal.bg,
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
                      color: isDark ? GuidyColors.darkCreator.withValues(alpha: 0.2) : GuidyColors.creatorSoft,
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Text('크리에이터 스튜디오', style: GuidyText.kicker(pal.creator)),
                  ),
                  const Spacer(),
                  Icon(Icons.notifications_outlined, color: pal.text, size: 22),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(me?.name ?? '크리에이터', style: GuidyText.h2(pal.text)),
            ),

            // 수익·청취·판매는 결제·통계 연결 전까지 예시
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GuidyColors.warn.withValues(alpha: 0.12),
                borderRadius: GuidyRadius.mdBorder,
              ),
              child: Text('수익·청취·판매 숫자와 가이드 만들기는 아직 미리보기예요. 결제와 오디오 업로드를 연결하면 실제로 동작해요.',
                  style: GuidyText.small(pal.text)),
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
                    Text('이달 예상 수익', style: GuidyText.small(Colors.white.withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    // 큰 글자에서 금액과 증감 배지가 한 줄에 안 들어가면 줄바꿈
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
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
                              color: GuidyColors.ok.withValues(alpha: 0.2),
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
                        painter: _MiniChartPainter(color: pal.accent),
                        size: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('다음 정산: 매월 15일', style: GuidyText.small(Colors.white.withValues(alpha: 0.6))),
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
                  _kpiCard('청취', '8,420', Icons.headphones_outlined, pal.accent, pal.surface, pal.line, pal.text, pal.sub),
                  const SizedBox(width: 10),
                  _kpiCard('판매', '142건', Icons.shopping_bag_outlined, pal.primary, pal.surface, pal.line, pal.text, pal.sub),
                  const SizedBox(width: 10),
                  _kpiCard('팔로워', '12.4k', Icons.people_outline_rounded, GuidyColors.ok, pal.surface, pal.line, pal.text, pal.sub),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 내 가이드
            SectionHeader(title: '내 가이드', action: '새 가이드 +',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideEditScreen()))),
            if (myGuides.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text('아직 공개된 가이드가 없어요', style: GuidyText.body(pal.sub)),
              ),
            ...myGuides.asMap().entries.map((e) {
              final ex = e.value;
              // 앱은 CMS에서 게시된 전시만 받음
              const statusLabels = ['공개'];
              const statusColors = [GuidyColors.ok];
              const idx = 0;
              return Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: pal.surface,
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: pal.line),
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
                                  color: statusColors[idx].withValues(alpha: 0.15),
                                  borderRadius: GuidyRadius.pillBorder,
                                ),
                                child: Text(statusLabels[idx],
                                  style: GuidyText.kicker(statusColors[idx])),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(ex.title, style: GuidyText.body(pal.text).copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(ex.venue, style: GuidyText.small(pal.sub)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideEditScreen())),
                      child: Icon(Icons.edit_outlined, color: pal.mute, size: 18),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // ── 프로필 활동 관리 ───────────────────────────
            _ActivityManagementSection(
              bgC: pal.bg, textC: pal.text, subC: pal.sub,
              muteC: pal.mute, surfaceC: pal.surface, lineC: pal.line,
            ),

            const SizedBox(height: 20),

            // 정산 안내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: pal.bgAlt,
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: pal.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: pal.accent.withValues(alpha: 0.15),
                        borderRadius: GuidyRadius.lgBorder,
                      ),
                      child: Icon(Icons.account_balance_wallet_outlined, color: pal.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('수수료 20% · 80% 정산', style: GuidyText.body(pal.text).copyWith(fontWeight: FontWeight.w700)),
                          Text('매월 15일 자동 정산', style: GuidyText.small(pal.sub)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: pal.mute),
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
    final pal = GuidyPalette.of(context);

    return Scaffold(
      backgroundColor: pal.bg,
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
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: pal.text),
                  ),
                  const Spacer(),
                  Text('자동저장됨', style: GuidyText.small(pal.mute)),
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
                                    color: isDone || isActive ? pal.primary : pal.line,
                                    borderRadius: GuidyRadius.pillBorder,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(_steps[i], style: GuidyText.kicker(isActive ? pal.primary : pal.mute)),
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
                  Text('오디오 녹음', style: GuidyText.h3(pal.text)),
                  const SizedBox(height: 4),
                  Text('각 작품의 오디오 해설을 녹음하거나 AI TTS로 생성하세요', style: GuidyText.body(pal.sub)),
                  const SizedBox(height: 16),

                  // 작품별 오디오 상태
                  ...DummyData.artworks.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final a = entry.value;
                    final statuses = ['완료', '녹음 중', '없음'];
                    final st = statuses[idx % 3];
                    final stColor = st == '완료' ? GuidyColors.ok : st == '녹음 중' ? GuidyColors.danger : pal.mute;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: st == '없음' ? GuidyColors.warn.withValues(alpha: 0.08) : pal.surface,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: st == '없음' ? GuidyColors.warn.withValues(alpha: 0.3) : pal.line),
                      ),
                      child: Row(
                        children: [
                          GuidyCover(seed: a.imageSeed, width: 44, height: 44, borderRadius: GuidyRadius.lgBorder),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: GuidyText.body(pal.text).copyWith(fontWeight: FontWeight.w700)),
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
                                color: pal.surface,
                                borderRadius: GuidyRadius.pillBorder,
                                border: Border.all(color: pal.line),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.add, color: pal.mute, size: 12),
                                const SizedBox(width: 2),
                                Text('녹음', style: GuidyText.kicker(pal.mute)),
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
                        colors: [pal.primary.withValues(alpha: 0.1), pal.accent.withValues(alpha: 0.1)],
                      ),
                      borderRadius: GuidyRadius.lgBorder,
                      border: Border.all(color: pal.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: pal.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI TTS로 자동 생성', style: GuidyText.body(pal.text).copyWith(fontWeight: FontWeight.w800)),
                              Text('스크립트만 있으면 자연스러운 낭독을 생성합니다', style: GuidyText.small(pal.sub)),
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
                color: pal.bg,
                border: Border(top: BorderSide(color: pal.line)),
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
                          color: pal.text,
                          borderRadius: GuidyRadius.pillBorder,
                        ),
                        child: Text(
                          _step < 3 ? '다음 단계 →' : '출시하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: pal.bg, fontSize: 15, fontWeight: FontWeight.w800,
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

class _MiniChartPainter extends CustomPainter {
  final Color color;
  const _MiniChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75, 0.9];
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // 그라디언트 채우기
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
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

  @override
  Widget build(BuildContext context) {
    final appStore = context.watch<AppStore>();
    final uid = AuthService.currentUser?.uid;
    final creator = uid == null ? null : appStore.creatorById(uid);
    if (creator == null) return const SizedBox.shrink();

    final activities = creator.activities;
    final pal = GuidyPalette.of(context);

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
                    color: pal.primary.withValues(alpha: 0.1),
                    borderRadius: GuidyRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: pal.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('추가', style: GuidyText.kicker(pal.primary)
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
                          .updateCreatorActivities(creator.id, newList);
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
    final pal = GuidyPalette.of(context);
    final isEdit   = widget.existing != null;

    return Dialog(
      backgroundColor: pal.surface,
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
                Text(isEdit ? '활동 수정' : '활동 추가', style: GuidyText.h3(pal.text)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: GuidyColors.mute, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('종류', style: GuidyText.small(pal.sub)),
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
                      color: selected ? pal.primary.withValues(alpha: 0.12) : pal.bg,
                      borderRadius: GuidyRadius.pillBorder,
                      border: Border.all(
                        color: selected ? pal.primary : pal.line,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(_typeLabels[t] ?? '',
                      style: GuidyText.kicker(selected ? pal.primary : pal.sub)
                          .copyWith(fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text('표시 이름 *', style: GuidyText.small(pal.sub)),
            const SizedBox(height: 6),
            _field(_labelCtrl, '예: YouTube', pal.bg, pal.line, pal.text, pal.sub),
            const SizedBox(height: 12),

            Text('부제 (구독자 수, 방문 수 등)', style: GuidyText.small(pal.sub)),
            const SizedBox(height: 6),
            _field(_detailCtrl, '예: 구독자 3.7만명', pal.bg, pal.line, pal.text, pal.sub),
            const SizedBox(height: 12),

            Text('링크 URL (선택)', style: GuidyText.small(pal.sub)),
            const SizedBox(height: 6),
            _field(_urlCtrl, 'https://...', pal.bg, pal.line, pal.text, pal.sub),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: pal.surface,
                      borderRadius: GuidyRadius.mdBorder,
                      border: Border.all(color: pal.line),
                    ),
                    child: Text('취소', style: GuidyText.small(pal.text)
                        .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: pal.primary,
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
