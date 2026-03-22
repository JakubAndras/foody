import 'dart:typed_data';

import 'package:csv/csv.dart';
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

  static String generateCsv(List<DayRecord> records, List<WeightEntry> weights) {
    final rows = <List<dynamic>>[];

    // ── Section 1: Daily Summary ──
    rows.add(['--- ${tr(LocaleKeys.export_daily_summary)} ---']);
    rows.add([
      tr(LocaleKeys.export_csv_date),
      tr(LocaleKeys.export_csv_calories),
      tr(LocaleKeys.export_csv_protein),
      tr(LocaleKeys.export_csv_carbs),
      tr(LocaleKeys.export_csv_fat),
      tr(LocaleKeys.export_csv_calorie_goal),
      tr(LocaleKeys.export_csv_exercise_calories),
      tr(LocaleKeys.export_csv_net_calories),
    ]);
    for (final r in records) {
      rows.add([
        _dateFmt.format(r.date),
        r.totalCalories.round(),
        r.totalProteins.round(),
        r.totalCarbs.round(),
        r.totalFats.round(),
        r.calorieGoal.round(),
        r.totalExerciseCalories.round(),
        r.netCalories.round(),
      ]);
    }

    // ── Calorie balance ──
    if (records.isNotEmpty) {
      final totalConsumed = records.fold<double>(0, (s, r) => s + r.totalCalories);
      final totalBurned = records.fold<double>(0, (s, r) => s + r.totalExerciseCalories);
      rows.add([]);
      rows.add([tr(LocaleKeys.export_consumed), '${totalConsumed.round()} ${tr(LocaleKeys.common_kcal)}']);
      rows.add([tr(LocaleKeys.export_burned), '${totalBurned.round()} ${tr(LocaleKeys.common_kcal)}']);
      rows.add([tr(LocaleKeys.export_balance), '${(totalConsumed - totalBurned).round()} ${tr(LocaleKeys.common_kcal)}']);
    }

    // ── Section 2: Meal Details ──
    final hasMeals = records.any((r) => r.meals.isNotEmpty);
    if (hasMeals) {
      rows.add([]);
      rows.add(['--- ${tr(LocaleKeys.export_meal_details)} ---']);
      rows.add([
        tr(LocaleKeys.export_csv_date),
        tr(LocaleKeys.common_meal),
        tr(LocaleKeys.common_ingredients),
        tr(LocaleKeys.common_weight),
        tr(LocaleKeys.export_csv_calories),
        tr(LocaleKeys.export_csv_protein),
        tr(LocaleKeys.export_csv_carbs),
        tr(LocaleKeys.export_csv_fat),
      ]);
      for (final r in records) {
        for (final meal in r.meals) {
          if (meal.ingredients.isEmpty) {
            rows.add([_dateFmt.format(r.date), meal.name, '', '', '', '', '', '']);
          }
          for (final ing in meal.ingredients) {
            rows.add([
              _dateFmt.format(r.date),
              meal.name,
              ing.name,
              ing.weight.round(),
              ing.calories.round(),
              ing.proteins.round(),
              ing.carbs.round(),
              ing.fats.round(),
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
      ]);
      for (final r in records) {
        for (final e in r.exercises) {
          rows.add([
            _dateTimeFmt.format(e.timestamp),
            e.name,
            e.durationMinutes != null ? '${e.durationMinutes} ${tr(LocaleKeys.common_min)}' : '',
            e.caloriesBurned.round(),
          ]);
        }
      }
    }

    // ── Section 4: Weight Progress ──
    if (weights.isNotEmpty) {
      rows.add([]);
      rows.add(['--- ${tr(LocaleKeys.progress_weight_progress)} ---']);
      rows.add([tr(LocaleKeys.export_csv_date), tr(LocaleKeys.export_csv_weight)]);
      for (final w in weights) {
        rows.add([_dateFmt.format(w.date), w.weight]);
      }
    }

    return const ListToCsvConverter().convert(rows);
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
  }) async {
    final regularData = await rootBundle.load('assets/fonts/Ubuntu-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Ubuntu-Bold.ttf');
    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    // Pre-compute averages & totals
    final avgCalories = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalCalories) / records.length;
    final avgProtein = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalProteins) / records.length;
    final avgCarbs = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalCarbs) / records.length;
    final avgFat = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalFats) / records.length;
    final totalConsumed = records.fold<double>(0, (s, r) => s + r.totalCalories);
    final totalBurned = records.fold<double>(0, (s, r) => s + r.totalExerciseCalories);
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
          _buildDailySummaryTable(records),
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
          ...records.expand((r) => _buildDayMealDetails(r)),

          // ── Exercise log ──
          if (records.any((r) => r.exercises.isNotEmpty)) ...[
            pw.Header(level: 1, text: tr(LocaleKeys.export_exercise_log)),
            _buildExerciseTable(records),
            pw.SizedBox(height: 16),
          ],

          // ── Weight progress ──
          if (weights.isNotEmpty) ...[
            pw.Header(level: 1, text: tr(LocaleKeys.progress_weight_progress)),
            _buildWeightTable(weights),
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
}
