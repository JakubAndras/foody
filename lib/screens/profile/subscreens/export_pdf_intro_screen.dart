import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_date_range_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ExportPdfIntroScreen extends StatelessWidget {
  const ExportPdfIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.l),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: ProfilePrimaryButton(
          label: tr(LocaleKeys.common_next),
          height: AppSizes.buttonHeight,
          radius: AppRadii.pill,
          onPressed: () => Get.to(() => const ExportPdfDateRangeScreen()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.export_intro_title), onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              tr(LocaleKeys.export_intro_subtitle),
              style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            padding: const EdgeInsets.all(AppSpacing.m),
            radius: AppRadii.l,
            shadow: AppShadows.screenCard,
            child: Column(
              children: [
                _FeatureItem(icon: CupertinoIcons.book, title: tr(LocaleKeys.export_meal_history), subtitle: tr(LocaleKeys.export_meal_history_desc)),
                const SizedBox(height: AppSpacing.m),
                _FeatureItem(icon: CupertinoIcons.flame, title: tr(LocaleKeys.export_exercise_history), subtitle: tr(LocaleKeys.export_exercise_history_desc)),
                const SizedBox(height: AppSpacing.m),
                _FeatureItem(icon: CupertinoIcons.graph_square, title: tr(LocaleKeys.export_weight_progress), subtitle: tr(LocaleKeys.export_weight_progress_desc)),
                const SizedBox(height: AppSpacing.m),
                _FeatureItem(icon: CupertinoIcons.chart_pie, title: tr(LocaleKeys.export_calorie_macros), subtitle: tr(LocaleKeys.export_calorie_macros_desc)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
          //const Center(child: _ReportIllustration()),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: AppSizes.iconLg, color: AppColors.textPrimary),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xxs),
              Text(subtitle, style: AppTextStyles.body14Relaxed.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      ],
    );
  }
}
