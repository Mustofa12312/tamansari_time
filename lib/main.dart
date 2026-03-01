import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/calendar/calendar_cubit.dart';
import 'presentation/blocs/prayer/prayer_bloc.dart';
import 'presentation/blocs/prayer/prayer_event.dart';
import 'presentation/blocs/settings/settings_cubit.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'domain/entities/prayer_settings.dart';

Future<void> main() async {
  // Catch any Flutter framework errors before they silently crash the app
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Locale init for Indonesian dates
  try {
    await initializeDateFormatting('id', null);
  } catch (_) {}

  // Hive init — jika gagal, app tetap bisa jalan dengan data default
  try {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(AppStrings.prayerSettingsBox);
    await Hive.openBox<dynamic>(AppStrings.locationBox);
    await Hive.openBox<dynamic>(AppStrings.prayerTimesBox);
  } catch (_) {}

  // DI
  try {
    await configureDependencies();
  } catch (_) {}

  // Notifications — tidak boleh crash jika izin belum diberikan
  try {
    final notifService = getIt<NotificationService>();
    await notifService.initialize();
  } catch (_) {}

  // Background service — opsional, jangan blokir launch
  try {
    final bgService = getIt<BackgroundService>();
    bgService.scheduleMidnightRefresh(); // sengaja tidak di-await
  } catch (_) {}

  runApp(const TamansariApp());
}

class TamansariApp extends StatelessWidget {
  const TamansariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PrayerBloc>(
          create: (_) => getIt<PrayerBloc>()..add(const LoadPrayerTimes()),
        ),
        BlocProvider<CalendarCubit>(create: (_) => getIt<CalendarCubit>()),
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, PrayerSettings>(
        builder: (context, settings) {
          // Automatic theme switching based on time logic
          bool currentDarkState = settings.isDarkMode;
          if (settings.autoThemeEnabled) {
            final now = DateTime.now();
            final isNight = now.hour < 5 || now.hour >= 18;
            currentDarkState = isNight;
          }
          ThemeConfig.isDark = currentDarkState;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: currentDarkState
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: AppColors.surface,
              systemNavigationBarIconBrightness: currentDarkState
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );

          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
