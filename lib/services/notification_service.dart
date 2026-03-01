import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/app_strings.dart';
import '../domain/entities/prayer_time.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Inisialisasi timezone — gunakan current local timezone
    tz.initializeTimeZones();
    _setLocalTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linux = LinuxInitializationSettings(
      defaultActionName: 'Buka',
    );
    const settings = InitializationSettings(
      android: android,
      iOS: iOS,
      linux: linux,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Buat notification channel dengan prioritas maksimum
    const channel = AndroidNotificationChannel(
      AppStrings.notifChannelId,
      AppStrings.notifChannelName,
      description: AppStrings.notifChannelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan1'), // Default sound
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    // Minta izin notifikasi & exact alarms
    await _requestPermissions();

    _initialized = true;
  }

  /// Deteksi timezone lokal dari environment variable atau fallback ke Jakarta
  void _setLocalTimezone() {
    try {
      // Coba baca timezone dari sistem
      final envTz = Platform.environment['TZ'];
      if (envTz != null && envTz.isNotEmpty) {
        try {
          tz.setLocalLocation(tz.getLocation(envTz));
          return;
        } catch (_) {}
      }
      // Coba baca dari /etc/timezone (Linux/Android)
      final tzFile = File('/etc/timezone');
      if (tzFile.existsSync()) {
        final tzName = tzFile.readAsStringSync().trim();
        if (tzName.isNotEmpty) {
          try {
            tz.setLocalLocation(tz.getLocation(tzName));
            return;
          } catch (_) {}
        }
      }
    } catch (_) {}
    // Fallback ke Jakarta untuk Indonesia
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        // Minta izin POST_NOTIFICATIONS (Android 13+)
        await androidPlugin?.requestNotificationsPermission();
        // Minta izin exact alarm (Android 12+)
        await androidPlugin?.requestExactAlarmsPermission();
      } else if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (_) {
      // Jangan crash jika permission request gagal
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Navigate to home screen — handled by app router
  }

  Future<void> schedulePrayerNotifications(PrayerTime prayerTime) async {
    await cancelAllPrayerNotifications();

    final prayers = {
      100: ('Subuh', prayerTime.fajr),
      102: ('Zuhur', prayerTime.dhuhr),
      103: ('Ashar', prayerTime.asr),
      104: ('Maghrib', prayerTime.maghrib),
      105: ('Isya', prayerTime.isha),
    };

    for (final entry in prayers.entries) {
      final id = entry.key;
      final name = entry.value.$1;
      final time = entry.value.$2;

      if (time.isAfter(DateTime.now())) {
        await _scheduleNotification(id, name, time);
      }
    }
  }

  Future<void> _scheduleNotification(
    int id,
    String prayerName,
    DateTime time, {
    String? soundFileName,
  }) async {
    // Re-init timezone setiap kali schedule untuk keakuratan
    _setLocalTimezone();

    final tzTime = tz.TZDateTime.from(time, tz.local);

    // Lewatkan jika waktunya sudah lewat
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetail = AndroidNotificationDetails(
      AppStrings.notifChannelId,
      AppStrings.notifChannelName,
      channelDescription: AppStrings.notifChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Waktu $prayerName',
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      sound: soundFileName != null
          ? RawResourceAndroidNotificationSound(
              soundFileName.replaceAll('.mp3', ''))
          : null,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      styleInformation: BigTextStyleInformation(
        prayerName == 'Imsak'
            ? 'Waktu Imsak telah tiba. Sebentar lagi Subuh.'
            : 'Sudah masuk waktu $prayerName. Segera kerjakan sholat.',
        summaryText: 'Waqtuna',
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        AppStrings.notifTitle,
        prayerName == 'Imsak' ? 'Waktu Imsak' : 'Sudah masuk waktu $prayerName',
        tzTime,
        NotificationDetails(
          android: androidDetail,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          linux: const LinuxNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Fallback: coba tanpa exact alarm jika gagal (misal izin dicabut)
      try {
        await _plugin.zonedSchedule(
          id,
          AppStrings.notifTitle,
          prayerName == 'Imsak'
              ? 'Waktu Imsak'
              : 'Sudah masuk waktu $prayerName',
          tzTime,
          NotificationDetails(
            android: androidDetail,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelAllPrayerNotifications() async {
    // Cancel semua ID yang digunakan oleh NotificationService
    for (final id in [100, 102, 103, 104, 105]) {
      await _plugin.cancel(id);
    }
    // Cancel juga ID yang digunakan AlarmService
    for (final id in [199, 200, 202, 203, 204, 205]) {
      await _plugin.cancel(id);
    }
  }

  /// Schedule a single prayer notification (used by AlarmService)
  Future<void> scheduleSinglePrayerNotification({
    required int id,
    required String name,
    required DateTime time,
    String? soundFileName,
  }) async {
    await _scheduleNotification(id, name, time, soundFileName: soundFileName);
  }

  /// Cancel a single notification by ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> showImmediateTestNotification() async {
    await _plugin.show(
      999,
      'Tes Notifikasi ✅',
      'An-Noor berhasil mengirim notifikasi!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppStrings.notifChannelId,
          AppStrings.notifChannelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}
