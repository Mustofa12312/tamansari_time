import 'package:equatable/equatable.dart';

/// Calculation method IDs matching adhan package
enum PrayerCalculationMethod {
  kemenag, // Indonesian Ministry (most common in ID)
  mwl, // Muslim World League
  isna, // Islamic Society of North America
  egypt, // Egyptian General Authority
  makkah, // Umm al-Qura, Makkah
  karachi, // University of Islamic Sciences, Karachi
  tehran, // Institute of Geophysics, University of Tehran
  singapore, // MUIS Singapore
  falak, // Falak Panyeppen (Metode Lokal Pesantren Indonesia)
}

/// User-configurable prayer time settings with minute adjustments.
class PrayerSettings extends Equatable {
  final PrayerCalculationMethod method;
  final int fajrAdjustment;
  final int dhuhrAdjustment;
  final int asrAdjustment;
  final int maghribAdjustment;
  final int ishaAdjustment;
  final int imsakAdjustment;
  final bool imsakEnabled;
  final String selectedAdhan;
  final double azanVolume;
  final bool notificationsEnabled;
  final bool isDarkMode;
  final bool autoThemeEnabled;

  const PrayerSettings({
    this.method = PrayerCalculationMethod.kemenag,
    this.fajrAdjustment = 0,
    this.dhuhrAdjustment = 0,
    this.asrAdjustment = 0,
    this.maghribAdjustment = 0,
    this.ishaAdjustment = 0,
    this.imsakAdjustment = 0,
    this.imsakEnabled = true,
    this.selectedAdhan = 'assets/audio/azan1.mp3',
    this.azanVolume = 0.8,
    this.notificationsEnabled = true,
    this.isDarkMode = true,
    this.autoThemeEnabled = false,
  });

  PrayerSettings copyWith({
    PrayerCalculationMethod? method,
    int? fajrAdjustment,
    int? dhuhrAdjustment,
    int? asrAdjustment,
    int? maghribAdjustment,
    int? ishaAdjustment,
    int? imsakAdjustment,
    bool? imsakEnabled,
    String? selectedAdhan,
    double? azanVolume,
    bool? notificationsEnabled,
    bool? isDarkMode,
    bool? autoThemeEnabled,
  }) {
    return PrayerSettings(
      method: method ?? this.method,
      fajrAdjustment: fajrAdjustment ?? this.fajrAdjustment,
      dhuhrAdjustment: dhuhrAdjustment ?? this.dhuhrAdjustment,
      asrAdjustment: asrAdjustment ?? this.asrAdjustment,
      maghribAdjustment: maghribAdjustment ?? this.maghribAdjustment,
      ishaAdjustment: ishaAdjustment ?? this.ishaAdjustment,
      imsakAdjustment: imsakAdjustment ?? this.imsakAdjustment,
      imsakEnabled: imsakEnabled ?? this.imsakEnabled,
      selectedAdhan: selectedAdhan ?? this.selectedAdhan,
      azanVolume: azanVolume ?? this.azanVolume,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoThemeEnabled: autoThemeEnabled ?? this.autoThemeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        method,
        fajrAdjustment,
        dhuhrAdjustment,
        asrAdjustment,
        maghribAdjustment,
        ishaAdjustment,
        imsakAdjustment,
        imsakEnabled,
        selectedAdhan,
        azanVolume,
        notificationsEnabled,
        isDarkMode,
        autoThemeEnabled,
      ];
}
