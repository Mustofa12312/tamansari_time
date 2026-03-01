import 'package:equatable/equatable.dart';

/// Immutable entity representing the 5 daily prayer times for a given date.
class PrayerTime extends Equatable {
  final DateTime imsak;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;

  const PrayerTime({
    required this.imsak,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  PrayerTime copyWith({
    DateTime? imsak,
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    DateTime? date,
  }) {
    return PrayerTime(
      imsak: imsak ?? this.imsak,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props =>
      [imsak, fajr, sunrise, dhuhr, asr, maghrib, isha, date];
}
