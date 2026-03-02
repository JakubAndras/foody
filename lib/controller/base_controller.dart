import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/network/rest_client.dart';
import 'package:diplomka/utils/dialog_utils.dart';

abstract class BaseController extends FullLifeCycleController with FullLifeCycleMixin {
  Widget get progressWidget {
    return Center(
      child: CircularProgressIndicator(
        // semanticsLabel: tr(LocaleKeys.semantics_in_progress),
        color: Get.theme.colorScheme.secondary,
      ),
    );
  }

  Future<bool> hasInternet({bool withDialog = true}) async {
    if (RestClient.to.hasNetworkConnection.isFalse) {
      if (withDialog) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        await DialogUtils.showDialog(
          title: tr(LocaleKeys.error_no_internet),
          message: tr(LocaleKeys.error_no_internet_message),
        );
      }
      return false;
    }
    return true;
  }

  @override
  void onResumed() {}

  @override
  void onPaused() {}

  @override
  void onInactive() {}

  @override
  void onDetached() {}
}
