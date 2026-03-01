import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/solar_phase.dart';
import '../../../domain/entities/prayer_time.dart';

class ThemeCubit extends Cubit<List<Color>> {
  ThemeCubit() : super(AppColors.ishaGradient);

  void updateFromPrayerTime(PrayerTime prayerTime) {
    // Build a temporary adhan PrayerTimes-like structure using our entity
    final phase = _computePhase(prayerTime);
    emit(_gradientFor(phase));
  }

  SolarPhase _computePhase(PrayerTime t) {
    final now = DateTime.now();
    if (now.isBefore(t.fajr)) return SolarPhase.isha;
    if (now.isBefore(t.sunrise)) return SolarPhase.fajr;
    if (now.isBefore(t.dhuhr)) return SolarPhase.sunrise;
    if (now.isBefore(t.asr)) return SolarPhase.dhuhr;
    if (now.isBefore(t.maghrib)) return SolarPhase.asr;
    if (now.isBefore(t.isha)) return SolarPhase.maghrib;
    return SolarPhase.isha;
  }

  List<Color> _gradientFor(SolarPhase phase) {
    switch (phase) {
      case SolarPhase.fajr:
        return AppColors.fajrGradient;
      case SolarPhase.sunrise:
        return AppColors.sunriseGradient;
      case SolarPhase.dhuhr:
        return AppColors.dhuhrGradient;
      case SolarPhase.asr:
        return AppColors.asrGradient;
      case SolarPhase.maghrib:
        return AppColors.maghribGradient;
      case SolarPhase.isha:
        return AppColors.ishaGradient;
    }
  }

  String gradientLabel(List<Color> gradient) {
    if (gradient == AppColors.fajrGradient) return 'Subuh';
    if (gradient == AppColors.sunriseGradient) return 'Syuruq';
    if (gradient == AppColors.dhuhrGradient) return 'Zuhur';
    if (gradient == AppColors.asrGradient) return 'Ashar';
    if (gradient == AppColors.maghribGradient) return 'Maghrib';
    return 'Isya';
  }
}
