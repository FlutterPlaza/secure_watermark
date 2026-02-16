/// Immutable configuration for forensic (invisible) watermarking.
///
/// Controls the spread-spectrum LSB embedding parameters.
class ForensicConfig {
  /// Creates a forensic watermark configuration.
  ///
  /// [redundancy] must be a positive odd integer (enables majority voting).
  /// [bitsPerChannel] is reserved for future use and must be 1.
  const ForensicConfig({
    this.redundancy = 5,
    this.bitsPerChannel = 1,
  })  : assert(redundancy > 0, 'redundancy must be positive'),
        assert(redundancy % 2 == 1, 'redundancy must be odd'),
        assert(bitsPerChannel == 1, 'only 1 bit per channel is supported');

  /// Number of times the payload is repeated for error correction.
  ///
  /// Must be a positive odd integer. Higher values improve resilience to
  /// image manipulation at the cost of requiring more pixel capacity.
  /// Defaults to 5.
  final int redundancy;

  /// Number of least-significant bits used per channel.
  ///
  /// Currently only 1 is supported. Reserved for future expansion.
  final int bitsPerChannel;

  /// Creates a copy of this config with the given fields replaced.
  ForensicConfig copyWith({
    int? redundancy,
    int? bitsPerChannel,
  }) {
    return ForensicConfig(
      redundancy: redundancy ?? this.redundancy,
      bitsPerChannel: bitsPerChannel ?? this.bitsPerChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForensicConfig &&
        other.redundancy == redundancy &&
        other.bitsPerChannel == bitsPerChannel;
  }

  @override
  int get hashCode => Object.hash(redundancy, bitsPerChannel);

  @override
  String toString() =>
      'ForensicConfig(redundancy: $redundancy, bitsPerChannel: $bitsPerChannel)';
}
