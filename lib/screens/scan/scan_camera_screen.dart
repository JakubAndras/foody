import 'dart:io';

import 'package:camera/camera.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/scan/scan_permission_screen.dart';
import 'package:diplomka/screens/scan/scan_preview_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:flutter/material.dart';
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
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _hasPermission = false;
  bool _permissionPermanentlyDenied = false;
  bool _showTip = false;
  bool _showNutritionTip = false;
  bool _isZoomed = true;
  ScanMode _mode = ScanMode.scanMeal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mode = widget.initialMode;
    _showTip = _mode != ScanMode.scanMeal;
    _showNutritionTip = _mode == ScanMode.foodLabel;
    _initPermissionAndCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
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
    if (_isInitializing) {
      setState(() {
        _isInitializing = true;
      });
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _isInitialized = true;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _isInitializing = false;
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
      if (mode == ScanMode.barcode) {
        _showTip = true;
        _showNutritionTip = false;
      } else if (mode == ScanMode.foodLabel) {
        _showTip = true;
        _showNutritionTip = true;
      } else {
        _showTip = false;
        _showNutritionTip = false;
      }
    });
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
                    _buildHandleBar(),
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
    if (_isInitialized && _cameraController != null) {
      final previewSize = _cameraController!.value.previewSize ?? const Size(1, 1);
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(_cameraController!),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.scanCameraSurface),
      child: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                'Camera unavailable',
                style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
              ),
            ),
    );
  }

  Widget _buildCameraTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.screen),
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
        frameColor = AppColors.textEmphasisAlt;
        break;
      case ScanMode.foodLabel:
        frameWidth = 288;
        frameHeight = 458;
        frameColor = AppColors.textEmphasisAlt;
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
    final enabled = _mode == ScanMode.scanMeal;
    return Align(
      alignment: const Alignment(0, 0.55),
      child: ScanZoomToggle(
        isEnabled: enabled,
        isZoomed: _isZoomed,
        onToggle: (value) {
          if (!enabled) return;
          setState(() => _isZoomed = value);
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
          const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(width: AppSpacing.sm),
              ScanModeTile(
                label: 'Barcode',
                icon: Icons.qr_code_2,
                isActive: _mode == ScanMode.barcode,
                onTap: () => _toggleMode(ScanMode.barcode),
                activeColor: AppColors.textHeading,
              ),
              const SizedBox(width: AppSpacing.sm),
              ScanModeTile(
                label: 'Food label',
                icon: Icons.description_outlined,
                isActive: _mode == ScanMode.foodLabel,
                onTap: () => _toggleMode(ScanMode.foodLabel),
                activeColor: AppColors.textHeading,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: _mode == ScanMode.scanMeal ? 1 : AppOpacities.disabled,
                  child: ScanCircleButton(
                    icon: Icons.flash_on,
                    onPressed: _mode == ScanMode.scanMeal ? () {} : null,
                    backgroundColor: AppColors.surfaceMuted,
                    shadow: const <BoxShadow>[],
                    size: AppSizes.scanAuxButtonSize,
                    iconSize: AppSizes.scanModeIconSize,
                    iconColor: AppColors.textEmphasisAlt,
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
    final body = isBarcode
        ? 'Align the barcode within the frame.'
        : 'Get nutrition details from any label to track your intake accurately.';
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: ScanTipOverlay(
            title: title,
            body: body,
            onDismiss: () => setState(() => _showTip = false),
            child: _showNutritionTip ? const ScanNutritionLabelCard() : null,
          ),
        ),
      ),
    );
  }
}
