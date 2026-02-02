import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('Camera access', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              Text(
                isPermanentlyDenied
                    ? 'Camera access is disabled. Enable it in Settings to scan meals.'
                    : 'Allow camera access to scan your meal and analyze it instantly.',
                style: AppTextStyles.body14Relaxed,
              ),
              const Spacer(),
              ScanPrimaryButton(
                label: isPermanentlyDenied ? 'Open Settings' : 'Allow Camera',
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
