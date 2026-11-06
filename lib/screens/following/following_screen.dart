// lib/screens/following/following_screen.dart
// 팔로잉 피드 화면

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/exhibition_actions.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pal = GuidyPalette.of(context);

    return Scaffold(
      backgroundColor: pal.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            GuidyHeader(title: '팔로잉', showBack: true),
            Container(height: 1, color: pal.line),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 스토리 스트립
                  _StoryStrip(),
                  Container(height: 1, color: pal.line),
                  const SizedBox(height: 12),
                  // 피드
                  ...DummyData.feedItems.map((item) => _FeedCard(item: item, isDark: isDark, textC: pal.text)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pal = GuidyPalette.of(context);

    return SizedBox(
      // 90 중 이름 한 줄(약 14)만 글자 배율에 맞춰 키움 → 큰 글자에서도 잘리지 않고, 1배일 땐 90 그대로
      height: 76 + MediaQuery.textScalerOf(context).scale(14),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: DummyData.creators.length,
        itemBuilder: (context, i) {
          final cr = DummyData.creators[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/creator/${cr.id}'),
            child: Container(
              width: 64,
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      CreatorAvatar(creator: cr, size: 48, showBadgeRing: i < 2),
                      if (i < 2)
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: pal.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: pal.bg,
                                width: 2,
                              ),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(cr.name, style: GuidyText.kicker(pal.sub),
                    maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedCard extends StatefulWidget {
  final FeedItem item;
  final bool isDark;
  final Color textC;

  const _FeedCard({required this.item, required this.isDark, required this.textC});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textC = widget.textC;
    final item = widget.item;
    final subC = GuidyPalette.forDark(isDark).sub;
    final muteC = GuidyPalette.forDark(isDark).mute;
    final surfaceC = GuidyPalette.forDark(isDark).surface;
    final lineC = GuidyPalette.forDark(isDark).line;
    final accentC = GuidyPalette.forDark(isDark).accent;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
        boxShadow: GuidyShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 크리에이터 헤더
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/creator/${item.creator.id}'),
                child: CreatorAvatar(creator: item.creator, size: 36),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.creator.name, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        if (item.creator.isVerified)
                          Icon(Icons.verified_rounded, color: GuidyPalette.forDark(isDark).primary, size: 14),
                      ],
                    ),
                    Text(_timeAgo(item.time), style: GuidyText.small(muteC)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.type == FeedItemType.newGuide ? accentC.withValues(alpha: 0.15) : lineC,
                  borderRadius: GuidyRadius.pillBorder,
                ),
                child: Text(
                  item.type == FeedItemType.newGuide ? '새 가이드' : '소식',
                  style: GuidyText.kicker(item.type == FeedItemType.newGuide ? accentC : muteC),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 제목
          if (item.title != null)
            Text(item.title!, style: GuidyText.h3(textC)),
          if (item.description != null) ...[
            const SizedBox(height: 6),
            Text(item.description!, style: GuidyText.body(subC), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],

          // 전시 미리보기
          if (item.exhibition != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/detail/${item.exhibition!.id}'),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: lineC),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    GuidyCover(
                      seed: item.exhibition!.coverSeed,
                      width: 72, height: 72,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ChannelBadge(type: item.exhibition!.channel),
                            const SizedBox(height: 4),
                            Text(item.exhibition!.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(item.exhibition!.venue, style: GuidyText.small(muteC)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: PillButton(
                        label: '재생',
                        primary: true,
                        size: 'sm',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => openExhibitionPlayer(context, item.exhibition!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 좋아요 / 저장
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _liked = !_liked),
                child: Row(
                  children: [
                    Icon(
                      _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: _liked ? Colors.red : muteC,
                    ),
                    const SizedBox(width: 4),
                    Text('${item.likes + (_liked ? 1 : 0)}', style: GuidyText.small(muteC)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(Icons.play_circle_outline_rounded, size: 18, color: muteC),
                  const SizedBox(width: 4),
                  Text('${item.plays}', style: GuidyText.small(muteC)),
                ],
              ),
              const Spacer(),
              Icon(Icons.bookmark_border_rounded, size: 20, color: muteC),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
