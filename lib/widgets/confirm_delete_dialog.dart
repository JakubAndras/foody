import 'dart:ui' as ui;

import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a confirmation dialog matching iOS 26 style.
///
/// Returns `true` if the user tapped the primary (right) button,
/// `false` if secondary (left), `null` if dismissed.
///
/// [title] — bold heading text.
/// [subtitle] — optional descriptive text below the title.
/// [primaryLabel] — right button label (the action: Delete, Save, Confirm …).
/// [secondaryLabel] — left button label (Cancel, Discard …).
/// [isDestructive] — when `true`, primary button has red text on surface
///   background; when `false`, primary has [AppColors.primary] background
///   with white text.
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  required String primaryLabel,
  required String secondaryLabel,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: AppColors.overlayDark40,
    builder: (_) => _ConfirmationDialogContent(
      title: title,
      subtitle: subtitle,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      isDestructive: isDestructive,
    ),
  );
}

class _ConfirmationDialogContent extends StatelessWidget {
  const _ConfirmationDialogContent({
    required this.title,
    this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isDestructive,
  });

  final String title;
  final String? subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Secondary (left) button styles
    final secondaryBg = isDestructive ? AppColors.primary : AppColors.surface;
    final secondaryText = isDestructive ? Colors.white : AppColors.textPrimary;
    final secondaryBorder = isDestructive ? null : Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3));

    // Primary (right) button styles
    final primaryBg = isDestructive ? AppColors.surface : AppColors.primary;
    final primaryText = isDestructive ? AppColors.error : (isDark ? AppColors.black : Colors.white);
    final primaryBorder = isDestructive ? Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)) : null;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.l, AppSpacing.m, AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.dialogSurface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.m, right: subtitle != null ? AppSpacing.xxxl : AppSpacing.m),
                      child: Text(
                        title,
                        style: (subtitle != null ? AppTextStyles.title18 : AppTextStyles.body16).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                        child: Text(subtitle!, style: AppTextStyles.body14Regular.copyWith(color: AppColors.textPrimary)),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      children: [
                        // Secondary (left) — Cancel, Discard …
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: secondaryBg,
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                                border: secondaryBorder,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                secondaryLabel,
                                style: AppTextStyles.body16.copyWith(color: secondaryText, fontWeight: FontWeight.w600, height: 1.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        // Primary (right) — Delete, Save …
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(true),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryBg,
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                                border: primaryBorder,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                primaryLabel,
                                style: AppTextStyles.body16.copyWith(color: primaryText, fontWeight: FontWeight.w600, height: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
