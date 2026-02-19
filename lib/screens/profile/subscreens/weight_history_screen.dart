import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/weight_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WeightHistoryScreen extends StatelessWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: ProfilePrimaryButton(
          label: 'Add Weight',
          height: AppSizes.buttonHeightCompact,
          onPressed: () => showWeightLogSheet(context),
        ),
      ),
      child: Column(
        children: [
          ProfileTopBar(title: 'Weight History', onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.l),
          Obx(() {
            final entries = WeightEntryController.to.entries;
            return Column(
              children: [
                WeightProgressCard(entries: entries),
                const SizedBox(height: AppSpacing.l),
                if (entries.isEmpty)
                  const _WeightHistoryEmptyState()
                else
                  WeightHistoryListView(
                    entries: entries,
                    onEntryTap: (entry) => showWeightLogSheet(context, entry: entry),
                  ),
                const SizedBox(height: AppSpacing.huge),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class WeightHistoryListView extends StatelessWidget {
  const WeightHistoryListView({super.key, required this.entries, this.onEntryTap});

  final List<WeightEntry> entries;
  final ValueChanged<WeightEntry>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _WeightHistoryEntryCard(
                  weight: _formatWeight(entry.weight),
                  date: _formatDate(entry.date),
                  onTap: onEntryTap == null ? null : () => onEntryTap!(entry),
                ),
              ))
          .toList(),
    );
  }

  String _formatWeight(double value) {
    final isInt = value % 1 == 0;
    final formatted = value.toStringAsFixed(isInt ? 0 : 1);
    return '$formatted kg';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}

class _WeightHistoryEntryCard extends StatelessWidget {
  const _WeightHistoryEntryCard({required this.weight, required this.date, this.onTap});

  final String weight;
  final String date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg2),
        child: Container(
          height: AppSizes.listRowHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadii.lg2),
            border: Border.all(color: AppColors.surfaceCardBorder),
            boxShadow: AppShadows.cardLite,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Row(
            children: [
              Text(weight, style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(date, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightHistoryEmptyState extends StatelessWidget {
  const _WeightHistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.listRowHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.lg2),
        border: Border.all(color: AppColors.surfaceCardBorder),
        boxShadow: AppShadows.cardLite,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      alignment: Alignment.center,
      child: Text(
        'No weight entries yet.',
        style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
