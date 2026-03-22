import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app_theme.dart';

class GlassToggleRow extends StatelessWidget {
  const GlassToggleRow({super.key, required this.title, this.subtitle, required this.isOn, this.onChanged, this.showDivider = true, this.trailing});

  final String title;
  final String? subtitle;
  final bool isOn;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(subtitle!, style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.s),
                trailing!,
              ],
              const SizedBox(width: AppSpacing.s),
              GlassSwitch(value: isOn, onChanged: onChanged ?? (_) {}, useOwnLayer: true, inactiveColor: AppColors.grey4.withValues(alpha: 0.4)),
            ],
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}
