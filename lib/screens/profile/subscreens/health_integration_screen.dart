import 'dart:io';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/health_integration_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HealthIntegrationScreen extends StatelessWidget {
  const HealthIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthIntegrationController>();

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: ProfilePrimaryButton(
          label: Platform.isIOS ? tr(LocaleKeys.health_open_health_app) : tr(LocaleKeys.health_open_health_connect),
          onPressed: () => controller.openHealthApp(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(
            title: Platform.isIOS ? tr(LocaleKeys.health_sync_to_apple_health) : tr(LocaleKeys.health_sync_to_health_connect),
            onBack: () => Get.back(),
          ),
          const SizedBox(height: AppSpacing.m),
          // Toggle row
          ProfileCard(
            radius: AppRadii.l,
            shadow: AppShadows.screenCard,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
            child: Obx(() {
              return GlassToggleRow(
                title: tr(LocaleKeys.health_sync_burned_calories),
                subtitle: controller.isEnabled.value ? _formatLastSync(controller.lastSyncTime.value) : null,
                isOn: controller.isEnabled.value,
                showDivider: false,
                onChanged: controller.isSyncing.value ? null : (val) => controller.toggleSync(val),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.m),
          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              Platform.isIOS ? tr(LocaleKeys.health_apple_health_description) : tr(LocaleKeys.health_health_connect_description),
              style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.l,
            shadow: AppShadows.screenCard,
            padding: EdgeInsets.zero,
            child: Column(
              children: Platform.isIOS ? _buildIosSteps() : _buildAndroidSteps(),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }

  List<Widget> _buildIosSteps() {
    return [
      _InstructionRow(
        icon: CupertinoIcons.heart_fill,
        iconColor: const Color(0xFFFF2D55),
        text: tr(LocaleKeys.health_apple_health_step1),
      ),
      _InstructionRow(
        icon: CupertinoIcons.person_circle,
        iconColor: AppColors.textSecondary,
        text: tr(LocaleKeys.health_apple_health_step2),
      ),
      _InstructionRow(
        icon: CupertinoIcons.shield,
        iconColor: AppColors.textSecondary,
        text: tr(LocaleKeys.health_apple_health_step3),
      ),
      _InstructionRow(
        icon: CupertinoIcons.square_grid_2x2_fill,
        iconColor: AppColors.textPrimary,
        text: tr(LocaleKeys.health_apple_health_step4),
        showDivider: false,
      ),
    ];
  }

  List<Widget> _buildAndroidSteps() {
    return [
      _InstructionRow(
        icon: CupertinoIcons.heart_circle,
        iconColor: const Color(0xFF4285F4),
        text: tr(LocaleKeys.health_health_connect_step1),
      ),
      _InstructionRow(
        icon: CupertinoIcons.square_grid_2x2_fill,
        iconColor: AppColors.textSecondary,
        text: tr(LocaleKeys.health_health_connect_step2),
      ),
      _InstructionRow(
        icon: CupertinoIcons.hand_draw,
        iconColor: AppColors.textPrimary,
        text: tr(LocaleKeys.health_health_connect_step3),
        showDivider: false,
      ),
    ];
  }

  String? _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return null;
    final diff = DateTime.now().difference(lastSync);
    if (diff.inMinutes < 1) return tr(LocaleKeys.health_last_synced, namedArgs: {'time': 'just now'});
    if (diff.inMinutes < 60) return tr(LocaleKeys.health_last_synced, namedArgs: {'time': '${diff.inMinutes} min ago'});
    if (diff.inHours < 24) return tr(LocaleKeys.health_last_synced, namedArgs: {'time': '${diff.inHours}h ago'});
    return tr(LocaleKeys.health_last_synced, namedArgs: {'time': '${diff.inDays}d ago'});
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: AppSpacing.m),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.s),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(text, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.settingsDividerIndent),
            child: Divider(height: AppSizes.dividerThin, color: AppColors.surface),
          ),
      ],
    );
  }
}
