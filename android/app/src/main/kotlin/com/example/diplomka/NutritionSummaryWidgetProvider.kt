package com.example.diplomka

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NutritionSummaryWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val payload = parseNutritionWidgetPayload(widgetData)

    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.nutrition_summary_widget).apply {
            val launchDashboardIntent =
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("diplomka://widget/open_dashboard?homeWidget=1"),
                )
            setOnClickPendingIntent(R.id.widget_container, launchDashboardIntent)

            setTextViewText(R.id.widget_calories_value, formatCalories(payload.caloriesToday))
            setTextViewText(
                R.id.widget_calories_goal,
                "/ ${formatCalories(payload.caloriesGoal)} kcal",
            )

            setProgressBar(R.id.widget_progress, 100, payload.progressPercent, false)
            setTextViewText(R.id.widget_protein, formatMacroGrams(payload.proteinToday))
            setTextViewText(R.id.widget_carbs, formatMacroGrams(payload.carbsToday))
            setTextViewText(R.id.widget_fat, formatMacroGrams(payload.fatToday))
            setTextViewText(R.id.widget_updated, formatUpdatedLabel(payload.lastUpdatedAtMillis))
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
