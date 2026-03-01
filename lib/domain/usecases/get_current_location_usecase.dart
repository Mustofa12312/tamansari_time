import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../repositories/i_location_repository.dart';
import '../../core/error/failures.dart';

class GetCurrentLocationUseCase {
  final ILocationRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<Either<Failure, LocationEntity>> call({bool forceRefresh = false}) {
    return _repository.getCurrentLocation(forceRefresh: forceRefresh);
  }
}
