import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:diplomka/database/entities/ai_attempt_entity.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _dateTimeFmt = DateFormat('yyyy-MM-dd HH:mm');

  static const _headerDeco = pw.BoxDecoration(color: PdfColor.fromInt(0xFF0A0A0A));
  static const _oddRowDeco = pw.BoxDecoration(color: PdfColor.fromInt(0xFFF5F5F5));

  // ─── CSV ──────────────────────────────────────────────────────────────

  static String generateCsv(
    List<DayRecord> records,
    List<WeightEntry> weights, {
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    String? sex,
    String? goal,
    String? dietType,
    String? customDietPreferences,
    double? weightChangeRateKgPerWeek,
    bool? prefersMetric,
    DateTime? dateOfBirth,
    // RESEARCH-ONLY: research-only — emit the AI attempt log section. Drop
    // with the rest of telemetry. See RESEARCH_ONLY.md.
    List<AiAttemptEntity> aiAttempts = const [],
  }) {
    final rows = <List<dynamic>>[];

    // ── Section 0: User Profile ──
    rows.add(['--- ${tr(LocaleKeys.export_user_profile)} ---']);
    rows.add([tr(LocaleKeys.export_csv_height), heightCm != null ? '${heightCm.round()}' : '']);
    rows.add([tr(LocaleKeys.export_csv_weight), weightKg != null ? '$weightKg' : '']);
    rows.add([tr(LocaleKeys.export_csv_goal_weight), goalWeightKg != null ? '$goalWeightKg' : '']);
    rows.add([tr(LocaleKeys.export_csv_sex), sex ?? '']);
    rows.add([tr(LocaleKeys.export_csv_goal), goal ?? '']);
    rows.add([tr(LocaleKeys.export_csv_diet_type_label), dietType ?? '']);
    rows.add([tr(LocaleKeys.export_csv_custom_diet), customDietPreferences ?? '']);
    rows.add([tr(LocaleKeys.export_csv_weight_change_rate), weightChangeRateKgPerWeek != null ? '$weightChangeRateKgPerWeek' : '']);
    rows.add([tr(LocaleKeys.export_csv_prefers_metric), prefersMetric != null ? (prefersMetric ? 'yes' : 'no') : '']);
    rows.add([tr(LocaleKeys.export_csv_date_of_birth), dateOfBirth != null ? _dateFmt.format(dateOfBirth) : '']);

    // RESEARCH-ONLY: build a "living" view that excludes soft-deleted meals
    // and ingredients. Used for daily summary aggregates so deleted records
    // don't inflate intake. The full `records` list (with deleted) is still
    // used in Meal Details so the AI snapshot of removed records survives.
    final livingRecords = records.map(_excludeDeleted).toList();

    // ── Section 1: Daily Summary ──
    rows.add([]);
    rows.add(['--- ${tr(LocaleKeys.export_daily_summary)} ---']);
    rows.add([
      tr(LocaleKeys.export_csv_date),
      tr(LocaleKeys.export_csv_calories),
      tr(LocaleKeys.export_csv_protein),
      tr(LocaleKeys.export_csv_carbs),
      tr(LocaleKeys.export_csv_fat),
      tr(LocaleKeys.export_csv_calorie_goal),
      tr(LocaleKeys.export_csv_protein_goal),
      tr(LocaleKeys.export_csv_carbs_goal),
      tr(LocaleKeys.export_csv_fat_goal),
      tr(LocaleKeys.export_csv_exercise_calories),
      tr(LocaleKeys.export_csv_net_calories),
      tr(LocaleKeys.export_csv_meal_count),
      tr(LocaleKeys.export_csv_exercise_count),
    ]);
    for (final r in livingRecords) {
      rows.add([
        _dateFmt.format(r.date),
        r.totalCalories.round(),
        r.totalProteins.round(),
        r.totalCarbs.round(),
        r.totalFats.round(),
        r.calorieGoal.round(),
        r.proteinGoal.round(),
        r.carbsGoal.round(),
        r.fatGoal.round(),
        r.totalExerciseCalories.round(),
        r.netCalories.round(),
        r.meals.length,
        r.exercises.length,
      ]);
    }

    // ── Calorie balance ──
    final totalConsumed = livingRecords.fold<double>(0, (s, r) => s + r.totalCalories);
    final totalBurned = livingRecords.fold<double>(0, (s, r) => s + r.totalExerciseCalories);
    if (records.isNotEmpty) {
      rows.add([]);
      rows.add([tr(LocaleKeys.export_consumed), '${totalConsumed.round()} ${tr(LocaleKeys.common_kcal)}']);
      rows.add([tr(LocaleKeys.export_burned), '${totalBurned.round()} ${tr(LocaleKeys.common_kcal)}']);
      rows.add([tr(LocaleKeys.export_balance), '${(totalConsumed - totalBurned).round()} ${tr(LocaleKeys.common_kcal)}']);
    }

    // ── Section 2: Meal Details ──
    // RESEARCH-ONLY: 23 telemetry columns added to this section
    // (input_source, ai_provider, ai_model, barcode, meal_was_edited_by_user,
    // meal_edited_at, meal_deleted_at, meal_ai_original_*,
    // ing_was_edited_by_user, ing_deleted_at, ing_ai_original_*). Strip them
    // and revert to the pre-thesis 13-column schema before production. See
    // RESEARCH_ONLY.md.
    final hasMeals = records.any((r) => r.meals.isNotEmpty);
    if (hasMeals) {
      rows.add([]);
      rows.add(['--- ${tr(LocaleKeys.export_meal_details)} ---']);
      rows.add([
        tr(LocaleKeys.export_csv_date),
        tr(LocaleKeys.common_meal),
        tr(LocaleKeys.export_csv_meal_timestamp),
        tr(LocaleKeys.export_csv_meal_confidence),
        tr(LocaleKeys.export_csv_has_photo),
        // ── Telemetry: meal-level ──
        'input_source',
        'ai_provider',
        'ai_model',
        'barcode',
        'meal_was_edited_by_user',
        'meal_edited_at',
        'meal_deleted_at',
        'meal_ai_original_name',
        'meal_ai_original_calories',
        'meal_ai_original_proteins',
        'meal_ai_original_carbs',
        'meal_ai_original_fats',
        'meal_ai_original_confidence',
        // ── Ingredient ──
        tr(LocaleKeys.common_ingredients),
        tr(LocaleKeys.common_weight),
        tr(LocaleKeys.export_csv_ingredient_amount),
        tr(LocaleKeys.export_csv_calories),
        tr(LocaleKeys.export_csv_protein),
        tr(LocaleKeys.export_csv_carbs),
        tr(LocaleKeys.export_csv_fat),
        tr(LocaleKeys.export_csv_ingredient_confidence),
        // ── Telemetry: ingredient-level ──
        'ing_was_edited_by_user',
        'ing_deleted_at',
        'ing_ai_original_name',
        'ing_ai_original_weight',
        'ing_ai_original_amount',
        'ing_ai_original_calories',
        'ing_ai_original_proteins',
        'ing_ai_original_carbs',
        'ing_ai_original_fats',
        'ing_ai_original_confidence',
      ]);
      for (final r in records) {
        for (final meal in r.meals) {
          final mealTimestamp = _dateTimeFmt.format(meal.timestamp);
          final mealConf = meal.confidence != null ? meal.confidence!.toStringAsFixed(2) : '';
          final hasPhoto = meal.photoPath != null ? 'yes' : 'no';

          final mealCols = [
            meal.inputSource ?? '',
            meal.aiProvider ?? '',
            meal.aiModel ?? '',
            meal.barcode ?? '',
            meal.wasEditedByUser ? 'yes' : 'no',
            meal.editedAt != null ? _dateTimeFmt.format(meal.editedAt!) : '',
            meal.deletedAt != null ? _dateTimeFmt.format(meal.deletedAt!) : '',
            meal.aiOriginalName ?? '',
            meal.aiOriginalCalories != null ? meal.aiOriginalCalories!.round() : '',
            meal.aiOriginalProteins != null ? meal.aiOriginalProteins!.round() : '',
            meal.aiOriginalCarbs != null ? meal.aiOriginalCarbs!.round() : '',
            meal.aiOriginalFats != null ? meal.aiOriginalFats!.round() : '',
            meal.aiOriginalConfidence != null ? meal.aiOriginalConfidence!.toStringAsFixed(2) : '',
          ];

          if (meal.ingredients.isEmpty) {
            rows.add([
              _dateFmt.format(r.date),
              meal.name,
              mealTimestamp,
              mealConf,
              hasPhoto,
              ...mealCols,
              '', '', '', '', '', '', '', '', // ingredient nutrient cols
              '', '', '', '', '', '', '', '', '', '', // ingredient telemetry cols
            ]);
          }
          for (final ing in meal.ingredients) {
            rows.add([
              _dateFmt.format(r.date),
              meal.name,
              mealTimestamp,
              mealConf,
              hasPhoto,
              ...mealCols,
              ing.name,
              ing.weight.round(),
              ing.amount,
              ing.calories.round(),
              ing.proteins.round(),
              ing.carbs.round(),
              ing.fats.round(),
              ing.confidence != null ? ing.confidence!.toStringAsFixed(2) : '',
              ing.wasEditedByUser ? 'yes' : 'no',
              ing.deletedAt != null ? _dateTimeFmt.format(ing.deletedAt!) : '',
              ing.aiOriginalName ?? '',
              ing.aiOriginalWeight != null ? ing.aiOriginalWeight!.round() : '',
              ing.aiOriginalAmount ?? '',
              ing.aiOriginalCalories != null ? ing.aiOriginalCalories!.round() : '',
              ing.aiOriginalProteins != null ? ing.aiOriginalProteins!.round() : '',
              ing.aiOriginalCarbs != null ? ing.aiOriginalCarbs!.round() : '',
              ing.aiOriginalFats != null ? ing.aiOriginalFats!.round() : '',
              ing.aiOriginalConfidence != null ? ing.aiOriginalConfidence!.toStringAsFixed(2) : '',
            ]);
          }
        }
      }
    }

    // ── Section 3: Exercise Log ──
    final hasExercises = records.any((r) => r.exercises.isNotEmpty);
    if (hasExercises) {
      rows.add([]);
      rows.add(['--- ${tr(LocaleKeys.export_exercise_log)} ---']);
      rows.add([
        tr(LocaleKeys.export_csv_date),
        tr(LocaleKeys.common_name),
        tr(LocaleKeys.common_duration),
        tr(LocaleKeys.export_csv_calories),
        tr(LocaleKeys.export_csv_source),
      ]);
      for (final r in records) {
        for (final e in r.exercises) {
          rows.add([
            _dateTimeFmt.format(e.timestamp),
            e.name,
            e.durationMinutes ?? '',
            e.caloriesBurned.round(),
            e.source ?? 'manual',
          ]);
        }
      }
    }

    // ── Section 4: Weight Progress ──
    if (weights.isNotEmpty) {
      rows.add([]);
      rows.add(['--- ${tr(LocaleKeys.progress_weight_progress)} ---']);
      rows.add([tr(LocaleKeys.export_csv_date), tr(LocaleKeys.export_csv_weight), tr(LocaleKeys.export_csv_has_photo)]);
      for (final w in weights) {
        rows.add([_dateFmt.format(w.date), w.weight, w.photoPath != null ? 'yes' : 'no']);
      }
    }

    // ── Section X: AI Attempts ──
    // RESEARCH-ONLY: research-only — every AI invocation outcome (success,
    // low confidence, parse failure, network error). Drop entire section
    // before production. See RESEARCH_ONLY.md.
    if (aiAttempts.isNotEmpty) {
      rows.add([]);
      rows.add(['--- AI Attempts ---']);
      rows.add([
        'Timestamp',
        'kind',
        'modality',
        'provider',
        'model',
        'status',
        'confidence',
        'error_message',
        'prompt_tokens',
        'completion_tokens',
        'cached_tokens',
        'cost_usd',
      ]);
      for (final a in aiAttempts) {
        rows.add([
          _dateTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(a.timestampMs)),
          a.kind,
          a.modality ?? '',
          a.provider ?? '',
          a.model ?? '',
          a.status,
          a.confidence != null ? a.confidence!.toStringAsFixed(2) : '',
          a.errorMessage ?? '',
          a.promptTokens?.toString() ?? '',
          a.completionTokens?.toString() ?? '',
          a.cachedTokens?.toString() ?? '',
          a.costUsd != null ? a.costUsd!.toStringAsFixed(6) : '',
        ]);
      }
    }

    // ── Section 5: Summary Statistics ──
    final totalMeals = livingRecords.fold<int>(0, (s, r) => s + r.meals.length);
    final totalIngredients = livingRecords.fold<int>(0, (s, r) => s + r.meals.fold<int>(0, (ms, m) => ms + m.ingredients.length));
    final totalExercises = livingRecords.fold<int>(0, (s, r) => s + r.exercises.length);
    rows.add([]);
    rows.add(['--- ${tr(LocaleKeys.export_summary_statistics)} ---']);
    rows.add([tr(LocaleKeys.export_csv_total_days), livingRecords.length]);
    rows.add([tr(LocaleKeys.export_csv_total_meals), totalMeals]);
    rows.add([tr(LocaleKeys.export_csv_total_ingredients), totalIngredients]);
    rows.add([tr(LocaleKeys.export_csv_total_exercises), totalExercises]);
    rows.add([tr(LocaleKeys.export_csv_total_weight_entries), weights.length]);
    if (livingRecords.isNotEmpty) {
      rows.add([tr(LocaleKeys.export_csv_avg_calories_per_day), (totalConsumed / livingRecords.length).round()]);
      rows.add([tr(LocaleKeys.export_csv_avg_protein_per_day), (livingRecords.fold<double>(0, (s, r) => s + r.totalProteins) / livingRecords.length).round()]);
      rows.add([tr(LocaleKeys.export_csv_avg_carbs_per_day), (livingRecords.fold<double>(0, (s, r) => s + r.totalCarbs) / livingRecords.length).round()]);
      rows.add([tr(LocaleKeys.export_csv_avg_fat_per_day), (livingRecords.fold<double>(0, (s, r) => s + r.totalFats) / livingRecords.length).round()]);
      rows.add([tr(LocaleKeys.export_csv_avg_meals_per_day), (totalMeals / livingRecords.length).toStringAsFixed(1)]);
      rows.add([tr(LocaleKeys.export_csv_avg_exercises_per_day), (totalExercises / livingRecords.length).toStringAsFixed(1)]);
    }

    // RESEARCH-ONLY: research-only roll-up of soft-deleted counts. Useful
    // shortcut so the analyst can see at a glance how many records the user
    // discarded. Drop with the rest of telemetry.
    final deletedMealCount = records.fold<int>(0, (s, r) => s + r.meals.where((m) => m.deletedAt != null).length);
    final deletedIngredientCount = records.fold<int>(0, (s, r) => s + r.meals.fold<int>(0, (ms, m) => ms + m.ingredients.where((i) => i.deletedAt != null).length));
    if (deletedMealCount > 0 || deletedIngredientCount > 0) {
      rows.add(['Soft-deleted meals', deletedMealCount]);
      rows.add(['Soft-deleted ingredients', deletedIngredientCount]);
    }
    if (aiAttempts.isNotEmpty) {
      final byStatus = <String, int>{};
      for (final a in aiAttempts) {
        byStatus[a.status] = (byStatus[a.status] ?? 0) + 1;
      }
      rows.add(['AI attempts (total)', aiAttempts.length]);
      for (final entry in byStatus.entries) {
        rows.add(['AI attempts (${entry.key})', entry.value]);
      }
    }

    // RESEARCH-ONLY: AI Usage Summary for cost analysis. Drop with the rest of telemetry.
    if (aiAttempts.isNotEmpty) {
      final agg = _aggregateAiUsage(aiAttempts);
      rows.add([]);
      rows.add(['--- AI Usage Summary ---']);
      rows.add(['Total AI calls', agg.totalCalls]);
      rows.add(['Total prompt tokens (input)', agg.totalPrompt]);
      rows.add(['Of which cached (input)', agg.totalCached]);
      rows.add(['Total completion tokens (output)', agg.totalCompletion]);
      rows.add(['Total cost (USD)', agg.totalCost.toStringAsFixed(6)]);
      rows.add([]);
      rows.add(['By model:', 'calls', 'prompt', 'completion', 'cached', 'cost_usd']);
      for (final e in agg.byModel.entries) {
        rows.add([e.key, e.value.calls, e.value.prompt, e.value.completion, e.value.cached, e.value.cost.toStringAsFixed(6)]);
      }
      rows.add([]);
      rows.add(['By kind:', 'calls', 'cost_usd']);
      for (final e in agg.byKind.entries) {
        rows.add([e.key, e.value.calls, e.value.cost.toStringAsFixed(6)]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  // RESEARCH-ONLY: research-only helper. Drop with the rest of telemetry.
  static DayRecord _excludeDeleted(DayRecord record) {
    final livingMeals = record.meals
        .where((m) => m.deletedAt == null)
        .map((m) => m.copyWith(ingredients: m.ingredients.where((i) => i.deletedAt == null).toList()))
        .toList();
    return record.copyWith(meals: livingMeals);
  }

  // ─── PDF ──────────────────────────────────────────────────────────────

  static Future<Uint8List> generatePdf(
    List<DayRecord> records,
    List<WeightEntry> weights,
    String dateRangeLabel, {
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    String? dietType,
    List<AiAttemptEntity> aiAttempts = const [],
  }) async {
    final regularData = await rootBundle.load('assets/fonts/Ubuntu-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Ubuntu-Bold.ttf');
    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    // RESEARCH-ONLY: filter out soft-deleted meals from aggregate display
    // so the user-facing PDF reflects the actual intake. The full `records`
    // list is still used in Meal Details so soft-deleted records remain
    // visible in the export. Drop with telemetry.
    final livingRecords = records.map(_excludeDeleted).toList();

    // Pre-compute averages & totals
    final avgCalories = livingRecords.isEmpty ? 0.0 : livingRecords.fold<double>(0, (s, r) => s + r.totalCalories) / livingRecords.length;
    final avgProtein = livingRecords.isEmpty ? 0.0 : livingRecords.fold<double>(0, (s, r) => s + r.totalProteins) / livingRecords.length;
    final avgCarbs = livingRecords.isEmpty ? 0.0 : livingRecords.fold<double>(0, (s, r) => s + r.totalCarbs) / livingRecords.length;
    final avgFat = livingRecords.isEmpty ? 0.0 : livingRecords.fold<double>(0, (s, r) => s + r.totalFats) / livingRecords.length;
    final totalConsumed = livingRecords.fold<double>(0, (s, r) => s + r.totalCalories);
    final totalBurned = livingRecords.fold<double>(0, (s, r) => s + r.totalExerciseCalories);
    final calorieBalance = totalConsumed - totalBurned;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _pdfHeader(dateRangeLabel),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ),
        build: (context) => [
          // ── Profile Summary ──
          if (calorieGoal != null || proteinGoal != null || carbsGoal != null || fatGoal != null || dietType != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(tr(LocaleKeys.export_daily_goals), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${tr(LocaleKeys.common_calories)}: ${calorieGoal?.round() ?? "-"} ${tr(LocaleKeys.common_kcal)}  |  ${tr(LocaleKeys.common_protein)}: ${proteinGoal?.round() ?? "-"}${tr(LocaleKeys.common_g)}  |  ${tr(LocaleKeys.common_carbs)}: ${carbsGoal?.round() ?? "-"}${tr(LocaleKeys.common_g)}  |  ${tr(LocaleKeys.common_fats)}: ${fatGoal?.round() ?? "-"}${tr(LocaleKeys.common_g)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ]),
                  if (dietType != null) pw.Text('${tr(LocaleKeys.export_diet_type)}: $dietType', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),

          // ── Summary ──
          pw.Header(level: 1, text: tr(LocaleKeys.export_daily_summary)),
          _buildDailySummaryTable(livingRecords),
          pw.SizedBox(height: 8),
          pw.Text(
            '${tr(LocaleKeys.export_period_averages_label)}: ${tr(LocaleKeys.common_calories)}: ${avgCalories.round()} ${tr(LocaleKeys.common_kcal)}  |  ${tr(LocaleKeys.common_protein)}: ${avgProtein.round()}${tr(LocaleKeys.common_g)}  |  ${tr(LocaleKeys.common_carbs)}: ${avgCarbs.round()}${tr(LocaleKeys.common_g)}  |  ${tr(LocaleKeys.common_fats)}: ${avgFat.round()}${tr(LocaleKeys.common_g)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${tr(LocaleKeys.export_calorie_balance)}: ${tr(LocaleKeys.export_consumed)} ${totalConsumed.round()} ${tr(LocaleKeys.common_kcal)}  |  ${tr(LocaleKeys.export_burned)} ${totalBurned.round()} ${tr(LocaleKeys.common_kcal)}  |  ${tr(LocaleKeys.export_balance)} ${calorieBalance.round()} ${tr(LocaleKeys.common_kcal)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),

          // ── Meal details ──
          pw.Header(level: 1, text: tr(LocaleKeys.export_meal_details)),
          ...livingRecords.expand((r) => _buildDayMealDetails(r)),

          // ── Exercise log ──
          if (livingRecords.any((r) => r.exercises.isNotEmpty)) ...[
            pw.Header(level: 1, text: tr(LocaleKeys.export_exercise_log)),
            _buildExerciseTable(livingRecords),
            pw.SizedBox(height: 16),
          ],

          // ── Weight progress ──
          if (weights.isNotEmpty) ...[
            pw.Header(level: 1, text: tr(LocaleKeys.progress_weight_progress)),
            _buildWeightTable(weights),
          ],

          // RESEARCH-ONLY: AI Usage Summary for cost analysis.
          if (aiAttempts.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'AI Usage Summary'),
            _buildAiUsageSummaryPdf(aiAttempts),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _pdfHeader(String dateRangeLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Foody - ${tr(LocaleKeys.export_pdf_title)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(dateRangeLabel, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildDailySummaryTable(List<DayRecord> records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: _headerDeco,
      oddRowDecoration: _oddRowDeco,
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerRight,
      headerAlignment: pw.Alignment.centerRight,
      headers: [tr(LocaleKeys.export_csv_date), tr(LocaleKeys.common_calories), tr(LocaleKeys.common_protein), tr(LocaleKeys.common_carbs), tr(LocaleKeys.common_fats), tr(LocaleKeys.export_csv_calorie_goal), tr(LocaleKeys.common_exercise), tr(LocaleKeys.export_csv_net_calories)],
      data: records
          .map((r) => [
                _dateFmt.format(r.date),
                '${r.totalCalories.round()}',
                '${r.totalProteins.round()}${tr(LocaleKeys.common_g)}',
                '${r.totalCarbs.round()}${tr(LocaleKeys.common_g)}',
                '${r.totalFats.round()}${tr(LocaleKeys.common_g)}',
                '${r.calorieGoal.round()}',
                '${r.totalExerciseCalories.round()}',
                '${r.netCalories.round()}',
              ])
          .toList(),
    );
  }

  static List<pw.Widget> _buildDayMealDetails(DayRecord record) {
    if (record.meals.isEmpty) return [];
    return [
      pw.Header(level: 2, text: _dateFmt.format(record.date)),
      ...record.meals.map((meal) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(meal.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              if (meal.ingredients.isNotEmpty)
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: _headerDeco,
                  oddRowDecoration: _oddRowDeco,
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  cellAlignment: pw.Alignment.centerRight,
                  headerAlignment: pw.Alignment.centerRight,
                  headers: [tr(LocaleKeys.common_ingredients), tr(LocaleKeys.common_weight), tr(LocaleKeys.common_calories), tr(LocaleKeys.common_protein), tr(LocaleKeys.common_carbs), tr(LocaleKeys.common_fats)],
                  data: meal.ingredients
                      .map((i) => [
                            i.name,
                            '${i.weight.round()}${tr(LocaleKeys.common_g)}',
                            '${i.calories.round()}',
                            '${i.proteins.round()}${tr(LocaleKeys.common_g)}',
                            '${i.carbs.round()}${tr(LocaleKeys.common_g)}',
                            '${i.fats.round()}${tr(LocaleKeys.common_g)}',
                          ])
                      .toList(),
                ),
            ],
          ),
        );
      }),
    ];
  }

  static pw.Widget _buildExerciseTable(List<DayRecord> records) {
    final exerciseRows = <List<String>>[];
    for (final r in records) {
      for (final e in r.exercises) {
        exerciseRows.add([
          _dateTimeFmt.format(e.timestamp),
          e.name,
          e.durationMinutes != null ? '${e.durationMinutes} ${tr(LocaleKeys.common_min)}' : '-',
          '${e.caloriesBurned.round()} ${tr(LocaleKeys.common_kcal)}',
        ]);
      }
    }
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: _headerDeco,
      oddRowDecoration: _oddRowDeco,
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: [tr(LocaleKeys.export_csv_date), tr(LocaleKeys.common_exercise), tr(LocaleKeys.common_duration), tr(LocaleKeys.common_calories)],
      data: exerciseRows,
    );
  }

  static pw.Widget _buildWeightTable(List<WeightEntry> weights) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: _headerDeco,
      oddRowDecoration: _oddRowDeco,
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: [tr(LocaleKeys.export_csv_date), tr(LocaleKeys.export_csv_weight)],
      data: weights.map((w) => [_dateFmt.format(w.date), '${w.weight}']).toList(),
    );
  }

  // RESEARCH-ONLY: PDF AI Usage Summary table.
  static pw.Widget _buildAiUsageSummaryPdf(List<AiAttemptEntity> attempts) {
    final agg = _aggregateAiUsage(attempts);
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: _headerDeco,
        oddRowDecoration: _oddRowDeco,
        cellStyle: const pw.TextStyle(fontSize: 9),
        headers: ['Metric', 'Value'],
        data: [
          ['Total AI calls', '${agg.totalCalls}'],
          ['Total prompt tokens (input)', '${agg.totalPrompt}'],
          ['Of which cached (input)', '${agg.totalCached}'],
          ['Total completion tokens (output)', '${agg.totalCompletion}'],
          ['Total cost (USD)', '\$${agg.totalCost.toStringAsFixed(4)}'],
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Text('By model', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: _headerDeco,
        oddRowDecoration: _oddRowDeco,
        cellStyle: const pw.TextStyle(fontSize: 8),
        headers: ['Model', 'Calls', 'Prompt', 'Completion', 'Cached', 'Cost (USD)'],
        data: agg.byModel.entries.map((e) => [e.key, '${e.value.calls}', '${e.value.prompt}', '${e.value.completion}', '${e.value.cached}', '\$${e.value.cost.toStringAsFixed(4)}']).toList(),
      ),
      pw.SizedBox(height: 8),
      pw.Text('By kind', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: _headerDeco,
        oddRowDecoration: _oddRowDeco,
        cellStyle: const pw.TextStyle(fontSize: 8),
        headers: ['Kind', 'Calls', 'Cost (USD)'],
        data: agg.byKind.entries.map((e) => [e.key, '${e.value.calls}', '\$${e.value.cost.toStringAsFixed(4)}']).toList(),
      ),
    ]);
  }

  // RESEARCH-ONLY: aggregation helper shared by CSV and PDF export.
  static _AiUsageAgg _aggregateAiUsage(List<AiAttemptEntity> attempts) {
    int totalPrompt = 0, totalCompletion = 0, totalCached = 0;
    double totalCost = 0;
    final byModel = <String, _AiModelAgg>{};
    final byKind = <String, _AiKindAgg>{};
    for (final a in attempts) {
      totalPrompt += a.promptTokens ?? 0;
      totalCompletion += a.completionTokens ?? 0;
      totalCached += a.cachedTokens ?? 0;
      totalCost += a.costUsd ?? 0;
      final m = a.model ?? 'unknown';
      final pm = byModel[m] ?? _AiModelAgg();
      byModel[m] = _AiModelAgg(calls: pm.calls + 1, prompt: pm.prompt + (a.promptTokens ?? 0), completion: pm.completion + (a.completionTokens ?? 0), cached: pm.cached + (a.cachedTokens ?? 0), cost: pm.cost + (a.costUsd ?? 0));
      final pk = byKind[a.kind] ?? _AiKindAgg();
      byKind[a.kind] = _AiKindAgg(calls: pk.calls + 1, cost: pk.cost + (a.costUsd ?? 0));
    }
    return _AiUsageAgg(totalCalls: attempts.length, totalPrompt: totalPrompt, totalCompletion: totalCompletion, totalCached: totalCached, totalCost: totalCost, byModel: byModel, byKind: byKind);
  }
}

class _AiUsageAgg {
  final int totalCalls;
  final int totalPrompt;
  final int totalCompletion;
  final int totalCached;
  final double totalCost;
  final Map<String, _AiModelAgg> byModel;
  final Map<String, _AiKindAgg> byKind;
  const _AiUsageAgg({required this.totalCalls, required this.totalPrompt, required this.totalCompletion, required this.totalCached, required this.totalCost, required this.byModel, required this.byKind});
}

class _AiModelAgg {
  final int calls;
  final int prompt;
  final int completion;
  final int cached;
  final double cost;
  const _AiModelAgg({this.calls = 0, this.prompt = 0, this.completion = 0, this.cached = 0, this.cost = 0});
}

class _AiKindAgg {
  final int calls;
  final double cost;
  const _AiKindAgg({this.calls = 0, this.cost = 0});
}
