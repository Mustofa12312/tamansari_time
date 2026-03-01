import 'package:equatable/equatable.dart';

/// Immutable entity representing GPS coordinates and city name.
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.city = '',
    this.country = 'Indonesia',
  });

  /// Default fallback: Jakarta
  static const LocationEntity defaultJakarta = LocationEntity(
    latitude: -6.2088,
    longitude: 106.8456,
    city: 'Jakarta',
    country: 'Indonesia',
  );

  @override
  List<Object?> get props => [latitude, longitude, city, country];
}
