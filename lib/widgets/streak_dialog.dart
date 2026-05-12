import 'dart:io' show Platform;
import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/controller/streak_controller.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StreakSheet extends StatelessWidget {
  const StreakSheet({super.key});

  static const List<String> _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      isScrollControlled: true,
      builder: (_) => const StreakSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl), bottom: Radius.circular(AppRadii.xxl + 10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: CustomPaint(
            painter: const _GlassSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: FutureBuilder<StreakInfo>(
                future: StreakController.to.getStreakInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SheetDragHandle(),
                          const SizedBox(height: AppSpacing.xl),
                          const Icon(CupertinoIcons.exclamationmark_circle, color: AppColors.error, size: 48),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            tr(LocaleKeys.streak_error_loading, namedArgs: {'error': snapshot.error.toString()}),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body14Regular.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SheetDragHandle(),
                          const SizedBox(height: AppSpacing.xl),
                          Text(tr(LocaleKeys.streak_no_data), style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    );
                  }

                  final info = snapshot.data!;
                  final isNewRecord = info.currentStreak >= info.longestStreak && info.currentStreak > 0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.xxs),
                      const SheetDragHandle(),
                      const SizedBox(height: AppSpacing.l),
                      // Streak hero card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l)),
                          child: Column(
                            children: [
                              const Icon(CupertinoIcons.flame, size: 56, color: Colors.orange),
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                tr(LocaleKeys.streak_title, namedArgs: {'count': info.currentStreak.toString()}),
                                style: AppTextStyles.title18.copyWith(fontSize: 22, color: Colors.orange, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      // Week activity row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final active = info.activeDaysThisWeek[i];
                            return Column(
                              children: [
                                Text(
                                  _dayLetters[i],
                                  style: AppTextStyles.body13.copyWith(
                                    color: active ? Colors.orange : AppColors.calendarDarkMuted,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active ? Colors.orange.withValues(alpha: 0.18) : AppColors.calendarDarkMuted.withValues(alpha: 0.08),
                                    border: Border.all(color: active ? Colors.orange : AppColors.calendarDarkMuted.withValues(alpha: 0.25), width: 1.5),
                                  ),
                                  child: active ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.orange) : null,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      // Record row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l)),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.star_circle, size: 24, color: Colors.orange),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tr(LocaleKeys.streak_your_record), style: AppTextStyles.body13.copyWith(color: AppColors.calendarDarkMuted)),
                                    Text(
                                      tr(LocaleKeys.streak_days, namedArgs: {'count': info.longestStreak.toString()}),
                                      style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              if (isNewRecord)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
                                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadii.pill)),
                                  child: Text(
                                    tr(LocaleKeys.streak_new_record),
                                    style: AppTextStyles.body13.copyWith(color: Colors.orange, fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      // Motivational text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Text(
                          tr(LocaleKeys.streak_motivational),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14Regular.copyWith(color: AppColors.calendarDarkMuted),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSheetPainter extends CustomPainter {
  const _GlassSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromLTRBAndCorners(
      0,
      0,
      size.width,
      size.height,
      topLeft: Radius.circular(AppRadii.xxl),
      topRight: Radius.circular(AppRadii.xxl),
      bottomRight: Radius.circular(AppRadii.xxl + 10),
      bottomLeft: Radius.circular(AppRadii.xxl + 10),
    );

    canvas.drawRRect(rrect, Paint()..color = AppColors.pickerGlassBase);

    final highlightRect = Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndCorners(highlightRect, topLeft: Radius.circular(AppRadii.xxl), topRight: Radius.circular(AppRadii.xxl)),
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30FFFFFF), Color(0x00FFFFFF)]).createShader(highlightRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    canvas.drawRRect(
      rrect.deflate(0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.glassBorder,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
