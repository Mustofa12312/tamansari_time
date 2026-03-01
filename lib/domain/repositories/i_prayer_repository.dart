import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../entities/prayer_time.dart';
import '../entities/prayer_settings.dart';
import '../../core/error/failures.dart';

abstract class IPrayerRepository {
  Future<Either<Failure, PrayerTime>> getPrayerTimes(
    LocationEntity location,
    DateTime date,
    PrayerSettings settings,
  );

  Future<Either<Failure, PrayerSettings>> getPrayerSettings();

  Future<Either<Failure, void>> savePrayerSettings(PrayerSettings settings);

  Future<Either<Failure, List<PrayerTime>>> getPrayerTimesForMonth(
    LocationEntity location,
    int year,
    int month,
    PrayerSettings settings,
  );
}
