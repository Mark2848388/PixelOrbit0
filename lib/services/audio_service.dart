import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Простой сервис фоновой музыки.
/// Положи расслабляющий джазовый трек в:
///   assets/audio/jazz_relax.mp3
/// (royalty-free, например с Pixabay / FreePD / Incompetech)
class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final AudioPlayer _bgm = AudioPlayer();
  bool _isPlaying = false;
  bool enabled = true;

  Future<void> init() async {
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.setVolume(0.35);
  }

  Future<void> playJazz() async {
    if (!enabled || _isPlaying) return;
    try {
      await _bgm.play(AssetSource('audio/jazz_relax.mp3'));
      _isPlaying = true;
    } catch (e) {
      // Файл ещё не добавлен — просто молча игнорируем
      debugPrint('BGM not found: put jazz_relax.mp3 into assets/audio/');
    }
  }

  Future<void> stop() async {
    await _bgm.stop();
    _isPlaying = false;
  }

  Future<void> toggle() async {
    enabled = !enabled;
    if (enabled) {
      await playJazz();
    } else {
      await stop();
    }
  }

  void dispose() {
    _bgm.dispose();
  }
}