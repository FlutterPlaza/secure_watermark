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
      home: const WatermarkDemoPage(),
    );
  }
}

class WatermarkDemoPage extends StatefulWidget {
  const WatermarkDemoPage({super.key});

  @override
  State<WatermarkDemoPage> createState() => _WatermarkDemoPageState();
}

class _WatermarkDemoPageState extends State<WatermarkDemoPage> {
  bool _enabled = true;
  double _opacity = 0.15;
  double _angle = -30;
  double _fontSize = 16;
  bool _staggered = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Watermark Demo')),
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
          SafeArea(
            child: Padding(
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
