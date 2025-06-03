import 'package:math_expressions/math_expressions.dart';

class ExpressionEvaluator {
  // Simple expression evaluator (percentage conversion now handled by ViewModel)
  double _evaluateExpression(String expression) {
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
    // No percentage preprocessing needed here anymore

    final parser = Parser();
    final exp = parser.parse(expression);
    final contextModel = ContextModel();
    final eval = exp.evaluate(EvaluationType.REAL, contextModel);

    return eval;
  }

  // this public method to call _evaluateExpression
  double evaluate(String expression) {
    return _evaluateExpression(expression);
  }
}