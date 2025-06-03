// presentation/widgets/calculator_button.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ButtonType {
  number,
  operator,
  equals,
  function,
}

enum ButtonShape {
  rounded,
  iconShaped,
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isExpandedMode;
  final bool keepFixedHeight;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;  // Add fontWeight parameter
  final double textSizeMultiplier;
  final int flex;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonShape shape;
  final bool enableTouchEffect;

  const CalculatorButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.number,
    this.isExpandedMode = false,
    this.keepFixedHeight = false,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.textStyle,
    this.fontWeight,  // Add fontWeight parameter
    this.textSizeMultiplier = 1.0,
    this.flex = 1,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.shape = ButtonShape.rounded,
    this.enableTouchEffect = true,
  });

  Color _getButtonColor() {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case ButtonType.number:
        return Colors.grey.shade300;
      case ButtonType.operator:
        return Colors.grey.shade200;
      case ButtonType.equals:
        return Colors.orange.shade600;
      case ButtonType.function:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;

    switch (type) {
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.operator:
        return Colors.orange.shade600;
      case ButtonType.function:
        return Colors.orange.shade600;
      default:
        return Colors.black;
    }
  }

  FontWeight _getFontWeight() {
    // If fontWeight is explicitly provided, use it
    if (fontWeight != null) {
      return fontWeight!;
    }

    final trimmedText = text.trim();

    // Special fontWeight for basic operators and functions
    const basicOperators = {'C', '( )', '÷', '×', '-', '+','%',"="};
    if (basicOperators.contains(trimmedText)) {
      return FontWeight.w500; // Slightly bolder for basic operators
    }

    // Apply w500 to mathematical symbols and scientific functions
    const lightWeightSymbols = {
      '³√', '√', '^',
      'sin', 'cos', 'tan', 'ln', 'log', '!',
      'φ', 'e', 'π'
    };

    if (lightWeightSymbols.contains(trimmedText)) {
      return FontWeight.w500;
    }

    // Keep equals button normal weight for better visibility
    if (type == ButtonType.equals) {
      return FontWeight.normal;
    }

    // All other buttons (numbers, parentheses, etc.) use w500
    return FontWeight.w500;
  }

  double _getBaseFontSize() {
    if (textStyle?.fontSize != null) {
      return textStyle!.fontSize!;
    }

    if (keepFixedHeight) {
      return 16.0;
    }

    return isExpandedMode
        ? (text.length > 4 ? 10.0 : text.length > 2 ? 12.0 : 16.0)
        : (text.length > 4 ? 14.0 : text.length > 2 ? 16.0 : 20.0);
  }

  double _getDefaultHeight() {
    if (height != null) return height!;
    if (keepFixedHeight) return 50;
    return isExpandedMode ? 32 : 60;
  }

  double _getIconSize() {
    return iconSize ?? (_getBaseFontSize() * textSizeMultiplier * 1.5);
  }

  Widget _buildIconShapedButton() {
    final effectiveIconSize = _getIconSize();
    final touchAreaSize = math.max(effectiveIconSize + 8, 44.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
      width: width ?? touchAreaSize,
      height: height ?? touchAreaSize,
      child: enableTouchEffect
          ? Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(touchAreaSize / 2),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: _getButtonColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: effectiveIconSize,
                color: iconColor ?? _getTextColor(),
              ),
            ),
          ),
        ),
      )
          : GestureDetector(
        onTap: onPressed,
        child: Center(
          child: Icon(
            icon,
            size: effectiveIconSize,
            color: iconColor ?? _getTextColor(),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton() {
    final animatedFontSize = _getBaseFontSize() * textSizeMultiplier;

    final buttonContent = Container(
      height: _getDefaultHeight(),
      width: width,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: _getButtonColor(),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: enableTouchEffect
          ? Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: onPressed,
          child: _buildButtonContent(animatedFontSize),
        ),
      )
          : GestureDetector(
        onTap: onPressed,
        child: _buildButtonContent(animatedFontSize),
      ),
    );

    return width == null
        ? Expanded(flex: flex, child: buttonContent)
        : buttonContent;
  }

  Widget _buildButtonContent(double animatedFontSize) {
    return Center(child: _buildButtonChild(animatedFontSize));
  }

  Widget _buildButtonChild(double animatedFontSize) {
    final iconWidget = icon != null
        ? Icon(
      icon,
      size: _getIconSize(),
      color: iconColor ?? _getTextColor(),
    )
        : null;

    final textWidget = text.isNotEmpty
        ? Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: animatedFontSize,
        fontWeight: _getFontWeight(),
        color: _getTextColor(),
        height: 1.0,
      ),
    )
        : null;

    // Show both icon and text side by side if both exist
    if (iconWidget != null && textWidget != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: 4),
          Flexible(child: textWidget),
        ],
      );
    }

    return iconWidget ?? textWidget ?? SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return shape == ButtonShape.iconShaped && icon != null
        ? _buildIconShapedButton()
        : _buildRoundedButton();
  }
}