# secure_watermark

[![CI](https://github.com/FlutterPlaza/secure_watermark/actions/workflows/ci.yml/badge.svg)](https://github.com/FlutterPlaza/secure_watermark/actions/workflows/ci.yml)

A Flutter package to render a **visible watermark overlay** over protected content. Part of the [FlutterPlaza Security Suite](https://flutterplaza.com).

Watermarks deter screenshots and make leaks traceable by tiling user-identifying text (user ID, email, timestamp) across the entire widget area. The overlay is rendered with `CustomPainter` — no native code required.

## Features

- Diagonal tiled text overlay with configurable opacity, rotation, font size, and spacing
- Staggered brick pattern (alternate rows offset) for crop resistance
- `IgnorePointer` — watermark does not intercept touch events
- `RepaintBoundary` — watermark repaints are isolated from child content
- `enabled` flag to toggle visibility without removing from widget tree
- Pure Flutter — works on all platforms (no plugin, no method channels)

## Installation

```yaml
dependencies:
  secure_watermark: ^0.1.0
```

## Usage

```dart
import 'package:secure_watermark/secure_watermark.dart';

Watermark(
  text: 'user@example.com  2026-02-15',
  style: const WatermarkStyle(opacity: 0.2, rotate: -45),
  enabled: true,
  child: MyProtectedContent(),
)
```

### Toggle watermark at runtime

```dart
Watermark(
  text: 'user@example.com',
  enabled: isWatermarkVisible, // controlled by setState, provider, etc.
  child: MyProtectedContent(),
)
```

### Customize style

```dart
const style = WatermarkStyle(
  opacity: 0.2,        // 0.0–1.0 (default: 0.15)
  rotate: -45,         // degrees (default: -30)
  fontSize: 14,        // logical pixels (default: 16)
  rowSpacing: 60,      // vertical gap between rows (default: 80)
  columnSpacing: 100,  // horizontal gap between columns (default: 120)
  fontWeight: FontWeight.bold,
  staggered: true,     // brick pattern offset (default: true)
);
```

## API Reference

### Watermark

| Property | Type | Default | Description |
|---|---|---|---|
| `text` | `String` | *required* | Text to tile as the watermark |
| `style` | `WatermarkStyle` | `WatermarkStyle()` | Visual configuration |
| `enabled` | `bool` | `true` | Whether the overlay is visible |
| `child` | `Widget` | *required* | Content to display beneath the watermark |

### WatermarkStyle

| Property | Type | Default | Description |
|---|---|---|---|
| `opacity` | `double` | `0.15` | Text opacity (0.0–1.0) |
| `rotate` | `double` | `-30` | Rotation angle in degrees |
| `textColor` | `Color` | `Color(0xFF9E9E9E)` | Text color (opacity applied separately) |
| `fontSize` | `double` | `16` | Font size in logical pixels |
| `rowSpacing` | `double` | `80` | Vertical spacing between rows |
| `columnSpacing` | `double` | `120` | Horizontal spacing between columns |
| `fontWeight` | `FontWeight` | `FontWeight.normal` | Font weight |
| `staggered` | `bool` | `true` | Offset alternate rows for brick pattern |

## How it works

The `Watermark` widget uses a `Stack` to layer a `CustomPaint` overlay on top of the child content. The `WatermarkPainter`:

1. Builds a `ui.Paragraph` with the watermark text
2. Translates and rotates the canvas around its center
3. Tiles the paragraph in a grid covering the full diagonal extent (ensuring no gaps after rotation)
4. In staggered mode, offsets alternate rows by half the column spacing — creating a brick pattern that is harder to crop out

The overlay is wrapped in `IgnorePointer` (touches pass through) and `RepaintBoundary` (repaints are isolated from the child).

## Related packages

- [no_screenshot](https://pub.dev/packages/no_screenshot) — Screenshot & recording prevention
- [no_tapjack](https://pub.dev/packages/no_tapjack) — Tapjacking & overlay attack detection

## License

BSD 3-Clause License. See [LICENSE](LICENSE) for details.
