import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/basic_calculator_viewmodel.dart';

class CalculatorDisplay extends StatefulWidget {
  final String expression;
  final String result;
  final CalculatorState state;
  final String liveResult;
  final bool isCompactMode; // Add this parameter

  const CalculatorDisplay({
    Key? key,
    required this.expression,
    required this.result,
    required this.liveResult,
    required this.state,
    this.isCompactMode = false, // Default to false
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

    final hasResult = textToShow.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade200,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dynamic font size calculation based on available space and compact mode
            double expressionFontSize, resultFontSize;

            // Adjust font sizes based on compact mode
            final fontSizeMultiplier = widget.isCompactMode ? 3 : 3;

            if (isResultFinal && hasResult) {
              // Result is primary (larger), expression is secondary (smaller)
              expressionFontSize = (constraints.maxHeight * 0.10 * fontSizeMultiplier).clamp(12.0, 26.0);
              resultFontSize = (constraints.maxHeight * 0.16 * fontSizeMultiplier).clamp(18.0, 42.0);
            } else {
              // Expression is primary (larger), result is secondary (smaller)
              expressionFontSize = (constraints.maxHeight * 0.16 * fontSizeMultiplier).clamp(18.0, 42.0);
              resultFontSize = (constraints.maxHeight * 0.10 * fontSizeMultiplier).clamp(12.0, 26.0);
            }

            // Swap colors based on state
            final Color expressionColor = isResultFinal
                ? (isError ? Colors.redAccent : Colors.grey[500]!)
                : (isError ? Colors.redAccent : Colors.black);

            final Color resultColor = isResultFinal
                ? (isError ? Colors.redAccent : Colors.black)
                : (isError ? Colors.redAccent : Colors.grey[500]!);

            // Dynamic height allocation - make both sections flexible
            final expressionFlex = widget.isCompactMode ? 2 : 3; // Reduce expression space in compact mode
            final resultFlex = widget.isCompactMode ? 1 : 2;     // Reduce result space in compact mode

            return Column(
              children: [
                // Expression container - flexible height based on mode
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        context.read<BasicCalculatorViewModel>().clearExpression();
                      },
                      child: TextField(
                        cursorHeight: expressionFontSize * 1.2, // Dynamic cursor height
                        controller: _controller,
                        focusNode: _focusNode,
                        readOnly: true,
                        showCursor: true,
                        enableInteractiveSelection: true,
                        cursorColor: isError ? Colors.redAccent : Colors.orange,
                        style: TextStyle(
                          fontSize: expressionFontSize,
                          fontWeight: FontWeight.normal,
                          color: isError ? Colors.redAccent : expressionColor,
                          height: 1.5,
                        ),
                        maxLines: null,
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

                // Result container - flexible height based on mode
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    alignment: Alignment.topRight,
                    child: Text(
                      hasResult ? '= $textToShow' : '',
                      style: TextStyle(
                        fontSize: resultFontSize,
                        color: isError ? Colors.redAccent : resultColor,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                      maxLines: widget.isCompactMode ? 1 : 1, // Limit lines in compact mode
                      overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}