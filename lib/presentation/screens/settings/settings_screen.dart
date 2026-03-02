import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../../domain/entities/prayer_settings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.settings,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, PrayerSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionTitle(AppStrings.darkMode),
              _buildSettingCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Mode Gelap',
                      subtitle: 'Gunakan tema gelap di seluruh aplikasi',
                      value: settings.isDarkMode,
                      onChanged: (val) =>
                          context.read<SettingsCubit>().setDarkMode(val),
                      icon: Icons.dark_mode_rounded,
                    ),
                    Divider(
                      color: AppColors.textPrimary.withValues(alpha: 0.1),
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildSwitchTile(
                      title: 'Otomatis',
                      subtitle: 'Ikuti waktu matahari (Malam = Gelap)',
                      value: settings.autoThemeEnabled,
                      onChanged: (val) => context
                          .read<SettingsCubit>()
                          .setAutoThemeEnabled(val),
                      icon: Icons.auto_mode_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.calculationMethod),
              _buildSettingCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Icon(
                    Icons.calculate_rounded,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(
                    _getMethodName(settings.method),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Metode perhitungan waktu shalat',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  onTap: () => _showMethodPicker(context, settings),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.notifications),
              _buildSettingCard(
                child: _buildSwitchTile(
                  title: AppStrings.enableNotifications,
                  subtitle: 'Aktifkan suara adhan & notifikasi',
                  value: settings.notificationsEnabled,
                  onChanged: (val) =>
                      context.read<SettingsCubit>().toggleNotifications(val),
                  icon: Icons.notifications_active_rounded,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.prayerAdjustments),
              _buildSettingCard(
                child: Column(
                  children: [
                    _buildAdjustmentTile(
                      context,
                      'Imsak',
                      settings.imsakAdjustment,
                      (val) =>
                          context.read<SettingsCubit>().setImsakAdjustment(val),
                      Icons.timer_outlined,
                    ),
                    _buildAdjustmentTile(
                      context,
                      'Subuh',
                      settings.fajrAdjustment,
                      (val) =>
                          context.read<SettingsCubit>().setFajrAdjustment(val),
                      Icons.nights_stay_rounded,
                    ),
                    _buildAdjustmentTile(
                      context,
                      'Dzuhur',
                      settings.dhuhrAdjustment,
                      (val) =>
                          context.read<SettingsCubit>().setDhuhrAdjustment(val),
                      Icons.wb_sunny_rounded,
                    ),
                    _buildAdjustmentTile(
                      context,
                      'Ashar',
                      settings.asrAdjustment,
                      (val) =>
                          context.read<SettingsCubit>().setAsrAdjustment(val),
                      Icons.wb_twilight_rounded,
                    ),
                    _buildAdjustmentTile(
                      context,
                      'Maghrib',
                      settings.maghribAdjustment,
                      (val) => context
                          .read<SettingsCubit>()
                          .setMaghribAdjustment(val),
                      Icons.brightness_3_rounded,
                    ),
                    _buildAdjustmentTile(
                      context,
                      'Isya',
                      settings.ishaAdjustment,
                      (val) =>
                          context.read<SettingsCubit>().setIshaAdjustment(val),
                      Icons.star_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => _confirmReset(context),
                child: Text(
                  'Kembali ke Pengaturan Default',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.7),
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(28), child: child),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: (val) {
        HapticFeedback.selectionClick();
        onChanged(val);
      },
      secondary: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.6),
        ),
      ),
      activeThumbColor: AppColors.accent,
      activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
    );
  }

  Widget _buildAdjustmentTile(
    BuildContext context,
    String name,
    int currentValue,
    Function(int) onUpdate,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary.withValues(alpha: 0.5),
        size: 20,
      ),
      title: Text(
        name,
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: AppColors.textPrimary.withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onUpdate(currentValue - 1);
            },
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${currentValue > 0 ? "+" : ""}$currentValue',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: currentValue != 0
                    ? AppColors.accent
                    : AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onUpdate(currentValue + 1);
            },
          ),
        ],
      ),
    );
  }

  String _getMethodName(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.kemenag:
        return AppStrings.kemenag;
      case PrayerCalculationMethod.mwl:
        return AppStrings.mwl;
      case PrayerCalculationMethod.isna:
        return AppStrings.isna;
      case PrayerCalculationMethod.egypt:
        return AppStrings.egypt;
      case PrayerCalculationMethod.makkah:
        return AppStrings.makkah;
      case PrayerCalculationMethod.karachi:
        return AppStrings.karachi;
      case PrayerCalculationMethod.tehran:
        return AppStrings.tehran;
      case PrayerCalculationMethod.falak:
        return AppStrings.falak;
      default:
        return 'Default';
    }
  }

  void _showMethodPicker(BuildContext context, PrayerSettings settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Metode Perhitungan',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: PrayerCalculationMethod.values.length,
                  itemBuilder: (context, index) {
                    final method = PrayerCalculationMethod.values[index];
                    final isSelected = settings.method == method;
                    return ListTile(
                      title: Text(
                        _getMethodName(method),
                        style: AppTypography.titleMedium.copyWith(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.accent,
                            )
                          : null,
                      onTap: () {
                        context.read<SettingsCubit>().setMethod(method);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan?'),
        content: const Text(
          'Semua perubahan akan dikembalikan ke setelan pabrik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().resetToDefaults();
              Navigator.pop(context);
            },
            child: Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
