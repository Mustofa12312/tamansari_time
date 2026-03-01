import 'package:get_it/get_it.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/prayer_repository_impl.dart';
import '../../data/sources/location_service.dart';
import '../../data/sources/prayer_calculator.dart';
import '../../data/sources/prayer_local_source.dart';
import '../../domain/repositories/i_location_repository.dart';
import '../../domain/repositories/i_prayer_repository.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_prayer_settings_usecase.dart';
import '../../domain/usecases/get_prayer_times_usecase.dart';
import '../../presentation/blocs/calendar/calendar_cubit.dart';
import '../../presentation/blocs/prayer/prayer_bloc.dart';
import '../../presentation/blocs/settings/settings_cubit.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
import '../../services/alarm_service.dart';
import '../../services/audio_service.dart';
import '../../services/background_service.dart';
import '../../services/notification_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ─── Services ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<AlarmService>(() => AlarmService(getIt()));
  getIt.registerLazySingleton<BackgroundService>(
    () => BackgroundService(getIt(), getIt()),
  );

  // ─── Data Sources ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<PrayerCalculator>(() => PrayerCalculator());
  getIt.registerLazySingleton<PrayerLocalSource>(() => PrayerLocalSource());

  // ─── Repositories ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ILocationRepository>(
    () => LocationRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IPrayerRepository>(
    () => PrayerRepositoryImpl(getIt(), getIt()),
  );

  // ─── Use Cases ────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<GetCurrentLocationUseCase>(
    () => GetCurrentLocationUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetPrayerTimesUseCase>(
    () => GetPrayerTimesUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetPrayerSettingsUseCase>(
    () => GetPrayerSettingsUseCase(getIt()),
  );

  // ─── BLoC / Cubits ────────────────────────────────────────────────────────
  getIt.registerFactory<PrayerBloc>(
    () => PrayerBloc(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<CalendarCubit>(() => CalendarCubit());
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit());
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit(getIt()));
}
