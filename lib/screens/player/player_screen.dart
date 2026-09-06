// lib/screens/player/player_screen.dart
// 작품 상세 + 오디오 플레이어 (자막 토글 포함)

import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class PlayerScreen extends StatefulWidget {
  final String artworkId;
  const PlayerScreen({super.key, required this.artworkId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  bool _captionsOn = false;
  double _currentTime = 0;
  double _duration = 180;
  int _activeTab = 0; // 0: 해설, 1: 스크립트, 2: 큐레이터, 3: 작가
  double _playbackRate = 1.0;
  Timer? _timer;

  final _tabs = ['해설', '스크립트', '큐레이터', '작가'];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          _currentTime += 0.5 * _playbackRate;
          if (_currentTime >= _duration) {
            _currentTime = _duration;
            _isPlaying = false;
            t.cancel();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _seek(double pos) {
    setState(() => _currentTime = pos.clamp(0, _duration));
  }

  Caption? get _activeCaption {
    final artwork = DummyData.artworks.first;
    for (final c in artwork.captions) {
      if (_currentTime >= c.startSec && _currentTime < c.endSec) return c;
    }
    return null;
  }

  Caption? get _nextCaption {
    final artwork = DummyData.artworks.first;
    final active = _activeCaption;
    if (active == null) return null;
    final idx = artwork.captions.indexOf(active);
    if (idx + 1 < artwork.captions.length) return artwork.captions[idx + 1];
    return null;
  }

  String _formatTime(double sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toInt().toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final artwork = DummyData.artworks.firstWhere(
      (a) => a.id == widget.artworkId,
      orElse: () => DummyData.artworks.first,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    if (_captionsOn && _activeTab != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _activeTab = 1);
      });
    }

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textC),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(color: primaryC, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text('1 / ${DummyData.artworks.length}',
                            style: GuidyText.small(muteC).copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(color: lineC, shape: BoxShape.circle),
                          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _captionsOn ? textC : surfaceC,
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(color: _captionsOn ? textC : lineC),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.closed_caption_outlined, size: 14,
                            color: _captionsOn ? bgC : muteC),
                          const SizedBox(width: 4),
                          Text('자막',
                            style: GuidyText.small(_captionsOn ? bgC : muteC)
                              .copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 커버 + 자막 오버레이 ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _captionsOn ? 24 : 32),
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
                  if (_captionsOn)
                    Positioned(
                      bottom: 12, left: 12, right: 12,
                      child: AnimatedOpacity(
                        opacity: _captionsOn ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: GuidyRadius.lgBorder,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_activeCaption != null)
                                Text(_activeCaption!.text, style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
                                  height: 1.4, fontFamily: GuidyText.fontFamily,
                                ))
                              else
                                Text('재생 중...', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                              if (_nextCaption != null) ...[
                                const SizedBox(height: 6),
                                Text(_nextCaption!.text, style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13,
                                  fontFamily: GuidyText.fontFamily,
                                )),
                              ],
                              const SizedBox(height: 8),
                              // 파형
                              Row(
                                children: List.generate(20, (i) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200 + i * 30),
                                      height: _isPlaying ? (4 + (i % 5) * 4.0) : 4,
                                      decoration: BoxDecoration(
                                        color: accentC,
                                        borderRadius: GuidyRadius.smBorder,
                                      ),
                                    ),
                                  ),
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 정보 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ChannelBadge(type: ChannelType.curation),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: surfaceC,
                                borderRadius: GuidyRadius.pillBorder,
                                border: Border.all(color: lineC),
                              ),
                              child: Text('국립현대미술관', style: GuidyText.kicker(muteC)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(artwork.title, style: GuidyText.h2(textC)),
                        const SizedBox(height: 2),
                        Text('${artwork.artist} · ${artwork.material}', style: GuidyText.body(subC)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 진행 바 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbColor: textC,
                      activeTrackColor: textC,
                      inactiveTrackColor: lineC,
                    ),
                    child: Slider(
                      value: _currentTime,
                      min: 0, max: _duration,
                      onChanged: _seek,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(_currentTime), style: GuidyText.small(muteC)),
                        Text(_formatTime(_duration), style: GuidyText.small(muteC)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 컨트롤 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      final rates = [1.0, 1.2, 1.5, 2.0, 0.8];
                      final idx = rates.indexOf(_playbackRate);
                      setState(() => _playbackRate = rates[(idx + 1) % rates.length]);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.pillBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Text('${_playbackRate}x', style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _seek(_currentTime - 15),
                    child: Icon(Icons.replay_10_rounded, size: 32, color: subC),
                  ),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: textC,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: bgC, size: 32,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _seek(_currentTime + 15),
                    child: Icon(Icons.forward_10_rounded, size: 32, color: subC),
                  ),
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

            // ── 탭 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(_tabs.length, (i) {
                        final isActive = i == _activeTab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isActive ? primaryC : lineC,
                                    width: isActive ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Text(_tabs[i], textAlign: TextAlign.center,
                                style: GuidyText.small(isActive ? primaryC : muteC)
                                  .copyWith(fontWeight: isActive ? FontWeight.w800 : FontWeight.w500)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── 탭 콘텐츠 ──
            Expanded(
              child: IndexedStack(
                index: _activeTab,
                children: [
                  // 해설
                  _buildDescription(artwork, textC, subC),
                  // 스크립트
                  _buildScript(artwork, textC, subC, muteC, primaryC, accentC, lineC),
                  // 큐레이터
                  _buildCurator(artwork, textC, subC, surfaceC, lineC, primaryC),
                  // 작가
                  _buildArtist(artwork, textC, subC),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(Artwork artwork, Color textC, Color subC) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Text(artwork.description, style: GuidyText.body(subC)),
    );
  }

  Widget _buildScript(Artwork artwork, Color textC, Color subC, Color muteC, Color primaryC, Color accentC, Color lineC) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: artwork.captions.length,
      itemBuilder: (context, i) {
        final cap = artwork.captions[i];
        final isActive = _currentTime >= cap.startSec && _currentTime < cap.endSec;
        return GestureDetector(
          onTap: () => _seek(cap.startSec),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: isActive ? primaryC.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: GuidyRadius.mdBorder,
              border: Border(left: BorderSide(
                color: isActive ? accentC : Colors.transparent,
                width: 3,
              )),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 38,
                  child: Text(
                    '${cap.startSec.toInt().toString().padLeft(2, '0')}s',
                    style: GuidyText.kicker(muteC),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(cap.text, style: TextStyle(
                    fontFamily: GuidyText.fontFamily,
                    fontSize: isActive ? 15 : 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? textC : subC,
                    height: 1.5,
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurator(Artwork artwork, Color textC, Color subC, Color surfaceC, Color lineC, Color primaryC) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceC,
          borderRadius: GuidyRadius.lgBorder,
          border: Border.all(color: lineC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3, height: 20,
                  decoration: BoxDecoration(
                    color: primaryC,
                    borderRadius: GuidyRadius.pillBorder,
                  ),
                ),
                const SizedBox(width: 8),
                Text('큐레이터 노트', style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            Text(artwork.curatorNote, style: GuidyText.body(subC)),
          ],
        ),
      ),
    );
  }

  Widget _buildArtist(Artwork artwork, Color textC, Color subC) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('작가 노트', style: GuidyText.h3(textC)),
          const SizedBox(height: 8),
          Text('${artwork.artist} 작가의 말: "이 작품은 빛의 순간적인 본질을 포착하려는 시도입니다. 관객이 작품 앞에서 시간을 잊기를 바랍니다."',
            style: GuidyText.body(subC)),
        ],
      ),
    );
  }
}

