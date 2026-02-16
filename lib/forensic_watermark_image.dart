import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'forensic_config.dart';
import 'forensic_watermark.dart';

/// A widget that embeds a forensic watermark into [imageBytes] and displays
/// the result.
///
/// Processing is performed in a background isolate via [compute] to avoid
/// blocking the UI thread.
///
/// Shows [placeholder] while processing and calls [errorBuilder] on failure.
/// Re-processes automatically when [imageBytes], [payload], [secretKey], or
/// [config] change.
///
/// ```dart
/// ForensicWatermarkImage(
///   imageBytes: pngBytes,
///   payload: 'user@example.com',
///   secretKey: 'key-123',
///   placeholder: const CircularProgressIndicator(),
///   errorBuilder: (context, error) => Text('Failed: $error'),
/// )
/// ```
class ForensicWatermarkImage extends StatefulWidget {
  /// Creates a widget that embeds and displays a forensic watermark.
  const ForensicWatermarkImage({
    super.key,
    required this.imageBytes,
    required this.payload,
    required this.secretKey,
    this.config = const ForensicConfig(),
    this.placeholder,
    this.errorBuilder,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  /// The source image as PNG-encoded bytes.
  final Uint8List imageBytes;

  /// The payload to embed invisibly (e.g. user ID, email).
  final String payload;

  /// The secret key used to seed the PRNG for embedding.
  final String secretKey;

  /// Configuration for the forensic watermark algorithm.
  final ForensicConfig config;

  /// Widget to display while the watermark is being embedded.
  final Widget? placeholder;

  /// Builder called when embedding fails.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// How the watermarked image should be inscribed into the space.
  final BoxFit fit;

  /// How the watermarked image should be aligned within its bounds.
  final Alignment alignment;

  @override
  State<ForensicWatermarkImage> createState() => _ForensicWatermarkImageState();
}

class _ForensicWatermarkImageState extends State<ForensicWatermarkImage> {
  Uint8List? _result;
  Object? _error;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _process();
  }

  @override
  void didUpdateWidget(ForensicWatermarkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBytes != widget.imageBytes ||
        oldWidget.payload != widget.payload ||
        oldWidget.secretKey != widget.secretKey ||
        oldWidget.config != widget.config) {
      _process();
    }
  }

  Future<void> _process() async {
    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      final result = await compute(
        _embedInIsolate,
        _EmbedParams(
          imageBytes: widget.imageBytes,
          payload: widget.payload,
          key: widget.secretKey,
          config: widget.config,
        ),
      );
      if (mounted) {
        setState(() {
          _result = result;
          _processing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _processing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
          const SizedBox.shrink();
    }
    if (_result != null) {
      return Image.memory(
        _result!,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    }
    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// Parameters passed to the background isolate.
class _EmbedParams {
  const _EmbedParams({
    required this.imageBytes,
    required this.payload,
    required this.key,
    required this.config,
  });

  final Uint8List imageBytes;
  final String payload;
  final String key;
  final ForensicConfig config;
}

/// Top-level function for [compute] — must not be a closure.
Uint8List _embedInIsolate(_EmbedParams params) {
  return ForensicWatermark.embed(
    imageBytes: params.imageBytes,
    payload: params.payload,
    key: params.key,
    config: params.config,
  );
}
