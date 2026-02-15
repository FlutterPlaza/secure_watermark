import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_watermark/secure_watermark.dart';

void main() {
  group('Watermark', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            child: Text('Hello'),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders CustomPaint when enabled', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('does not render CustomPaint when disabled', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            enabled: false,
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsNothing);
    });

    testWidgets('wraps overlay in IgnorePointer', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.byType(IgnorePointer), findsOneWidget);
    });

    testWidgets('wraps overlay in RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.byType(RepaintBoundary), findsOneWidget);
    });

    testWidgets('no IgnorePointer when disabled', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            enabled: false,
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.byType(IgnorePointer), findsNothing);
    });

    testWidgets('uses Stack as root', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('accepts custom style', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            style: WatermarkStyle(opacity: 0.5, rotate: -45),
            child: SizedBox.shrink(),
          ),
        ),
      );
      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      final painter = customPaint.painter! as WatermarkPainter;
      expect(painter.style.opacity, 0.5);
      expect(painter.style.rotate, -45);
    });

    testWidgets('passes text to painter', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'user@example.com',
            child: SizedBox.shrink(),
          ),
        ),
      );
      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      final painter = customPaint.painter! as WatermarkPainter;
      expect(painter.text, 'user@example.com');
    });

    testWidgets('child remains interactive under watermark', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Watermark(
            text: 'test',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tapped = true,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });
}
