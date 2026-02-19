import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VoicePermissionScreen extends StatelessWidget {
  const VoicePermissionScreen({
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
              Text('Microphone access', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.m),
              Text(
                isPermanentlyDenied
                    ? 'Microphone access is disabled. Enable it in Settings to record your voice logs.'
                    : 'Allow microphone access to record meals and exercises with your voice.',
                style: AppTextStyles.body14Relaxed,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  if (isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    onRequestPermission();
                  }
                },
                child: Container(
                  height: AppSizes.buttonHeight,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: AppShadows.button,
                  ),
                  child: Center(
                    child: Text(
                      isPermanentlyDenied ? 'Open Settings' : 'Allow Microphone',
                      style: AppTextStyles.button18.copyWith(color: AppColors.onPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
