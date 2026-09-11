// lib/screens/creator/creator_profile_screen.dart
// 크리에이터 프로필 화면 — 팔로우 수치 실시간 반영 + 활동 링크 + 메시지 버튼 제거

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';

class CreatorProfileScreen extends StatelessWidget {
  final String creatorId;
  const CreatorProfileScreen({super.key, required this.creatorId});

  @override
  Widget build(BuildContext context) {
    // AppStore에서 최신 Creator 데이터 (activities 포함) 읽기
    final appStore  = context.watch<AppStore>();
    final userStore = context.watch<UserStore>();

    final creator = appStore.creatorById(creatorId)
        ?? DummyData.creators.first;
    final isFollowing = userStore.isFollowing(creatorId);

    // 팔로우 수치: 실제 팔로잉 여부에 따라 +1
    final displayFollowers = creator.followerCount + (isFollowing ? 1 : 0);

    final creatorGuides = appStore.exhibitions
        .where((e) => e.creatorId == creator.id)
        .toList();

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgC       = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC     = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC     = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC  = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC     = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC  = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;
    final accentC   = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── 헤더 (뒤로가기 + 공유) ──────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Icon(Icons.share_outlined, color: textC, size: 22),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 프로필 헤더 ──────────────────────────────
                  Column(
                    children: [
                      CreatorAvatar(creator: creator, size: 80, showBadgeRing: true),
                      const SizedBox(height: 12),
                      if (creator.isVerified)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryC.withValues(alpha: 0.1),
                            borderRadius: GuidyRadius.pillBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: primaryC, size: 12),
                              const SizedBox(width: 4),
                              Text('인증 크리에이터',
                                  style: GuidyText.kicker(primaryC)),
                            ],
                          ),
                        ),
                      Text(creator.name, style: GuidyText.h2(textC)),
                      const SizedBox(height: 4),
                      Text(creator.title, style: GuidyText.body(subC)),
                      const SizedBox(height: 16),

                      // ── 통계 ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _statItem('가이드', '${creator.guideCount}', textC, subC),
                          _divider(lineC),
                          _statItem('팔로워', _formatNum(displayFollowers), textC, subC),
                          _divider(lineC),
                          _statItem('총 청취', _formatNum(creator.totalPlays), textC, subC),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── 팔로우 버튼 (메시지 버튼 제거) ─────────
                      GestureDetector(
                        onTap: () => userStore.toggleFollow(creatorId),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          decoration: BoxDecoration(
                            color: isFollowing ? lineC : textC,
                            borderRadius: GuidyRadius.pillBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFollowing
                                    ? Icons.person_remove_outlined
                                    : Icons.person_add_outlined,
                                color: isFollowing ? textC : bgC,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isFollowing ? '팔로잉' : '팔로우',
                                style: TextStyle(
                                  color: isFollowing ? textC : bgC,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: GuidyText.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 소개글 ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surfaceC,
                            borderRadius: GuidyRadius.lgBorder,
                            border: Border(
                                left: BorderSide(color: accentC, width: 3)),
                          ),
                          child: Text('"${creator.bio}"',
                              style: GuidyText.body(subC),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── 대표 가이드 ──────────────────────────────
                  const SectionHeader(title: '대표 가이드'),
                  if (creatorGuides.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: creatorGuides.length,
                        itemBuilder: (context, i) => ExhibitionCard(
                          exhibition: creatorGuides[i],
                          onTap: () => Navigator.pushNamed(
                              context, '/detail/${creatorGuides[i].id}'),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.library_music_outlined,
                                size: 48, color: muteC),
                            const SizedBox(height: 8),
                            Text('아직 출시된 가이드가 없습니다',
                                style: GuidyText.body(muteC)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // ── 다른 활동 ──────────────────────────────
                  if (creator.activities.isNotEmpty) ...[
                    const SectionHeader(title: '다른 활동'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: creator.activities.asMap().entries.map((e) {
                          final i = e.key;
                          final act = e.value;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: i < creator.activities.length - 1 ? 8 : 0),
                            child: _ActivityTile(
                              activity: act,
                              lineC: lineC,
                              textC: textC,
                              subC: subC,
                              muteC: muteC,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color textC, Color subC) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(value, style: GuidyText.h3(textC)),
          Text(label, style: GuidyText.small(subC)),
        ],
      ),
    );
  }

  Widget _divider(Color lineC) =>
      Container(width: 1, height: 28, color: lineC);

  String _formatNum(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ─── 활동 타일 ────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final CreatorActivity activity;
  final Color lineC, textC, subC, muteC;

  const _ActivityTile({
    required this.activity,
    required this.lineC,
    required this.textC,
    required this.subC,
    required this.muteC,
  });

  static IconData _iconFor(ActivityType type) {
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

  Future<void> _launch() async {
    if (activity.url == null) return;
    final uri = Uri.parse(activity.url!);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = activity.url != null && activity.url!.isNotEmpty;
    return GestureDetector(
      onTap: hasLink ? _launch : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Row(
          children: [
            Icon(_iconFor(activity.type), size: 20, color: muteC),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.label,
                      style: GuidyText.body(textC)
                          .copyWith(fontWeight: FontWeight.w600)),
                  if (activity.detail.isNotEmpty)
                    Text(activity.detail, style: GuidyText.small(subC)),
                ],
              ),
            ),
            if (hasLink)
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: muteC)
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
