import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class AppLiquidGlassViewConfig {
  final double pixelRatio;
  final bool realTimeCapture;
  final bool useSync;
  final LiquidGlassRefreshRate refreshRate;

  const AppLiquidGlassViewConfig({
    this.pixelRatio = 0.8,
    this.realTimeCapture = true,
    this.useSync = true,
    this.refreshRate = LiquidGlassRefreshRate.high,
  });
}

class AppLiquidGlassLensConfig {
  final double magnification;
  final LiquidGlassRefractionMode refractionMode;
  final double distortion;
  final double distortionWidth;
  final double diagonalFlip;
  final LiquidGlassShape shape;
  final LiquidGlassBlur blur;
  final double chromaticAberration;
  final double saturation;
  final bool enableInnerRadiusTransparent;
  final bool outOfBoundaries;
  final Color color;

  const AppLiquidGlassLensConfig({
    this.magnification = 1,
    this.refractionMode = LiquidGlassRefractionMode.shapeRefraction,
    this.distortion = 0.1,
    this.distortionWidth = 30,
    this.diagonalFlip = 0,
    this.shape = const RoundedRectangleShape(),
    this.blur = const LiquidGlassBlur(),
    this.chromaticAberration = 0.003,
    this.saturation = 1,
    this.enableInnerRadiusTransparent = false,
    this.outOfBoundaries = false,
    this.color = Colors.transparent,
  });

  LiquidGlass build({
    required double width,
    required double height,
    required LiquidGlassPosition position,
    Widget? child,
    bool draggable = false,
    bool visibility = true,
    LiquidGlassController? controller,
  }) {
    return LiquidGlass(
      controller: controller,
      width: width,
      height: height,
      magnification: magnification,
      refractionMode: refractionMode,
      distortion: distortion,
      distortionWidth: distortionWidth,
      diagonalFlip: diagonalFlip,
      draggable: draggable,
      position: position,
      shape: shape,
      blur: blur,
      chromaticAberration: chromaticAberration,
      saturation: saturation,
      enableInnerRadiusTransparent: enableInnerRadiusTransparent,
      visibility: visibility,
      color: color,
      outOfBoundaries: outOfBoundaries,
      child: child,
    );
  }
}

class AppLiquidGlassPresets {
  static const AppLiquidGlassViewConfig mainTabView = AppLiquidGlassViewConfig(
    pixelRatio: 0.72,
    realTimeCapture: true,
    useSync: true,
    refreshRate: LiquidGlassRefreshRate.high,
  );

  static const AppLiquidGlassLensConfig mainTabBarLens = AppLiquidGlassLensConfig(
    magnification: 1.0,
    refractionMode: LiquidGlassRefractionMode.shapeRefraction,
    distortion: 0.09,
    distortionWidth: 16,
    shape: RoundedRectangleShape(
      cornerRadius: AppRadii.pill,
      borderWidth: 0.8,
      borderSoftness: 1.4,
      lightIntensity: 2,
      oneSideLightIntensity: 1.0,
      lightDirection: 315,
      lightMode: LiquidGlassLightMode.edge,
      lightColor: Color(0x00000000),
      shadowColor: Color(0x00000000), // 0x00000000 // 0x80FFFFFF
    ),
    blur: LiquidGlassBlur(sigmaX: 1.5, sigmaY: 1.5),
    chromaticAberration: 0,
    saturation: 1.05,
    color: Color(0x70FFFFFF),
  );

  static const AppLiquidGlassLensConfig basicButtonLens = AppLiquidGlassLensConfig(
    magnification: 1.0,
    refractionMode: LiquidGlassRefractionMode.shapeRefraction,
    distortion: 0.09,
    distortionWidth: 12,
    shape: RoundedRectangleShape(
      cornerRadius: AppRadii.pill,
      borderWidth: 0.8,
      borderSoftness: 1.4,
      lightIntensity: 2,
      oneSideLightIntensity: 1.0,
      lightDirection: 315,
      lightMode: LiquidGlassLightMode.edge,
      lightColor: Color(0x00000000),
      shadowColor: Color(0x00000000), // 0x00000000 // 0x80FFFFFF
    ),
    blur: LiquidGlassBlur(sigmaX: 1.5, sigmaY: 1.5),
    chromaticAberration: 0,
    saturation: 1.05,
    color: Color(0x70FFFFFF),
  );

  static const AppLiquidGlassViewConfig calendarSheet = AppLiquidGlassViewConfig(
    pixelRatio: 0.72,
    realTimeCapture: true,
    useSync: true,
    refreshRate: LiquidGlassRefreshRate.high,
  );

  static const AppLiquidGlassLensConfig calendarSheetLens = AppLiquidGlassLensConfig(
    magnification: 1.01,
    distortion: 0.08,
    distortionWidth: 22,
    shape: RoundedRectangleShape(
      cornerRadius: AppRadii.lg,
      borderWidth: 1.2,
      borderSoftness: 1.2,
      lightIntensity: 1.25,
      oneSideLightIntensity: 0.7,
      lightDirection: 210,
    ),
    blur: LiquidGlassBlur(sigmaX: 4, sigmaY: 4),
    chromaticAberration: 0.002,
    saturation: 1.03,
    color: Color(0x40FFFFFF),
  );
}

class AppLiquidGlassLayer extends StatelessWidget {
  final Widget backgroundWidget;
  final List<LiquidGlass> children;
  final AppLiquidGlassViewConfig viewConfig;
  final LiquidGlassViewController? controller;

  const AppLiquidGlassLayer({
    super.key,
    required this.backgroundWidget,
    required this.children,
    this.viewConfig = AppLiquidGlassPresets.mainTabView,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassView(
      controller: controller,
      backgroundWidget: backgroundWidget,
      children: children,
      pixelRatio: viewConfig.pixelRatio,
      realTimeCapture: viewConfig.realTimeCapture,
      useSync: viewConfig.useSync,
      refreshRate: viewConfig.refreshRate,
    );
  }
}
