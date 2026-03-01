import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class DualCalendarCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isFocused;
  final bool isOutside;
  final bool isHijriPrimary;
  final VoidCallback? onTap;

  const DualCalendarCell({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isFocused = false,
    this.isOutside = false,
    this.isHijriPrimary = false,
    this.onTap,
  });

  String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(date);

    Color background = Colors.transparent;
    Color textColor = isOutside ? AppColors.textMuted : AppColors.textPrimary;
    Color hijriColor = isOutside
        ? AppColors.textMuted.withValues(alpha: 0.5)
        : AppColors.textSecondary;

    if (isSelected) {
      background = AppColors.primary;
      textColor = AppColors.white;
      hijriColor = AppColors.white.withValues(alpha: 0.8);
    } else if (isToday) {
      background = AppColors.primary.withValues(alpha: 0.1);
      textColor = AppColors.primary;
      hijriColor = AppColors.primary.withValues(alpha: 0.8);
    }

    final masehiText = '${date.day}';
    final hijriText = _toArabicDigits('${hijri.hDay}');

    final String primaryText = isHijriPrimary ? hijriText : masehiText;
    final String secondaryText = isHijriPrimary ? masehiText : hijriText;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 2.0)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryText,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: isSelected || isToday
                    ? FontWeight.w800
                    : FontWeight.w500,
                height: 1.1,
              ),
            ),
            Text(
              secondaryText,
              style: AppTypography.labelSmall.copyWith(
                color: hijriColor,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
