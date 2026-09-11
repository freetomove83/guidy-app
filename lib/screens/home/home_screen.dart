// lib/screens/home/home_screen.dart
// HomeB - 크리에이터 발견 (윌라스토리 감성)

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/ad_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  final _tabs = ['발견', '큐레이션', '크리에이터', '아카이브', '팔로잉'];

  // ── 광고 상태 ───────────────────────────────────────────
  bool _showPopupAd   = false;
  bool _showSlideUpAd = false;

  @override
  void initState() {
    super.initState();
    // 홈 진입 0.8초 후 팝업 광고 표시
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && AdDataStore.popupAd != null) {
        setState(() => _showPopupAd = true);
      }
    });
    // 팝업 닫힌 후 2초 뒤 슬라이드업 광고 표시
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && AdDataStore.slideUpAd != null && !_showPopupAd) {
        setState(() => _showSlideUpAd = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;

    return Scaffold(
      backgroundColor: bgC,
      body: Stack(
        children: [
          // ── 메인 콘텐츠 ────────────────────────────────
          SafeArea(
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

          // ── 홈 팝업 광고 ─────────────────────────────
          if (_showPopupAd && AdDataStore.popupAd != null)
            HomePopupAd(
              ad: AdDataStore.popupAd!,
              onClose: () {
                setState(() => _showPopupAd = false);
                // 팝업 닫힌 후 1.5초 후 슬라이드업 노출
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted && AdDataStore.slideUpAd != null) {
                    setState(() => _showSlideUpAd = true);
                  }
                });
              },
              onNavigate: (route) {
                setState(() => _showPopupAd = false);
                if (route.startsWith('/')) {
                  Navigator.pushNamed(context, route);
                }
              },
            ),

          // ── 홈 하단 슬라이드업 광고 ───────────────────
          if (_showSlideUpAd && AdDataStore.slideUpAd != null)
            HomeSlideUpAd(
              ad: AdDataStore.slideUpAd!,
              onClose: () => setState(() => _showSlideUpAd = false),
              onNavigate: (route) {
                setState(() => _showSlideUpAd = false);
                if (route.startsWith('/')) {
                  Navigator.pushNamed(context, route);
                }
              },
            ),
        ],
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
          height: 170,
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
              childAspectRatio: 0.62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
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
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textC     = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC     = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC  = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC     = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC  = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;
    final accentC   = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    final archives = DummyData.exhibitions
        .where((e) => e.channel == ChannelType.archive)
        .toList();

    if (archives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: muteC),
            const SizedBox(height: 12),
            Text('아카이브된 전시가 없습니다', style: GuidyText.body(muteC)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ─── 스크롤 영역 ─────────────────────────────────
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ─── 무료/유료 구분 범례 ───────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: GuidyColors.ok.withValues(alpha: 0.12),
                          borderRadius: GuidyRadius.pillBorder,
                          border: Border.all(
                              color: GuidyColors.ok.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_open_rounded,
                                size: 11, color: GuidyColors.ok),
                            const SizedBox(width: 4),
                            Text('무료 감상',
                                style: GuidyText.kicker(GuidyColors.ok)
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('표시된 전시는 결제 없이 감상 가능',
                          style: GuidyText.small(muteC)),
                    ],
                  ),
                ),
              ),

              // ─── 전시 그리드 ───────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ArchiveCard(
                      exhibition: archives[i],
                      onTap: () => Navigator.pushNamed(
                          context, '/detail/${archives[i].id}'),
                    ),
                    childCount: archives.length,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── 하단 고정 띠 배너 ────────────────────────────
        _ArchiveNoticeBanner(
          isDark: isDark,
          textC: textC,
          subC: subC,
          surfaceC: surfaceC,
          lineC: lineC,
          primaryC: primaryC,
          accentC: accentC,
          onTap: () => Navigator.pushNamed(context, '/detail/e3'),
        ),
      ],
    );
  }
}

// ─── 아카이브 하단 고정 띠 배너 ──────────────────────────────
class _ArchiveNoticeBanner extends StatelessWidget {
  final bool isDark;
  final Color textC, subC, surfaceC, lineC, primaryC, accentC;
  final VoidCallback onTap;

  const _ArchiveNoticeBanner({
    required this.isDark,
    required this.textC,
    required this.subC,
    required this.surfaceC,
    required this.lineC,
    required this.primaryC,
    required this.accentC,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceC,
          border: Border(
            top: BorderSide(color: lineC, width: 1),
          ),
        ),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryC.withValues(alpha: 0.15),
                    accentC.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: GuidyRadius.mdBorder,
              ),
              child: Icon(Icons.headphones_rounded, size: 18, color: primaryC),
            ),
            const SizedBox(width: 12),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '아카이브 무료 감상 가능',
                    style: GuidyText.body(textC)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '종료된 전시도 오디오 가이드로 언제든 다시 만나보세요',
                    style: GuidyText.small(subC),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 화살표
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: primaryC.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: primaryC,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 아카이브 전용 카드 (무료 배지 오버레이) ─────────────────
class _ArchiveCard extends StatelessWidget {
  final Exhibition exhibition;
  final VoidCallback onTap;
  const _ArchiveCard({required this.exhibition, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 기본 ExhibitionCard
        ExhibitionCard(exhibition: exhibition, onTap: onTap),
        // 무료 감상 배지 오버레이
        if (exhibition.isFreeAccess)
          Positioned(
            bottom: 10, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GuidyColors.ok,
                  borderRadius: GuidyRadius.pillBorder,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open_rounded,
                        size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('무료 감상',
                        style: GuidyText.kicker(Colors.white)
                            .copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
      ],
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
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => ExhibitionCard(
        exhibition: items[i],
        onTap: () => Navigator.pushNamed(context, '/detail/${items[i].id}'),
      ),
    );
  }
}
