import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_strings.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
    });
    HapticFeedback.heavyImpact();
    _controller.forward().then((_) => _controller.reverse());
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppStrings.navTasbih,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Counter Display
              Column(
                children: [
                  Text(
                    'SubhanAllah / Alhamdulillah',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_count',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Interaction Button
              Center(
                child: GestureDetector(
                  onTapDown: (_) => _increment(),
                  child: ScaleTransition(
                    scale: _animation,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textPrimary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.textPrimary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 40,
                            spreadRadius: 5,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.textPrimary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.textPrimary,
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Reset Button
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset Counter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(
                      color: AppColors.textPrimary.withValues(alpha: 0.3),
                    ),
                    backgroundColor: AppColors.textPrimary.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
