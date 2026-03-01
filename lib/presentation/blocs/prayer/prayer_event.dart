import 'package:equatable/equatable.dart';

abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial load — fetches GPS location + calculates prayer times
class LoadPrayerTimes extends PrayerEvent {
  final bool forceLocationRefresh;
  const LoadPrayerTimes({this.forceLocationRefresh = false});

  @override
  List<Object?> get props => [forceLocationRefresh];
}

/// Refresh with new date (e.g., when day changes at midnight)
class RefreshForDate extends PrayerEvent {
  final DateTime date;
  const RefreshForDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Countdown tick — fires every second to update the timer
class CountdownTick extends PrayerEvent {
  const CountdownTick();
}
