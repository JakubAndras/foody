import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/progress_ring.dart';

class MacrosCard extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final IconData icon;
  final Color color;

  const MacrosCard({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = goal <= 0 ? 0 : (current / goal).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        height: AppSizes.macroCardHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.m),
          //boxShadow: AppShadows.control,
        ),
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: current.toStringAsFixed(0),
                style: AppTextStyles.h3,
                children: [
                  TextSpan(
                    text: '/${goal.toStringAsFixed(0)}g',
                    style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption12.copyWith(color: AppColors.textMuted),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: ProgressRing(
                size: AppSizes.macroRingSize,
                strokeWidth: AppSizes.macroRingStroke,
                value: progress,
                backgroundColor: AppColors.outline.withValues(alpha: 0.6),
                foregroundColor: color,
                child: Icon(icon, color: color, size: AppSizes.iconLg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
