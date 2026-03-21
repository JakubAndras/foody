import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Unified primary action button — gradient pill, white text, optional icon.
/// NOT glass for now — will be swapped to glass later.
class FoodyPrimaryButton extends StatelessWidget {
  const FoodyPrimaryButton({super.key, required this.label, this.onTap, this.icon, this.gradient, this.height, this.leading, this.shadow});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Gradient? gradient;
  final double? height;
  final Widget? leading;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDisabled ? AppOpacities.disabled : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: height ?? AppSizes.buttonHeight,
          decoration: BoxDecoration(gradient: gradient ?? AppGradients.primary, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: shadow),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.xs)],
                if (icon != null) ...[Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconMd), const SizedBox(width: AppSpacing.xs)],
                Text(label, style: AppTextStyles.title18.copyWith(height: 1.25, color: AppColors.onPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified secondary action button — surface bg, outline border, optional icon.
/// NOT glass for now — will be swapped to glass later.
class FoodySecondaryButton extends StatelessWidget {
  const FoodySecondaryButton({super.key, required this.label, this.onTap, this.icon, this.height, this.leading});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? height;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDisabled ? AppOpacities.disabled : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: height ?? AppSizes.buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.outline),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.xs)],
                if (icon != null) ...[Icon(icon, color: AppColors.textPrimary, size: AppSizes.iconMd), const SizedBox(width: AppSpacing.xs)],
                Text(label, style: AppTextStyles.title18.copyWith(height: 1.25, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
