import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:flutter/material.dart';

/// Shows a centered info overlay dialog using the [ScanTipOverlay] style.
///
/// [title] — bold heading displayed at the top.
/// [body] — explanatory text below the title.
/// [child] — optional widget rendered above the title (e.g. an icon).
void showInfoDialog(BuildContext context, {required String title, required String body, Widget? child}) {
  showDialog(
    context: context,
    barrierColor: AppColors.overlayDark40,
    builder: (_) => _InfoDialogContent(title: title, body: body, child: child),
  );
}

class _InfoDialogContent extends StatelessWidget {
  const _InfoDialogContent({required this.title, required this.body, this.child});

  final String title;
  final String body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: ScanTipOverlay(
            title: title,
            body: body,
            onDismiss: () => Navigator.of(context).pop(),
            child: child,
          ),
        ),
      ),
    );
  }
}
