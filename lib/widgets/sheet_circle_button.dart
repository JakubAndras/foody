import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class SheetCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const SheetCircleButton({super.key, required this.icon, required this.onTap, this.backgroundColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? AppColors.calendarDarkMuted.withValues(alpha: 0.3),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: AppSizes.iconLg, color: iconColor ?? AppColors.black),
      ),
    );
  }
}
