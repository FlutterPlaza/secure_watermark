import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:secure_watermark/forensic_config.dart';
import 'package:secure_watermark/forensic_watermark_image.dart';

/// Creates a solid-color 20x20 RGBA PNG as bytes.
Uint8List _createTestPng() {
  final image = img.Image(width: 20, height: 20);
  for (var y = 0; y < 20; y++) {
    for (var x = 0; x < 20; x++) {
      image.setPixelRgba(x, y, 128, 128, 128, 255);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

/// Pumps until compute() completes by using [runAsync] then rebuilding.
Future<void> _pumpUntilSettled(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
  await tester.pumpAndSettle();
}

void main() {
  group('ForensicWatermarkImage', () {
    testWidgets('shows placeholder while processing', (tester) async {
      final png = _createTestPng();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'test',
            secretKey: 'key',
            placeholder: const Text('Loading'),
          ),
        ),
      );
      // Before settling, should show placeholder.
      expect(find.text('Loading'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows Image.memory after processing completes',
        (tester) async {
      final png = _createTestPng();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'hi',
            secretKey: 'key',
            config: const ForensicConfig(redundancy: 1),
            placeholder: const Text('Loading'),
          ),
        ),
      );
      await _pumpUntilSettled(tester);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('shows error builder on failure', (tester) async {
      // Pass invalid bytes to trigger an error.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: Uint8List.fromList([1, 2, 3]),
            payload: 'test',
            secretKey: 'key',
            errorBuilder: (context, error) => const Text('Error'),
          ),
        ),
      );
      await _pumpUntilSettled(tester);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('reprocesses when payload changes', (tester) async {
      final png = _createTestPng();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'first',
            secretKey: 'key',
            config: const ForensicConfig(redundancy: 1),
            placeholder: const Text('Loading'),
          ),
        ),
      );
      await _pumpUntilSettled(tester);
      expect(find.byType(Image), findsOneWidget);

      // Change payload — should trigger reprocess.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'second',
            secretKey: 'key',
            config: const ForensicConfig(redundancy: 1),
            placeholder: const Text('Loading'),
          ),
        ),
      );
      // Should show placeholder during reprocessing.
      expect(find.text('Loading'), findsOneWidget);
      await _pumpUntilSettled(tester);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('passes fit to Image.memory', (tester) async {
      final png = _createTestPng();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'hi',
            secretKey: 'key',
            config: const ForensicConfig(redundancy: 1),
            fit: BoxFit.cover,
          ),
        ),
      );
      await _pumpUntilSettled(tester);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('passes alignment to Image.memory', (tester) async {
      final png = _createTestPng();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'hi',
            secretKey: 'key',
            config: const ForensicConfig(redundancy: 1),
            alignment: Alignment.topLeft,
          ),
        ),
      );
      await _pumpUntilSettled(tester);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.alignment, Alignment.topLeft);
    });

    testWidgets('shows SizedBox.shrink when no placeholder provided',
        (tester) async {
      final png = _createTestPng();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ForensicWatermarkImage(
            imageBytes: png,
            payload: 'hi',
            secretKey: 'key',
          ),
        ),
      );
      // While processing, should show SizedBox.shrink (default).
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
