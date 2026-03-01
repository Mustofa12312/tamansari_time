import 'package:just_audio/just_audio.dart';
import '../core/constants/app_strings.dart';
import 'package:hive/hive.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  double _volume = 0.8;

  Future<void> initialize() async {
    final box = Hive.box(AppStrings.prayerSettingsBox);
    _volume =
        (box.get(AppStrings.volumeKey, defaultValue: 0.8) as num).toDouble();
    await _player.setVolume(_volume);
  }

  Future<void> playAzan({String? assetPath}) async {
    try {
      final box = Hive.box(AppStrings.prayerSettingsBox);
      final defaultAdhan = box.get(AppStrings.selectedAdhanKey,
          defaultValue: 'assets/audio/azan1.mp3') as String;
      final path = assetPath ?? defaultAdhan;
      await _player.stop();
      await _player.setAsset(path);
      await _player.setVolume(_volume);
      await _player.play();
    } catch (e) {
      // Silently fail if audio asset not found
    }
  }

  Future<void> stopAzan() async {
    await _player.stop();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    final box = Hive.box(AppStrings.prayerSettingsBox);
    await box.put(AppStrings.volumeKey, _volume);
  }

  bool get isPlaying => _player.playing;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
