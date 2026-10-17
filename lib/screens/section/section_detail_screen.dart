// lib/screens/section/section_detail_screen.dart
// 섹션 상세 화면 — 커버이미지 + 설명 + 해당 섹션 작품 목록

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../widgets/common_widgets.dart';

class SectionDetailScreen extends StatelessWidget {
  final String sectionId;
  const SectionDetailScreen({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final store   = context.read<AppStore>();
    final section = store.sectionById(sectionId);

    if (section == null) {
      return _NotFound();
    }

    final exhibition = store.exhibitionById(section.exhibitionId);
    final artworks   = section.artworkIds
        .map((id) => store.artworkById(id))
        .whereType<Artwork>()
        .toList();

    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg     : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText    : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub     : GuidyColors.sub;
    final lineC    = isDark ? GuidyColors.darkLine    : GuidyColors.line;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final muteC    = isDark ? GuidyColors.darkMute    : GuidyColors.mute;
    final accentC  = isDark ? GuidyColors.darkAccent  : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── 히어로 이미지 ───────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Base64 이미지 or 플레이스홀더
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: SectionImageWidget(
                        imageBase64: section.imageBase64,
                        imageSeed:   section.imageSeed,
                        width:       double.infinity,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    // 그라디언트 오버레이
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              bgC.withValues(alpha: 0.9),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // 뒤로가기 버튼
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: GuidyRadius.mdBorder,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    // 섹션 번호 배지
                    Positioned(
                      bottom: 16, left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: GuidyColors.primary.withValues(alpha: 0.9),
                          borderRadius: GuidyRadius.pillBorder,
                        ),
                        child: Text(
                          'SECTION ${section.order}',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: GuidyText.fontFamily,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── 콘텐츠 ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 전시 레이블
                      if (exhibition != null) ...[
                        Row(
                          children: [
                            Icon(Icons.museum_outlined, size: 13, color: muteC),
                            const SizedBox(width: 4),
                            Text(exhibition.title,
                              style: GuidyText.kicker(muteC)),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // 섹션 제목
                      Text(section.title, style: GuidyText.h1(textC)),
                      const SizedBox(height: 12),

                      // 섹션 설명
                      if (section.description.isNotEmpty) ...[
                        Text(section.description,
                          style: GuidyText.body(subC)),
                        const SizedBox(height: 20),
                      ],

                      // 통계
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: surfaceC,
                          borderRadius: GuidyRadius.lgBorder,
                          border: Border.all(color: lineC),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem(Icons.image_outlined,
                              '${artworks.length}', '작품', textC, muteC),
                            Container(width: 1, height: 30, color: lineC),
                            _statItem(Icons.headphones_outlined,
                              '${(artworks.fold(0, (sum, a) => sum + a.durationSec) ~/ 60)}분',
                              '총 재생', textC, muteC),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 작품 목록
                      if (artworks.isNotEmpty) ...[
                        Text('이 섹션의 작품',
                          style: GuidyText.h3(textC)),
                        const SizedBox(height: 12),
                        ...artworks.asMap().entries.map((entry) =>
                          _ArtworkItem(
                            artwork: entry.value,
                            index: entry.key + 1,
                            isDark: isDark,
                            textC: textC, subC: subC,
                            lineC: lineC, surfaceC: surfaceC,
                            muteC: muteC, accentC: accentC,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: surfaceC,
                            borderRadius: GuidyRadius.lgBorder,
                            border: Border.all(color: lineC),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.collections_outlined, size: 36, color: muteC),
                                const SizedBox(height: 8),
                                Text('이 섹션의 작품이 준비 중입니다',
                                  style: GuidyText.body(muteC)),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── 하단 CTA ─────────────────────────────────
          if (artworks.isNotEmpty)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: bgC,
                  border: Border(top: BorderSide(color: lineC)),
                  boxShadow: GuidyShadow.up,
                ),
                child: PillButton(
                  label: '이 섹션 듣기',
                  primary: true,
                  onPressed: () => Navigator.pushNamed(
                    context, '/player/${artworks.first.id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color textC, Color muteC) {
    return Column(
      children: [
        Icon(icon, size: 18, color: muteC),
        const SizedBox(height: 4),
        Text(value, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: GuidyText.kicker(muteC)),
      ],
    );
  }
}

// ─── 작품 아이템 ──────────────────────────────────────────
class _ArtworkItem extends StatelessWidget {
  final Artwork artwork;
  final int index;
  final bool isDark;
  final Color textC, subC, lineC, surfaceC, muteC, accentC;

  const _ArtworkItem({
    required this.artwork, required this.index,
    required this.isDark,
    required this.textC, required this.subC,
    required this.lineC, required this.surfaceC,
    required this.muteC, required this.accentC,
  });

  @override
  Widget build(BuildContext context) {
    final durMin = artwork.durationSec ~/ 60;
    final durSec = artwork.durationSec % 60;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/player/${artwork.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Row(
          children: [
            // 순서 번호
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                color: GuidyColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$index', style: const TextStyle(
                  color: GuidyColors.primary, fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: GuidyText.fontFamily,
                )),
              ),
            ),
            const SizedBox(width: 10),
            // 썸네일
            GuidyCover(
              seed: artwork.imageSeed,
              width: 52, height: 52,
              borderRadius: GuidyRadius.mdBorder,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(artwork.title,
                    style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(artwork.artist, style: GuidyText.small(subC)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 11, color: muteC),
                      const SizedBox(width: 3),
                      Text('$durMin:${durSec.toString().padLeft(2, '0')}',
                        style: GuidyText.kicker(muteC)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline_rounded, color: accentC, size: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Not Found ────────────────────────────────────────────
class _NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC    = isDark ? GuidyColors.darkBg   : GuidyColors.bg;
    final textC  = isDark ? GuidyColors.darkText  : GuidyColors.ink;
    final muteC  = isDark ? GuidyColors.darkMute  : GuidyColors.mute;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: textC, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 56, color: muteC),
                    const SizedBox(height: 12),
                    Text('섹션을 찾을 수 없습니다', style: GuidyText.body(muteC)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
