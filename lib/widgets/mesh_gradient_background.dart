import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app_theme.dart';

/// A mesh-style gradient background with soft, blurred color blobs.
///
/// Mimics the premium multi-tone backgrounds seen in modern iOS apps
/// (e.g. Cal AI). Renders positioned radial gradient circles on a
/// near-white base to create a subtle, warm feel.
///
/// Usage:
/// ```dart
/// Stack(children: [
///   const MeshGradientBackground(),
///   // …your content
/// ])
/// ```
///
/// Or use [MeshGradientBackground.decoration] for a simpler single-layer
/// background on a Container/Scaffold:
/// ```dart
/// Scaffold(
///   body: Stack(children: [
///     const MeshGradientBackground(),
///     SafeArea(child: …),
///   ]),
/// )
/// ```
class MeshGradientBackground extends StatelessWidget {
  const MeshGradientBackground({
    super.key,
    this.blobs,
    this.baseColor,
  });

  /// Custom blob definitions. Falls back to [defaultBlobs].
  final List<MeshBlob>? blobs;

  /// Base fill behind all blobs. Defaults to [AppColors.meshBase].
  final Color? baseColor;

  /// Default set of blobs that produce a subtle warm-cool mesh.
  static const List<MeshBlob> defaultBlobs = [
    // Warm peach — upper right
    MeshBlob(
      color: AppColors.meshPeach,
      alignment: Alignment(0.85, -0.65),
      radius: 0.55,
    ),
    // Soft lavender — upper left
    MeshBlob(
      color: AppColors.meshLavender,
      alignment: Alignment(-0.75, -0.5),
      radius: 0.5,
    ),
    // Cool sky-blue — lower left
    MeshBlob(
      color: AppColors.meshSky,
      alignment: Alignment(-0.6, 0.7),
      radius: 0.45,
    ),
    // Gentle mint — lower right
    MeshBlob(
      color: AppColors.meshMint,
      alignment: Alignment(0.7, 0.55),
      radius: 0.4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MeshGradientPainter(
          blobs: blobs ?? defaultBlobs,
          baseColor: baseColor ?? AppColors.meshBase,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Describes a single colour blob in the mesh gradient.
class MeshBlob {
  const MeshBlob({
    required this.color,
    required this.alignment,
    this.radius = 0.5,
  });

  /// The blob colour (typically a light pastel).
  final Color color;

  /// Position inside the canvas, using [Alignment] semantics
  /// (-1 … +1 for each axis).
  final Alignment alignment;

  /// Radius as a fraction of the canvas diagonal (0 … 1).
  final double radius;
}

class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({required this.blobs, required this.baseColor});

  final List<MeshBlob> blobs;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill with base
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    final diagonal = size.longestSide;

    // 2. Draw each blob as a radial gradient
    for (final blob in blobs) {
      final center = blob.alignment.alongSize(size);
      final blobRadius = diagonal * blob.radius;

      final gradient = ui.Gradient.radial(
        center,
        blobRadius,
        [blob.color, blob.color.withAlpha(0)],
        [0.0, 1.0],
      );

      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = gradient
          ..blendMode = BlendMode.srcOver,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.blobs != blobs;
  }
}
