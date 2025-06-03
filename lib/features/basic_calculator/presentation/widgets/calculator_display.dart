import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/basic_calculator_viewmodel.dart';

class CalculatorDisplay extends StatefulWidget {
  final String expression;
  final String result; // this will be the evaluated answer or error text
  final CalculatorState state;
  final String liveResult;

  const CalculatorDisplay({
    Key? key,
    required this.expression,
    required this.result,
    required this.liveResult,
    required this.state,
  }) : super(key: key);

  @override
  State<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends State<CalculatorDisplay> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: formatExpression(widget.expression));
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant CalculatorDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final formattedExpr = formatExpression(widget.expression);

    if (_controller.text != formattedExpr) {
      _controller.text = formattedExpr;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String formatExpression(String expression) {
    return expression
        .replaceAll('*', '×')
        .replaceAll('/', '÷')
        .replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.state == CalculatorState.error;
    final isResultFinal = widget.state == CalculatorState.result;
    final textToShow = isError
        ? widget.result
        : isResultFinal
        ? widget.result
        : widget.liveResult;

    final shouldShowResult = textToShow.isNotEmpty;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height after padding
          final availableHeight = constraints.maxHeight - 32; // 12 + 20 padding

          // Reserve space for spacing between expression and result
          final spacingHeight = shouldShowResult ? 12.0 : 0.0;
          final contentHeight = availableHeight - spacingHeight;

          // Dynamic font size calculation based on available space
          double expressionFontSize, resultFontSize;

          if (shouldShowResult) {
            // When showing result, split the space proportionally
            if (isResultFinal) {
              // Result is primary (larger), expression is secondary (smaller)
              expressionFontSize = (contentHeight * 0.35).clamp(16.0, 32.0);
              resultFontSize = (contentHeight * 0.65).clamp(24.0, 56.0);
            } else {
              // Expression is primary (larger), result is secondary (smaller)
              expressionFontSize = (contentHeight * 0.65).clamp(24.0, 56.0);
              resultFontSize = (contentHeight * 0.35).clamp(16.0, 32.0);
            }
          } else {
            // Only expression showing, use most of the available space
            expressionFontSize = (contentHeight * 0.8).clamp(24.0, 64.0);
            resultFontSize = 0; // Not used
          }

          // Swap colors based on state
          final Color expressionColor = isResultFinal
              ? (isError ? Colors.redAccent : Colors.grey[400]!)
              : (isError ? Colors.redAccent : Colors.white);

          final Color resultColor = isResultFinal
              ? (isError ? Colors.redAccent : Colors.white)
              : (isError ? Colors.redAccent : Colors.grey[400]!);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Flexible expression with cursor
              Flexible(
                flex: shouldShowResult ? (isResultFinal ? 35 : 65) : 100,
                child: GestureDetector(
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    context.read<BasicCalculatorViewModel>().clearExpression();
                  },
                  child: Container(
                    width: double.infinity,
                    child: TextField(
                      cursorHeight: expressionFontSize * 0.8, // Dynamic cursor height
                      controller: _controller,
                      focusNode: _focusNode,
                      readOnly: true,
                      showCursor: true,
                      enableInteractiveSelection: true,
                      cursorColor: isError ? Colors.redAccent : Colors.white,
                      style: TextStyle(
                        fontSize: expressionFontSize,
                        fontWeight: FontWeight.bold,
                        color: isError ? Colors.redAccent : expressionColor,
                        height: 1.1, // Tighter line height
                      ),
                      maxLines: null, // Allow unlimited lines
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),

              if (shouldShowResult) ...[
                SizedBox(height: spacingHeight),
                // Flexible result
                Flexible(
                  flex: isResultFinal ? 65 : 35,
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      '= $textToShow',
                      style: TextStyle(
                        fontSize: resultFontSize,
                        color: isError ? Colors.redAccent : resultColor,
                        fontWeight: FontWeight.w500,
                        height: 1.1, // Tighter line height
                      ),
                      maxLines: null, // Allow unlimited lines
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}