// lib/screens/creator/creator_profile_screen.dart
// 크리에이터 프로필 화면

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String creatorId;
  const CreatorProfileScreen({super.key, required this.creatorId});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final creator = DummyData.creators.firstWhere(
      (c) => c.id == widget.creatorId,
      orElse: () => DummyData.creators.first,
    );
    final creatorGuides = DummyData.exhibitions
        .where((e) => e.creatorId == creator.id)
        .toList();

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
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 헤더
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
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textC),
                          ),
                        ),
                        Icon(Icons.share_outlined, color: textC, size: 22),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 프로필 헤더 (중앙 정렬)
                  Column(
                    children: [
                      CreatorAvatar(creator: creator, size: 80, showBadgeRing: true),
                      const SizedBox(height: 12),
                      if (creator.isVerified)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryC.withValues(alpha: 0.1),
                            borderRadius: GuidyRadius.pillBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: primaryC, size: 12),
                              const SizedBox(width: 4),
                              Text('인증 크리에이터', style: GuidyText.kicker(primaryC)),
                            ],
                          ),
                        ),
                      Text(creator.name, style: GuidyText.h2(textC)),
                      const SizedBox(height: 4),
                      Text(creator.title, style: GuidyText.body(subC)),
                      const SizedBox(height: 16),

                      // 통계
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _statItem('가이드', '${creator.guideCount}', textC, subC),
                          _divider(lineC),
                          _statItem('팔로워', _formatNum(creator.followerCount), textC, subC),
                          _divider(lineC),
                          _statItem('총 청취', _formatNum(creator.totalPlays), textC, subC),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isFollowing = !_isFollowing),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                              decoration: BoxDecoration(
                                color: _isFollowing ? lineC : textC,
                                borderRadius: GuidyRadius.pillBorder,
                              ),
                              child: Text(
                                _isFollowing ? '팔로잉' : '팔로우',
                                style: TextStyle(
                                  color: _isFollowing ? textC : bgC,
                                  fontSize: 14, fontWeight: FontWeight.w800,
                                  fontFamily: GuidyText.fontFamily,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                            decoration: BoxDecoration(
                              color: surfaceC,
                              borderRadius: GuidyRadius.pillBorder,
                              border: Border.all(color: lineC),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mail_outline_rounded, size: 16, color: textC),
                                const SizedBox(width: 6),
                                Text('메시지', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 자기 소개
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surfaceC,
                            borderRadius: GuidyRadius.lgBorder,
                            border: Border(left: BorderSide(color: accentC, width: 3)),
                          ),
                          child: Text('"${creator.bio}"',
                            style: GuidyText.body(subC), textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 대표 가이드
                  const SectionHeader(title: '대표 가이드'),
                  if (creatorGuides.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: creatorGuides.length,
                        itemBuilder: (context, i) => ExhibitionCard(
                          exhibition: creatorGuides[i],
                          onTap: () => Navigator.pushNamed(context, '/detail/${creatorGuides[i].id}'),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.library_music_outlined, size: 48, color: muteC),
                            const SizedBox(height: 8),
                            Text('아직 출시된 가이드가 없습니다', style: GuidyText.body(muteC)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // 다른 활동
                  const SectionHeader(title: '다른 활동'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _activityItem(Icons.smart_display_outlined, 'YouTube', '구독자 ${_formatNum(creator.followerCount * 3)}명', lineC, textC, subC, muteC),
                        const SizedBox(height: 8),
                        _activityItem(Icons.article_outlined, '블로그', '월 ${_formatNum(creator.followerCount * 2)}회 방문', lineC, textC, subC, muteC),
                        const SizedBox(height: 8),
                        _activityItem(Icons.mic_external_on_outlined, '강연', '연간 ${creator.guideCount * 2}회', lineC, textC, subC, muteC),
                      ],
                    ),
                  ),
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

  Widget _divider(Color lineC) {
    return Container(width: 1, height: 28, color: lineC);
  }

  Widget _activityItem(IconData icon, String title, String sub, Color lineC, Color textC, Color subC, Color muteC) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muteC),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
                Text(sub, style: GuidyText.small(subC)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: muteC),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
