import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 진동, 알림음, 화면 꺼짐 방지. 지원하지 않는 기기에서는 조용히 무시한다.
class AlertService {
  AudioPlayer? _player;
  AudioPlayer get _audio => _player ??= AudioPlayer();

  /// [strong]이면 시간 종료용 (더 길게, 더 여러 번)
  Future<void> alert({required bool strong, required bool sound}) async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: strong ? [0, 300, 150, 300, 150, 300] : [0, 250, 120, 250]);
      }
    } catch (e) {
      debugPrint('진동 실패: $e');
    }
    if (!sound) return;
    final beeps = strong ? 3 : 2;
    for (var i = 0; i < beeps; i++) {
      try {
        await _audio.stop();
        await _audio.play(AssetSource('sounds/beep.wav'));
      } catch (e) {
        debugPrint('알림음 실패: $e');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }

  Future<void> keepScreenOn(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } catch (e) {
      debugPrint('화면 유지 설정 실패: $e');
    }
  }
}
