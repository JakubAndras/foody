# FR-31: Natural-Language Queries (Ask AI) — Implementation Plan

## Goal
Replace hardcoded mock responses in the Ask AI feature with real OpenAI GPT-4o calls that analyze the user's actual nutrition/exercise history and answer natural-language questions.

## Current State
- **UI is 100% built**: `AskAiScreen` (entry), `AskAiResponseScreen` (result display), all widgets (prompt card, response card, summary card, calendar grid)
- **All responses are hardcoded**: `_AskAiVariantData.fromVariant()` returns 3 static mock datasets
- **No text input**: `AskAiPromptCard` shows placeholder text but has no `TextField`
- **No controller**: No state management for the query flow
- **No AI prompt**: `prompt.dart` has meal/exercise prompts but no query prompt

## Architecture Decision

**Approach: Single free-form AI call with structured JSON response**

The AI receives:
1. The user's question
2. A summary of their nutrition data (aggregated day records for relevant period)
3. User profile context (diet type, goals)

The AI returns a structured JSON response that maps directly to the existing UI structure (response text + summary metric + affected days + insight type).

This avoids complex local query parsing — the LLM handles intent extraction, date range inference, and data analysis in one call.

## Implementation Steps

### Step 1: Add query prompt to `lib/utils/prompt.dart`

Add a new `analyzeQuery` prompt that instructs GPT-4o to:
- Understand the user's nutrition question
- Analyze the provided day records data
- Return structured JSON matching the UI's data needs:
  ```json
  {
    "response_text": "string — narrative answer to the question",
    "insight_type": "violations | achieved | tracked",
    "summary_value": "int — key metric number",
    "summary_label": "string — what the number means",
    "affected_days": [{"year": 2026, "month": 1, "day": 5}, ...],
    "period_label": "string — e.g. 'January 2026' or 'Last 7 days'"
  }
  ```

### Step 2: Add `generateQueryResponse()` to `OpenaiRestClient`

New method on `openai_rest_client.dart`:
- System context: "You are a nutrition data analyst assistant."
- Takes: query text + nutrition data context string + user profile context
- No images needed
- Returns raw API response (same pattern as `generateExerciseResponse`)

### Step 3: Create response model `AskAiQueryResponse`

New file: `lib/model/ask_ai_query_response.dart`
- Fields: `responseText`, `insightType`, `summaryValue`, `summaryLabel`, `affectedDays` (List of DateTime), `periodLabel`
- Factory `fromJson()` to parse AI response
- Method to map `insightType` string to gradient/icon (violations→danger, achieved→success, tracked→warning)

### Step 4: Create `AskAiController` (GetxController)

New file: `lib/controller/ask_ai_controller.dart`
- **State:**
  - `query` (RxString) — current user input
  - `isLoading` (RxBool)
  - `response` (Rxn<AskAiQueryResponse>)
  - `errorMessage` (RxnString)
- **Methods:**
  - `submitQuery(String query)`:
    1. Set loading state
    2. Fetch day records from `DayRecordRepository.getAllDayRecords()`
    3. Build nutrition context summary (aggregate last 30-90 days of data into compact text/JSON)
    4. Build user profile context from `SessionManager`
    5. Call `OpenaiRestClient.generateQueryResponse()`
    6. Parse response JSON → `AskAiQueryResponse`
    7. Update state (response or error)
  - `_buildNutritionContext(List<DayRecord> records)`:
    - Compact JSON array of daily summaries: `{date, calories, protein, carbs, fat, meals: [{name, calories, ingredients: [name]}], exercises: [{name, caloriesBurned}], goals: {cal, prot, carbs, fat}}`
    - Limit to last 90 days to stay within token limits
    - If data is very large, summarize further (weekly aggregates for older data)
  - `_buildUserProfileContext()`:
    - Diet type, restrictions, weight, height, age, goal

### Step 5: Register controller in `lib/locator.dart`

```dart
Get.lazyPut<AskAiController>(() => AskAiController(), fenix: true);
```

### Step 6: Update `AskAiPromptCard` widget

In `ask_ai_widgets.dart`:
- Replace static placeholder `Text` with actual `TextField`
- Accept `TextEditingController` and `onAsk` callback with query text
- Clear button clears the text field
- "Ask AI" button calls `onAsk(text)`

### Step 7: Update `AskAiScreen`

In `ask_ai_screen.dart`:
- Initialize `AskAiController` via `Get.find()`
- Wire `AskAiPromptCard` to controller's `submitQuery()`
- Example questions populate the text field and auto-submit
- On successful response → navigate to updated `AskAiResponseScreen` with real data
- Show loading indicator during API call
- Show error snackbar on failure

### Step 8: Update `AskAiResponseScreen`

In `ask_ai_response_screen.dart`:
- Remove `AskAiResponseVariant` enum and all variant-specific wrapper screens
- Accept `AskAiQueryResponse` as parameter (passed from controller)
- Map `insightType` to icon/gradient (reuse existing gradient definitions)
- Display real `responseText`, `summaryValue`, `summaryLabel`, `affectedDays`, `periodLabel`
- Calendar card shows actual affected month/days from response
- Keep Share functionality (now uses real data)
- Keep prompt card at top showing the original query (read-only)

## Files to Create
1. `lib/model/ask_ai_query_response.dart` — response model
2. `lib/controller/ask_ai_controller.dart` — query state management

## Files to Modify
1. `lib/utils/prompt.dart` — add `analyzeQuery` prompt
2. `lib/network/openai_rest_client.dart` — add `generateQueryResponse()`
3. `lib/screens/profile/ask_ai/ask_ai_widgets.dart` — make prompt card functional
4. `lib/screens/profile/ask_ai/ask_ai_screen.dart` — wire to controller
5. `lib/screens/profile/ask_ai/ask_ai_response_screen.dart` — accept dynamic data
6. `lib/locator.dart` — register `AskAiController`

## Data Flow
```
User types question → AskAiController.submitQuery()
  → DayRecordRepository.getAllDayRecords() → build context JSON
  → SessionManager → build profile context
  → OpenaiRestClient.generateQueryResponse(query, nutritionCtx, profileCtx)
  → GPT-4o → structured JSON response
  → AskAiQueryResponse.fromJson()
  → Navigate to AskAiResponseScreen(response)
  → UI renders: response text + summary card + calendar
```

## Token Budget Considerations
- Each day record compact summary ≈ 100-200 tokens
- 90 days ≈ 9,000-18,000 tokens context
- GPT-4o supports 128K context → plenty of room
- For users with many meals, cap at most recent 60 days detailed + weekly summary for older data

## Edge Cases
- **No data**: Show "You don't have enough nutrition data logged yet" message
- **API error**: Show error in snackbar, keep user on input screen
- **Empty query**: Disable "Ask AI" button when text is empty
- **Very long query**: Cap at 500 characters
- **AI returns unexpected format**: Fallback to showing raw response text only (no summary/calendar)
