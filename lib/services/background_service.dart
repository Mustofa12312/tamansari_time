import 'notification_service.dart';
import 'alarm_service.dart';
import '../data/sources/location_service.dart';
import '../data/sources/prayer_calculator.dart';
import '../data/sources/prayer_local_source.dart';

/// Manages prayer time refresh dan notification scheduling.
/// Background scheduling dilakukan via flutter_local_notifications.
/// Refresh terjadi saat app dibuka (scheduleMidnightRefresh).
class BackgroundService {
  final NotificationService _notificationService;
  final AlarmService _alarmService;

  BackgroundService(this._notificationService, this._alarmService);

  /// Dipanggil saat app start:
  /// 1. Schedule notifikasi untuk HARI INI (waktu yang belum lewat)
  /// 2. Schedule notifikasi untuk BESOK agar siap di tengah malam
  Future<void> scheduleMidnightRefresh() async {
    Future.microtask(() async {
      try {
        final locationService = LocationService();
        final location = await locationService.getCurrentLocation();

        final localSource = PrayerLocalSource();
        final settings = localSource.loadSettings();

        final calculator = PrayerCalculator();
        final now = DateTime.now();

        // ── Schedule notifikasi hari ini ─────────────────────────────────────
        // Ini penting agar notifikasi waktu sholat yang belum lewat hari ini
        // selalu terjadwal saat app dibuka
        final todayTimes = calculator.calculate(location, now, settings);
        await localSource.cachePrayerTimes(todayTimes);
        if (settings.notificationsEnabled) {
          await _notificationService.cancelAllPrayerNotifications();
          await _alarmService.schedulePrayerAlarms(todayTimes, settings);
        }

        // ── Schedule notifikasi besok ─────────────────────────────────────────
        // Supaya notifikasi subuh besok sudah siap bahkan jika app tidak dibuka
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowTimes =
            calculator.calculate(location, tomorrow, settings);
        await localSource.cachePrayerTimes(tomorrowTimes);

        // KRUSIAL: Jadwalkan juga untuk besok!
        if (settings.notificationsEnabled) {
          await _alarmService.schedulePrayerAlarms(tomorrowTimes, settings);
        }
      } catch (_) {
        // Silently fail — akan retry saat app dibuka lagi
      }
    });
  }
}
