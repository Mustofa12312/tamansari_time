import 'package:adhan/adhan.dart';

/// Represents the current solar phase based on prayer times.
/// Used to drive the adaptive gradient theme.
enum SolarPhase { fajr, sunrise, dhuhr, asr, maghrib, isha }

class SolarPhaseUtil {
  SolarPhaseUtil._();

  /// Determines current [SolarPhase] from [PrayerTimes] and [DateTime.now()].
  static SolarPhase current(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    final fajr = prayerTimes.fajr;
    final sunrise = prayerTimes.sunrise;
    final dhuhr = prayerTimes.dhuhr;
    final asr = prayerTimes.asr;
    final maghrib = prayerTimes.maghrib;
    final isha = prayerTimes.isha;

    if (now.isBefore(fajr)) return SolarPhase.isha;
    if (now.isBefore(sunrise)) return SolarPhase.fajr;
    if (now.isBefore(dhuhr)) return SolarPhase.sunrise;
    if (now.isBefore(asr)) return SolarPhase.dhuhr;
    if (now.isBefore(maghrib)) return SolarPhase.asr;
    if (now.isBefore(isha)) return SolarPhase.maghrib;
    return SolarPhase.isha;
  }

  /// Name of the next prayer in Indonesian
  static String nextPrayerName(PrayerTimes prayerTimes) {
    final phase = current(prayerTimes);
    switch (phase) {
      case SolarPhase.fajr:
        return 'Syuruq';
      case SolarPhase.sunrise:
        return 'Zuhur';
      case SolarPhase.dhuhr:
        return 'Ashar';
      case SolarPhase.asr:
        return 'Maghrib';
      case SolarPhase.maghrib:
        return 'Isya';
      case SolarPhase.isha:
        return 'Subuh';
    }
  }

  /// Returns the [DateTime] of the next prayer
  static DateTime nextPrayerTime(PrayerTimes prayerTimes) {
    final phase = current(prayerTimes);
    switch (phase) {
      case SolarPhase.fajr:
        return prayerTimes.sunrise;
      case SolarPhase.sunrise:
        return prayerTimes.dhuhr;
      case SolarPhase.dhuhr:
        return prayerTimes.asr;
      case SolarPhase.asr:
        return prayerTimes.maghrib;
      case SolarPhase.maghrib:
        return prayerTimes.isha;
      case SolarPhase.isha:
        // Next fajr is tomorrow — add 1 day approximation
        return prayerTimes.fajr.add(const Duration(hours: 24));
    }
  }

  /// Returns current prayer name in Indonesian
  static String currentPrayerName(PrayerTimes prayerTimes) {
    final phase = current(prayerTimes);
    switch (phase) {
      case SolarPhase.fajr:
        return 'Subuh';
      case SolarPhase.sunrise:
        return 'Syuruq';
      case SolarPhase.dhuhr:
        return 'Zuhur';
      case SolarPhase.asr:
        return 'Ashar';
      case SolarPhase.maghrib:
        return 'Maghrib';
      case SolarPhase.isha:
        return 'Isya';
    }
  }
}
