// lib/screens/player/player_screen.dart
// Guidy 오디오 플레이어 — audioplayers 실제 재생 연결

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/app_store.dart';
import '../../services/audio_service.dart';
import '../../widgets/common_widgets.dart';

class PlayerScreen extends StatefulWidget {
  final String artworkId;
  const PlayerScreen({super.key, required this.artworkId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {

  bool _captionsOn = false;
  int  _activeTab  = 0;                          // 0:해설 1:스크립트 2:큐레이터 3:작가
  late int _artworkIndex;                        // 현재 작품 인덱스
  List<Artwork> _playlist = [];                  // 같은 전시의 작품 리스트

  // 파형 애니메이션
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();

    // 파형 루프
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // 작품 목록 & 인덱스 구성
    final store = context.read<AppStore>();
    final artwork = store.artworkById(widget.artworkId) ?? store.artworks.first;
    _playlist = store.artworks
        .where((a) => a.exhibitionId == artwork.exhibitionId)
        .toList();
    _artworkIndex = _playlist.indexWhere((a) => a.id == artwork.id);
    if (_artworkIndex < 0) _artworkIndex = 0;

    // 자동 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<GuidyAudioService>();
      final current = _playlist[_artworkIndex];
      if (current.audioUrl != null) {
        audio.play(current.audioUrl!, artworkId: current.id);
      }
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    // 화면 이탈 시 자동 정지는 하지 않음 (미니플레이어 연계 대비)
    super.dispose();
  }

  Artwork get _currentArtwork => _playlist[_artworkIndex];

  // 이전 작품
  void _prevTrack(GuidyAudioService audio) {
    if (_artworkIndex <= 0) return;
    setState(() => _artworkIndex--);
    _playCurrentTrack(audio);
  }

  // 다음 작품
  void _nextTrack(GuidyAudioService audio) {
    if (_artworkIndex >= _playlist.length - 1) return;
    setState(() => _artworkIndex++);
    _playCurrentTrack(audio);
  }

  void _playCurrentTrack(GuidyAudioService audio) {
    final a = _currentArtwork;
    if (a.audioUrl != null) {
      audio.play(a.audioUrl!, artworkId: a.id);
    }
  }

  // 현재 재생 위치에 해당하는 자막
  Caption? _activeCaption(double positionSec) {
    for (final c in _currentArtwork.captions) {
      if (positionSec >= c.startSec && positionSec < c.endSec) return c;
    }
    return null;
  }

  Caption? _nextCaption(double positionSec) {
    final active = _activeCaption(positionSec);
    if (active == null) return null;
    final idx = _currentArtwork.captions.indexOf(active);
    if (idx + 1 < _currentArtwork.captions.length) {
      return _currentArtwork.captions[idx + 1];
    }
    return null;
  }

  final _tabs = ['해설', '스크립트', '큐레이터', '작가'];

  @override
  Widget build(BuildContext context) {
    final audio   = context.watch<GuidyAudioService>();
    final artwork = _currentArtwork;

    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;
    final accentC  = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    final positionSec = audio.positionSec;
    final durationSec = audio.durationSec > 0
        ? audio.durationSec
        : artwork.durationSec.toDouble();

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        child: Column(
          children: [

            // ── 헤더 ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  // 뒤로
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
                  // 트랙 카운터
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 4, height: 4,
                              decoration: BoxDecoration(
                                  color: primaryC, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(
                            '${_artworkIndex + 1} / ${_playlist.length}',
                            style: GuidyText.small(muteC)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          Container(width: 4, height: 4,
                              decoration: BoxDecoration(
                                  color: lineC, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  ),
                  // 자막 토글
                  GestureDetector(
                    onTap: () => setState(() {
                      _captionsOn = !_captionsOn;
                      if (_captionsOn) _activeTab = 1;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _captionsOn ? textC : surfaceC,
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(
                            color: _captionsOn ? textC : lineC),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.closed_caption_outlined,
                              size: 14,
                              color: _captionsOn ? bgC : muteC),
                          const SizedBox(width: 4),
                          Text('자막',
                              style: GuidyText.small(
                                      _captionsOn ? bgC : muteC)
                                  .copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 커버 + 자막 오버레이 ──────────────────────
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: _captionsOn ? 24 : 32),
              child: Stack(
                children: [
                  AnimatedScale(
                    scale: _captionsOn ? 0.88 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: GuidyCover(
                      seed: artwork.imageSeed,
                      aspectRatio: 1,
                      borderRadius: GuidyRadius.xlBorder,
                    ),
                  ),
                  // 로딩 인디케이터
                  if (audio.isLoading)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: GuidyRadius.xlBorder,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 에러 오버레이
                  if (audio.state == GuidyAudioState.error)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: GuidyRadius.xlBorder,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.white, size: 32),
                              const SizedBox(height: 8),
                              Text('오디오를 불러올 수 없습니다',
                                  style: GuidyText.small(Colors.white)),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _playCurrentTrack(audio),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: GuidyRadius.pillBorder,
                                  ),
                                  child: Text('다시 시도',
                                      style:
                                          GuidyText.small(Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 자막 오버레이
                  if (_captionsOn)
                    Positioned(
                      bottom: 12, left: 12, right: 12,
                      child: AnimatedOpacity(
                        opacity: _captionsOn ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.82),
                            borderRadius: GuidyRadius.lgBorder,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_activeCaption(positionSec) != null)
                                Text(
                                  _activeCaption(positionSec)!.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.45,
                                    fontFamily: GuidyText.fontFamily,
                                  ),
                                )
                              else
                                Text('♪  재생 중...',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.5),
                                        fontSize: 13,
                                        fontFamily:
                                            GuidyText.fontFamily)),
                              if (_nextCaption(positionSec) != null) ...[
                                const SizedBox(height: 5),
                                Text(
                                  _nextCaption(positionSec)!.text,
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.45),
                                    fontSize: 12,
                                    fontFamily: GuidyText.fontFamily,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              // 재생 중 파형
                              AnimatedBuilder(
                                animation: _waveCtrl,
                                builder: (_, __) => Row(
                                  children: List.generate(22, (i) {
                                    final t = _waveCtrl.value;
                                    final h = audio.isPlaying
                                        ? 3.0 +
                                            (((t + i * 0.15) % 1.0) *
                                                (3 + (i % 4) * 2.5))
                                        : 3.0;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.8),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 120),
                                          height: h,
                                          decoration: BoxDecoration(
                                            color: accentC,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
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

            const SizedBox(height: 14),

            // ── 작품 정보 ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          ChannelBadge(type: ChannelType.curation),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: surfaceC,
                              borderRadius: GuidyRadius.pillBorder,
                              border: Border.all(color: lineC),
                            ),
                            child: Text('국립현대미술관',
                                style: GuidyText.kicker(muteC)),
                          ),
                        ]),
                        const SizedBox(height: 7),
                        Text(artwork.title,
                            style: GuidyText.h2(textC)),
                        const SizedBox(height: 2),
                        Text(
                          '${artwork.artist} · ${artwork.material}',
                          style: GuidyText.body(subC),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 프로그레스 슬라이더 ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbColor: textC,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      activeTrackColor: textC,
                      inactiveTrackColor: lineC,
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14),
                    ),
                    child: Slider(
                      value: positionSec.clamp(0.0, durationSec),
                      min: 0,
                      max: durationSec,
                      onChanged: (v) => audio.seekTo(v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(GuidyAudioService.formatTime(positionSec),
                            style: GuidyText.small(muteC)),
                        // 남은 시간
                        Text(
                          '-${GuidyAudioService.formatTime(durationSec - positionSec)}',
                          style: GuidyText.small(muteC),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 컨트롤 바 ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 재생 속도
                  GestureDetector(
                    onTap: () {
                      const rates = [1.0, 1.2, 1.5, 2.0, 0.8];
                      final idx = rates.indexOf(audio.speed);
                      audio.setSpeed(rates[(idx + 1) % rates.length]);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Text(
                        '${audio.speed % 1 == 0 ? audio.speed.toInt() : audio.speed}x',
                        style: GuidyText.small(textC)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  // 15초 뒤로
                  GestureDetector(
                    onTap: () => audio.skipBackward(15),
                    child: Icon(Icons.replay_10_rounded,
                        size: 32, color: subC),
                  ),
                  // 재생/정지
                  GestureDetector(
                    onTap: () {
                      if (artwork.audioUrl != null) {
                        audio.togglePlay(artwork.audioUrl!,
                            artworkId: artwork.id);
                      }
                    },
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: textC, shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: textC.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: audio.isLoading
                          ? Center(
                              child: SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  color: bgC, strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : Icon(
                              audio.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: bgC, size: 32,
                            ),
                    ),
                  ),
                  // 15초 앞으로
                  GestureDetector(
                    onTap: () => audio.skipForward(15),
                    child: Icon(Icons.forward_10_rounded,
                        size: 32, color: subC),
                  ),
                  // 자막 토글 (하단)
                  GestureDetector(
                    onTap: () => setState(() {
                      _captionsOn = !_captionsOn;
                      if (_captionsOn) _activeTab = 1;
                    }),
                    child: Icon(
                      Icons.closed_caption_outlined,
                      size: 28,
                      color: _captionsOn ? accentC : subC,
                    ),
                  ),
                ],
              ),
            ),

            // ── 이전/다음 작품 네비게이션 ────────────────
            if (_playlist.length > 1)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _artworkIndex > 0
                          ? () => _prevTrack(audio)
                          : null,
                      child: Row(
                        children: [
                          Icon(Icons.skip_previous_rounded,
                              size: 18,
                              color: _artworkIndex > 0 ? subC : lineC),
                          const SizedBox(width: 4),
                          Text('이전 작품',
                              style: GuidyText.small(
                                  _artworkIndex > 0 ? subC : lineC)),
                        ],
                      ),
                    ),
                    // 현재 트랙 도트
                    Row(
                      children: List.generate(_playlist.length, (i) =>
                        Container(
                          width: i == _artworkIndex ? 16 : 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: i == _artworkIndex
                                ? primaryC
                                : lineC,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _artworkIndex < _playlist.length - 1
                          ? () => _nextTrack(audio)
                          : null,
                      child: Row(
                        children: [
                          Text('다음 작품',
                              style: GuidyText.small(
                                  _artworkIndex < _playlist.length - 1
                                      ? subC
                                      : lineC)),
                          const SizedBox(width: 4),
                          Icon(Icons.skip_next_rounded,
                              size: 18,
                              color: _artworkIndex < _playlist.length - 1
                                  ? subC
                                  : lineC),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ── 탭 헤더 ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final isActive = i == _activeTab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _activeTab = i),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    isActive ? primaryC : lineC,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabs[i],
                            textAlign: TextAlign.center,
                            style: GuidyText.small(
                                    isActive ? primaryC : muteC)
                                .copyWith(
                                    fontWeight: isActive
                                        ? FontWeight.w800
                                        : FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── 탭 콘텐츠 ────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _activeTab,
                children: [
                  _buildDescription(artwork, textC, subC),
                  _buildScript(
                      artwork, audio.positionSec,
                      textC, subC, muteC, primaryC, accentC, lineC, audio),
                  _buildCurator(
                      artwork, textC, subC, surfaceC, lineC, primaryC),
                  _buildArtist(artwork, textC, subC),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 탭 콘텐츠 빌더 ──────────────────────────────────────

  Widget _buildDescription(
      Artwork artwork, Color textC, Color subC) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Text(artwork.description,
          style: GuidyText.body(subC).copyWith(height: 1.7)),
    );
  }

  Widget _buildScript(
    Artwork artwork,
    double positionSec,
    Color textC, Color subC, Color muteC,
    Color primaryC, Color accentC, Color lineC,
    GuidyAudioService audio,
  ) {
    if (artwork.captions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subtitles_off_outlined,
                size: 40, color: muteC),
            const SizedBox(height: 10),
            Text('스크립트가 없습니다',
                style: GuidyText.body(muteC)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: artwork.captions.length,
      itemBuilder: (context, i) {
        final cap = artwork.captions[i];
        final isActive = positionSec >= cap.startSec &&
            positionSec < cap.endSec;
        return GestureDetector(
          onTap: () => audio.seekTo(cap.startSec),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding:
                const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryC.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: GuidyRadius.mdBorder,
              border: Border(
                left: BorderSide(
                  color: isActive ? accentC : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${cap.startSec.toInt().toString().padLeft(2, '0')}s',
                    style: GuidyText.kicker(muteC),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cap.text,
                    style: TextStyle(
                      fontFamily: GuidyText.fontFamily,
                      fontSize: isActive ? 15 : 13,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isActive ? textC : subC,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurator(
    Artwork artwork,
    Color textC, Color subC, Color surfaceC,
    Color lineC, Color primaryC,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(18),
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
                width: 3, height: 20,
                decoration: BoxDecoration(
                  color: primaryC,
                  borderRadius: GuidyRadius.pillBorder,
                ),
              ),
              const SizedBox(width: 8),
              Text('큐레이터 노트',
                  style: GuidyText.body(textC)
                      .copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            Text(artwork.curatorNote,
                style: GuidyText.body(subC).copyWith(height: 1.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildArtist(
      Artwork artwork, Color textC, Color subC) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('작가 노트', style: GuidyText.h3(textC)),
          const SizedBox(height: 10),
          Text(
            '"${artwork.artist} 작가의 말: 이 작품은 빛의 순간적인 본질을 포착하려는 시도입니다. 관객이 작품 앞에서 시간을 잊기를 바랍니다."',
            style: GuidyText.body(subC).copyWith(height: 1.75),
          ),
          const SizedBox(height: 20),
          Text('재료', style: GuidyText.small(textC)
              .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(artwork.material, style: GuidyText.body(subC)),
        ],
      ),
    );
  }
}
