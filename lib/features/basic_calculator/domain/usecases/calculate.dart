// domain/usecases/calculate.dart
import 'package:dartz/dartz.dart';

import '../faliures/calculation_faliures.dart';
import '../repositories/calculation_repository.dart';

class Calculate {
  final CalculationRepository repository;

  Calculate(this.repository);

  Future<Either<Failure, double>> call(String expression) async {
    return await repository.calculate(expression);
  }
}