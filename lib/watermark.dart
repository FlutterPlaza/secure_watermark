import 'package:flutter/widgets.dart';

import 'watermark_painter.dart';
import 'watermark_style.dart';

/// A widget that renders a visible watermark overlay on top of its [child].
///
/// The watermark tiles [text] (e.g. user ID, email, timestamp) across the
/// entire child area. Useful for deterring screenshots and tracing leaks.
///
/// The overlay is rendered with [IgnorePointer] so it does not intercept
/// touch events, and wrapped in a [RepaintBoundary] to isolate repaints.
///
/// ```dart
/// Watermark(
///   text: 'user@example.com  2026-02-15',
///   style: const WatermarkStyle(opacity: 0.2, rotate: -45),
///   child: MyProtectedContent(),
/// )
/// ```
class Watermark extends StatelessWidget {
  /// Creates a watermark overlay over [child].
  ///
  /// The [text] is tiled across the child area according to [style].
  /// Set [enabled] to false to hide the watermark without removing the
  /// widget from the tree.
  const Watermark({
    super.key,
    required this.text,
    this.style = const WatermarkStyle(),
    this.enabled = true,
    required this.child,
  });

  /// The text to display as the watermark (e.g. user ID, email, timestamp).
  final String text;

  /// The visual style configuration for the watermark.
  final WatermarkStyle style;

  /// Whether the watermark overlay is visible.
  ///
  /// When false, only the [child] is rendered. Defaults to true.
  final bool enabled;

  /// The content to display beneath the watermark.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: WatermarkPainter(
                    text: text,
                    style: style,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
