import '../../domain/entities/location.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.city,
    super.country,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? 'Indonesia',
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'country': country,
  };

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      city: entity.city,
      country: entity.country,
    );
  }

  static const LocationModel defaultJakarta = LocationModel(
    latitude: -6.2088,
    longitude: 106.8456,
    city: 'Jakarta',
    country: 'Indonesia',
  );
}
