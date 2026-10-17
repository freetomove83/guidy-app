// lib/screens/archive/archive_screen.dart
// 아카이브 화면

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class ArchiveScreen extends StatelessWidget {
  final String exhibitionId;
  const ArchiveScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context) {
    final exhibition = DummyData.exhibitions.firstWhere(
      (e) => e.id == exhibitionId && e.channel == ChannelType.archive,
      orElse: () => DummyData.exhibitions.firstWhere((e) => e.channel == ChannelType.archive),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

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
                                colors: [Colors.transparent, bgC.withOpacity(0.9)],
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
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: GuidyRadius.mdBorder,
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                              Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: GuidyRadius.mdBorder,
                                  ),
                                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
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
                                  color: Colors.black.withOpacity(0.5),
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
                          Text(exhibition.title, style: GuidyText.h1(textC)),
                          const SizedBox(height: 6),
                          Text(exhibition.venue, style: GuidyText.body(subC)),
                          const SizedBox(height: 20),

                          // 액션 버튼
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/player/a1'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: textC,
                                      borderRadius: GuidyRadius.pillBorder,
                                    ),
                                    child: Text('전체 감상하기', textAlign: TextAlign.center,
                                      style: TextStyle(color: bgC, fontSize: 15, fontWeight: FontWeight.w800,
                                        fontFamily: GuidyText.fontFamily)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              PillButton(label: '미리듣기', size: 'lg'),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 큐레이터 노트
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
                                Row(children: [
                                  Container(
                                    width: 3, height: 16,
                                    decoration: BoxDecoration(color: primaryC, borderRadius: GuidyRadius.pillBorder),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('큐레이터 노트', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w800)),
                                ]),
                                const SizedBox(height: 8),
                                Text(exhibition.description, style: GuidyText.body(subC), maxLines: 4, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 메타 그리드 3열
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceC,
                              borderRadius: GuidyRadius.lgBorder,
                              border: Border.all(color: lineC),
                            ),
                            child: Row(
                              children: [
                                _metaItem3(Icons.image_outlined, '작품 수', '${exhibition.workCount}개', textC, muteC),
                                _divider(lineC),
                                _metaItem3(Icons.headphones_outlined, '총 청취', '8,420회', textC, muteC),
                                _divider(lineC),
                                _metaItem3(Icons.translate_rounded, '언어', '한국어', textC, muteC),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 작품 갤러리
                          Text('수록 작품', style: GuidyText.h3(textC)),
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
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
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
                color: bgC,
                border: Border(top: BorderSide(color: lineC)),
                boxShadow: GuidyShadow.up,
              ),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: textC,
                    borderRadius: GuidyRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: bgC, size: 18),
                      const SizedBox(width: 8),
                      Text('₩${exhibition.price} · 구매하고 감상하기',
                        style: TextStyle(color: bgC, fontSize: 15, fontWeight: FontWeight.w800,
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
