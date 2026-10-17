// lib/screens/creator_guides/creator_guides_screen.dart
// 크리에이터 가이드 목록 — 개별 결제 잠금 (B안)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../models/user_store.dart';
import '../../widgets/common_widgets.dart';

class CreatorGuidesScreen extends StatelessWidget {
  final String exhibitionId;
  const CreatorGuidesScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context) {
    final store      = context.read<AppStore>();
    final exhibition = store.exhibitionById(exhibitionId);
    final guides     = store.creatorGuidesFor(exhibitionId);

    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final accentC  = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 헤더 ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
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
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('크리에이터 가이드', style: GuidyText.h3(textC)),
                        if (exhibition != null)
                          Text(exhibition.title, style: GuidyText.small(subC)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── 전시 히어로 배너 ───────────────────────
            if (exhibition != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentC.withOpacity(0.08),
                    borderRadius: GuidyRadius.lgBorder,
                    border: Border.all(color: accentC.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      GuidyCover(
                          seed: exhibition.coverSeed,
                          width: 52, height: 52,
                          borderRadius: GuidyRadius.mdBorder),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exhibition.title,
                              style: GuidyText.body(textC)
                                  .copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(exhibition.venue,
                                style: GuidyText.small(subC)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.mic_rounded, size: 12, color: accentC),
                              const SizedBox(width: 4),
                              Text('${guides.length}개의 크리에이터 가이드',
                                style: GuidyText.kicker(accentC)
                                    .copyWith(fontWeight: FontWeight.w700)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ─── 안내 문구 ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text('가이드 선택', style: GuidyText.h3(textC)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 11, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text('가이드별 개별 결제',
                          style: GuidyText.kicker(const Color(0xFFF59E0B))
                              .copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── 가이드 목록 ────────────────────────────
            Expanded(
              child: guides.isEmpty
                  ? _EmptyGuides(muteC: muteC)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: guides.length,
                      itemBuilder: (context, i) => _GuideCard(
                        guide: guides[i],
                        exhibition: exhibition,
                        isDark: isDark,
                        textC: textC, subC: subC,
                        lineC: lineC, surfaceC: surfaceC,
                        muteC: muteC, accentC: accentC,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 빈 상태 ────────────────────────────────────────────
class _EmptyGuides extends StatelessWidget {
  final Color muteC;
  const _EmptyGuides({required this.muteC});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded, size: 56, color: muteC),
          const SizedBox(height: 12),
          Text('아직 등록된 크리에이터 가이드가 없습니다',
              style: GuidyText.body(muteC)),
          const SizedBox(height: 6),
          Text('크리에이터들이 이 전시의 가이드를 준비 중이에요',
              style: GuidyText.small(muteC)),
        ],
      ),
    );
  }
}

// ─── 가이드 카드 ────────────────────────────────────────
class _GuideCard extends StatelessWidget {
  final CreatorGuide guide;
  final Exhibition? exhibition;
  final bool isDark;
  final Color textC, subC, lineC, surfaceC, muteC, accentC;

  const _GuideCard({
    required this.guide,
    required this.exhibition,
    required this.isDark,
    required this.textC, required this.subC,
    required this.lineC, required this.surfaceC,
    required this.muteC, required this.accentC,
  });

  @override
  Widget build(BuildContext context) {
    final userStore    = context.watch<UserStore>();
    final isFollowing  = userStore.isFollowing(guide.creatorId);
    final isPurchased  = userStore.hasPurchasedGuide(guide.id);
    final isFree       = guide.price == 0;
    final canPlay      = isPurchased || isFree;

    // 아바타 색상
    Color avatarC;
    try {
      avatarC = Color(int.parse('FF${guide.avatarColor.replaceFirst('#', '')}',
          radix: 16));
    } catch (_) {
      avatarC = GuidyColors.primary;
    }

    final durMin = guide.durationSec ~/ 60;
    final durSec = guide.durationSec % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(
          color: canPlay ? lineC : lineC.withOpacity(0.6),
        ),
      ),
      child: Column(
        children: [
          // ── 크리에이터 정보 행 ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // 아바타
                Stack(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: avatarC.withOpacity(canPlay ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          guide.creatorName.isNotEmpty
                              ? guide.creatorName[0]
                              : 'C',
                          style: TextStyle(
                            color: canPlay
                                ? avatarC
                                : avatarC.withOpacity(0.5),
                            fontSize: 18, fontWeight: FontWeight.w800,
                            fontFamily: GuidyText.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    // 구매 완료 뱃지
                    if (isPurchased)
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: GuidyColors.ok,
                            shape: BoxShape.circle,
                            border: Border.all(color: surfaceC, width: 1.5),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(guide.creatorName,
                          style: GuidyText.body(textC)
                              .copyWith(fontWeight: FontWeight.w700)),
                        if (guide.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 14, color: GuidyColors.accent),
                        ],
                      ]),
                      Text(guide.creatorTitle, style: GuidyText.small(subC)),
                    ],
                  ),
                ),
                // 팔로우 버튼
                GestureDetector(
                  onTap: () =>
                      context.read<UserStore>().toggleFollow(guide.creatorId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFollowing
                          ? surfaceC
                          : accentC.withOpacity(0.12),
                      borderRadius: GuidyRadius.pillBorder,
                      border: Border.all(
                        color: isFollowing
                            ? lineC
                            : accentC.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      isFollowing ? '팔로잉' : '팔로우',
                      style: GuidyText.kicker(isFollowing ? muteC : accentC)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: lineC, height: 1),

          // ── 가이드 정보 + 재생 버튼 ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guide.guideTitle,
                  style: GuidyText.body(textC)
                      .copyWith(fontWeight: FontWeight.w600)),
                if (guide.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(guide.description,
                    style: GuidyText.small(subC),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _metaStat(Icons.timer_outlined,
                      '$durMin:${durSec.toString().padLeft(2, '0')}', muteC),
                    const SizedBox(width: 14),
                    _metaStat(Icons.play_circle_outline_rounded,
                      _fmtCount(guide.plays), muteC),
                    const SizedBox(width: 14),
                    _metaStat(Icons.star_rounded,
                      guide.rating > 0
                          ? guide.rating.toStringAsFixed(1)
                          : '-',
                      muteC,
                      iconColor: const Color(0xFFF59E0B)),
                    const Spacer(),
                    // ── 재생 or 잠금 버튼 ──────────────
                    canPlay
                        ? _PlayButton(
                            guide: guide,
                            accentC: accentC,
                          )
                        : _BuyButton(
                            guide: guide,
                            exhibition: exhibition,
                            surfaceC: surfaceC,
                            lineC: lineC,
                            textC: textC,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaStat(IconData icon, String label, Color color,
      {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor ?? color),
        const SizedBox(width: 3),
        Text(label, style: GuidyText.kicker(color)),
      ],
    );
  }

  String _fmtCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000)  return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}

// ─── 재생 버튼 (구매 완료 / 무료) ───────────────────────
class _PlayButton extends StatelessWidget {
  final CreatorGuide guide;
  final Color accentC;
  const _PlayButton({required this.guide, required this.accentC});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final artworkId = guide.firstArtworkId ?? 'a1';
        Navigator.pushNamed(context, '/player/$artworkId');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: accentC,
          borderRadius: GuidyRadius.pillBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text('재생', style: GuidyText.small(Colors.white)
                .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── 구매 버튼 (잠금 상태) ──────────────────────────────
class _BuyButton extends StatelessWidget {
  final CreatorGuide guide;
  final Exhibition? exhibition;
  final Color surfaceC, lineC, textC;

  const _BuyButton({
    required this.guide,
    required this.exhibition,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
  });

  String _fmtPrice(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPurchaseDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withOpacity(0.12),
          borderRadius: GuidyRadius.pillBorder,
          border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded,
                size: 14, color: Color(0xFFF59E0B)),
            const SizedBox(width: 5),
            Text('₩${_fmtPrice(guide.price)}',
              style: GuidyText.small(const Color(0xFFF59E0B))
                  .copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final surfC    = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC2   = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final lineC2   = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;

    // 아바타 색상
    Color avatarC;
    try {
      avatarC = Color(int.parse(
          'FF${guide.avatarColor.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      avatarC = GuidyColors.primary;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: surfC,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: lineC2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 제목
            Text('가이드 구매', style: GuidyText.h3(textC2)),
            const SizedBox(height: 16),

            // 크리에이터 + 가이드 정보 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 크리에이터
                  Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: avatarC.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          guide.creatorName.isNotEmpty
                              ? guide.creatorName[0]
                              : 'C',
                          style: TextStyle(
                            color: avatarC, fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: GuidyText.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(guide.creatorName,
                            style: GuidyText.body(textC2)
                                .copyWith(fontWeight: FontWeight.w700)),
                          if (guide.isVerified) ...[
                            const SizedBox(width: 3),
                            const Icon(Icons.verified_rounded,
                                size: 13, color: GuidyColors.accent),
                          ],
                        ]),
                        Text(guide.creatorTitle,
                            style: GuidyText.small(subC)),
                      ],
                    ),
                  ]),
                  Divider(color: lineC2, height: 20),
                  Text(guide.guideTitle,
                    style: GuidyText.body(textC2)
                        .copyWith(fontWeight: FontWeight.w600)),
                  if (guide.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(guide.description,
                      style: GuidyText.small(subC),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 10),
                  Row(children: [
                    _stat(Icons.timer_outlined,
                      '${guide.durationSec ~/ 60}분', muteC),
                    const SizedBox(width: 12),
                    _stat(Icons.star_rounded,
                      guide.rating > 0
                          ? guide.rating.toStringAsFixed(1)
                          : '-',
                      const Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    _stat(Icons.play_circle_outline_rounded,
                      _fmtCount(guide.plays), muteC),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 가격 행
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.08),
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 18, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('결제 금액',
                            style: GuidyText.small(
                                const Color(0xFFF59E0B))),
                        Text('이 가이드는 1회 결제 후 영구 이용 가능합니다',
                          style: GuidyText.kicker(muteC)),
                      ],
                    ),
                  ),
                  Text('₩${_fmtPrice(guide.price)}',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 20, fontWeight: FontWeight.w900,
                      fontFamily: GuidyText.fontFamily,
                    )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 취소 + 구매 버튼
            Row(children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: bgC,
                      borderRadius: GuidyRadius.pillBorder,
                      border: Border.all(color: lineC2),
                    ),
                    child: Center(
                      child: Text('취소',
                          style: GuidyText.body(muteC)
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _processPurchase(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Center(
                      child: Text(
                        '₩${_fmtPrice(guide.price)} 구매하기',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15, fontWeight: FontWeight.w800,
                          fontFamily: GuidyText.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _processPurchase(BuildContext context) {
    final userStore = context.read<UserStore>();
    final purchase  = Purchase(
      id:               'g_${DateTime.now().millisecondsSinceEpoch}',
      exhibitionId:     guide.exhibitionId,
      exhibitionTitle:  exhibition?.title ?? '',
      venueName:        exhibition?.venue ?? '',
      coverSeed:        exhibition?.coverSeed ?? 0,
      pricePaid:        guide.price,
      purchasedAt:      DateTime.now(),
      status:           PurchaseStatus.unused,
      type:             PurchaseType.guide,
      guideId:          guide.id,
      guideTitle:       guide.guideTitle,
      creatorName:      guide.creatorName,
    );
    userStore.addPurchase(purchase);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('「${guide.guideTitle}」 구매 완료!\n지금 바로 재생하세요.'),
          ),
        ]),
        backgroundColor: GuidyColors.ok,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _stat(IconData icon, String label, Color c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 3),
        Text(label, style: GuidyText.kicker(c)),
      ],
    );
  }

  String _fmtCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000)  return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}
