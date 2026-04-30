import 'dart:io' show Platform;

/// Runtime platform/device capability checks.
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
