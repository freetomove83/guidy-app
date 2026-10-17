// lib/services/audio_service.dart
// Guidy 오디오 서비스 — audioplayers 6.x 래퍼
// Web + Android 공통 지원

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 오디오 재생 상태
enum GuidyAudioState { idle, loading, playing, paused, completed, error }

/// Guidy 오디오 서비스 싱글톤
class GuidyAudioService extends ChangeNotifier {
  static final GuidyAudioService _instance = GuidyAudioService._internal();
  factory GuidyAudioService() => _instance;
  GuidyAudioService._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  // ── 상태 ────────────────────────────────────────────────
  GuidyAudioState _state = GuidyAudioState.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  String? _currentAudioId;   // 현재 재생 중인 작품 ID
  String? _currentUrl;       // 현재 오디오 경로
  String? _errorMessage;

  // ── 외부 접근 게터 ──────────────────────────────────────
  GuidyAudioState get state      => _state;
  Duration        get position   => _position;
  Duration        get duration   => _duration;
  double          get speed      => _speed;
  String?         get currentId  => _currentAudioId;
  bool            get isPlaying  => _state == GuidyAudioState.playing;
  bool            get isLoading  => _state == GuidyAudioState.loading;
  String?         get error      => _errorMessage;

  /// 재생 진행률 0.0 ~ 1.0
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// 현재 위치 (초)
  double get positionSec => _position.inMilliseconds / 1000.0;

  /// 전체 길이 (초)
  double get durationSec => _duration.inMilliseconds / 1000.0;

  // ── 초기화 ──────────────────────────────────────────────
  void _init() {
    // 재생 위치 스트림
    _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // 전체 길이 스트림
    _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    // 재생 완료
    _player.onPlayerComplete.listen((_) {
      _state = GuidyAudioState.completed;
      _position = _duration;
      notifyListeners();
    });

    // 상태 변경
    _player.onPlayerStateChanged.listen((ps) {
      switch (ps) {
        case PlayerState.playing:
          _state = GuidyAudioState.playing;
        case PlayerState.paused:
          _state = GuidyAudioState.paused;
        case PlayerState.stopped:
          _state = GuidyAudioState.idle;
        case PlayerState.completed:
          _state = GuidyAudioState.completed;
        case PlayerState.disposed:
          _state = GuidyAudioState.idle;
      }
      notifyListeners();
    });
  }

  // ── 공개 메서드 ──────────────────────────────────────────

  /// 오디오 로드 & 재생
  /// [audioPath] : 'assets/audio/xxx.mp3' 또는 'https://...'
  /// [artworkId] : 작품 식별자 (중복 재생 방지)
  Future<void> play(String audioPath, {String? artworkId}) async {
    try {
      // 같은 오디오가 이미 이어지고 있으면 처음부터 다시 재생하지 않는다
      // (미니플레이어 → 플레이어 재진입 시 재생 위치 유지)
      if (_currentUrl == audioPath && _currentAudioId == artworkId) {
        if (_state == GuidyAudioState.playing ||
            _state == GuidyAudioState.loading) {
          return;
        }
        if (_state == GuidyAudioState.paused) {
          await _player.resume();
          return;
        }
        // completed / error / idle → 아래에서 처음부터 재생
      }

      _state = GuidyAudioState.loading;
      _errorMessage = null;
      _currentAudioId = artworkId;
      _currentUrl = audioPath;
      notifyListeners();

      Source source;
      if (audioPath.startsWith('assets/')) {
        source = AssetSource(audioPath.replaceFirst('assets/', ''));
      } else if (audioPath.startsWith('http')) {
        source = UrlSource(audioPath);
      } else {
        source = AssetSource(audioPath);
      }

      await _player.setPlaybackRate(_speed);
      await _player.play(source);
    } catch (e) {
      _state = GuidyAudioState.error;
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint('[GuidyAudio] Error: $e');
      notifyListeners();
    }
  }

  /// 일시정지
  Future<void> pause() async {
    await _player.pause();
  }

  /// 재개
  Future<void> resume() async {
    await _player.resume();
  }

  /// 재생/일시정지 토글
  Future<void> togglePlay(String audioPath, {String? artworkId}) async {
    if (isPlaying && _currentUrl == audioPath) {
      await pause();
    } else if (_state == GuidyAudioState.paused && _currentUrl == audioPath) {
      await resume();
    } else {
      // 새로운 오디오 재생
      await play(audioPath, artworkId: artworkId);
    }
  }

  /// 탐색 (초 단위)
  Future<void> seekTo(double seconds) async {
    final ms = (seconds * 1000).toInt().clamp(0, _duration.inMilliseconds);
    await _player.seek(Duration(milliseconds: ms));
  }

  /// 앞으로 건너뛰기
  Future<void> skipForward([double seconds = 15]) async {
    await seekTo(positionSec + seconds);
  }

  /// 뒤로 건너뛰기
  Future<void> skipBackward([double seconds = 15]) async {
    await seekTo(positionSec - seconds);
  }

  /// 재생 속도 변경
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _player.setPlaybackRate(speed);
    notifyListeners();
  }

  /// 정지 (위치 초기화)
  Future<void> stop() async {
    await _player.stop();
    _position = Duration.zero;
    _currentAudioId = null;
    _currentUrl = null;
    _state = GuidyAudioState.idle;
    notifyListeners();
  }

  /// 시간 포맷: 초 → mm:ss
  static String formatTime(double seconds) {
    final total = seconds.toInt().clamp(0, 99 * 60 + 59);
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    super.dispose();
  }
}
