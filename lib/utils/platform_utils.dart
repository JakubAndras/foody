import 'dart:io' show Platform;

/// Runtime platform/device capability checks.
///
/// Android rendering strategy: Impeller is disabled via AndroidManifest.xml
/// (EnableImpeller=false) because multiple Android GPUs exhibit shader-related
/// rendering bugs (Mali-G52 texture allocation failure, Tensor G6 Y-axis flip).
/// This causes liquid_glass_widgets to gracefully skip its fragment shader
/// pipeline (ImageFilter.isShaderFilterSupported returns false on Skia).
class PlatformUtils {
  /// Whether the `variable_blur` GPU fragment shader is safe to use.
  ///
  /// Disabled on Android: on some Android GPUs (e.g. Samsung Mali-G52 on
  /// Galaxy A13) the gralloc4 HAL cannot allocate the R8 intermediate
  /// textures the shader requires, so its output is empty and scrollable
  /// content disappears. Rather than rely on per-device detection, the
  /// blur is iOS-only.
  static bool get useGpuBlurShader => Platform.isIOS;
}
