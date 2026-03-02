import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import '../models/location_model.dart';
import '../../core/constants/app_strings.dart';

/// Multi-strategy location service:
/// 1. If not forceRefresh → return cached location (or Jakarta default)
/// 2. If forceRefresh or no cache → check/request permission, get GPS
/// 3. On permission denied/timeout → try last known position
/// 4. Final fallback: cached Hive data or Jakarta default
class LocationService {
  /// Get location.
  /// - [forceRefresh] = false → return cached/default immediately (fast startup)
  /// - [forceRefresh] = true  → request GPS (triggered by user pressing GPS btn)
  Future<LocationModel> getCurrentLocation({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Try cache first for instant startup
      final cached = _getCachedLocation();
      if (cached != null) return cached;

      // No cache yet — try GPS silently (permission may already be granted)
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          // Permission already granted, get GPS quietly
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 8),
          );
          final model = await _positionToModel(position);
          _cacheLocation(model);
          return model;
        }
      } catch (_) {
        // Silent fail — return default below
      }

      return LocationModel.defaultJakarta;
    }

    // ── Force Refresh: User explicitly tapped GPS button ──────────────────
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied, open settings
      await Geolocator.openAppSettings();
      return _getCachedOrDefault();
    }

    if (permission == LocationPermission.denied) {
      return _getCachedOrDefault();
    }

    // Permission granted — get accurate position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
      final model = await _positionToModel(position);
      _cacheLocation(model);
      return model;
    } catch (_) {
      // Fallback: try last known position
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          final model = await _positionToModel(last);
          _cacheLocation(model);
          return model;
        }
      } catch (_) {}

      return _getCachedOrDefault();
    }
  }

  Future<LocationModel> _positionToModel(Position position) async {
    String city = '';
    String country = 'Indonesia';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 6));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city =
            p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
        country = p.country ?? 'Indonesia';
      }
    } catch (_) {}

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      country: country,
    );
  }

  LocationModel _getCachedOrDefault() {
    return _getCachedLocation() ?? LocationModel.defaultJakarta;
  }

  LocationModel? _getCachedLocation() {
    try {
      final box = Hive.box(AppStrings.locationBox);
      final lat = box.get(AppStrings.cachedLatKey) as double?;
      final lng = box.get(AppStrings.cachedLngKey) as double?;
      final city = box.get(AppStrings.cachedCityKey) as String? ?? '';
      if (lat != null && lng != null) {
        return LocationModel(
          latitude: lat,
          longitude: lng,
          city: city,
          country: 'Indonesia',
        );
      }
    } catch (_) {}
    return null;
  }

  Future<LocationModel> getCachedLocation() async {
    return _getCachedOrDefault();
  }

  void _cacheLocation(LocationModel model) {
    try {
      final box = Hive.box(AppStrings.locationBox);
      box.put(AppStrings.cachedLatKey, model.latitude);
      box.put(AppStrings.cachedLngKey, model.longitude);
      box.put(AppStrings.cachedCityKey, model.city);
    } catch (_) {}
  }
}
