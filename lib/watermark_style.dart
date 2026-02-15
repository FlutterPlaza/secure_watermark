import 'package:flutter/widgets.dart';

/// Immutable configuration for the watermark overlay appearance.
///
/// Controls visual properties such as opacity, rotation angle, text color,
/// font size, spacing, and whether alternate rows are staggered (brick pattern).
class WatermarkStyle {
  /// Creates a watermark style configuration.
  ///
  /// All parameters have sensible defaults for a subtle diagonal watermark.
  const WatermarkStyle({
    this.opacity = 0.15,
    this.rotate = -30,
    this.textColor = const Color(0xFF9E9E9E),
    this.fontSize = 16,
    this.rowSpacing = 80,
    this.columnSpacing = 120,
    this.fontWeight = FontWeight.normal,
    this.staggered = true,
  });

  /// Opacity of the watermark text, from 0.0 (invisible) to 1.0 (fully opaque).
  ///
  /// Defaults to 0.15.
  final double opacity;

  /// Rotation angle in degrees. Negative values rotate counter-clockwise.
  ///
  /// Defaults to -30.
  final double rotate;

  /// Color of the watermark text (opacity is applied separately).
  ///
  /// Defaults to grey (0xFF9E9E9E).
  final Color textColor;

  /// Font size of the watermark text in logical pixels.
  ///
  /// Defaults to 16.
  final double fontSize;

  /// Vertical spacing between watermark text rows in logical pixels.
  ///
  /// Defaults to 80.
  final double rowSpacing;

  /// Horizontal spacing between watermark text columns in logical pixels.
  ///
  /// Defaults to 120.
  final double columnSpacing;

  /// Font weight of the watermark text.
  ///
  /// Defaults to [FontWeight.normal].
  final FontWeight fontWeight;

  /// Whether alternate rows are offset by half [columnSpacing] to create
  /// a brick pattern, making cropping more difficult.
  ///
  /// Defaults to true.
  final bool staggered;

  /// Creates a copy of this style with the given fields replaced.
  WatermarkStyle copyWith({
    double? opacity,
    double? rotate,
    Color? textColor,
    double? fontSize,
    double? rowSpacing,
    double? columnSpacing,
    FontWeight? fontWeight,
    bool? staggered,
  }) {
    return WatermarkStyle(
      opacity: opacity ?? this.opacity,
      rotate: rotate ?? this.rotate,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      columnSpacing: columnSpacing ?? this.columnSpacing,
      fontWeight: fontWeight ?? this.fontWeight,
      staggered: staggered ?? this.staggered,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatermarkStyle &&
        other.opacity == opacity &&
        other.rotate == rotate &&
        other.textColor == textColor &&
        other.fontSize == fontSize &&
        other.rowSpacing == rowSpacing &&
        other.columnSpacing == columnSpacing &&
        other.fontWeight == fontWeight &&
        other.staggered == staggered;
  }

  @override
  int get hashCode {
    return Object.hash(
      opacity,
      rotate,
      textColor,
      fontSize,
      rowSpacing,
      columnSpacing,
      fontWeight,
      staggered,
    );
  }

  @override
  String toString() {
    return 'WatermarkStyle('
        'opacity: $opacity, '
        'rotate: $rotate, '
        'textColor: $textColor, '
        'fontSize: $fontSize, '
        'rowSpacing: $rowSpacing, '
        'columnSpacing: $columnSpacing, '
        'fontWeight: $fontWeight, '
        'staggered: $staggered)';
  }
}
