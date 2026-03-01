import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../entities/prayer_time.dart';
import '../entities/prayer_settings.dart';
import '../repositories/i_prayer_repository.dart';
import '../../core/error/failures.dart';

class GetPrayerTimesUseCase {
  final IPrayerRepository _repository;

  GetPrayerTimesUseCase(this._repository);

  Future<Either<Failure, PrayerTime>> call({
    required LocationEntity location,
    required PrayerSettings settings,
    DateTime? date,
  }) {
    return _repository.getPrayerTimes(
      location,
      date ?? DateTime.now(),
      settings,
    );
  }
}

class GetPrayerTimesForMonthUseCase {
  final IPrayerRepository _repository;

  GetPrayerTimesForMonthUseCase(this._repository);

  Future<Either<Failure, List<PrayerTime>>> call({
    required LocationEntity location,
    required PrayerSettings settings,
    required int year,
    required int month,
  }) {
    return _repository.getPrayerTimesForMonth(location, year, month, settings);
  }
}
