import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import '../../blocs/prayer/prayer_bloc.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_strings.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _lastHeading = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppStrings.navQibla,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: BlocBuilder<PrayerBloc, PrayerState>(
          builder: (context, state) {
            if (state is! PrayerLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.textPrimary),
              );
            }

            final lat = state.location.latitude;
            final lng = state.location.longitude;
            final qiblaDirection = Qibla(Coordinates(lat, lng)).direction;

            return StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState('Sensor Kompas bermasalah');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                    ),
                  );
                }

                double? heading = snapshot.data?.heading;
                if (heading == null) {
                  return _buildErrorState(
                    'Perangkat ini tidak mendukung fitur kompas',
                  );
                }

                // Normalizing heading for smooth rotation
                double diff = heading - _lastHeading;
                if (diff.abs() > 180) {
                  if (heading > _lastHeading) {
                    _lastHeading += 360;
                  } else {
                    _lastHeading -= 360;
                  }
                }
                _lastHeading = heading;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildDirectionInfo(qiblaDirection, heading),
                    const SizedBox(height: 48),
                    _buildCompassUI(heading, qiblaDirection),
                    const Spacer(),
                    _buildLocationFooter(state.location.city),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDirectionInfo(double qibla, double heading) {
    // Determine if aligned with Qibla (tolerance 3 degrees)
    bool isAligned =
        (heading - qibla).abs() < 3 || (heading - qibla).abs() > 357;

    return Column(
      children: [
        Text(
          '${qibla.toStringAsFixed(0)}°',
          style: AppTypography.displayLarge.copyWith(
            color: isAligned
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.6),
            fontSize: 80,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: isAligned
                ? AppColors.textPrimary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isAligned
                  ? AppColors.textPrimary
                  : AppColors.textPrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            isAligned ? 'POSISI TEPAT' : 'PUTAR PERANGKAT',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompassUI(double heading, double qibla) {
    final compassAngle = -heading * (math.pi / 180);
    final qiblaAngle = (qibla - heading) * (math.pi / 180);

    return Center(
      child: Container(
        height: 340,
        width: 340,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textPrimary.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Dial
            Transform.rotate(
              angle: compassAngle,
              child: Stack(
                alignment: Alignment.center,
                children: [_buildDialMarks(), _buildCardinalPoints()],
              ),
            ),

            // Fixed Pointer (Current Direction)
            Container(
              height: 200,
              width: 2,
              color: AppColors.textPrimary.withValues(alpha: 0.4),
            ),

            // Qibla Needle
            Transform.rotate(angle: qiblaAngle, child: _buildQiblaNeedle()),

            // Center Pin
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textPrimary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialMarks() {
    return Stack(
      children: List.generate(72, (i) {
        return Transform.rotate(
          angle: (i * 5) * (math.pi / 180),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              width: i % 2 == 0 ? 2 : 1,
              height: i % 18 == 0 ? 15 : (i % 2 == 0 ? 10 : 5),
              color: i % 18 == 0
                  ? AppColors.textPrimary
                  : AppColors.textPrimary.withValues(alpha: 0.4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardinalPoints() {
    return Stack(
      children: [
        _cardinalText('U', Alignment.topCenter, AppColors.textPrimary),
        _cardinalText(
          'S',
          Alignment.bottomCenter,
          AppColors.textPrimary.withValues(alpha: 0.8),
        ),
        _cardinalText(
          'T',
          Alignment.centerRight,
          AppColors.textPrimary.withValues(alpha: 0.8),
        ),
        _cardinalText(
          'B',
          Alignment.centerLeft,
          AppColors.textPrimary.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _cardinalText(String text, Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildQiblaNeedle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_rounded, color: AppColors.textPrimary, size: 44),
        Container(
          height: 120,
          width: 6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.textPrimary,
                AppColors.textPrimary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 120), // Balance
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_off_rounded,
              size: 80,
              color: AppColors.textPrimary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFooter(String city) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_rounded,
            size: 18,
            color: AppColors.textPrimary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            city,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
