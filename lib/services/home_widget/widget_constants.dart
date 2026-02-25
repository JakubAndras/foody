abstract final class WidgetConstants {
  static const int schemaVersion = 1;

  static const String iOSAppGroupId = 'group.com.jakubandras.diplomka.widgets';
  static const String payloadStorageKey = 'home_widget_payload';

  static const String deepLinkScheme = 'diplomka';
  static const String deepLinkHost = 'widget';
  static const String actionOpenDashboard = 'open_dashboard';
  static const String actionScanFood = 'scan_food';
  static const String actionScanBarcode = 'scan_barcode';

  static const String nutritionAndroidProvider = 'NutritionSummaryWidgetProvider';
  static const String scanFoodAndroidProvider = 'ScanFoodShortcutWidgetProvider';
  static const String barcodeAndroidProvider = 'BarcodeShortcutWidgetProvider';

  static const String nutritionIOSKind = 'NutritionSummaryWidget';
  static const String scanFoodIOSKind = 'ScanFoodShortcutWidget';
  static const String barcodeIOSKind = 'BarcodeShortcutWidget';
}
