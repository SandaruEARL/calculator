// domain/usecases/get_calculation_history.dart
import 'package:dartz/dartz.dart';
import '../entities/calculation.dart';
import '../faliures/calculation_faliures.dart';
import '../repositories/calculation_repository.dart';

class GetCalculationHistory {
  final CalculationRepository repository;

  GetCalculationHistory(this.repository);

  Future<Either<Failure, List<Calculation>>> call() async {
    return await repository.getCalculationHistory();
  }
}