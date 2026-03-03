# FR-34: AI Accuracy Evaluation — Implementation Plan

> **Goal:** Track how accurate AI nutritional estimates are by comparing original AI values against user-corrected values, surface accuracy metrics in the UI, and feed correction data back into prompts to improve future recognition.

---

## Overview

When the AI analyzes a meal photo/description, it produces estimated nutritional values. Users often edit these values before saving. FR-34 captures the delta between "what AI said" and "what the user saved" to measure AI accuracy over time — and then closes the loop by using that correction history to make future AI estimates more accurate.

**Four pillars:**
1. **Capture** — persist original AI values alongside user-edited values
2. **Compute** — calculate accuracy metrics (% deviation per macro, acceptance rate)
3. **Display** — show accuracy stats on the Progress screen + optional thumbs up/down feedback on EditMealScreen
4. **Improve** — feed correction patterns back into AI prompts to reduce future errors

---

## Phase 1: Persist Original AI Values

### 1.1 Add AI snapshot columns to `IngredientEntity`

**File:** `lib/database/entities/ingredient_entity.dart`

Add nullable columns that store the original AI-suggested values:

```dart
final double? aiCalories;    // Original AI-estimated calories
final double? aiProteins;    // Original AI-estimated proteins
final double? aiCarbs;       // Original AI-estimated carbs
final double? aiFats;        // Original AI-estimated fats
final double? aiWeight;      // Original AI-estimated weight
```

**Why on Ingredient, not Meal?** Meal totals are computed from ingredients (`meal.totalCalories` is a fold over ingredients). Tracking at ingredient level gives per-item granularity and meal-level accuracy is derived from it.

### 1.2 Add `wasEditedByUser` flag to `MealEntity`

**File:** `lib/database/entities/meal_entity.dart`

```dart
final bool wasEditedByUser;  // true if user modified any AI values before saving
```

This allows quick filtering: "how many meals did the user accept as-is vs edit?"

### 1.3 Database migration (v8 → v9)

**File:** `lib/database/migrations.dart`

```sql
ALTER TABLE `Ingredient` ADD COLUMN `aiCalories` REAL;
ALTER TABLE `Ingredient` ADD COLUMN `aiProteins` REAL;
ALTER TABLE `Ingredient` ADD COLUMN `aiCarbs` REAL;
ALTER TABLE `Ingredient` ADD COLUMN `aiFats` REAL;
ALTER TABLE `Ingredient` ADD COLUMN `aiWeight` REAL;
ALTER TABLE `Meal` ADD COLUMN `wasEditedByUser` INTEGER NOT NULL DEFAULT 0;
```

Wrap each in try/catch for idempotency (existing migration pattern).

### 1.4 Update `app_database.dart`

Bump `_databaseVersion` from `8` to `9`. Register `migration8to9` in `locator.dart`.

### 1.5 Update domain models

**`lib/model/ingredient.dart`** — add fields:
```dart
final double? aiCalories;
final double? aiProteins;
final double? aiCarbs;
final double? aiFats;
final double? aiWeight;
```

**`lib/model/meal.dart`** — add field:
```dart
final bool wasEditedByUser;  // default: false
```

Update `copyWith()`, constructor, and `Meal.fromAnswer()` to populate `ai*` fields from the AI response (at creation time, AI values = current values).

### 1.6 Update `DayRecordRepository`

In `saveMealForDate()` and `_buildMealFromEntity()` / `_buildIngredientFromEntity()`, map the new fields between domain models and entities.

### 1.7 Populate AI snapshot in `Meal.fromAnswer()`

When creating a Meal from an AI response, set each ingredient's `ai*` fields to the same values as the primary fields:

```dart
return Ingredient(
  name: ingResponse.name,
  weight: weight,
  calories: ingResponse.nutritionalValues.calories.toDouble(),
  proteins: ingResponse.nutritionalValues.proteins,
  carbs: ingResponse.nutritionalValues.carbs,
  fats: ingResponse.nutritionalValues.fats,
  confidence: ingResponse.confidence,
  // AI snapshot — same as primary values at creation time
  aiCalories: ingResponse.nutritionalValues.calories.toDouble(),
  aiProteins: ingResponse.nutritionalValues.proteins,
  aiCarbs: ingResponse.nutritionalValues.carbs,
  aiFats: ingResponse.nutritionalValues.fats,
  aiWeight: weight,
);
```

When users edit values in `EditIngredientScreen`, only the primary fields change — the `ai*` fields remain unchanged, preserving the original AI estimates.

---

## Phase 2: Detect Edits & Set `wasEditedByUser`

### 2.1 Compare at save time in `EditMealScreen`

**File:** `lib/screens/meals/edit_meal_screen.dart`

In `_handleSaveInEditMode()`, before saving, compare each ingredient's current values against its `ai*` snapshot:

```dart
bool wasEdited = _ingredients.any((ing) {
  if (ing.aiCalories == null) return false; // Manual entry, not AI
  return ing.calories != ing.aiCalories ||
         ing.proteins != ing.aiProteins ||
         ing.carbs != ing.aiCarbs ||
         ing.fats != ing.aiFats ||
         ing.weight != ing.aiWeight;
});
```

Also check if ingredients were added or removed (compare count to original meal's ingredient count).

Set `wasEditedByUser` on the meal before saving:
```dart
final mealToSave = workingMeal.copyWith(wasEditedByUser: wasEdited);
```

### 2.2 Preserve AI snapshot through edits

In `EditIngredientScreen`, when building the updated ingredient from text controllers, carry over the `ai*` fields from `_baseIngredient`:

```dart
Ingredient _buildIngredientFromInputs() {
  return Ingredient(
    // ... user-edited values from controllers ...
    aiCalories: _baseIngredient.aiCalories,
    aiProteins: _baseIngredient.aiProteins,
    aiCarbs: _baseIngredient.aiCarbs,
    aiFats: _baseIngredient.aiFats,
    aiWeight: _baseIngredient.aiWeight,
    confidence: _baseIngredient.confidence,
  );
}
```

---

## Phase 3: Accuracy Computation Service

### 3.1 Create `AiAccuracyService`

**New file:** `lib/services/ai_accuracy_service.dart`

```dart
class AiAccuracyService extends GetxService {
  static AiAccuracyService get to => Get.find();

  /// Calculate accuracy stats for a date range
  Future<AiAccuracyStats> getAccuracyStats({
    required DateTime from,
    required DateTime to,
  }) async { ... }
}
```

### 3.2 `AiAccuracyStats` model

**New file:** `lib/model/ai_accuracy_stats.dart`

```dart
class AiAccuracyStats {
  final int totalAiMeals;          // Meals created via AI (have ai* fields)
  final int editedMeals;           // Meals where user changed values
  final int acceptedAsIsMeals;     // Meals user didn't edit
  final double acceptanceRate;     // acceptedAsIs / totalAiMeals (0.0–1.0)

  final double avgCalorieDeviation;   // Mean absolute % deviation for calories
  final double avgProteinDeviation;
  final double avgCarbsDeviation;
  final double avgFatsDeviation;
  final double avgWeightDeviation;

  final double overallAccuracy;    // 1 - avgDeviation (weighted across macros)
}
```

### 3.3 Deviation formula

Per-ingredient deviation for a given field:
```
deviation = |userValue - aiValue| / max(aiValue, 1.0)
```

Aggregate per meal: average deviation across all ingredients.
Aggregate for period: average across all meals.

Overall accuracy = `1.0 - clamp(avgDeviation, 0, 1)` expressed as percentage.

### 3.4 Query pattern

Fetch all meals in date range via `DayRecordRepository`, filter to those where any ingredient has non-null `aiCalories`, compute stats. This is a read-only aggregation — no new DAO queries needed initially, just iterate through the domain models already fetched by the repository.

### 3.5 Register in `locator.dart`

```dart
Get.lazyPut(() => AiAccuracyService());
```

---

## Phase 4: UI — Progress Screen Card

### 4.1 Add "AI Accuracy" card to Progress Screen

**File:** `lib/screens/progress_screen.dart`

Add a new card after the BMI card, following the existing card pattern. The card shows:

- **Header**: "AI Accuracy" with an icon (e.g., `Icons.auto_awesome`)
- **Main stat**: Overall accuracy as a large percentage (e.g., "87%") with a confidence-style color badge (green/yellow/red reusing `MatchBadge` thresholds)
- **Breakdown row**: 4 mini-stats showing per-macro deviation:
  - Calories: ±X%
  - Protein: ±X%
  - Carbs: ±X%
  - Fats: ±X%
- **Acceptance rate**: "X of Y meals accepted without edits" with a mini progress bar
- **Time range selector**: Reuse the existing `_SegmentedControl` pattern (This week / Last week / Last month / All time)

### 4.2 Create `AiAccuracyController`

**New file:** `lib/controller/ai_accuracy_controller.dart`

```dart
class AiAccuracyController extends GetxController {
  final stats = Rxn<AiAccuracyStats>();
  final selectedRange = 0.obs;  // index into time range options

  Future<void> loadStats() async { ... }
}
```

Register in `locator.dart` with `Get.lazyPut()`.

### 4.3 Empty state

If no AI-analyzed meals exist yet, show a placeholder: "Start scanning meals to see AI accuracy stats here."

---

## Phase 5: Correction Feedback Loop (Improving AI Recognition)

The core idea: use stored correction data from Phases 1–2 to make future AI prompts smarter. This closes the loop — corrections aren't just tracked, they actively improve recognition.

### 5.1 Create `AiCorrectionHistoryService`

**New file:** `lib/services/ai_feature/ai_correction_history_service.dart`

Queries the DB for recent correction patterns to inject into prompts.

```dart
class AiCorrectionHistoryService extends GetxService {
  static AiCorrectionHistoryService get to => Get.find();

  /// Get correction hints for prompt injection
  Future<CorrectionContext> getCorrectionContext() async { ... }
}
```

### 5.2 `CorrectionContext` model

**New file:** `lib/model/ai_correction_context.dart`

```dart
class CorrectionContext {
  final double avgPortionBias;            // e.g., +18% → user eats larger portions
  final Map<String, FoodCorrection> frequentCorrections; // per-food corrections
  final List<String> hints;              // Natural language hints for the prompt
}

class FoodCorrection {
  final String foodName;
  final int correctionCount;             // How many times this food was corrected
  final double avgCalorieDelta;          // Average calorie correction (e.g., +25)
  final double avgWeightDelta;           // Average weight correction (e.g., +30g)
}
```

### 5.3 Build correction context from DB

In `AiCorrectionHistoryService.getCorrectionContext()`:

1. **Fetch recent AI meals** (last 30–90 days) where `aiCalories != null`
2. **Compute per-food correction patterns:**
   - Group ingredients by normalized name (lowercased, trimmed)
   - For each food with ≥2 corrections, calculate average delta for calories and weight
   - Example: "chicken breast" was corrected from avg 165→210 kcal across 5 meals
3. **Compute global portion bias:**
   - Average ratio: `userWeight / aiWeight` across all corrected ingredients
   - If consistently > 1.0 → user eats larger portions than AI estimates
   - If consistently < 1.0 → user eats smaller portions
4. **Generate natural language hints** from the patterns:
   ```
   "This user typically eats 20% larger portions than average."
   "When estimating chicken breast, use ~210 kcal per 150g (user has corrected this 5 times)."
   "The user frequently corrects rice portions upward by ~40g."
   ```

### 5.4 Inject correction context into AI prompts

**File:** `lib/utils/prompt.dart`

Add a new section to the meal analysis prompt, after the existing dietary context from `_buildMealUserAttributes()`:

```dart
String _buildCorrectionContext(CorrectionContext ctx) {
  if (ctx.hints.isEmpty) return '';

  final buffer = StringBuffer();
  buffer.writeln('Based on this user\'s history of corrections to your estimates:');
  for (final hint in ctx.hints) {
    buffer.writeln('- $hint');
  }
  buffer.writeln('Adjust your estimates accordingly.');
  return buffer.toString();
}
```

Limit to top 5 most relevant hints to avoid bloating the prompt.

### 5.5 Wire into `AiPipelineService`

**File:** `lib/services/ai_feature/ai_pipeline_service.dart`

Before calling the AI provider in `analyzeMeal()`:

```dart
final correctionCtx = await AiCorrectionHistoryService.to.getCorrectionContext();
final prompt = buildMealPrompt(
  userAttributes: _buildMealUserAttributes(),
  correctionContext: _buildCorrectionContext(correctionCtx),
);
```

### 5.6 Nutritional database cross-reference (hybrid approach)

Instead of trusting AI for both identification AND macro values, split responsibilities:

**File:** `lib/services/ai_feature/ai_pipeline_service.dart` (post-processing)

After receiving the AI response, for each ingredient:

1. **Look up** the identified food name in Open Food Facts (already integrated via `BarcodeLookupService` / `OpenFoodFactsClient`) by text search
2. **If a match is found** with high confidence: use the database's per-100g macros × AI-estimated weight, instead of AI's macro estimates
3. **If no match**: keep AI's original macro estimates

This makes the AI responsible only for **identification + portion estimation** (what vision models are good at), while macros come from an authoritative nutritional database.

```dart
Future<AiResponse> _postProcessWithNutritionalDB(AiResponse response) async {
  for (final ingredient in response.answer.ingredients) {
    final dbLookup = await _lookupFood(ingredient.name);
    if (dbLookup != null && dbLookup.confidence > 0.8) {
      final weight = _parseWeight(ingredient.quantity);
      ingredient.nutritionalValues = NutritionalValues(
        calories: (dbLookup.caloriesPer100g * weight / 100).round(),
        proteins: dbLookup.proteinsPer100g * weight / 100,
        carbs: dbLookup.carbsPer100g * weight / 100,
        fats: dbLookup.fatsPer100g * weight / 100,
      );
    }
  }
  return response;
}
```

> **Note:** This is the highest-impact improvement since it grounds AI estimates in real nutritional data. The existing Open Food Facts integration (`lib/network/open_food_facts_client.dart`) can be extended with a text search endpoint alongside the barcode lookup.

### 5.7 Prompt engineering improvements

**File:** `lib/utils/prompt.dart`

Independent of the feedback loop, these prompt changes improve accuracy immediately:

- **Few-shot examples**: Include 2–3 example meal analyses in the system prompt showing the expected precision level and JSON format
- **Chain-of-thought**: Instruct the model to first list what it sees, then estimate portions, then calculate macros — reduces compound errors
- **Explicit weight instructions**: "Always estimate weight in grams, even for countable items (e.g., '1 medium apple = 182g', '1 slice of bread = 30g')"
- **Regional context**: If user locale is `cs`, add: "Consider typical Czech portion sizes and local food preparations"

---

## Phase 6 (Optional): Thumbs Up/Down Feedback

### 6.1 Add feedback UI in `EditMealScreen`

After AI analysis, before the user starts editing, show a subtle prompt:

```
"Was this analysis accurate?"
[👍 Yes]  [👎 No, I'll fix it]
```

- **Thumbs up**: Sets `wasEditedByUser = false` explicitly and saves immediately (skip manual confirmation if user wants).
- **Thumbs down**: Normal edit flow continues. `wasEditedByUser` is set automatically at save time based on actual changes.

This is optional because `wasEditedByUser` is already computed automatically from value comparison. The explicit feedback adds a subjective dimension (user might think "close enough" even if values differ slightly).

### 6.2 Store feedback

Add `userFeedback` field to `MealEntity` (nullable int: `null` = no feedback, `1` = positive, `0` = negative). This can be part of the same migration (v8→v9) or deferred to a later migration.

---

## File Changes Summary

### New Files
| File | Purpose |
|------|---------|
| `lib/services/ai_accuracy_service.dart` | Accuracy computation logic |
| `lib/services/ai_feature/ai_correction_history_service.dart` | Builds correction context from past user edits |
| `lib/model/ai_accuracy_stats.dart` | Stats data model |
| `lib/model/ai_correction_context.dart` | Correction context model for prompt injection |
| `lib/controller/ai_accuracy_controller.dart` | UI state for accuracy card |
| `lib/widgets/ai_accuracy_card.dart` | Progress screen card widget |

### Modified Files
| File | Changes |
|------|---------|
| `lib/database/entities/ingredient_entity.dart` | Add `aiCalories`, `aiProteins`, `aiCarbs`, `aiFats`, `aiWeight` |
| `lib/database/entities/meal_entity.dart` | Add `wasEditedByUser` |
| `lib/database/app_database.dart` | Bump version to 9 |
| `lib/database/migrations.dart` | Add `migration8to9` |
| `lib/model/ingredient.dart` | Add AI snapshot fields + update `copyWith()` |
| `lib/model/meal.dart` | Add `wasEditedByUser` + update `fromAnswer()`, `copyWith()` |
| `lib/services/day_record_repository.dart` | Map new fields in entity ↔ domain conversions |
| `lib/screens/meals/edit_meal_screen.dart` | Compute `wasEditedByUser` at save time |
| `lib/screens/ingredients/edit_ingredient_screen.dart` | Carry over `ai*` fields in `_buildIngredientFromInputs()` |
| `lib/screens/progress_screen.dart` | Add AI Accuracy card |
| `lib/utils/prompt.dart` | Add correction context section + few-shot examples + chain-of-thought |
| `lib/services/ai_feature/ai_pipeline_service.dart` | Inject correction context before AI call + optional nutritional DB post-processing |
| `lib/locator.dart` | Register migration + new services/controllers |

### Localization
| Key | EN | CS |
|-----|----|----|
| `ai_accuracy` | AI Accuracy | Přesnost AI |
| `ai_accuracy_empty` | Start scanning meals to see AI accuracy stats here. | Začněte skenovat jídla, abyste zde viděli statistiky přesnosti AI. |
| `overall_accuracy` | Overall Accuracy | Celková přesnost |
| `acceptance_rate` | Acceptance Rate | Míra přijetí |
| `meals_accepted` | {count} of {total} meals accepted without edits | {count} z {total} jídel přijato bez úprav |
| `calorie_deviation` | Calories | Kalorie |
| `protein_deviation` | Protein | Bílkoviny |
| `carbs_deviation` | Carbs | Sacharidy |
| `fats_deviation` | Fats | Tuky |
| `this_week` | This week | Tento týden |
| `last_week` | Last week | Minulý týden |
| `last_month` | Last month | Minulý měsíc |
| `all_time` | All time | Celkem |

---

## Implementation Order

1. **DB + Models** (Phase 1) — migration, entities, domain models, repository mapping
2. **Edit detection** (Phase 2) — carry AI snapshot through edits, detect changes at save
3. **Run `build_runner`** — regenerate Floor code
4. **Service + Controller** (Phase 3) — accuracy computation
5. **UI Card** (Phase 4) — progress screen widget
6. **Correction feedback loop** (Phase 5) — correction history service, prompt injection, prompt improvements
7. **Localization** — add translation keys
8. **Thumbs up/down** (Phase 6, optional) — explicit user feedback
9. **Nutritional DB cross-reference** (Phase 5.6, optional) — extend Open Food Facts with text search for post-processing

---

## Testing Checklist

- [ ] New meal from AI: `ai*` fields populated, match primary values
- [ ] Edit ingredient then save: `ai*` fields unchanged, `wasEditedByUser = true`
- [ ] Save AI meal without edits: `wasEditedByUser = false`
- [ ] Manual meal (no AI): `ai*` fields null, excluded from accuracy stats
- [ ] Migration: existing data upgrades cleanly (ai* fields null for old data)
- [ ] Accuracy card: shows correct stats, handles empty state
- [ ] Time range filter: stats update on segment change
- [ ] Duplicate meal: `ai*` fields preserved in copy
- [ ] Correction context: hints generated from ≥2 corrections of same food
- [ ] Correction context: empty hints when no correction history exists (prompt unchanged)
- [ ] Portion bias: computed correctly from weight deltas across corrected ingredients
- [ ] Prompt injection: correction hints appear in AI prompt, limited to top 5
- [ ] Prompt improvements: few-shot examples and chain-of-thought present in prompt
- [ ] Regional context: Czech portion hint injected when locale is `cs`
