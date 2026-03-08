import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(tr(LocaleKeys.scan_camera_access), style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.m),
              Text(
                isPermanentlyDenied
                    ? tr(LocaleKeys.scan_camera_disabled_message)
                    : tr(LocaleKeys.scan_camera_allow_message),
                style: AppTextStyles.body14Relaxed,
              ),
              const Spacer(),
              ScanPrimaryButton(
                label: isPermanentlyDenied ? tr(LocaleKeys.scan_open_settings) : tr(LocaleKeys.scan_allow_camera),
                onPressed: () async {
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
        ),
      ),
    );
  }
}
