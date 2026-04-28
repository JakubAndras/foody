// Benchmark metrics: error calculations, aggregation, and sub-group analysis.

// ---------------------------------------------------------------------------
// Per-dish result
// ---------------------------------------------------------------------------

class BenchmarkResult {
  final String dishId;
  final int runNumber;

  // Ground truth (from Nutrition5k)
  final double refCalories;
  final double refMassGrams;
  final double refFat;
  final double refCarbs;
  final double refProtein;
  final int refIngredientCount;
  final String refCalorieStratum;
  final String refComplexity;

  // AI output
  final bool aiValid;
  final String aiMealName;
  final double aiConfidence;
  final double aiCalories;
  final double aiProtein;
  final double aiFat;
  final double aiCarbs;
  final double aiWeightGrams;
  final int aiIngredientCount;

  // Timing
  final int responseTimeMs;

  // Error flag
  final bool isApiError;
  final String? errorMessage;

  BenchmarkResult({
    required this.dishId,
    required this.runNumber,
    required this.refCalories,
    required this.refMassGrams,
    required this.refFat,
    required this.refCarbs,
    required this.refProtein,
    required this.refIngredientCount,
    required this.refCalorieStratum,
    required this.refComplexity,
    required this.aiValid,
    required this.aiMealName,
    required this.aiConfidence,
    required this.aiCalories,
    required this.aiProtein,
    required this.aiFat,
    required this.aiCarbs,
    required this.aiWeightGrams,
    required this.aiIngredientCount,
    this.responseTimeMs = 0,
    this.isApiError = false,
    this.errorMessage,
  });

  factory BenchmarkResult.failed({
    required String dishId,
    required int runNumber,
    required double refCalories,
    required double refMassGrams,
    required double refFat,
    required double refCarbs,
    required double refProtein,
    required int refIngredientCount,
    required String refCalorieStratum,
    required String refComplexity,
    required String error,
  }) {
    return BenchmarkResult(
      dishId: dishId,
      runNumber: runNumber,
      refCalories: refCalories,
      refMassGrams: refMassGrams,
      refFat: refFat,
      refCarbs: refCarbs,
      refProtein: refProtein,
      refIngredientCount: refIngredientCount,
      refCalorieStratum: refCalorieStratum,
      refComplexity: refComplexity,
      aiValid: false,
      aiMealName: '',
      aiConfidence: 0,
      aiCalories: 0,
      aiProtein: 0,
      aiFat: 0,
      aiCarbs: 0,
      aiWeightGrams: 0,
      aiIngredientCount: 0,
      isApiError: true,
      errorMessage: error,
    );
  }

  // Errors (signed: positive = AI overestimated)
  double get calorieError => aiCalories - refCalories;
  double get proteinError => aiProtein - refProtein;
  double get fatError => aiFat - refFat;
  double get carbsError => aiCarbs - refCarbs;
  double get weightError => aiWeightGrams - refMassGrams;

  // Percentage errors
  double get calorieErrorPercent => _percentError(aiCalories, refCalories);
  double get proteinErrorPercent => _percentError(aiProtein, refProtein);
  double get fatErrorPercent => _percentError(aiFat, refFat);
  double get carbsErrorPercent => _percentError(aiCarbs, refCarbs);
  double get weightErrorPercent => _percentError(aiWeightGrams, refMassGrams);

  // Absolute percentage errors
  double get calorieAbsPercentError => calorieErrorPercent.abs();
  double get proteinAbsPercentError => proteinErrorPercent.abs();
  double get fatAbsPercentError => fatErrorPercent.abs();
  double get carbsAbsPercentError => carbsErrorPercent.abs();
  double get weightAbsPercentError => weightErrorPercent.abs();

  bool get isUsable => !isApiError && aiValid;
}

// ---------------------------------------------------------------------------
// Median result (aggregated across multiple runs for one dish)
// ---------------------------------------------------------------------------

class MedianDishResult {
  final String dishId;
  final String calorieStratum;
  final String complexity;
  final int refIngredientCount;
  final double refCalories;
  final double refMassGrams;
  final double refFat;
  final double refCarbs;
  final double refProtein;

  final double medianAiCalories;
  final double medianAiProtein;
  final double medianAiFat;
  final double medianAiCarbs;
  final double medianAiWeight;
  final double medianConfidence;
  final String bestMealName; // from the median-calorie run
  final int medianAiIngredientCount;

  final double calorieAbsPercentError;
  final double proteinAbsPercentError;
  final double fatAbsPercentError;
  final double carbsAbsPercentError;
  final double weightAbsPercentError;

  final double calorieSignedPercentError;
  final double proteinSignedPercentError;
  final double fatSignedPercentError;
  final double carbsSignedPercentError;
  final double weightSignedPercentError;

  final int validRuns;
  final int totalRuns;

  MedianDishResult({
    required this.dishId,
    required this.calorieStratum,
    required this.complexity,
    required this.refIngredientCount,
    required this.refCalories,
    required this.refMassGrams,
    required this.refFat,
    required this.refCarbs,
    required this.refProtein,
    required this.medianAiCalories,
    required this.medianAiProtein,
    required this.medianAiFat,
    required this.medianAiCarbs,
    required this.medianAiWeight,
    required this.medianConfidence,
    required this.bestMealName,
    required this.medianAiIngredientCount,
    required this.calorieAbsPercentError,
    required this.proteinAbsPercentError,
    required this.fatAbsPercentError,
    required this.carbsAbsPercentError,
    required this.weightAbsPercentError,
    required this.calorieSignedPercentError,
    required this.proteinSignedPercentError,
    required this.fatSignedPercentError,
    required this.carbsSignedPercentError,
    required this.weightSignedPercentError,
    required this.validRuns,
    required this.totalRuns,
  });
}

// ---------------------------------------------------------------------------
// Aggregate metrics
// ---------------------------------------------------------------------------

class AggregateMetrics {
  final int totalDishes;
  final int validDishes;
  final double validRate;

  final double calorieMape;
  final double proteinMape;
  final double fatMape;
  final double carbsMape;
  final double weightMape;

  final double calorieMae;
  final double proteinMae;
  final double fatMae;
  final double carbsMae;
  final double weightMae;

  final double caloriesWithin10;
  final double caloriesWithin20;
  final double caloriesWithin30;

  final double meanConfidence;
  final double avgAiIngredients;
  final double avgRefIngredients;
  final double avgResponseTimeMs;
  final double medianResponseTimeMs;
  final double minResponseTimeMs;
  final double maxResponseTimeMs;

  AggregateMetrics({
    required this.totalDishes,
    required this.validDishes,
    required this.validRate,
    required this.calorieMape,
    required this.proteinMape,
    required this.fatMape,
    required this.carbsMape,
    required this.weightMape,
    required this.calorieMae,
    required this.proteinMae,
    required this.fatMae,
    required this.carbsMae,
    required this.weightMae,
    required this.caloriesWithin10,
    required this.caloriesWithin20,
    required this.caloriesWithin30,
    required this.meanConfidence,
    required this.avgAiIngredients,
    required this.avgRefIngredients,
    required this.avgResponseTimeMs,
    required this.medianResponseTimeMs,
    required this.minResponseTimeMs,
    required this.maxResponseTimeMs,
  });
}

class SubgroupMetrics {
  final String groupType; // "complexity" or "calorie_range"
  final String groupName;
  final int count;
  final double calorieMape;
  final double proteinMape;
  final double fatMape;
  final double carbsMape;
  final double caloriesWithin20;

  SubgroupMetrics({
    required this.groupType,
    required this.groupName,
    required this.count,
    required this.calorieMape,
    required this.proteinMape,
    required this.fatMape,
    required this.carbsMape,
    required this.caloriesWithin20,
  });
}

// ---------------------------------------------------------------------------
// Computation
// ---------------------------------------------------------------------------

/// Compute median dish results from multiple runs
List<MedianDishResult> computeMedianResults(List<BenchmarkResult> allResults) {
  // Group by dish_id
  final grouped = <String, List<BenchmarkResult>>{};
  for (final r in allResults) {
    grouped.putIfAbsent(r.dishId, () => []).add(r);
  }

  final medians = <MedianDishResult>[];
  for (final entry in grouped.entries) {
    final dishId = entry.key;
    final runs = entry.value;
    final usable = runs.where((r) => r.isUsable).toList();

    if (usable.isEmpty) {
      // All runs failed — include with zero values for tracking
      final ref = runs.first;
      medians.add(MedianDishResult(
        dishId: dishId,
        calorieStratum: ref.refCalorieStratum,
        complexity: ref.refComplexity,
        refIngredientCount: ref.refIngredientCount,
        refCalories: ref.refCalories,
        refMassGrams: ref.refMassGrams,
        refFat: ref.refFat,
        refCarbs: ref.refCarbs,
        refProtein: ref.refProtein,
        medianAiCalories: 0,
        medianAiProtein: 0,
        medianAiFat: 0,
        medianAiCarbs: 0,
        medianAiWeight: 0,
        medianConfidence: 0,
        bestMealName: runs.first.aiMealName,
        medianAiIngredientCount: 0,
        calorieAbsPercentError: 100,
        proteinAbsPercentError: 100,
        fatAbsPercentError: 100,
        carbsAbsPercentError: 100,
        weightAbsPercentError: 100,
        calorieSignedPercentError: -100,
        proteinSignedPercentError: -100,
        fatSignedPercentError: -100,
        carbsSignedPercentError: -100,
        weightSignedPercentError: -100,
        validRuns: 0,
        totalRuns: runs.length,
      ));
      continue;
    }

    // Sort by calories to find median run
    usable.sort((a, b) => a.aiCalories.compareTo(b.aiCalories));
    final medianRun = usable[usable.length ~/ 2];

    medians.add(MedianDishResult(
      dishId: dishId,
      calorieStratum: medianRun.refCalorieStratum,
      complexity: medianRun.refComplexity,
      refIngredientCount: medianRun.refIngredientCount,
      refCalories: medianRun.refCalories,
      refMassGrams: medianRun.refMassGrams,
      refFat: medianRun.refFat,
      refCarbs: medianRun.refCarbs,
      refProtein: medianRun.refProtein,
      medianAiCalories: medianRun.aiCalories,
      medianAiProtein: medianRun.aiProtein,
      medianAiFat: medianRun.aiFat,
      medianAiCarbs: medianRun.aiCarbs,
      medianAiWeight: medianRun.aiWeightGrams,
      medianConfidence: medianRun.aiConfidence,
      bestMealName: medianRun.aiMealName,
      medianAiIngredientCount: medianRun.aiIngredientCount,
      calorieAbsPercentError: medianRun.calorieAbsPercentError,
      proteinAbsPercentError: medianRun.proteinAbsPercentError,
      fatAbsPercentError: medianRun.fatAbsPercentError,
      carbsAbsPercentError: medianRun.carbsAbsPercentError,
      weightAbsPercentError: medianRun.weightAbsPercentError,
      calorieSignedPercentError: medianRun.calorieErrorPercent,
      proteinSignedPercentError: medianRun.proteinErrorPercent,
      fatSignedPercentError: medianRun.fatErrorPercent,
      carbsSignedPercentError: medianRun.carbsErrorPercent,
      weightSignedPercentError: medianRun.weightErrorPercent,
      validRuns: usable.length,
      totalRuns: runs.length,
    ));
  }

  return medians;
}

/// Compute aggregate metrics from median results
AggregateMetrics computeAggregate(List<MedianDishResult> medians, {List<BenchmarkResult>? rawResults}) {
  final valid = medians.where((m) => m.validRuns > 0).toList();

  // Filter out dishes where reference value is too small for meaningful percentage error
  final calValid = valid.where((m) => m.refCalories >= 10).toList();
  final proValid = valid.where((m) => m.refCalories >= 10).toList(); // use calorie threshold as proxy
  final fatValid = valid.where((m) => m.refFat >= 1).toList();
  final carbValid = valid.where((m) => m.refCalories >= 10).toList();
  final weightValid = valid.where((m) => m.refMassGrams >= 10).toList();

  return AggregateMetrics(
    totalDishes: medians.length,
    validDishes: valid.length,
    validRate: valid.length / medians.length * 100,
    calorieMape: _mape(calValid.map((m) => m.calorieAbsPercentError)),
    proteinMape: _mape(proValid.map((m) => m.proteinAbsPercentError)),
    fatMape: _mape(fatValid.map((m) => m.fatAbsPercentError)),
    carbsMape: _mape(carbValid.map((m) => m.carbsAbsPercentError)),
    weightMape: _mape(weightValid.map((m) => m.weightAbsPercentError)),
    calorieMae: _mae(calValid.map((m) => (m.medianAiCalories - m.refCalories).abs())),
    proteinMae: _mae(proValid.map((m) => (m.medianAiProtein - m.refProtein).abs())),
    fatMae: _mae(fatValid.map((m) => (m.medianAiFat - m.refFat).abs())),
    carbsMae: _mae(carbValid.map((m) => (m.medianAiCarbs - m.refCarbs).abs())),
    weightMae: _mae(weightValid.map((m) => (m.medianAiWeight - m.refMassGrams).abs())),
    caloriesWithin10: _withinBand(calValid.map((m) => m.calorieAbsPercentError), 10),
    caloriesWithin20: _withinBand(calValid.map((m) => m.calorieAbsPercentError), 20),
    caloriesWithin30: _withinBand(calValid.map((m) => m.calorieAbsPercentError), 30),
    meanConfidence: valid.isEmpty ? 0 : valid.map((m) => m.medianConfidence).reduce((a, b) => a + b) / valid.length,
    avgAiIngredients: valid.isEmpty ? 0 : valid.map((m) => m.medianAiIngredientCount.toDouble()).reduce((a, b) => a + b) / valid.length,
    avgRefIngredients: valid.isEmpty ? 0 : valid.map((m) => m.refIngredientCount.toDouble()).reduce((a, b) => a + b) / valid.length,
    avgResponseTimeMs: _computeAvgResponseTime(rawResults),
    medianResponseTimeMs: _computeMedianResponseTime(rawResults),
    minResponseTimeMs: _computeMinResponseTime(rawResults),
    maxResponseTimeMs: _computeMaxResponseTime(rawResults),
  );
}

double _computeAvgResponseTime(List<BenchmarkResult>? results) {
  if (results == null || results.isEmpty) return 0;
  final times = results.where((r) => !r.isApiError && r.responseTimeMs > 0).map((r) => r.responseTimeMs.toDouble()).toList();
  if (times.isEmpty) return 0;
  return times.reduce((a, b) => a + b) / times.length;
}

double _computeMedianResponseTime(List<BenchmarkResult>? results) {
  if (results == null || results.isEmpty) return 0;
  final times = results.where((r) => !r.isApiError && r.responseTimeMs > 0).map((r) => r.responseTimeMs.toDouble()).toList();
  if (times.isEmpty) return 0;
  return median(times);
}

double _computeMinResponseTime(List<BenchmarkResult>? results) {
  if (results == null || results.isEmpty) return 0;
  final times = results.where((r) => !r.isApiError && r.responseTimeMs > 0).map((r) => r.responseTimeMs.toDouble()).toList();
  if (times.isEmpty) return 0;
  return times.reduce((a, b) => a < b ? a : b);
}

double _computeMaxResponseTime(List<BenchmarkResult>? results) {
  if (results == null || results.isEmpty) return 0;
  final times = results.where((r) => !r.isApiError && r.responseTimeMs > 0).map((r) => r.responseTimeMs.toDouble()).toList();
  if (times.isEmpty) return 0;
  return times.reduce((a, b) => a > b ? a : b);
}

/// Compute sub-group metrics
List<SubgroupMetrics> computeSubgroups(List<MedianDishResult> medians) {
  final valid = medians.where((m) => m.validRuns > 0 && m.refCalories >= 10).toList();
  final subgroups = <SubgroupMetrics>[];

  // By complexity
  for (final complexity in ['simple', 'medium', 'complex']) {
    final group = valid.where((m) => m.complexity == complexity).toList();
    if (group.isEmpty) continue;
    subgroups.add(SubgroupMetrics(
      groupType: 'complexity',
      groupName: complexity,
      count: group.length,
      calorieMape: _mape(group.map((m) => m.calorieAbsPercentError)),
      proteinMape: _mape(group.map((m) => m.proteinAbsPercentError)),
      fatMape: _mape(group.map((m) => m.fatAbsPercentError)),
      carbsMape: _mape(group.map((m) => m.carbsAbsPercentError)),
      caloriesWithin20: _withinBand(group.map((m) => m.calorieAbsPercentError), 20),
    ));
  }

  // By calorie range
  for (final stratum in ['very_low', 'low', 'medium', 'high', 'very_high']) {
    final group = valid.where((m) => m.calorieStratum == stratum).toList();
    if (group.isEmpty) continue;
    subgroups.add(SubgroupMetrics(
      groupType: 'calorie_range',
      groupName: stratum,
      count: group.length,
      calorieMape: _mape(group.map((m) => m.calorieAbsPercentError)),
      proteinMape: _mape(group.map((m) => m.proteinAbsPercentError)),
      fatMape: _mape(group.map((m) => m.fatAbsPercentError)),
      carbsMape: _mape(group.map((m) => m.carbsAbsPercentError)),
      caloriesWithin20: _withinBand(group.map((m) => m.calorieAbsPercentError), 20),
    ));
  }

  return subgroups;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

double _percentError(double aiValue, double refValue) {
  if (refValue == 0) return aiValue == 0 ? 0 : 100.0; // cap at 100% for zero ref
  return ((aiValue - refValue) / refValue) * 100;
}

double _mape(Iterable<double> absPercentErrors) {
  final list = absPercentErrors.toList();
  if (list.isEmpty) return 0;
  return list.reduce((a, b) => a + b) / list.length;
}

double _mae(Iterable<double> absErrors) {
  final list = absErrors.toList();
  if (list.isEmpty) return 0;
  return list.reduce((a, b) => a + b) / list.length;
}

double _withinBand(Iterable<double> absPercentErrors, double band) {
  final list = absPercentErrors.toList();
  if (list.isEmpty) return 0;
  return list.where((e) => e <= band).length / list.length * 100;
}

double median(List<double> values) {
  if (values.isEmpty) return 0;
  final sorted = List<double>.from(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}
