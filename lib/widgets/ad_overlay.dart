// lib/widgets/ad_overlay.dart
// Guidy 앱 — 광고 오버레이 위젯 3종
//   1. SplashAdOverlay   — 스플래시 광고 (앱 실행 시)
//   2. HomePopupAd       — 홈 팝업 레이어 광고 (홈 진입 시)
//   3. HomeSlideUpAd     — 홈 하단 슬라이드업 광고

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

// ─── 더미 광고 데이터 모델 ─────────────────────────────────
enum AdMediaType { image, video }
enum AdLandingType { url, internal }

class AdData {
  final String id;
  final String title;
  final AdMediaType mediaType;
  final String? imageUrl;       // 실제 이미지 URL
  final AdLandingType landingType;
  final String? landingUrl;     // 외부 URL or 내부 라우트
  final DateTime endAt;
  final bool active;

  const AdData({
    required this.id,
    required this.title,
    required this.mediaType,
    this.imageUrl,
    required this.landingType,
    this.landingUrl,
    required this.endAt,
    required this.active,
  });
}

// ─── 광고 데이터 — CMS(Firestore banners)에서 불러오고, 못 불러오면 기본 광고 ──
// 기본 광고의 landingUrl은 DummyData에 실제로 있는 전시·크리에이터 ID여야 함 (store_test에서 검사)
class AdDataStore {
  static AdData? _splashAd = AdData(
    id: 'ad_splash_001',
    title: '여름 특별전 시작!',
    mediaType: AdMediaType.image,
    imageUrl: null, // Firebase Storage URL 연결 예정
    landingType: AdLandingType.internal,
    landingUrl: '/detail/e1',
    endAt: DateTime(2026, 12, 31),
    active: true,
  );

  static AdData? _popupAd = AdData(
    id: 'ad_popup_001',
    title: '「침묵과 소음」 심층 탐방 오디오 가이드',
    mediaType: AdMediaType.image,
    imageUrl: null,
    landingType: AdLandingType.internal,
    landingUrl: '/detail/e4',
    endAt: DateTime(2026, 12, 31),
    active: true,
  );

  static AdData? _slideUpAd = AdData(
    id: 'ad_slideup_001',
    title: '신규 크리에이터 정재원 등장',
    mediaType: AdMediaType.image,
    imageUrl: null,
    landingType: AdLandingType.internal,
    landingUrl: '/creator/c4',
    endAt: DateTime(2026, 12, 31),
    active: true,
  );

  static AdData? _live(AdData? ad) =>
      ad != null && ad.active && DateTime.now().isBefore(ad.endAt) ? ad : null;

  /// CMS 광고 배너 관리에서 등록한 배너로 교체 — 구좌마다 지금 노출 기간인 배너 중 가장 최근 것.
  /// 불러오면 CMS에 없는 구좌는 광고 없음. 오프라인·Firebase 없음 → 기본 광고 유지.
  static Future<void> load({Duration timeout = const Duration(seconds: 6)}) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('banners').get().timeout(timeout);
      final now = DateTime.now();
      final live = <String, (DateTime, AdData)>{};
      for (final doc in snap.docs) {
        final d = doc.data();
        final start = d['start_at'], end = d['end_at'];
        if (d['paused'] == true || start is! Timestamp || end is! Timestamp) continue;
        final endAt = end.toDate().add(const Duration(days: 1)); // 종료일 당일까지
        if (now.isBefore(start.toDate()) || !now.isBefore(endAt)) continue;
        final ad = AdData(
          id: doc.id,
          title: (d['title'] as String?) ?? '',
          mediaType: d['media_type'] == 'video' ? AdMediaType.video : AdMediaType.image,
          imageUrl: d['media_type'] == 'video' ? null : d['media_url'] as String?,
          landingType: d['landing_type'] == 'internal' ? AdLandingType.internal : AdLandingType.url,
          landingUrl: _landingRoute(d),
          endAt: endAt,
          active: true,
        );
        final slot = d['slot'] as String? ?? '';
        if (!live.containsKey(slot) || start.toDate().isAfter(live[slot]!.$1)) {
          live[slot] = (start.toDate(), ad);
        }
      }
      _splashAd  = live['splash']?.$2;
      _popupAd   = live['homePopup']?.$2;
      _slideUpAd = live['homeSlideUp']?.$2;
      debugPrint('[Ads] CMS 배너 ${live.length}개 구좌 사용');
    } catch (e) {
      debugPrint('[Ads] 배너 불러오기 실패 → 기본 광고 사용: $e');
    }
  }

  /// CMS 랜딩 설정 → 앱 라우트('/detail/e1') 또는 외부 URL
  static String? _landingRoute(Map<String, dynamic> d) {
    if (d['landing_type'] != 'internal') return d['landing_url'] as String?;
    final id = d['internal_target_id'] as String?;
    if (id == null || id.isEmpty) return null;
    return switch (d['internal_target']) {
      'exhibition' => '/detail/$id',
      'creator'    => '/creator/$id',
      _            => id, // 앱 화면 라우트 (/home 등)
    };
  }

  /// 광고 탭 — 앱 라우트는 화면 이동, 그 외(https://)는 외부 브라우저
  static Future<void> open(NavigatorState navigator, String landing) async {
    if (landing.startsWith('/')) {
      navigator.pushNamed(landing);
    } else {
      final uri = Uri.tryParse(landing);
      if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  static AdData? get splashAd  => _live(_splashAd);
  static AdData? get popupAd   => _live(_popupAd);
  static AdData? get slideUpAd => _live(_slideUpAd);

  // '오늘 하루 보지 않기' — 숨긴 날짜(yyyy-mm-dd)를 저장
  static const _kPopupHiddenOn = 'guidy_popup_ad_hidden_on';
  static String _today() => DateTime.now().toIso8601String().substring(0, 10);

  static Future<bool> isPopupHiddenToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPopupHiddenOn) == _today();
  }

  static Future<void> hidePopupToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPopupHiddenOn, _today());
  }
}

// ══════════════════════════════════════════════════════════
// 1. 스플래시 광고 오버레이
//    - 앱 실행 시 스플래시 화면 위에 노출
//    - 5초 카운트다운 후 자동 닫힘
//    - "건너뛰기" 버튼 즉시 닫기
//    - 광고 탭 시 랜딩 이동
// ══════════════════════════════════════════════════════════
class SplashAdOverlay extends StatefulWidget {
  final AdData ad;
  final VoidCallback onClose;
  final void Function(String route) onNavigate;

  const SplashAdOverlay({
    super.key,
    required this.ad,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  State<SplashAdOverlay> createState() => _SplashAdOverlayState();
}

class _SplashAdOverlayState extends State<SplashAdOverlay>
    with SingleTickerProviderStateMixin {
  static const _countdownSec = 5;
  int _remaining = _countdownSec;
  Timer? _timer;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeIn,
      child: Material(
        color: Colors.black.withValues(alpha: 0.92),
        child: Stack(
          children: [
            // ── 광고 이미지/영상 영역 ────────────────────
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  widget.onClose();
                  if (widget.ad.landingUrl != null) {
                    widget.onNavigate(widget.ad.landingUrl!);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 광고 이미지 (더미 플레이스홀더)
                    Container(
                      width: size.width * 0.85,
                      height: size.height * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0B3D5C), Color(0xFF1A6B8A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: widget.ad.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(widget.ad.imageUrl!, fit: BoxFit.cover),
                            )
                          : _AdDummyContent(ad: widget.ad),
                    ),
                    const SizedBox(height: 20),
                    // CTA 라벨
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: GuidyColors.accent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '자세히 보기',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: GuidyText.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 우상단: 건너뛰기 카운트다운 ─────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  widget.onClose();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _remaining > 0 ? '건너뛰기 $_remaining' : '닫기',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

            // ── 좌하단: 광고 라벨 ────────────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('광고', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 2. 홈 팝업 광고
//    - 홈 화면 진입 시 중앙 팝업
//    - X 버튼 또는 배경 탭으로 닫기
//    - "오늘 하루 보지 않기" 체크 옵션
//    - 1:1 이미지/영상 광고
// ══════════════════════════════════════════════════════════
class HomePopupAd extends StatefulWidget {
  final AdData ad;
  final VoidCallback onClose;
  final void Function(String route) onNavigate;

  const HomePopupAd({
    super.key,
    required this.ad,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  State<HomePopupAd> createState() => _HomePopupAdState();
}

class _HomePopupAdState extends State<HomePopupAd>
    with SingleTickerProviderStateMixin {
  bool _dontShowToday = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_dontShowToday) await AdDataStore.hidePopupToday();
    await _ctrl.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        child: GestureDetector(
          onTap: _close,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 팝업 내부 탭 차단
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── 광고 이미지 영역 ────────────────
                      GestureDetector(
                        onTap: () {
                          _close();
                          if (widget.ad.landingUrl != null) {
                            widget.onNavigate(widget.ad.landingUrl!);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: widget.ad.imageUrl != null
                                ? Image.network(widget.ad.imageUrl!, fit: BoxFit.cover)
                                : _AdDummyContent(ad: widget.ad, rounded: false),
                          ),
                        ),
                      ),

                      // ── 하단 컨트롤 ────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // "오늘 하루 보지 않기"
                            GestureDetector(
                              onTap: () => setState(() => _dontShowToday = !_dontShowToday),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      color: _dontShowToday ? GuidyColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _dontShowToday ? GuidyColors.primary : GuidyColors.mute,
                                      ),
                                    ),
                                    child: _dontShowToday
                                        ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '오늘 하루 보지 않기',
                                    style: TextStyle(
                                      fontFamily: GuidyText.fontFamily,
                                      fontSize: 12,
                                      color: GuidyColors.mute,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // 닫기
                            GestureDetector(
                              onTap: _close,
                              child: Text(
                                '닫기',
                                style: TextStyle(
                                  fontFamily: GuidyText.fontFamily,
                                  fontSize: 13,
                                  color: GuidyColors.sub,
                                  fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 3. 홈 하단 슬라이드업 광고
//    - 홈 화면 하단에서 슬라이드 업
//    - 스와이프 다운 또는 X 버튼으로 닫기
//    - 16:5 와이드 배너 비율
// ══════════════════════════════════════════════════════════
class HomeSlideUpAd extends StatefulWidget {
  final AdData ad;
  final VoidCallback onClose;
  final void Function(String route) onNavigate;

  const HomeSlideUpAd({
    super.key,
    required this.ad,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  State<HomeSlideUpAd> createState() => _HomeSlideUpAdState();
}

class _HomeSlideUpAdState extends State<HomeSlideUpAd>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _ctrl.reverse();
    widget.onClose();
  }

  // 스와이프 다운 처리
  void _onDragStart(DragStartDetails d) {/* drag tracking */}
  void _onDragEnd(DragEndDetails d) {
    if (d.primaryVelocity != null && d.primaryVelocity! > 300) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad   = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onVerticalDragStart: _onDragStart,
            onVerticalDragEnd: _onDragEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 드래그 핸들
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: GuidyColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 광고 배너
                  GestureDetector(
                    onTap: () {
                      _close();
                      if (widget.ad.landingUrl != null) {
                        widget.onNavigate(widget.ad.landingUrl!);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 5,
                          child: widget.ad.imageUrl != null
                              ? Image.network(widget.ad.imageUrl!, fit: BoxFit.cover)
                              : _AdDummyContent(ad: widget.ad, rounded: false, compact: true),
                        ),
                      ),
                    ),
                  ),

                  // 하단 바
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomPad),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GuidyColors.chip,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('광고', style: TextStyle(color: GuidyColors.mute, fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.ad.title,
                            style: TextStyle(
                              fontFamily: GuidyText.fontFamily,
                              fontSize: 13,
                              color: GuidyColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _close,
                          child: const Icon(Icons.close_rounded, size: 20, color: GuidyColors.mute),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 광고 더미 콘텐츠 플레이스홀더 ───────────────────────────
class _AdDummyContent extends StatelessWidget {
  final AdData ad;
  final bool rounded;
  final bool compact;
  const _AdDummyContent({required this.ad, this.rounded = true, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: rounded ? BorderRadius.circular(16) : null,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3D5C), Color(0xFFD97757)],
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -10, bottom: -10,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // 콘텐츠
          Center(
            child: compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.headphones_rounded, size: 20, color: Colors.white),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          ad.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'NotoSansKR',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.headphones_rounded, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          ad.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'NotoSansKR',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '탭하여 자세히 보기',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
