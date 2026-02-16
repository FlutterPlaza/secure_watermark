import 'package:flutter_test/flutter_test.dart';

import 'package:secure_watermark_example/main.dart';

void main() {
  testWidgets('App renders with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WatermarkExampleApp());

    // Verify both navigation tabs are present.
    expect(find.text('Visible'), findsOneWidget);
    expect(find.text('Forensic'), findsOneWidget);

    // Visible watermark page is shown by default.
    expect(find.text('Visible Watermark'), findsOneWidget);
  });
}
