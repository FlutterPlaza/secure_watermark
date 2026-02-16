import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'forensic_config.dart';

/// Magic number (`0x574D`, ASCII "WM") prepended to every embedded payload.
///
/// Used during extraction to verify the correct key before attempting to
/// decode the payload bytes.
const int _kMagic = 0x574D;

/// Maximum fraction of image pixels that may be used for embedding.
///
/// Keeps the PRNG position generator from stalling due to collisions.
const double _kMaxCapacityFraction = 0.7;

/// Static utility class for forensic (invisible) watermark embedding and
/// extraction using spread-spectrum LSB modulation.
///
/// The algorithm modifies the least-significant bit of the blue channel at
/// pseudo-random pixel positions seeded by the secret [key]. The payload is
/// repeated [ForensicConfig.redundancy] times and recovered via majority vote,
/// providing resilience against minor image edits.
///
/// ```dart
/// final watermarked = ForensicWatermark.embed(
///   imageBytes: pngBytes,
///   payload: 'user@example.com',
///   key: 'secret-key',
/// );
///
/// final recovered = ForensicWatermark.extract(
///   imageBytes: watermarked,
///   key: 'secret-key',
/// );
/// print(recovered); // user@example.com
/// ```
class ForensicWatermark {
  ForensicWatermark._();

  /// Embeds [payload] invisibly into [imageBytes] using [key].
  ///
  /// Returns the watermarked image as PNG-encoded bytes.
  ///
  /// Throws [ArgumentError] if:
  /// - [payload] is empty
  /// - [key] is empty
  /// - [imageBytes] cannot be decoded as an image
  /// - The image has insufficient pixel capacity for the payload
  static Uint8List embed({
    required Uint8List imageBytes,
    required String payload,
    required String key,
    ForensicConfig config = const ForensicConfig(),
  }) {
    if (payload.isEmpty) {
      throw ArgumentError.value(payload, 'payload', 'must not be empty');
    }
    if (key.isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be empty');
    }

    final image = img.decodePng(imageBytes);
    if (image == null) {
      throw ArgumentError.value(
        imageBytes,
        'imageBytes',
        'could not decode PNG image',
      );
    }

    final payloadBytes = utf8.encode(payload);
    final bits = _buildBitStream(payloadBytes);
    final totalBits = bits.length * config.redundancy;
    final pixelCount = image.width * image.height;

    if (totalBits > (pixelCount * _kMaxCapacityFraction).floor()) {
      throw ArgumentError(
        'Payload too large: needs $totalBits positions but image only '
        'supports ${(pixelCount * _kMaxCapacityFraction).floor()} '
        '(${image.width}x${image.height} pixels at '
        '${(_kMaxCapacityFraction * 100).toInt()}% capacity)',
      );
    }

    final seed = _djb2(key);
    final rng = Random(seed);
    final used = <int>{};

    // Two-phase position generation (matches extract's two-phase read).
    const headerBits = 48; // 16-bit magic + 32-bit length
    final headerTotalBits = headerBits * config.redundancy;
    final payloadBitCount = payloadBytes.length * 8;
    final payloadTotalBits = payloadBitCount * config.redundancy;

    final headerPositions =
        _generatePositions(rng, pixelCount, headerTotalBits, used);
    final payloadPositions =
        _generatePositions(rng, pixelCount, payloadTotalBits, used);

    // Write header bits at header positions.
    final headerBitStream = bits.sublist(0, headerBits);
    var posIndex = 0;
    for (var copy = 0; copy < config.redundancy; copy++) {
      for (final bit in headerBitStream) {
        final pixelIndex = headerPositions[posIndex++];
        final x = pixelIndex % image.width;
        final y = pixelIndex ~/ image.width;
        final pixel = image.getPixel(x, y);
        pixel.b = (pixel.b.toInt() & ~1) | bit;
      }
    }

    // Write payload bits at payload positions.
    final payloadBitStream = bits.sublist(headerBits);
    posIndex = 0;
    for (var copy = 0; copy < config.redundancy; copy++) {
      for (final bit in payloadBitStream) {
        final pixelIndex = payloadPositions[posIndex++];
        final x = pixelIndex % image.width;
        final y = pixelIndex ~/ image.width;
        final pixel = image.getPixel(x, y);
        pixel.b = (pixel.b.toInt() & ~1) | bit;
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// Extracts a previously embedded payload from [imageBytes] using [key].
  ///
  /// Returns the payload string, or `null` if the key is wrong, no watermark
  /// is found, or the data is corrupted.
  static String? extract({
    required Uint8List imageBytes,
    required String key,
    ForensicConfig config = const ForensicConfig(),
  }) {
    if (key.isEmpty) return null;

    final image = img.decodePng(imageBytes);
    if (image == null) return null;

    final pixelCount = image.width * image.height;
    final seed = _djb2(key);

    // Phase 1: read header (16-bit magic + 32-bit length = 48 bits) per copy.
    const headerBits = 48;
    final headerTotalBits = headerBits * config.redundancy;

    if (headerTotalBits > (pixelCount * _kMaxCapacityFraction).floor()) {
      return null;
    }

    final rng = Random(seed);
    final used = <int>{};
    final headerPositions =
        _generatePositions(rng, pixelCount, headerTotalBits, used);

    final headerBitValues = <int>[];
    for (final pixelIndex in headerPositions) {
      final x = pixelIndex % image.width;
      final y = pixelIndex ~/ image.width;
      final pixel = image.getPixel(x, y);
      headerBitValues.add(pixel.b.toInt() & 1);
    }

    final headerVoted =
        _majorityVote(headerBitValues, headerBits, config.redundancy);

    // Verify magic number.
    var magic = 0;
    for (var i = 0; i < 16; i++) {
      magic = (magic << 1) | headerVoted[i];
    }
    if (magic != _kMagic) return null;

    // Read byte count.
    var byteCount = 0;
    for (var i = 16; i < 48; i++) {
      byteCount = (byteCount << 1) | headerVoted[i];
    }

    if (byteCount <= 0 || byteCount > 10 * 1024 * 1024) return null;

    // Phase 2: read payload bits.
    final payloadBitCount = byteCount * 8;
    final payloadTotalBits = payloadBitCount * config.redundancy;
    final totalBitsNeeded = headerTotalBits + payloadTotalBits;

    if (totalBitsNeeded > (pixelCount * _kMaxCapacityFraction).floor()) {
      return null;
    }

    final payloadPositions =
        _generatePositions(rng, pixelCount, payloadTotalBits, used);

    final payloadBitValues = <int>[];
    for (final pixelIndex in payloadPositions) {
      final x = pixelIndex % image.width;
      final y = pixelIndex ~/ image.width;
      final pixel = image.getPixel(x, y);
      payloadBitValues.add(pixel.b.toInt() & 1);
    }

    final payloadVoted =
        _majorityVote(payloadBitValues, payloadBitCount, config.redundancy);

    // Decode bits → bytes → UTF-8.
    final bytes = Uint8List(byteCount);
    for (var i = 0; i < byteCount; i++) {
      var byte = 0;
      for (var b = 0; b < 8; b++) {
        byte = (byte << 1) | payloadVoted[i * 8 + b];
      }
      bytes[i] = byte;
    }

    try {
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Builds the full bit stream: 16-bit magic + 32-bit length + payload bits.
  static List<int> _buildBitStream(List<int> payloadBytes) {
    final bits = <int>[];

    // 16-bit magic.
    for (var i = 15; i >= 0; i--) {
      bits.add((_kMagic >> i) & 1);
    }

    // 32-bit byte count.
    final byteCount = payloadBytes.length;
    for (var i = 31; i >= 0; i--) {
      bits.add((byteCount >> i) & 1);
    }

    // Payload bits.
    for (final byte in payloadBytes) {
      for (var i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1);
      }
    }

    return bits;
  }

  /// DJB2 hash — deterministic across platforms, no crypto dependency.
  static int _djb2(String input) {
    var hash = 5381;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) + hash + input.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Generates [count] unique random pixel indices in `[0, pixelCount)`.
  ///
  /// Uses Set-based collision avoidance with the given [rng]. The [used] set
  /// is shared across calls to ensure PRNG state stays consistent between
  /// the two-phase (header + payload) generation in both embed and extract.
  static List<int> _generatePositions(
    Random rng,
    int pixelCount,
    int count,
    Set<int> used,
  ) {
    final positions = <int>[];
    while (positions.length < count) {
      final pos = rng.nextInt(pixelCount);
      if (used.add(pos)) {
        positions.add(pos);
      }
    }
    return positions;
  }

  /// Majority-vote decoder for redundancy copies.
  ///
  /// Given [raw] bit values (length = [bitCount] * [redundancy]), returns
  /// [bitCount] bits where each bit is the majority across copies.
  static List<int> _majorityVote(List<int> raw, int bitCount, int redundancy) {
    final result = List<int>.filled(bitCount, 0);
    for (var i = 0; i < bitCount; i++) {
      var ones = 0;
      for (var c = 0; c < redundancy; c++) {
        ones += raw[c * bitCount + i];
      }
      result[i] = ones > redundancy ~/ 2 ? 1 : 0;
    }
    return result;
  }
}
