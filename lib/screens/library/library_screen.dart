// lib/screens/library/library_screen.dart
// 내 서재 화면 — 컬렉션 / 이어듣기 / 즐겨찾기 / 크리에이터

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';

class LibraryScreen extends StatefulWidget {
  final int initialTab;
  const LibraryScreen({super.key, this.initialTab = 0});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late int _tabIndex;
  final _tabs = ['컬렉션', '이어듣기', '즐겨찾기', '크리에이터'];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC    = isDark ? GuidyColors.darkBg   : GuidyColors.bg;
    final lineC  = isDark ? GuidyColors.darkLine  : GuidyColors.line;

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
                    final isA    = i == _tabIndex;
                    final textC  = isDark ? GuidyColors.darkText  : GuidyColors.ink;
                    final muteC  = isDark ? GuidyColors.darkMute  : GuidyColors.mute;
                    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
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
                  _CreatorsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 컬렉션 탭 ───────────────────────────────────────────
class _CollectionTab extends StatelessWidget {
  const _CollectionTab();

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final textC    = isDark ? GuidyColors.darkText    : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub     : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute    : GuidyColors.mute;
    final lineC    = isDark ? GuidyColors.darkLine    : GuidyColors.line;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final store    = context.read<AppStore>();
    final exhibitions = store.exhibitions;

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
            itemCount: exhibitions.where((e) => e.isActive).length,
            itemBuilder: (context, i) {
              final items = exhibitions.where((e) => e.isActive).toList();
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
        ...exhibitions
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
                          Text(e.title,
                            style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
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

// ─── 이어듣기 탭 ─────────────────────────────────────────
class _ContinueTab extends StatelessWidget {
  const _ContinueTab();

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final textC    = isDark ? GuidyColors.darkText    : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub     : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute    : GuidyColors.mute;
    final lineC    = isDark ? GuidyColors.darkLine    : GuidyColors.line;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final accentC  = isDark ? GuidyColors.darkAccent  : GuidyColors.accent;
    final artworks = context.read<AppStore>().artworks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: artworks.map((a) => Container(
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
                  GuidyCover(seed: a.imageSeed, width: 60, height: 60,
                    borderRadius: GuidyRadius.lgBorder),
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
                    Text(a.title,
                      style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
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

// ─── 즐겨찾기 탭 ─────────────────────────────────────────
class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    final userStore  = context.watch<UserStore>();
    final store      = context.read<AppStore>();
    final favorites  = userStore.favorites;
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final textC      = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC       = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC      = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final lineC      = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final surfaceC   = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final accentC    = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outlined, size: 64, color: muteC),
            const SizedBox(height: 12),
            Text('즐겨찾기한 가이드가 없습니다', style: GuidyText.body(muteC)),
            const SizedBox(height: 8),
            Text('전시 상세에서 북마크 버튼을 눌러 저장하세요',
              style: GuidyText.small(muteC)),
            const SizedBox(height: 16),
            PillButton(
              label: '가이드 탐색하기',
              primary: true,
              onPressed: () => Navigator.pushNamed(context, '/'),
            ),
          ],
        ),
      );
    }

    final favExhibitions = favorites
        .map((id) => store.exhibitionById(id))
        .whereType<Exhibition>()
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('즐겨찾기한 전시 ${favExhibitions.length}개',
          style: GuidyText.small(muteC)),
        const SizedBox(height: 12),
        ...favExhibitions.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: surfaceC,
            borderRadius: GuidyRadius.lgBorder,
            border: Border.all(color: lineC),
          ),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/detail/${e.id}'),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: GuidyCover(
                    seed: e.coverSeed,
                    width: 80, height: 80,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChannelBadge(type: e.channel),
                      const SizedBox(height: 4),
                      Text(e.title,
                        style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(e.venue, style: GuidyText.small(subC)),
                      const SizedBox(height: 4),
                      Text(e.price == 0
                        ? '무료'
                        : '₩${_formatPrice(e.price)}',
                        style: GuidyText.kicker(accentC)
                          .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                // 즐겨찾기 해제
                GestureDetector(
                  onTap: () => context.read<UserStore>().toggleFavorite(e.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(Icons.bookmark_rounded, color: accentC, size: 20),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── 크리에이터 탭 ───────────────────────────────────────
class _CreatorsTab extends StatelessWidget {
  const _CreatorsTab();

  @override
  Widget build(BuildContext context) {
    final userStore  = context.watch<UserStore>();
    final following  = userStore.following;
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final textC      = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC       = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC      = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final lineC      = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final surfaceC   = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;

    if (following.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: muteC),
            const SizedBox(height: 12),
            Text('팔로우한 크리에이터가 없습니다', style: GuidyText.body(muteC)),
            const SizedBox(height: 8),
            Text('크리에이터 가이드에서 팔로우를 눌러보세요',
              style: GuidyText.small(muteC)),
          ],
        ),
      );
    }

    // 팔로우 중인 크리에이터 목록 (DummyData에서)
    final followedCreators = DummyData.creators
        .where((c) => following.contains(c.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('팔로우 중인 크리에이터 ${followedCreators.length}명',
          style: GuidyText.small(muteC)),
        const SizedBox(height: 12),
        ...followedCreators.map((creator) {
          Color avatarColor;
          try {
            final hex = creator.avatarColor.replaceFirst('#', '');
            avatarColor = Color(int.parse('FF$hex', radix: 16));
          } catch (_) {
            avatarColor = GuidyColors.primary;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceC,
              borderRadius: GuidyRadius.lgBorder,
              border: Border.all(color: lineC),
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/creator/${creator.id}'),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: avatarColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        creator.name.isNotEmpty ? creator.name[0] : 'C',
                        style: TextStyle(
                          color: avatarColor,
                          fontSize: 20, fontWeight: FontWeight.w800,
                          fontFamily: GuidyText.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(creator.name,
                              style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                            if (creator.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded,
                                size: 14, color: GuidyColors.accent),
                            ],
                          ],
                        ),
                        Text(creator.title, style: GuidyText.small(subC)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _stat(Icons.people_outline_rounded,
                              _formatCount(creator.followerCount), muteC),
                            const SizedBox(width: 10),
                            _stat(Icons.headphones_outlined,
                              '${creator.guideCount}개 가이드', muteC),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 언팔로우 버튼
                  GestureDetector(
                    onTap: () => context.read<UserStore>().toggleFollow(creator.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Text('팔로잉',
                        style: GuidyText.kicker(muteC).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _stat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
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
