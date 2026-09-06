// lib/screens/library/library_screen.dart
// 내 서재 화면

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _tabIndex = 0;
  final _tabs = ['컬렉션', '이어듣기', '즐겨찾기'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            GuidyHeader(title: '내 서재', showSearch: true),
            // 탭
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineC)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final isA = i == _tabIndex;
                    final isDark2 = isDark;
                    final textC = isDark2 ? GuidyColors.darkText : GuidyColors.ink;
                    final muteC = isDark2 ? GuidyColors.darkMute : GuidyColors.mute;
                    final primaryC = isDark2 ? GuidyColors.darkPrimary : GuidyColors.primary;
                    return GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                            color: isA ? primaryC : Colors.transparent,
                            width: 2.5,
                          )),
                        ),
                        child: Text(_tabs[i], style: TextStyle(
                          fontFamily: GuidyText.fontFamily, fontSize: 14,
                          fontWeight: isA ? FontWeight.w800 : FontWeight.w500,
                          color: isA ? textC : muteC,
                        )),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: const [
                  _CollectionTab(),
                  _ContinueTab(),
                  _FavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 컬렉션 탭
class _CollectionTab extends StatelessWidget {
  const _CollectionTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
      children: [
        // 진행 중인 전시
        const SectionHeader(title: '진행 중인 전시'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: DummyData.exhibitions.where((e) => e.isActive).length,
            itemBuilder: (context, i) {
              final items = DummyData.exhibitions.where((e) => e.isActive).toList();
              return ExhibitionCard(
                exhibition: items[i],
                onTap: () => Navigator.pushNamed(context, '/detail/${items[i].id}'),
                progressRatio: (i + 1) * 0.25,
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // 내 아카이브
        const SectionHeader(title: '내 아카이브'),
        ...DummyData.exhibitions
            .where((e) => e.channel == ChannelType.archive)
            .map((e) => Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC),
              ),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/archive/${e.id}'),
                child: Row(
                  children: [
                    GuidyCover(seed: e.coverSeed, width: 60, height: 60,
                      borderRadius: GuidyRadius.lgBorder),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ChannelBadge(type: ChannelType.archive),
                          const SizedBox(height: 4),
                          Text(e.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(e.venue, style: GuidyText.small(subC)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: muteC, size: 18),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// 이어듣기 탭
class _ContinueTab extends StatelessWidget {
  const _ContinueTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: DummyData.artworks.map((a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/player/${a.id}'),
          child: Row(
            children: [
              Stack(
                children: [
                  GuidyCover(seed: a.imageSeed, width: 60, height: 60, borderRadius: GuidyRadius.lgBorder),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: GuidyRadius.lgBorder,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                    Text(a.artist, style: GuidyText.small(subC)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: GuidyRadius.pillBorder,
                      child: LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: lineC,
                        valueColor: AlwaysStoppedAnimation<Color>(accentC),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('1:12 / ${a.durationSec ~/ 60}:${(a.durationSec % 60).toString().padLeft(2, '0')}',
                      style: GuidyText.kicker(muteC)),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

// 즐겨찾기 탭
class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outlined, size: 64, color: muteC),
          const SizedBox(height: 12),
          Text('즐겨찾기한 가이드가 없습니다', style: GuidyText.body(muteC)),
          const SizedBox(height: 8),
          PillButton(
            label: '가이드 탐색하기',
            primary: true,
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
        ],
      ),
    );
  }
}
