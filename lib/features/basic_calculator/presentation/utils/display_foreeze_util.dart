// frozen_calculator_display.dart - Display component that maintains state during transitions
import 'package:flutter/material.dart';
import '../viewmodels/basic_calculator_viewmodel.dart';

class FrozenCalculatorDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String liveResult;
  final CalculatorState state;

  const FrozenCalculatorDisplay({
    Key? key,
    required this.expression,
    required this.result,
    required this.liveResult,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Expression display
          if (expression.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _formatExpression(expression),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.end,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Live result display (preview)
          if (liveResult.isNotEmpty && state != CalculatorState.result && state != CalculatorState.error)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '= $liveResult',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[400],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Main result display
          Container(
            width: double.infinity,
            child: Text(
              result,
              style: TextStyle(
                fontSize: _getResultFontSize(result),
                fontWeight: FontWeight.w300,
                color: state == CalculatorState.error ? Colors.red : Colors.black,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpression(String expression) {
    return expression
        .replaceAll('*', '×')
        .replaceAll('/', '÷');
  }

  double _getResultFontSize(String result) {
    if (result.length <= 8) return 48.0;
    if (result.length <= 12) return 40.0;
    if (result.length <= 16) return 32.0;
    return 24.0;
  }
}