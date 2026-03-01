import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../blocs/calendar/calendar_cubit.dart';
import '../../blocs/prayer/prayer_bloc.dart';
import '../../blocs/prayer/prayer_event.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<PrayerBloc>().add(
              const LoadPrayerTimes(forceLocationRefresh: true),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildCalendarCard(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildTodaySection(context),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildPrayerList(context),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final cubit = context.read<CalendarCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.calendarHighlight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.MMMM().format(state.focusedDay),
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.search_rounded, color: AppColors.textPrimary),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Calendar
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: state.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(state.selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  cubit.selectDay(selectedDay, focusedDay);
                  context.read<PrayerBloc>().add(RefreshForDate(selectedDay));
                },
                headerVisible: false,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  weekendStyle: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, isSelected: false, isToday: false),
                  selectedBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, isSelected: true, isToday: false),
                  todayBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, isSelected: false, isToday: true),
                  outsideBuilder: (context, day, focusedDay) => _buildDayCell(
                    day,
                    isSelected: false,
                    isToday: false,
                    isOutside: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    required bool isSelected,
    required bool isToday,
    bool isOutside = false,
  }) {
    Color bgColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    BoxBorder? border;

    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = AppColors.white;
    } else if (isToday) {
      border = Border.all(color: AppColors.textPrimary, width: 1);
      textColor = AppColors.textPrimary;
    } else if (isOutside) {
      textColor = AppColors.textMuted.withValues(alpha: 0.5);
    } else {
      bgColor = AppColors.calendarHighlight;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppTypography.titleMedium.copyWith(
          color: textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTodaySection(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${state.selectedDay.day}',
                          style: AppTypography.displayMedium.copyWith(
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '5 Waktu Sholat',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat.EEEE().format(state.selectedDay),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View all',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoading || state is PrayerInitial) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is PrayerError) {
          return SliverFillRemaining(child: Center(child: Text(state.message)));
        } else if (state is PrayerLoaded) {
          final prayers = [
            {
              'name': AppStrings.fajr,
              'time': state.prayerTime.fajr,
              'icon': Icons.nights_stay_rounded,
            },
            {
              'name': AppStrings.sunrise,
              'time': state.prayerTime.sunrise,
              'icon': Icons.wb_sunny_rounded,
            },
            {
              'name': AppStrings.dhuhr,
              'time': state.prayerTime.dhuhr,
              'icon': Icons.wb_sunny_outlined,
            },
            {
              'name': AppStrings.asr,
              'time': state.prayerTime.asr,
              'icon': Icons.wb_twilight_rounded,
            },
            {
              'name': AppStrings.maghrib,
              'time': state.prayerTime.maghrib,
              'icon': Icons.brightness_3_rounded,
            },
            {
              'name': AppStrings.isha,
              'time': state.prayerTime.isha,
              'icon': Icons.star_border_rounded,
            },
          ];

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final prayer = prayers[index];
              final isNext = state.nextPrayerName == prayer['name'];

              return _PrayerCard(
                name: prayer['name'] as String,
                time: prayer['time'] as DateTime,
                icon: prayer['icon'] as IconData,
                isNext: isNext,
              );
            }, childCount: prayers.length),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final DateTime time;
  final IconData icon;
  final bool isNext;

  const _PrayerCard({
    required this.name,
    required this.time,
    required this.icon,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('hh:mm a');
    final formattedTime = format.format(time);

    // Estimate end time approx 45 mins for UI sake
    final formattedEndTime = format.format(
      time.add(const Duration(minutes: 45)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? AppColors.calendarHighlight : AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNext
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: isNext
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$formattedTime - $formattedEndTime',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.toUpperCase(),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.textMuted,
            ),
            onPressed: () {
              // Notification toggle stub
            },
          ),
        ],
      ),
    );
  }
}
