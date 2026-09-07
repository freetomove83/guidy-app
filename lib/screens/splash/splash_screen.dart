// lib/screens/splash/splash_screen.dart
// Guidy 스플래시 · Deep Marine 테마 애니메이션

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ad_overlay.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── 컨트롤러 ──────────────────────────────────────────────
  late final AnimationController _logoCtrl;    // 로고 등장
  late final AnimationController _waveCtrl;    // 오디오 파형 루프
  late final AnimationController _tagCtrl;     // 태그라인 등장
  late final AnimationController _barCtrl;     // 진행 바
  late final AnimationController _exitCtrl;    // 퇴장 페이드

  // ── 로고 ──────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;

  // ── 아이콘 ────────────────────────────────────────────────
  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;

  // ── 태그라인 ──────────────────────────────────────────────
  late final Animation<double> _tagFade;
  late final Animation<Offset> _tagSlide;

  // ── 프로그레스 바 ─────────────────────────────────────────
  late final Animation<double> _barProgress;

  // ── 퇴장 ──────────────────────────────────────────────────
  late final Animation<double> _exitFade;

  // ── 광고 오버레이 ─────────────────────────────────────────
  bool _showSplashAd = false;

  @override
  void initState() {
    super.initState();

    // ─ 로고 (0 → 900ms) ──────────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic),
    );

    // 아이콘은 로고보다 약간 앞서 등장
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // ─ 오디오 파형 루프 ──────────────────────────────────
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // ─ 태그라인 (500ms delay 후 등장) ────────────────────
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut),
    );
    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOutCubic),
    );

    // ─ 진행 바 (400ms delay 후 2200ms 동안) ──────────────
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _barProgress = CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut);

    // ─ 퇴장 페이드 ───────────────────────────────────────
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic),
    );

    // ─ 시퀀스 실행 ───────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1) 로고 등장
    await _logoCtrl.forward();

    // 2) 태그라인 등장 (약간 겹치게)
    await Future.delayed(const Duration(milliseconds: 100));
    _tagCtrl.forward();

    // 3) 진행 바 시작
    await Future.delayed(const Duration(milliseconds: 200));
    await _barCtrl.forward();

    // 4) 완료 후 잠깐 유지
    await Future.delayed(const Duration(milliseconds: 300));

    // 5) 스플래시 광고 분기
    if (!mounted) return;
    final ad = AdDataStore.splashAd;
    if (ad != null) {
      setState(() => _showSplashAd = true);
      return; // 광고 닫힐 때 _onAdClosed() 에서 이동
    }

    // 6) 광고 없을 때 → 바로 퇴장
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _onAdClosed() async {
    if (!mounted) return;
    setState(() => _showSplashAd = false);
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _waveCtrl.dispose();
    _tagCtrl.dispose();
    _barCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        AnimatedBuilder(
      animation: _exitCtrl,
      builder: (context, child) {
        return Opacity(
          opacity: _exitFade.value,
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF071525),
        body: Stack(
          children: [
            // ── 배경 그라디언트 ────────────────────────────
            Positioned.fill(
              child: CustomPaint(
                painter: _SplashBgPainter(),
              ),
            ),

            // ── 배경 장식 원 (흐릿한 글로우) ──────────────
            Positioned(
              top: size.height * 0.12,
              left: size.width * 0.5 - 180,
              child: AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, __) => Opacity(
                  opacity: (_logoFade.value * 0.35).clamp(0.0, 1.0),
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF0B3D5C).withValues(alpha: 0.6),
                          const Color(0xFF0B3D5C).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 중앙 콘텐츠 ───────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘 (헤드폰)
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _iconFade,
                      child: ScaleTransition(
                        scale: _iconScale,
                        child: _HeadphoneIcon(size: 80),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // GUIDY 워드마크
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _GuidyWordmark(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 오디오 파형 + 태그라인
                  AnimatedBuilder(
                    animation: _tagCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _tagFade,
                      child: SlideTransition(
                        position: _tagSlide,
                        child: Column(
                          children: [
                            // 오디오 파형 바
                            AnimatedBuilder(
                              animation: _waveCtrl,
                              builder: (_, __) => _AudioWave(
                                progress: _waveCtrl.value,
                              ),
                            ),
                            const SizedBox(height: 18),
                            // 태그라인
                            Text(
                              '당신의 오디오 가이드',
                              style: TextStyle(
                                fontFamily: GuidyText.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.55),
                                letterSpacing: 0.5,
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

            // ── 하단 진행 바 ──────────────────────────────
            Positioned(
              bottom: 60,
              left: 48,
              right: 48,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _barCtrl,
                    builder: (_, __) => _ProgressBar(
                      progress: _barProgress.value,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _tagCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _tagFade,
                      child: Text(
                        'GUIDY',
                        style: TextStyle(
                          fontFamily: GuidyText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.25),
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
        // ── 스플래시 광고 오버레이 ────────────────────────────
        if (_showSplashAd && AdDataStore.splashAd != null)
          SplashAdOverlay(
            ad: AdDataStore.splashAd!,
            onClose: _onAdClosed,
            onNavigate: (route) {
              // 광고 랜딩 후 홈으로 이동 (내부 라우트는 홈 진입 후 처리)
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
      ],
    );
  }
}

// ─── 배경 페인터 ──────────────────────────────────────────────
class _SplashBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 메인 그라디언트
    final mainGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF0D2A40),
        Color(0xFF071525),
        Color(0xFF050F1A),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = mainGrad.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      ),
    );

    // 좌상단 액센트 글로우
    final topGlow = RadialGradient(
      colors: [
        const Color(0xFF0B3D5C).withValues(alpha: 0.5),
        const Color(0xFF0B3D5C).withValues(alpha: 0.0),
      ],
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.15),
        width: 320,
        height: 260,
      ),
      Paint()..shader = topGlow.createShader(
        Rect.fromCenter(
          center: Offset(size.width * 0.2, size.height * 0.15),
          width: 320,
          height: 260,
        ),
      ),
    );

    // 우하단 테라코타 글로우
    final bottomGlow = RadialGradient(
      colors: [
        const Color(0xFFD97757).withValues(alpha: 0.12),
        const Color(0xFFD97757).withValues(alpha: 0.0),
      ],
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.85, size.height * 0.88),
        width: 280,
        height: 240,
      ),
      Paint()..shader = bottomGlow.createShader(
        Rect.fromCenter(
          center: Offset(size.width * 0.85, size.height * 0.88),
          width: 280,
          height: 240,
        ),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── 헤드폰 아이콘 ────────────────────────────────────────────
class _HeadphoneIcon extends StatelessWidget {
  final double size;
  const _HeadphoneIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3D5C).withValues(alpha: 0.8),
            blurRadius: 32,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFF4A8BB0).withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _HeadphonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;

    // 헤드밴드 (위 아치)
    final path = Path();
    path.moveTo(w * 0.08, h * 0.55);
    path.cubicTo(
      w * 0.08, h * 0.08,
      w * 0.92, h * 0.08,
      w * 0.92, h * 0.55,
    );
    canvas.drawPath(path, paint);

    // 왼쪽 이어패드
    final leftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.5, w * 0.22, h * 0.4),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(
      leftRect,
      Paint()
        ..color = const Color(0xFF4A8BB0)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      leftRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07,
    );

    // 오른쪽 이어패드
    final rightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.78, h * 0.5, w * 0.22, h * 0.4),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(
      rightRect,
      Paint()
        ..color = const Color(0xFF4A8BB0)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rightRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── GUIDY 워드마크 ───────────────────────────────────────────
class _GuidyWordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // G + guidy 조합 워드마크
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // G 강조
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4A8BB0), Color(0xFF7EC8E3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'G',
                style: TextStyle(
                  fontFamily: GuidyText.fontFamily,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),
            const Text(
              'uidy',
              style: TextStyle(
                fontFamily: GuidyText.fontFamily,
                fontSize: 44,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 1.0,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── 오디오 파형 ──────────────────────────────────────────────
class _AudioWave extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0 루프 값
  const _AudioWave({required this.progress});

  @override
  Widget build(BuildContext context) {
    // 7개 바 · 각기 다른 위상 오프셋
    const barCount = 7;
    const barWidth = 3.5;
    const barSpacing = 5.0;
    const maxHeight = 24.0;
    const minHeight = 4.0;

    // 위상 오프셋 (자연스러운 파형)
    const phaseOffsets = [0.0, 0.18, 0.36, 0.54, 0.36, 0.18, 0.0];
    const amplitudes  = [0.5, 0.75, 1.0, 0.85, 1.0, 0.75, 0.5];

    return SizedBox(
      width: barCount * (barWidth + barSpacing) - barSpacing,
      height: maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (i) {
          final phase = (progress + phaseOffsets[i]) % 1.0;
          final sinVal = (math.sin(phase * 2 * math.pi) + 1) / 2; // 0~1
          final barH = minHeight + (maxHeight - minHeight) * sinVal * amplitudes[i];

          return Container(
            width: barWidth,
            height: barH,
            margin: EdgeInsets.only(right: i < barCount - 1 ? barSpacing : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF0B3D5C),
                  const Color(0xFF4A8BB0),
                  const Color(0xFF7EC8E3).withValues(alpha: 0.8),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── 진행 바 ──────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 트랙
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              // 배경
              Container(
                height: 2,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              // 진행
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0B3D5C),
                        Color(0xFF4A8BB0),
                        Color(0xFF7EC8E3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
