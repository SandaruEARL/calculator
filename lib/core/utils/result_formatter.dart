// lib/core/utils/result_formatter.dart
import 'dart:math' as math;

class ResultFormatter {
  /// Format the result with appropriate precision and notation
  static String formatResult(double value) {
    // Handle special cases
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';

    // Handle very small numbers (close to zero)
    if (value.abs() < 1e-10 && value != 0) {
      return '0';
    }

    // Handle very large numbers with scientific notation
    if (value.abs() >= 1e12) {
      return _formatScientificNotation(value);
    }

    // Handle very small non-zero numbers with scientific notation
    if (value.abs() < 1e-6 && value != 0) {
      return _formatScientificNotation(value);
    }

    // For integers or numbers that can be represented as integers
    if (value == value.toInt() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    // For decimal numbers, use appropriate precision
    return _formatDecimal(value);
  }

  /// Format decimal numbers with appropriate precision
  static String _formatDecimal(double value) {
    // Determine appropriate decimal places based on magnitude
    int decimalPlaces = _getDecimalPlaces(value);

    String formatted = value.toStringAsFixed(decimalPlaces);

    // Remove trailing zeros and decimal point if not needed
    formatted = formatted.replaceAll(RegExp(r'0*$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');

    return formatted;
  }

  /// Get appropriate number of decimal places based on value magnitude
  static int _getDecimalPlaces(double value) {
    double absValue = value.abs();

    if (absValue >= 1000) return 2;
    if (absValue >= 100) return 3;
    if (absValue >= 10) return 4;
    if (absValue >= 1) return 6;
    if (absValue >= 0.1) return 7;
    return 8;
  }

  /// Format numbers in scientific notation
  static String _formatScientificNotation(double value) {
    if (value == 0) return '0';

    int exponent = (math.log(value.abs()) / math.ln10).floor();
    double mantissa = value / math.pow(10, exponent);

    // Format mantissa with appropriate precision
    String mantissaStr;
    if (mantissa == mantissa.toInt()) {
      mantissaStr = mantissa.toInt().toString();
    } else {
      mantissaStr = mantissa.toStringAsFixed(6);
      mantissaStr = mantissaStr.replaceAll(RegExp(r'0*$'), '');
      mantissaStr = mantissaStr.replaceAll(RegExp(r'\.$'), '');
    }

    return '${mantissaStr}E${exponent >= 0 ? '+' : ''}$exponent';
  }

  /// Format result for specific scientific contexts
  static String formatScientificResult(double value, {
    bool useDegrees = false,
    int? precision,
  }) {
    // Handle angle conversions for trigonometric results
    if (useDegrees && _isTrigonometricResult(value)) {
      value = _radiansToDegrees(value);
    }

    // Use custom precision if specified
    if (precision != null) {
      if (value == value.toInt()) {
        return value.toInt().toString();
      }
      String formatted = value.toStringAsFixed(precision);
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }

    return formatResult(value);
  }

  /// Check if value is likely a trigonometric result that might need degree conversion
  static bool _isTrigonometricResult(double value) {
    // This is a heuristic - in practice, you'd need context about what function was called
    return value.abs() <= math.pi;
  }

  /// Convert radians to degrees
  static double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// Format result with units (for scientific calculations)
  static String formatWithUnit(double value, String unit) {
    return '${formatResult(value)} $unit';
  }

  /// Format percentage results
  static String formatPercentage(double value) {
    double percentage = value * 100;
    return '${formatResult(percentage)}%';
  }

  /// Format complex mathematical expressions results
  static String formatMathematicalResult(double value, {
    bool showAsInteger = false,
    bool showAsPercentage = false,
    bool showInScientific = false,
    int? decimalPlaces,
  }) {
    if (showAsPercentage) {
      return formatPercentage(value);
    }

    if (showInScientific) {
      return _formatScientificNotation(value);
    }

    if (showAsInteger && value == value.toInt()) {
      return value.toInt().toString();
    }

    if (decimalPlaces != null) {
      String formatted = value.toStringAsFixed(decimalPlaces);
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }

    return formatResult(value);
  }

  /// Get formatted result with additional information for debugging
  static Map<String, String> getDetailedFormat(double value) {
    return {
      'standard': formatResult(value),
      'scientific': _formatScientificNotation(value),
      'fixed_2': value.toStringAsFixed(2),
      'fixed_6': value.toStringAsFixed(6),
      'percentage': formatPercentage(value),
      'raw': value.toString(),
    };
  }

  /// Format angle results (for trigonometric functions)
  static String formatAngle(double radians, {bool inDegrees = false}) {
    if (inDegrees) {
      double degrees = _radiansToDegrees(radians);
      return '${formatResult(degrees)}°';
    }
    return '${formatResult(radians)} rad';
  }

  /// Format logarithmic results with appropriate precision
  static String formatLogarithm(double value) {
    // Logarithms often result in irrational numbers, so use appropriate precision
    if (value == value.toInt() && value.abs() < 1000) {
      return value.toInt().toString();
    }

    return _formatDecimal(value);
  }

  /// Check if result should be displayed in a special format
  static bool shouldUseSpecialFormat(double value) {
    return value.isNaN ||
        value.isInfinite ||
        value.abs() >= 1e12 ||
        (value.abs() < 1e-6 && value != 0);
  }
}