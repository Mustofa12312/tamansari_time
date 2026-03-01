import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';
import '../../../domain/entities/prayer_time.dart';
import '../../../domain/entities/prayer_settings.dart';
import '../../../domain/usecases/get_current_location_usecase.dart';
import '../../../domain/usecases/get_prayer_settings_usecase.dart';
import '../../../domain/usecases/get_prayer_times_usecase.dart';
import '../../../services/alarm_service.dart';
import '../../../services/notification_service.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetCurrentLocationUseCase _getLocation;
  final GetPrayerTimesUseCase _getPrayerTimes;
  final GetPrayerSettingsUseCase _getSettings;
  final AlarmService _alarmService;
  final NotificationService _notificationService;

  Timer? _countdownTimer;

  PrayerBloc(
    this._getLocation,
    this._getPrayerTimes,
    this._getSettings,
    this._alarmService,
    this._notificationService,
  ) : super(const PrayerInitial()) {
    on<LoadPrayerTimes>(_onLoad);
    on<RefreshForDate>(_onRefreshForDate);
    on<CountdownTick>(_onTick);
  }

  Future<void> _onLoad(LoadPrayerTimes event, Emitter<PrayerState> emit) async {
    emit(const PrayerLoading());

    // 1. Get location
    final locationResult =
        await _getLocation(forceRefresh: event.forceLocationRefresh);
    if (isClosed) return;

    await locationResult.fold(
      (failure) async => emit(PrayerError(failure.message)),
      (location) async {
        // 2. Get prayer settings
        final settingsResult = await _getSettings();
        if (isClosed) return;

        await settingsResult.fold(
          (failure) async => emit(PrayerError(failure.message)),
          (settings) async {
            // 3. Calculate prayer times
            final timesResult = await _getPrayerTimes(
              location: location,
              settings: settings,
            );
            if (isClosed) return;

            await timesResult.fold(
              (failure) async => emit(PrayerError(failure.message)),
              (times) async {
                // 4. Schedule notifications setiap kali prayer times dihitung
                if (settings.notificationsEnabled) {
                  await _scheduleNotificationsForDay(times, settings);
                }
                _startCountdown(times, location, emit);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onRefreshForDate(
    RefreshForDate event,
    Emitter<PrayerState> emit,
  ) async {
    final locationResult = await _getLocation();
    final settingsResult = await _getSettings();

    await locationResult.fold(
      (failure) async => emit(PrayerError(failure.message)),
      (location) async {
        await settingsResult.fold(
          (failure) async => emit(PrayerError(failure.message)),
          (settings) async {
            final timesResult = await _getPrayerTimes(
              location: location,
              settings: settings,
              date: event.date,
            );
            await timesResult.fold(
              (failure) async => emit(PrayerError(failure.message)),
              (times) async {
                if (settings.notificationsEnabled) {
                  await _scheduleNotificationsForDay(times, settings);
                }
                _startCountdown(times, location, emit);
              },
            );
          },
        );
      },
    );
  }

  /// Jadwalkan notifikasi/alarm untuk satu hari penuh.
  /// Dipanggil setiap kali prayer times berhasil dihitung.
  Future<void> _scheduleNotificationsForDay(
    PrayerTime times,
    PrayerSettings settings,
  ) async {
    try {
      // Cancel semua notif lama dulu
      await _notificationService.cancelAllPrayerNotifications();
      // Schedule melalui AlarmService (yang mengelola ID & audio)
      await _alarmService.schedulePrayerAlarms(times, settings);
    } catch (_) {
      // Jangan crash app jika notifikasi gagal
    }
  }

  void _onTick(CountdownTick event, Emitter<PrayerState> emit) {
    final current = state;
    if (current is PrayerLoaded) {
      // Recompute next prayer
      final nextTime = _computeNextPrayerTime(current.prayerTime);
      final newRemaining = nextTime.difference(DateTime.now());
      final nextName = _computeNextPrayerName(current.prayerTime);
      final currName = _computeCurrentPrayerName(current.prayerTime);

      if (!isClosed) {
        emit(
          PrayerLoaded(
            prayerTime: current.prayerTime,
            nextPrayerName: nextName,
            currentPrayerName: currName,
            timeUntilNext:
                newRemaining.isNegative ? Duration.zero : newRemaining,
            location: current.location,
            date: current.date,
          ),
        );
      }
    }
  }

  void _startCountdown(
    PrayerTime times,
    dynamic location,
    Emitter<PrayerState> emit,
  ) {
    _cancelTimer();
    final nextTime = _computeNextPrayerTime(times);
    final remaining = nextTime.difference(DateTime.now());

    emit(
      PrayerLoaded(
        prayerTime: times,
        nextPrayerName: _computeNextPrayerName(times),
        currentPrayerName: _computeCurrentPrayerName(times),
        timeUntilNext: remaining.isNegative ? Duration.zero : remaining,
        location: location,
        date: times.date,
      ),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const CountdownTick());
    });
  }

  DateTime _computeNextPrayerTime(PrayerTime t) {
    final now = DateTime.now();
    if (now.isBefore(t.imsak)) return t.imsak;
    if (now.isBefore(t.fajr)) return t.fajr;
    if (now.isBefore(t.sunrise)) return t.sunrise;
    if (now.isBefore(t.dhuhr)) return t.dhuhr;
    if (now.isBefore(t.asr)) return t.asr;
    if (now.isBefore(t.maghrib)) return t.maghrib;
    if (now.isBefore(t.isha)) return t.isha;
    return t.imsak.add(const Duration(hours: 24));
  }

  String _computeNextPrayerName(PrayerTime t) {
    final now = DateTime.now();
    if (now.isBefore(t.imsak)) return 'Imsak';
    if (now.isBefore(t.fajr)) return 'Subuh';
    if (now.isBefore(t.sunrise)) return 'Syuruq';
    if (now.isBefore(t.dhuhr)) return 'Zuhur';
    if (now.isBefore(t.asr)) return 'Ashar';
    if (now.isBefore(t.maghrib)) return 'Maghrib';
    if (now.isBefore(t.isha)) return 'Isya';
    return 'Imsak';
  }

  String _computeCurrentPrayerName(PrayerTime t) {
    final now = DateTime.now();
    if (now.isBefore(t.imsak)) return 'Isya';
    if (now.isBefore(t.fajr)) return 'Imsak';
    if (now.isBefore(t.sunrise)) return 'Subuh';
    if (now.isBefore(t.dhuhr)) return 'Syuruq';
    if (now.isBefore(t.asr)) return 'Zuhur';
    if (now.isBefore(t.maghrib)) return 'Ashar';
    if (now.isBefore(t.isha)) return 'Maghrib';
    return 'Isya';
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
