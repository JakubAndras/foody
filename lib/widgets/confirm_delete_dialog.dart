import 'dart:ui' as ui;

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shows a confirm-delete dialog matching iOS 26 style.
///
/// Returns `true` if the user confirmed deletion, `null`/`false` otherwise.
Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
  required String cancelLabel,
  required String deleteLabel,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: AppColors.overlayDark40,
    builder: (_) => _ConfirmDeleteContent(
      title: title,
      cancelLabel: cancelLabel,
      deleteLabel: deleteLabel,
    ),
  );
}

class _ConfirmDeleteContent extends StatelessWidget {
  const _ConfirmDeleteContent({required this.title, required this.cancelLabel, required this.deleteLabel});

  final String title;
  final String cancelLabel;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(false),
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
                  color: const Color(0xE8EDEEF0).withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.m, right: AppSpacing.xxxl),
                      child: Text(title, style: AppTextStyles.title18.copyWith(color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                      child: Text(tr(LocaleKeys.common_cannot_undo), style: AppTextStyles.body14Regular.copyWith(color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                              alignment: Alignment.center,
                              child: Text(cancelLabel, style: AppTextStyles.body16.copyWith(color: Colors.white, fontWeight: FontWeight.w600, height: 1.0)),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(true),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3))),
                              alignment: Alignment.center,
                              child: Text(deleteLabel, style: AppTextStyles.body16.copyWith(color: AppColors.error, fontWeight: FontWeight.w600, height: 1.0)),
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
