// lib/screens/creator/creator_profile_screen.dart
// 크리에이터 프로필 화면 — 팔로우 수치 실시간 반영 + 활동 링크 + 메시지 버튼 제거

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                        GestureDetector(
                          onTap: () => _showShareSheet(context, creator,
                              isDark: isDark, bgC: bgC, textC: textC,
                              subC: subC, muteC: muteC, lineC: lineC,
                              surfaceC: surfaceC, primaryC: primaryC),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: surfaceC,
                              borderRadius: GuidyRadius.mdBorder,
                              border: Border.all(color: lineC),
                            ),
                            child: Icon(Icons.share_outlined,
                                size: 16, color: textC),
                          ),
                        ),
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

  void _showShareSheet(
    BuildContext context,
    Creator creator, {
    required bool isDark,
    required Color bgC,
    required Color textC,
    required Color subC,
    required Color muteC,
    required Color lineC,
    required Color surfaceC,
    required Color primaryC,
  }) {
    final shareUrl = 'https://guidy.co.kr/creator/${creator.id}';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(
        creator: creator,
        shareUrl: shareUrl,
        isDark: isDark,
        bgC: bgC,
        textC: textC,
        subC: subC,
        muteC: muteC,
        lineC: lineC,
        surfaceC: surfaceC,
        primaryC: primaryC,
      ),
    );
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

// ─── 공유 바텀시트 ────────────────────────────────────────
class _ShareSheet extends StatelessWidget {
  final Creator creator;
  final String shareUrl;
  final bool isDark;
  final Color bgC, textC, subC, muteC, lineC, surfaceC, primaryC;

  const _ShareSheet({
    required this.creator,
    required this.shareUrl,
    required this.isDark,
    required this.bgC,
    required this.textC,
    required this.subC,
    required this.muteC,
    required this.lineC,
    required this.surfaceC,
    required this.primaryC,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: GuidyRadius.xlBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들바
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: lineC,
              borderRadius: GuidyRadius.pillBorder,
            ),
          ),
          // 제목
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text('크리에이터 공유하기',
                    style: GuidyText.h3(textC)),
              ],
            ),
          ),
          // 크리에이터 미리보기 카드
          Container(
            margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceC,
              borderRadius: GuidyRadius.lgBorder,
              border: Border.all(color: lineC),
            ),
            child: Row(
              children: [
                CreatorAvatar(creator: creator, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(creator.name,
                          style: GuidyText.body(textC)
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(creator.title,
                          style: GuidyText.small(subC)),
                    ],
                  ),
                ),
                if (creator.isVerified)
                  Icon(Icons.verified_rounded,
                      color: primaryC, size: 16),
              ],
            ),
          ),
          // URL 복사 영역
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: shareUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('링크가 클립보드에 복사되었습니다'),
                  backgroundColor: GuidyColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: GuidyRadius.lgBorder),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                  Icon(Icons.link_rounded, size: 16, color: muteC),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: GuidyText.small(subC),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryC,
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Text('복사',
                        style: GuidyText.kicker(Colors.white)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          // 공유 채널 버튼들
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ShareChannelBtn(
                  icon: Icons.message_rounded,
                  label: '메시지',
                  color: const Color(0xFF00C300),
                  onTap: () => _launchKakao(context, shareUrl),
                ),
                _ShareChannelBtn(
                  icon: Icons.chat_bubble_rounded,
                  label: '카카오톡',
                  color: const Color(0xFFFEE500),
                  iconColor: const Color(0xFF191919),
                  onTap: () => _launchKakao(context, shareUrl),
                ),
                _ShareChannelBtn(
                  icon: Icons.camera_alt_rounded,
                  label: '인스타그램',
                  color: const Color(0xFFE1306C),
                  onTap: () => _copyAndNotify(context, shareUrl),
                ),
                _ShareChannelBtn(
                  icon: Icons.copy_rounded,
                  label: '링크 복사',
                  color: primaryC,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('링크가 복사되었습니다'),
                        backgroundColor: GuidyColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: GuidyRadius.lgBorder),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 취소 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: surfaceC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC),
              ),
              child: Text('닫기',
                  style: GuidyText.body(subC),
                  textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _launchKakao(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('링크가 복사되었습니다. 앱에서 붙여넣기 하세요'),
        backgroundColor: GuidyColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  void _copyAndNotify(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('인스타그램 앱에서 링크를 붙여넣기 하세요'),
        backgroundColor: GuidyColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }
}

// ─── 공유 채널 버튼 ───────────────────────────────────────
class _ShareChannelBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ShareChannelBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                fontFamily: GuidyText.fontFamily,
                fontSize: 11,
                color: GuidyColors.mute,
              )),
        ],
      ),
    );
  }
}
