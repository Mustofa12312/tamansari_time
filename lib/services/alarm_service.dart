import '../domain/entities/prayer_time.dart';
import '../domain/entities/prayer_settings.dart';
import 'notification_service.dart';

/// Schedules prayer notifications using flutter_local_notifications.
/// android_alarm_manager_plus dihapus karena tidak kompatibel dengan Flutter v2 embedding.
class AlarmService {
  final NotificationService _notificationService;

  static const int _imsakAlarmId = 199;
  static const int _fajrAlarmId = 200;
  static const int _dhuhrAlarmId = 202;
  static const int _asrAlarmId = 203;
  static const int _maghribAlarmId = 204;
  static const int _ishaAlarmId = 205;

  AlarmService(this._notificationService);

  Future<void> schedulePrayerAlarms(
    PrayerTime prayerTime,
    PrayerSettings settings,
  ) async {
    if (!settings.notificationsEnabled) return;

    // Hitung offset berdasarkan hari untuk ID unik (0 untuk hari ini, 10 untuk besok)
    final now = DateTime.now();
    final isTomorrow = prayerTime.date.day != now.day;
    final idOffset = isTomorrow ? 10 : 0;

    final prayers = {
      _fajrAlarmId + idOffset: (
        prayerTime.fajr,
        'Subuh',
        settings.selectedAdhan
      ),
      _dhuhrAlarmId + idOffset: (
        prayerTime.dhuhr,
        'Zuhur',
        settings.selectedAdhan
      ),
      _asrAlarmId + idOffset: (prayerTime.asr, 'Ashar', settings.selectedAdhan),
      _maghribAlarmId + idOffset: (
        prayerTime.maghrib,
        'Maghrib',
        settings.selectedAdhan
      ),
      _ishaAlarmId + idOffset: (
        prayerTime.isha,
        'Isya',
        settings.selectedAdhan
      ),
    };

    if (settings.imsakEnabled) {
      prayers[_imsakAlarmId + idOffset] =
          (prayerTime.imsak, 'Imsak', 'imsak.mp3');
    }

    for (final entry in prayers.entries) {
      final id = entry.key;
      final time = entry.value.$1;
      final name = entry.value.$2;
      final audioFileName = entry.value.$3.split('/').last;

      if (time.isAfter(DateTime.now())) {
        // Cancel ID spesifik ini dulu sebelum schedule ulang agar fresh
        await _notificationService.cancelNotification(id);

        await _notificationService.scheduleSinglePrayerNotification(
          id: id,
          name: name,
          time: time,
          soundFileName: audioFileName,
        );
      }
    }
  }

  Future<void> cancelAllAlarms() async {
    for (final id in [
      _imsakAlarmId,
      _fajrAlarmId,
      _dhuhrAlarmId,
      _asrAlarmId,
      _maghribAlarmId,
      _ishaAlarmId,
    ]) {
      await _notificationService.cancelNotification(id);
    }
  }
}
