// data/repositories/calculation_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/calculation.dart';
import '../../domain/faliures/calculation_faliures.dart';
import '../../domain/repositories/calculation_repository.dart';
import '../../domain/services/expresion_evaluator.dart';
import '../datasources/calculation_local_datasource.dart';
import '../models/calculation_model.dart';

class CalculationRepositoryImpl implements CalculationRepository {
  final CalculationLocalDataSource localDataSource;
  final ExpressionEvaluator evaluator;

  CalculationRepositoryImpl({
    required this.localDataSource,
    required this.evaluator,
  });

  @override
  Future<Either<Failure, double>> calculate(String expression) async {
    try {
      final result = await evaluator.evaluate(expression);
      if (result.isInfinite || result.isNaN) {
        return Left(DivisionByZeroFailure());
      }
      return Right(result);
    } catch (e) {
      return Left(InvalidExpressionFailure());
    }
  }

  @override
  Future<Either<Failure, List<Calculation>>> getCalculationHistory() async {
    try {
      final calculations = await localDataSource.getCalculationHistory();
      return Right(calculations);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateLive(String expression) async {
    try {
      final result = await evaluator.evaluate(expression);
      if (result.isInfinite || result.isNaN) {
        return Left(DivisionByZeroFailure());
      }
      return Right(result);
    } catch (e) {
      return Left(InvalidExpressionFailure());
    }
  }


  @override
  Future<Either<Failure, void>> saveCalculation(Calculation calculation) async {
    try {
      final model = CalculationModel.fromEntity(calculation);
      await localDataSource.saveCalculation(model);
      return Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }




}
