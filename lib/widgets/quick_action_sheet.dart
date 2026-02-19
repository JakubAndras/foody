import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class QuickActionSheet extends StatelessWidget {
  const QuickActionSheet({
    super.key,
    required this.onLogMeal,
    required this.onBarcode,
    required this.onVoiceLog,
    required this.onMealScan,
    required this.onWeight,
    required this.onExercise,
  });

  final VoidCallback onLogMeal;
  final VoidCallback onBarcode;
  final VoidCallback onVoiceLog;
  final VoidCallback onMealScan;
  final VoidCallback onWeight;
  final VoidCallback onExercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.m),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildGridRow(
                left: _QuickActionTile(
                  icon: Icons.center_focus_strong,
                  label: 'Log Meal',
                  iconBg: const Color(0x212B7FFF),
                  onTap: onLogMeal,
                ),
                right: _QuickActionTile(
                  icon: Icons.qr_code_2,
                  label: 'Barcode Scan',
                  iconBg: const Color(0x21FB2C36),
                  onTap: onBarcode,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _buildGridRow(
                left: _QuickActionTile(
                  icon: Icons.mic,
                  label: 'Voice Log',
                  iconBg: const Color(0x216366F1),
                  onTap: onVoiceLog,
                ),
                right: _QuickActionTile(
                  icon: Icons.photo_camera_outlined,
                  label: 'Meal Scan',
                  iconBg: const Color(0x2105DF72),
                  onTap: onMealScan,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadii.lg2),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 20,
                      color: Color(0x14000000),
                    ),
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Color(0x0F000000),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuickActionRow(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      onTap: onWeight,
                    ),
                    const Divider(height: 1, color: AppColors.outline),
                    _QuickActionRow(
                      icon: Icons.fitness_center_outlined,
                      label: 'Exercise',
                      onTap: onExercise,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: right),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.lg2),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 8),
              blurRadius: 20,
              color: Color(0x14000000),
            ),
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 6,
              color: Color(0x0F000000),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Icon(icon, color: AppColors.textEmphasisAlt),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTextStyles.body13),
          ],
        ),
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textEmphasisAlt),
      title: Text(label, style: AppTextStyles.body14),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      dense: true,
    );
  }
}
