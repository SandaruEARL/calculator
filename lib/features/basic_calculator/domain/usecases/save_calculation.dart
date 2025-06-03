// domain/usecases/save_calculation.dart
import 'package:dartz/dartz.dart';

import '../entities/calculation.dart';
import '../faliures/calculation_faliures.dart';
import '../repositories/calculation_repository.dart';

class SaveCalculation {
  final CalculationRepository repository;

  SaveCalculation(this.repository);

  Future<Either<Failure, void>> call(Calculation calculation) async {
    return await repository.saveCalculation(calculation);
  }
}
