// lib/screens/archive/archive_screen.dart
// 아카이브 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/exhibition_actions.dart';

class ArchiveScreen extends StatelessWidget {
  final String exhibitionId;
  const ArchiveScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context) {
    final exhibition = context.read<AppStore>().exhibitionById(exhibitionId);
    if (exhibition == null) {
      return const NotFoundScreen(message: '전시를 찾을 수 없습니다');
    }
    final canPlay = context.watch<UserStore>().canAccess(exhibition);

    final pal = GuidyPalette.of(context);

    return Scaffold(
      backgroundColor: pal.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 히어로 커버 4:5
                    Stack(
                      children: [
                        GuidyCover(
                          seed: exhibition.coverSeed,
                          aspectRatio: 4 / 5,
                          borderRadius: BorderRadius.zero,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, pal.bg.withValues(alpha: 0.9)],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // 헤더
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
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                              Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: GuidyRadius.mdBorder,
                                  ),
                                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: GuidyRadius.mdBorder,
                                  ),
                                  child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        // 배지 + 연도
                        Positioned(
                          bottom: 16, left: 20, right: 20,
                          child: Row(
                            children: [
                              const ChannelBadge(type: ChannelType.archive, size: 'md'),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: GuidyRadius.pillBorder,
                                ),
                                child: const Text('2024', style: TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                                  fontFamily: GuidyText.fontFamily,
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exhibition.title, style: GuidyText.h1(pal.text)),
                          const SizedBox(height: 6),
                          Text(exhibition.venue, style: GuidyText.body(pal.sub)),
                          const SizedBox(height: 20),

                          // 액션 버튼
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => canPlay
                                      ? openExhibitionPlayer(context, exhibition)
                                      : confirmPurchase(context, exhibition),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: pal.text,
                                      borderRadius: GuidyRadius.pillBorder,
                                    ),
                                    child: Text('전체 감상하기', textAlign: TextAlign.center,
                                      style: TextStyle(color: pal.bg, fontSize: 15, fontWeight: FontWeight.w800,
                                        fontFamily: GuidyText.fontFamily)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              PillButton(label: '미리듣기', size: 'lg',
                                onPressed: () => openExhibitionPlayer(context, exhibition)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 큐레이터 노트
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: pal.surface,
                              borderRadius: GuidyRadius.lgBorder,
                              border: Border.all(color: pal.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 3, height: 16,
                                    decoration: BoxDecoration(color: pal.primary, borderRadius: GuidyRadius.pillBorder),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('큐레이터 노트', style: GuidyText.body(pal.text).copyWith(fontWeight: FontWeight.w800)),
                                ]),
                                const SizedBox(height: 8),
                                Text(exhibition.description, style: GuidyText.body(pal.sub), maxLines: 4, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 메타 그리드 3열
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: pal.surface,
                              borderRadius: GuidyRadius.lgBorder,
                              border: Border.all(color: pal.line),
                            ),
                            child: Row(
                              children: [
                                _metaItem3(Icons.image_outlined, '작품 수', '${exhibition.workCount}개', pal.text, pal.mute),
                                _divider(pal.line),
                                _metaItem3(Icons.headphones_outlined, '총 청취', '8,420회', pal.text, pal.mute),
                                _divider(pal.line),
                                _metaItem3(Icons.translate_rounded, '언어', '한국어', pal.text, pal.mute),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 작품 갤러리
                          Text('수록 작품', style: GuidyText.h3(pal.text)),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: exhibition.workCount.clamp(0, 9),
                            itemBuilder: (context, i) => Stack(
                              children: [
                                GuidyCover(
                                  seed: i,
                                  aspectRatio: 1,
                                  borderRadius: GuidyRadius.mdBorder,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: GuidyRadius.mdBorder,
                                      color: Colors.black.withValues(alpha: 0.2),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 하단 CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: pal.bg,
                border: Border(top: BorderSide(color: pal.line)),
                boxShadow: GuidyShadow.up,
              ),
              child: GestureDetector(
                onTap: () => canPlay
                    ? openExhibitionPlayer(context, exhibition)
                    : confirmPurchase(context, exhibition),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: pal.text,
                    borderRadius: GuidyRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: pal.bg, size: 18),
                      const SizedBox(width: 8),
                      Text(canPlay ? '지금 바로 감상하기' : '₩${formatPrice(exhibition.price)} · 구매하고 감상하기',
                        style: TextStyle(color: pal.bg, fontSize: 15, fontWeight: FontWeight.w800,
                          fontFamily: GuidyText.fontFamily)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem3(IconData icon, String label, String value, Color textC, Color muteC) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: muteC),
          const SizedBox(height: 4),
          Text(value, style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(fontSize: 10, color: muteC, fontFamily: GuidyText.fontFamily)),
        ],
      ),
    );
  }

  Widget _divider(Color lineC) {
    return Container(width: 1, height: 40, color: lineC);
  }
}
