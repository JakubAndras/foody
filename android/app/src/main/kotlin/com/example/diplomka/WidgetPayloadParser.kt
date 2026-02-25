package com.example.diplomka

import android.content.SharedPreferences
import kotlin.math.abs
import kotlin.math.roundToInt
import org.json.JSONObject
import java.util.Locale

private const val payloadStorageKey = "home_widget_payload"

data class NutritionWidgetPayload(
    val caloriesToday: Double,
    val caloriesGoal: Double,
    val proteinToday: Double,
    val carbsToday: Double,
    val fatToday: Double,
    val progressPercent: Int,
    val lastUpdatedAtMillis: Long,
) {
  companion object {
    fun empty(): NutritionWidgetPayload {
      return NutritionWidgetPayload(
          caloriesToday = 0.0,
          caloriesGoal = 0.0,
          proteinToday = 0.0,
          carbsToday = 0.0,
          fatToday = 0.0,
          progressPercent = 0,
          lastUpdatedAtMillis = 0L,
      )
    }
  }
}

fun parseNutritionWidgetPayload(widgetData: SharedPreferences): NutritionWidgetPayload {
  val payloadString = widgetData.getString(payloadStorageKey, null) ?: return NutritionWidgetPayload.empty()
  return try {
    val payload = JSONObject(payloadString)
    NutritionWidgetPayload(
        caloriesToday = payload.optDouble("caloriesToday", 0.0),
        caloriesGoal = payload.optDouble("caloriesGoal", 0.0),
        proteinToday = payload.optDouble("proteinToday", 0.0),
        carbsToday = payload.optDouble("carbsToday", 0.0),
        fatToday = payload.optDouble("fatToday", 0.0),
        progressPercent = (payload.optDouble("progress", 0.0).coerceIn(0.0, 1.0) * 100).roundToInt(),
        lastUpdatedAtMillis = payload.optLong("lastUpdatedAtMillis", 0L),
    )
  } catch (_: Exception) {
    NutritionWidgetPayload.empty()
  }
}

fun formatMacroGrams(value: Double): String {
  val rounded = value.roundToInt().toDouble()
  return if (abs(value - rounded) < 0.05) {
    "${rounded.toInt()}g"
  } else {
    "${String.format(Locale.US, "%.1f", value)}g"
  }
}

fun formatCalories(value: Double): String {
  return value.roundToInt().toString()
}

fun formatUpdatedLabel(lastUpdatedAtMillis: Long): String {
  if (lastUpdatedAtMillis <= 0L) return "Updated recently"
  val now = System.currentTimeMillis()
  val elapsedMinutes = ((now - lastUpdatedAtMillis) / 60000L).coerceAtLeast(0)
  return if (elapsedMinutes <= 0) {
    "Updated just now"
  } else {
    "Updated ${elapsedMinutes}m ago"
  }
}
