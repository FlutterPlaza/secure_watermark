## 0.1.0

- feat: initial release
- feat: `Watermark` widget with `Stack` + `IgnorePointer` + `RepaintBoundary` overlay
- feat: `WatermarkStyle` immutable config with opacity, rotation, spacing, staggered mode
- feat: `WatermarkPainter` using `ParagraphBuilder` for efficient text tiling
- feat: diagonal tiling with staggered rows (brick pattern) for crop resistance
- feat: `enabled` flag to toggle watermark without removing from widget tree
- test: widget, painter, and style unit tests
