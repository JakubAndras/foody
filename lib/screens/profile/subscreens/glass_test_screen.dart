import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class GlassTestScreen extends StatefulWidget {
  const GlassTestScreen({super.key});

  @override
  State<GlassTestScreen> createState() => _GlassTestScreenState();
}

class _GlassTestScreenState extends State<GlassTestScreen> {
  final viewController = LiquidGlassViewController();
  final lensController = LiquidGlassController();
  final bool _realtime = true;
  int _bgIndex = 0;

  static const _imageUrls = [
    'https://raw.githubusercontent.com/AhmeedGamil/liquid_glass_easy_assets/refs/heads/main/flower.jpg',
    'https://raw.githubusercontent.com/AhmeedGamil/liquid_glass_easy_assets/refs/heads/main/rain.jpg',
    'https://raw.githubusercontent.com/AhmeedGamil/liquid_glass_easy_assets/refs/heads/main/neon.png',
    'https://raw.githubusercontent.com/AhmeedGamil/liquid_glass_easy_assets/refs/heads/main/socotra_tree_1.png',
    'https://raw.githubusercontent.com/AhmeedGamil/liquid_glass_easy_assets/refs/heads/main/socotra_tree_2.jpg',
    'https://raw.githubusercontent.com/AhmeedGamil/liquid_glass_easy_assets/refs/heads/main/socotra_tree_3.jpg',
  ];

  Widget _buildBackground() {
    final fitModes = [BoxFit.fitWidth, BoxFit.fitHeight, BoxFit.cover, BoxFit.cover, BoxFit.cover, BoxFit.cover];
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          _imageUrls[_bgIndex],
          fit: fitModes[_bgIndex],
          width: double.infinity,
          height: double.infinity,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text(
              'Liquid Glass Test',
              style: TextStyle(fontSize: 26, color: Colors.black54, fontWeight: FontWeight.w700, letterSpacing: 0.25),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshSnapshot() async {
    lensController.hideLiquidGlass(animationTimeMillisecond: 280);
    await Future.delayed(const Duration(milliseconds: 340));
    await viewController.captureOnce();
    lensController.showLiquidGlass(animationTimeMillisecond: 280);
  }

  void _nextBackground() {
    setState(() {
      _bgIndex = (_bgIndex + 1) % _imageUrls.length;
    });
    if (!_realtime) {
      viewController.captureOnce();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassView(
        controller: viewController,
        backgroundWidget: _buildBackground(),
        pixelRatio: 1,
        useSync: true,
        realTimeCapture: _realtime,
        refreshRate: LiquidGlassRefreshRate.deviceRefreshRate,
        children: [
          _buildGlassForIndex(_bgIndex),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _refreshSnapshot,
                      icon: const Icon(CupertinoIcons.arrow_clockwise),
                      label: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextBackground,
                      icon: const Icon(CupertinoIcons.photo),
                      label: const Text('Next BG'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.xmark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  LiquidGlass _buildGlassForIndex(int index) {
    switch (index) {
      case 0:
        return LiquidGlass(
          controller: lensController,
          position: const LiquidGlassAlignPosition(alignment: Alignment.center),
          width: 100,
          height: 100,
          magnification: 1,
          enableInnerRadiusTransparent: false,
          diagonalFlip: 0,
          distortion: 0.1125,
          distortionWidth: 50,
          chromaticAberration: 0.002,
          draggable: true,
          outOfBoundaries: true,
          blur: LiquidGlassBlur(sigmaX: 0.75, sigmaY: 0.75),
          shape: RoundedRectangleShape(cornerRadius: 50, borderWidth: 1, borderSoftness: 2.5, lightIntensity: 1.5, lightDirection: 39.0),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(height: 50, width: 50, child: Icon(CupertinoIcons.pause, size: 36, color: Colors.white)),
            ),
          ),
        );
      case 1:
        return LiquidGlass(
          controller: lensController,
          position: const LiquidGlassAlignPosition(alignment: Alignment.center),
          width: 240 * 0.8,
          height: 312 * 0.8,
          magnification: 1,
          enableInnerRadiusTransparent: false,
          diagonalFlip: 0,
          distortion: 0.075,
          distortionWidth: 70,
          draggable: true,
          outOfBoundaries: true,
          chromaticAberration: 0.002,
          color: Colors.grey.withAlpha(60),
          blur: LiquidGlassBlur(sigmaX: 0.5, sigmaY: 0.5),
          shape: RoundedRectangleShape(
            cornerRadius: 70 * 0.8,
            borderWidth: 1,
            borderSoftness: 7.5,
            lightIntensity: 1.5 * 0.6,
            oneSideLightIntensity: 0.4,
            lightDirection: 39.0,
          ),
          visibility: true,
          child: Center(
            child: _WeatherWidget(
              cityName: 'City',
              description: 'Rainy',
              temperature: 23.4,
              minTemp: 22.0,
              maxTemp: 30.5,
              humidity: 58,
              windSpeed: 14.3,
              weatherIcon: CupertinoIcons.drop,
            ),
          ),
        );
      case 2:
        return LiquidGlass(
          position: const LiquidGlassAlignPosition(alignment: Alignment.center),
          width: 250,
          height: 250,
          magnification: 1,
          enableInnerRadiusTransparent: false,
          diagonalFlip: 0,
          distortion: 0.0875,
          distortionWidth: 80,
          chromaticAberration: 0.002,
          draggable: true,
          outOfBoundaries: true,
          blur: LiquidGlassBlur(sigmaX: 0, sigmaY: 0),
          shape: SuperellipseShape(curveExponent: 3, borderWidth: 1, borderSoftness: 1, lightIntensity: 1, lightDirection: 0),
        );
      case 3:
        return LiquidGlass(
          controller: lensController,
          width: 240,
          height: 200,
          magnification: 1,
          distortion: 0.25,
          draggable: true,
          distortionWidth: 70,
          chromaticAberration: 0.002,
          position: LiquidGlassAlignPosition(alignment: Alignment.center),
          shape: RoundedRectangleShape(lightDirection: 140, lightIntensity: 1.5, borderWidth: 2, borderSoftness: 1.5),
        );
      case 4:
        return LiquidGlass(
          controller: lensController,
          width: 240,
          height: 200,
          magnification: 1,
          distortion: 0.1,
          draggable: true,
          outOfBoundaries: true,
          distortionWidth: 70,
          chromaticAberration: 0.002,
          position: LiquidGlassAlignPosition(alignment: Alignment.center),
          shape: SuperellipseShape(lightDirection: 140, lightIntensity: 1.5, borderWidth: 2, borderSoftness: 1.5, curveExponent: 4),
        );
      case 5:
        return LiquidGlass(
          controller: lensController,
          width: 150,
          height: 150,
          magnification: 1,
          distortion: 0.075,
          draggable: true,
          outOfBoundaries: true,
          distortionWidth: 50,
          chromaticAberration: 0.002,
          position: LiquidGlassAlignPosition(alignment: Alignment.center),
          shape: RoundedRectangleShape(lightDirection: 140, lightIntensity: 1.5, borderWidth: 2, borderSoftness: 1.5, cornerRadius: 75),
        );
      default:
        return LiquidGlass(
          position: const LiquidGlassAlignPosition(alignment: Alignment.center),
          width: 100,
          height: 100,
          shape: RoundedRectangleShape(cornerRadius: 50),
        );
    }
  }
}

class _WeatherWidget extends StatelessWidget {
  final String cityName;
  final String description;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final double humidity;
  final double windSpeed;
  final IconData weatherIcon;

  const _WeatherWidget({
    required this.cityName,
    required this.description,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.windSpeed,
    this.weatherIcon = CupertinoIcons.sun_max_fill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300 * 0.8,
      padding: const EdgeInsets.all(21 * 0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * 0.8),
        border: Border.all(color: Colors.white.withAlpha(0), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cityName, style: const TextStyle(fontSize: 22 * 0.8, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(_formattedDate(), style: TextStyle(fontSize: 14 * 0.8, color: Colors.white.withAlpha(204))),
            ],
          ),
          const SizedBox(height: 16 * 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(weatherIcon, size: 44 * 0.8, color: Colors.white.withAlpha(229)),
              const SizedBox(width: 12 * 0.8),
              Text('${temperature.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 52 * 0.8, fontWeight: FontWeight.w700, color: Colors.white, height: 0.9)),
            ],
          ),
          const SizedBox(height: 8 * 0.8),
          Text(description, style: const TextStyle(fontSize: 18 * 0.8, fontWeight: FontWeight.w500, color: Colors.white70)),
          const SizedBox(height: 16 * 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tempInfo('Min', minTemp),
              const SizedBox(width: 16 * 0.8),
              _tempInfo('Max', maxTemp),
            ],
          ),
          const SizedBox(height: 16 * 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _extraInfo(CupertinoIcons.drop, 'Humidity', '$humidity%'),
              _extraInfo(CupertinoIcons.wind, 'Wind', '$windSpeed km/h'),
            ],
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Widget _tempInfo(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14 * 0.8, color: Colors.white.withAlpha(204))),
        Text('${value.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 16 * 0.8, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _extraInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withAlpha(229), size: 22 * 0.8),
        const SizedBox(height: 4 * 0.8),
        Text(label, style: TextStyle(fontSize: 12 * 0.8, color: Colors.white.withAlpha(179))),
        Text(value, style: const TextStyle(fontSize: 13 * 0.8, fontWeight: FontWeight.w500, color: Colors.white)),
      ],
    );
  }
}
