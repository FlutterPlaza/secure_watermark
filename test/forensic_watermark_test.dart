import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:secure_watermark/forensic_config.dart';
import 'package:secure_watermark/forensic_watermark.dart';

/// Creates a solid-color 100x100 RGBA PNG as bytes.
Uint8List _createTestPng({int width = 100, int height = 100}) {
  final image = img.Image(width: width, height: height);
  // Fill with a mid-tone blue so LSB changes are invisible.
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = image.getPixel(x, y);
      pixel
        ..r = 128
        ..g = 128
        ..b = 128
        ..a = 255;
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('ForensicWatermark', () {
    group('embed + extract roundtrip', () {
      test('basic ASCII roundtrip', () {
        final png = _createTestPng();
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'user@example.com',
          key: 'secret',
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'secret',
        );
        expect(extracted, 'user@example.com');
      });

      test('unicode roundtrip', () {
        final png = _createTestPng();
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'Héllo Wörld 日本語 🎉',
          key: 'key',
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'key',
        );
        expect(extracted, 'Héllo Wörld 日本語 🎉');
      });

      test('single-character payload', () {
        final png = _createTestPng();
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'A',
          key: 'k',
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'k',
        );
        expect(extracted, 'A');
      });

      test('redundancy 1 works', () {
        final png = _createTestPng();
        const config = ForensicConfig(redundancy: 1);
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key',
          config: config,
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'key',
          config: config,
        );
        expect(extracted, 'test');
      });

      test('redundancy 3 works', () {
        final png = _createTestPng();
        const config = ForensicConfig(redundancy: 3);
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'hello',
          key: 'mykey',
          config: config,
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'mykey',
          config: config,
        );
        expect(extracted, 'hello');
      });

      test('redundancy 7 works', () {
        final png = _createTestPng();
        const config = ForensicConfig(redundancy: 7);
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'hi',
          key: 'k',
          config: config,
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'k',
          config: config,
        );
        expect(extracted, 'hi');
      });
    });

    group('wrong key returns null', () {
      test('different key returns null', () {
        final png = _createTestPng();
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'secret data',
          key: 'correct-key',
        );
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'wrong-key',
        );
        expect(extracted, isNull);
      });

      test('unmarked image returns null', () {
        final png = _createTestPng();
        final extracted = ForensicWatermark.extract(
          imageBytes: png,
          key: 'any-key',
        );
        expect(extracted, isNull);
      });
    });

    group('determinism', () {
      test('same inputs produce same output', () {
        final png = _createTestPng();
        final a = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key',
        );
        final b = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key',
        );
        expect(a, equals(b));
      });

      test('different payloads produce different output', () {
        final png = _createTestPng();
        final a = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'payload-a',
          key: 'key',
        );
        final b = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'payload-b',
          key: 'key',
        );
        expect(a, isNot(equals(b)));
      });

      test('different keys produce different output', () {
        final png = _createTestPng();
        final a = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key-a',
        );
        final b = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key-b',
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('output validity', () {
      test('output is valid PNG', () {
        final png = _createTestPng();
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key',
        );
        final decoded = img.decodePng(watermarked);
        expect(decoded, isNotNull);
        expect(decoded!.width, 100);
        expect(decoded.height, 100);
      });

      test('output dimensions match input', () {
        final png = _createTestPng(width: 50, height: 75);
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key',
        );
        final decoded = img.decodePng(watermarked);
        expect(decoded!.width, 50);
        expect(decoded.height, 75);
      });
    });

    group('error handling', () {
      test('throws on empty payload', () {
        final png = _createTestPng();
        expect(
          () => ForensicWatermark.embed(
            imageBytes: png,
            payload: '',
            key: 'key',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on empty key', () {
        final png = _createTestPng();
        expect(
          () => ForensicWatermark.embed(
            imageBytes: png,
            payload: 'test',
            key: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on invalid image bytes', () {
        expect(
          () => ForensicWatermark.embed(
            imageBytes: Uint8List.fromList([1, 2, 3]),
            payload: 'test',
            key: 'key',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws when payload exceeds capacity', () {
        // 2x2 image = 4 pixels. Even a tiny payload will exceed 70% capacity.
        final tinyPng = _createTestPng(width: 2, height: 2);
        expect(
          () => ForensicWatermark.embed(
            imageBytes: tinyPng,
            payload: 'this is way too long for 4 pixels',
            key: 'key',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('extract returns null for empty key', () {
        final png = _createTestPng();
        final result = ForensicWatermark.extract(
          imageBytes: png,
          key: '',
        );
        expect(result, isNull);
      });

      test('extract returns null for invalid image bytes', () {
        final result = ForensicWatermark.extract(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          key: 'key',
        );
        expect(result, isNull);
      });
    });

    group('config mismatch', () {
      test('wrong redundancy fails to extract', () {
        final png = _createTestPng();
        final watermarked = ForensicWatermark.embed(
          imageBytes: png,
          payload: 'test',
          key: 'key',
          config: const ForensicConfig(redundancy: 1),
        );
        // With redundancy 1 embed / 3 extract, only 1/3 copies have correct
        // data — not enough for majority vote to reconstruct the magic number.
        final extracted = ForensicWatermark.extract(
          imageBytes: watermarked,
          key: 'key',
          config: const ForensicConfig(redundancy: 3),
        );
        expect(extracted, isNull);
      });
    });
  });
}
