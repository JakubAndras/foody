import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanOnboardingScreen extends StatefulWidget {
  const ScanOnboardingScreen({super.key});

  @override
  State<ScanOnboardingScreen> createState() => _ScanOnboardingScreenState();
}

class _ScanOnboardingScreenState extends State<ScanOnboardingScreen> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  final List<_ScanOnboardingPageData> _pages = const [
    _ScanOnboardingPageData(
      title: 'Get the best scan:',
      bullets: [
        _BulletData(icon: Icons.photo_camera_outlined, label: 'Hold still'),
        _BulletData(icon: Icons.wb_sunny_outlined, label: 'Use lots of light'),
        _BulletData(icon: Icons.visibility_outlined, label: 'Ensure all ingredients are visible'),
      ],
    ),
    _ScanOnboardingPageData(
      title: 'AI analyzes your food',
      bullets: [
        _BulletData(icon: Icons.camera_outlined, label: 'Ingredients are identified'),
        _BulletData(icon: Icons.flash_on_outlined, label: 'Takes a few seconds'),
        _BulletData(icon: Icons.schedule_outlined, label: 'You\'ll see the calories and macros'),
      ],
    ),
    _ScanOnboardingPageData(
      title: 'Fix results, if necessary',
      bullets: [
        _BulletData(icon: Icons.auto_awesome_outlined, label: 'Check that the AI analysis is accurate'),
        _BulletData(icon: Icons.add_circle_outline, label: 'Add or remove ingredients as needed'),
        _BulletData(icon: Icons.search_outlined, label: 'Tap "Fix Results" if something\'s off'),
      ],
    ),
    _ScanOnboardingPageData(
      title: 'For highest accuracy:',
      bullets: [
        _BulletData(icon: Icons.auto_awesome_outlined, label: 'Add a text description of your meal'),
        _BulletData(icon: Icons.qr_code_outlined, label: 'Scan the barcode'),
        _BulletData(icon: Icons.description_outlined, label: 'Or take a photo of the food label'),
      ],
    ),
    _ScanOnboardingPageData(
      title: 'For fastest process:',
      bullets: [
        _BulletData(icon: Icons.emoji_food_beverage_outlined, label: 'When cooking your own meal'),
        // _BulletData(icon: Icons.photo_library_outlined, label: 'Capture all ingredients together in one photo'),
        // _BulletData(icon: Icons.bolt_outlined, label: 'Save time by logging everything at once'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SessionManager.to.scanOnboardingComplete.value) {
        Get.off(() => const ScanCameraScreen());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _activeIndex = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return _ScanOnboardingPage(data: data, index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanOnboardingPage extends StatelessWidget {
  const _ScanOnboardingPage({
    required this.data,
    required this.index,
  });

  final _ScanOnboardingPageData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isLast = index == 4;
    return Column(
      children: [
        _buildImageHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContent(context),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: ScanIndicatorDots(count: 5, activeIndex: index),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: ScanPrimaryButton(
                    label: isLast ? 'Scan now' : 'Next',
                    onPressed: () {
                      final state = context.findAncestorStateOfType<_ScanOnboardingScreenState>();
                      state?._next();
                    },
                    height: AppSizes.buttonHeightCompact,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppRadii.xl),
        bottomRight: Radius.circular(AppRadii.xl),
      ),
      child: Container(
        height: 497,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.scanPlaceholder,
        ),
        child: Center(
          child: Text(
            'Image placeholder',
            style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: AppTextStyles.scanTitle),
          const SizedBox(height: AppSpacing.lg),
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
    required this.title,
    required this.bullets,
  });

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
