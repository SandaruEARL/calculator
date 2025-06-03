import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class ExpressionEvaluator {
  // Simple expression evaluator with pow function support
  static double _evaluateExpression(String expression) {
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    final parser = Parser();

    print(expression);

    final exp = parser.parse(expression);

    final contextModel = ContextModel();
    final eval = exp.evaluate(EvaluationType.REAL, contextModel);
    print(eval);

    return eval;
  }

  // Public method to call _evaluateExpression
  double evaluate(String expression) {
    return _evaluateExpression(expression);
  }
}
