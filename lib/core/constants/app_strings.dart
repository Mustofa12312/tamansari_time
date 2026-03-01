class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Tamansari Time';
  static const String appTagline = 'Waktu Sholat & Kalender Islam';

  // Prayer Names (Indonesian)
  static const String imsak = 'Imsak';
  static const String fajr = 'Subuh';
  static const String sunrise = 'Syuruq';
  static const String dhuhr = 'Zuhur';
  static const String asr = 'Ashar';
  static const String maghrib = 'Maghrib';
  static const String isha = 'Isya';

  // Prayer Names (Arabic)
  static const String imsakArabic = 'الإمساك';
  static const String fajrArabic = 'الفجر';
  static const String dhuhrArabic = 'الظهر';
  static const String asrArabic = 'العصر';
  static const String maghribArabic = 'المغرب';
  static const String ishaArabic = 'العشاء';

  // Navigation
  static const String navHome = 'Beranda';
  static const String navTasbih = 'Tasbih';
  static const String navDoa = 'Doa';
  static const String navQibla = 'Kiblat';
  static const String navSettings = 'Pengaturan';

  // Home Screen
  static const String nextPrayer = 'Sholat Berikutnya';
  static const String todayPrayers = 'Jadwal Sholat Hari Ini';
  static const String locationError = 'Gagal mendapatkan lokasi';
  static const String locationPermissionDenied = 'Izin lokasi ditolak';
  static const String usingCachedLocation = 'Menggunakan lokasi tersimpan';
  static const String usingDefaultLocation = 'Lokasi: Jakarta (default)';

  // Calendar
  static const String calendar = 'Kalender';
  static const String hijriCalendar = 'Kalender Hijriah';
  static const String gregorianCalendar = 'Kalender Masehi';

  // Settings
  static const String settings = 'Pengaturan';
  static const String calculationMethod = 'Metode Perhitungan';
  static const String prayerAdjustments = 'Penyesuaian Waktu';
  static const String azanSound = 'Suara Azan';
  static const String volume = 'Volume';
  static const String notifications = 'Notifikasi';
  static const String enableNotifications = 'Aktifkan Notifikasi';
  static const String testAzan = 'Tes Azan';
  static const String darkMode = 'Mode Gelap';
  static const String autoTheme = 'Otomatis Ikuti Waktu';
  static const String saveSettings = 'Simpan';
  static const String minutes = 'menit';

  // Calculation Methods
  static const String kemenag = 'Kemenag (Indonesia)';
  static const String mwl = 'MWL';
  static const String isna = 'ISNA';
  static const String egypt = 'Egypt';
  static const String makkah = 'Makkah';
  static const String karachi = 'Karachi';
  static const String tehran = 'Tehran';
  static const String falak = 'Falak (Panyeppen)';

  // Errors
  static const String errorGeneral = 'Terjadi kesalahan';
  static const String errorLocation = 'Gagal mendapatkan lokasi';
  static const String errorPrayerTimes = 'Gagal menghitung waktu sholat';
  static const String retry = 'Coba Lagi';

  // Notifications
  static const String notifChannelId = 'waqtuna_prayer_v1';
  static const String notifChannelName = 'Waktu Sholat';
  static const String notifChannelDesc = 'Notifikasi waktu sholat harian';
  static const String notifTitle = 'Waktu Sholat';
  static const String notifBody = 'Sudah masuk waktu sholat';

  // Hive Box names
  static const String prayerSettingsBox = 'prayer_settings';
  static const String locationBox = 'location_cache';
  static const String prayerTimesBox = 'prayer_times_cache';

  // Hive Keys
  static const String cachedLatKey = 'cached_lat';
  static const String cachedLngKey = 'cached_lng';
  static const String cachedCityKey = 'cached_city';
  static const String methodKey = 'calc_method';
  static const String volumeKey = 'azan_volume';
  static const String notifEnabledKey = 'notif_enabled';
  static const String fajrAdjKey = 'fajr_adj';
  static const String dhuhrAdjKey = 'dhuhr_adj';
  static const String asrAdjKey = 'asr_adj';
  static const String maghribAdjKey = 'maghrib_adj';
  static const String ishaAdjKey = 'isha_adj';
  static const String imsakAdjKey = 'imsak_adj';
  static const String imsakEnabledKey = 'imsak_enabled';
  static const String selectedAdhanKey = 'selected_adhan';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String autoThemeEnabledKey = 'auto_theme_enabled';
}
