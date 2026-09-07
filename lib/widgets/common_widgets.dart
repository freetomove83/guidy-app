// lib/widgets/common_widgets.dart
// Guidy 공통 컴포넌트 모음

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── Cover (SVG 그라디언트 플레이스홀더) ────────────────────
class GuidyCover extends StatelessWidget {
  final int seed;
  final double? width;
  final double? height;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final String? imageUrl;

  const GuidyCover({
    super.key,
    required this.seed,
    this.width,
    this.height,
    this.aspectRatio = 3 / 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.imageUrl,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFF0B3D5C), Color(0xFF1A5A7A)],
    [Color(0xFFD97757), Color(0xFFE89575)],
    [Color(0xFF2F8F5C), Color(0xFF4AB07A)],
    [Color(0xFF7D6A94), Color(0xFF9D8AB4)],
    [Color(0xFF0B3D5C), Color(0xFFD97757)],
    [Color(0xFF1A3A2A), Color(0xFF2F8F5C)],
    [Color(0xFF3A1A2A), Color(0xFF7D3A5C)],
    [Color(0xFF1A2A3A), Color(0xFF0B3D5C)],
  ];

  List<Color> get _colors => _gradients[seed % _gradients.length];

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (imageUrl != null) {
      img = Image.network(imageUrl!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      img = _placeholder();
    }

    if (width != null || height != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(width: width, height: height, child: img),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(aspectRatio: aspectRatio, child: img),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CoverPatternPainter(seed: seed)),
          ),
        ],
      ),
    );
  }
}

class _CoverPatternPainter extends CustomPainter {
  final int seed;
  const _CoverPatternPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final r = size.width * 0.6 + (seed * 13.0 % 40);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), r, paint);
    paint.color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), r * 0.7, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── ChannelBadge ────────────────────────────────────────
class ChannelBadge extends StatelessWidget {
  final ChannelType type;
  final String? size; // 'sm' | 'md'

  const ChannelBadge({super.key, required this.type, this.size = 'sm'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = _label();
    final bg = _bg(isDark);
    final textColor = Colors.white;
    final fontSize = size == 'sm' ? 9.0 : 11.0;
    final px = size == 'sm' ? 6.0 : 8.0;
    final py = size == 'sm' ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(color: bg, borderRadius: GuidyRadius.pillBorder),
      child: Text(label, style: TextStyle(
        fontFamily: GuidyText.fontFamily, fontSize: fontSize,
        fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.2,
      )),
    );
  }

  String _label() {
    switch (type) {
      case ChannelType.curation: return '🏛 큐레이션';
      case ChannelType.creator: return '🎨 크리에이터';
      case ChannelType.archive: return '📚 아카이브';
    }
  }

  Color _bg(bool isDark) {
    switch (type) {
      case ChannelType.curation: return isDark ? GuidyColors.darkCuration : GuidyColors.curation;
      case ChannelType.creator: return isDark ? GuidyColors.darkCreator : GuidyColors.creator;
      case ChannelType.archive: return isDark ? GuidyColors.darkArchive : GuidyColors.archive;
    }
  }
}

// ─── PillButton ──────────────────────────────────────────
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final String size; // 'sm' | 'md' | 'lg'
  final IconData? icon;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = false,
    this.size = 'md',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final bgC = isDark ? GuidyColors.darkSurface : GuidyColors.chip;
    final bg = primary ? (isDark ? GuidyColors.darkText : GuidyColors.ink) : bgC;
    final fg = primary ? (isDark ? GuidyColors.darkBg : Colors.white) : textC;

    final (py, px, fs) = switch (size) {
      'sm' => (8.0, 14.0, 12.0),
      'lg' => (14.0, 22.0, 15.0),
      _ => (11.0, 18.0, 14.0),
    };

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
        decoration: BoxDecoration(color: bg, borderRadius: GuidyRadius.pillBorder),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: fs + 2),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(
              fontFamily: GuidyText.fontFamily, fontSize: fs,
              fontWeight: FontWeight.w700, color: fg, letterSpacing: -0.1,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── CategoryTabs ────────────────────────────────────────
class CategoryTabs extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const CategoryTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: lineC, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isActive = i == activeIndex;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? primaryC : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontFamily: GuidyText.fontFamily,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive ? textC : muteC,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── CreatorAvatar ───────────────────────────────────────
class CreatorAvatar extends StatelessWidget {
  final Creator creator;
  final double size;
  final bool showBadgeRing;
  final bool showNewBadge;
  final int newCount;

  const CreatorAvatar({
    super.key,
    required this.creator,
    this.size = 48,
    this.showBadgeRing = false,
    this.showNewBadge = false,
    this.newCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = GuidyColors.creator;
    final bgColor = _parseColor(creator.avatarColor);

    return SizedBox(
      width: size + (showBadgeRing ? 8 : 0),
      height: size + (showBadgeRing ? 8 : 0),
      child: Stack(
        children: [
          Container(
            width: size + (showBadgeRing ? 8 : 0),
            height: size + (showBadgeRing ? 8 : 0),
            decoration: showBadgeRing ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 2),
            ) : null,
            padding: showBadgeRing ? const EdgeInsets.all(3) : EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bgColor, bgColor.withValues(alpha: 0.7)],
                ),
              ),
              child: Center(
                child: Text(
                  creator.name.substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w800,
                    fontFamily: GuidyText.fontFamily,
                  ),
                ),
              ),
            ),
          ),
          if (showNewBadge && newCount > 0)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: GuidyColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  newCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ─── GuidyHeader ─────────────────────────────────────────
class GuidyHeader extends StatelessWidget {
  final String? title;
  final bool showBack;
  final bool showSearch;
  final bool showBell;
  final bool showShare;
  final bool showHeart;
  final List<Widget>? actions;
  final bool showLogo;
  final VoidCallback? onBack;
  final bool isDark;

  const GuidyHeader({
    super.key,
    this.title,
    this.showBack = false,
    this.showSearch = false,
    this.showBell = false,
    this.showShare = false,
    this.showHeart = false,
    this.actions,
    this.showLogo = false,
    this.onBack,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark || Theme.of(context).brightness == Brightness.dark;
    final textC = dark ? GuidyColors.darkText : GuidyColors.ink;
    final accentC = dark ? GuidyColors.darkAccent : GuidyColors.accent;
    final bgC = dark ? GuidyColors.darkBg : GuidyColors.bg;

    return Container(
      color: bgC,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: dark ? GuidyColors.darkSurface : GuidyColors.surface,
                  borderRadius: GuidyRadius.mdBorder,
                  border: Border.all(color: dark ? GuidyColors.darkLine : GuidyColors.line),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textC),
              ),
            ),
          if (showLogo) ...[
            ClipRRect(
              borderRadius: GuidyRadius.smBorder,
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 30, height: 30, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text('Guidy', style: TextStyle(
              fontFamily: GuidyText.fontFamily,
              fontSize: 20, fontWeight: FontWeight.w800,
              letterSpacing: -0.6, color: textC,
            )),
          ],
          if (title != null && !showLogo) ...[
            if (showBack) const SizedBox(width: 12),
            Expanded(
              child: Text(title!, style: TextStyle(
                fontFamily: GuidyText.fontFamily,
                fontSize: 17, fontWeight: FontWeight.w800,
                letterSpacing: -0.3, color: textC,
              )),
            ),
          ],
          const Spacer(),
          ...?actions,
          if (showHeart)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.favorite_border_rounded, size: 22, color: textC),
            ),
          if (showShare)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.share_outlined, size: 22, color: textC),
            ),
          if (showSearch)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/search'),
                child: Icon(Icons.search_rounded, size: 24, color: textC),
              ),
            ),
          if (showBell)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_outlined, size: 24, color: textC),
                    Positioned(
                      top: -1, right: -1,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: accentC,
                          shape: BoxShape.circle,
                          border: Border.all(color: bgC, width: 1.5),
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
}

// ─── MiniPlayer (하단 고정) ───────────────────────────────
class MiniPlayer extends StatelessWidget {
  final String artworkTitle;
  final String exhibitionTitle;
  final int coverSeed;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;

  const MiniPlayer({
    super.key,
    required this.artworkTitle,
    required this.exhibitionTitle,
    required this.coverSeed,
    this.isPlaying = false,
    this.onTap,
    this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: GuidyRadius.pillBorder,
          border: Border.all(color: lineC),
          boxShadow: GuidyShadow.up,
        ),
        child: Row(
          children: [
            GuidyCover(seed: coverSeed, width: 40, height: 40,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(artworkTitle, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(exhibitionTitle, style: GuidyText.small(subC), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.replay_10_rounded, size: 22, color: GuidyColors.sub),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                      color: GuidyColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white, size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.forward_10_rounded, size: 22, color: GuidyColors.sub),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SectionHeader ───────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: GuidyText.h3(textC)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: GuidyText.small(muteC).copyWith(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// ─── ExhibitionCard (그리드용) ────────────────────────────
class ExhibitionCard extends StatelessWidget {
  final Exhibition exhibition;
  final VoidCallback? onTap;
  /// 0.0 ~ 1.0 사이 진행률. null 이면 바를 표시하지 않음
  final double? progressRatio;

  const ExhibitionCard({
    super.key,
    required this.exhibition,
    this.onTap,
    this.progressRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,          // 그리드 셀 전체 높이 점유
        decoration: BoxDecoration(
          color: surface,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 이미지 영역: 고정 높이로 텍스트 공간 보장 ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GuidyCover(
                      seed: exhibition.coverSeed,
                      height: 150,
                      borderRadius: BorderRadius.zero,
                    ),
                    Positioned(
                      top: 10, left: 10,
                      child: ChannelBadge(type: exhibition.channel),
                    ),
                    if (exhibition.isActive)
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: GuidyColors.ok,
                            borderRadius: GuidyRadius.pillBorder,
                          ),
                          child: const Text('진행 중', style: TextStyle(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800,
                          )),
                        ),
                      ),
                    // ── 진행률 바 — ClipRRect 내부라 이미지와 자연스럽게 일체화 ──
                    if (progressRatio != null)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 그라데이션 마스크: 위쪽 페이드인
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.32),
                                  ],
                                ),
                              ),
                            ),
                            // 실제 진행 바: 3px 두께
                            SizedBox(
                              height: 3,
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: (progressRatio! * 1000).round().clamp(1, 1000),
                                    child: Container(color: GuidyColors.accent),
                                  ),
                                  Flexible(
                                    flex: ((1 - progressRatio!) * 1000).round().clamp(0, 999),
                                    child: Container(
                                      color: Colors.white.withValues(alpha: 0.30),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // ── 텍스트 영역: Expanded로 남은 공간 모두 사용 ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 제목 + 장소
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exhibition.title,
                          style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exhibition.venue,
                          style: GuidyText.small(subC),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // 작품수·시간 + 가격 + 진행 바 (하단 고정)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${exhibition.workCount}작품 · ${exhibition.duration}',
                                style: GuidyText.small(muteC),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exhibition.price == 0
                                  ? '무료'
                                  : '₩${_formatPrice(exhibition.price)}',
                              style: GuidyText.small(
                                exhibition.price == 0 ? GuidyColors.ok : textC,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

// ─── GuidyInputLabel ─────────────────────────────────────
class GuidyInputLabel extends StatelessWidget {
  final String label;
  final Color textC;
  const GuidyInputLabel({super.key, required this.label, required this.textC});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700));
  }
}

// ─── GuidyInputField ─────────────────────────────────────
class GuidyInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color surfaceC;
  final Color lineC;
  final Color textC;
  final Color subC;
  final Widget? suffix;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const GuidyInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
    required this.subC,
    this.suffix,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        focusNode: focusNode,
        onChanged: onChanged,
        style: GuidyText.body(textC),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GuidyText.body(subC),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
      ),
    );
  }
}
