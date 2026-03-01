import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer_time.dart';
import '../../../domain/entities/location.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {
  const PrayerInitial();
}

class PrayerLoading extends PrayerState {
  const PrayerLoading();
}

class PrayerLoaded extends PrayerState {
  final PrayerTime prayerTime;
  final String nextPrayerName;
  final String currentPrayerName;
  final Duration timeUntilNext;
  final LocationEntity location;
  final DateTime date;

  const PrayerLoaded({
    required this.prayerTime,
    required this.nextPrayerName,
    required this.currentPrayerName,
    required this.timeUntilNext,
    required this.location,
    required this.date,
  });

  @override
  List<Object?> get props => [
    prayerTime,
    nextPrayerName,
    currentPrayerName,
    timeUntilNext,
    location,
    date,
  ];
}

class PrayerError extends PrayerState {
  final String message;
  const PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}
