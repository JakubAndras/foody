import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/scan/scan_permission_screen.dart';
import 'package:diplomka/screens/scan/scan_preview_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  final BarcodeLookupService _barcodeLookupService = BarcodeLookupService.to;
  final MobileScannerController _barcodeScannerController = MobileScannerController(
    formats: const <BarcodeFormat>[
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    autoStart: false,
  );

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
  bool _isBarcodeRecognitionTriggered = false;
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
    _barcodeScannerController.dispose();
    super.dispose();
  }

  void _releaseCameraController() {
    final controller = _cameraController;
    _cameraController = null;
    _activeBackCamera = null;
    _isInitialized = false;
    _isFlashOn = false;
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted || token != _freezeFrameToken) return;
    setState(() {
      _frozenPreviewBytes = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _releaseCameraController();
      _pauseBarcodeScanner();
    } else if (state == AppLifecycleState.resumed) {
      if (_mode == ScanMode.barcode) {
        _resumeBarcodeScanner();
      } else {
        _initCamera();
      }
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

    if (_mode == ScanMode.barcode) {
      _isBarcodeRecognitionTriggered = false;
      await _resumeBarcodeScanner();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
      });
      return;
    }

    await _initCamera();
  }

  Future<void> _initCamera() async {
    if (_mode == ScanMode.barcode) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
      });
      return;
    }
    await _initCameraWithPreferredBackCamera();
  }

  Future<void> _initCameraWithPreferredBackCamera({
    CameraDescription? preferredBackCamera,
    bool preserveFlash = false,
  }) async {
    if (_mode == ScanMode.barcode) return;
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
    if (_mode == ScanMode.barcode) return;
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

  Future<void> _toggleMode(ScanMode mode) async {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _showTip = false;
      _showNutritionTip = false;
      _isFlashOn = false;
    });

    if (!_hasPermission) return;

    if (mode == ScanMode.barcode) {
      _isBarcodeRecognitionTriggered = false;
      _releaseCameraController();
      await _resumeBarcodeScanner();
      return;
    }

    await _pauseBarcodeScanner();
    await _initCamera();
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
    if (_mode == ScanMode.barcode) {
      await _toggleBarcodeTorch();
      return;
    }
    await _setFlash(!_isFlashOn);
  }

  Future<void> _toggleBarcodeTorch() async {
    try {
      await _barcodeScannerController.toggleTorch();
      if (!mounted) return;
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFlashOn = false);
    }
  }

  double _zoomLevelForSelection(bool isNormalZoom) {
    final target = isNormalZoom ? 1.0 : 0.5;
    return target.clamp(_minZoomLevel, _maxZoomLevel).toDouble();
  }

  Future<void> _setZoomSelection(bool isNormalZoom) async {
    if (_mode == ScanMode.barcode) return;
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

  Future<void> _setBarcodeZoom(bool isNormalZoom) async {
    try {
      final scale = isNormalZoom ? 0.5 : 0.0;
      await _barcodeScannerController.setZoomScale(scale);
      if (!mounted) return;
      setState(() => _isZoomed = isNormalZoom);
    } catch (_) {}
  }

  Future<void> _pauseBarcodeScanner() async {
    try {
      await _barcodeScannerController.stop();
    } catch (_) {}
  }

  Future<void> _resumeBarcodeScanner() async {
    if (_mode != ScanMode.barcode || !_hasPermission) return;
    try {
      await _barcodeScannerController.start();
      final scale = _isZoomed ? 0.5 : 0.0;
      await _barcodeScannerController.setZoomScale(scale);
    } catch (_) {}
  }

  Future<void> _restartBarcodeScan() async {
    _isBarcodeRecognitionTriggered = false;
    await _resumeBarcodeScanner();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_mode != ScanMode.barcode || _isBarcodeRecognitionTriggered) return;
    final rawValue = _readFirstBarcode(capture);
    if (rawValue == null) return;
    final normalized = _barcodeLookupService.normalizeBarcode(rawValue);
    if (normalized == null || !_barcodeLookupService.isSupportedBarcode(normalized)) {
      return;
    }
    await _startUnifiedBarcodeFlow(barcode: normalized);
  }

  String? _readFirstBarcode(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        return raw;
      }
    }
    return null;
  }

  Future<void> _startUnifiedBarcodeFlow({
    required String barcode,
  }) async {
    if (_isBarcodeRecognitionTriggered) return;
    _isBarcodeRecognitionTriggered = true;
    _pauseBarcodeScanner();
    if (!mounted) return;

    final selectedDate = SelectedDateService.to.selectedDate.value;
    DashboardController.to.analyzeMealFromBarcode(
      selectedDate: selectedDate,
      barcode: barcode,
    );

    if (Get.isRegistered<MainScreenController>()) {
      MainScreenController.to.showDashboardTab();
    }
    Get.until((route) => route.isFirst);
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
              SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Stack(
                  children: [
                    _buildCameraTopBar(),
                    if (!_showTip) _buildScanFrame(),
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
    if (_mode == ScanMode.barcode) {
      return _buildBarcodeSurface();
    }

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
                      tr(LocaleKeys.scan_camera_unavailable),
                      style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.onPrimary),
                  ),
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

  Widget _buildBarcodeSurface() {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _barcodeScannerController,
          fit: BoxFit.cover,
          onDetect: _onBarcodeDetected,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.overlayDark40,
                    Colors.transparent,
                    AppColors.overlayDark40,
                  ],
                ),
              ),
            ),
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
          left: AppSpacing.m,
          right: AppSpacing.m,
          top: AppSpacing.xl,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ScanCircleButton(
              icon: CupertinoIcons.xmark,
              onPressed: () => Get.back(),
              child: GlassStrokeIcon.close(),
            ),
            ScanCircleButton(
              icon: CupertinoIcons.info,
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
    if (_mode == ScanMode.barcode) {
      return Align(
        alignment: const Alignment(0, 0.94),
        child: ScanZoomToggle(
          isEnabled: true,
          isZoomed: _isZoomed,
          onToggle: (value) async {
            await _setBarcodeZoom(value);
          },
        ),
      );
    }

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
                label: tr(LocaleKeys.scan_scan_meal),
                icon: CupertinoIcons.viewfinder,
                isActive: _mode == ScanMode.scanMeal,
                onTap: () => _toggleMode(ScanMode.scanMeal),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.s),
              ScanModeTile(
                label: tr(LocaleKeys.scan_barcode),
                icon: CupertinoIcons.qrcode_viewfinder,
                isActive: _mode == ScanMode.barcode,
                onTap: () => _toggleMode(ScanMode.barcode),
                activeColor: AppColors.textHeading,
              ),
              const SizedBox(width: AppSpacing.s),
              ScanModeTile(
                label: tr(LocaleKeys.scan_food_label),
                icon: CupertinoIcons.doc_text,
                isActive: _mode == ScanMode.foodLabel,
                onTap: () => _toggleMode(ScanMode.foodLabel),
                activeColor: AppColors.textHeading,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: _mode == ScanMode.barcode ? _buildBarcodeControls() : _buildPhotoControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ScanCircleButton(
          icon: _isFlashOn ? Icons.flash_on : CupertinoIcons.bolt_slash,
          onPressed: _toggleFlash,
          backgroundColor: _isFlashOn ? AppColors.primary : AppColors.surfaceMuted,
          shadow: const <BoxShadow>[],
          size: AppSizes.scanAuxButtonSize,
          iconSize: AppSizes.scanIconSize,
          iconColor: _isFlashOn ? AppColors.onPrimary : AppColors.textEmphasis,
        ),
        ScanShutterButton(onPressed: _capturePhoto),
        ScanCircleButton(
          icon: CupertinoIcons.photo_on_rectangle,
          onPressed: _pickFromGallery,
          backgroundColor: AppColors.surfaceMuted,
          shadow: const <BoxShadow>[],
          size: AppSizes.scanAuxButtonSize,
          iconSize: AppSizes.scanIconSize,
          iconColor: AppColors.textEmphasis,
        ),
      ],
    );
  }

  Widget _buildBarcodeControls() {
    return SizedBox(
      height: AppSizes.scanShutterSize,
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ScanCircleButton(
          icon: _isFlashOn ? Icons.flash_on : CupertinoIcons.bolt_slash,
          onPressed: _toggleFlash,
          backgroundColor: _isFlashOn ? AppColors.primary : AppColors.surfaceMuted,
          shadow: const <BoxShadow>[],
          size: AppSizes.scanAuxButtonSize,
          iconSize: AppSizes.scanIconSize,
          iconColor: _isFlashOn ? AppColors.onPrimary : AppColors.textEmphasis,
        ),
        ScanCircleButton(
          icon: CupertinoIcons.arrow_clockwise,
          onPressed: _restartBarcodeScan,
          backgroundColor: AppColors.surfaceMuted,
          shadow: const <BoxShadow>[],
          size: AppSizes.scanAuxButtonSize,
          iconSize: AppSizes.scanIconSize,
          iconColor: AppColors.textEmphasis,
        ),
      ],
      ),
    );
  }

  Widget _buildTipOverlay() {
    final String title;
    final String body;
    final Widget? child;

    switch (_mode) {
      case ScanMode.scanMeal:
        title = tr(LocaleKeys.scan_meal_photo_tips_title);
        body = '';
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScanBulletRow(icon: CupertinoIcons.viewfinder, label: tr(LocaleKeys.scan_meal_tip_center_food)),
            const SizedBox(height: AppSpacing.s),
            ScanBulletRow(icon: CupertinoIcons.sun_max, label: tr(LocaleKeys.scan_meal_tip_good_lighting)),
            const SizedBox(height: AppSpacing.s),
            ScanBulletRow(icon: CupertinoIcons.eye, label: tr(LocaleKeys.scan_meal_tip_include_all)),
            const SizedBox(height: AppSpacing.s),
            ScanBulletRow(icon: CupertinoIcons.pencil, label: tr(LocaleKeys.scan_meal_tip_add_description)),
          ],
        );
      case ScanMode.barcode:
        title = tr(LocaleKeys.scan_barcode_scanner_title);
        body = tr(LocaleKeys.scan_barcode_scanner_body);
        child = null;
      case ScanMode.foodLabel:
        title = tr(LocaleKeys.scan_nutrition_label_title);
        body = tr(LocaleKeys.scan_nutrition_label_body);
        child = _showNutritionTip ? const ScanNutritionLabelCard() : null;
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showTip = false),
        child: ColoredBox(
          color: AppColors.overlayDark40,
          child: Align(
            alignment: const Alignment(0, -0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: ScanTipOverlay(
                title: title,
                body: body,
                onDismiss: () => setState(() => _showTip = false),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

