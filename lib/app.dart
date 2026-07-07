import 'package:diplomka/navigation.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_flow_screen.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/notification_bootstrap.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme_data.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  DateTime? appPausedAt;
  final AppThemeData appThemeData = AppThemeData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationBootstrap.run(ref);
    });
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.removeObserver(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(sessionProvider.select((s) => s.themeMode));
    final onboardingComplete = ref.watch(sessionProvider.select((s) => s.onboardingComplete));
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: [...context.localizationDelegates, const LocaleNamesLocalizationsDelegate()],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Foody',
        themeMode: themeMode,
        theme: appThemeData.themeData,
        darkTheme: appThemeData.darkThemeData,
        builder: (context, child) => DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(decoration: TextDecoration.none),
          child: child!,
        ),
        home: onboardingComplete ? const MainScreen() : const OnboardingFlowScreen(),
      ),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        appPausedAt = null;
        await ref.read(widgetSyncServiceProvider).syncToday(reason: 'app_resumed');
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
