import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class QuickActionSheet extends StatelessWidget {
  const QuickActionSheet({super.key, required this.onLogMeal, required this.onBarcode, required this.onVoiceLog, required this.onMealScan, required this.onExercise});

  final VoidCallback onLogMeal;
  final VoidCallback onBarcode;
  final VoidCallback onVoiceLog;
  final VoidCallback onMealScan;
  final VoidCallback onExercise;

  @override
  Widget build(BuildContext context) {
    return AppQuickAction.useGlassCards ? _buildV2(context) : _buildV1(context);
  }

  /// V1: Glass sheet background, white option cards
  Widget _buildV1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl), bottom: Radius.circular(AppRadii.xxl + 10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: CustomPaint(
            painter: const _GlassSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: _buildContent(_v1TileDecoration, _v1RowDecoration, AppColors.textEmphasis, AppTextStyles.body14, AppTextStyles.body14),
            ),
          ),
        ),
      ),
    );
  }

  /// V2: Transparent sheet background, glass option cards
  Widget _buildV2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: SafeArea(
        top: false,
        bottom: false,
        child: _buildContent(
          _v2TileDecoration,
          _v2RowDecoration,
          AppColors.black,
          AppTextStyles.body14.copyWith(color: AppColors.black),
          AppTextStyles.body14.copyWith(color: AppColors.black),
        ),
      ),
    );
  }

  Widget _buildContent(BoxDecoration tileDecoration, BoxDecoration rowDecoration, Color iconColor, TextStyle tileTextStyle, TextStyle rowTextStyle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.m),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!AppQuickAction.useGlassCards) const SheetDragHandle(),
          if (!AppQuickAction.useGlassCards) const SizedBox(height: AppSpacing.m),
          _buildGridRow(
            left: _QuickActionTile(
              icon: Icons.center_focus_strong,
              label: tr(LocaleKeys.quick_action_log_meal),
              iconBg: const Color(0x212B7FFF),
              onTap: onLogMeal,
              decoration: tileDecoration,
              iconColor: iconColor,
              textStyle: tileTextStyle,
            ),
            right: _QuickActionTile(
              icon: Icons.qr_code_2,
              label: tr(LocaleKeys.quick_action_barcode_scan),
              iconBg: const Color(0x21FB2C36),
              onTap: onBarcode,
              decoration: tileDecoration,
              iconColor: iconColor,
              textStyle: tileTextStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          _buildGridRow(
            left: _QuickActionTile(
              icon: Icons.mic,
              label: tr(LocaleKeys.quick_action_voice_log),
              iconBg: const Color(0x216366F1),
              onTap: onVoiceLog,
              decoration: tileDecoration,
              iconColor: iconColor,
              textStyle: tileTextStyle,
            ),
            right: _QuickActionTile(
              icon: Icons.photo_camera_outlined,
              label: tr(LocaleKeys.quick_action_meal_scan),
              iconBg: const Color(0x2105DF72),
              onTap: onMealScan,
              decoration: tileDecoration,
              iconColor: iconColor,
              textStyle: tileTextStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _ActionRow(
            icon: Icons.fitness_center_outlined,
            label: tr(LocaleKeys.quick_action_exercise),
            onTap: onExercise,
            decoration: rowDecoration,
            iconColor: iconColor,
            textStyle: rowTextStyle,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
      ),
    );
  }

  static final _v1TileDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppRadii.l),
    border: Border.all(color: AppColors.outline),
  );
  static final _v1RowDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppRadii.l),
    border: Border.all(color: AppColors.outline),
  );

  static BoxDecoration get _v2TileDecoration => BoxDecoration(
    color: const Color(0x40FFFFFF),
    borderRadius: BorderRadius.circular(AppRadii.l),
    border: Border.all(color: const Color(0x30FFFFFF), width: 0.8),
  );
  static BoxDecoration get _v2RowDecoration => BoxDecoration(
    color: const Color(0x40FFFFFF),
    borderRadius: BorderRadius.circular(AppRadii.l),
    border: Border.all(color: const Color(0x30FFFFFF), width: 0.8),
  );

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
    required this.decoration,
    required this.iconColor,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final VoidCallback onTap;
  final BoxDecoration decoration;
  final Color iconColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final tile = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
    if (!AppQuickAction.useGlassCards) return tile;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), child: tile),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.onTap, required this.decoration, required this.iconColor, required this.textStyle});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final BoxDecoration decoration;
  final Color iconColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final row = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(label, style: textStyle),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          dense: true,
        ),
      ),
    );
    if (!AppQuickAction.useGlassCards) return row;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), child: row),
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

    // Glass fill
    canvas.drawRRect(rrect, Paint()..color = const Color(0xB0FFFFFF));

    // Specular highlight at the top
    final highlightRect = Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndCorners(highlightRect, topLeft: Radius.circular(AppRadii.xxl), topRight: Radius.circular(AppRadii.xxl)),
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30FFFFFF), Color(0x00FFFFFF)]).createShader(highlightRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Border
    canvas.drawRRect(
      rrect.deflate(0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.white1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
