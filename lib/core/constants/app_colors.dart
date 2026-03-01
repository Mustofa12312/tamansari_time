import 'package:flutter/material.dart';

class ThemeConfig {
  static bool isDark = false;
}

class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────────────────────
  static Color get primary =>
      const Color(0xFF2C3A4B); // Dark Navy from reference
  static Color get primaryLight => const Color(0xFF4A5A75);
  static Color get primaryDark => const Color(0xFF1A2332);
  static Color get accent =>
      ThemeConfig.isDark ? const Color(0xFF38BDF8) : const Color(0xFF2C3A4B);
  static Color get accentDark => const Color(0xFF1E293B);

  // ─── Neutral ──────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static Color get surface =>
      ThemeConfig.isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9);
  static Color get surfaceLight =>
      ThemeConfig.isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get cardDark =>
      ThemeConfig.isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get cardLight =>
      ThemeConfig.isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9);

  static Color get textPrimary =>
      ThemeConfig.isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
  static Color get textSecondary =>
      ThemeConfig.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textMuted =>
      ThemeConfig.isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  static Color get divider =>
      ThemeConfig.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  // ─── Specific UI Element Colors ───────────────────────────────────────────
  static Color get calendarHighlight =>
      const Color(0xFFE8EDF2); // Light blue-gray for unselected days

  // ─── Solar Phase Gradients (Kept for compatibility, muted slightly) ───────
  static List<Color> get fajrGradient => const [
    Color(0xFF1E293B),
    Color(0xFF334155),
    Color(0xFF475569),
  ];
  static List<Color> get sunriseGradient => const [
    Color(0xFFDD6B20),
    Color(0xFFED8936),
    Color(0xFFF6AD55),
  ];
  static List<Color> get dhuhrGradient => const [
    Color(0xFF2B6CB0),
    Color(0xFF3182CE),
    Color(0xFF4299E1),
  ];
  static List<Color> get asrGradient => const [
    Color(0xFFD69E2E),
    Color(0xFFD69E2E),
    Color(0xFFECC94B),
  ];
  static List<Color> get maghribGradient => const [
    Color(0xFFC53030),
    Color(0xFFE53E3E),
    Color(0xFFFC8181),
  ];
  static List<Color> get ishaGradient => const [
    Color(0xFF1A202C),
    Color(0xFF2D3748),
    Color(0xFF4A5568),
  ];

  // ─── Status Colors ────────────────────────────────────────────────────────
  static Color get success => const Color(0xFF10B981);
  static Color get warning => const Color(0xFFF59E0B);
  static Color get error => const Color(0xFFEF4444);
  static Color get info => const Color(0xFF3B82F6);

  // ─── Glass Effect ─────────────────────────────────────────────────────────
  static Color get glassWhite =>
      ThemeConfig.isDark ? const Color(0x1AFFFFFF) : const Color(0x33FFFFFF);
  static Color get glassBorder =>
      ThemeConfig.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000);
  static Color get glassOverlay =>
      ThemeConfig.isDark ? const Color(0x0AFFFFFF) : const Color(0x05000000);
}
