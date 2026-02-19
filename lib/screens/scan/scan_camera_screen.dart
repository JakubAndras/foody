import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/scan/scan_permission_screen.dart';
import 'package:diplomka/screens/scan/scan_preview_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScanMode { scanMeal, barcode, foodLabel }

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({
    super.key,
    this.initialMode = ScanMode.scanMeal,
  });

  final ScanMode initialMode;

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> with WidgetsBindingObserver {
  final GlobalKey _previewBoundaryKey = GlobalKey();
  CameraController? _cameraController;
  List<CameraDescription>? _availableCameras;
  CameraDescription? _activeBackCamera;
  CameraDescription? _wideBackCamera;
  CameraDescription? _ultraWideBackCamera;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _hasPermission = false;
  bool _permissionPermanentlyDenied = false;
  bool _showTip = false;
  bool _showNutritionTip = false;
  bool _isZoomed = true;
  bool _isFlashOn = false;
  Uint8List? _frozenPreviewBytes;
  int _freezeFrameToken = 0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  ScanMode _mode = ScanMode.scanMeal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mode = widget.initialMode;
    _showTip = false;
    _showNutritionTip = false;
    _initPermissionAndCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseCameraController();
    super.dispose();
  }

  void _releaseCameraController() {
    final controller = _cameraController;
    _cameraController = null;
    _activeBackCamera = null;
    _isInitialized = false;
    _isFlashOn = false;
    _isZoomed = true;
    _minZoomLevel = 1.0;
    _maxZoomLevel = 1.0;
    controller?.dispose().catchError((_) {});
  }

  Future<List<CameraDescription>> _getAvailableCameras() async {
    final cached = _availableCameras;
    if (cached != null) return cached;
    final cameras = await availableCameras();
    _availableCameras = cameras;
    return cameras;
  }

  Future<void> _capturePreviewFreezeFrame() async {
    final boundary = _previewBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    try {
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null || !mounted) return;
      final token = _freezeFrameToken + 1;
      setState(() {
        _freezeFrameToken = token;
        _frozenPreviewBytes = byteData.buffer.asUint8List();
      });
    } catch (_) {}
  }

  Future<void> _clearFrozenPreviewWhenStable(int token) async {
    // Keep the frozen frame briefly after init so first frames from new lens
    // are already stable when we reveal the live preview.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted || token != _freezeFrameToken) return;
    setState(() {
      _frozenPreviewBytes = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _releaseCameraController();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initPermissionAndCamera() async {
    setState(() {
      _isInitializing = true;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _hasPermission = false;
        _permissionPermanentlyDenied = status.isPermanentlyDenied;
        _isInitializing = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _permissionPermanentlyDenied = false;
    });

    await _initCamera();
  }

  Future<void> _initCamera() async {
    return _initCameraWithPreferredBackCamera();
  }

  Future<void> _initCameraWithPreferredBackCamera({
    CameraDescription? preferredBackCamera,
    bool preserveFlash = false,
  }) async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    try {
      final shouldRestoreFlash = preserveFlash && _isFlashOn;
      _releaseCameraController();
      final cameras = await _getAvailableCameras();
      final backCameras = cameras.where((camera) => camera.lensDirection == CameraLensDirection.back).toList();
      if (backCameras.isEmpty) {
        throw Exception('No back camera found');
      }

      CameraDescription? wideBackCamera;
      CameraDescription? ultraWideBackCamera;
      for (final camera in backCameras) {
        final cameraName = camera.name.toLowerCase();
        if (wideBackCamera == null &&
            (camera.lensType == CameraLensType.wide || (camera.lensType == CameraLensType.unknown && cameraName.contains('wide')))) {
          wideBackCamera = camera;
        }
        if (ultraWideBackCamera == null &&
            (camera.lensType == CameraLensType.ultraWide || (camera.lensType == CameraLensType.unknown && cameraName.contains('ultra')))) {
          ultraWideBackCamera = camera;
        }
      }
      wideBackCamera ??= backCameras.first;
      final isSelectingNormal = preferredBackCamera == null ? _isZoomed : preferredBackCamera != ultraWideBackCamera;
      final targetBackCamera = preferredBackCamera ?? (isSelectingNormal ? wideBackCamera : (ultraWideBackCamera ?? wideBackCamera));

      final controller = CameraController(
        targetBackCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      final normalZoom = 1.0.clamp(minZoom, maxZoom).toDouble();
      await controller.setZoomLevel(normalZoom);
      try {
        await controller.setFlashMode(shouldRestoreFlash ? FlashMode.torch : FlashMode.off);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _activeBackCamera = targetBackCamera;
        _wideBackCamera = wideBackCamera;
        _ultraWideBackCamera = ultraWideBackCamera;
        _isInitialized = true;
        _isInitializing = false;
        _isFlashOn = shouldRestoreFlash;
        _isZoomed = targetBackCamera != ultraWideBackCamera;
        _minZoomLevel = minZoom;
        _maxZoomLevel = maxZoom;
      });
      if (_frozenPreviewBytes != null) {
        _clearFrozenPreviewWhenStable(_freezeFrameToken);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _isInitializing = false;
        _frozenPreviewBytes = null;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final file = await _cameraController!.takePicture();
      if (!mounted) return;
      Get.to(() => ScanPreviewScreen(imagePath: file.path));
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final permission = await _requestGalleryPermission();
    if (!permission) return;
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (!mounted) return;
    Get.to(() => ScanPreviewScreen(imagePath: image.path));
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    final status = await Permission.storage.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  void _toggleMode(ScanMode mode) {
    setState(() {
      _mode = mode;
      // Never auto-open help. It should only appear from explicit help tap.
      _showTip = false;
      _showNutritionTip = false;
    });
  }

  Future<void> _setFlash(bool enabled) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
      if (!mounted) return;
      setState(() => _isFlashOn = enabled);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFlashOn = false);
    }
  }

  Future<void> _toggleFlash() async {
    await _setFlash(!_isFlashOn);
  }

  double _zoomLevelForSelection(bool isNormalZoom) {
    final target = isNormalZoom ? 1.0 : 0.5;
    return target.clamp(_minZoomLevel, _maxZoomLevel).toDouble();
  }

  Future<void> _setZoomSelection(bool isNormalZoom) async {
    final wideBackCamera = _wideBackCamera;
    final ultraWideBackCamera = _ultraWideBackCamera;
    if (wideBackCamera != null && ultraWideBackCamera != null) {
      final targetBackCamera = isNormalZoom ? wideBackCamera : ultraWideBackCamera;
      if (_activeBackCamera != targetBackCamera) {
        await _capturePreviewFreezeFrame();
        await _initCameraWithPreferredBackCamera(
          preferredBackCamera: targetBackCamera,
          preserveFlash: true,
        );
        return;
      }
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    final level = _zoomLevelForSelection(isNormalZoom);
    try {
      await controller.setZoomLevel(level);
      if (!mounted || _cameraController != controller) return;
      setState(() {
        _isZoomed = isNormalZoom;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return ScanPermissionScreen(
        isPermanentlyDenied: _permissionPermanentlyDenied,
        onRequestPermission: _initPermissionAndCamera,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildCameraSurface(),
          Column(
            children: [
              const ScanStatusBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildCameraTopBar(),
                    _buildScanFrame(),
                    //_buildHandleBar(),
                    _buildZoomToggle(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
          if (_showTip) _buildTipOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraSurface() {
    final hasLivePreview = _isInitialized && _cameraController != null;
    final hasFrozenPreview = _frozenPreviewBytes != null;

    return Stack(
      children: [
        if (hasLivePreview)
          RepaintBoundary(
            key: _previewBoundaryKey,
            child: _buildLiveCameraPreview(_cameraController!),
          )
        else if (hasFrozenPreview)
          _buildFrozenPreview()
        else
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.scanCameraSurface),
            child: !_isInitializing
                ? Center(
                    child: Text(
                      'Camera unavailable',
                      style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : null,
          ),
        if (hasFrozenPreview)
          Positioned.fill(
            child: IgnorePointer(
              child: _buildFrozenPreview(),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveCameraPreview(CameraController controller) {
    final previewSize = controller.value.previewSize ?? const Size(1, 1);
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildFrozenPreview() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.memory(
          _frozenPreviewBytes!,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  Widget _buildCameraTopBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ScanCircleButton(
              icon: Icons.close,
              onPressed: () => Get.back(),
            ),
            ScanCircleButton(
              icon: Icons.help_outline,
              onPressed: () {
                setState(() {
                  _showTip = !_showTip;
                  _showNutritionTip = _mode == ScanMode.foodLabel;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textTertiary,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    double frameWidth;
    double frameHeight;
    Color frameColor;

    switch (_mode) {
      case ScanMode.barcode:
        frameWidth = 340;
        frameHeight = 200;
        frameColor = AppColors.primary;
        break;
      case ScanMode.foodLabel:
        frameWidth = 288;
        frameHeight = 458;
        frameColor = AppColors.primary;
        break;
      case ScanMode.scanMeal:
        frameWidth = 340;
        frameHeight = 400;
        frameColor = AppColors.primary;
        break;
    }

    return Align(
      alignment: const Alignment(0, -0.1),
      child: ScanFrameCorners(width: frameWidth, height: frameHeight, color: frameColor),
    );
  }

  Widget _buildZoomToggle() {
    final hasLensSwitchOption = _wideBackCamera != null && _ultraWideBackCamera != null;
    final hasDifferentZoomSteps = hasLensSwitchOption || (_zoomLevelForSelection(true) - _zoomLevelForSelection(false)).abs() > 0.01;
    final enabled = _isInitialized && hasDifferentZoomSteps;
    return Align(
      alignment: const Alignment(0, 0.94),
      child: ScanZoomToggle(
        isEnabled: enabled,
        isZoomed: _isZoomed,
        onToggle: (value) async {
          if (!enabled) return;
          await _setZoomSelection(value);
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: AppSizes.scanBottomBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.button,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScanModeTile(
                label: 'Scan Meal',
                icon: Icons.center_focus_strong,
                isActive: _mode == ScanMode.scanMeal,
                onTap: () => _toggleMode(ScanMode.scanMeal),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.s),
              ScanModeTile(
                label: 'Barcode',
                icon: Icons.qr_code_2,
                isActive: _mode == ScanMode.barcode,
                onTap: () => _toggleMode(ScanMode.barcode),
                activeColor: AppColors.textHeading,
              ),
              const SizedBox(width: AppSpacing.s),
              ScanModeTile(
                label: 'Food label',
                icon: Icons.description_outlined,
                isActive: _mode == ScanMode.foodLabel,
                onTap: () => _toggleMode(ScanMode.foodLabel),
                activeColor: AppColors.textHeading,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 1,
                  child: ScanCircleButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onPressed: _toggleFlash,
                    backgroundColor: _isFlashOn ? AppColors.primary : AppColors.surfaceMuted,
                    shadow: const <BoxShadow>[],
                    size: AppSizes.scanAuxButtonSize,
                    iconSize: AppSizes.scanModeIconSize,
                    iconColor: _isFlashOn ? AppColors.onPrimary : AppColors.textEmphasisAlt,
                  ),
                ),
                ScanShutterButton(onPressed: _capturePhoto),
                ScanCircleButton(
                  icon: Icons.photo_library_outlined,
                  onPressed: _pickFromGallery,
                  backgroundColor: AppColors.surfaceMuted,
                  shadow: const <BoxShadow>[],
                  size: AppSizes.scanAuxButtonSize,
                  iconSize: AppSizes.scanModeIconSize,
                  iconColor: AppColors.textEmphasisAlt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipOverlay() {
    final isBarcode = _mode == ScanMode.barcode;
    final title = isBarcode ? 'Barcode Scanner' : 'Nutrition Label Scanner';
    final body =
        isBarcode ? 'Align the barcode within the frame.' : 'Get nutrition details from any label to track your intake accurately.';
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0, 0.8),
        child: ScanTipOverlay(
          title: title,
          body: body,
          onDismiss: () => setState(() => _showTip = false),
          child: _showNutritionTip ? const ScanNutritionLabelCard() : null,
        ),
      ),
    );
  }
}
