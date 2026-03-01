//
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';

class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat format;
  final Map<DateTime, List<dynamic>> events;
  final bool showHijriAsPrimary;

  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    this.format = CalendarFormat.month,
    this.events = const {},
    this.showHijriAsPrimary = false,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarFormat? format,
    Map<DateTime, List<dynamic>>? events,
    bool? showHijriAsPrimary,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      format: format ?? this.format,
      events: events ?? this.events,
      showHijriAsPrimary: showHijriAsPrimary ?? this.showHijriAsPrimary,
    );
  }
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit()
      : super(
          CalendarState(
              focusedDay: DateTime.now(), selectedDay: DateTime.now()),
        );

  void selectDay(DateTime day, DateTime focusedDay) {
    emit(state.copyWith(selectedDay: day, focusedDay: focusedDay));
  }

  void changeFocusedDay(DateTime day) {
    emit(state.copyWith(focusedDay: day));
  }

  void changeFormat(CalendarFormat format) {
    emit(state.copyWith(format: format));
  }

  void toggleCalendarPrimary() {
    emit(state.copyWith(showHijriAsPrimary: !state.showHijriAsPrimary));
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(focusedDay: now, selectedDay: now));
  }

  void goToPreviousMonth() {
    if (state.showHijriAsPrimary) {
      final currentHijri = HijriCalendar.fromDate(state.focusedDay);
      int ny = currentHijri.hYear;
      int nm = currentHijri.hMonth - 1;
      if (nm <= 0) {
        nm = 12;
        ny -= 1;
      }
      final prevHijriFirstDay = currentHijri.hijriToGregorian(ny, nm, 1);
      emit(state.copyWith(focusedDay: prevHijriFirstDay));
    } else {
      final prev =
          DateTime(state.focusedDay.year, state.focusedDay.month - 1, 1);
      emit(state.copyWith(focusedDay: prev));
    }
  }

  void goToNextMonth() {
    if (state.showHijriAsPrimary) {
      final currentHijri = HijriCalendar.fromDate(state.focusedDay);
      int ny = currentHijri.hYear;
      int nm = currentHijri.hMonth + 1;
      if (nm > 12) {
        nm = 1;
        ny += 1;
      }
      final nextHijriFirstDay = currentHijri.hijriToGregorian(ny, nm, 1);
      emit(state.copyWith(focusedDay: nextHijriFirstDay));
    } else {
      final next =
          DateTime(state.focusedDay.year, state.focusedDay.month + 1, 1);
      emit(state.copyWith(focusedDay: next));
    }
  }
}
