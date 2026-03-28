import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class SheetCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const SheetCircleButton({super.key, required this.icon, required this.onTap, this.size = 48, this.iconSize, this.backgroundColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? AppColors.calendarDarkMuted.withValues(alpha: 0.3),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize ?? AppSizes.iconLiOS, color: iconColor ?? AppColors.black),
      ),
    );
  }
}
