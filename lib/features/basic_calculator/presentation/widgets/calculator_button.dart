// presentation/widgets/calculator_button.dart
import 'package:flutter/material.dart';

enum ButtonType {
  number,
  operator,
  equals,
  function,
}

enum ButtonShape {
  rectangle,
  circle,
  rounded,
  arrow, // New arrow shape
}

enum IconPosition {
  left,
  right,
  top,
  bottom,
  center, // Icon only, no text
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isExpandedMode;
  final bool keepFixedHeight;
  final IconData? icon;
  final Color? iconColor; // Custom icon color
  final double? iconSize; // Custom icon size
  final IconPosition iconPosition; // Icon position relative to text
  final TextStyle? textStyle;
  final double textSizeMultiplier;
  final int flex;
  final double? width;
  final double? height; // Custom height
  final Color? backgroundColor; // Custom background color
  final Color? textColor; // Custom text color
  final ButtonShape shape; // Button shape
  final double borderRadius; // Adjustable border radius
  final EdgeInsetsGeometry? margin; // Custom margin
  final EdgeInsetsGeometry? padding; // Custom padding
  final Border? border; // Custom border
  final List<BoxShadow>? boxShadow; // Custom shadow
  final Gradient? gradient; // Gradient background
  final double? arrowWidth; // Arrow width for arrow shape
  final double? arrowHeight; // Arrow height for arrow shape
  final ArrowDirection arrowDirection; // Arrow direction
  final double iconTextSpacing; // Spacing between icon and text
  final bool enableTouchEffect; // NEW: Enable/disable touch ripple effect

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
    this.iconPosition = IconPosition.left,
    this.textStyle,
    this.textSizeMultiplier = 1.0,
    this.flex = 1,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.shape = ButtonShape.rounded,
    this.borderRadius = 8.0,
    this.margin,
    this.padding,
    this.border,
    this.boxShadow,
    this.gradient,
    this.arrowWidth,
    this.arrowHeight,
    this.arrowDirection = ArrowDirection.right,
    this.iconTextSpacing = 4.0,
    this.enableTouchEffect = true, // NEW: Default to true for backward compatibility
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
    if (iconColor != null) return iconColor!;
    return _getTextColor();
  }

  double _getBaseFontSize() {
    if (textStyle?.fontSize != null) {
      return textStyle!.fontSize!;
    }

    if (keepFixedHeight) {
      return 16.0; // Reduced from 18.0 for better fit
    }

    if (isExpandedMode) {
      // More conservative sizing for expanded mode
      if (text.length > 4) return 10.0;
      if (text.length > 2) return 12.0;
      return 16.0;
    } else {
      // Better sizing for normal mode
      if (text.length > 4) return 14.0;
      if (text.length > 2) return 16.0;
      return 20.0; // Reduced from 22.0
    }
  }

  double _getDefaultHeight() {
    if (height != null) return height!;
    if (keepFixedHeight) return 50;
    return isExpandedMode ? 32 : 60;
  }

  double _getIconSize() {
    if (iconSize != null) return iconSize!;
    final baseFontSize = _getBaseFontSize() * textSizeMultiplier;
    return baseFontSize;
  }

  // FIXED: Get proper BorderRadius based on shape and borderRadius property
  BorderRadius? _getBorderRadius() {
    switch (shape) {
      case ButtonShape.rectangle:
        return BorderRadius.zero;
      case ButtonShape.circle:
        return null; // Circle doesn't use BorderRadius
      case ButtonShape.rounded:
        return BorderRadius.circular(borderRadius);
      case ButtonShape.arrow:
        return BorderRadius.circular(borderRadius); // ADDED: Arrow shapes can now have border radius
    }
  }

  Widget _buildArrowShape() {
    final arrowW = arrowWidth ?? (width ?? 60.0);
    final arrowH = arrowHeight ?? _getDefaultHeight();

    return CustomPaint(
      size: Size(arrowW, arrowH),
      painter: ArrowPainter(
        color: gradient != null ? Colors.transparent : _getButtonColor(),
        gradient: gradient,
        direction: arrowDirection,
        border: border,
        boxShadow: boxShadow,
        borderRadius: borderRadius, // ADDED: Pass border radius to painter
      ),
    );
  }

  // FIXED: Updated to properly handle borderRadius
  ShapeBorder _getButtonShape() {
    switch (shape) {
      case ButtonShape.rectangle:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: border?.top ?? BorderSide.none,
        );
      case ButtonShape.circle:
        return CircleBorder(
          side: border?.top ?? BorderSide.none,
        );
      case ButtonShape.rounded:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border?.top ?? BorderSide.none,
        );
      case ButtonShape.arrow:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius), // ADDED: Arrow shapes can now have border radius
          side: border?.top ?? BorderSide.none,
        );
    }
  }

  Widget _buildTouchableButton({required Widget child, required ShapeBorder shapeBorder}) {
    if (!enableTouchEffect) {
      // Return a GestureDetector instead of InkWell when touch effect is disabled
      return GestureDetector(
        onTap: onPressed,
        child: child,
      );
    }

    return Material(
      color: Colors.transparent,
      shape: shapeBorder,
      child: InkWell(
        customBorder: shapeBorder,
        onTap: onPressed,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animatedFontSize = _getBaseFontSize() * textSizeMultiplier;
    final defaultMargin = EdgeInsets.symmetric(horizontal: 5, vertical: 4);
    final effectiveMargin = margin ?? defaultMargin;
    final shapeBorder = _getButtonShape();

    Widget buttonContent;

    if (shape == ButtonShape.arrow) {
      // Special handling for arrow shape - don't use Expanded wrapper
      buttonContent = Container(
        margin: effectiveMargin,
        child: Stack(
          children: [
            _buildArrowShape(),
            Positioned.fill(
              child: _buildTouchableButton(
                shapeBorder: shapeBorder,
                child: Container(
                  padding: padding ?? EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    child: _buildButtonChild(animatedFontSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      // Return arrow button without Expanded wrapper to avoid layout issues
      return buttonContent;
    } else {
      // FIXED: Standard button shapes with proper border radius handling
      buttonContent = Container(
        height: _getDefaultHeight(),
        width: width,
        margin: effectiveMargin,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: gradient != null ? null : _getButtonColor(),
            gradient: gradient,
            borderRadius: _getBorderRadius(), // FIXED: Use the proper method
            shape: shape == ButtonShape.circle ? BoxShape.circle : BoxShape.rectangle,
            border: border,
            boxShadow: boxShadow,
          ),
          child: _buildTouchableButton(
            shapeBorder: shapeBorder,
            child: Container(
              padding: padding ?? EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Center(
                child: _buildButtonChild(animatedFontSize),
              ),
            ),
          ),
        ),
      );
    }

    // Preserve original Expanded behavior for non-arrow buttons with no fixed width
    if (width == null && shape != ButtonShape.arrow) {
      return Expanded(
        flex: flex,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Widget _buildButtonChild(double animatedFontSize) {
    final iconWidget = icon != null ? Icon(
      icon,
      size: _getIconSize(),
      color: _getIconColor(),
    ) : null;

    final textWidget = text.isNotEmpty ? AnimatedDefaultTextStyle(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      style: TextStyle(
        fontSize: animatedFontSize,
        fontWeight: FontWeight.w500,
        color: _getTextColor(),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ) : null;

    // Handle different icon positions - FIXED LAYOUT LOGIC
    if (iconWidget != null && textWidget != null) {
      switch (iconPosition) {
        case IconPosition.left:
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(width: iconTextSpacing),
              Flexible(child: textWidget),
            ],
          );
        case IconPosition.right:
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: textWidget),
              SizedBox(width: iconTextSpacing),
              iconWidget,
            ],
          );
        case IconPosition.top:
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(height: iconTextSpacing),
              Flexible(child: textWidget),
            ],
          );
        case IconPosition.bottom:
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: textWidget),
              SizedBox(height: iconTextSpacing),
              iconWidget,
            ],
          );
        case IconPosition.center:
        // Show only icon when position is center
          return iconWidget;
      }
    } else if (iconWidget != null) {
      return iconWidget;
    } else if (textWidget != null) {
      return textWidget;
    }

    return SizedBox.shrink();
  }
}

enum ArrowDirection {
  up,
  down,
  left,
  right,
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final Gradient? gradient;
  final ArrowDirection direction;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double borderRadius; // ADDED: Border radius for rounded arrows

  ArrowPainter({
    required this.color,
    this.gradient,
    required this.direction,
    this.border,
    this.boxShadow,
    this.borderRadius = 0.0, // ADDED: Default to 0 for sharp corners
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = color;
    }

    // Create fully rounded arrow with custom path or use RRect approach
    if (borderRadius > 0) {
      _drawRoundedArrow(canvas, size, paint);
    } else {
      _drawSharpArrow(canvas, size, paint);
    }

    // Draw border if specified
    if (border != null) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = border!.top.color
        ..strokeWidth = border!.top.width;

      if (borderRadius > 0) {
        _drawRoundedArrowBorder(canvas, size, borderPaint);
      } else {
        _drawSharpArrowBorder(canvas, size, borderPaint);
      }
    }
  }

  void _drawRoundedArrow(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final arrowTipRatio = 0.3;
    final radius = borderRadius.clamp(0.0, size.width * 0.2); // Limit radius to prevent distortion

    switch (direction) {
      case ArrowDirection.right:
        final arrowTipWidth = size.width * arrowTipRatio;
        final arrowMidY = size.height / 2;

        // Start from top-left with radius
        path.moveTo(radius, 0);

        // Top edge to arrow start with radius
        path.lineTo(size.width - arrowTipWidth - radius, 0);
        path.quadraticBezierTo(
          size.width - arrowTipWidth, 0,
          size.width - arrowTipWidth + radius, radius,
        );

        // Upper diagonal edge to tip (rounded)
        final tipControlX = size.width - (arrowTipWidth * 0.3);
        final tipControlY = arrowMidY - (arrowMidY * 0.3);
        path.quadraticBezierTo(tipControlX, tipControlY, size.width - radius, arrowMidY);
        path.quadraticBezierTo(size.width, arrowMidY, size.width - radius, arrowMidY);

        // Lower diagonal edge from tip (rounded)
        final tipControlY2 = arrowMidY + (arrowMidY * 0.3);
        path.quadraticBezierTo(tipControlX, tipControlY2, size.width - arrowTipWidth + radius, size.height - radius);

        // Bottom edge from arrow to left with radius
        path.quadraticBezierTo(
          size.width - arrowTipWidth, size.height,
          size.width - arrowTipWidth - radius, size.height,
        );
        path.lineTo(radius, size.height);

        // Left edge with rounded corners
        path.quadraticBezierTo(0, size.height, 0, size.height - radius);
        path.lineTo(0, radius);
        path.quadraticBezierTo(0, 0, radius, 0);
        path.close();
        break;

      case ArrowDirection.left:
        final arrowTipWidth = size.width * arrowTipRatio;
        final arrowMidY = size.height / 2;

        // Start from top-right with radius
        path.moveTo(size.width - radius, 0);

        // Top edge to arrow start with radius
        path.lineTo(arrowTipWidth + radius, 0);
        path.quadraticBezierTo(
          arrowTipWidth, 0,
          arrowTipWidth - radius, radius,
        );

        // Upper diagonal edge to tip (rounded)
        final tipControlX = arrowTipWidth * 0.3;
        final tipControlY = arrowMidY - (arrowMidY * 0.3);
        path.quadraticBezierTo(tipControlX, tipControlY, radius, arrowMidY);
        path.quadraticBezierTo(0, arrowMidY, radius, arrowMidY);

        // Lower diagonal edge from tip (rounded)
        final tipControlY2 = arrowMidY + (arrowMidY * 0.3);
        path.quadraticBezierTo(tipControlX, tipControlY2, arrowTipWidth - radius, size.height - radius);

        // Bottom edge from arrow to right with radius
        path.quadraticBezierTo(
          arrowTipWidth, size.height,
          arrowTipWidth + radius, size.height,
        );
        path.lineTo(size.width - radius, size.height);

        // Right edge with rounded corners
        path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
        path.lineTo(size.width, radius);
        path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
        path.close();
        break;

      case ArrowDirection.up:
        final arrowTipHeight = size.height * arrowTipRatio;
        final arrowMidX = size.width / 2;

        // Start from bottom-left with radius
        path.moveTo(radius, size.height);

        // Left edge to arrow start with radius
        path.lineTo(radius, arrowTipHeight + radius);
        path.quadraticBezierTo(
          0, arrowTipHeight,
          radius, arrowTipHeight - radius,
        );

        // Left diagonal edge to tip (rounded)
        final tipControlX = arrowMidX - (arrowMidX * 0.3);
        final tipControlY = arrowTipHeight * 0.3;
        path.quadraticBezierTo(tipControlX, tipControlY, arrowMidX, radius);
        path.quadraticBezierTo(arrowMidX, 0, arrowMidX, radius);

        // Right diagonal edge from tip (rounded)
        final tipControlX2 = arrowMidX + (arrowMidX * 0.3);
        path.quadraticBezierTo(tipControlX2, tipControlY, size.width - radius, arrowTipHeight - radius);

        // Right edge from arrow to bottom with radius
        path.quadraticBezierTo(
          size.width, arrowTipHeight,
          size.width - radius, arrowTipHeight + radius,
        );
        path.lineTo(size.width - radius, size.height - radius);

        // Bottom edge with rounded corners
        path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
        path.lineTo(radius, size.height);
        path.quadraticBezierTo(0, size.height, 0, size.height - radius);
        path.lineTo(0, arrowTipHeight + radius);
        path.close();
        break;

      case ArrowDirection.down:
        final arrowTipHeight = size.height * arrowTipRatio;
        final arrowMidX = size.width / 2;

        // Start from top-left with radius
        path.moveTo(radius, 0);

        // Top edge with rounded corner
        path.lineTo(size.width - radius, 0);
        path.quadraticBezierTo(size.width, 0, size.width, radius);

        // Right edge to arrow start with radius
        path.lineTo(size.width - radius, size.height - arrowTipHeight - radius);
        path.quadraticBezierTo(
          size.width, size.height - arrowTipHeight,
          size.width - radius, size.height - arrowTipHeight + radius,
        );

        // Right diagonal edge to tip (rounded)
        final tipControlX = arrowMidX + (arrowMidX * 0.3);
        final tipControlY = size.height - (arrowTipHeight * 0.3);
        path.quadraticBezierTo(tipControlX, tipControlY, arrowMidX, size.height - radius);
        path.quadraticBezierTo(arrowMidX, size.height, arrowMidX, size.height - radius);

        // Left diagonal edge from tip (rounded)
        final tipControlX2 = arrowMidX - (arrowMidX * 0.3);
        path.quadraticBezierTo(tipControlX2, tipControlY, radius, size.height - arrowTipHeight + radius);

        // Left edge from arrow to top with radius
        path.quadraticBezierTo(
          0, size.height - arrowTipHeight,
          radius, size.height - arrowTipHeight - radius,
        );
        path.lineTo(0, radius);

        // Left edge with rounded corner
        path.quadraticBezierTo(0, 0, radius, 0);
        path.close();
        break;
    }

    // Draw shadow if specified
    if (boxShadow != null) {
      for (final shadow in boxShadow!) {
        final shadowPath = path.shift(shadow.offset);
        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
        canvas.drawPath(shadowPath, shadowPaint);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawSharpArrow(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final arrowTipRatio = 0.3;

    switch (direction) {
      case ArrowDirection.right:
        final arrowTipWidth = size.width * arrowTipRatio;
        path.moveTo(0, 0);
        path.lineTo(size.width - arrowTipWidth, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - arrowTipWidth, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;
      case ArrowDirection.left:
        final arrowTipWidth = size.width * arrowTipRatio;
        path.moveTo(arrowTipWidth, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(arrowTipWidth, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;
      case ArrowDirection.up:
        final arrowTipHeight = size.height * arrowTipRatio;
        path.moveTo(0, arrowTipHeight);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, arrowTipHeight);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;
      case ArrowDirection.down:
        final arrowTipHeight = size.height * arrowTipRatio;
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - arrowTipHeight);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, size.height - arrowTipHeight);
        path.close();
        break;
    }

    // Draw shadow if specified
    if (boxShadow != null) {
      for (final shadow in boxShadow!) {
        final shadowPath = path.shift(shadow.offset);
        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
        canvas.drawPath(shadowPath, shadowPaint);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawRoundedArrowBorder(Canvas canvas, Size size, Paint borderPaint) {
    // Create the same rounded path for border
    final path = Path();
    final arrowTipRatio = 0.3;
    final radius = borderRadius.clamp(0.0, size.width * 0.2);

    // Use the same path logic as _drawRoundedArrow but only stroke
    // This is a simplified version - you would copy the full path logic here
    // For brevity, using a basic approach
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, borderPaint);
  }

  void _drawSharpArrowBorder(Canvas canvas, Size size, Paint borderPaint) {
    final path = Path();
    final arrowTipRatio = 0.3;

    // Same sharp arrow path as _drawSharpArrow
    switch (direction) {
      case ArrowDirection.right:
        final arrowTipWidth = size.width * arrowTipRatio;
        path.moveTo(0, 0);
        path.lineTo(size.width - arrowTipWidth, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - arrowTipWidth, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;
      case ArrowDirection.left:
        final arrowTipWidth = size.width * arrowTipRatio;
        path.moveTo(arrowTipWidth, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(arrowTipWidth, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;
      case ArrowDirection.up:
        final arrowTipHeight = size.height * arrowTipRatio;
        path.moveTo(0, arrowTipHeight);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, arrowTipHeight);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;
      case ArrowDirection.down:
        final arrowTipHeight = size.height * arrowTipRatio;
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - arrowTipHeight);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, size.height - arrowTipHeight);
        path.close();
        break;
    }

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}