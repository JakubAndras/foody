import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _dateTimeFmt = DateFormat('yyyy-MM-dd HH:mm');

  // ─── CSV ──────────────────────────────────────────────────────────────

  static String generateCsv(List<DayRecord> records, List<WeightEntry> weights) {
    final rows = <List<dynamic>>[];

    // Daily nutrition header
    rows.add(['Date', 'Calories', 'Protein (g)', 'Carbs (g)', 'Fat (g)', 'Calorie Goal', 'Exercise Calories', 'Net Calories']);

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

    if (weights.isNotEmpty) {
      rows.add([]); // blank separator
      rows.add(['Date', 'Weight (kg)']);
      for (final w in weights) {
        rows.add([_dateFmt.format(w.date), w.weight]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  // ─── PDF ──────────────────────────────────────────────────────────────

  static Future<Uint8List> generatePdf(List<DayRecord> records, List<WeightEntry> weights, String dateRangeLabel) async {
    final doc = pw.Document();

    // Pre-compute averages
    final avgCalories = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalCalories) / records.length;
    final avgProtein = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalProteins) / records.length;
    final avgCarbs = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalCarbs) / records.length;
    final avgFat = records.isEmpty ? 0.0 : records.fold<double>(0, (s, r) => s + r.totalFats) / records.length;

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
          // ── Summary ──
          pw.Header(level: 1, text: 'Daily Summary'),
          _buildDailySummaryTable(records),
          pw.SizedBox(height: 8),
          pw.Text(
            'Period Averages — Calories: ${avgCalories.round()} kcal  |  Protein: ${avgProtein.round()}g  |  Carbs: ${avgCarbs.round()}g  |  Fat: ${avgFat.round()}g',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),

          // ── Meal details ──
          pw.Header(level: 1, text: 'Meal Details'),
          ...records.expand((r) => _buildDayMealDetails(r)),

          // ── Exercise log ──
          if (records.any((r) => r.exercises.isNotEmpty)) ...[
            pw.Header(level: 1, text: 'Exercise Log'),
            _buildExerciseTable(records),
            pw.SizedBox(height: 16),
          ],

          // ── Weight progress ──
          if (weights.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Weight Progress'),
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
        pw.Text('Foody — Nutrition Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(dateRangeLabel, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildDailySummaryTable(List<DayRecord> records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerRight,
      headerAlignment: pw.Alignment.centerRight,
      headers: ['Date', 'Calories', 'Protein', 'Carbs', 'Fat', 'Goal', 'Exercise', 'Net'],
      data: records
          .map((r) => [
                _dateFmt.format(r.date),
                '${r.totalCalories.round()}',
                '${r.totalProteins.round()}g',
                '${r.totalCarbs.round()}g',
                '${r.totalFats.round()}g',
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
                  headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  cellAlignment: pw.Alignment.centerRight,
                  headerAlignment: pw.Alignment.centerRight,
                  headers: ['Ingredient', 'Weight', 'Cal', 'Protein', 'Carbs', 'Fat'],
                  data: meal.ingredients
                      .map((i) => [
                            i.name,
                            '${i.weight.round()}g',
                            '${i.calories.round()}',
                            '${i.proteins.round()}g',
                            '${i.carbs.round()}g',
                            '${i.fats.round()}g',
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
          e.durationMinutes != null ? '${e.durationMinutes} min' : '-',
          '${e.caloriesBurned.round()} kcal',
        ]);
      }
    }
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: ['Date', 'Exercise', 'Duration', 'Burned'],
      data: exerciseRows,
    );
  }

  static pw.Widget _buildWeightTable(List<WeightEntry> weights) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: ['Date', 'Weight (kg)'],
      data: weights.map((w) => [_dateFmt.format(w.date), '${w.weight}']).toList(),
    );
  }
}
