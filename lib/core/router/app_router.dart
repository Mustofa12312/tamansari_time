import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/settings/settings_cubit.dart';
import '../../domain/entities/prayer_settings.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/tasbih/tasbih_screen.dart';
import '../../presentation/screens/doa/doa_screen.dart';
import '../../presentation/screens/qibla/qibla_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/qibla',
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: '/tasbih',
            builder: (context, state) => const TasbihScreen(),
          ),
          GoRoute(path: '/doa', builder: (context, state) => const DoaScreen()),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final Widget child;

  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final location = GoRouterState.of(context).uri.toString();
        int currentIndex = 0;
        if (location.startsWith('/home')) currentIndex = 0;
        if (location.startsWith('/qibla')) currentIndex = 1;
        if (location.startsWith('/tasbih')) currentIndex = 2;
        if (location.startsWith('/doa')) currentIndex = 3;
        if (location.startsWith('/settings')) currentIndex = 4;

        return BlocBuilder<SettingsCubit, PrayerSettings>(
          builder: (context, _) => Scaffold(
            body: child,
            bottomNavigationBar: _buildBottomNav(context, currentIndex),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: AppStrings.navHome,
                isActive: currentIndex == 0,
                onTap: () => context.go('/home'),
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: AppStrings.navQibla,
                isActive: currentIndex == 1,
                onTap: () => context.go('/qibla'),
              ),
              _NavItem(
                icon: Icons.fingerprint_rounded,
                label: AppStrings.navTasbih,
                isActive: currentIndex == 2,
                onTap: () => context.go('/tasbih'),
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: AppStrings.navDoa,
                isActive: currentIndex == 3,
                onTap: () => context.go('/doa'),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: AppStrings.navSettings,
                isActive: currentIndex == 4,
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive
              ? AppColors.accent.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? AppColors.accent : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.accent : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
