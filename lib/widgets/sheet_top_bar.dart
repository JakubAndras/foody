import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Reusable top bar for bottom sheets.
///
/// Shows a centered [title], a close button on the left, and an optional
/// confirm button on the right.
class SheetTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback? onConfirm;

  const SheetTopBar({super.key, required this.title, required this.onClose, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: AppTextStyles.title17.copyWith(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                SheetCircleButton(icon: CupertinoIcons.xmark, onTap: onClose),
                const Spacer(),
                if (onConfirm != null)
                  SheetCircleButton(
                    icon: CupertinoIcons.checkmark,
                    backgroundColor: isDark ? Colors.white : AppColors.black,
                    iconColor: isDark ? AppColors.black : Colors.white,
                    onTap: onConfirm!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
