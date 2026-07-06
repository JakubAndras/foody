import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/app_theme.dart';

/// Glass icon button with dark icon — wraps [GlassButton.custom] so we can
/// control icon colour (the stock [GlassIconButton] hardcodes white).
class CustomGlassIconButton extends StatelessWidget {
  const CustomGlassIconButton({super.key, required this.icon, required this.onPressed, this.size = 44, this.iconSize, this.child});

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double? iconSize;
  final Widget? child;

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
        child:
            child ??
            Padding(
              padding: icon == CupertinoIcons.chevron_left ? const EdgeInsets.only(right: 1.5) : EdgeInsets.zero,
              child: Icon(icon, size: effectiveIconSize, color: AppColors.textPrimary),
            ),
      ),
    );
  }
}

/// Custom-painted icon that matches iOS native glass button style.
/// Use with [CustomGlassIconButton.child] for consistent stroke weight.
class GlassStrokeIcon extends StatelessWidget {
  const GlassStrokeIcon({super.key, required this.painter, this.size = AppSizes.scanIconSize});

  final CustomPainter painter;
  final double size;

  /// X mark — close / dismiss.
  factory GlassStrokeIcon.close({double size = AppSizes.scanIconSize}) => GlassStrokeIcon(painter: const _CloseStrokePainter(), size: size);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: painter);
  }
}

const _kStrokeWidth = 2.0;
const _kInsetFraction = 0.19;

Paint _glassStrokePaint() => Paint()
  ..color = AppColors.textPrimary
  ..strokeWidth = _kStrokeWidth
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

class _CloseStrokePainter extends CustomPainter {
  const _CloseStrokePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _glassStrokePaint();
    final inset = size.width * _kInsetFraction;
    canvas.drawLine(Offset(inset, inset), Offset(size.width - inset, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(inset, size.height - inset), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      borderColor: Colors.transparent,
      children: items
          .map(
            (item) => GestureDetector(
              onTap: item.onPressed,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: height,
                height: height,
                child: Center(
                  child: Icon(item.icon, size: effectiveIconSize, color: AppColors.textPrimary),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Transparent app bar with independent glass elements — iOS 26 style.
/// Back/action buttons are standalone glass pills; title is plain text.
/// No shared glass layer.
class CustomGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomGlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.leadingIcon,
    this.leadingIconSize,
    this.actions,
    this.onBack,
    this.showLeading = true,
    this.horizontalPadding,
    this.useSafeArea = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final IconData? leadingIcon;
  final double? leadingIconSize;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showLeading;
  final double? horizontalPadding;
  final bool useSafeArea;

  @override
  Size get preferredSize => Size.fromHeight(
    // Mirror the Android-only extra top padding applied in build() so
    // Scaffold.appBar slots reserve enough height. iOS unaffected.
    AppSizes.topBarHeight + (Platform.isAndroid ? AppSpacing.m : 0),
  );

  @override
  Widget build(BuildContext context) {
    final leadingWidget = !showLeading
        ? const SizedBox(width: AppSizes.backButtonSize)
        : leading ??
              CustomGlassIconButton(icon: leadingIcon ?? CupertinoIcons.chevron_left, iconSize: leadingIconSize ?? AppSizes.iconMd, onPressed: onBack ?? () => Navigator.of(context).pop());

    final titleContent = titleWidget ?? (title != null ? Text(title!, style: AppTextStyles.title18) : null);

    Widget bar = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 0),
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

    // Android's status bar inset (~24px) is smaller than iOS's notch/dynamic
    // island inset (~47px), so SafeArea alone leaves the bar feeling cramped
    // against the status bar. Add extra breathing room only on Android.
    if (Platform.isAndroid && useSafeArea) {
      bar = Padding(padding: const EdgeInsets.only(top: AppSpacing.m), child: bar);
    }

    return useSafeArea ? SafeArea(bottom: false, child: bar) : bar;
  }
}
