import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class ExpressionUtils {
  // Mathematical constants
  static const double goldenRatio = 1.618033988749895;
  static const double eulerNumber = 2.718281828459045;

  static String _convertPercentageForCalculation(String expression) {
    // Convert percentage symbols to /100 for calculation
    // Handle multiple patterns:
    // 1. number% -> number/100
    // 2. )% -> )/100 (for expressions like (45*5)%)
    return expression.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?|\))\s*%'),
          (match) {
        final beforePercent = match[1]!;
        if (beforePercent == ')') {
          return '$beforePercent/100';
        } else {
          return '$beforePercent/100';
        }
      },
    );
  }

  static String _convertConstantsForCalculation(String expression) {
    // Replace mathematical constants with their numerical values
    String converted = expression;

    // Replace π with its value
    converted = converted.replaceAll('π', math.pi.toString());

    // Replace e with its value
    converted = converted.replaceAll('e', eulerNumber.toString());

    // Replace φ (golden ratio) with its value
    converted = converted.replaceAll('φ', goldenRatio.toString());

    return converted;
  }

  static String _convertScientificFunctionsForCalculation(String expression) {
    String converted = expression;

    // Convert trigonometric functions
    converted = converted.replaceAllMapped(
      RegExp(r'sin\(([^)]+)\)'),
          (match) {
        final angle = match.group(1)!;
        return 'sin($angle)';
      },
    );

    converted = converted.replaceAllMapped(
      RegExp(r'cos\(([^)]+)\)'),
          (match) {
        final angle = match.group(1)!;
        return 'cos($angle)';
      },
    );

    converted = converted.replaceAllMapped(
      RegExp(r'tan\(([^)]+)\)'),
          (match) {
        final angle = match.group(1)!;
        return 'tan($angle)';
      },
    );

    // Convert logarithmic functions
    converted = converted.replaceAllMapped(
      RegExp(r'ln\(([^)]+)\)'),
          (match) {
        final value = match.group(1)!;
        return 'ln($value)';
      },
    );

    converted = converted.replaceAllMapped(
      RegExp(r'log\(([^)]+)\)'),
          (match) {
        final value = match.group(1)!;
        return 'log($value)';
      },
    );

    // Convert square root
    converted = converted.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
          (match) {
        final value = match.group(1)!;
        return 'sqrt($value)';
      },
    );

    // Convert cube root
    converted = converted.replaceAllMapped(
      RegExp(r'cbrt\(([^)]+)\)'),
          (match) {
        final value = match.group(1)!;
        return 'cbrt($value)';
      },
    );

    return converted;
  }

  static String _convertFactorialForCalculation(String expression) {
    // Convert factorial notation (n!) to factorial function call
    return expression.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?|\))\s*!'),
          (match) {
        final number = match.group(1)!;
        return 'factorial($number)';
      },
    );
  }

  static String _convertPowerForCalculation(String expression) {
    // Convert power notation (a^b) to pow function call
    return expression.replaceAllMapped(
      RegExp(r'([^+\-*/()^]+)\s*\^\s*([^+\-*/()^]+)'),
          (match) {
        final base = match.group(1)!;
        final exponent = match.group(2)!;
        return 'pow($base,$exponent)';
      },
    );
  }

  static String fixIncompleteExpression(String expr) {
    // Apply all conversions in order
    expr = _convertPercentageForCalculation(expr);
    expr = _convertConstantsForCalculation(expr);
    expr = _convertScientificFunctionsForCalculation(expr);
    expr = _convertFactorialForCalculation(expr);
    expr = _convertPowerForCalculation(expr);

    // 1. Balance parentheses
    int openCount = '('.allMatches(expr).length;
    int closeCount = ')'.allMatches(expr).length;
    int unclosed = openCount - closeCount;

    String fixedExpr = expr;

    // Add missing closing parentheses at the end
    for (int i = 0; i < unclosed; i++) {
      fixedExpr += ')';
    }

    // 2. Remove trailing operators (except closing parenthesis and digits)
    while (fixedExpr.isNotEmpty) {
      final lastChar = fixedExpr.characters.last;
      if (RegExp(r'[\+\-\*/%\^]').hasMatch(lastChar)) {
        fixedExpr = fixedExpr.substring(0, fixedExpr.length - 1);
      } else {
        break;
      }
    }

    // 3. Fix consecutive operators inside expression
    // Handle patterns more carefully to avoid breaking valid negative numbers

    // First pass: Handle obvious consecutive operator duplicates
    fixedExpr = fixedExpr.replaceAllMapped(
      RegExp(r'([\+\*/%\^]){2,}'),
          (match) => match.group(1)!,
    );

    // Second pass: Handle operator combinations more intelligently
    fixedExpr = fixedExpr.replaceAllMapped(
      RegExp(r'([\+\-\*/%\^])([\+\*/%\^])'),
          (match) {
        final first = match.group(1)!;
        final second = match.group(2)!;

        // Keep the second operator (last one wins)
        return second;
      },
    );

    // Third pass: Handle minus signs more carefully
    // Pattern like *-- or +-- should become *- or +-
    fixedExpr = fixedExpr.replaceAllMapped(
      RegExp(r'([\+\-\*/%\^])(\-{2,})'),
          (match) {
        final operator = match.group(1)!;
        return '$operator-';
      },
    );

    // Fourth pass: Clean up any remaining invalid patterns
    // Remove patterns like */ or +* etc., keeping the last operator
    fixedExpr = fixedExpr.replaceAllMapped(
      RegExp(r'([\*/%\^])([\+\-])'),
          (match) {
        final first = match.group(1)!;
        final second = match.group(2)!;
        // If it's multiplication/division/power followed by +/-, keep both for negative numbers
        return '$first$second';
      },
    );

    return fixedExpr;
  }

  /// Helper method to validate if an expression is mathematically valid
  static bool isValidExpression(String expression) {
    try {
      final fixed = fixIncompleteExpression(expression);

      // Basic validation checks
      if (fixed.isEmpty) return false;

      // Check for balanced parentheses
      int openCount = '('.allMatches(fixed).length;
      int closeCount = ')'.allMatches(fixed).length;
      if (openCount != closeCount) return false;

      // Check that expression doesn't start or end with invalid operators
      final firstChar = fixed.characters.first;
      final lastChar = fixed.characters.last;

      if (RegExp(r'[\+\*/%\^]').hasMatch(firstChar)) return false;
      if (RegExp(r'[\+\-\*/%\^]').hasMatch(lastChar)) return false;

      // Check for valid function calls
      if (!_hasValidFunctionCalls(fixed)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _hasValidFunctionCalls(String expression) {
    // Check if all function calls have proper syntax
    final functionPattern = RegExp(r'(sin|cos|tan|ln|log|sqrt|cbrt|factorial|pow)\s*\(');
    final matches = functionPattern.allMatches(expression);

    for (final match in matches) {
      final functionName = match.group(1)!;
      final startIndex = match.end;

      // Check if the function call is properly closed
      int parenCount = 1;
      int currentIndex = startIndex;

      while (currentIndex < expression.length && parenCount > 0) {
        final char = expression[currentIndex];
        if (char == '(') parenCount++;
        if (char == ')') parenCount--;
        currentIndex++;
      }

      if (parenCount != 0) return false;

      // Special validation for pow function (should have 2 parameters)
      if (functionName == 'pow') {
        final content = expression.substring(startIndex, currentIndex - 1);
        final commaCount = ','.allMatches(content).length;
        if (commaCount != 1) return false;
      }
    }

    return true;
  }

  /// Convert degrees to radians for trigonometric functions
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// Calculate factorial
  static double factorial(double n) {
    if (n < 0 || n != n.floor()) {
      throw ArgumentError('Factorial is only defined for non-negative integers');
    }

    if (n == 0 || n == 1) return 1;

    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Calculate cube root
  static num cubeRoot(double value) {
    if (value < 0) {
      return -math.pow(-value, 1/3);
    }
    return math.pow(value, 1/3).toDouble();
  }

  /// Debug method to show step-by-step conversion
  static Map<String, String> debugConversion(String expression) {
    return {
      'original': expression,
      'after_percentage': _convertPercentageForCalculation(expression),
      'after_constants': _convertConstantsForCalculation(_convertPercentageForCalculation(expression)),
      'after_functions': _convertScientificFunctionsForCalculation(_convertConstantsForCalculation(_convertPercentageForCalculation(expression))),
      'after_factorial': _convertFactorialForCalculation(_convertScientificFunctionsForCalculation(_convertConstantsForCalculation(_convertPercentageForCalculation(expression)))),
      'after_power': _convertPowerForCalculation(_convertFactorialForCalculation(_convertScientificFunctionsForCalculation(_convertConstantsForCalculation(_convertPercentageForCalculation(expression))))),
      'final': fixIncompleteExpression(expression),
    };
  }

  /// Get function suggestions based on input
  static List<String> getFunctionSuggestions(String input) {
    final functions = ['sin', 'cos', 'tan', 'ln', 'log', 'sqrt', 'cbrt'];
    return functions.where((func) => func.startsWith(input.toLowerCase())).toList();
  }

  /// Check if expression contains scientific functions
  static bool hasScientificFunctions(String expression) {
    final scientificPattern = RegExp(r'(sin|cos|tan|ln|log|sqrt|cbrt|factorial|pow|\^|!|π|e|φ)');
    return scientificPattern.hasMatch(expression);
  }
}