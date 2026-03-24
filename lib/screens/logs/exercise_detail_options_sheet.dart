import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ExerciseDetailOptionsSheet extends StatelessWidget {
  const ExerciseDetailOptionsSheet({
    super.key,
    required this.onReport,
    required this.onDelete,
    this.onDuplicate,
  });

  final VoidCallback onReport;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.glassSheet,
            borderRadius: BorderRadius.circular(AppRadii.l),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDuplicate != null) ...[
                _OptionRow(
                  icon: Icons.content_copy_outlined,
                  label: tr(LocaleKeys.exercise_duplicate_to_today),
                  color: AppColors.textPrimary,
                  onTap: onDuplicate!,
                ),
                const SizedBox(height: AppSpacing.s),
              ],
              _OptionRow(
                icon: Icons.report_gmailerrorred_outlined,
                label: tr(LocaleKeys.common_report),
                color: AppColors.textPrimary,
                onTap: onReport,
              ),
              const SizedBox(height: AppSpacing.s),
              _OptionRow(
                icon: Icons.delete_outline,
                label: tr(LocaleKeys.common_delete),
                color: AppColors.error,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.m),
          Text(
            label,
            style: AppTextStyles.body16.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
