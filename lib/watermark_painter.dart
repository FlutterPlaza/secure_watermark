import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'watermark_style.dart';

/// A [CustomPainter] that tiles watermark text across the entire canvas.
///
/// The painter rotates the canvas by [WatermarkStyle.rotate] degrees and
/// renders text in a grid pattern. When [WatermarkStyle.staggered] is true,
/// alternate rows are offset by half the column spacing to create a brick
/// pattern that is harder to crop out.
class WatermarkPainter extends CustomPainter {
  /// Creates a watermark painter with the given [text] and [style].
  WatermarkPainter({
    required this.text,
    required this.style,
  });

  /// The text to render as the watermark.
  final String text;

  /// The visual style configuration.
  final WatermarkStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    final radians = style.rotate * math.pi / 180;

    // Build the paragraph once and reuse for each tile.
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    final textStyle = ui.TextStyle(
      color: style.textColor.withValues(alpha: style.opacity),
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
    );

    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);
    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: double.infinity));

    final textWidth = paragraph.longestLine;
    final textHeight = paragraph.height;

    // After rotation, the visible area expands. We need to tile a larger
    // region to ensure full coverage. The diagonal of the canvas gives the
    // maximum extent needed in any direction after rotation.
    final diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);

    final stepX = textWidth + style.columnSpacing;
    final stepY = textHeight + style.rowSpacing;

    canvas.save();

    // Translate to center, rotate, then translate back so the rotation
    // is centered on the canvas.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(radians);
    canvas.translate(-size.width / 2, -size.height / 2);

    // Tile from -diagonal to +diagonal to cover all rotated area.
    final startX = (size.width / 2) - diagonal;
    final endX = (size.width / 2) + diagonal;
    final startY = (size.height / 2) - diagonal;
    final endY = (size.height / 2) + diagonal;

    var row = 0;
    for (var y = startY; y < endY; y += stepY) {
      final staggerOffset = (style.staggered && row.isOdd) ? stepX / 2 : 0.0;
      for (var x = startX + staggerOffset; x < endX; x += stepX) {
        canvas.drawParagraph(paragraph, Offset(x, y));
      }
      row++;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(WatermarkPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.style != style;
  }
}
