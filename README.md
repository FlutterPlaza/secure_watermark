# secure_watermark

[![CI](https://github.com/FlutterPlaza/secure_watermark/actions/workflows/ci.yml/badge.svg)](https://github.com/FlutterPlaza/secure_watermark/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/secure_watermark.svg)](https://pub.dev/packages/secure_watermark)
[![pub points](https://img.shields.io/pub/points/secure_watermark)](https://pub.dev/packages/secure_watermark/score)
[![popularity](https://img.shields.io/pub/popularity/secure_watermark)](https://pub.dev/packages/secure_watermark/score)
[![likes](https://img.shields.io/pub/likes/secure_watermark)](https://pub.dev/packages/secure_watermark/score)
[![license](https://img.shields.io/github/license/FlutterPlaza/secure_watermark)](https://github.com/FlutterPlaza/secure_watermark/blob/main/LICENSE)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A Flutter package for **visible & invisible watermarking**. Part of the [FlutterPlaza Security Suite](https://flutterplaza.com).

- **Visible watermarks** deter screenshots by tiling user-identifying text over content
- **Forensic (invisible) watermarks** embed traceable data directly into image pixels using spread-spectrum LSB modulation — enabling post-leak identification even when visible watermarks are cropped out

## Visible Watermark

Tile user-identifying text (email, user ID, timestamp) across any widget with configurable opacity, rotation, font size, and staggered brick pattern.

<p align="center">
  <img src="https://raw.githubusercontent.com/FlutterPlaza/secure_watermark/main/doc/gif/visible_watermark-ezgif.com-video-to-gif-converter.gif" alt="Visible watermark demo" width="300"/>
</p>

## Forensic (Invisible) Watermark

Embed traceable data into image pixels. The watermarked image looks identical to the original — but the hidden payload can be extracted with the correct secret key.

<p align="center">
  <img src="https://raw.githubusercontent.com/FlutterPlaza/secure_watermark/main/doc/gif/forensic_watermark-ezgif.com-video-to-gif-converter.gif" alt="Forensic watermark demo" width="300"/>
</p>

## Features

**Visible watermark** (`Watermark` widget):
- Diagonal tiled text overlay with configurable opacity, rotation, font size, and spacing
- Staggered brick pattern (alternate rows offset) for crop resistance
- `IgnorePointer` — watermark does not intercept touch events
- `RepaintBoundary` — watermark repaints are isolated from child content
- `enabled` flag to toggle visibility without removing from widget tree

**Forensic (invisible) watermark** (`ForensicWatermark` + `ForensicWatermarkImage`):
- Spread-spectrum LSB embedding in blue channel at PRNG-selected pixel positions
- Majority voting with configurable redundancy for error correction
- Magic number validation for wrong-key detection
- `ForensicWatermarkImage` widget with background isolate processing
- CLI tools for embedding and extraction (`dart run secure_watermark:embed` / `extract`)

Pure Dart/Flutter — works on all platforms (no plugin, no method channels).

## Installation

```yaml
dependencies:
  secure_watermark: ^0.3.1
```

## Usage

### Visible watermark overlay

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

### Forensic watermark (embed invisible data)

```dart
import 'package:secure_watermark/secure_watermark.dart';

// Embed a payload into an image
final watermarked = ForensicWatermark.embed(
  imageBytes: pngBytes,         // PNG-encoded Uint8List
  payload: 'user@example.com',  // data to hide
  key: 'secret-key-123',        // secret key for PRNG seeding
);

// Extract the payload later
final payload = ForensicWatermark.extract(
  imageBytes: watermarked,
  key: 'secret-key-123',
);
print(payload); // user@example.com
```

### Forensic watermark widget

```dart
ForensicWatermarkImage(
  imageBytes: pngBytes,
  payload: 'user@example.com',
  secretKey: 'key-123',
  config: const ForensicConfig(redundancy: 5),
  placeholder: const CircularProgressIndicator(),
  errorBuilder: (ctx, error) => Text('Failed: $error'),
  fit: BoxFit.contain,
)
```

### CLI tools

```bash
# Embed
dart run secure_watermark:embed -i photo.png -o watermarked.png -p "user@example.com" -k "secret"

# Extract
dart run secure_watermark:extract -i watermarked.png -k "secret"
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

### ForensicWatermark

| Method | Returns | Description |
|---|---|---|
| `embed(imageBytes, payload, key, [config])` | `Uint8List` | Embeds payload into PNG, returns watermarked PNG bytes |
| `extract(imageBytes, key, [config])` | `String?` | Extracts payload, returns `null` on wrong key or no watermark |

### ForensicConfig

| Property | Type | Default | Description |
|---|---|---|---|
| `redundancy` | `int` | `5` | Odd positive int — copies for majority voting |
| `bitsPerChannel` | `int` | `1` | LSBs per channel (only 1 supported) |

### ForensicWatermarkImage

| Property | Type | Default | Description |
|---|---|---|---|
| `imageBytes` | `Uint8List` | *required* | Source PNG image |
| `payload` | `String` | *required* | Data to embed invisibly |
| `secretKey` | `String` | *required* | Secret key for PRNG seeding |
| `config` | `ForensicConfig` | `ForensicConfig()` | Algorithm configuration |
| `placeholder` | `Widget?` | `null` | Shown during processing |
| `errorBuilder` | `Widget Function(BuildContext, Object)?` | `null` | Called on failure |
| `fit` | `BoxFit` | `BoxFit.contain` | Image fit mode |
| `alignment` | `Alignment` | `Alignment.center` | Image alignment |

## How it works

The `Watermark` widget uses a `Stack` to layer a `CustomPaint` overlay on top of the child content. The `WatermarkPainter`:

1. Builds a `ui.Paragraph` with the watermark text
2. Translates and rotates the canvas around its center
3. Tiles the paragraph in a grid covering the full diagonal extent (ensuring no gaps after rotation)
4. In staggered mode, offsets alternate rows by half the column spacing — creating a brick pattern that is harder to crop out

The overlay is wrapped in `IgnorePointer` (touches pass through) and `RepaintBoundary` (repaints are isolated from the child).

### Forensic watermark algorithm

The `ForensicWatermark` uses spread-spectrum LSB (Least Significant Bit) modulation:

**Embedding:**
1. Decode PNG to RGBA pixels
2. Convert payload to UTF-8 bytes, prepend 16-bit magic number (`0x574D`) + 32-bit length header
3. Seed a PRNG with a DJB2 hash of the secret key
4. Generate unique random pixel positions (Set-based collision avoidance)
5. Modify the LSB of the blue channel at each position to encode bits
6. Repeat the payload `redundancy` times for error correction
7. Re-encode to PNG

**Extraction:**
1. Decode PNG, seed PRNG with same key
2. Read header bits across all redundancy copies, majority-vote each bit
3. Verify magic number — return `null` if wrong (wrong key)
4. Read payload bits, majority-vote, decode UTF-8

## Example app

The `example/` directory contains a full demo app with two tabs:

- **Visible** — interactive controls for the `Watermark` widget (opacity, angle, font size, staggered pattern)
- **Forensic** — embed/extract invisible watermarks with configurable payload, key, and redundancy

```bash
cd example
flutter run
```

## Related packages

- [no_screenshot](https://pub.dev/packages/no_screenshot) — Screenshot & recording prevention
- [no_tapjack](https://pub.dev/packages/no_tapjack) — Tapjacking & overlay attack detection

## License

BSD 3-Clause License. See [LICENSE](LICENSE) for details.
