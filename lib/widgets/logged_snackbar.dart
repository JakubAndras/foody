import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void showLoggedSnackbar({
  required BuildContext context,
  required String message,
  required VoidCallback onView,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF22C55E), size: 28),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              onView();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                tr(LocaleKeys.common_view),
                style: AppTextStyles.body14.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              onUndo();
            },
            child: Text(
              tr(LocaleKeys.common_undo),
              style: AppTextStyles.body14.copyWith(
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
      duration: const Duration(seconds: 4),
    ),
  );
}
