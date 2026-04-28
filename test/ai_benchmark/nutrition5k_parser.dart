// Nutrition5k CSV parser and dish selector.
//
// Usage:
//   dart run test/ai_benchmark/nutrition5k_parser.dart
//
// Parses dish_metadata_cafe1.csv, selects ~50 dishes stratified by calorie
// range and ingredient count, writes selected_dishes.json.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class Nutrition5kIngredient {
  final String id;
  final String name;
  final double grams;
  final double calories;
  final double fat;
  final double carbs;
  final double protein;

  Nutrition5kIngredient({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grams': _round(grams),
        'calories': _round(calories),
        'fat': _round(fat),
        'carbs': _round(carbs),
        'protein': _round(protein),
      };
}

class Nutrition5kDish {
  final String dishId;
  final double totalCalories;
  final double totalMassGrams;
  final double totalFat;
  final double totalCarbs;
  final double totalProtein;
  final List<Nutrition5kIngredient> ingredients;

  Nutrition5kDish({
    required this.dishId,
    required this.totalCalories,
    required this.totalMassGrams,
    required this.totalFat,
    required this.totalCarbs,
    required this.totalProtein,
    required this.ingredients,
  });

  int get ingredientCount => ingredients.length;

  String get ingredientsSummary =>
      ingredients.map((i) => '${i.name} (${_round(i.grams)}g)').join(', ');

  String get calorieStratum {
    if (totalCalories < 100) return 'very_low';
    if (totalCalories < 250) return 'low';
    if (totalCalories < 400) return 'medium';
    if (totalCalories < 600) return 'high';
    return 'very_high';
  }

  String get complexityGroup {
    if (ingredientCount <= 3) return 'simple';
    if (ingredientCount <= 7) return 'medium';
    return 'complex';
  }

  Map<String, dynamic> toJson() => {
        'dish_id': dishId,
        'total_calories': _round(totalCalories),
        'total_mass_grams': _round(totalMassGrams),
        'total_fat': _round(totalFat),
        'total_carbs': _round(totalCarbs),
        'total_protein': _round(totalProtein),
        'ingredient_count': ingredientCount,
        'calorie_stratum': calorieStratum,
        'complexity': complexityGroup,
        'ingredients_summary': ingredientsSummary,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };
}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------

List<Nutrition5kDish> parseCafe1Csv(String csvContent) {
  final dishes = <Nutrition5kDish>[];

  for (final line in csvContent.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    final parts = trimmed.split(',');
    if (parts.length < 6) continue;

    final dishId = parts[0].trim();
    final totalCal = double.tryParse(parts[1].trim()) ?? 0;
    final totalMass = double.tryParse(parts[2].trim()) ?? 0;
    final totalFat = double.tryParse(parts[3].trim()) ?? 0;
    final totalCarb = double.tryParse(parts[4].trim()) ?? 0;
    final totalPro = double.tryParse(parts[5].trim()) ?? 0;

    // Skip invalid entries
    if (totalCal <= 0 || totalMass <= 0) continue;

    // Skip data quality outliers
    // - Max 1500 kcal (above that is likely a tray, not a single plate)
    // - Calorie density > 9 kcal/g is physically impossible (pure fat = 9 kcal/g)
    if (totalCal > 1500) continue;
    if (totalCal / totalMass > 9.0) continue;

    // Parse ingredient tuples (7 fields each) starting at index 6
    final ingredients = <Nutrition5kIngredient>[];
    var i = 6;
    while (i + 6 < parts.length) {
      final ingrId = parts[i].trim();
      final ingrName = parts[i + 1].trim();
      final ingrGrams = double.tryParse(parts[i + 2].trim()) ?? 0;
      final ingrCal = double.tryParse(parts[i + 3].trim()) ?? 0;
      final ingrFat = double.tryParse(parts[i + 4].trim()) ?? 0;
      final ingrCarb = double.tryParse(parts[i + 5].trim()) ?? 0;
      final ingrPro = double.tryParse(parts[i + 6].trim()) ?? 0;

      if (ingrName.isNotEmpty && ingrGrams > 0) {
        ingredients.add(Nutrition5kIngredient(
          id: ingrId,
          name: ingrName,
          grams: ingrGrams,
          calories: ingrCal,
          fat: ingrFat,
          carbs: ingrCarb,
          protein: ingrPro,
        ));
      }
      i += 7;
    }

    if (ingredients.isEmpty) continue;

    dishes.add(Nutrition5kDish(
      dishId: dishId,
      totalCalories: totalCal,
      totalMassGrams: totalMass,
      totalFat: totalFat,
      totalCarbs: totalCarb,
      totalProtein: totalPro,
      ingredients: ingredients,
    ));
  }

  return dishes;
}

// ---------------------------------------------------------------------------
// Dish selection
// ---------------------------------------------------------------------------

List<Nutrition5kDish> selectDishes(
  List<Nutrition5kDish> allDishes, {
  int targetTotal = 50,
  Set<String>? overheadDishIds,
}) {
  final random = Random(42); // fixed seed for reproducibility

  // Filter: only dishes with overhead images (if list provided)
  var eligible = allDishes;
  if (overheadDishIds != null) {
    eligible = allDishes.where((d) => overheadDishIds.contains(d.dishId)).toList();
    print('Filtered to ${eligible.length} dishes with overhead images.');
  }

  // Prefer dishes with >= 2 ingredients, but keep some 1-ingredient for variety
  final multiIngr = eligible.where((d) => d.ingredientCount >= 2).toList();
  final singleIngr = eligible.where((d) => d.ingredientCount == 1).toList();
  print('Multi-ingredient (>=2): ${multiIngr.length}, single: ${singleIngr.length}');

  // Stratify by calorie range
  final strata = <String, List<Nutrition5kDish>>{};
  for (final dish in multiIngr) {
    strata.putIfAbsent(dish.calorieStratum, () => []).add(dish);
  }
  // Also prepare single-ingredient pool per stratum (for fallback)
  final singleStrata = <String, List<Nutrition5kDish>>{};
  for (final dish in singleIngr) {
    singleStrata.putIfAbsent(dish.calorieStratum, () => []).add(dish);
  }

  // Target counts per stratum — allow max 2 single-ingredient per stratum
  final stratumTargets = <String, int>{
    'very_low': 8,
    'low': 12,
    'medium': 12,
    'high': 10,
    'very_high': 8,
  };
  const maxSinglePerStratum = 2;

  final selected = <Nutrition5kDish>[];

  for (final entry in stratumTargets.entries) {
    final stratum = entry.key;
    final target = entry.value;
    final candidates = strata[stratum] ?? [];
    final singleCandidates = singleStrata[stratum] ?? [];

    if (candidates.isEmpty && singleCandidates.isEmpty) {
      print('WARNING: No dishes in stratum "$stratum"');
      continue;
    }

    // Sort multi-ingredient by ingredient count for diversity
    candidates.sort((a, b) => a.ingredientCount.compareTo(b.ingredientCount));

    // Pick evenly spaced from multi-ingredient candidates
    final multiTarget = target - maxSinglePerStratum.clamp(0, target);
    final picked = <Nutrition5kDish>[];

    if (candidates.isNotEmpty) {
      final step = candidates.length / multiTarget;
      for (var i = 0; i < multiTarget && i < candidates.length; i++) {
        final idx = (i * step).floor().clamp(0, candidates.length - 1);
        final dish = candidates[idx];
        if (!picked.any((d) => d.dishId == dish.dishId)) {
          picked.add(dish);
        }
      }

      // Fill remaining from multi-ingredient if we missed due to dupes
      if (picked.length < multiTarget) {
        final remaining = candidates.where((d) => !picked.any((p) => p.dishId == d.dishId)).toList();
        remaining.shuffle(random);
        for (final dish in remaining) {
          if (picked.length >= multiTarget) break;
          picked.add(dish);
        }
      }
    }

    // Add a few single-ingredient dishes for diversity
    if (singleCandidates.isNotEmpty) {
      singleCandidates.shuffle(random);
      final singleCount = (target - picked.length).clamp(0, maxSinglePerStratum);
      picked.addAll(singleCandidates.take(singleCount));
    }

    // If still short, fill from any remaining candidates
    if (picked.length < target) {
      final allRemaining = [...candidates, ...singleCandidates]
          .where((d) => !picked.any((p) => p.dishId == d.dishId))
          .toList();
      allRemaining.shuffle(random);
      for (final dish in allRemaining) {
        if (picked.length >= target) break;
        picked.add(dish);
      }
    }

    selected.addAll(picked.take(target));
  }

  // Sort final selection by calorie range for readability
  selected.sort((a, b) => a.totalCalories.compareTo(b.totalCalories));
  return selected;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  final csvPath = 'test/ai_benchmark/nutrition5k/metadata/dish_metadata_cafe1.csv';
  final outputPath = 'test/ai_benchmark/nutrition5k/selected_dishes.json';

  final csvFile = File(csvPath);
  if (!csvFile.existsSync()) {
    stderr.writeln('ERROR: CSV not found at $csvPath');
    stderr.writeln('Download it first with:');
    stderr.writeln('  curl -o $csvPath "https://storage.googleapis.com/nutrition5k_dataset/nutrition5k_dataset/metadata/dish_metadata_cafe1.csv"');
    exit(1);
  }

  // Load overhead image IDs (pre-fetched list of dishes with overhead photos)
  final overheadIdsPath = 'test/ai_benchmark/nutrition5k/metadata/overhead_dish_ids.txt';
  Set<String>? overheadDishIds;
  final overheadIdsFile = File(overheadIdsPath);
  if (overheadIdsFile.existsSync()) {
    overheadDishIds = overheadIdsFile.readAsLinesSync().map((l) => l.trim()).where((l) => l.isNotEmpty).toSet();
    print('Loaded ${overheadDishIds.length} dish IDs with overhead images.');
  } else {
    print('WARNING: $overheadIdsPath not found — selecting without image filter.');
  }

  print('Parsing $csvPath ...');
  final csvContent = csvFile.readAsStringSync();
  final allDishes = parseCafe1Csv(csvContent);
  print('Parsed ${allDishes.length} valid dishes from Cafe 1.');

  // Print distribution
  print('\nCalorie distribution:');
  final strata = <String, int>{};
  for (final dish in allDishes) {
    strata.update(dish.calorieStratum, (v) => v + 1, ifAbsent: () => 1);
  }
  for (final entry in ['very_low', 'low', 'medium', 'high', 'very_high']) {
    print('  $entry: ${strata[entry] ?? 0} dishes');
  }

  print('\nComplexity distribution:');
  final complexities = <String, int>{};
  for (final dish in allDishes) {
    complexities.update(dish.complexityGroup, (v) => v + 1, ifAbsent: () => 1);
  }
  for (final entry in ['simple', 'medium', 'complex']) {
    print('  $entry: ${complexities[entry] ?? 0} dishes');
  }

  // Select dishes
  print('\nSelecting 50 dishes...');
  final selected = selectDishes(allDishes, overheadDishIds: overheadDishIds);
  print('Selected ${selected.length} dishes.');

  // Print selected summary
  print('\nSelected dishes:');
  for (var i = 0; i < selected.length; i++) {
    final d = selected[i];
    print('  ${i + 1}. ${d.dishId} | ${d.totalCalories.round()} kcal | ${d.totalMassGrams.round()}g | ${d.ingredientCount} ingr | ${d.calorieStratum}/${d.complexityGroup}');
  }

  // Write JSON
  final jsonOutput = const JsonEncoder.withIndent('  ').convert(selected.map((d) => d.toJson()).toList());
  File(outputPath).writeAsStringSync(jsonOutput);
  print('\nWritten to $outputPath');

  // Print dish IDs for image download
  final idsPath = 'test/ai_benchmark/nutrition5k/selected_dish_ids.txt';
  File(idsPath).writeAsStringSync(selected.map((d) => d.dishId).join('\n'));
  print('Dish IDs written to $idsPath');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

double _round(double v) => (v * 100).round() / 100;
