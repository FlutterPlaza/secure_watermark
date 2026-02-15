import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_watermark/watermark_style.dart';

void main() {
  group('WatermarkStyle', () {
    test('has sensible defaults', () {
      const style = WatermarkStyle();
      expect(style.opacity, 0.15);
      expect(style.rotate, -30);
      expect(style.textColor, const Color(0xFF9E9E9E));
      expect(style.fontSize, 16);
      expect(style.rowSpacing, 80);
      expect(style.columnSpacing, 120);
      expect(style.fontWeight, FontWeight.normal);
      expect(style.staggered, true);
    });

    test('supports const construction', () {
      // Compile-time const — if this compiles, the test passes.
      const style = WatermarkStyle(opacity: 0.3, rotate: -45);
      expect(style.opacity, 0.3);
      expect(style.rotate, -45);
    });

    test('equality with identical values', () {
      const a = WatermarkStyle(opacity: 0.2, fontSize: 20);
      const b = WatermarkStyle(opacity: 0.2, fontSize: 20);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different values', () {
      const a = WatermarkStyle(opacity: 0.2);
      const b = WatermarkStyle(opacity: 0.3);
      expect(a, isNot(equals(b)));
    });

    test('equality is identity-aware', () {
      const style = WatermarkStyle();
      expect(style, equals(style));
    });

    test('not equal to non-WatermarkStyle', () {
      const style = WatermarkStyle();
      // ignore: unrelated_type_equality_checks
      expect(style == 'not a style', isFalse);
    });

    test('copyWith replaces specified fields', () {
      const original = WatermarkStyle();
      final modified = original.copyWith(opacity: 0.5, staggered: false);
      expect(modified.opacity, 0.5);
      expect(modified.staggered, false);
      // Unchanged fields preserve defaults.
      expect(modified.rotate, -30);
      expect(modified.fontSize, 16);
    });

    test('copyWith with no arguments returns equal copy', () {
      const original = WatermarkStyle(opacity: 0.4, rotate: -60);
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('toString includes all fields', () {
      const style = WatermarkStyle();
      final str = style.toString();
      expect(str, contains('opacity'));
      expect(str, contains('rotate'));
      expect(str, contains('fontSize'));
      expect(str, contains('staggered'));
      expect(str, contains('WatermarkStyle('));
    });
  });
}
