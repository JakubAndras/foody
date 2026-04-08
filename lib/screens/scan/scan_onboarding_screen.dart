import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';

class ScanOnboardingScreen extends StatefulWidget {
  const ScanOnboardingScreen({super.key, this.forceShow = false});

  final bool forceShow;

  @override
  State<ScanOnboardingScreen> createState() => _ScanOnboardingScreenState();
}

class _ScanOnboardingScreenState extends State<ScanOnboardingScreen> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  List<_ScanOnboardingPageData> get _pages => [
    _ScanOnboardingPageData(
      image: 'assets/images/scan_onboarding_1.png',
      title: tr(LocaleKeys.scan_best_scan),
      bullets: [
        _BulletData(icon: CupertinoIcons.camera, label: tr(LocaleKeys.scan_hold_still)),
        _BulletData(icon: CupertinoIcons.sun_max, label: tr(LocaleKeys.scan_use_light)),
        _BulletData(icon: CupertinoIcons.eye, label: tr(LocaleKeys.scan_ensure_visible)),
      ],
    ),
    _ScanOnboardingPageData(
      image: 'assets/images/scan_onboarding_2.png',
      title: tr(LocaleKeys.scan_ai_analyzes),
      bullets: [
        _BulletData(icon: CupertinoIcons.camera, label: tr(LocaleKeys.scan_ingredients_identified)),
        _BulletData(icon: CupertinoIcons.bolt, label: tr(LocaleKeys.scan_takes_few_seconds)),
        _BulletData(icon: CupertinoIcons.clock, label: tr(LocaleKeys.scan_see_calories_macros)),
      ],
    ),
    _ScanOnboardingPageData(
      image: 'assets/images/scan_onboarding_3.png',
      title: tr(LocaleKeys.scan_fix_results),
      bullets: [
        _BulletData(icon: CupertinoIcons.sparkles, label: tr(LocaleKeys.scan_check_accurate)),
        _BulletData(icon: CupertinoIcons.add_circled, label: tr(LocaleKeys.scan_add_remove_ingredients)),
        _BulletData(icon: CupertinoIcons.search, label: tr(LocaleKeys.scan_tap_fix)),
      ],
    ),
    _ScanOnboardingPageData(
      image: 'assets/images/scan_onboarding_4.png',
      title: tr(LocaleKeys.scan_highest_accuracy),
      bullets: [
        _BulletData(icon: CupertinoIcons.sparkles, label: tr(LocaleKeys.scan_add_text_description)),
        _BulletData(icon: CupertinoIcons.qrcode, label: tr(LocaleKeys.scan_scan_the_barcode)),
        _BulletData(icon: CupertinoIcons.doc_text, label: tr(LocaleKeys.scan_photo_food_label)),
      ],
    ),
    _ScanOnboardingPageData(
      image: 'assets/images/scan_onboarding_5.png',
      title: tr(LocaleKeys.scan_fastest_process),
      bullets: [
        _BulletData(icon: CupertinoIcons.flame, label: tr(LocaleKeys.scan_cooking_own_meal)),
        _BulletData(icon: CupertinoIcons.photo_on_rectangle, label: tr(LocaleKeys.scan_capture_together)),
        _BulletData(icon: CupertinoIcons.bolt, label: tr(LocaleKeys.scan_save_time)),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.forceShow && SessionManager.to.scanOnboardingComplete.value) {
        Get.off(() => const ScanCameraScreen());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _back() {
    if (_activeIndex == 0) {
      Get.back();
    } else {
      _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
    }
  }

  void _next() {
    if (_activeIndex == _pages.length - 1) {
      SessionManager.to.setScanOnboardingComplete(true);
      Get.to(() => const ScanCameraScreen());
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _activeIndex == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScanIndicatorDots(count: _pages.length, activeIndex: _activeIndex),
              const SizedBox(height: AppSpacing.m),
              SizedBox(
                width: double.infinity,
                child: ScanPrimaryButton(
                  label: isLastPage ? tr(LocaleKeys.scan_scan_now) : tr(LocaleKeys.common_next),
                  onPressed: _next,
                  height: AppSizes.buttonHeight,
                ),
              ),
            ],
          ),
        ),
      ),
      body: LiquidGlassScope(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _activeIndex = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return _ScanOnboardingPage(data: data);
                },
              ),
              Positioned(
                top: AppSpacing.s,
                left: AppSpacing.screen,
                child: CustomGlassIconButton(
                  icon: CupertinoIcons.chevron_left,
                  iconSize: AppSizes.iconLg,
                  onPressed: _back,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOnboardingPage extends StatelessWidget {
  const _ScanOnboardingPage({
    required this.data,
  });

  final _ScanOnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    const bottomOverlayReserve = AppSpacing.xl + AppSizes.scanIndicatorDot + AppSpacing.m + AppSizes.buttonHeight + AppSpacing.bottom;
    return Column(
      children: [
        _buildImageHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: bottomOverlayReserve,
            ),
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    final imageHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(300.0, 440.0);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppRadii.xl),
        bottomRight: Radius.circular(AppRadii.xl),
      ),
      child: Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.scanPlaceholder,
        ),
        child: Image.asset(data.image, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w500, height: 1.214)),
          const SizedBox(height: AppSpacing.l),
          for (final bullet in data.bullets) ...[
            ScanBulletRow(icon: bullet.icon, label: bullet.label),
            const SizedBox(height: AppSpacing.screen),
          ],
        ],
      ),
    );
  }
}

class _ScanOnboardingPageData {
  const _ScanOnboardingPageData({
    required this.image,
    required this.title,
    required this.bullets,
  });

  final String image;
  final String title;
  final List<_BulletData> bullets;
}

class _BulletData {
  const _BulletData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
