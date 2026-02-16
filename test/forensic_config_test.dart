import 'package:flutter_test/flutter_test.dart';
import 'package:secure_watermark/forensic_config.dart';

void main() {
  group('ForensicConfig', () {
    test('has sensible defaults', () {
      const config = ForensicConfig();
      expect(config.redundancy, 5);
      expect(config.bitsPerChannel, 1);
    });

    test('supports const construction', () {
      const config = ForensicConfig(redundancy: 3);
      expect(config.redundancy, 3);
    });

    test('equality with identical values', () {
      const a = ForensicConfig(redundancy: 7);
      const b = ForensicConfig(redundancy: 7);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different values', () {
      const a = ForensicConfig(redundancy: 3);
      const b = ForensicConfig(redundancy: 5);
      expect(a, isNot(equals(b)));
    });

    test('equality is identity-aware', () {
      const config = ForensicConfig();
      expect(config, equals(config));
    });

    test('not equal to non-ForensicConfig', () {
      const config = ForensicConfig();
      // ignore: unrelated_type_equality_checks
      expect(config == 'not a config', isFalse);
    });

    test('copyWith replaces specified fields', () {
      const original = ForensicConfig();
      final modified = original.copyWith(redundancy: 7);
      expect(modified.redundancy, 7);
      expect(modified.bitsPerChannel, 1);
    });

    test('copyWith with no arguments returns equal copy', () {
      const original = ForensicConfig(redundancy: 3);
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('toString includes all fields', () {
      const config = ForensicConfig();
      final str = config.toString();
      expect(str, contains('ForensicConfig'));
      expect(str, contains('redundancy'));
      expect(str, contains('bitsPerChannel'));
    });
  });
}
