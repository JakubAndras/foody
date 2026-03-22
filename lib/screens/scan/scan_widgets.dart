import 'dart:io';
import 'dart:ui' as ui;

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ScanPrimaryButton extends StatelessWidget {
  const ScanPrimaryButton({super.key, required this.label, this.onPressed, this.gradient, this.icon, this.height, this.hasShadow = true});

  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final double? height;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return FoodyPrimaryButton(
      label: label,
      onTap: onPressed,
      icon: icon,
      gradient: gradient,
      height: height ?? AppSizes.buttonHeight,
      shadow: hasShadow ? AppShadows.button : null,
    );
  }
}

class ScanIndicatorDots extends StatelessWidget {
  const ScanIndicatorDots({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: AppSizes.scanIndicatorDot,
          height: AppSizes.scanIndicatorDot,
          margin: EdgeInsets.symmetric(horizontal: AppSizes.scanIndicatorGap / 2),
          decoration: BoxDecoration(color: isActive ? AppColors.primary : AppColors.borderStrong, borderRadius: BorderRadius.circular(AppRadii.pill)),
        );
      }),
    );
  }
}

class ScanBulletRow extends StatelessWidget {
  const ScanBulletRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSizes.iconLg,
          height: AppSizes.iconLg,
          child: Icon(icon, size: AppSizes.iconLg, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: Text(label, style: AppTextStyles.body16.copyWith(fontSize: 17, fontWeight: FontWeight.w400, height: 1.412, color: AppColors.primary))),
      ],
    );
  }
}

class ScanCircleButton extends StatelessWidget {
  const ScanCircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.primary,
    this.size = AppSizes.scanTopButtonSize,
    this.iconSize = AppSizes.scanTopIconSize,
    this.shadow = AppShadows.calendarDay,
    this.border,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final List<BoxShadow> shadow;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return CustomGlassIconButton(icon: icon, onPressed: onPressed, size: size, iconSize: iconSize);
  }
}

class ScanFrameCorners extends StatelessWidget {
  const ScanFrameCorners({super.key, required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          _corner(
            alignment: Alignment.topLeft,
            border: Border(
              left: BorderSide(color: color, width: AppSizes.scanCornerStroke),
              top: BorderSide(color: color, width: AppSizes.scanCornerStroke),
            ),
            radius: const BorderRadius.only(topLeft: Radius.circular(AppRadii.l)),
          ),
          _corner(
            alignment: Alignment.topRight,
            border: Border(
              right: BorderSide(color: color, width: AppSizes.scanCornerStroke),
              top: BorderSide(color: color, width: AppSizes.scanCornerStroke),
            ),
            radius: const BorderRadius.only(topRight: Radius.circular(AppRadii.l)),
          ),
          _corner(
            alignment: Alignment.bottomLeft,
            border: Border(
              left: BorderSide(color: color, width: AppSizes.scanCornerStroke),
              bottom: BorderSide(color: color, width: AppSizes.scanCornerStroke),
            ),
            radius: const BorderRadius.only(bottomLeft: Radius.circular(AppRadii.l)),
          ),
          _corner(
            alignment: Alignment.bottomRight,
            border: Border(
              right: BorderSide(color: color, width: AppSizes.scanCornerStroke),
              bottom: BorderSide(color: color, width: AppSizes.scanCornerStroke),
            ),
            radius: const BorderRadius.only(bottomRight: Radius.circular(AppRadii.l)),
          ),
        ],
      ),
    );
  }

  Widget _corner({required Alignment alignment, required Border border, required BorderRadius radius}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: AppSizes.scanCornerSize,
        height: AppSizes.scanCornerSize,
        decoration: BoxDecoration(border: border, borderRadius: radius),
      ),
    );
  }
}

class ScanZoomToggle extends StatelessWidget {
  const ScanZoomToggle({super.key, required this.isEnabled, required this.isZoomed, required this.onToggle});

  final bool isEnabled;
  final bool isZoomed;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : AppOpacities.disabled,
      child: Container(
        width: AppSizes.scanZoomPillWidth,
        height: AppSizes.scanZoomPillHeight,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.calendarDay),
        child: Row(
          children: [
            _zoomButton(label: tr(LocaleKeys.scan_zoom_05x), isActive: !isZoomed, onTap: () => onToggle(false)),
            _zoomButton(label: tr(LocaleKeys.scan_zoom_1x), isActive: isZoomed, onTap: () => onToggle(true)),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton({required String label, required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppSizes.scanZoomButtonHeight,
          decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Center(
            child: Text(label, style: AppTextStyles.body14.copyWith(color: isActive ? AppColors.onPrimary : AppColors.primary)),
          ),
        ),
      ),
    );
  }
}

class ScanModeTile extends StatelessWidget {
  const ScanModeTile({super.key, required this.label, required this.icon, required this.isActive, required this.onTap, this.activeColor});

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final Color bg = isActive ? (activeColor ?? AppColors.primary) : AppColors.surface;
    final Color fg = isActive ? AppColors.onPrimary : AppColors.textEmphasis;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.scanModeButtonWidth,
        height: AppSizes.scanModeButtonHeight,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.m),
          border: isActive ? null : Border.all(color: AppColors.outline, width: 1.08),
          boxShadow: isActive ? AppShadows.calendarDay : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.scanModeIconSize, color: fg),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.label12.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

class ScanShutterButton extends StatelessWidget {
  const ScanShutterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSizes.scanShutterSize,
        height: AppSizes.scanShutterSize,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.calendarDay),
        child: Center(
          child: Container(
            width: AppSizes.scanShutterRingSize,
            height: AppSizes.scanShutterRingSize,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.onPrimary, width: AppSizes.scanCornerStroke),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanTipOverlay extends StatelessWidget {
  const ScanTipOverlay({super.key, required this.title, required this.body, required this.onDismiss, this.child});

  final String title;
  final String body;
  final VoidCallback onDismiss;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: const Color(0x55FFFFFF),
            borderRadius: BorderRadius.circular(AppRadii.l),
            border: Border.all(color: const Color(0x44FFFFFF), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (child != null) ...[child!, const SizedBox(height: AppSpacing.l)],
                    Text(title, style: AppTextStyles.h4.copyWith(height: 1.4, color: AppColors.primary), textAlign: TextAlign.center),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s),
                      SizedBox(
                        width: 280,
                        child: Text(body, style: AppTextStyles.body14Regular, textAlign: TextAlign.center),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 100,
                  height: 48,
                  decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Center(child: Text(tr(LocaleKeys.scan_got_it), style: AppTextStyles.body14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanNutritionLabelCard extends StatelessWidget {
  const ScanNutritionLabelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 159,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.xs), boxShadow: AppShadows.calendarDay),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition Facts', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 2),
          Text('Serving size 1 container (170g)', style: AppTextStyles.caption12.copyWith(fontSize: 8)),
          Text('Servings 1', style: AppTextStyles.caption12.copyWith(fontSize: 8)),
          const SizedBox(height: 4),
          Container(height: 4, color: AppColors.primary),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calories', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
              Text('130', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 2),
          _row('Total Fat 1g', '1%'),
          _row('Saturated Fat 0g', '0%', indent: true),
          _row('Cholesterol 10mg', '4%'),
          _row('Sodium 55mg', '2%'),
          _row('Total Carb. 15g', '5%'),
          _row('Dietary Fiber 0g', '0%', indent: true),
          _row('Total Sugars 5g', ''),
          _row('Protein 11g', ''),
          const SizedBox(height: 2),
          Text(
            '*The % Daily Value tells you how much a nutrient in a serving of food contributes to a daily diet.',
            style: AppTextStyles.caption12.copyWith(fontSize: 6, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool indent = false}) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 6 : 0, top: 1, bottom: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.caption12.copyWith(fontSize: 7.5, fontWeight: indent ? FontWeight.w400 : FontWeight.w700)),
          ),
          if (value.isNotEmpty) Text(value, style: AppTextStyles.caption12.copyWith(fontSize: 7.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class ScanPreviewImage extends StatelessWidget {
  const ScanPreviewImage({super.key, required this.imagePath, this.hasShadow = true});

  final String? imagePath;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadii.l),
      boxShadow: hasShadow ? AppShadows.previewImage : null,
      image: imagePath != null ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover) : null,
      gradient: imagePath == null ? AppGradients.scanPlaceholder : null,
    );

    return Container(width: AppSizes.scanPreviewImageWidth, height: AppSizes.scanPreviewImageHeight, decoration: decoration);
  }
}

class ScanInputField extends StatelessWidget {
  const ScanInputField({super.key, required this.hint, required this.controller, required this.height, this.maxLines = 1, this.hasShadow = true});

  final String hint;
  final TextEditingController controller;
  final double height;
  final int maxLines;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.m),
        border: Border.all(color: AppColors.outline, width: 1.08),
        boxShadow: hasShadow ? AppShadows.control : null,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
        ),
        style: AppTextStyles.body16,
      ),
    );
  }
}

class ScanStatusBar extends StatelessWidget {
  const ScanStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.scanStatusBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('16:54', style: AppTextStyles.body14Regular.copyWith(color: AppColors.statusBarDark)),
            Text('100%', style: AppTextStyles.caption12.copyWith(color: AppColors.statusBarDark)),
          ],
        ),
      ),
    );
  }
}
