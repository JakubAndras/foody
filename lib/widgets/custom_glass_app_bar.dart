import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/app_theme.dart';

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
        settings: AppGlass.standard,
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

/// Group of icon buttons in a single glass pill — iOS 26 style.
class CustomGlassIconButtonGroup extends StatelessWidget {
  const CustomGlassIconButtonGroup({super.key, required this.items, this.height = 44, this.iconSize});

  final List<({IconData icon, VoidCallback onPressed})> items;
  final double height;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (height * 0.5);
    return GlassButtonGroup(
      useOwnLayer: true,
      glassSettings: AppGlass.standard,
      quality: GlassQuality.premium,
      borderRadius: height / 2,
      children: items
          .map((item) => GestureDetector(
                onTap: item.onPressed,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(width: height, height: height, child: Center(child: Icon(item.icon, size: effectiveIconSize, color: AppColors.black))),
              ))
          .toList(),
    );
  }
}

/// Transparent app bar with independent glass elements — iOS 26 style.
/// Back/action buttons are standalone glass pills; title is plain text.
/// No shared glass layer.
class CustomGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomGlassAppBar({super.key, this.title, this.titleWidget, this.leading, this.leadingIcon, this.leadingIconSize, this.actions, this.onBack, this.showLeading = true});

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final IconData? leadingIcon;
  final double? leadingIconSize;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showLeading;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final leadingWidget = !showLeading
        ? const SizedBox(width: AppSizes.backButtonSize)
        : leading ?? CustomGlassIconButton(icon: leadingIcon ?? Icons.arrow_back_ios_new_rounded, iconSize: leadingIconSize ?? AppSizes.iconMd, onPressed: onBack ?? () => Get.back());

    final titleContent = titleWidget ?? (title != null ? Text(title!, style: AppTextStyles.title18) : null);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
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
      ),
    );
  }
}
