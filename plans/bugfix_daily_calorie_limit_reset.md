# Bugfix: Daily Calorie Limit Resets to 2000 — Implementation Plan

## Problem Statement

Discovered during long-term user testing (`thesis/testovani/dlouhodoby_text_notes.md`):

> "bug, kde se kazdemu nastavi v nasledujicim dnu kaloricky limit na 2000 .. nehlede zda predchozi den mel mene ci vice"

Every time the user logs the first meal/exercise of a new calendar day, the day's calorie goal is hardcoded to **2000 kcal** (and macros to **150 / 250 / 70 g**), regardless of:

- the user's persisted nutrition goal from onboarding / `EditNutritionGoalsScreen`,
- the goal that was active on the previous day,
- any rollover-calorie carry-forward from the previous day (`SessionManager.rolloverCaloriesEnabled`).

### Reproduction

1. Finish onboarding with a custom calorie goal (e.g. 1700 kcal) or change goals via Profile → Edit Nutrition Goals so that yesterday's `DayRecord` has `calorieGoal = 1700`.
2. Wait until midnight (or change device date forward by one day).
3. Open the app on the new date and log any meal/exercise (or simply trigger an action that touches the day).
4. Inspect the new day's `DayRecord` — `calorieGoal` is `2000`, not `1700`. Dashboard shows the wrong target. Rollover (if enabled) is computed against `2000`, not against the user's real goal.

---

## Root Cause

`DayRecordRepository._ensureDayRecordId` creates a brand-new `DayRecordEntity` for any date that does not yet exist in the DB, but it passes **only the date** to the constructor. The entity then falls back to the constructor default values for `calorieGoal`, `proteinGoal`, `carbsGoal`, `fatGoal`.

**Primary site:** `lib/services/day_record_repository.dart:359-369`

```dart
Future<int> _ensureDayRecordId(DateTime normalizedDate) async {
  final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
  if (existing != null) {
    return existing.id!;
  }

  final id = await _dayRecordDao.insertDayRecord(
    DayRecordEntity(date: normalizedDate),   // <-- no goals passed
  );
  return id;
}
```

**Defaults that get baked in** — `lib/database/entities/day_record_entity.dart:21-24`:

```dart
this.calorieGoal = 2000,
this.proteinGoal = 150,
this.carbsGoal = 250,
this.fatGoal = 70,
```

The same hardcoded defaults also live in:

- `lib/model/day_record.dart:19-22` (domain model default constructor),
- `lib/model/nutrition_goals.dart:12-17` (`NutritionGoals.defaults`).

`_ensureDayRecordId` is called from:

- `DayRecordRepository.saveMealForDate` — `lib/services/day_record_repository.dart:94`
- `DayRecordRepository.saveExerciseForDate` — `lib/services/day_record_repository.dart:221`

So **the first meal/exercise logged on a new day silently creates a `DayRecord` with the default 2000 / 150 / 250 / 70 goals**, regardless of what the user actually has configured. The user's persisted goal lives only inside previous `DayRecord` rows (it is not stored as a standalone profile-level setting on SharedPreferences); `NutritionGoalsService.saveGoalsEffectiveFromDate` writes the goal into every existing day record from the effective date forward, but it cannot write into a row that does not yet exist. The bug is therefore deterministic on every fresh day.

### Why `NutritionGoalsService` does not save the user

`NutritionGoalsService.goalsForDate` (`lib/services/nutrition_goals_service.dart:26-42`) can correctly *resolve* the right goal for a date by looking at the most recent prior `DayRecord` (`_resolveGoalsFromKnownDayRecords`, lines 96-111). However, this is read-only — it only feeds the dashboard's display. The persisted row created by `_ensureDayRecordId` still carries the wrong values, and all downstream calculations (rollover in `DayRecordController._computeRollover`, calendar ring rendering in `_resolveRingStyleWithSettings`, exports, weekly/monthly summaries) read from the row, not from the service cache.

### Why rollover is broken as a consequence

`DayRecordController._computeRollover` (`lib/controller/day_record_controller.dart:252-256`) uses `prevRecord.calorieGoal` to compute leftover calories from yesterday. If yesterday's record was silently created with the default 2000 (e.g. user historically had 1700 but skipped logging yesterday before the bug existed, or the user is new and the onboarding goal never propagated to a future day), the rollover is wrong as well. The fix below resolves both symptoms at the source.

---

## Files to Change

| File | Change |
|------|--------|
| `lib/services/day_record_repository.dart` | Make `_ensureDayRecordId` seed new rows with the resolved goal from the most recent prior `DayRecord` instead of relying on entity defaults. |
| `lib/services/nutrition_goals_service.dart` | Add a synchronous goal resolver that can be called from the repository without a Get controller round-trip (move/expose the prior-day lookup logic on top of the DAO). Alternative: query the DAO directly from the repository. |

No UI changes needed. No new translations. No schema change.

### Files NOT to change (but worth double-checking after the fix)

- `lib/database/entities/day_record_entity.dart` — leave the constructor defaults as safety fallback; we explicitly pass goals at every insertion site.
- `lib/model/day_record.dart` — same rationale.
- `lib/model/nutrition_goals.dart` — `NutritionGoals.defaults` stays as the absolute last-resort fallback (truly new user with no prior records and no profile data).

---

## Fix Strategy

When `_ensureDayRecordId` has to insert a new `DayRecordEntity`, resolve the goal in this priority order:

1. **Most recent prior `DayRecord`** in the DB (`date < normalizedDate`) — carries the user's last effective goal.
2. **Most recent `DayRecord` of any date** — covers the edge case where the user logs a meal on a past date before any "today" record exists.
3. **`NutritionGoals.defaults`** — only when the user has literally zero `DayRecord` rows yet (first launch, first action).

Doing the lookup in the repository keeps the fix local to the persistence layer and avoids coupling `NutritionGoalsService` (a `GetxService`) with the repository (which must remain safely callable from background tasks).

---

## Step-by-Step Fix

### Step 1 — Add a "find most recent prior DayRecord" DAO query

In `lib/database/dao/day_record_dao.dart`, add:

```dart
@Query('SELECT * FROM DayRecord WHERE date < :beforeMs ORDER BY date DESC LIMIT 1')
Future<DayRecordEntity?> findMostRecentDayRecordBefore(int beforeMs);

@Query('SELECT * FROM DayRecord ORDER BY date DESC LIMIT 1')
Future<DayRecordEntity?> findMostRecentDayRecord();
```

Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate `app_database.g.dart`.

### Step 2 — Resolve goals before insertion

In `lib/services/day_record_repository.dart`, replace `_ensureDayRecordId` (lines 359-369) with:

```dart
Future<int> _ensureDayRecordId(DateTime normalizedDate) async {
  final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
  if (existing != null) {
    return existing.id!;
  }

  final seed = await _resolveSeedGoalsForNewRecord(normalizedDate);
  final id = await _dayRecordDao.insertDayRecord(
    DayRecordEntity(
      date: normalizedDate,
      calorieGoal: seed.calorieGoal,
      proteinGoal: seed.proteinGoal,
      carbsGoal: seed.carbsGoal,
      fatGoal: seed.fatGoal,
    ),
  );
  return id;
}

Future<NutritionGoals> _resolveSeedGoalsForNewRecord(DateTime normalizedDate) async {
  final prior = await _dayRecordDao.findMostRecentDayRecordBefore(normalizedDate.millisecondsSinceEpoch);
  if (prior != null) {
    return NutritionGoals(
      calorieGoal: prior.calorieGoal,
      proteinGoal: prior.proteinGoal,
      carbsGoal: prior.carbsGoal,
      fatGoal: prior.fatGoal,
    );
  }
  final anyExisting = await _dayRecordDao.findMostRecentDayRecord();
  if (anyExisting != null) {
    return NutritionGoals(
      calorieGoal: anyExisting.calorieGoal,
      proteinGoal: anyExisting.proteinGoal,
      carbsGoal: anyExisting.carbsGoal,
      fatGoal: anyExisting.fatGoal,
    );
  }
  return NutritionGoals.defaults;
}
```

Add the import: `import 'package:diplomka/model/nutrition_goals.dart';`

### Step 3 — Also fix the `upsertDayRecord` else-branch (defensive)

`lib/services/day_record_repository.dart:77-87` already passes the goals from the caller's `DayRecord`, so it is correct — but `NutritionGoalsService.saveGoalsEffectiveFromDate` calls `upsertDayRecord` with a `DayRecord.initial(normalizedEffectiveDate)` that has just been overwritten by `goals.applyToDayRecord(record)` (`nutrition_goals_service.dart:79-86`). Verify this path still works after the change. No code change expected here; this is just a verification step.

### Step 4 — Optional cleanup pass (recommended, not blocking)

The constructor defaults `2000 / 150 / 250 / 70` are now only reachable through `NutritionGoals.defaults` and through anyone who constructs `DayRecord` / `DayRecordEntity` without specifying goals. Audit grep:

```
grep -rn "DayRecordEntity(" lib/
grep -rn "DayRecord(" lib/ | grep -v "DayRecord(\$\| \?\?"
```

Confirm no other site silently inserts a row without goals. If new sites are discovered, route them through the same seed helper.

---

## Test Plan / Verification

### Manual smoke test (primary)

1. Fresh install. Complete onboarding with a non-default calorie goal (e.g. 1700 kcal). Confirm dashboard shows 1700.
2. Force-quit and reopen — still 1700.
3. Change device date to tomorrow. Open the app. Dashboard should still show 1700 (no record yet, resolver picks the prior day's goal at *display* time via `NutritionGoalsService`).
4. Log any meal. The new `DayRecord` is written with `calorieGoal = 1700`. Verify by:
   - Calorie goal on the daily card is 1700, not 2000.
   - Toggle rollover on (Profile → Preferences), confirm that yesterday's rollover is computed against 1700.
5. Repeat with a Czech locale + a custom diet to ensure no regression in unrelated screens.

### Edge cases to exercise

- **First-ever launch, no DayRecord rows yet, no onboarding finished**: should fall back to `NutritionGoals.defaults` (2000/150/250/70). This is acceptable — onboarding will overwrite it the moment the user finishes.
- **User logs a meal on a *past* date that has no DayRecord**: the resolver picks the most recent prior record. If none exists (the past date is older than every existing record), it picks the most recent record of any date. Acceptable — using the user's known goal beats fabricating 2000.
- **User edits nutrition goals mid-day**: `NutritionGoalsService.saveGoalsEffectiveFromDate` already updates today and every future existing row. Future days that don't yet exist will be seeded from today's row when first written. Correct.

### Regression checks

- `flutter analyze` — no new warnings.
- `flutter test` — no failing tests. If a test fixture creates `DayRecordEntity(date: ...)` without goals and asserts on `calorieGoal == 2000`, update it to assert against the resolver (or pass goals explicitly).
- Smoke-test the export (CSV/PDF): goals column for "new" days should reflect the propagated value, not 2000.
- Smoke-test home-widget sync (`WidgetSyncService`) on day rollover.

---

## Data Migration

**None required.** DB schema stays at version 1 (per `CLAUDE.md` and `lib/database/app_database.dart:30`). The bug only affects rows written *after* the fix ships; existing buggy rows in long-term testers' DBs can optionally be back-corrected by:

1. Asking testers to re-save goals via Profile → Edit Nutrition Goals (current code already propagates to all existing records on/after the effective date).

This is documented as a one-step user action; no code-side migration is justified for a research build.

---

## Risk & Scope Summary

- **Lines changed**: ~30 in `day_record_repository.dart`, ~6 in `day_record_dao.dart`, plus regenerated `app_database.g.dart`.
- **New dependencies**: none.
- **New schema**: none.
- **Risk**: Low. The fix only affects the path that creates a brand-new `DayRecord`. Existing rows are untouched. The fallback chain ends in `NutritionGoals.defaults`, so behavior never gets *worse* than today's buggy behavior.
- **Thesis impact**: Worth a short paragraph in `chapters/05-testovani.tex` under "Nálezy z dlouhodobého testování / opravy" — bug found in long-term test, root-caused to a default-value leak in the day-record creation path, fix described, and the fix shipped to v[X]. Keeps the testing chapter honest about iteration.
