package com.example.diplomka

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ScanFoodShortcutWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.shortcut_widget).apply {
            setTextViewText(R.id.widget_label, "Scan Food")
            setImageViewResource(R.id.widget_icon, android.R.drawable.ic_menu_camera)

            val launchIntent =
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("diplomka://widget/scan_food?homeWidget=1"),
                )
            setOnClickPendingIntent(R.id.widget_container, launchIntent)
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
