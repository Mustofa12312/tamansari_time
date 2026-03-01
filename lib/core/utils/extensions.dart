import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

extension DateTimeExtensions on DateTime {
  /// Format: "Senin, 25 Februari 2026"
  String toIndonesianDateString() {
    return DateFormat('EEEE, d MMMM yyyy', 'id').format(this);
  }

  /// Format: "06:15"
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format: "06:15:30"
  String toFullTimeString() {
    return DateFormat('HH:mm:ss').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

extension DurationExtensions on Duration {
  /// Format: "02:34:15"
  String toHhMmSs() {
    final hours = inHours.toString().padLeft(2, '0');
    final mins = inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$mins:$secs';
  }

  String toHumanReadable() {
    if (inHours > 0) {
      return '${inHours}j ${inMinutes.remainder(60)}m';
    }
    return '${inMinutes}m ${inSeconds.remainder(60)}d';
  }
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => mediaQuery.size;
  double get screenWidth => size.width;
  double get screenHeight => size.height;
  bool get isDark => theme.brightness == Brightness.dark;
}

extension HijriCalendarExtensions on HijriCalendar {
  String get longMonthNameIndo {
    switch (hMonth) {
      case 1:
        return 'Muharram';
      case 2:
        return 'Safar';
      case 3:
        return 'Rabiul Awal';
      case 4:
        return 'Rabiul Akhir';
      case 5:
        return 'Jumadil Awal';
      case 6:
        return 'Jumadil Akhir';
      case 7:
        return 'Rajab';
      case 8:
        return 'Syaban';
      case 9:
        return 'Ramadhan';
      case 10:
        return 'Syawal';
      case 11:
        return 'Dzulqaidah';
      case 12:
        return 'Dzulhijjah';
      default:
        return '';
    }
  }
}
