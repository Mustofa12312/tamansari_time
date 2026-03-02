import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../../blocs/calendar/calendar_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../widgets/dual_calendar_cell.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          children: [
            Text(
              AppStrings.calendar,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Hijriah & Masehi',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_calls_rounded, color: AppColors.textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<CalendarCubit>().toggleCalendarPrimary();
            },
            tooltip: 'Tukar Hijriah/Masehi',
          ),
          IconButton(
            icon: Icon(Icons.today_rounded, color: AppColors.textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<CalendarCubit>().goToToday();
            },
            tooltip: 'Hari Ini',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, calState) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.textPrimary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: calState.showHijriAsPrimary
                            ? _buildHijriCalendar(context, calState)
                            : _buildGregorianCalendar(context, calState),
                      ),
                    ),
                  ),
                ),
                _DayInfoPanel(selectedDay: calState.selectedDay),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGregorianCalendar(BuildContext context, CalendarState calState) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: TableCalendar(
        key: ValueKey(calState.focusedDay.month),
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: calState.focusedDay,
        locale: 'id',
        availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
        selectedDayPredicate: (day) => isSameDay(day, calState.selectedDay),
        calendarFormat: CalendarFormat.month,
        onDaySelected: (selected, focused) {
          HapticFeedback.selectionClick();
          context.read<CalendarCubit>().selectDay(selected, focused);
        },
        onPageChanged: (focusedDay) {
          context.read<CalendarCubit>().changeFocusedDay(focusedDay);
        },
        headerStyle: HeaderStyle(
          titleTextStyle: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textPrimary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isHijriPrimary: false,
            isDarkBg: true,
          ),
          todayBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isToday: true,
            isHijriPrimary: false,
            isDarkBg: true,
          ),
          selectedBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isSelected: true,
            isToday: isSameDay(day, DateTime.now()),
            isHijriPrimary: false,
            isDarkBg: true,
          ),
          outsideBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isOutside: true,
            isHijriPrimary: false,
            isDarkBg: true,
          ),
        ),
      ),
    );
  }

  Widget _buildHijriCalendar(BuildContext context, CalendarState calState) {
    final focusHijri = HijriCalendar.fromDate(calState.focusedDay);
    final int lengthOfMonth = focusHijri.lengthOfMonth;
    final DateTime firstDayGregorian = focusHijri.hijriToGregorian(
      focusHijri.hYear,
      focusHijri.hMonth,
      1,
    );

    final int emptySlots = firstDayGregorian.weekday - 1;
    final int totalSlots = emptySlots + lengthOfMonth;
    final int rowCount = (totalSlots / 7).ceil();

    final arabicMonths = [
      '', // 1-indexed
      'Muharram',
      'Safar',
      'Rabiul Awal',
      'Rabiul Akhir',
      'Jumadil Awal',
      'Jumadil Akhir',
      'Rajab', 'Syaban', 'Ramadhan', 'Syawal', 'Dzulqaidah', 'Dzulhijjah',
    ];
    final arabicDays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CalendarCubit>().goToPreviousMonth();
                  },
                ),
                Text(
                  '${arabicMonths[focusHijri.hMonth]} ${focusHijri.hYear}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CalendarCubit>().goToNextMonth();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Days of week
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: Text(
                      arabicDays[index],
                      style: AppTypography.labelSmall.copyWith(
                        color: (index == 5 || index == 6)
                            ? AppColors.accent
                            : AppColors.textPrimary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < emptySlots || index >= emptySlots + lengthOfMonth) {
                final offset = index - emptySlots;
                final date = firstDayGregorian.add(Duration(days: offset));
                return DualCalendarCell(
                  date: date,
                  isOutside: true,
                  isHijriPrimary: true,
                  isDarkBg: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<CalendarCubit>().selectDay(date, date);
                  },
                );
              } else {
                final offset = index - emptySlots;
                final date = firstDayGregorian.add(Duration(days: offset));
                return DualCalendarCell(
                  date: date,
                  isSelected: isSameDay(date, calState.selectedDay),
                  isToday: isSameDay(date, DateTime.now()),
                  isHijriPrimary: true,
                  isDarkBg: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<CalendarCubit>().selectDay(
                      date,
                      calState.focusedDay,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DayInfoPanel extends StatelessWidget {
  final DateTime selectedDay;

  const _DayInfoPanel({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(selectedDay);
    final gregorianStr = DateFormat(
      'EEEE, d MMMM yyyy',
      'id',
    ).format(selectedDay);
    final hijriStr =
        '${hijri.hDay} ${hijri.longMonthNameIndo} ${hijri.hYear} H';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hijriStr,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gregorianStr,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
