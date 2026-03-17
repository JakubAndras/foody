import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class GlassPopupItem {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;

  const GlassPopupItem({required this.label, this.icon, this.color, this.selected = false, this.onTap});
}

class GlassPopup extends StatelessWidget {
  final List<GlassPopupItem> items;

  const GlassPopup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.m),
          decoration: BoxDecoration(color: AppColors.glassSheet, borderRadius: BorderRadius.circular(AppRadii.lg)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: item == items.last ? 0 : AppSpacing.s),
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: SizedBox(
                        height: AppSizes.actionRowHeight,
                        child: Row(
                          children: [
                            if (item.selected)
                              Icon(Icons.check_rounded, color: item.color ?? AppColors.primary, size: AppSizes.iconMd)
                            else if (item.icon != null)
                              Icon(item.icon, color: item.color ?? AppColors.textPrimary, size: AppSizes.iconMd)
                            else
                              SizedBox(width: AppSizes.iconMd),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                item.label,
                                style: AppTextStyles.selectMealPickerItem.copyWith(
                                  color: item.color ?? AppColors.textPrimary,
                                  fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

Future<void> showGlassPopup({
  required BuildContext context,
  required List<GlassPopupItem> items,
  Alignment anchor = Alignment.topRight,
}) {
  final double topInset = MediaQuery.of(context).padding.top;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Glass popup',
    barrierColor: AppColors.overlayDark40.withValues(alpha: 0.2),
    transitionDuration: AppTheme.transitionDuration,
    pageBuilder: (context, _, _) {
      return SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).pop(), child: const SizedBox.expand()),
            ),
            Positioned(
              top: topInset + AppSizes.topBarHeight + AppSpacing.xs,
              right: anchor == Alignment.topRight ? AppSpacing.edge : null,
              left: anchor == Alignment.topLeft ? AppSpacing.edge : null,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: AppSizes.actionSheetWidth),
                  child: GlassPopup(items: items),
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final alignmentForScale = anchor == Alignment.topRight ? Alignment.topRight : Alignment.topLeft;
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween<double>(begin: 0.96, end: 1).animate(curved), alignment: alignmentForScale, child: child),
      );
    },
  );
}
