import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';

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
    List<PlatformDialogAction> dialogActions = [];

    if (actions?.isNotEmpty ?? false) {
      dialogActions = actions!
          .map(
            (action) => PlatformDialogAction(
              onPressed: action.onPressed ?? () => Get.back(),
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: action.isDefault,
                isDestructiveAction: action.isDestructive,
                textStyle: Get.textTheme.titleMedium?.copyWith(color: action.isDestructive ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary),
              ),
              child: PlatformText(
                action.title ?? "",
                semanticsLabel: action.title ?? "",
                style: Get.textTheme.titleMedium?.copyWith(color: action.isDestructive ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary),
              ),
            ),
          )
          .toList();
    } else {
      dialogActions.add(PlatformDialogAction(
        child: PlatformText(
          tr(defaultActionTitle ?? "LocaleKeys.ok"),
          style: Get.textTheme.titleMedium?.copyWith(color: Get.theme.colorScheme.primary),
        ),
        onPressed: () => Get.back(),
        cupertino: (_, __) => CupertinoDialogActionData(
          isDefaultAction: true,
          isDestructiveAction: false,
          textStyle: Get.textTheme.titleMedium?.copyWith(color: Get.theme.colorScheme.primary),
        ),
      ));
    }

    try {
      await Get.dialog(
        WillPopScope(
          onWillPop: () => Future.value(barrierDismissible),
          child: PlatformAlertDialog(
            title: title != null ? Text(title, style: Platform.isAndroid ? Get.textTheme.displaySmall : null) : null,
            content: content ??
                (message != null //
                    ? Text(message)
                    : null),
            actions: hideActions ? [] : dialogActions,
            material: (_, __) => MaterialAlertDialogData(shape: material.RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
            cupertino: (_, __) => CupertinoAlertDialogData(),
          ),
        ),
        barrierDismissible: barrierDismissible,
      ).then((value) {
        if (onClose != null) {
          onClose(value);
        }
      });
    } catch (error) {
      //Logger.to.logError(error);
    }
  }

  static Future<dynamic> showProgressHUD({Widget? content, double contentWidth = 200.0, contentHeight = 180.0, RxnDouble? progress}) {
    final context = Get.context;
    return material.showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (BuildContext context) {
        final accentColor = Get.theme.colorScheme.secondary;

        return WillPopScope(
          onWillPop: () async => false,
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
                      Obx(() {
                        if (progress.value == null) {
                          return Container();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text("progress.value!.toPercentString()"),
                        );
                      }),
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
    final context = Get.context;

    Future.delayed(dismissTime, () {
      Get.back();
      onClose?.call();
    });

    return material.showDialog(
      barrierDismissible: false,
      context: context!,
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
