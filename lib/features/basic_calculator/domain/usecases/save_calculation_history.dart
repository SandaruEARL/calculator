// features/basic_calculator/domain/usecases/save_calculation_history.dart
import 'package:dartz/dartz.dart';

import '../entities/calculation.dart';
import '../faliures/calculation_faliures.dart';
import '../repositories/calculation_repository.dart';

class SaveCalculationHistory {
  
  final CalculationRepository repository;

  SaveCalculationHistory(this.repository);

  Future<Either<Failure, void>> call(Calculation calculation) async {
    return await repository.saveCalculation(calculation);
  }

}