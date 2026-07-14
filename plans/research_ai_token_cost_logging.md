# Research: Per-Call AI Token and USD Cost Logging

> **Summary**: Instrument every OpenAI Chat Completions call in Foody to capture `response.usage` (prompt_tokens, completion_tokens, cached_tokens) and the resulting USD cost computed from the official OpenAI price table, persist it to the existing `AiAttempt` research table, and surface the new fields in the CSV export plus an aggregated USD cost summary block in the PDF export so the long-term-study analyst can reconstruct real per-user operating cost.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement
The thesis opponent asked for the real economic cost of running Foody based on the long-term study. The existing `AiAttempt` telemetry rows tell us when AI calls happened and how they went, but they record **no token counts and no USD cost**. The current CSV/PDF exports therefore cannot answer the question without external manual estimation, which is what the thesis defense currently relies on.

### 1.2 Solution Overview
Read the `usage` object that OpenAI already returns in every Chat Completions response, compute the dollar cost via a small pure-Dart pricing util that mirrors the official OpenAI table, and persist both into four new nullable columns on the `AiAttempt` table (schema bumps DB v2 → v3 with an additive `ALTER TABLE` migration). Existing exports gain the four new columns inside the *AI Attempts* CSV section plus a new *AI Usage Summary* block at the end of the CSV and PDF that aggregates total calls, tokens (split into input non-cached / input cached / output) and total USD.

### 1.3 Scope: What This IS
- Capture `prompt_tokens`, `completion_tokens`, and `prompt_tokens_details.cached_tokens` from every successful OpenAI Chat Completions response (six call sites total: meal recognition, exercise recognition, query-scope estimate, Ask AI analysis, nutrition goals generation, and the prompt-injection pre-screen).
- Compute USD cost in pure Dart using the supplied OpenAI price table for `gpt-5.4`, `gpt-5.4-mini`, and `gpt-5.5`.
- Persist tokens and cost on the `AiAttempt` row via four new nullable columns (`promptTokens`, `completionTokens`, `cachedTokens`, `costUsd`).
- Bump SQLite schema from v2 to v3 with an additive `ALTER TABLE AiAttempt ADD COLUMN ...` migration, so existing tester data is preserved (legacy rows remain `NULL` for the new columns).
- Extend the existing `--- AI Attempts ---` CSV section with four columns and emit a new `--- AI Usage Summary ---` block (in both CSV and PDF) that aggregates per-model and per-status totals and a grand-total USD figure for the report period.
- Log a **separate** `AiAttempt` row for each prompt-injection pre-screen call (today these are not logged at all) so the mini-model cost is visible.

### 1.4 Scope: What This IS NOT
- **No** user-visible cost UI (preferences, dashboard, profile) — cost is internal research telemetry only, exactly like the rest of the AiAttempt log that already lives under the `RESEARCH-ONLY` banner.
- **No** prompt optimisation, no cache-aware prompt restructuring, no batch API migration.
- **No** in-app aggregation per day or per user beyond what the report period already provides; the analyst will aggregate from CSV.
- **No** CZK / currency conversion — cost is stored and reported in USD only.
- **No** changes to Gemini path. Gemini does not bill via OpenAI's usage object; if `usage` is absent, the new columns simply stay `NULL` and the cost calculator returns `null`.

---

## 2. SUCCESS CRITERIA

Implementation is COMPLETE when ALL criteria are met:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | Every successful OpenAI Chat Completions call writes an `AiAttempt` row with non-null `promptTokens`, `completionTokens`, and `costUsd`. | Run a meal photo recognition, Ask AI query, goals generation, and a voice exercise log on a debug build. Open the SQLite DB and confirm four new rows have the new columns populated. |
| 2 | Each prompt-injection pre-screen call writes its own `AiAttempt` row with `kind='injection_screen'` and the mini-model pricing. | Log a meal via voice (which triggers the pre-screen). Confirm two rows are written (pre-screen + meal) and the pre-screen row uses `gpt-5.4-mini` with cost < $0.001. |
| 3 | `AiCostCalculator.calculateCostUsd` produces the exact value below for the unit test inputs: model `gpt-5.4`, 2000 prompt tokens (0 cached), 600 completion tokens → **0.014000 USD**. | Unit test `test/utils/ai_cost_calculator_test.dart`. |
| 4 | Cached tokens are billed at the cached rate when present in the response. For model `gpt-5.4`, 2000 prompt (800 cached), 600 completion → **0.012200 USD**. | Same unit test file, separate case. |
| 5 | DB migration v2 → v3 runs on an existing v2 database without data loss; legacy `AiAttempt` rows remain queryable with the new columns set to `NULL`. | Restore a backup `.db` from a previous build, install the new build over it, open DB, run `SELECT id, promptTokens FROM AiAttempt` and confirm legacy rows are `NULL` and new rows are populated. |
| 6 | CSV export contains four new columns at the right edge of the `--- AI Attempts ---` table and a new `--- AI Usage Summary ---` block with grand totals. | Run *Profile → Export PDF/CSV* over the test period, open the CSV, eyeball the columns and the summary section. |
| 7 | PDF export renders the same `--- AI Usage Summary ---` block as a readable text/table page at the end of the document. | Generate PDF, open, confirm the summary page is present and totals match the CSV. |
| 8 | A model returned by the API that is not in the price table (e.g. a future `gpt-5.6`) is logged with non-null tokens but `costUsd` `NULL`, and no exception is raised. | Manually temporarily change the model string in `openai_rest_client.dart` to something unrecognised, run a call, confirm the row is written with `costUsd` `NULL`. |
| 9 | Telemetry failure (DB write error, missing `usage` field, divide-by-zero, etc.) never breaks the AI flow visible to the user. | Throw inside `AiAttemptLogService.log` (temporarily). Confirm the meal still gets saved end-to-end and the error is silently swallowed (it already wraps in `try { } catch (_) { }`, but the new code must preserve this). |
| 10 | `flutter analyze` is clean and `flutter pub run build_runner build --delete-conflicting-outputs` succeeds after the entity change. | Run both commands. |

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture

```
┌────────────────────┐   data (Map)    ┌──────────────────────┐
│ OpenaiRestClient   │────────────────▶│ AiPipelineService    │
│                    │ contains        │ (or OpenaiService    │
│ _postChatCompletion│ response.usage  │  for meal recogn.)   │
│ preScreenForInject.│                 └──────────┬───────────┘
└──────────┬─────────┘                            │
           │                                       │ OpenAiUsage.fromResponse(data)
           │                                       │ AiCostCalculator.calculateCostUsd(...)
           │                                       ▼
           │                            ┌──────────────────────┐
           │                            │ AiAttemptLogService  │
           │                            │ .log(... usage, cost)│
           │                            └──────────┬───────────┘
           │                                       │
           │                                       ▼
           │                            ┌──────────────────────┐
           │                            │ AiAttemptDao (Floor) │
           │                            │ → AiAttempt table v3 │
           │                            └──────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ ExportService.generateCsv / .generatePdf                     │
│   reads AiAttemptEntity rows                                 │
│   emits per-row data + new aggregated "AI Usage Summary"     │
└──────────────────────────────────────────────────────────────┘
```

Data flow: the OpenAI response body already contains a `usage` field. The network layer keeps returning the raw `Map<String, dynamic>` (no signature change). The caller (pipeline) extracts usage via a static helper, calls the cost calculator, and forwards both to the existing `AiAttemptLogService.log`. The DAO writes the enriched row. Export reads it back unchanged plus a small aggregation pass.

### 3.2 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Where to read `usage` from? | At the pipeline layer via a static helper `OpenAiUsage.fromResponse(data)`. Network layer signature stays `Map<String, dynamic>`. | The response body already carries `usage` at the top level. Forcing a new return type would break six call sites and the Gemini implementation that reuses the same interface. A static helper is purely additive. |
| Where to compute cost? | At the pipeline layer, right before `AiAttemptLogService.log`. | The pipeline already knows the model and the modality. Keeping cost computation out of the DAO and out of the network client preserves the clean layering. |
| Store cost as `REAL` or `INTEGER` (micro-dollars)? | `REAL` (Dart `double`). | Six significant digits is sufficient ($0.000001 precision). The analyst exports as text anyway. Integer micro-cents would force ceremony at every read site for no real benefit. |
| Add a separate `AiAttempt` row for the pre-screen call or fold it into the meal row? | Separate row. New `AiAttemptKind.injectionScreen`. | The pre-screen is a distinct API call with its own latency, its own model, and its own cost. Folding it would lose the 1:1 mapping between rows and billable API calls, which is the whole point of the exercise. |
| DB migration strategy? | Additive `ALTER TABLE ... ADD COLUMN` for each of the 4 new columns. Bump version 2 → 3. | Matches the pattern already established by `_migration1to2` in `lib/database/migrations.dart` (added `dietaryViolation`). No data loss, no risky transforms. |
| Currency? | USD only, stored as a `double`. | OpenAI bills in USD. CZK conversion is the analyst's job and depends on the exchange rate at analysis time. Embedding it freezes the wrong rate. |
| Model name source of truth for cost lookup? | A new `lib/utils/ai_model_constants.dart` with named constants. Both `openai_rest_client.dart` and the pipeline import the same constant. | Today the network client hardcodes `"gpt-5.4"` as a string literal in two places. Hardcoding twice (network + pipeline) would drift. A single constant prevents that. |
| Pre-screen `AiAttempt` status field semantics. | `success` if API returned 200 (regardless of injection verdict). New status `injection_detected` if the pre-screen flagged the input as injection. | Preserves the existing convention that `status` = API outcome bucket. Whether the verdict was "injection: yes" is captured by a new status value, so an analyst can count detections by `WHERE status='injection_detected'`. |
| Behaviour when `usage` field is missing from response. | Log the attempt with all three token columns `NULL` and `costUsd` `NULL`. No exception. | Forward-compat with future API changes and with Gemini which lacks `usage`. |

---

## 4. IMPLEMENTATION STEPS

> Execute steps in order. Do not skip.

### Step 1: Add the model name constants

**Goal**: Single source of truth for the three model strings used in the network layer and the pipeline.
**Files**: `lib/utils/ai_model_constants.dart` (new).

```dart
// Centralised model identifiers used in OpenAI Chat Completions requests.
// Keep in sync with the price table in AiCostCalculator.
const String aiModelMain = 'gpt-5.4';
const String aiModelPreScreen = 'gpt-5.4-mini';
const String aiModelFlagship = 'gpt-5.5';
```

**Done when**: File exists, exports compile.

---

### Step 2: Implement the cost calculator

**Goal**: Pure-Dart util that converts (model, prompt, completion, cached) into a USD double using the supplied price table.
**Files**: `lib/utils/ai_cost_calculator.dart` (new).

```dart
import 'package:diplomka/utils/ai_model_constants.dart';

class _Pricing {
  final double inputPerM;        // USD per 1M non-cached input tokens
  final double cachedInputPerM;  // USD per 1M cached input tokens
  final double outputPerM;       // USD per 1M output tokens
  const _Pricing(this.inputPerM, this.cachedInputPerM, this.outputPerM);
}

class AiCostCalculator {
  static const Map<String, _Pricing> _table = {
    aiModelMain:     _Pricing(2.50, 0.25, 15.00),   // gpt-5.4
    aiModelPreScreen:_Pricing(0.75, 0.075, 4.50),   // gpt-5.4-mini
    aiModelFlagship: _Pricing(5.00, 0.50, 30.00),   // gpt-5.5
  };

  /// Returns the cost in USD (e.g. 0.014) or null if the model is unknown.
  /// `cachedTokens` is a subset of `promptTokens` (already counted in it);
  /// the non-cached portion is billed at the input rate, the cached portion
  /// at the cached rate.
  static double? calculateCostUsd({
    required String model,
    required int promptTokens,
    required int completionTokens,
    int cachedTokens = 0,
  }) {
    final p = _table[model];
    if (p == null) return null;
    final nonCached = (promptTokens - cachedTokens).clamp(0, 1 << 30);
    return (nonCached / 1e6) * p.inputPerM
         + (cachedTokens / 1e6) * p.cachedInputPerM
         + (completionTokens / 1e6) * p.outputPerM;
  }
}
```

**Done when**: File compiles, unit test (Step 12) passes.

---

### Step 3: Implement the `OpenAiUsage` extraction helper

**Goal**: Static helper that converts a raw response `Map<String, dynamic>` into a typed usage object, tolerating missing fields.
**Files**: `lib/utils/openai_usage.dart` (new).

```dart
class OpenAiUsage {
  final int promptTokens;
  final int completionTokens;
  final int cachedTokens; // 0 if not reported

  const OpenAiUsage({
    required this.promptTokens,
    required this.completionTokens,
    this.cachedTokens = 0,
  });

  /// Returns null when the response carries no `usage` block.
  static OpenAiUsage? fromResponse(Map<String, dynamic>? data) {
    if (data == null) return null;
    final usage = data['usage'];
    if (usage is! Map) return null;
    final cached = (usage['prompt_tokens_details'] is Map)
        ? (usage['prompt_tokens_details']['cached_tokens'] as num? ?? 0).toInt()
        : 0;
    return OpenAiUsage(
      promptTokens: (usage['prompt_tokens'] as num? ?? 0).toInt(),
      completionTokens: (usage['completion_tokens'] as num? ?? 0).toInt(),
      cachedTokens: cached,
    );
  }
}
```

**Done when**: File compiles. (Behaviour is exercised in the integration smoke test, Step 13.)

---

### Step 4: Extend `AiAttemptEntity` with the four new nullable columns

**Goal**: Persist tokens and cost alongside the existing fields.
**Files**: `lib/database/entities/ai_attempt_entity.dart`.

Append after `errorMessage`:

```dart
  /// Prompt (input) tokens reported by OpenAI's `response.usage.prompt_tokens`.
  /// Null when the provider did not return a usage block.
  final int? promptTokens;

  /// Completion (output) tokens reported by `response.usage.completion_tokens`.
  final int? completionTokens;

  /// Subset of `promptTokens` that hit OpenAI's prompt cache, from
  /// `response.usage.prompt_tokens_details.cached_tokens`. Null/0 when absent.
  final int? cachedTokens;

  /// Computed USD cost of this single API call. Null when the model is not
  /// in the price table or when tokens are missing.
  final double? costUsd;
```

…and add them to the constructor signature as `this.promptTokens, this.completionTokens, this.cachedTokens, this.costUsd`.

**Done when**: Field list compiles. `build_runner` will regenerate the schema in Step 6.

---

### Step 5: Update `AiAttemptKind` enum and code mapping

**Goal**: A distinct kind for prompt-injection pre-screen calls and a distinct status for "injection detected".
**Files**: `lib/services/ai_feature/ai_attempt_log_service.dart`.

```diff
- enum AiAttemptKind { meal, exercise, goals }
+ enum AiAttemptKind { meal, exercise, goals, query, queryScope, injectionScreen }
```

```diff
- enum AiAttemptStatus { success, lowConfidence, invalidResponse, error, injectionRejected }
+ enum AiAttemptStatus { success, lowConfidence, invalidResponse, error, injectionRejected, injectionDetected }
```

Update `_kindCode` and `_statusCode` accordingly (`query`, `query_scope`, `injection_screen`, `injection_detected`).

> Adding `query` and `queryScope` is a bonus: those Ask AI endpoints currently aren't logged either, but their cost will be material in a heavy Ask AI user's bill. They share the same code path so it's effectively free to instrument.

**Done when**: All switch statements remain exhaustive (no analyser warnings).

---

### Step 6: Extend `AiAttemptLogService.log` to accept tokens and cost

**Goal**: Pipe the new fields from caller to DAO.
**Files**: `lib/services/ai_feature/ai_attempt_log_service.dart`.

Add four optional parameters and forward them into the entity constructor:

```dart
Future<void> log({
  required AiAttemptKind kind,
  required AiAttemptStatus status,
  String? modality,
  String? provider,
  String? model,
  double? confidence,
  String? errorMessage,
  DateTime? timestamp,
  int? promptTokens,
  int? completionTokens,
  int? cachedTokens,
  double? costUsd,
}) async {
  try {
    await _dao.insertAttempt(
      AiAttemptEntity(
        timestampMs: (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
        kind: _kindCode(kind),
        modality: modality,
        provider: provider,
        model: model,
        status: _statusCode(status),
        confidence: confidence,
        errorMessage: _truncate(errorMessage),
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        cachedTokens: cachedTokens,
        costUsd: costUsd,
      ),
    );
  } catch (_) { /* telemetry must never affect user-facing behaviour */ }
}
```

**Done when**: Existing callers compile unchanged (params are optional). New callers can pass tokens.

---

### Step 7: Regenerate Floor schema

**Goal**: Have `app_database.g.dart` reflect the new columns.
**Files**: auto-generated (`lib/database/app_database.g.dart`, `lib/database/dao/ai_attempt_dao.g.dart` if any).

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Done when**: Build runner exits cleanly and the regenerated SQL inside `app_database.g.dart` for table `AiAttempt` mentions `promptTokens`, `completionTokens`, `cachedTokens`, `costUsd`.

---

### Step 8: Add the v2 → v3 migration and bump the database version

**Goal**: Existing testers can upgrade in-place without losing their AI history.
**Files**: `lib/database/migrations.dart`, `lib/database/app_database.dart`.

In `migrations.dart`:

```dart
// v2 → v3: per-call token usage and USD cost on AiAttempt.
// Additive only; legacy rows stay NULL.
final _migration2to3 = Migration(2, 3, (db) async {
  await db.execute('ALTER TABLE AiAttempt ADD COLUMN promptTokens INTEGER');
  await db.execute('ALTER TABLE AiAttempt ADD COLUMN completionTokens INTEGER');
  await db.execute('ALTER TABLE AiAttempt ADD COLUMN cachedTokens INTEGER');
  await db.execute('ALTER TABLE AiAttempt ADD COLUMN costUsd REAL');
});

final List<Migration> appMigrations = [_migration1to2, _migration2to3];
```

In `app_database.dart`:

```diff
- const _databaseVersion = 2;
+ const _databaseVersion = 3;
```

**Done when**: Cold-launch on a v2 backup `.db` does not throw, `PRAGMA user_version` returns `3`, legacy rows return `NULL` for the new columns.

---

### Step 9: Thread model name through `_postChatCompletion` and replace hard-coded literals

**Goal**: Remove the literal `"gpt-5.4"` from `_postChatCompletion` and `"gpt-5.4-mini"` from `preScreenForInjection`; reuse the constants from Step 1.
**Files**: `lib/network/openai_rest_client.dart`.

```diff
- Future<Map<String, dynamic>> _postChatCompletion({
-   required String context,
-   required String prompt,
-   ...
- }) async {
+ Future<Map<String, dynamic>> _postChatCompletion({
+   required String context,
+   required String prompt,
+   String model = aiModelMain,
+   ...
+ }) async {
    ...
-     data: { "model": "gpt-5.4", ... }
+     data: { "model": model, ... }
  }
```

```diff
- "model": "gpt-5.4-mini",
+ "model": aiModelPreScreen,
```

Add `import 'package:diplomka/utils/ai_model_constants.dart';` at the top.

**Done when**: No raw `"gpt-5.4*"` string literals remain in `openai_rest_client.dart`.

---

### Step 10: Instrument the five regular call sites in the pipeline

**Goal**: After each successful OpenAI call, extract `usage`, compute cost, and pass them to `AiAttemptLogService.log`.
**Files**: `lib/services/ai_feature/ai_pipeline_service.dart`, `lib/services/ai_feature/openai_service.dart`.

The pattern at every call site:

```dart
final data = await OpenaiRestClient().generateExerciseResponse(...);

final usage = OpenAiUsage.fromResponse(data);
final cost = (usage == null) ? null : AiCostCalculator.calculateCostUsd(
  model: aiModelMain,
  promptTokens: usage.promptTokens,
  completionTokens: usage.completionTokens,
  cachedTokens: usage.cachedTokens,
);

await AiAttemptLogService.to.log(
  kind: AiAttemptKind.exercise,
  status: AiAttemptStatus.success,   // or .lowConfidence / .invalidResponse
  provider: 'openai',
  model: aiModelMain,
  confidence: parsed.confidence,
  promptTokens: usage?.promptTokens,
  completionTokens: usage?.completionTokens,
  cachedTokens: usage?.cachedTokens,
  costUsd: cost,
);
```

Apply to:
1. `ai_pipeline_service.dart` ~ line 57 — meal recognition (kind: meal, modality from caller).
2. `ai_pipeline_service.dart` ~ line 157 — exercise.
3. `ai_pipeline_service.dart` ~ line 246 — goals.
4. Ask AI scope estimate (`estimateQueryScope`) — wherever it is called; kind: `queryScope`.
5. Ask AI analysis (`generateQueryResponse`) — wherever it is called; kind: `query`.
6. `openai_service.dart` if it currently logs meals on behalf of the pipeline (avoid double logging — keep the log call in exactly one layer; whichever already logs today wins, just add the new fields there).

**Done when**: Each call site logs an attempt with non-null `costUsd` on success.

> **Anti-double-logging note**: Grep for existing `AiAttemptLogService.to.log` calls before adding any. The existing layer that already logs is the one to extend; don't add a second log call.

---

### Step 11: Instrument `preScreenForInjection`

**Goal**: Log a separate `AiAttempt` row per pre-screen API call.
**Files**: `lib/network/openai_rest_client.dart` (or whichever layer wraps the pre-screen — if there is none, log directly from inside `preScreenForInjection` *after* the response is parsed).

```dart
if (response.statusCode == 200) {
  final content = response.data['choices']?[0]?['message']?['content'] ?? '';
  final isInjection = content.toString().contains('"is_injection": true')
                   || content.toString().contains('"is_injection":true');

  final usage = OpenAiUsage.fromResponse(response.data);
  final cost = (usage == null) ? null : AiCostCalculator.calculateCostUsd(
    model: aiModelPreScreen,
    promptTokens: usage.promptTokens,
    completionTokens: usage.completionTokens,
    cachedTokens: usage.cachedTokens,
  );

  // Fire-and-forget; AiAttemptLogService swallows its own errors.
  AiAttemptLogService.to.log(
    kind: AiAttemptKind.injectionScreen,
    status: isInjection ? AiAttemptStatus.injectionDetected : AiAttemptStatus.success,
    provider: 'openai',
    model: aiModelPreScreen,
    promptTokens: usage?.promptTokens,
    completionTokens: usage?.completionTokens,
    cachedTokens: usage?.cachedTokens,
    costUsd: cost,
  );

  return isInjection;
}
```

> **Layering caveat**: today `OpenaiRestClient` is a pure transport class with no dependency on services. If you'd rather not pull `AiAttemptLogService` in here, refactor: have `preScreenForInjection` return a small record `(bool isInjection, OpenAiUsage? usage)` and let the caller log. Choose whichever is cleaner in this codebase — both are acceptable. Add a one-line comment explaining the choice.

**Done when**: A meal flow involving voice input writes two `AiAttempt` rows (pre-screen first, then meal), both with non-null `costUsd`.

---

### Step 12: Add unit tests for the cost calculator

**Goal**: Lock the price table behaviour in regression tests.
**Files**: `test/utils/ai_cost_calculator_test.dart` (new).

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:diplomka/utils/ai_cost_calculator.dart';
import 'package:diplomka/utils/ai_model_constants.dart';

void main() {
  group('AiCostCalculator', () {
    test('gpt-5.4 baseline call without cache', () {
      final cost = AiCostCalculator.calculateCostUsd(
        model: aiModelMain, promptTokens: 2000, completionTokens: 600);
      expect(cost, closeTo(0.014, 1e-6));    // 2000/1M*2.5 + 600/1M*15
    });

    test('gpt-5.4 call with 800 cached tokens', () {
      final cost = AiCostCalculator.calculateCostUsd(
        model: aiModelMain, promptTokens: 2000, completionTokens: 600, cachedTokens: 800);
      // (1200/1M)*2.5 + (800/1M)*0.25 + (600/1M)*15 = 0.003 + 0.0002 + 0.009 = 0.0122
      expect(cost, closeTo(0.0122, 1e-6));
    });

    test('gpt-5.4-mini pricing', () {
      final cost = AiCostCalculator.calculateCostUsd(
        model: aiModelPreScreen, promptTokens: 1000, completionTokens: 20);
      // (1000/1M)*0.75 + (20/1M)*4.5 = 0.00075 + 0.00009 = 0.00084
      expect(cost, closeTo(0.00084, 1e-7));
    });

    test('unknown model returns null', () {
      expect(AiCostCalculator.calculateCostUsd(
        model: 'gpt-future', promptTokens: 100, completionTokens: 10), isNull);
    });

    test('cachedTokens greater than promptTokens does not produce negative input', () {
      final cost = AiCostCalculator.calculateCostUsd(
        model: aiModelMain, promptTokens: 100, completionTokens: 0, cachedTokens: 500);
      expect(cost, greaterThanOrEqualTo(0));
    });
  });
}
```

**Done when**: `flutter test test/utils/ai_cost_calculator_test.dart` is green.

---

### Step 13: Extend the CSV `--- AI Attempts ---` section

**Goal**: Append four columns to the existing per-row table.
**Files**: `lib/services/export/export_service.dart` (around line 264–289).

```diff
  rows.add([
    'Timestamp', 'kind', 'modality', 'provider', 'model',
    'status', 'confidence', 'error_message',
+   'prompt_tokens', 'completion_tokens', 'cached_tokens', 'cost_usd',
  ]);
  for (final a in aiAttempts) {
    rows.add([
      _dateTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(a.timestampMs)),
      a.kind, a.modality ?? '', a.provider ?? '', a.model ?? '',
      a.status,
      a.confidence != null ? a.confidence!.toStringAsFixed(2) : '',
      a.errorMessage ?? '',
+     a.promptTokens?.toString() ?? '',
+     a.completionTokens?.toString() ?? '',
+     a.cachedTokens?.toString() ?? '',
+     a.costUsd != null ? a.costUsd!.toStringAsFixed(6) : '',
    ]);
  }
```

Column header strings remain English in the CSV (consistent with the existing English-only header row for this section — Czech localisation is done elsewhere via `tr(LocaleKeys....)` for sections that have locale keys; the AI Attempts section already uses raw English).

**Done when**: A re-exported CSV shows four extra columns aligned with the header.

---

### Step 14: Emit the `--- AI Usage Summary ---` aggregated block (CSV)

**Goal**: Provide a quick-look total for the report period.
**Files**: `lib/services/export/export_service.dart` (after the existing AI Attempts loop, before *Section 5: Summary Statistics*, or appended to that summary — pick the location that keeps the existing ordering most natural; recommendation: append to *Summary Statistics*).

```dart
if (aiAttempts.isNotEmpty) {
  rows.add([]);
  rows.add(['--- AI Usage Summary ---']);
  int totalPrompt = 0, totalCompletion = 0, totalCached = 0;
  double totalCost = 0;
  final byModel = <String, ({int calls, int prompt, int completion, int cached, double cost})>{};
  final byKind = <String, ({int calls, double cost})>{};
  for (final a in aiAttempts) {
    totalPrompt   += a.promptTokens ?? 0;
    totalCompletion += a.completionTokens ?? 0;
    totalCached   += a.cachedTokens ?? 0;
    totalCost     += a.costUsd ?? 0;
    final m = a.model ?? 'unknown';
    final prev = byModel[m] ?? (calls: 0, prompt: 0, completion: 0, cached: 0, cost: 0.0);
    byModel[m] = (
      calls: prev.calls + 1,
      prompt: prev.prompt + (a.promptTokens ?? 0),
      completion: prev.completion + (a.completionTokens ?? 0),
      cached: prev.cached + (a.cachedTokens ?? 0),
      cost: prev.cost + (a.costUsd ?? 0),
    );
    final prevK = byKind[a.kind] ?? (calls: 0, cost: 0.0);
    byKind[a.kind] = (calls: prevK.calls + 1, cost: prevK.cost + (a.costUsd ?? 0));
  }
  rows.add(['Total AI calls', aiAttempts.length]);
  rows.add(['Total prompt tokens (input)', totalPrompt]);
  rows.add(['Of which cached (input)', totalCached]);
  rows.add(['Total completion tokens (output)', totalCompletion]);
  rows.add(['Total cost (USD)', totalCost.toStringAsFixed(6)]);
  rows.add([]);
  rows.add(['By model:', 'calls', 'prompt', 'completion', 'cached', 'cost_usd']);
  for (final e in byModel.entries) {
    rows.add([e.key, e.value.calls, e.value.prompt, e.value.completion, e.value.cached, e.value.cost.toStringAsFixed(6)]);
  }
  rows.add([]);
  rows.add(['By kind:', 'calls', 'cost_usd']);
  for (final e in byKind.entries) {
    rows.add([e.key, e.value.calls, e.value.cost.toStringAsFixed(6)]);
  }
}
```

**Done when**: A re-exported CSV contains the summary block with totals that match a manual `awk` over the per-row section.

---

### Step 15: Extend the PDF export with the same summary block

**Goal**: PDF readers (e.g. the thesis defense committee) see the totals without opening the CSV.
**Files**: `lib/services/export/export_service.dart`, inside `generatePdf` (around line 345+).

Append the block to the existing *Summary Statistics* page using the same `pw.` widgets the rest of the PDF uses; do **not** force a new page. If the content overflows naturally, let `pw.Wrap` / `pw.Partitions` (or whichever `pw.MultiPage` mechanism is already in use here) spill over to the next page. Two simple tables:

1. Grand totals (5 rows: calls, prompt tokens, cached, completion, cost USD).
2. By-model breakdown (header + N rows from the `byModel` map).

PDF cost values use `toStringAsFixed(4)` (4 decimals — human-readable). This differs intentionally from the CSV which uses 6 decimals; the PDF is for readers, the CSV for analysis.

Both labels stay English to match the *AI Attempts* PDF section's convention (consistent with CSV).

Refactor the aggregation logic from Step 14 into a private helper (`_aggregateAiUsage(List<AiAttemptEntity>)`) so CSV and PDF share it. Place the helper at the bottom of `ExportService` next to the other private helpers.

**Done when**: Generated PDF visually shows the new section appended to *Summary Statistics* (no extra forced page break). Numbers match the CSV summary for the same time range to 4 decimal places.

---

### Step 16: Smoke-test the full flow on device

**Goal**: End-to-end confirmation before declaring done.
**Files**: none — runtime test.

Procedure:
1. Build and run on the iPhone test device.
2. Log a meal via photo (triggers `generateResponse` only).
3. Log a meal via voice (triggers `preScreenForInjection` → `generateResponse`; expect 2 attempt rows).
4. Log an exercise via voice (triggers `preScreenForInjection` → `generateExerciseResponse`; expect 2 rows).
5. Ask the Ask AI a question (triggers `estimateQueryScope` then `generateQueryResponse`; expect 2 rows).
6. Trigger goal generation from profile (triggers `generateGoalsResponse`; expect 1 row).
7. Go to Profile → Export → choose a date range covering today → CSV and PDF.
8. Open the CSV. Confirm:
   - `--- AI Attempts ---` table has 12 columns and ~8 rows (6 user actions × varying API calls).
   - `cost_usd` column is populated for every row.
   - `--- AI Usage Summary ---` block exists with non-zero totals.
9. Open the PDF. Confirm the matching summary block.
10. Open SQLite via `sqlite3` on the export `.db` (or via Drift inspector / DB browser):
    ```sql
    SELECT id, kind, modality, model, promptTokens, completionTokens, cachedTokens, costUsd
    FROM AiAttempt ORDER BY id DESC LIMIT 10;
    ```
    Confirm new rows match the CSV.

**Done when**: All ten checks pass. The grand-total `cost_usd` is in the expected range (~$0.01–$0.05 for a handful of vision calls).

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| OpenAI API returns 200 but no `usage` field. | Attempt is logged with tokens `NULL` and `costUsd` `NULL`. Flow continues. | `OpenAiUsage.fromResponse` returns `null`; downstream guards `if (usage == null) ...`. |
| OpenAI API returns `prompt_tokens_details` without `cached_tokens`. | Treat cached as `0`. | Default value already in `fromResponse`. |
| Model string in the request was changed (e.g. analyst overrode for an experiment) to one not in the price table. | Tokens are logged, `costUsd` is `NULL`. CSV/PDF summary shows the unknown model row separately. | `AiCostCalculator` returns `null` for unknown models; aggregation already groups by model string. |
| `AiAttemptDao.insertAttempt` throws (DB locked, disk full). | Telemetry silently dropped. User-facing flow is unaffected. | Existing `try { } catch (_) { }` in `AiAttemptLogService.log` preserved. |
| Existing v2 database on a tester's phone is upgraded to v3 mid-study. | Schema is migrated; old rows have `NULL` tokens/cost. CSV summary handles `NULL` as `0` for sums. | Step 8 migration is additive. Aggregation code coerces `null → 0`. |
| `preScreenForInjection` fails (network 5xx, timeout). | Existing fail-open behaviour preserved (returns `false`). No attempt logged (because no usable response). | Wrap the new log call inside the `if (response.statusCode == 200)` branch. Do not log on failure to avoid noise; the meal-level error attempt already captures user-visible outcomes. |
| Same meal triggers the AI twice via "Improve with AI" rerun. | Two distinct `AiAttempt` rows with `modality='fix_with_ai_rerun'` for the second one, each with its own cost. | Already the case with the existing log path; nothing new to do. |
| Gemini provider is selected. | If `usage` is absent (it usually is for Gemini), tokens/cost are `NULL`. Aggregation still counts the call. | `OpenAiUsage.fromResponse(null)` returns `null`. No code branch for Gemini needed. |
| Empty `aiAttempts` list at export time. | Summary block is suppressed entirely (matches existing per-row block behaviour). | Wrap the summary aggregator in `if (aiAttempts.isNotEmpty)`. |
| `promptTokens < cachedTokens` (theoretically impossible but defensive). | `nonCached` clamps to 0; cost calculation is non-negative. | `AiCostCalculator` uses `.clamp(0, …)`. |

---

## 6. SECURITY CONSIDERATIONS

- **Input validation**: Token integers from API responses are coerced via `(x as num? ?? 0).toInt()`. No SQL injection risk — values pass through Floor's parameterised inserts.
- **Auth/Access control**: No change. API key handling stays as-is (`.env` via `flutter_dotenv`).
- **Sensitive data**: Tokens and cost are numeric only. No prompt content or user text is added to the new fields. The existing `RESEARCH-ONLY` banner on the entity already documents that the whole table is dropped before production.
- **Logging**: The new fields ride on top of the existing research-only telemetry. Do **not** add `print()` of usage to release builds. If diagnostic prints are added during development, gate them on `kDebugMode`.

---

## 7. ASSUMPTIONS

Inferred from incomplete input — verify these are correct:

1. **OpenAI returns `usage` for every Chat Completions response of the models in use.** True for `gpt-4o`/`gpt-4.1` families on the OpenAI API as of late 2025; the thesis uses `gpt-5.4`/`5.5`/`5.4-mini` as forward-looking placeholders for the same API family. If a future model changes the response shape, `OpenAiUsage.fromResponse` returns `null` and the columns stay `NULL` — graceful degradation.
2. **`cached_tokens` is a subset of `prompt_tokens` (not in addition to).** This is how OpenAI documents it. Cost is split: `(prompt - cached) × inputRate + cached × cachedRate + completion × outputRate`.
3. **The analyst wants raw per-call numbers plus a grand total — no per-day aggregation in app.** Stated explicitly in the brief ("agregaci provedu já z CSV mimo aplikaci").
4. **A schema migration is acceptable** (versus reinstalling fresh on testers). Implied by "ship bez migrací" reference in CLAUDE.md being already broken — v1 → v2 migration already exists in `migrations.dart`. Continuing the additive pattern is the lowest-risk choice.
5. **CSV headers stay in English for the *AI Attempts* and *AI Usage Summary* sections.** The existing AI Attempts header row is hardcoded English; following the same convention avoids new locale keys for research-only output.
6. **`AiAttemptLogService.to` is accessible from inside `OpenaiRestClient`** (if Step 11 is implemented inline rather than refactored). Verified — it's a GetX service registered in `lib/locator.dart`.
7. **The Ask AI scope-estimate and analysis calls are not currently logged.** Inferred from the absence of `query` / `query_scope` kinds in `AiAttemptKind`. Adding them is a small bonus.
8. **The 1 USD ≈ 22 CZK conversion** (used in the previous chat) is acceptable as off-app conversion. The plan stores USD only.

> Open questions live in Section 12.

---

## 8. QUICK REFERENCE

### Files to Modify
- `lib/database/entities/ai_attempt_entity.dart` — add 4 nullable fields.
- `lib/database/migrations.dart` — add `_migration2to3` and append to `appMigrations`.
- `lib/database/app_database.dart` — bump `_databaseVersion` to `3`.
- `lib/services/ai_feature/ai_attempt_log_service.dart` — extend enums + `log()` signature.
- `lib/services/ai_feature/ai_pipeline_service.dart` — instrument all OpenAI calls.
- `lib/services/ai_feature/openai_service.dart` — pass usage through if it logs.
- `lib/network/openai_rest_client.dart` — replace hardcoded model strings with constants; instrument `preScreenForInjection` (or refactor to return usage).
- `lib/services/export/export_service.dart` — add 4 CSV columns; add summary block (CSV + PDF).

### Files to Create
- `lib/utils/ai_model_constants.dart` — central model name constants.
- `lib/utils/ai_cost_calculator.dart` — pure-Dart USD calculator with the price table.
- `lib/utils/openai_usage.dart` — DTO + static `fromResponse` helper.
- `test/utils/ai_cost_calculator_test.dart` — unit tests for the pricing math.

### Dependencies
- No new packages.

### Commands
```bash
# Regenerate Floor schema after entity change
flutter pub run build_runner build --delete-conflicting-outputs

# Run the new unit tests
flutter test test/utils/ai_cost_calculator_test.dart

# Static analysis
flutter analyze
```

---

## 11. CHANGELOG

| Date | Change |
|------|--------|
| 2026-06-16 | Initial plan created. |
| 2026-06-16 | All four open questions resolved (Ask AI: two rows; PDF summary: appended to Summary Statistics; cost precision: 6 dec CSV / 4 dec PDF; no backfill of v2 rows). All five follow-up suggestions accepted as deferred work. Section 12.2 renamed *Resolved Decisions*; 12.3 marked as accepted-deferred. |

---

## 12. OPEN QUESTIONS & ALTERNATIVE APPROACHES

> Always include. This is the last section the reader sees — it surfaces what is still uncertain and what other paths exist.

### 12.1 Alternative Approaches Considered

| Approach | Pros | Cons | Selected? |
|----------|------|------|-----------|
| **A. Per-row logging via existing `AiAttemptLogService`, extract `usage` at the pipeline layer, store cost as `REAL` on the existing `AiAttempt` row.** | Reuses the existing telemetry pipeline 1:1. No new tables. Single migration step. CSV/PDF extensions trivial. | Pipeline has to know which model was called (handled by the new shared constants). | ✅ |
| B. New dedicated `AiCallCost` table with FK to `AiAttempt`. | Cleaner normalisation if future cost fields are added (separate breakdowns per token type, prompt cache details, audio tokens). | Extra table, extra DAO, extra join in export. Overkill for four scalar fields. | — |
| C. Dio response interceptor that automatically writes a cost row for any OpenAI hit, no pipeline changes. | Truly cross-cutting; future call sites instrumented for free. | Loses context (kind, modality, confidence) that lives in the pipeline layer. Would either need a thread-local context (fragile in async Dart) or a parallel "cost-only" table separate from `AiAttempt` — splitting the very data the analyst wants to join. | — |
| D. No DB change; print tokens to console and let the user copy. | Zero code surface. | Unusable for an actual study; thesis opponent's question demands reproducible data. | — |

**Why the selected approach won**: Approach A minimises new surface area, reuses the established `AiAttempt` schema and its export pipeline, and keeps the model-specific cost computation in exactly one place (`AiCostCalculator`). The analyst gets the data they need without a normalised schema redesign that the thesis timeline doesn't justify.

### 12.2 Resolved Decisions

> Originally open questions; resolved by author on 2026-06-16. Recorded here so an implementer (or future Claude) does not re-litigate them.

- [x] **Ask AI calls are logged as TWO separate `AiAttempt` rows.** One for `estimateQueryScope` (kind `queryScope`) and one for `generateQueryResponse` (kind `query`). Each is a billable API call and must appear separately. Already reflected in Step 5 (enum values) and Step 10 (instrumentation list items 4 and 5).
- [x] **PDF *AI Usage Summary* is appended to the existing *Summary Statistics* page**, with automatic overflow to a new page only if needed (via `pw.Wrap` / `pw.Partitions`). Do not force a new page. Step 15 should be implemented accordingly.
- [x] **`costUsd` decimal precision: 6 decimals in CSV, 4 decimals in PDF.** Per-row CSV uses `toStringAsFixed(6)` so a single mini-call at $0.000084 stays legible; PDF summary uses `toStringAsFixed(4)` for human readability. Step 13 (CSV) already uses 6 decimals; Step 15 (PDF) should use 4.
- [x] **No retroactive cost backfill for v2 `AiAttempt` rows.** Legacy rows stay `NULL` for the four new columns. An estimated value would silently bias the long-term-study totals.

### 12.3 Suggestions & Follow-ups (accepted, deferred)

> All five suggestions were acknowledged by the author on 2026-06-16 and accepted as future work. They remain out of scope for this plan to keep its size bounded; track them as separate tasks after the cost-logging plan is implemented.

- [ ] Add a `cachedTokenRatio` derived field (`cached / prompt`) to the PDF summary — useful signal for evaluating future prompt-caching work.
- [ ] Add a small DAO helper `SELECT SUM(costUsd) FROM AiAttempt WHERE timestampMs >= ?` for a possible in-app debug "research mode" screen.
- [ ] After the next long-term study completes, **drop the entire `AiAttempt` table** per `RESEARCH_ONLY.md` before any production release. The new cost columns store quasi-billing data that must not ship to consumers.
- [ ] If OpenAI introduces a new model class mid-study (e.g. `gpt-5.6`), add the row to `_table` in `AiCostCalculator` and hotfix. Legacy rows with the unknown model still carry correct token counts and can be re-priced retroactively from CSV.
- [ ] Remove or gate behind `kDebugMode` the existing `print(response.data.toString())` in `_postChatCompletion` (line 219 of `lib/network/openai_rest_client.dart`). It currently dumps the full response — including the new `usage` block — to logcat even in release builds.
