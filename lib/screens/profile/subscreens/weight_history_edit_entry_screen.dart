import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:flutter/material.dart';

class WeightHistoryEditEntryScreen extends StatelessWidget {
  const WeightHistoryEditEntryScreen({super.key, this.entry});

  final WeightEntry? entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: AppColors.overlayDark40),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.lg),
                  child: WeightLogSheet(entry: entry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
