// domain/usecases/calculate_live.dart
import 'package:dartz/dartz.dart';

import '../faliures/calculation_faliures.dart';
import '../repositories/calculation_repository.dart';

class CalculateLive {
  final CalculationRepository repository;

  CalculateLive(this.repository);

  Future<Either<Failure, double>> call(String expression) async {
    return await repository.calculateLive(expression);
  }
}

