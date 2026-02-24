import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_date_range_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ExportPdfIntroScreen extends StatelessWidget {
  const ExportPdfIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.l),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: ProfilePrimaryButton(
          label: 'Next',
          height: AppSizes.buttonHeightCompact,
          radius: AppRadii.md,
          onPressed: () => Get.to(() => const ExportPdfDateRangeScreen()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.l),
          Text('Get your PDF\nSummary Report', style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.s),
          Text(
            "Here's what you'll get in your summary report:",
            style: AppTextStyles.body16.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            padding: const EdgeInsets.all(AppSpacing.m),
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            child: Column(
              children: const [
                _FeatureItem(icon: Icons.restaurant_menu, title: 'Meal history', subtitle: 'All logged meals and nutrition details'),
                SizedBox(height: AppSpacing.m),
                _FeatureItem(icon: Icons.directions_run, title: 'Exercise history', subtitle: 'Logged workouts and activity sessions'),
                SizedBox(height: AppSpacing.m),
                _FeatureItem(icon: Icons.show_chart, title: 'Weight progress', subtitle: 'Weekly trend of recorded weight changes'),
                SizedBox(height: AppSpacing.m),
                _FeatureItem(icon: Icons.pie_chart_outline, title: 'Calorie & macros breakdown', subtitle: 'Historical breakdown of calories and macros'),
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

const List<Color> _barColors = [AppColors.reportRed, AppColors.reportPurple, AppColors.reportBlue];

class _LegendDot extends StatelessWidget {
  const _LegendDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
