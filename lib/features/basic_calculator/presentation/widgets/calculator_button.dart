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
        return Colors.black87;
    }
  }

  Color _getIconColor() {
    return iconColor ?? _getTextColor();
  }

  double _getBaseFontSize() {
    if (textStyle?.fontSize != null) {
      return textStyle!.fontSize!;
    }

    if (keepFixedHeight) {
      return 16.0;
    }

    if (isExpandedMode) {
      if (text.length > 4) return 10.0;
      if (text.length > 2) return 12.0;
      return 16.0;
    } else {
      if (text.length > 4) return 14.0;
      if (text.length > 2) return 16.0;
      return 20.0;
    }
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
    final touchAreaSize = effectiveIconSize + 1; // 8px padding on each side
    final margin = EdgeInsets.symmetric(horizontal: 1, vertical: 0);

    final containerWidth = width ?? touchAreaSize;
    final containerHeight = height ?? touchAreaSize;

    // Ensure minimum touch target size (44x44 per Material Design)
    final finalWidth = math.max(containerWidth, 44.0);
    final finalHeight = math.max(containerHeight, 44.0);

    return Container(
      margin: margin,
      width: finalWidth,
      height: finalHeight,
      child: enableTouchEffect
          ? Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(finalWidth / 2),
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
                color: _getIconColor(),
              ),
            ),
          ),
        ),
      )
          : GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: effectiveIconSize,
              color: _getIconColor(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton() {
    final animatedFontSize = _getBaseFontSize() * textSizeMultiplier;
    final margin = EdgeInsets.symmetric(horizontal: 5, vertical: 4);

    final buttonContent = Container(
      height: _getDefaultHeight(),
      width: width,
      margin: margin,
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

    if (width == null) {
      return Expanded(
        flex: flex,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Widget _buildButtonContent(double animatedFontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Center(
        child: _buildButtonChild(animatedFontSize),
      ),
    );
  }

  Widget _buildButtonChild(double animatedFontSize) {
    final iconWidget = icon != null
        ? Icon(
      icon,
      size: _getIconSize(),
      color: _getIconColor(),
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
        fontWeight: FontWeight.w500,
        color: _getTextColor(),
      ),
    )
        : null;

    // If both icon and text exist, show them side by side
    if (iconWidget != null && textWidget != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: 4),
          Flexible(child: textWidget),
        ],
      );
    }

    // Return whichever exists
    return iconWidget ?? textWidget ?? SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Special handling for icon-shaped buttons
    if (shape == ButtonShape.iconShaped && icon != null) {
      return _buildIconShapedButton();
    }

    return _buildRoundedButton();
  }
}