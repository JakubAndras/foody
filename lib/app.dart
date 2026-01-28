import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:get/get.dart';

import 'app_theme_data.dart';

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  DateTime? appPausedAt;
  final AppThemeData appThemeData = AppThemeData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.removeObserver(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        localizationsDelegates: [
          ...context.localizationDelegates,
          const LocaleNamesLocalizationsDelegate(),
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Foody',
        //themeMode: SessionManager.to.themeModeIndex.value,
        theme: appThemeData.themeData,
        //darkTheme: appThemeData.darkThemeData,
        home: const MainScreen(),
      ),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (appPausedAt != null) {}
        appPausedAt = null;
        break;

      case AppLifecycleState.paused:
        appPausedAt = DateTime.now();
        break;

      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }
}
