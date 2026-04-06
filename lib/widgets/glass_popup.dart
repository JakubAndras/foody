import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GlassPopupItem {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;
  final bool showDividerAbove;
  final IconData? trailingIcon;

  const GlassPopupItem({required this.label, this.icon, this.color, this.selected = false, this.onTap, this.showDividerAbove = false, this.trailingIcon});
}

class GlassPopup extends StatelessWidget {
  final List<GlassPopupItem> items;

  const GlassPopup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
          decoration: BoxDecoration(color: AppColors.glassSheet, borderRadius: BorderRadius.circular(AppRadii.l)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (item) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.showDividerAbove) FractionallySizedBox(widthFactor: 0.95, child: Divider(height: AppSpacing.s, thickness: AppSizes.dividerThin, color: AppColors.textPrimary.withValues(alpha: 0.2))),
                      Padding(
                        padding: EdgeInsets.only(bottom: item == items.last ? 0 : AppSpacing.s, top: item.showDividerAbove ? AppSpacing.xs : 0),
                        child: InkWell(
                          onTap: item.onTap,
                          borderRadius: BorderRadius.circular(AppRadii.s),
                          child: SizedBox(
                            height: AppSizes.actionRowHeight,
                            child: Row(
                              children: [
                                if (item.selected)
                                  Icon(CupertinoIcons.checkmark, color: item.color ?? AppColors.primary, size: AppSizes.iconMd)
                                else if (item.icon != null)
                                  Icon(item.icon, color: item.color ?? AppColors.textPrimary, size: AppSizes.iconMd)
                                else
                                  SizedBox(width: AppSizes.iconMd),
                                const SizedBox(width: AppSpacing.s),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: AppTextStyles.body16.copyWith(
                                      fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
                                      height: 1.75,
                                      color: item.color ?? AppColors.textPrimary,
                                      letterSpacing: -0.4492,
                                    ),
                                  ),
                                ),
                                if (item.trailingIcon != null) Icon(item.trailingIcon, color: AppColors.textPrimary, size: AppSizes.iconMd),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

Future<void> showGlassPopup({required BuildContext context, required List<GlassPopupItem> items, Alignment anchor = Alignment.topRight, BuildContext? targetContext, Offset targetOffset = Offset.zero}) {
  Rect? targetRect;
  if (targetContext != null) {
    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      targetRect = position & renderBox.size;
    }
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Glass popup',
    barrierColor: AppColors.overlayDark40,
    transitionDuration: AppTheme.transitionDuration,
    pageBuilder: (dialogContext, _, _) {
      final mediaQuery = MediaQuery.of(dialogContext);
      final screenWidth = mediaQuery.size.width;
      final safeTop = mediaQuery.padding.top;

      final double top;
      final double? right;
      final double? left;

      if (targetRect != null) {
        top = targetRect.top + targetOffset.dy;
        right = screenWidth - targetRect.right + targetOffset.dx;
        left = null;
      } else {
        top = safeTop + AppSizes.topBarHeight + 4;
        right = anchor == Alignment.topRight ? AppSpacing.edge : null;
        left = anchor == Alignment.topLeft ? AppSpacing.edge : null;
      }

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(dialogContext).pop(), child: const SizedBox.expand()),
          ),
          Positioned(
            top: top,
            right: right,
            left: left,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: AppSizes.actionSheetWidth),
                child: GlassPopup(items: items),
              ),
            ),
          ),
        ],
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
