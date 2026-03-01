import 'package:dartz/dartz.dart';
import '../entities/prayer_settings.dart';
import '../repositories/i_prayer_repository.dart';
import '../../core/error/failures.dart';

class GetPrayerSettingsUseCase {
  final IPrayerRepository _repository;

  GetPrayerSettingsUseCase(this._repository);

  Future<Either<Failure, PrayerSettings>> call() {
    return _repository.getPrayerSettings();
  }
}

class SavePrayerSettingsUseCase {
  final IPrayerRepository _repository;

  SavePrayerSettingsUseCase(this._repository);

  Future<Either<Failure, void>> call(PrayerSettings settings) {
    return _repository.savePrayerSettings(settings);
  }
}
