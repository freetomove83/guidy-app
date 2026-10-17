// lib/screens/scan/scan_screen.dart
// QR 스캔 화면 (웹 미리보기용 시뮬레이션)

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  bool _scanned = false;
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scanLineAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    super.dispose();
  }

  void _simulateScan() {
    setState(() => _scanned = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pushNamed(context, '/detail/e1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 배경 시뮬
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.grey.shade900,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // 어둡게 마스크 (스캔 영역 제외)
          Positioned.fill(
            child: CustomPaint(
              painter: _ScanMaskPainter(scanned: _scanned),
            ),
          ),

          // 스캔 프레임
          Center(
            child: SizedBox(
              width: 240, height: 240,
              child: Stack(
                children: [
                  // 코너
                  ..._buildCorners(),
                  // 스캔 라인
                  if (!_scanned)
                    AnimatedBuilder(
                      animation: _scanLineAnim,
                      builder: (context, _) {
                        return Positioned(
                          left: 12, right: 12,
                          top: 12 + (216 * _scanLineAnim.value),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, GuidyColors.accent, Colors.transparent],
                              ),
                              borderRadius: GuidyRadius.pillBorder,
                            ),
                          ),
                        );
                      },
                    ),
                  // 감지 완료 표시
                  if (_scanned)
                    Center(
                      child: Container(
                        width: 60, height: 60,
                        decoration: const BoxDecoration(
                          color: GuidyColors.ok,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 상단
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      ),
                      const Text('QR 스캔', style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                        fontFamily: GuidyText.fontFamily,
                      )),
                      const Icon(Icons.flash_off_rounded, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 안내 텍스트
          Align(
            alignment: const Alignment(0, 0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 260),
                Text(
                  _scanned ? 'QR 코드 인식됨!' : '작품 옆 QR을 사각형 안에 담아주세요',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14, fontFamily: GuidyText.fontFamily,
                  ),
                ),
              ],
            ),
          ),

          // 하단 개발 모드 카드
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: GestureDetector(
              onTap: _simulateScan,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: GuidyRadius.lgBorder,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: GuidyColors.accent.withOpacity(0.2),
                        borderRadius: GuidyRadius.mdBorder,
                      ),
                      child: const Icon(Icons.qr_code_rounded, color: GuidyColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('가상 QR 테스트 (개발 모드)', style: TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700,
                            fontFamily: GuidyText.fontFamily,
                          )),
                          Text('탭하여 QR 스캔 시뮬레이션', style: TextStyle(
                            color: Colors.white54, fontSize: 12, fontFamily: GuidyText.fontFamily,
                          )),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    final color = _scanned ? GuidyColors.ok : Colors.white;
    const w = 3.0;
    const len = 24.0;
    const r = 16.0;

    return [
      // 좌상
      Positioned(top: 0, left: 0, child: _corner(color, w, len, r, true, true)),
      // 우상
      Positioned(top: 0, right: 0, child: _corner(color, w, len, r, false, true)),
      // 좌하
      Positioned(bottom: 0, left: 0, child: _corner(color, w, len, r, true, false)),
      // 우하
      Positioned(bottom: 0, right: 0, child: _corner(color, w, len, r, false, false)),
    ];
  }

  Widget _corner(Color color, double w, double len, double r, bool isLeft, bool isTop) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: CustomPaint(
        size: Size(len + r, len + r),
        painter: _CornerPainter(color: color, strokeWidth: w, cornerLen: len, radius: r,
          isLeft: isLeft, isTop: isTop),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLen;
  final double radius;
  final bool isLeft;
  final bool isTop;

  const _CornerPainter({
    required this.color, required this.strokeWidth, required this.cornerLen,
    required this.radius, required this.isLeft, required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? 1.0 : -1.0;
    final dy = isTop ? 1.0 : -1.0;

    path.moveTo(x, y + dy * cornerLen);
    path.lineTo(x, y + dy * radius);
    path.arcToPoint(Offset(x + dx * radius, y), radius: Radius.circular(radius));
    path.lineTo(x + dx * cornerLen, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ScanMaskPainter extends CustomPainter {
  final bool scanned;
  const _ScanMaskPainter({required this.scanned});

  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 240.0;
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()..color = Colors.black.withOpacity(scanned ? 0.2 : 0.6);

    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: frameSize, height: frameSize),
      const Radius.circular(16),
    ));
    final mask = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(mask, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─── 비콘 감지 오버레이 ───────────────────────────────────
class BeaconToast extends StatefulWidget {
  final String artworkTitle;
  final String artistName;
  final VoidCallback onDismiss;
  final VoidCallback onAutoPlay;

  const BeaconToast({
    super.key,
    required this.artworkTitle,
    required this.artistName,
    required this.onDismiss,
    required this.onAutoPlay,
  });

  @override
  State<BeaconToast> createState() => _BeaconToastState();
}

class _BeaconToastState extends State<BeaconToast> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdown = i - 1);
    }
    widget.onAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: GuidyShadow.pop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (i) => Container(
                width: 60.0 + i * 30,
                height: 60.0 + i * 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryC.withOpacity(0.04 * (3 - i).toDouble()),
                ),
              )),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: primaryC,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bluetooth_searching_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('근처에서 감지됨', style: GuidyText.small(subC)),
          const SizedBox(height: 4),
          Text(widget.artworkTitle, style: GuidyText.h3(textC)),
          Text(widget.artistName, style: GuidyText.body(subC)),
          const SizedBox(height: 20),

          // 3초 프로그레스
          ClipRRect(
            borderRadius: GuidyRadius.pillBorder,
            child: LinearProgressIndicator(
              value: _countdown / 3,
              backgroundColor: GuidyColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(primaryC),
              minHeight: 3,
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? GuidyColors.darkBgAlt : GuidyColors.bgAlt,
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Text('나중에', textAlign: TextAlign.center,
                      style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onAutoPlay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryC,
                      borderRadius: GuidyRadius.pillBorder,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text('자동 재생 · ${_countdown}s', style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700,
                          fontFamily: GuidyText.fontFamily,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
