import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.child,
    this.bottom,
    this.progress,
    this.showBack = true,
    this.onBack,
    this.padding,
  });

  final Widget child;
  final Widget? bottom;
  final double? progress;
  final bool showBack;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.l,
        );
    final bool hasTopChrome = progress != null || showBack;
    final double contentTopInset = hasTopChrome ? AppSizes.topBarHeight : 0;

    final media = MediaQuery.of(context);
    final double topInset = media.padding.top;
    final double bottomInset = media.padding.bottom;
    final double bottomBarHeight = bottom == null ? 0 : AppSizes.buttonHeight + AppSpacing.bottom + bottomInset;
    final Widget? floatingActionButton = bottom == null
        ? null
        : SafeArea(
            top: false,
            bottom: false,
            minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: SizedBox(
              width: double.infinity,
              child: bottom,
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: bottom == null ? null : FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: contentTopInset),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: AppSpacing.xl + bottomBarHeight,
                ),
                child: Padding(
                  padding: resolvedPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (progress != null)
            Positioned(
              left: AppSpacing.xl + 32,
              right: AppSpacing.m,
              top: topInset + AppSpacing.m + 2,
              child: OnboardingProgressBar(value: progress!),
            ),
          if (showBack)
            Positioned(
              left: AppSpacing.m,
              top: topInset,
              child: OnboardingBackButton(onPressed: onBack),
            ),
        ],
      ),
    );
  }
}

class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.backButtonSize,
      height: AppSizes.backButtonSize,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.outline, width: 1),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Center(
            child: Icon(
              CupertinoIcons.chevron_left,
              size: AppSizes.iconMd,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: AppSizes.stepIndicatorHeight,
        child: Stack(
          children: [
            Container(color: AppColors.outline),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1),
              child: Container(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isEnabled = true,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        );

    final List<Color> colors =
        isEnabled ? AppGradients.primary.colors : AppGradients.primary.colors.map((color) => color.withValues(alpha: 0.5)).toList();

    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AppGradients.primary.begin,
                end: AppGradients.primary.end,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.s),
                  ],
                  Text(label, style: labelStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingSolidButton extends StatelessWidget {
  const OnboardingSolidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.onPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );

    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.s),
                ],
                Text(label, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingOutlinedButton extends StatelessWidget {
  const OnboardingOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.s),
                ],
                Text(label, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingTextLink extends StatelessWidget {
  const OnboardingTextLink({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textMuted,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w500,
        );

    return GestureDetector(
      onTap: onPressed,
      child: Text(label, style: style, textAlign: TextAlign.center),
    );
  }
}

class OnboardingLanguageChip extends StatelessWidget {
  const OnboardingLanguageChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.glassLight,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇺🇸', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.selected = false,
    this.onTap,
    this.height = AppSizes.buttonHeight,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool selected;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color background = selected ? AppColors.primary : AppColors.surface;
    final Color titleColor = selected ? AppColors.onPrimary : AppColors.textPrimary;
    final Color subtitleColor = selected ? AppColors.onPrimary.withValues(alpha: 0.7) : AppColors.textSecondary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.m),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle!,
                          style: textTheme.bodyLarge?.copyWith(
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPillChipSmall extends StatelessWidget {
  const OnboardingPillChipSmall({
    super.key,
    required this.label,
    this.textColor,
    this.backgroundColor,
    this.leading,
  });

  final String label;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: textColor ?? AppColors.textPrimary,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceChip,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}

class OnboardingPillChipBig extends StatelessWidget {
  const OnboardingPillChipBig({
    super.key,
    required this.label,
    this.textColor,
    this.backgroundColor,
    this.leading,
  });

  final String label;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: textColor ?? AppColors.textPrimary,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceChip,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}

class OnboardingSurfaceCard extends StatelessWidget {
  const OnboardingSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.radius = AppRadii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class OnboardingSlider extends StatelessWidget {
  const OnboardingSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: AppSizes.sliderTrackHeight,
        activeTrackColor: AppColors.primaryDark,
        inactiveTrackColor: AppColors.surfaceChip,
        thumbColor: AppColors.surface,
        overlayColor: AppColors.primary.withValues(alpha: 0.08),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: AppSizes.sliderThumbRadius),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class OnboardingSliderTicks extends StatelessWidget {
  const OnboardingSliderTicks({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        count,
        (index) => Container(
          width: AppSizes.sliderTickSize,
          height: AppSizes.sliderTickSize,
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class OnboardingRingChart extends StatelessWidget {
  const OnboardingRingChart({
    super.key,
    required this.value,
    required this.color,
    required this.label,
    required this.unit,
    this.size = AppSizes.ringSize,
    this.strokeWidth = AppSizes.ringStroke,
    this.centerChild,
  });

  final double value;
  final Color color;
  final String label;
  final String unit;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: value,
              color: color,
              background: AppColors.surfacePill,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: centerChild ??
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: label,
                          style: textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: unit,
                          style: textTheme.titleSmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.background,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color background;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint active = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;

    canvas.drawCircle(center, radius, base);

    final double sweep = 2 * 3.1415926535 * progress.clamp(0, 1);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, sweep, false, active);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.background != background;
  }
}

class OnboardingRuler extends StatelessWidget {
  const OnboardingRuler({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.rulerHeight,
      width: double.infinity,
      child: CustomPaint(
        painter: _RulerPainter(),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    final Paint basePaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.6)
      ..strokeWidth = 2;

    final Paint highlightPaint = Paint()..color = AppColors.outline;

    final double centerX = size.width / 2;
    final Rect highlightRect = Rect.fromCenter(
      center: Offset(centerX, size.height * 0.4),
      width: AppSizes.rulerHighlightWidth,
      height: AppSizes.rulerHighlightHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect, const Radius.circular(AppRadii.sm)),
      highlightPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      basePaint,
    );

    final int ticks = (size.width / AppSizes.rulerTickSpacing).floor();
    for (int i = 0; i <= ticks; i++) {
      final double x = i * AppSizes.rulerTickSpacing;
      final double tickHeight = i % 10 == 0
          ? AppSizes.rulerMajorTick
          : i % 5 == 0
              ? AppSizes.rulerMidTick
              : AppSizes.rulerMinorTick;
      canvas.drawLine(
        Offset(x, size.height * 0.75),
        Offset(x, size.height * 0.75 - tickHeight),
        linePaint,
      );
    }

    canvas.drawLine(
      Offset(centerX, size.height * 0.2),
      Offset(centerX, size.height * 0.75),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingPlaceholderImage extends StatelessWidget {
  const OnboardingPlaceholderImage({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          size: AppSizes.iconXl,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class OnboardingGlassCard extends StatelessWidget {
  const OnboardingGlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassMuted,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class OnboardingSmallBadge extends StatelessWidget {
  const OnboardingSmallBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
