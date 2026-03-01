import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../blocs/prayer/prayer_bloc.dart';
import '../../blocs/prayer/prayer_event.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh timer every second to force UI update for countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            BlocBuilder<PrayerBloc, PrayerState>(
              builder: (context, state) {
                String city = 'Mencari lokasi...';
                if (state is PrayerLoaded) {
                  city = state.location.city.isNotEmpty
                      ? state.location.city
                      : 'Jakarta, Indonesia';
                }
                return Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<PrayerBloc>().add(
              const LoadPrayerTimes(forceLocationRefresh: true),
            );
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildHeroCountdown(context),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              _buildPrayerList(context),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40), // Bottom padding
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCountdown(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<PrayerBloc, PrayerState>(
          builder: (context, state) {
            if (state is! PrayerLoaded) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final nextPrayer = state.nextPrayerName;
            final timeUntil = state.timeUntilNext;
            final prayerInfo = _getPrayerData(state, nextPrayer);
            final nextPrayerTimeStr =
                prayerInfo['timeStr'] as String? ?? '--:--';

            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat(
                            'EEEE, d MMMM',
                            'id',
                          ).format(DateTime.now()),
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Menuju ${nextPrayer.toUpperCase()}',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatDuration(timeUntil),
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 48,
                          height: 1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        nextPrayerTimeStr,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Map<String, dynamic> _getPrayerData(PrayerLoaded state, String prayerName) {
    final format = DateFormat('HH:mm');
    switch (prayerName) {
      case AppStrings.imsak:
        return {'timeStr': format.format(state.prayerTime.imsak)};
      case AppStrings.fajr:
        return {'timeStr': format.format(state.prayerTime.fajr)};
      case AppStrings.sunrise:
        return {'timeStr': format.format(state.prayerTime.sunrise)};
      case AppStrings.dhuhr:
        return {'timeStr': format.format(state.prayerTime.dhuhr)};
      case AppStrings.asr:
        return {'timeStr': format.format(state.prayerTime.asr)};
      case AppStrings.maghrib:
        return {'timeStr': format.format(state.prayerTime.maghrib)};
      case AppStrings.isha:
        return {'timeStr': format.format(state.prayerTime.isha)};
      default:
        return {'timeStr': '--:--'};
    }
  }

  bool _isCurrentPrayer(PrayerLoaded state, String prayerName) {
    return state.currentPrayerName == prayerName;
  }

  Widget _buildPrayerList(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoaded) {
          final prayers = [
            {
              'name': AppStrings.imsak,
              'time': state.prayerTime.imsak,
              'icon': Icons.nights_stay_outlined,
            },
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
              final isCurrent = _isCurrentPrayer(
                state,
                prayer['name'] as String,
              );

              return _PrayerCard(
                name: prayer['name'] as String,
                time: prayer['time'] as DateTime,
                icon: prayer['icon'] as IconData,
                isNext: isNext,
                isCurrent: isCurrent,
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
  final bool isCurrent;

  const _PrayerCard({
    required this.name,
    required this.time,
    required this.icon,
    this.isNext = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('HH:mm');
    final formattedTime = format.format(time);

    final highlight = isNext || isCurrent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.calendarHighlight : AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: highlight
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: highlight ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                    color: highlight
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                if (highlight) ...[
                  const SizedBox(height: 2),
                  Text(
                    isNext ? 'Waktu berikutnya' : 'Waktu saat ini',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formattedTime,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
