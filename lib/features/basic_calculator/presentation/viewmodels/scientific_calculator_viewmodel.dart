// presentation/viewmodels/scientific_calculator_viewmodel.dart
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../domain/usecases/calculate.dart';
import '../../domain/usecases/calculate_live.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/get_calculation_history.dart';
import '../../domain/usecases/save_calculation.dart';

enum AngleMode { degrees, radians }

class ScientificCalculatorViewModel extends ChangeNotifier {
  final Calculate calculate;
  final SaveCalculation saveCalculation;
  final GetCalculationHistory getCalculationHistory;
  final ClearHistory clearHistory;
  final CalculateLive calculateLive;

  ScientificCalculatorViewModel({
    required this.calculateLive,
    required this.calculate,
    required this.saveCalculation,
    required this.getCalculationHistory,
    required this.clearHistory,
  });

  AngleMode _angleMode = AngleMode.degrees;

  // Mathematical constants
  static const double goldenRatio = 1.618033988749895;
  static const double eulerNumber = 2.718281828459045;

  // Getters
  AngleMode get angleMode => _angleMode;
  bool get isDegreeMode => _angleMode == AngleMode.degrees;

  // Toggle angle mode
  void toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees;
    notifyListeners();
  }

  void setAngleMode(bool isDegrees) {
    _angleMode = isDegrees ? AngleMode.degrees : AngleMode.radians;
    notifyListeners();
  }

  // Scientific constants
  String getConstantValue(String constant) {
    switch (constant) {
      case 'π':
        return math.pi.toString();
      case 'e':
        return eulerNumber.toString();
      case 'φ': // Golden ratio
        return goldenRatio.toString();
      default:
        return '';
    }
  }

  String getConstantDisplay(String constant) {
    switch (constant) {
      case 'π':
        return 'π';
      case 'e':
        return 'e';
      case 'φ':
        return 'φ';
      default:
        return constant;
    }
  }

  // Scientific functions
  String getScientificFunction(String function) {
    switch (function) {
      case 'sin':
        return 'sin(';
      case 'cos':
        return 'cos(';
      case 'tan':
        return 'tan(';
      case 'asin':
        return 'asin(';
      case 'acos':
        return 'acos(';
      case 'atan':
        return 'atan(';
      case 'ln':
        return 'ln(';
      case 'log':
        return 'log(';
      case '√':
        return 'sqrt(';
      case '∛':
        return 'cbrt(';
      case 'sinh':
        return 'sinh(';
      case 'cosh':
        return 'cosh(';
      case 'tanh':
        return 'tanh(';
      default:
        return '';
    }
  }

  String getScientificFunctionDisplay(String function) {
    switch (function) {
      case 'sin':
        return 'sin(';
      case 'cos':
        return 'cos(';
      case 'tan':
        return 'tan(';
      case 'asin':
        return 'sin⁻¹(';
      case 'acos':
        return 'cos⁻¹(';
      case 'atan':
        return 'tan⁻¹(';
      case 'ln':
        return 'ln(';
      case 'log':
        return 'log(';
      case '√':
        return '√(';
      case '∛':
        return '∛(';
      case 'sinh':
        return 'sinh(';
      case 'cosh':
        return 'cosh(';
      case 'tanh':
        return 'tanh(';
      default:
        return function;
    }
  }

  // Power functions
  String getPowerFunction(String power) {
    switch (power) {
      case 'x²':
        return '^2';
      case 'x³':
        return '^3';
      case '10ˣ':
        return '10^';
      case '2ˣ':
        return '2^';
      case 'eˣ':
        return 'e^';
      default:
        return '^';
    }
  }

  // Additional scientific operations
  bool isValidForFactorial(String expression) {
    if (expression.isEmpty) return false;
    final trimmed = expression.trimRight();
    final lastChar = trimmed.isNotEmpty ? trimmed.characters.last : '';
    return RegExp(r'\d').hasMatch(lastChar) || lastChar == ')';
  }

  bool isValidForPower(String expression) {
    if (expression.isEmpty) return false;
    final trimmed = expression.trimRight();
    final lastChar = trimmed.isNotEmpty ? trimmed.characters.last : '';
    return !('+-*/%^'.contains(lastChar));
  }

  bool needsMultiplicationBefore(String lastChar) {
    return lastChar.isNotEmpty &&
        (RegExp(r'\d').hasMatch(lastChar) ||
            lastChar == ')' ||
            lastChar == '%' ||
            lastChar == 'π' ||
            lastChar == 'e' ||
            lastChar == 'φ' ||
            lastChar == '!');
  }

  // Memory functions (if needed)
  double _memory = 0;
  double get memory => _memory;

  void memoryStore(double value) {
    _memory = value;
    notifyListeners();
  }

  void memoryRecall() {
    // This would be handled by the main calculator view model
    notifyListeners();
  }

  void memoryClear() {
    _memory = 0;
    notifyListeners();
  }

  void memoryAdd(double value) {
    _memory += value;
    notifyListeners();
  }

  void memorySubtract(double value) {
    _memory -= value;
    notifyListeners();
  }

  // Utility functions for expression validation
  bool isExpressionEmpty(String expression) => expression.trim().isEmpty;

  bool endsWithOperator(String expression) {
    if (expression.isEmpty) return false;
    final lastChar = expression.trimRight().characters.lastOrNull ?? '';
    return '+-*/%^'.contains(lastChar);
  }

  bool endsWithNumber(String expression) {
    if (expression.isEmpty) return false;
    final lastChar = expression.trimRight().characters.lastOrNull ?? '';
    return RegExp(r'\d').hasMatch(lastChar);
  }

  bool endsWithClosingParenthesis(String expression) {
    if (expression.isEmpty) return false;
    final lastChar = expression.trimRight().characters.lastOrNull ?? '';
    return lastChar == ')';
  }

  // Get parenthesis type based on current expression
  String getParenthesisType(String expression) {
    final openCount = '('.allMatches(expression).length;
    final closeCount = ')'.allMatches(expression).length;
    return openCount <= closeCount ? '(' : ')';
  }

  // Angle conversion helpers (for when implementing actual calculation)
  double convertToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double convertToDegrees(double radians) {
    return radians * 180 / math.pi;
  }
}