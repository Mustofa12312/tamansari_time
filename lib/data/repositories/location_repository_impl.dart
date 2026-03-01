import 'package:dartz/dartz.dart';
import '../models/location_model.dart';
import '../sources/location_service.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/i_location_repository.dart';
import '../../core/error/failures.dart';

class LocationRepositoryImpl implements ILocationRepository {
  final LocationService _locationService;

  LocationRepositoryImpl(this._locationService);

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation(
      {bool forceRefresh = false}) async {
    try {
      final location =
          await _locationService.getCurrentLocation(forceRefresh: forceRefresh);
      return Right(location);
    } catch (e) {
      return Left(LocationFailure('Gagal mendapatkan lokasi: $e'));
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> getCachedLocation() async {
    try {
      final location = await _locationService.getCachedLocation();
      return Right(location);
    } catch (e) {
      return const Right(LocationModel.defaultJakarta);
    }
  }
}
