// lib/screens/home/home_screen.dart
// HomeB - 크리에이터 발견 (윌라스토리 감성)

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  final _tabs = ['발견', '큐레이션', '크리에이터', '아카이브', '팔로잉'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 헤더
            GuidyHeader(showLogo: true, showSearch: true, showBell: true),
            // 카테고리 탭
            CategoryTabs(
              tabs: _tabs,
              activeIndex: _tabIndex,
              onChanged: (i) {
                setState(() => _tabIndex = i);
                if (i == 4) {
                  _navigateToFollowing();
                }
              },
            ),
            // 콘텐츠
            Expanded(
              child: IndexedStack(
                index: _tabIndex == 4 ? 0 : _tabIndex,
                children: const [
                  _DiscoverTab(),
                  _CurationTab(),
                  _CreatorTab(),
                  _ArchiveTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFollowing() {
    Navigator.pushNamed(context, '/following').then((_) {
      setState(() => _tabIndex = 0);
    });
  }
}

// ─── 발견 탭 ─────────────────────────────────────────────
class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── 이달의 크리에이터 히어로 배너 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/creator/c1'),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: GuidyRadius.xlBorder,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryC, accentC],
                ),
                boxShadow: GuidyShadow.pop,
              ),
              child: Stack(
                children: [
                  // 배경 패턴
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HeroBgPainter(isDark: isDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: GuidyRadius.pillBorder,
                              ),
                              child: const Text('이달의 크리에이터',
                                style: TextStyle(color: Colors.white, fontSize: 10,
                                  fontWeight: FontWeight.w800, letterSpacing: 0.5,
                                  fontFamily: GuidyText.fontFamily),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Center(
                                child: Text('김', style: TextStyle(
                                  color: Colors.white, fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: GuidyText.fontFamily,
                                )),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('김도슨트', style: TextStyle(
                                    color: Colors.white, fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: GuidyText.fontFamily,
                                    letterSpacing: -0.4,
                                  )),
                                  Text('미술사 큐레이터 · 가이드 14개',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12, fontFamily: GuidyText.fontFamily,
                                    )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            PillButton(label: '팔로우'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: GuidyRadius.pillBorder,
                              ),
                              child: Text('가이드 보기', style: TextStyle(
                                color: primaryC, fontSize: 12, fontWeight: FontWeight.w700,
                                fontFamily: GuidyText.fontFamily,
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── 주목받는 크리에이터 ──
        const SectionHeader(title: '주목받는 크리에이터', action: '더보기 →'),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: DummyData.creators.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final cr = DummyData.creators[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/creator/${cr.id}'),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceC,
                    borderRadius: GuidyRadius.lgBorder,
                    border: Border.all(color: lineC),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CreatorAvatar(creator: cr, size: 52, showBadgeRing: true),
                      const SizedBox(height: 8),
                      Text(cr.name, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      const SizedBox(height: 2),
                      Text(cr.title, style: GuidyText.small(muteC),
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text('팔로워 ${_formatNum(cr.followerCount)}',
                        style: GuidyText.kicker(subC)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 28),

        // ── 이번 주 새 가이드 ──
        const SectionHeader(title: '이번 주 새 가이드', action: '더보기 →'),
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
            itemCount: DummyData.exhibitions.length,
            itemBuilder: (context, i) {
              return ExhibitionCard(
                exhibition: DummyData.exhibitions[i],
                onTap: () => Navigator.pushNamed(context, '/detail/${DummyData.exhibitions[i].id}'),
              );
            },
          ),
        ),

        const SizedBox(height: 28),

        // ── 크리에이터 CTA ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/creator-studio'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? GuidyColors.darkBgAlt : GuidyColors.bgAlt,
                borderRadius: GuidyRadius.xlBorder,
                border: Border.all(color: lineC),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: accentC.withValues(alpha: 0.15),
                      borderRadius: GuidyRadius.lgBorder,
                    ),
                    child: Icon(Icons.mic_rounded, color: accentC, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('크리에이터가 되어보세요',
                          style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('나만의 오디오 가이드를 만들고 수익을 창출하세요',
                          style: GuidyText.small(subC)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: muteC),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 80), // 하단 네비 여백
      ],
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// Hero 배경 painter
class _HeroBgPainter extends CustomPainter {
  final bool isDark;
  const _HeroBgPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 80, p);
    p.color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 60, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── 큐레이션 탭 ─────────────────────────────────────────
class _CurationTab extends StatelessWidget {
  const _CurationTab();

  @override
  Widget build(BuildContext context) {
    final curations = DummyData.exhibitions
        .where((e) => e.channel == ChannelType.curation)
        .toList();

    return _ExhibitionListTab(
      items: curations,
      emptyMessage: '진행 중인 큐레이션 전시가 없습니다',
    );
  }
}

// ─── 크리에이터 탭 ───────────────────────────────────────
class _CreatorTab extends StatelessWidget {
  const _CreatorTab();

  @override
  Widget build(BuildContext context) {
    final creators_items = DummyData.exhibitions
        .where((e) => e.channel == ChannelType.creator)
        .toList();

    return _ExhibitionListTab(
      items: creators_items,
      emptyMessage: '크리에이터 가이드가 없습니다',
    );
  }
}

// ─── 아카이브 탭 ─────────────────────────────────────────
class _ArchiveTab extends StatelessWidget {
  const _ArchiveTab();

  @override
  Widget build(BuildContext context) {
    final archives = DummyData.exhibitions
        .where((e) => e.channel == ChannelType.archive)
        .toList();

    return _ExhibitionListTab(
      items: archives,
      emptyMessage: '아카이브된 전시가 없습니다',
    );
  }
}

class _ExhibitionListTab extends StatelessWidget {
  final List<Exhibition> items;
  final String emptyMessage;

  const _ExhibitionListTab({required this.items, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 48, color: muteC),
            const SizedBox(height: 12),
            Text(emptyMessage, style: GuidyText.body(muteC)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => ExhibitionCard(
        exhibition: items[i],
        onTap: () => Navigator.pushNamed(context, '/detail/${items[i].id}'),
      ),
    );
  }
}
