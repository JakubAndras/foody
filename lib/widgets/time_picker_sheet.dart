import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerSheet extends StatefulWidget {
  const TimePickerSheet({super.key, required this.title, required this.initialTime});

  final String title;
  final TimeOfDay initialTime;

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = DateTime(2000, 1, 1, widget.initialTime.hour, widget.initialTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl), bottom: Radius.circular(AppRadii.xxl + 10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: CustomPaint(
            painter: const _GlassSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  const SheetDragHandle(),
                  const SizedBox(height: AppSpacing.m),
                  // Header
                  Text(widget.title, style: AppTextStyles.title17.copyWith(color: AppColors.black, fontWeight: FontWeight.w700)),
                  // Time picker
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: AppTextStyles.h4.copyWith(color: AppColors.black, fontWeight: FontWeight.w400, fontSize: 20),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: _selectedTime,
                        use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                        backgroundColor: Colors.transparent,
                        onDateTimeChanged: (DateTime date) {
                          _selectedTime = date;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Done button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute)),
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                          alignment: Alignment.center,
                          child: Text(tr(LocaleKeys.common_done), style: AppTextStyles.title18.copyWith(color: AppColors.onPrimary)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<TimeOfDay?> showTimePickerSheet({required BuildContext context, required String title, required TimeOfDay initialTime}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: AppColors.overlayDark,
    isScrollControlled: true,
    builder: (_) => TimePickerSheet(title: title, initialTime: initialTime),
  );
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
      topLeft: Radius.circular(AppRadii.xl),
      topRight: Radius.circular(AppRadii.xl),
      bottomRight: Radius.circular(AppRadii.xxl + 10),
      bottomLeft: Radius.circular(AppRadii.xxl + 10),
    );

    canvas.drawRRect(rrect, Paint()..color = const Color(0xB0FFFFFF));

    final highlightRect = Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndCorners(highlightRect, topLeft: Radius.circular(AppRadii.xl), topRight: Radius.circular(AppRadii.xl)),
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30FFFFFF), Color(0x00FFFFFF)]).createShader(highlightRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

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
