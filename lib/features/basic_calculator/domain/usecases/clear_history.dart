// domain/usecases/clear_history.dart
import 'package:dartz/dartz.dart';
import '../faliures/calculation_faliures.dart';
import '../repositories/calculation_repository.dart';

class ClearHistory {
  final CalculationRepository repository;

  ClearHistory(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearHistory();
  }
}