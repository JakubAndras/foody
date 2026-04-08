import 'dart:io' show Platform;

import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum SnackBarType { success, error, info, warning }

void showSnackBar({
  BuildContext? context,
  required String message,
  String? subtitle,
  SnackBarType type = SnackBarType.success,
  IconData? icon,
  Color? iconColor,
  String? primaryLabel,
  VoidCallback? onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  Duration duration = const Duration(seconds: 2),
}) {
  final ctx = context ?? Get.context!;
  final isDark = Theme.of(ctx).brightness == Brightness.dark;

  final IconData resolvedIcon;
  final Color resolvedColor;
  switch (type) {
    case SnackBarType.success:
      resolvedIcon = icon ?? CupertinoIcons.checkmark_circle_fill;
      resolvedColor = iconColor ?? AppColors.success;
    case SnackBarType.error:
      resolvedIcon = icon ?? CupertinoIcons.xmark_circle_fill;
      resolvedColor = iconColor ?? const Color(0xFFFF3B30);
    case SnackBarType.info:
      resolvedIcon = icon ?? CupertinoIcons.info_circle_fill;
      resolvedColor = iconColor ?? const Color(0xFF3478F6);
    case SnackBarType.warning:
      resolvedIcon = icon ?? CupertinoIcons.exclamationmark_triangle_fill;
      resolvedColor = iconColor ?? const Color(0xFFFF9500);
  }

  ScaffoldMessenger.of(ctx).clearSnackBars();
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(resolvedIcon, color: resolvedColor, size: 32),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (onPrimary != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                onPrimary();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.black,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  primaryLabel ?? '',
                  style: AppTextStyles.body14.copyWith(color: isDark ? AppColors.black : AppColors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (onPrimary != null && onSecondary != null) const SizedBox(width: AppSpacing.m),
          if (onSecondary != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                onSecondary();
              },
              child: Text(
                secondaryLabel ?? '',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : AppColors.white,
      elevation: 0.5,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, Platform.isAndroid ? AppSpacing.l : AppSpacing.xxs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.l)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
      duration: duration,
    ),
  );
}
