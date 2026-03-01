import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../../core/error/failures.dart';

abstract class ILocationRepository {
  Future<Either<Failure, LocationEntity>> getCurrentLocation(
      {bool forceRefresh = false});
  Future<Either<Failure, LocationEntity>> getCachedLocation();
}
