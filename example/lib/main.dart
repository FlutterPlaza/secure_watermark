import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_watermark/secure_watermark.dart';

void main() {
  runApp(const WatermarkExampleApp());
}

class WatermarkExampleApp extends StatelessWidget {
  const WatermarkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Watermark Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Home — tab navigation between visible and forensic demos
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  static const _pages = <Widget>[
    VisibleWatermarkPage(),
    ForensicWatermarkPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.visibility),
            label: 'Visible',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            label: 'Forensic',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Visible watermark (existing demo)
// ---------------------------------------------------------------------------

class VisibleWatermarkPage extends StatefulWidget {
  const VisibleWatermarkPage({super.key});

  @override
  State<VisibleWatermarkPage> createState() => _VisibleWatermarkPageState();
}

class _VisibleWatermarkPageState extends State<VisibleWatermarkPage> {
  bool _enabled = true;
  double _opacity = 0.15;
  double _angle = -30;
  double _fontSize = 16;
  bool _staggered = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visible Watermark')),
      body: Column(
        children: [
          Expanded(
            child: Watermark(
              text: 'user@example.com  2026-02-15',
              enabled: _enabled,
              style: WatermarkStyle(
                opacity: _opacity,
                rotate: _angle,
                fontSize: _fontSize,
                staggered: _staggered,
              ),
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'This content is protected by a visible watermark overlay. '
                    'Adjust the controls below to preview different styles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Watermark Enabled'),
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                ),
                _buildSlider(
                  label: 'Opacity',
                  value: _opacity,
                  min: 0.05,
                  max: 0.5,
                  onChanged: (v) => setState(() => _opacity = v),
                ),
                _buildSlider(
                  label: 'Angle',
                  value: _angle,
                  min: -90,
                  max: 90,
                  onChanged: (v) => setState(() => _angle = v),
                ),
                _buildSlider(
                  label: 'Font Size',
                  value: _fontSize,
                  min: 10,
                  max: 32,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
                SwitchListTile(
                  title: const Text('Staggered (Brick Pattern)'),
                  value: _staggered,
                  onChanged: (v) => setState(() => _staggered = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(value.toStringAsFixed(1), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Forensic (invisible) watermark
// ---------------------------------------------------------------------------

class ForensicWatermarkPage extends StatefulWidget {
  const ForensicWatermarkPage({super.key});

  @override
  State<ForensicWatermarkPage> createState() => _ForensicWatermarkPageState();
}

class _ForensicWatermarkPageState extends State<ForensicWatermarkPage> {
  final _payloadController = TextEditingController(text: 'user@example.com');
  final _keyController = TextEditingController(text: 'secret-key-123');
  int _redundancy = 5;

  Uint8List? _originalPng;
  Uint8List? _watermarkedPng;
  String? _extractedPayload;
  String? _error;
  bool _embedding = false;
  bool _extracting = false;

  @override
  void initState() {
    super.initState();
    _generateSampleImage();
  }

  /// Creates a simple gradient PNG as the source image.
  void _generateSampleImage() {
    // Build a 200x200 gradient PNG using the image package.
    // We use ForensicWatermark's dependency (image) indirectly here.
    // For the example, we create raw PNG bytes manually via a canvas.
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 200);

    // Draw a gradient background.
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw a white circle.
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      60,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    final picture = recorder.endRecording();
    picture.toImage(200, 200).then((image) {
      image.toByteData(format: ImageByteFormat.png).then((byteData) {
        if (mounted && byteData != null) {
          setState(() {
            _originalPng = byteData.buffer.asUint8List();
          });
        }
      });
    });
  }

  Future<void> _embed() async {
    if (_originalPng == null) return;
    setState(() {
      _embedding = true;
      _error = null;
      _watermarkedPng = null;
      _extractedPayload = null;
    });

    try {
      final result = ForensicWatermark.embed(
        imageBytes: _originalPng!,
        payload: _payloadController.text,
        key: _keyController.text,
        config: ForensicConfig(redundancy: _redundancy),
      );
      setState(() {
        _watermarkedPng = result;
        _embedding = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _embedding = false;
      });
    }
  }

  Future<void> _extract() async {
    if (_watermarkedPng == null) return;
    setState(() {
      _extracting = true;
      _extractedPayload = null;
      _error = null;
    });

    try {
      final payload = ForensicWatermark.extract(
        imageBytes: _watermarkedPng!,
        key: _keyController.text,
        config: ForensicConfig(redundancy: _redundancy),
      );
      setState(() {
        _extractedPayload = payload;
        _extracting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _extracting = false;
      });
    }
  }

  @override
  void dispose() {
    _payloadController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Forensic Watermark')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Source image preview
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child:
                      Text('Source Image', style: theme.textTheme.titleMedium),
                ),
                if (_originalPng != null)
                  Center(
                    child: Image.memory(
                      _originalPng!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _payloadController,
                    decoration: const InputDecoration(
                      labelText: 'Payload',
                      hintText: 'Data to embed invisibly',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Secret Key',
                      hintText: 'Key for PRNG seeding',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Redundancy: '),
                      DropdownButton<int>(
                        value: _redundancy,
                        items: const [1, 3, 5, 7, 9]
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text('$r'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _redundancy = v ?? 5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _originalPng != null && !_embedding ? _embed : null,
                  icon: _embedding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.lock),
                  label: const Text('Embed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed:
                      _watermarkedPng != null && !_extracting ? _extract : null,
                  icon: _extracting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open),
                  label: const Text('Extract'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Watermarked image preview
          if (_watermarkedPng != null)
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Watermarked Image',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Looks identical — the watermark is invisible!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.memory(
                      _watermarkedPng!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Extracted payload
          if (_extractedPayload != null)
            Card(
              color: theme.colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Extracted Payload'),
                subtitle: Text(
                  _extractedPayload!,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),

          if (_extractedPayload == null &&
              _watermarkedPng != null &&
              !_extracting &&
              _error == null)
            const SizedBox.shrink(),

          // Error
          if (_error != null)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.error),
                title: const Text('Error'),
                subtitle: Text(_error!),
              ),
            ),
        ],
      ),
    );
  }
}
