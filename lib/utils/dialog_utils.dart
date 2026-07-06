import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/navigation.dart';

class DialogUtils {
  static Future<void> showDialog({
    String? title,
    Widget? content,
    String? message,
    String? defaultActionTitle,
    List<DialogAction>? actions,
    Function(dynamic)? onClose,
    bool barrierDismissible = true,
    bool hideActions = false,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    List<PlatformDialogAction> dialogActions = [];

    if (actions?.isNotEmpty ?? false) {
      dialogActions = actions!
          .map(
            (action) => PlatformDialogAction(
              onPressed: action.onPressed ?? () => navigatorKey.currentState?.pop(),
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: action.isDefault,
                isDestructiveAction: action.isDestructive,
                textStyle: textTheme.titleMedium?.copyWith(color: action.isDestructive ? colorScheme.secondary : colorScheme.primary),
              ),
              child: PlatformText(
                action.title ?? "",
                semanticsLabel: action.title ?? "",
                style: textTheme.titleMedium?.copyWith(color: action.isDestructive ? colorScheme.secondary : colorScheme.primary),
              ),
            ),
          )
          .toList();
    } else {
      dialogActions.add(PlatformDialogAction(
        child: PlatformText(
          defaultActionTitle ?? tr(LocaleKeys.common_ok),
          style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
        ),
        onPressed: () => navigatorKey.currentState?.pop(),
        cupertino: (_, __) => CupertinoDialogActionData(
          isDefaultAction: true,
          isDestructiveAction: false,
          textStyle: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
        ),
      ));
    }

    try {
      final value = await material.showDialog<dynamic>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) => PopScope(
          canPop: barrierDismissible,
          child: PlatformAlertDialog(
            title: title != null ? Text(title, style: Platform.isAndroid ? textTheme.displaySmall : null) : null,
            content: content ??
                (message != null //
                    ? Text(message)
                    : null),
            actions: hideActions ? [] : dialogActions,
            material: (_, __) => MaterialAlertDialogData(shape: material.RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
            cupertino: (_, __) => CupertinoAlertDialogData(),
          ),
        ),
      );
      if (onClose != null) {
        onClose(value);
      }
    } catch (error) {
      //Logger.to.logError(error);
    }
  }

  static Future<dynamic> showProgressHUD({Widget? content, double contentWidth = 200.0, contentHeight = 180.0, ValueListenable<double?>? progress}) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future<dynamic>.value();
    final accentColor = Theme.of(context).colorScheme.secondary;
    return material.showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: SizedBox(
              width: content != null ? contentWidth : 150.0,
              height: content != null ? contentHeight : 150.0,
              child: material.AlertDialog(
                insetPadding: material.EdgeInsets.zero,
                contentPadding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                content: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    if (progress != null)
                      ValueListenableBuilder<double?>(
                        valueListenable: progress,
                        builder: (_, value, __) {
                          if (value == null) {
                            return Container();
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text("${(value * 100).toStringAsFixed(0)}%"),
                          );
                        },
                      ),
                    if (content != null) ...[content],
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSuccessDialog(String title, {Duration dismissTime = const Duration(seconds: 2), VoidCallback? onClose}) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Future.delayed(dismissTime, () {
      navigatorKey.currentState?.pop();
      onClose?.call();
    });

    return material.showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            width: 240,
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRect(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        "assets/images/ic_ok.png",
                        color: AppTheme.okColor,
                        width: 64,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DialogAction {
  final String? title;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;

  DialogAction({
    this.title,
    this.onPressed,
    this.isDefault = true,
    this.isDestructive = false,
  });
}
