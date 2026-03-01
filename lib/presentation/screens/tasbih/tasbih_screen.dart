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

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
    HapticFeedback.lightImpact();
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppStrings.navTasbih, style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTap: _increment,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardDark,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.white.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_count',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 72,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reset,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset'),
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.primary,
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
