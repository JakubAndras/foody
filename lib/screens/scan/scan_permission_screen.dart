import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPermissionScreen extends StatelessWidget {
  const ScanPermissionScreen({
    super.key,
    required this.isPermanentlyDenied,
    required this.onRequestPermission,
  });

  final bool isPermanentlyDenied;
  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(
            title: tr(LocaleKeys.scan_camera_access),
            onBack: () => Get.back(),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Icon(CupertinoIcons.camera_fill, color: AppColors.textPrimary, size: AppSizes.iconXl),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Text(
                isPermanentlyDenied ? tr(LocaleKeys.scan_camera_disabled_message) : tr(LocaleKeys.scan_camera_allow_message),
                style: AppTextStyles.body14Relaxed.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Spacer(),
          FoodyPrimaryButton(
            label: isPermanentlyDenied ? tr(LocaleKeys.scan_open_settings) : tr(LocaleKeys.scan_allow_camera),
            onTap: () async {
              if (isPermanentlyDenied) {
                await openAppSettings();
              } else {
                onRequestPermission();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
