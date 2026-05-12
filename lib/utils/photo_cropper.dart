import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Arguments passed to the background-isolate crop function.
@immutable
class _CropArgs {
  const _CropArgs({required this.bytes, required this.targetAspectRatio, required this.jpegQuality});

  final Uint8List bytes;
  final double targetAspectRatio;
  final int jpegQuality;
}

/// Pure-Dart, isolate-based photo cropper that mirrors the on-screen
/// `BoxFit.cover` math used by the live camera preview, so the captured JPEG
/// contains the exact rectangle the user saw before pressing the shutter.
class PhotoCropper {
  PhotoCropper._();

  /// Crops [sourcePath] to [targetAspectRatio] (height / width, in the
  /// visually-upright orientation) using a centered cover-crop. Returns the
  /// path to the cropped JPEG, or [sourcePath] if cropping is unnecessary or
  /// fails (so the user is never blocked).
  static Future<String> cropCenterCoverToAspect({required String sourcePath, required double targetAspectRatio, int jpegQuality = 85}) async {
    if (!targetAspectRatio.isFinite || targetAspectRatio <= 0) {
      return sourcePath;
    }
    try {
      final bytes = await File(sourcePath).readAsBytes();
      final outBytes = await compute(_cropSync, _CropArgs(bytes: bytes, targetAspectRatio: targetAspectRatio, jpegQuality: jpegQuality));
      if (outBytes == null) return sourcePath;
      final outPath = _croppedJpegPathFor(sourcePath);
      await File(outPath).writeAsBytes(outBytes, flush: true);
      return outPath;
    } catch (_) {
      return sourcePath;
    }
  }

}

/// Top-level function so it can be dispatched via [compute].
Uint8List? _cropSync(_CropArgs args) {
  try {
    final decoded = img.decodeImage(args.bytes);
    if (decoded == null) return null;

    // Bake EXIF orientation so width/height match the upright (user-visible)
    // image; the `camera` plugin writes EXIF orientation rather than rotating
    // pixels, so cropping without baking would crop the wrong rectangle.
    final upright = img.bakeOrientation(decoded);

    final srcW = upright.width;
    final srcH = upright.height;
    if (srcW <= 0 || srcH <= 0) return null;
    final srcAspect = srcH / srcW;

    if ((srcAspect - args.targetAspectRatio).abs() < 0.001) {
      return Uint8List.fromList(img.encodeJpg(upright, quality: args.jpegQuality));
    }

    int cropW;
    int cropH;
    if (args.targetAspectRatio > srcAspect) {
      // Viewport is taller than the source: keep full height, crop left/right.
      cropH = srcH;
      cropW = (srcH / args.targetAspectRatio).round();
    } else {
      // Viewport is wider than the source: keep full width, crop top/bottom.
      cropW = srcW;
      cropH = (srcW * args.targetAspectRatio).round();
    }

    cropW = cropW.clamp(1, srcW);
    cropH = cropH.clamp(1, srcH);
    final x = ((srcW - cropW) / 2).round();
    final y = ((srcH - cropH) / 2).round();

    final cropped = img.copyCrop(upright, x: x, y: y, width: cropW, height: cropH);
    return Uint8List.fromList(img.encodeJpg(cropped, quality: args.jpegQuality));
  } catch (_) {
    return null;
  }
}

/// Returns a sibling path next to [sourcePath] with the suffix `_cropped.jpg`,
/// using the platform path separator. Avoids depending on `package:path` so
/// the utility stays self-contained.
String _croppedJpegPathFor(String sourcePath) {
  final separator = Platform.pathSeparator;
  final separatorIndex = sourcePath.lastIndexOf(separator);
  final dir = separatorIndex >= 0 ? sourcePath.substring(0, separatorIndex) : '';
  final fileName = separatorIndex >= 0 ? sourcePath.substring(separatorIndex + 1) : sourcePath;
  final dotIndex = fileName.lastIndexOf('.');
  final baseName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  final croppedName = '${baseName}_cropped.jpg';
  return dir.isEmpty ? croppedName : '$dir$separator$croppedName';
}
