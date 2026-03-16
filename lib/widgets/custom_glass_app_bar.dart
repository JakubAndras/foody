import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/app_theme.dart';

/// App-wide glass settings for standalone icon buttons.
const customGlassSettings = LiquidGlassSettings(thickness: 42, blur: 5, glassColor: Color(0xB0FFFFFF), lightIntensity: 6, lightAngle: 0.3 * pi);

/// Glass icon button with dark icon — wraps [GlassButton.custom] so we can
/// control icon colour (the stock [GlassIconButton] hardcodes white).
class CustomGlassIconButton extends StatelessWidget {
  const CustomGlassIconButton({super.key, required this.icon, required this.onPressed, this.size = 44, this.iconSize});

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (size * 0.5);
    final isEnabled = onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: GlassButton.custom(
        onTap: onPressed ?? () {},
        enabled: isEnabled,
        width: size,
        height: size,
        shape: const LiquidOval(),
        useOwnLayer: true,
        settings: customGlassSettings,
        quality: GlassQuality.premium,
        interactionScale: 0.95,
        child: Padding(
          padding: icon == Icons.arrow_back_ios_new_rounded ? const EdgeInsets.only(right: 1.5) : EdgeInsets.zero,
          child: Icon(icon, size: effectiveIconSize, color: AppColors.black),
        ),
      ),
    );
  }
}

/// Transparent app bar with independent glass elements — iOS 26 style.
/// Back/action buttons are standalone glass pills; title is plain text.
/// No shared glass layer.
class CustomGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomGlassAppBar({super.key, this.title, this.titleWidget, this.leading, this.leadingIcon, this.actions, this.onBack, this.showLeading = true});

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showLeading;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final leadingWidget = !showLeading
        ? const SizedBox(width: AppSizes.backButtonSize)
        : leading ?? CustomGlassIconButton(icon: leadingIcon ?? Icons.arrow_back_ios_new_rounded, iconSize: AppSizes.iconMd, onPressed: onBack ?? () => Get.back());

    final titleContent = titleWidget ?? (title != null ? Text(title!, style: AppTextStyles.title18Tight) : null);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (titleContent != null) Center(child: titleContent),
            Row(
              children: [
                leadingWidget,
                const Spacer(),
                if (actions != null && actions!.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, spacing: AppSpacing.s, children: actions!)
                else
                  SizedBox(width: AppSizes.backButtonSize),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
