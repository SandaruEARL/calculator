// domain/failures/calculation_failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DivisionByZeroFailure extends Failure {
  const DivisionByZeroFailure() : super('Division by zero is not allowed');
}

class InvalidExpressionFailure extends Failure {
  const InvalidExpressionFailure() : super('Invalid mathematical expression');
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
