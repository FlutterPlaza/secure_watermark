import 'package:flutter_test/flutter_test.dart';
import 'package:secure_watermark/watermark_painter.dart';
import 'package:secure_watermark/watermark_style.dart';

void main() {
  group('WatermarkPainter', () {
    group('shouldRepaint', () {
      test('returns false for identical text and style', () {
        final a = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(),
        );
        final b = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(),
        );
        expect(a.shouldRepaint(b), isFalse);
      });

      test('returns true when text changes', () {
        final a = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(),
        );
        final b = WatermarkPainter(
          text: 'world',
          style: const WatermarkStyle(),
        );
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when style changes', () {
        final a = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(opacity: 0.2),
        );
        final b = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(opacity: 0.3),
        );
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when rotation changes', () {
        final a = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(rotate: -30),
        );
        final b = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(rotate: -45),
        );
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when staggered changes', () {
        final a = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(staggered: true),
        );
        final b = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(staggered: false),
        );
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns false for same instance as old delegate', () {
        final painter = WatermarkPainter(
          text: 'hello',
          style: const WatermarkStyle(),
        );
        expect(painter.shouldRepaint(painter), isFalse);
      });
    });
  });
}
