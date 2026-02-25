package com.example.diplomka

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BarcodeShortcutWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.shortcut_widget).apply {
            setTextViewText(R.id.widget_label, "Barcode")
            setImageViewResource(R.id.widget_icon, android.R.drawable.ic_menu_search)

            val launchIntent =
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("diplomka://widget/scan_barcode?homeWidget=1"),
                )
            setOnClickPendingIntent(R.id.widget_container, launchIntent)
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
