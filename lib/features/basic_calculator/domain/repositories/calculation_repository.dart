// domain/repositories/calculation_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/calculation.dart';
import '../faliures/calculation_faliures.dart';
abstract class CalculationRepository {

  Future<Either<Failure, double>> calculate(String expression);
  Future<Either<Failure, List<Calculation>>> getCalculationHistory();
  Future<Either<Failure, void>> saveCalculation(Calculation calculation);
  Future<Either<Failure, void>> clearHistory();
  Future<Either<Failure, double>> calculateLive(String expression);

}