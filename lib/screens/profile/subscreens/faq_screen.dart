import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  List<_FaqItem> get _items => [
        _FaqItem(question: tr(LocaleKeys.faq_q_how_does_foody_work), answer: tr(LocaleKeys.faq_a_how_does_foody_work)),
        _FaqItem(question: tr(LocaleKeys.faq_q_how_accurate), answer: tr(LocaleKeys.faq_a_how_accurate)),
        _FaqItem(question: tr(LocaleKeys.faq_q_estimate_off), answer: tr(LocaleKeys.faq_a_estimate_off)),
        _FaqItem(question: tr(LocaleKeys.faq_q_per_serving), answer: tr(LocaleKeys.faq_a_per_serving)),
        _FaqItem(question: tr(LocaleKeys.faq_q_without_photo), answer: tr(LocaleKeys.faq_a_without_photo)),
        _FaqItem(question: tr(LocaleKeys.faq_q_barcode), answer: tr(LocaleKeys.faq_a_barcode)),
        _FaqItem(question: tr(LocaleKeys.faq_q_nutrition_goals), answer: tr(LocaleKeys.faq_a_nutrition_goals)),
        _FaqItem(question: tr(LocaleKeys.faq_q_data_storage), answer: tr(LocaleKeys.faq_a_data_storage)),
      ];

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.profile_faq), onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isExpanded = _expandedIndex == index;
            return _ExpandableFaqItem(
              question: item.question,
              answer: item.answer,
              isExpanded: isExpanded,
              onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
            );
          }),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class _ExpandableFaqItem extends StatelessWidget {
  const _ExpandableFaqItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: AppTheme.transitionDuration,
                  child: const Icon(CupertinoIcons.chevron_right, size: AppSizes.iconMd, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: AppTheme.transitionDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.s),
                        border: Border(left: BorderSide(color: AppColors.outline, width: 3)),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Text(
                        answer,
                        style: AppTextStyles.body14Relaxed,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
