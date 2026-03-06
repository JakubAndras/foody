import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

class ProfileGradientScaffold extends StatelessWidget {
  const ProfileGradientScaffold({
    super.key,
    required this.child,
    this.padding,
    this.scroll = false,
    this.safeTop = true,
    this.safeBottom = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final Widget child;
  final EdgeInsets? padding;
  final bool scroll;
  final bool safeTop;
  final bool safeBottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          top: safeTop,
          bottom: safeBottom,
          child: scroll
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: content,
                    ),
                  ),
                )
              : content,
        ),
      ),
    );
  }
}

class ProfileBackButton extends StatelessWidget {
  const ProfileBackButton({super.key, this.onPressed, this.icon = Icons.chevron_left});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.backButtonSize,
      height: AppSizes.backButtonSize,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onPressed,
          child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.navItemHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ProfileBackButton(onPressed: onBack),
          ),
          Text(
            title,
            style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.screen),
    this.color = AppColors.surface,
    this.radius = AppRadii.lg,
    this.shadow,
    this.border,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  final List<BoxShadow>? shadow;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
        border: border,
      ),
      padding: padding,
      child: child,
    );
  }
}

class ProfilePrimaryButton extends StatelessWidget {
  const ProfilePrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.height = AppSizes.buttonHeightCompact,
    this.radius = AppRadii.pill,
    this.shadow,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double height;
  final double radius;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.title17.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileOutlineButton extends StatelessWidget {
  const ProfileOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.height = AppSizes.buttonHeightCompact,
    this.radius = AppRadii.pill,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: AppTextStyles.title17.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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

class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.body14.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ProfileSettingsRow extends StatelessWidget {
  const ProfileSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.showDivider = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right, size: AppSizes.iconSm, color: AppColors.textTertiary),
        ],
      ),
    );

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(onTap: onTap, child: row),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.settingsDividerIndent),
            child: Divider(height: AppSizes.dividerThin, color: AppColors.surfaceSubtle),
          ),
      ],
    );
  }
}

class ProfileToggle extends StatelessWidget {
  const ProfileToggle({super.key, required this.isOn, this.onTap});

  final bool isOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.transitionDuration,
        width: AppSizes.toggleWidthSm,
        height: AppSizes.toggleHeightSm,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isOn ? AppColors.primarySoft : AppColors.borderStrong,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: AnimatedAlign(
          duration: AppTheme.transitionDuration,
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: AppSizes.toggleKnobSm,
            height: AppSizes.toggleKnobSm,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              boxShadow: AppShadows.control,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTimeChip extends StatelessWidget {
  const ProfileTimeChip({super.key, required this.label, this.width});

  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.streakPillHeight,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
