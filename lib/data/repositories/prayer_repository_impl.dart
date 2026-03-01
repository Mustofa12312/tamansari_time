import 'package:dartz/dartz.dart';
import '../sources/prayer_calculator.dart';
import '../sources/prayer_local_source.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_settings.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/i_prayer_repository.dart';
import '../../core/error/failures.dart';

class PrayerRepositoryImpl implements IPrayerRepository {
  final PrayerCalculator _calculator;
  final PrayerLocalSource _localSource;

  PrayerRepositoryImpl(this._calculator, this._localSource);

  @override
  Future<Either<Failure, PrayerTime>> getPrayerTimes(
    LocationEntity location,
    DateTime date,
    PrayerSettings settings,
  ) async {
    try {
      // Try cache first
      final cached = _localSource.loadCachedPrayerTimes(date);
      if (cached != null) {
        return Right(cached);
      }
      // Calculate fresh
      final model = _calculator.calculate(location, date, settings);
      await _localSource.cachePrayerTimes(model);
      return Right(model);
    } catch (e) {
      return Left(
        PrayerCalculationFailure('Gagal menghitung waktu sholat: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, PrayerSettings>> getPrayerSettings() async {
    try {
      return Right(_localSource.loadSettings());
    } catch (e) {
      return Left(CacheFailure('Gagal membaca pengaturan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePrayerSettings(
    PrayerSettings settings,
  ) async {
    try {
      await _localSource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan pengaturan: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTime>>> getPrayerTimesForMonth(
    LocationEntity location,
    int year,
    int month,
    PrayerSettings settings,
  ) async {
    try {
      final models = _calculator.calculateForMonth(
        location,
        year,
        month,
        settings,
      );
      // Cache each day
      for (final m in models) {
        await _localSource.cachePrayerTimes(m);
      }
      return Right(models);
    } catch (e) {
      return Left(
        PrayerCalculationFailure('Gagal menghitung jadwal bulanan: $e'),
      );
    }
  }
}
