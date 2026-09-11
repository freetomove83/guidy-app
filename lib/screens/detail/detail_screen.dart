// lib/screens/detail/detail_screen.dart
// 전시 상세 화면 — 즐겨찾기/좋아요/크리에이터 가이드 배너/섹션 실제 데이터 연결

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';

class DetailScreen extends StatefulWidget {
  final String exhibitionId;
  const DetailScreen({super.key, required this.exhibitionId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final exhibition = store.exhibitionById(widget.exhibitionId)
        ?? store.exhibitions.first;
    final artworks   = store.artworksFor(widget.exhibitionId);
    final firstArtworkId = artworks.isNotEmpty ? artworks.first.id : 'a1';
    final sections   = store.sectionsFor(widget.exhibitionId);
    final guides     = store.creatorGuidesFor(widget.exhibitionId);

    final userStore = context.watch<UserStore>();
    final isFav  = userStore.isFavorite(widget.exhibitionId);
    final isLiked = userStore.isLiked(widget.exhibitionId);

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgC       = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC     = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC     = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC  = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC     = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final accentC   = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;
    final accentSoftC = isDark
        ? GuidyColors.darkAccent.withValues(alpha: 0.14)
        : GuidyColors.accentSoft;

    return Scaffold(
      backgroundColor: bgC,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── 히어로 ──────────────────────────
                    Stack(
                      children: [
                        GuidyCover(
                          seed: exhibition.coverSeed,
                          aspectRatio: 4 / 3,
                          borderRadius: BorderRadius.zero,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, bgC.withValues(alpha: 0.8)],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // 뒤로가기 / 즐겨찾기 / 공유
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16, right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
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
                              Row(
                                children: [
                                  // 즐겨찾기 버튼 (북마크)
                                  GestureDetector(
                                    onTap: () => userStore.toggleFavorite(widget.exhibitionId),
                                    child: Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: isFav
                                            ? GuidyColors.accent.withValues(alpha: 0.85)
                                            : Colors.black.withValues(alpha: 0.4),
                                        borderRadius: GuidyRadius.mdBorder,
                                      ),
                                      child: Icon(
                                        isFav
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        color: Colors.white, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 공유 버튼
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      borderRadius: GuidyRadius.mdBorder,
                                    ),
                                    child: const Icon(Icons.share_outlined,
                                      color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ─── 콘텐츠 ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 배지 + 좋아요
                          Row(
                            children: [
                              ChannelBadge(type: exhibition.channel, size: 'md'),
                              if (exhibition.isActive) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: GuidyColors.ok.withValues(alpha: 0.15),
                                    borderRadius: GuidyRadius.pillBorder,
                                  ),
                                  child: const Text('진행 중', style: TextStyle(
                                    color: GuidyColors.ok, fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: GuidyText.fontFamily,
                                  )),
                                ),
                              ],
                              const Spacer(),
                              // 좋아요 버튼 (YouTube/Instagram 스타일)
                              GestureDetector(
                                onTap: () => userStore.toggleLike(widget.exhibitionId),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isLiked
                                        ? Colors.red.withValues(alpha: 0.12)
                                        : surfaceC,
                                    borderRadius: GuidyRadius.pillBorder,
                                    border: Border.all(
                                      color: isLiked
                                          ? Colors.red.withValues(alpha: 0.4)
                                          : lineC,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isLiked
                                            ? Icons.thumb_up_rounded
                                            : Icons.thumb_up_outlined,
                                        size: 16,
                                        color: isLiked ? Colors.red : muteC,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isLiked ? '좋아요' : '좋아요',
                                        style: GuidyText.small(
                                          isLiked ? Colors.red : muteC,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(exhibition.title, style: GuidyText.h1(textC)),
                          const SizedBox(height: 10),
                          Text(exhibition.description,
                            style: GuidyText.body(subC),
                            maxLines: 3, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 20),

                          // 메타 그리드
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceC,
                              borderRadius: GuidyRadius.lgBorder,
                              border: Border.all(color: lineC),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _metaItem(Icons.place_outlined, '장소', exhibition.venue, textC, muteC),
                                    _metaItem(Icons.image_outlined, '작품 수', '${exhibition.workCount}개', textC, muteC),
                                  ],
                                ),
                                Divider(color: lineC, height: 20),
                                Row(
                                  children: [
                                    _metaItem(Icons.timer_outlined, '소요 시간', exhibition.duration, textC, muteC),
                                    _metaItem(Icons.attach_money_rounded, '이용료',
                                      exhibition.price == 0 ? '무료' : '₩${_formatPrice(exhibition.price)}',
                                      textC, muteC),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 크리에이터 가이드 배너 (curation 채널일 때)
                          if (exhibition.channel == ChannelType.curation && guides.isNotEmpty)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context, '/creator-guides/${widget.exhibitionId}'),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: accentSoftC,
                                  borderRadius: GuidyRadius.lgBorder,
                                  border: Border.all(color: accentC.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.mic_rounded, color: accentC, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('이 전시의 크리에이터 가이드',
                                            style: GuidyText.small(accentC)
                                                .copyWith(fontWeight: FontWeight.w800)),
                                          Text('다른 관점에서 감상해보세요',
                                            style: GuidyText.small(subC)),
                                        ],
                                      ),
                                    ),
                                    Text('${guides.length}개 →',
                                      style: GuidyText.small(accentC)
                                          .copyWith(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),

                          // 섹션 리스트 (실제 데이터)
                          Text('섹션 구성', style: GuidyText.h3(textC)),
                          const SizedBox(height: 12),
                          if (sections.isEmpty)
                            // 더미 섹션 표시 (섹션 데이터 없을 때)
                            ...List.generate(3, (i) =>
                              _sectionItemDummy(i + 1, textC, subC, lineC, surfaceC))
                          else
                            ...sections.map((section) => GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context, '/section/${section.id}'),
                              child: _SectionCard(
                                section: section,
                                textC: textC, subC: subC,
                                lineC: lineC, surfaceC: surfaceC,
                              ),
                            )),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── 하단 고정 CTA ────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20,
                MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: bgC,
                border: Border(top: BorderSide(color: lineC)),
                boxShadow: GuidyShadow.up,
              ),
              child: Row(
                children: [
                  PillButton(
                    label: '미리듣기',
                    size: 'md',
                    onPressed: () => Navigator.pushNamed(context, '/player/$firstArtworkId'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 구매 처리 (UserStore에 추가)
                        final purchase = Purchase(
                          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                          exhibitionId: widget.exhibitionId,
                          exhibitionTitle: exhibition.title,
                          venueName: exhibition.venue,
                          coverSeed: exhibition.coverSeed,
                          pricePaid: exhibition.price,
                          purchasedAt: DateTime.now(),
                          status: PurchaseStatus.unused,
                        );
                        context.read<UserStore>().addPurchase(purchase);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('「${exhibition.title}」 구매가 완료되었습니다'),
                            backgroundColor: GuidyColors.ok,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? GuidyColors.darkText : GuidyColors.ink,
                          borderRadius: GuidyRadius.pillBorder,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                              color: isDark ? GuidyColors.darkBg : Colors.white,
                              size: 18),
                            const SizedBox(width: 6),
                            Text(
                              exhibition.price == 0
                                  ? '무료로 감상하기'
                                  : '₩${_formatPrice(exhibition.price)} 구매',
                              style: TextStyle(
                                color: isDark ? GuidyColors.darkBg : Colors.white,
                                fontSize: 15, fontWeight: FontWeight.w800,
                                fontFamily: GuidyText.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }

  Widget _metaItem(IconData icon, String label, String value, Color textC, Color muteC) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: muteC),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GuidyText.kicker(muteC)),
              Text(value, style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  // 섹션 데이터 없을 때 더미 표시용
  Widget _sectionItemDummy(int num, Color textC, Color subC, Color lineC, Color surfaceC) {
    final sectionNames = ['입구 · 소개', '메인 갤러리', '특별전시'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: GuidyColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$num', style: const TextStyle(
                color: GuidyColors.primary, fontSize: 12, fontWeight: FontWeight.w800,
                fontFamily: GuidyText.fontFamily,
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sectionNames[num - 1],
                  style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
                Text('작품 ${num * 4}개', style: GuidyText.small(subC)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: GuidyColors.mute, size: 18),
        ],
      ),
    );
  }
}

// ─── 섹션 카드 (실제 데이터) ──────────────────────────────
class _SectionCard extends StatelessWidget {
  final ExhibitionSection section;
  final Color textC, subC, lineC, surfaceC;

  const _SectionCard({
    required this.section,
    required this.textC, required this.subC,
    required this.lineC, required this.surfaceC,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: Row(
        children: [
          // 썸네일 — Base64 이미지 or 플레이스홀더
          SectionImageWidget(
            imageBase64: section.imageBase64,
            imageSeed:   section.imageSeed,
            width: 52, height: 52,
            borderRadius: GuidyRadius.mdBorder,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(
                        color: GuidyColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${section.order}', style: const TextStyle(
                          color: GuidyColors.primary, fontSize: 10,
                          fontWeight: FontWeight.w800,
                          fontFamily: GuidyText.fontFamily,
                        )),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(section.title,
                        style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                if (section.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(section.description,
                    style: GuidyText.small(subC),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 3),
                Text('작품 ${section.artworkIds.length}개',
                  style: GuidyText.kicker(GuidyColors.mute)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: GuidyColors.mute, size: 18),
        ],
      ),
    );
  }
}
