import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/prayer_time_model.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/prayer_settings.dart';

class PrayerLocalSource {
  Box get _settingsBox => Hive.box(AppStrings.prayerSettingsBox);

  PrayerSettings loadSettings() {
    final box = _settingsBox;
    return PrayerSettings(
      method: PrayerCalculationMethod
          .values[box.get(AppStrings.methodKey, defaultValue: 0) as int],
      fajrAdjustment: box.get(AppStrings.fajrAdjKey, defaultValue: 0) as int,
      dhuhrAdjustment: box.get(AppStrings.dhuhrAdjKey, defaultValue: 0) as int,
      asrAdjustment: box.get(AppStrings.asrAdjKey, defaultValue: 0) as int,
      maghribAdjustment:
          box.get(AppStrings.maghribAdjKey, defaultValue: 0) as int,
      ishaAdjustment: box.get(AppStrings.ishaAdjKey, defaultValue: 0) as int,
      azanVolume: box.get(AppStrings.volumeKey, defaultValue: 0.8) as double,
      notificationsEnabled:
          box.get(AppStrings.notifEnabledKey, defaultValue: true) as bool,
      imsakAdjustment: box.get(AppStrings.imsakAdjKey, defaultValue: 0) as int,
      imsakEnabled:
          box.get(AppStrings.imsakEnabledKey, defaultValue: true) as bool,
      selectedAdhan: box.get(AppStrings.selectedAdhanKey,
          defaultValue: 'assets/audio/azan1.mp3') as String,
      isDarkMode: box.get(AppStrings.isDarkModeKey, defaultValue: true) as bool,
      autoThemeEnabled:
          box.get(AppStrings.autoThemeEnabledKey, defaultValue: false) as bool,
    );
  }

  Future<void> saveSettings(PrayerSettings settings) async {
    final box = _settingsBox;
    await box.put(AppStrings.methodKey, settings.method.index);
    await box.put(AppStrings.fajrAdjKey, settings.fajrAdjustment);
    await box.put(AppStrings.dhuhrAdjKey, settings.dhuhrAdjustment);
    await box.put(AppStrings.asrAdjKey, settings.asrAdjustment);
    await box.put(AppStrings.maghribAdjKey, settings.maghribAdjustment);
    await box.put(AppStrings.ishaAdjKey, settings.ishaAdjustment);
    await box.put(AppStrings.volumeKey, settings.azanVolume);
    await box.put(AppStrings.notifEnabledKey, settings.notificationsEnabled);
    await box.put(AppStrings.imsakAdjKey, settings.imsakAdjustment);
    await box.put(AppStrings.imsakEnabledKey, settings.imsakEnabled);
    await box.put(AppStrings.selectedAdhanKey, settings.selectedAdhan);
    await box.put(AppStrings.isDarkModeKey, settings.isDarkMode);
    await box.put(AppStrings.autoThemeEnabledKey, settings.autoThemeEnabled);
  }

  PrayerTimeModel? loadCachedPrayerTimes(DateTime date) {
    try {
      final box = Hive.box(AppStrings.prayerTimesBox);
      final key = '${date.year}-${date.month}-${date.day}';
      final raw = box.get(key) as String?;
      if (raw == null) return null;
      return PrayerTimeModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> cachePrayerTimes(PrayerTimeModel model) async {
    try {
      final box = Hive.box(AppStrings.prayerTimesBox);
      final key = '${model.date.year}-${model.date.month}-${model.date.day}';
      await box.put(key, jsonEncode(model.toJson()));
    } catch (_) {}
  }
}
