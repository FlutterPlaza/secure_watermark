import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:secure_watermark/forensic_config.dart';
import 'package:secure_watermark/forensic_watermark.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('input',
        abbr: 'i', help: 'Input PNG file path', mandatory: true)
    ..addOption('output',
        abbr: 'o', help: 'Output PNG file path', mandatory: true)
    ..addOption('payload', abbr: 'p', help: 'Payload to embed', mandatory: true)
    ..addOption('key', abbr: 'k', help: 'Secret key', mandatory: true)
    ..addOption('redundancy',
        abbr: 'r', help: 'Redundancy (odd positive int)', defaultsTo: '5')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln();
    stderr.writeln('Usage: dart run secure_watermark:embed [options]');
    stderr.writeln(parser.usage);
    exit(64); // EX_USAGE
  }

  if (args.flag('help')) {
    stdout.writeln('Embed a forensic watermark into a PNG image.');
    stdout.writeln();
    stdout.writeln('Usage: dart run secure_watermark:embed [options]');
    stdout.writeln(parser.usage);
    exit(0);
  }

  final inputPath = args.option('input')!;
  final outputPath = args.option('output')!;
  final payload = args.option('payload')!;
  final key = args.option('key')!;
  final redundancy = int.tryParse(args.option('redundancy')!);

  if (redundancy == null || redundancy <= 0 || redundancy.isEven) {
    stderr.writeln('Error: redundancy must be a positive odd integer');
    exit(64);
  }

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Error: input file not found: $inputPath');
    exit(66); // EX_NOINPUT
  }

  final imageBytes = Uint8List.fromList(inputFile.readAsBytesSync());
  final config = ForensicConfig(redundancy: redundancy);

  try {
    final result = ForensicWatermark.embed(
      imageBytes: imageBytes,
      payload: payload,
      key: key,
      config: config,
    );
    File(outputPath).writeAsBytesSync(result);
    stdout.writeln('Watermark embedded successfully: $outputPath');
  } on ArgumentError catch (e) {
    stderr.writeln('Error: ${e.message}');
    exit(65); // EX_DATAERR
  }
}
