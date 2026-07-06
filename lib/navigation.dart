import 'package:flutter/widgets.dart';

/// Globální navigator key. Používá se VÝHRADNĚ pro navigaci z vnějších vstupních
/// bodů, kde není `BuildContext` (tap na notifikaci, akce home widgetu, deep-link).
/// V UI vrstvě naviguj přes `Navigator.of(context)`, ne přes tento klíč.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Kontext posledního Navigatoru (pro dialogy z vnějších vstupních bodů).
BuildContext? get rootNavigatorContext => navigatorKey.currentContext;
