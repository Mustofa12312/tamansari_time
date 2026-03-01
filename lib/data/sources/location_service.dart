import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import '../models/location_model.dart';
import '../../core/constants/app_strings.dart';

/// Multi-strategy location service:
/// 1. GPS getCurrentPosition
/// 2. getLastKnownPosition
/// 3. Hive cached coordinates
/// 4. Jakarta default (emergency fallback)
class LocationService {
  Future<LocationModel> getCurrentLocation({bool forceRefresh = false}) async {
    // If not forcing refresh, try to read from Hive cache first
    if (!forceRefresh) {
      final cached = _getCachedLocation();
      if (cached != null) return cached;
    }

    // Step 1: Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return _getCachedOrDefault();
    }

    // Step 2: Try GPS with timeout
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      final model = await _positionToModel(position);
      _cacheLocation(model);
      return model;
    } catch (_) {
      // Step 3: Try last known position
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          final model = await _positionToModel(last);
          _cacheLocation(model);
          return model;
        }
      } catch (_) {}

      // Step 4: Read from Hive cache
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
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isNotEmpty) {
        city = placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            '';
        country = placemarks.first.country ?? 'Indonesia';
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
