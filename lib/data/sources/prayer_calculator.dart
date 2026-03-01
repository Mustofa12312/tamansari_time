import 'package:adhan/adhan.dart';
import '../models/prayer_time_model.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_settings.dart';

/// Wraps the `adhan` package with calculation method selection
/// and per-prayer minute adjustments from [PrayerSettings].
class PrayerCalculator {
  PrayerTimeModel calculate(
    LocationEntity location,
    DateTime date,
    PrayerSettings settings,
  ) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final params = _buildParameters(settings);

    final dateComponents = DateComponents(date.year, date.month, date.day);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // Calculate Imsak
    final baseImsak = prayerTimes.fajr.subtract(const Duration(minutes: 10));

    // Apply minute adjustments
    return PrayerTimeModel(
      imsak: baseImsak.add(Duration(minutes: settings.imsakAdjustment)),
      fajr: prayerTimes.fajr.add(Duration(minutes: settings.fajrAdjustment)),
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr.add(Duration(minutes: settings.dhuhrAdjustment)),
      asr: prayerTimes.asr.add(Duration(minutes: settings.asrAdjustment)),
      maghrib: prayerTimes.maghrib.add(
        Duration(minutes: settings.maghribAdjustment),
      ),
      isha: prayerTimes.isha.add(Duration(minutes: settings.ishaAdjustment)),
      date: date,
    );
  }

  List<PrayerTimeModel> calculateForMonth(
    LocationEntity location,
    int year,
    int month,
    PrayerSettings settings,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final results = <PrayerTimeModel>[];
    for (var day = 1; day <= daysInMonth; day++) {
      results.add(calculate(location, DateTime(year, month, day), settings));
    }
    return results;
  }

  CalculationParameters _buildParameters(PrayerSettings settings) {
    switch (settings.method) {
      case PrayerCalculationMethod.kemenag:
        // Kemenag Indonesia — custom: Fajr 20°, Isha 18°
        final params = CalculationMethod.karachi.getParameters();
        params.fajrAngle = 20;
        params.ishaAngle = 18;
        return params;
      case PrayerCalculationMethod.mwl:
        return CalculationMethod.muslim_world_league.getParameters();
      case PrayerCalculationMethod.isna:
        return CalculationMethod.north_america.getParameters();
      case PrayerCalculationMethod.egypt:
        return CalculationMethod.egyptian.getParameters();
      case PrayerCalculationMethod.makkah:
        return CalculationMethod.umm_al_qura.getParameters();
      case PrayerCalculationMethod.karachi:
        return CalculationMethod.karachi.getParameters();
      case PrayerCalculationMethod.tehran:
        return CalculationMethod.tehran.getParameters();
      case PrayerCalculationMethod.singapore:
        return CalculationMethod.singapore.getParameters();
      case PrayerCalculationMethod.falak:
        // Falak Panyeppen — Metode pesantren tradisional Indonesia
        // Fajr 20°, Isha 18°, madhab Syafi'i (Asr standar)
        final params = CalculationMethod.karachi.getParameters();
        params.fajrAngle = 20;
        params.ishaAngle = 18;
        params.madhab = Madhab.shafi;
        return params;
    }
  }
}
