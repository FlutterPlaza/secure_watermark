## 0.3.1

- fix: shorten package description to meet pub.dev 60–180 character limit
- fix: tighten `args` lower bound to `^2.5.0` for `ArgResults.flag()`/`option()` compatibility
- fix: replace `setPixelRgba` with `getPixel` channel assignment in tests for `image` 4.0.0 compatibility
- fix: pass pub.dev downgrade analysis with zero errors

## 0.3.0

- feat: example app with two-tab demo (visible + forensic watermarks)
- docs: added GIF showcases to README for both visible and forensic features
- docs: added badges (pub version, points, popularity, likes, license, lints)
- docs: added example app section with run instructions
- fix: example test updated to match new app structure

## 0.2.0

- feat: forensic (invisible) watermarking via spread-spectrum LSB embedding
- feat: `ForensicWatermark` static utility with `embed()` and `extract()` methods
- feat: `ForensicConfig` immutable configuration (redundancy, bitsPerChannel)
- feat: `ForensicWatermarkImage` widget with background isolate processing
- feat: CLI tools — `dart run secure_watermark:embed` / `extract`
- feat: DJB2-seeded PRNG with Set-based collision avoidance for deterministic pixel selection
- feat: majority voting across redundancy copies for error correction
- feat: magic number (`0x574D`) validation for wrong-key detection
- deps: added `image` ^4.0.0 and `args` ^2.4.0

## 0.1.0

- feat: initial release
- feat: `Watermark` widget with `Stack` + `IgnorePointer` + `RepaintBoundary` overlay
- feat: `WatermarkStyle` immutable config with opacity, rotation, spacing, staggered mode
- feat: `WatermarkPainter` using `ParagraphBuilder` for efficient text tiling
- feat: diagonal tiling with staggered rows (brick pattern) for crop resistance
- feat: `enabled` flag to toggle watermark without removing from widget tree
- test: widget, painter, and style unit tests
