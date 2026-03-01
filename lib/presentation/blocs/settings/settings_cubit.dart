import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/prayer_settings.dart';
import '../../../domain/usecases/get_prayer_settings_usecase.dart';
import '../../../data/sources/prayer_local_source.dart';

class SettingsCubit extends Cubit<PrayerSettings> {
  final GetPrayerSettingsUseCase _getSettings;
  final PrayerLocalSource _localSource = PrayerLocalSource();

  SettingsCubit(this._getSettings) : super(const PrayerSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final result = await _getSettings();
    result.fold((_) {}, (settings) => emit(settings));
  }

  Future<void> setMethod(PrayerCalculationMethod method) async {
    final updated = state.copyWith(method: method);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setFajrAdjustment(int minutes) async {
    final updated = state.copyWith(fajrAdjustment: minutes);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setDhuhrAdjustment(int minutes) async {
    final updated = state.copyWith(dhuhrAdjustment: minutes);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setAsrAdjustment(int minutes) async {
    final updated = state.copyWith(asrAdjustment: minutes);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setMaghribAdjustment(int minutes) async {
    final updated = state.copyWith(maghribAdjustment: minutes);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setIshaAdjustment(int minutes) async {
    final updated = state.copyWith(ishaAdjustment: minutes);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setImsakAdjustment(int minutes) async {
    final updated = state.copyWith(imsakAdjustment: minutes);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setImsakEnabled(bool enabled) async {
    final updated = state.copyWith(imsakEnabled: enabled);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setSelectedAdhan(String adhanPath) async {
    final updated = state.copyWith(selectedAdhan: adhanPath);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setVolume(double volume) async {
    final updated = state.copyWith(azanVolume: volume);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> resetToDefaults() async {
    const defaults = PrayerSettings();
    emit(defaults);
    await _localSource.saveSettings(defaults);
  }

  Future<void> setDarkMode(bool isDark) async {
    final updated = state.copyWith(isDarkMode: isDark);
    emit(updated);
    await _localSource.saveSettings(updated);
  }

  Future<void> setAutoThemeEnabled(bool enabled) async {
    final updated = state.copyWith(autoThemeEnabled: enabled);
    emit(updated);
    await _localSource.saveSettings(updated);
  }
}
