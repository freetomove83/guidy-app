// lib/screens/creator_guides/creator_guides_screen.dart
// 크리에이터 가이드 목록 화면 — 같은 전시의 크리에이터별 가이드

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';

class CreatorGuidesScreen extends StatelessWidget {
  final String exhibitionId;
  const CreatorGuidesScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context) {
    final store       = context.read<AppStore>();
    final exhibition  = store.exhibitionById(exhibitionId);
    final guides      = store.creatorGuidesFor(exhibitionId);

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgC       = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC     = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final lineC     = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final surfaceC  = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final muteC     = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final accentC   = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: surfaceC,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('크리에이터 가이드', style: GuidyText.h3(textC)),
                        if (exhibition != null)
                          Text(exhibition.title, style: GuidyText.small(subC)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── 전시 히어로 배너 ───────────────────────
            if (exhibition != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentC.withValues(alpha: 0.08),
                    borderRadius: GuidyRadius.lgBorder,
                    border: Border.all(color: accentC.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      GuidyCover(seed: exhibition.coverSeed, width: 52, height: 52, borderRadius: GuidyRadius.mdBorder),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exhibition.title,
                              style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(exhibition.venue, style: GuidyText.small(subC)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.mic_rounded, size: 12, color: accentC),
                                const SizedBox(width: 4),
                                Text('${guides.length}개의 크리에이터 가이드',
                                  style: GuidyText.kicker(accentC).copyWith(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('가이드 선택', style: GuidyText.h3(textC)),
            ),
            const SizedBox(height: 8),

            // ─── 가이드 목록 ────────────────────────────
            Expanded(
              child: guides.isEmpty
                  ? _EmptyGuides(muteC: muteC)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: guides.length,
                      itemBuilder: (context, i) => _GuideCard(
                        guide: guides[i],
                        isDark: isDark,
                        textC: textC, subC: subC,
                        lineC: lineC, surfaceC: surfaceC,
                        muteC: muteC, accentC: accentC,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 빈 상태 ────────────────────────────────────────────
class _EmptyGuides extends StatelessWidget {
  final Color muteC;
  const _EmptyGuides({required this.muteC});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded, size: 56, color: muteC),
          const SizedBox(height: 12),
          Text('아직 등록된 크리에이터 가이드가 없습니다', style: GuidyText.body(muteC)),
          const SizedBox(height: 6),
          Text('크리에이터들이 이 전시의 가이드를 준비 중이에요', style: GuidyText.small(muteC)),
        ],
      ),
    );
  }
}

// ─── 가이드 카드 ──────────────────────────────────────────
class _GuideCard extends StatelessWidget {
  final CreatorGuide guide;
  final bool isDark;
  final Color textC, subC, lineC, surfaceC, muteC, accentC;

  const _GuideCard({
    required this.guide,
    required this.isDark,
    required this.textC, required this.subC,
    required this.lineC, required this.surfaceC,
    required this.muteC, required this.accentC,
  });

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final isFollowing = userStore.isFollowing(guide.creatorId);

    // 아바타 컬러 파싱
    Color avatarColor;
    try {
      final hex = guide.avatarColor.replaceFirst('#', '');
      avatarColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      avatarColor = GuidyColors.primary;
    }

    final durationMin = guide.durationSec ~/ 60;
    final durationSec = guide.durationSec % 60;

    return GestureDetector(
      onTap: () {
        // 가이드의 첫 번째 작품으로 플레이어 이동
        final artworkId = guide.firstArtworkId ?? 'a1';
        Navigator.pushNamed(context, '/player/$artworkId');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Column(
          children: [
            // 상단: 크리에이터 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // 아바타
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: avatarColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        guide.creatorName.isNotEmpty ? guide.creatorName[0] : 'C',
                        style: TextStyle(
                          color: avatarColor,
                          fontSize: 18, fontWeight: FontWeight.w800,
                          fontFamily: GuidyText.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(guide.creatorName,
                              style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                            if (guide.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 14, color: GuidyColors.accent),
                            ],
                          ],
                        ),
                        Text(guide.creatorTitle, style: GuidyText.small(subC)),
                      ],
                    ),
                  ),
                  // 팔로우 버튼
                  GestureDetector(
                    onTap: () => context.read<UserStore>().toggleFollow(guide.creatorId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? surfaceC
                            : accentC.withValues(alpha: 0.12),
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(
                          color: isFollowing ? lineC : accentC.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        isFollowing ? '팔로잉' : '팔로우',
                        style: GuidyText.kicker(isFollowing ? muteC : accentC)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 구분선
            Divider(color: lineC, height: 1),

            // 하단: 가이드 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guide.guideTitle,
                    style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
                  if (guide.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(guide.description,
                      style: GuidyText.small(subC),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _metaStat(Icons.timer_outlined,
                        '$durationMin:${durationSec.toString().padLeft(2, '0')}', muteC),
                      const SizedBox(width: 14),
                      _metaStat(Icons.play_circle_outline_rounded,
                        _formatCount(guide.plays), muteC),
                      const SizedBox(width: 14),
                      _metaStat(Icons.star_rounded,
                        guide.rating > 0 ? guide.rating.toStringAsFixed(1) : '-', muteC,
                        iconColor: const Color(0xFFF59E0B)),
                      const Spacer(),
                      // 재생 버튼
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: accentC,
                          borderRadius: GuidyRadius.pillBorder,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('재생', style: GuidyText.small(Colors.white)
                                .copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaStat(IconData icon, String label, Color color, {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor ?? color),
        const SizedBox(width: 3),
        Text(label, style: GuidyText.kicker(color)),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000)  return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}
