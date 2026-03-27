import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class SheetDragHandle extends StatelessWidget {
  final Color? color;

  const SheetDragHandle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(color: color ?? AppColors.calendarDarkMuted.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
