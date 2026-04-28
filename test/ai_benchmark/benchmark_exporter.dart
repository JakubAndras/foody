// Benchmark results exporter: CSV, summary text, raw JSON.

import 'dart:convert';
import 'dart:io';

import 'benchmark_metrics.dart';

// ---------------------------------------------------------------------------
// Export all results to a timestamped directory
// ---------------------------------------------------------------------------

String exportResults({
  required List<BenchmarkResult> rawResults,
  required List<MedianDishResult> medianResults,
  required AggregateMetrics aggregate,
  required List<SubgroupMetrics> subgroups,
  required String model,
  required int runsPerDish,
  String promptVariant = 'baseline',
}) {
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
  final dir = 'test/ai_benchmark/results/${model}_${promptVariant}_$timestamp';
  Directory(dir).createSync(recursive: true);

  _writePerDishCsv('$dir/per_dish_results.csv', medianResults);
  _writeRawResultsCsv('$dir/all_runs.csv', rawResults);
  _writeAggregateCsv('$dir/aggregate_results.csv', aggregate);
  _writeSubgroupCsv('$dir/accuracy_by_subgroup.csv', subgroups);
  _writeSummary('$dir/summary.txt', aggregate, subgroups, medianResults, model, runsPerDish, promptVariant);
  _writeRawJson('$dir/raw_responses.json', rawResults);

  // Also write a "latest" symlink-like copy
  final latestDir = 'test/ai_benchmark/results/latest';
  if (Directory(latestDir).existsSync()) {
    Directory(latestDir).deleteSync(recursive: true);
  }
  _copyDirectory(dir, latestDir);

  return dir;
}

// ---------------------------------------------------------------------------
// Per-dish CSV (median aggregated)
// ---------------------------------------------------------------------------

void _writePerDishCsv(String path, List<MedianDishResult> results) {
  final buf = StringBuffer();
  buf.writeln('dish_id,stratum,complexity,ref_ingredients,'
      'ref_cal,ref_mass_g,ref_fat,ref_carbs,ref_protein,'
      'ai_name,ai_confidence,'
      'ai_cal,ai_fat,ai_carbs,ai_protein,ai_weight_g,ai_ingredients,'
      'cal_err_%,fat_err_%,carb_err_%,pro_err_%,weight_err_%,'
      'cal_abs_err,valid_runs,total_runs');

  for (final r in results) {
    buf.writeln('${r.dishId},${r.calorieStratum},${r.complexity},${r.refIngredientCount},'
        '${_f(r.refCalories)},${_f(r.refMassGrams)},${_f(r.refFat)},${_f(r.refCarbs)},${_f(r.refProtein)},'
        '"${_escapeCsv(r.bestMealName)}",${_f(r.medianConfidence)},'
        '${_f(r.medianAiCalories)},${_f(r.medianAiFat)},${_f(r.medianAiCarbs)},${_f(r.medianAiProtein)},${_f(r.medianAiWeight)},${r.medianAiIngredientCount},'
        '${_f(r.calorieSignedPercentError)},${_f(r.fatSignedPercentError)},${_f(r.carbsSignedPercentError)},${_f(r.proteinSignedPercentError)},${_f(r.weightSignedPercentError)},'
        '${_f((r.medianAiCalories - r.refCalories).abs())},${r.validRuns},${r.totalRuns}');
  }

  File(path).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// All runs CSV (raw, one row per run)
// ---------------------------------------------------------------------------

void _writeRawResultsCsv(String path, List<BenchmarkResult> results) {
  final buf = StringBuffer();
  buf.writeln('dish_id,run,ref_cal,ref_mass_g,ref_fat,ref_carbs,ref_protein,ref_ingredients,'
      'ai_valid,ai_name,ai_confidence,ai_cal,ai_fat,ai_carbs,ai_protein,ai_weight_g,ai_ingredients,'
      'cal_err_%,fat_err_%,carb_err_%,pro_err_%,weight_err_%,is_api_error,error_message');

  for (final r in results) {
    buf.writeln('${r.dishId},${r.runNumber},'
        '${_f(r.refCalories)},${_f(r.refMassGrams)},${_f(r.refFat)},${_f(r.refCarbs)},${_f(r.refProtein)},${r.refIngredientCount},'
        '${r.aiValid},"${_escapeCsv(r.aiMealName)}",${_f(r.aiConfidence)},'
        '${_f(r.aiCalories)},${_f(r.aiFat)},${_f(r.aiCarbs)},${_f(r.aiProtein)},${_f(r.aiWeightGrams)},${r.aiIngredientCount},'
        '${_f(r.calorieErrorPercent)},${_f(r.fatErrorPercent)},${_f(r.carbsErrorPercent)},${_f(r.proteinErrorPercent)},${_f(r.weightErrorPercent)},'
        '${r.isApiError},"${_escapeCsv(r.errorMessage ?? '')}"');
  }

  File(path).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// Aggregate CSV
// ---------------------------------------------------------------------------

void _writeAggregateCsv(String path, AggregateMetrics a) {
  final buf = StringBuffer();
  buf.writeln('metric,calories,protein,fat,carbs,weight');
  buf.writeln('mape_%,${_f(a.calorieMape)},${_f(a.proteinMape)},${_f(a.fatMape)},${_f(a.carbsMape)},${_f(a.weightMape)}');
  buf.writeln('mae,${_f(a.calorieMae)},${_f(a.proteinMae)},${_f(a.fatMae)},${_f(a.carbsMae)},${_f(a.weightMae)}');
  buf.writeln('within_10_%,${_f(a.caloriesWithin10)},,,,');
  buf.writeln('within_20_%,${_f(a.caloriesWithin20)},,,,');
  buf.writeln('within_30_%,${_f(a.caloriesWithin30)},,,,');
  buf.writeln('mean_confidence,${_f(a.meanConfidence)},,,,');
  buf.writeln('valid_rate_%,${_f(a.validRate)},,,,');
  buf.writeln('n_dishes,${a.totalDishes},,,,');
  buf.writeln('n_valid,${a.validDishes},,,,');

  File(path).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// Subgroup CSV
// ---------------------------------------------------------------------------

void _writeSubgroupCsv(String path, List<SubgroupMetrics> subgroups) {
  final buf = StringBuffer();
  buf.writeln('group_type,group_name,n_dishes,cal_mape_%,pro_mape_%,fat_mape_%,carb_mape_%,cal_within_20_%');

  for (final s in subgroups) {
    buf.writeln('${s.groupType},${s.groupName},${s.count},'
        '${_f(s.calorieMape)},${_f(s.proteinMape)},${_f(s.fatMape)},${_f(s.carbsMape)},${_f(s.caloriesWithin20)}');
  }

  File(path).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// Human-readable summary
// ---------------------------------------------------------------------------

void _writeSummary(
  String path,
  AggregateMetrics a,
  List<SubgroupMetrics> subgroups,
  List<MedianDishResult> medians,
  String model,
  int runsPerDish,
  String promptVariant,
) {
  final buf = StringBuffer();

  buf.writeln('==============================================');
  buf.writeln(' AI Accuracy Benchmark - Nutrition5k Dataset');
  buf.writeln('==============================================');
  buf.writeln('Date:       ${DateTime.now().toIso8601String().substring(0, 10)}');
  buf.writeln('Model:      $model');
  buf.writeln('Prompt:     $promptVariant');
  buf.writeln('Dishes:     ${a.totalDishes} (from Nutrition5k Cafe 1)');
  buf.writeln('Runs/dish:  $runsPerDish (median aggregation)');
  buf.writeln('API calls:  ${a.totalDishes * runsPerDish}');
  buf.writeln('');

  buf.writeln('CALORIE ACCURACY');
  buf.writeln('  MAPE:          ${_f(a.calorieMape)}%');
  buf.writeln('  MAE:           ${_f(a.calorieMae)} kcal');
  buf.writeln('  Within +-10%:  ${_f(a.caloriesWithin10)}% of dishes');
  buf.writeln('  Within +-20%:  ${_f(a.caloriesWithin20)}% of dishes');
  buf.writeln('  Within +-30%:  ${_f(a.caloriesWithin30)}% of dishes');
  buf.writeln('');

  buf.writeln('MACRONUTRIENT ACCURACY (MAPE)');
  buf.writeln('  Protein:       ${_f(a.proteinMape)}%');
  buf.writeln('  Fat:           ${_f(a.fatMape)}%');
  buf.writeln('  Carbohydrates: ${_f(a.carbsMape)}%');
  buf.writeln('');

  buf.writeln('WEIGHT ESTIMATION');
  buf.writeln('  MAPE:          ${_f(a.weightMape)}%');
  buf.writeln('  MAE:           ${_f(a.weightMae)} g');
  buf.writeln('');

  buf.writeln('API RESPONSE TIME');
  buf.writeln('  Average:           ${(a.avgResponseTimeMs / 1000).toStringAsFixed(2)} s');
  buf.writeln('  Median:            ${(a.medianResponseTimeMs / 1000).toStringAsFixed(2)} s');
  buf.writeln('  Min:               ${(a.minResponseTimeMs / 1000).toStringAsFixed(2)} s');
  buf.writeln('  Max:               ${(a.maxResponseTimeMs / 1000).toStringAsFixed(2)} s');
  buf.writeln('');

  buf.writeln('AI BEHAVIOR');
  buf.writeln('  Valid responses:    ${a.validDishes}/${a.totalDishes} (${_f(a.validRate)}%)');
  buf.writeln('  Mean confidence:    ${_f(a.meanConfidence)}');
  buf.writeln('  Avg AI ingredients: ${_f(a.avgAiIngredients)}');
  buf.writeln('  Avg N5k ingredients:${_f(a.avgRefIngredients)}');
  buf.writeln('');

  buf.writeln('COMPARISON WITH NUTRITION5K PAPER (Table 3, CVPR 2021)');
  buf.writeln('  Paper 2D direct prediction:  26.1% calorie MAPE');
  buf.writeln('  This benchmark (Foody app):  ${_f(a.calorieMape)}% calorie MAPE');
  buf.writeln('');

  // Subgroup: complexity
  final complexityGroups = subgroups.where((s) => s.groupType == 'complexity').toList();
  if (complexityGroups.isNotEmpty) {
    buf.writeln('CALORIE ACCURACY BY DISH COMPLEXITY');
    for (final s in complexityGroups) {
      final label = '${s.groupName} (N=${s.count})'.padRight(30);
      buf.writeln('  $label${_f(s.calorieMape)}% MAPE, ${_f(s.caloriesWithin20)}% within +-20%');
    }
    buf.writeln('');
  }

  // Subgroup: calorie range
  final calorieGroups = subgroups.where((s) => s.groupType == 'calorie_range').toList();
  if (calorieGroups.isNotEmpty) {
    buf.writeln('CALORIE ACCURACY BY CALORIE RANGE');
    for (final s in calorieGroups) {
      final label = '${s.groupName} (N=${s.count})'.padRight(30);
      buf.writeln('  $label${_f(s.calorieMape)}% MAPE, ${_f(s.caloriesWithin20)}% within +-20%');
    }
    buf.writeln('');
  }

  // Top 5 best and worst dishes
  final sorted = List<MedianDishResult>.from(medians.where((m) => m.validRuns > 0))
    ..sort((a, b) => a.calorieAbsPercentError.compareTo(b.calorieAbsPercentError));

  if (sorted.length >= 5) {
    buf.writeln('TOP 5 MOST ACCURATE DISHES');
    for (var i = 0; i < 5; i++) {
      final d = sorted[i];
      buf.writeln('  ${d.dishId}: ${_f(d.calorieAbsPercentError)}% error '
          '(AI: ${_f(d.medianAiCalories)} kcal, ref: ${_f(d.refCalories)} kcal) '
          '"${d.bestMealName}"');
    }
    buf.writeln('');

    buf.writeln('TOP 5 LEAST ACCURATE DISHES');
    for (var i = sorted.length - 1; i >= sorted.length - 5 && i >= 0; i--) {
      final d = sorted[i];
      buf.writeln('  ${d.dishId}: ${_f(d.calorieAbsPercentError)}% error '
          '(AI: ${_f(d.medianAiCalories)} kcal, ref: ${_f(d.refCalories)} kcal) '
          '"${d.bestMealName}"');
    }
    buf.writeln('');
  }

  File(path).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// Raw JSON dump
// ---------------------------------------------------------------------------

void _writeRawJson(String path, List<BenchmarkResult> results) {
  final data = results.map((r) => {
        'dish_id': r.dishId,
        'run': r.runNumber,
        'ai_valid': r.aiValid,
        'ai_meal_name': r.aiMealName,
        'ai_confidence': r.aiConfidence,
        'ai_calories': r.aiCalories,
        'ai_protein': r.aiProtein,
        'ai_fat': r.aiFat,
        'ai_carbs': r.aiCarbs,
        'ai_weight_grams': r.aiWeightGrams,
        'ai_ingredient_count': r.aiIngredientCount,
        'ref_calories': r.refCalories,
        'ref_mass_grams': r.refMassGrams,
        'ref_fat': r.refFat,
        'ref_carbs': r.refCarbs,
        'ref_protein': r.refProtein,
        'calorie_error_%': r.calorieErrorPercent,
        'response_time_ms': r.responseTimeMs,
        'is_api_error': r.isApiError,
        'error_message': r.errorMessage,
      }).toList();

  File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _f(double v) => v.toStringAsFixed(2);

String _escapeCsv(String s) => s.replaceAll('"', '""');

void _copyDirectory(String source, String destination) {
  Directory(destination).createSync(recursive: true);
  for (final entity in Directory(source).listSync()) {
    final newPath = '$destination/${entity.uri.pathSegments.last}';
    if (entity is File) {
      entity.copySync(newPath);
    }
  }
}
