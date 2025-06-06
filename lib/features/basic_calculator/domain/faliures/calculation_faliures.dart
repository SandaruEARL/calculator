// domain/failures/calculation_failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DivisionByZeroFailure extends Failure {
  const DivisionByZeroFailure() : super('ERROR');
}

class InvalidExpressionFailure extends Failure {
  const InvalidExpressionFailure() : super('ERROR');
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
