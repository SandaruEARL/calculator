// presentation/viewmodels/basic_calculator_viewmodel.dart

import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/expression_formatter.dart';
import '../../core/utils/result_formatter.dart';
import '../../domain/entities/calculation.dart';
import '../../domain/usecases/calculate.dart';
import '../../domain/usecases/calculate_live.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/get_calculation_history.dart';
import '../../domain/usecases/save_calculation.dart';

enum CalculatorState { initial, calculating, result, error, history }

class BasicCalculatorViewModel extends ChangeNotifier {
  final Calculate calculate;
  final SaveCalculation saveCalculation;
  final GetCalculationHistory getCalculationHistory;
  final ClearHistory clearHistory;
  final CalculateLive calculateLive;

  BasicCalculatorViewModel({
    required this.calculateLive,
    required this.calculate,
    required this.saveCalculation,
    required this.getCalculationHistory,
    required this.clearHistory,
  });

  String _display = '0';
  String _expression = '';
  CalculatorState _state = CalculatorState.initial;
  String _errorMessage = '';
  List<Calculation> _history = [];
  bool _shouldResetDisplay = false;
  String _liveResult = '';

  // Getters
  String get display => _display;
  String get expression => _expression;
  CalculatorState get state => _state;
  String get errorMessage => _errorMessage;
  List<Calculation> get history => _history;
  String get liveResult => _liveResult;

  String get displayExpression {
    return _expression
        .replaceAll('*', '×')
        .replaceAll('/', '÷');
  }

  Future<void> _updateLiveResult() async {
    if (_expression.trim().isEmpty) {
      _liveResult = '';
      notifyListeners();
      return;
    }

    final fixedExpression = ExpressionUtils.fixIncompleteExpression(_expression);

    final result = await calculateLive(fixedExpression);

    result.fold(
          (failure) {
        _liveResult = '';
      },
          (value) {
        _liveResult = ResultFormatter.formatResult(value);
      },
    );
    notifyListeners();
  }

  void onNumberPressed(String number) {
    final trimmedExpr = _expression.trimRight();
    final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';
    final isLastCharOperator = '+-*/%'.contains(lastChar);

    final isFreshStart = _shouldResetDisplay && _state == CalculatorState.result;
    final shouldContinueExpression = _shouldResetDisplay && isLastCharOperator;

    if (isFreshStart) {
      _display = number;
      _expression = number;
      _shouldResetDisplay = false;
    } else if (shouldContinueExpression) {
      _display = number;
      _expression += number;
      _shouldResetDisplay = false;
    } else {
      final needsMultiplication = (lastChar == ')' || lastChar == '%') && RegExp(r'\d').hasMatch(number);

      if (_display == '0') {
        _display = number;
        _expression = number;
      } else {
        if (needsMultiplication) {
          _expression += ' * ';
        }
        _display += number;
        _expression += number;
      }
    }

    _state = CalculatorState.initial;
    _updateLiveResult();
    notifyListeners();
  }

  void onParenthesisPressed() {
    final openCount = '('.allMatches(_expression).length;
    final closeCount = ')'.allMatches(_expression).length;
    final shouldInsertOpen = openCount <= closeCount;
    final paren = shouldInsertOpen ? '(' : ')';

    if (_shouldResetDisplay) {
      _display = paren;
      _expression = paren;
      _shouldResetDisplay = false;
    } else {
      final trimmedExpr = _expression.trimRight();
      final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';

      if (paren == '(') {
        // Insert * before '(' if last char is digit, ), or %
        if (lastChar.isNotEmpty &&
            (RegExp(r'\d').hasMatch(lastChar) || lastChar == ')' || lastChar == '%')) {
          _expression += ' * ';
          _display += paren;
          _expression += paren;
        } else {
          _display += paren;
          _expression += paren;
        }
      } else {
        // Add closing parenthesis only if allowed by count
        if (openCount > closeCount) {
          _display += paren;
          _expression += paren;
        }
      }
    }

    _state = CalculatorState.initial;
    _updateLiveResult();
    notifyListeners();
  }

  void onDoubleZeroPressed() {
    final lastCharIsOperator = _expression.isNotEmpty && RegExp(r'[+\-*/]$').hasMatch(_expression);

    // Case 1: If the last char is an operator, treat this as starting a new number — insert "0"
    if (lastCharIsOperator) {
      _display = '0';
      _expression += '0';
      _shouldResetDisplay = false;
    }
    // Case 2: If we should reset or are starting fresh — just show "0"
    else if (_shouldResetDisplay || _display == '' || _display == '0') {
      _display = '0';
      _expression = '0';
      _shouldResetDisplay = false;
    }
    // Case 3: If display has only 0s, don't add more
    else if (RegExp(r'^0+$').hasMatch(_display)) {
      return;
    }
    // Case 4: Append "00" normally
    else {
      _display += '00';
      _expression += '00';
    }

    _state = CalculatorState.initial;
    _updateLiveResult();
    notifyListeners();
  }

  void onOperatorPressed(String operator) {
    if (_shouldResetDisplay) {
      _shouldResetDisplay = false;
    }

    // Define operator characters
    const operators = {'+', '-', '*', '/', '%', '^'};

    // Only restrict operator press if *both* are truly empty
    if (_expression.isEmpty && _display.isEmpty) {
      if (operator == '-') {
        _expression = operator;
        _display = operator;
        _state = CalculatorState.initial;
        _updateLiveResult();
        notifyListeners();
      }
      return;
    }

    String lastChar = _expression[_expression.length - 1];

    // Block chaining another operator after a single leading '-'
    if (_expression.length == 1 && _expression == '-' && operator != '-') {
      return;
    }

    if (operators.contains(lastChar)) {
      if (lastChar == operator) {
        return; // Prevent same operator twice
      } else {
        // Replace the last operator only if it's not the lone leading '-'
        if (!(_expression.length == 1 && _expression == '-')) {
          _expression = _expression.substring(0, _expression.length - 1) + operator;
          _display = '';
        }
      }
    } else {
      // Append % or other operator if valid
      if (operator == '%') {
        _display += '%';
        _expression += '%';
      } else {
        _expression += operator;
        _display = '';
      }
    }

    _state = CalculatorState.initial;
    _updateLiveResult();
    notifyListeners();
  }

  void onDecimalPressed() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _expression = '0.';
      _shouldResetDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
      _expression += '.';
    }
    _state = CalculatorState.initial;
    _updateLiveResult();
    notifyListeners();
  }

  Future<void> onEqualsPressed() async {
    if (_expression.isEmpty) return;

    _state = CalculatorState.calculating;
    notifyListeners();

    final fixedExpression = ExpressionUtils.fixIncompleteExpression(_expression);

    final result = await calculate(fixedExpression);

    result.fold(
          (failure) {
        _errorMessage = failure.message;
        _state = CalculatorState.error;
        _shouldResetDisplay = true;
      },
          (value) async {
        _display = ResultFormatter.formatResult(value);

        _state = CalculatorState.result;
        _shouldResetDisplay = true;

        // Save calculation with the fixed expression
        final calculation = Calculation(
          expression: fixedExpression,
          result: value,
          timestamp: DateTime.now(),
        );

        await saveCalculation(calculation);

        // Optionally update _expression to fixed version so UI reflects it
        _expression = fixedExpression;
      },
    );

    _updateLiveResult();
    notifyListeners();
  }

  void onClearPressed() {
    _display = '0';
    _expression = '';
    _state = CalculatorState.initial;
    _errorMessage = '';
    _shouldResetDisplay = false;
    _liveResult = '';
    notifyListeners();

  }

  void onBackspacePressed() {
    if (_expression.isEmpty) return;

    // Remove last character from expression
    _expression = _expression.substring(0, _expression.length - 1);

    // Reset the display flag so next input doesn't wipe everything
    _shouldResetDisplay = false;

    // Rebuild display from expression
    if (_expression.isEmpty) {
      _display = '0';
    } else {
      // Find the last number/operand in the expression to set as display
      final trimmedExpr = _expression.trimRight();

      // Look for the last number after the last operator
      final lastOperatorIndex = RegExp(r'[\+\-\*/%]').allMatches(trimmedExpr).lastOrNull?.start ?? -1;

      if (lastOperatorIndex == -1) {
        // No operators found, entire expression is the display
        _display = trimmedExpr;
      } else if (lastOperatorIndex == trimmedExpr.length - 1) {
        // Last character is an operator, so display should be empty for next input
        _display = '';
      } else {
        // Extract everything after the last operator as display
        _display = trimmedExpr.substring(lastOperatorIndex + 1);
      }

      // Handle edge case where display becomes empty but expression has content
      if (_display.isEmpty && _expression.isNotEmpty) {
        // Check if expression ends with an operator
        final lastChar = _expression.characters.lastOrNull ?? '';
        if ('+-*/%'.contains(lastChar)) {
          _display = '';  // Keep display empty after operator
        } else {
          _display = _expression; // Fallback
        }
      }
    }

    _state = CalculatorState.initial;
    _updateLiveResult();
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _state = CalculatorState.history;
    notifyListeners();

    final result = await getCalculationHistory();
    result.fold(
          (failure) {
        _errorMessage = failure.message;
        _state = CalculatorState.error;
      },
          (calculations) {
        _history = calculations.reversed.toList(); // Show newest first
        _state = CalculatorState.history;
      },
    );
    notifyListeners();
  }

  Future<void> clearCalculationHistory() async {
    final result = await clearHistory();
    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _history.clear(),
    );
    notifyListeners();
  }

  void clearExpression() {
    _display = '0';
    _expression = '';
    _liveResult = '';
    _state = CalculatorState.initial;
    notifyListeners();
  }
}