import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_circle_button.dart';
import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: Text(title, style: AppTextStyles.title17.copyWith(color: AppColors.black, fontWeight: FontWeight.w600))),
            Row(
              children: [
                SheetCircleButton(icon: Icons.close_rounded, onTap: onClose),
                const Spacer(),
                if (onConfirm != null)
                  SheetCircleButton(icon: Icons.check_rounded, backgroundColor: AppColors.primary, iconColor: AppColors.white1, onTap: onConfirm!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
