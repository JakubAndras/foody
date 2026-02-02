# Implementation Plan

## Current State Snapshot
- App shell + navigation: Bottom nav + quick actions are wired (`lib/screens/main_screen.dart`, `lib/widgets/bottom_nav_bar.dart`, `lib/widgets/quick_action_sheet.dart`). Onboarding screens exist but are not used at app start (`lib/screens/onboarding/`).
- Core data layer: Floor DB is set up with DayRecord/Meal/Ingredient entities and DAOs, but the model is inconsistent (DayRecord stores a list of meals while Meal/Ingredient are also entities; DAOs reference missing foreign keys). The app currently uses DayRecord + embedded Meal list via `DayRecordController` (`lib/controller/day_record_controller.dart`, `lib/model/day_record.dart`, `lib/model/meal.dart`).
- Manual meal editing: Edit meal/ingredient screens exist and can save meals into a DayRecord, but use `DateTime.now()` instead of selected date and have UI/data issues (e.g., ingredient list shows meal totals) (`lib/screens/edit_meal_screen.dart`, `lib/screens/edit_ingredient_screen.dart`).
- Dashboard: Daily summary, macros, streak display, and date picker exist; exercise/rollover values are static placeholders (`lib/screens/dashboard_screen.dart`, `lib/widgets/calories_card.dart`, `lib/widgets/macros_row.dart`).
- AI/photo flow: OpenAI service client exists with prompt parsing; Gemini client is stub/likely wrong endpoint; API keys are hard-coded. Dashboard photo analysis calls OpenAI directly; scan preview “Analyze” is stubbed (no real AI). (`lib/services/ai_feature/`, `lib/network/`, `lib/utils/prompt.dart`, `lib/screens/scan/`).
- Scan/Barcode/Voice/Exercise UIs: Camera UI works (no barcode decoding), scan preview analyze is stubbed, voice recording works but transcription and analysis are stubbed, exercise log is UI-only with local state (`lib/screens/scan/`, `lib/screens/logs/voice_log/`, `lib/screens/logs/exercise_log/`).
- Profile/Ask AI/Export/Notifications: UI-only; no persistence or backend logic (`lib/screens/profile/`).

## Foundational Decisions (blockers to many FRs)
1. Data model approach
   - Decision: **Normalized Meal/Ingredient tables with DayRecord as an aggregate view.**
   - DayRecord entities store goals/date; meals and ingredients are stored in their own tables with FK relations.
   - The repository builds `DayRecord` + `Meal` + `Ingredient` aggregates for UI.
   - Future work: keep all CRUD paths going through the repository to avoid embedded list drift.
2. AI provider + secrets
   - OpenAI is the primary provider.
   - Keep AI logic provider-agnostic so switching to Gemini/other models is a quick config change.
   - Remove hard-coded keys and define secure key storage (env or user-provided key).
3. Sync/auth
   - No online sync/auth for now; use local sqflite only.
   - Keep architecture ready for optional cloud sync later (but out of current scope).
4. Barcode + OFF integration
   - Select scanning library and Open Food Facts API integration strategy.
5. Notifications stack
   - Pick a local notification package and scheduling strategy.

## Implementation Plan by Area

### 1) Navigation and App Flow (cross-cutting)
- Add a startup gate that decides between onboarding and main app (e.g., `SharedPreferences` flag). Touchpoints: `lib/main.dart`, `lib/app.dart`, `lib/services/shared_preferences_manager.dart`, `lib/screens/onboarding/onboarding_flow_screen.dart`.
- Centralize navigation routes (GetX named routes or a router) so flows can be deep-linked to edit/confirm screens.
- Wire missing transitions: scan -> analyze -> fix result -> edit meal -> save; select meal -> edit meal -> save; voice log -> transcript -> confirm -> save; exercise log -> add -> save.

### 2) Data Layer and Record Creation (cross-cutting)
- Align DB schema with chosen model (see “Foundational Decisions”).
  - If embedding: remove unused Meal/Ingredient DAOs or stop treating Meal/Ingredient as standalone entities.
  - If normalizing: add `dayRecordId` to Meal and `mealId` to Ingredient; update DAOs and migrations.
- Introduce a repository layer for CRUD to keep controllers clean and allow future sync if ever needed.
- Fix record creation to use the selected date/time, not `DateTime.now()` everywhere (e.g., `lib/screens/edit_meal_screen.dart`, `lib/controller/dashboard_controller.dart`).
- Add mealtime metadata, portion units, and user edits history to the model to support multiple FRs.
- Add update/delete operations across screens and ensure DayRecord totals recalc consistently.

### 3) AI Recognition Pipeline (cross-cutting)
- Replace hard-coded API keys and unify provider selection via `AiServiceManager` (`lib/services/ai_feature/ai_service_manager.dart`).
- Build a single AI pipeline that can:
  - Accept photo or text input.
  - Return structured JSON (meal, ingredients, quantities, confidence).
  - Provide error types (AI uncertainty vs technical failure).
- Add a persistence layer for AI proposals and user edits (needed for FR-34).
- Integrate AI results into EditMeal flow for confirmation and manual fixes.

---

## Functional Requirements (FR) Plan

### FR-01 Manual meal entry (no AI)
Status: Partial (EditMeal/EditIngredient UI exists; persistence uses selected date incorrectly)
Plan:
- Wire manual entry from “Log Meal” and “Manual” actions to EditMeal with selected date.
- Ensure ingredient list displays ingredient data (not meal totals) and saves correctly.
- Add validation and persistence tests for meal creation/edit.
Touchpoints: `lib/screens/edit_meal_screen.dart`, `lib/screens/edit_ingredient_screen.dart`, `lib/screens/log_meal/select_meal/select_meal_screen.dart`, `lib/controller/day_record_controller.dart`.

### FR-02 Daily overview (“daily card”)
Status: Partial (dashboard shows totals but exercise/rollover are placeholders)
Plan:
- Ensure totals are computed from actual saved records for selected date.
- Add mealtime grouping + accurate meal list in dashboard card.
- Integrate exercise/rollover data once models exist.
Touchpoints: `lib/screens/dashboard_screen.dart`, `lib/widgets/calories_card.dart`, `lib/widgets/recently_uploaded_card.dart`, `lib/controller/dashboard_controller.dart`.

### FR-03 Target goals
Status: Not implemented (UI-only)
Plan:
- Add persistent goal fields (calories/macros) to user profile or DayRecord defaults.
- Implement Edit Goals screen with validation and save.
- Recompute dashboard/summary using updated goals.
Touchpoints: `lib/screens/profile/subscreens/edit_nutrition_goals_screen.dart`, `lib/model/day_record.dart`, `lib/services/shared_preferences_manager.dart` (or profile DB).

### FR-04 User profile management
Status: Not implemented (UI-only)
Plan:
- Create UserProfile model (weight, height, DOB, gender, goals, activity).
- Add CRUD with persistence (local DB only for now).
- Wire onboarding inputs to profile creation.
Touchpoints: `lib/screens/onboarding/`, `lib/screens/profile/subscreens/personal_details_screen.dart`, new model/DAO.

### FR-05 Data control and deletion
Status: Partial (meal deletion exists; account deletion not implemented)
Plan:
- Add delete actions for meals, day records, and full account data wipe.
- If future cloud sync is added, perform remote delete and local cleanup.
- Add confirmations and undo/restore where appropriate.
Touchpoints: `lib/screens/edit_meal_screen.dart`, `lib/controller/day_record_controller.dart`, new profile/account service.

### FR-06 Photo-based meal entry
Status: Partial (camera flow exists; AI wired only in dashboard picker)
Plan:
- Connect Scan Camera -> Preview -> AI analysis -> EditMeal flow.
- Ensure permissions and error handling for camera/photo.
- Save the captured photo reference with the meal (file path or blob).
Touchpoints: `lib/screens/scan/scan_camera/scan_camera_screen.dart`, `lib/screens/scan/scan_preview/scan_preview_screen.dart`, `lib/services/ai_feature/`.

### FR-07 AI suggestions for items and portions
Status: Partial (AI response parsed into ingredients; no portion logic)
Plan:
- Update prompt + parsing to include portion/quantity units.
- Map AI quantities into meal/ingredient model and UI.
- Provide user adjustment controls with recalculated nutrition.
Touchpoints: `lib/utils/prompt.dart`, `lib/model/ai_response.dart`, `lib/screens/edit_meal_screen.dart`.

### FR-08 Uncertainty indication
Status: Not implemented
Plan:
- Display confidence at meal and ingredient level in AI-based flows.
- Add a settings toggle to show/hide uncertainty indicators.
Touchpoints: `lib/model/ai_response.dart`, `lib/screens/meals/meal_detail/meal_detail_screen.dart`, settings screen.

### FR-09 Explain AI limits
Status: Partial (scan onboarding has tips; no dedicated help)
Plan:
- Add an “AI limitations” help sheet accessible from scan and recognition screens.
- Include examples and best practices for better inputs.
Touchpoints: `lib/screens/scan/scan_onboarding/scan_onboarding_screen.dart`, `lib/screens/scan/scan_preview/scan_preview_screen.dart`.

### FR-10 Distinguish “AI error” vs “app error”
Status: Not implemented
Plan:
- Define error types in AI pipeline (network, parsing, model low confidence).
- Show different UI flows: retry vs manual entry suggestion.
Touchpoints: `lib/services/ai_feature/`, `lib/screens/scan/scan_preview/scan_preview_screen.dart`.

### FR-11 Text fallback after photo failure
Status: Not implemented
Plan:
- Add text-only analysis input when image analysis fails.
- Reuse the same AI pipeline and EditMeal confirmation.
Touchpoints: `lib/screens/scan/scan_preview/scan_preview_screen.dart`, `lib/services/ai_feature/`.

### FR-12 Import photo from gallery
Status: Partial (gallery pick exists)
Plan:
- Wire gallery selection into analysis pipeline and confirmation flow.
- Persist photo reference with meal.
Touchpoints: `lib/screens/scan/scan_camera/scan_camera_screen.dart`, `lib/controller/dashboard_controller.dart`.

### FR-13 Re-run recognition from edit screen
Status: Not implemented
Plan:
- Add a “Re-analyze” button in EditMeal (with original photo).
- Replace existing AI proposal while preserving user edits on request.
Touchpoints: `lib/screens/edit_meal_screen.dart`, AI pipeline.

### FR-14 Entry without photo
Status: Partial (manual entry exists)
Plan:
- Ensure “no-photo” meals can be created, edited, and shown across dashboard/history.
- Add optional description field for later AI re-run.
Touchpoints: `lib/screens/edit_meal_screen.dart`, data model.

### FR-15 Quantity units: grams and pieces
Status: Not implemented
Plan:
- Add unit system to Ingredient (g, piece, ml, etc.) with conversion rules.
- Update EditIngredient UI to select units and recompute nutrition.
Touchpoints: `lib/model/ingredient.dart`, `lib/screens/edit_ingredient_screen.dart`.

### FR-16 Portion presets with estimated grams
Status: Not implemented
Plan:
- Add presets (small/medium/large, serving) to EditMeal/Ingredient.
- Store per-item default gram estimates for presets.
Touchpoints: `lib/screens/edit_meal_screen.dart`, new preset data.

### FR-17 Barcode scanner
Status: Not implemented (UI only)
Plan:
- Integrate barcode scanning library (e.g., `mobile_scanner`).
- Call Open Food Facts API and map to Meal/Ingredient.
- Add error/empty handling for unknown barcodes.
Touchpoints: `lib/screens/scan/scan_camera/scan_camera_screen.dart`, new OFF client service.

### FR-18 Favorites
Status: Not implemented (mock only)
Plan:
- Add “favorite” flag to Meal/Ingredient model.
- Update Select Meal UI to toggle and filter favorites.
Touchpoints: `lib/screens/log_meal/select_meal/select_meal_screen.dart`, data model.

### FR-19 Duplicate previous record
Status: Not implemented
Plan:
- Add duplicate action from meal detail/history list.
- Allow selecting target date/mealtime before saving.
Touchpoints: `lib/screens/meals/meal_detail/meal_detail_screen.dart`, DayRecordController.

### FR-20 Name autocomplete from history
Status: Not implemented
Plan:
- Create a local history index of meal names and ingredients.
- Provide typeahead suggestions in manual entry.
Touchpoints: `lib/screens/edit_meal_screen.dart`, repository layer.

### FR-21 Plan vs. actual for cooking
Status: Not implemented
Plan:
- Add “planned” vs “actual” quantities per ingredient.
- Provide quick switch between planned/actual totals in EditMeal.
Touchpoints: model updates + EditMeal UI.

### FR-22 Dietary restrictions and intolerances
Status: Not implemented
Plan:
- Add restriction model to user profile (allergens, diet types).
- Tag ingredients with allergen info where possible (OFF or manual tags).
- Surface warnings in meal detail.
Touchpoints: profile screens, meal detail, AI parsing.

### FR-23 Violations in calendar
Status: Not implemented
Plan:
- Add calendar view that highlights days with restriction violations.
- Compute violations from meal ingredients + user restrictions.
Touchpoints: new calendar screen, DayRecord aggregation.

### FR-24 Intake vs. expenditure in one view
Status: Not implemented (placeholders only)
Plan:
- Add ExerciseRecord model and link to DayRecord totals.
- Update calories card to show intake, burn, and balance.
Touchpoints: `lib/widgets/calories_card.dart`, exercise log data.

### FR-25 Expenditure integration settings
Status: Not implemented
Plan:
- Add profile settings to include/exclude exercise calories in daily goal.
- Recompute dashboard totals when toggled.
Touchpoints: settings UI + SessionManager or profile data.

### FR-26 Weekly and monthly overviews
Status: Not implemented (progress screen is static)
Plan:
- Add aggregation queries for weekly/monthly stats.
- Implement charts/trend views with real data.
Touchpoints: `lib/screens/progress_screen.dart`, DayRecord aggregation.

### FR-27 Alerts on limit exceedance
Status: Not implemented
Plan:
- Trigger alerts when daily calories/macros exceed goals.
- Surface in dashboard and via notifications if enabled.
Touchpoints: Dashboard controller + notifications.

### FR-28 Data export (CSV)
Status: Not implemented (UI only)
Plan:
- Implement CSV export for meals + daily summaries.
- Add share/save flow and file permissions.
Touchpoints: `lib/screens/profile/subscreens/export_pdf_*`, new export service.

### FR-29 Offline tolerance
Status: Not implemented
Plan:
- Add offline detection and queueing for AI/barcode requests.
- Allow saving draft meals with pending analysis.
Touchpoints: `connectivity_plus`, repository layer, scan/AI flows.

### FR-30 Cloud storage and sync
Status: Deferred (out of scope for now)
Plan:
- Keep data model and repository interfaces clean to allow optional sync in the future.
- No online auth or cloud DB implementation in current scope.
Touchpoints: repository layer (future-only).

### FR-31 Natural-language queries over data
Status: Not implemented (Ask AI is static)
Plan:
- Build query pipeline: extract intent -> run local aggregations -> optionally call LLM.
- Integrate Ask AI UI with real results and error handling.
Touchpoints: `lib/screens/profile/ask_ai/`, AI services.

### FR-32 Monthly motivational summary
Status: Not implemented
Plan:
- Create monthly summary generator (adherence, calories, streaks).
- Deliver via in-app card and/or notification/email.
Touchpoints: new summary service + notifications.

### FR-33 Gentle, configurable notifications
Status: Not implemented (UI only)
Plan:
- Add notification scheduling with user-configurable times.
- Provide quiet hours and per-type toggles.
Touchpoints: `lib/screens/profile/subscreens/tracking_reminders_screen.dart`, notifications service.

### FR-34 Continuous AI accuracy evaluation
Status: Not implemented
Plan:
- Store AI proposal vs user edits for each meal.
- Compute metrics (match rate, delta) and expose a report.
Touchpoints: AI pipeline, data model, new analytics screen.

### FR-35 Show/hide advanced features
Status: Not implemented
Plan:
- Add settings toggles for advanced features (AI uncertainty, analytics, etc.).
- Gate UI sections based on settings.
Touchpoints: settings screens + feature flags in UI.

---

## Suggested Milestone Order
1) Data model alignment + navigation gating (onboarding -> main) + record creation fixes.
2) Core logging UX: manual entry, edit flows, daily overview accuracy.
3) AI scan pipeline (photo + text + error handling) + uncertainty UX.
4) Barcode + OFF integration + favorites + duplication + autocomplete.
5) Exercise logging + intake vs expenditure + weekly/monthly analytics.
6) Export + offline queue + notifications.
7) AI queries + monthly summaries + accuracy evaluation.

## Notes / Known Risks
- Current DB schema conflicts (embedded lists + standalone entities) will cause bugs unless resolved.
- Hard-coded API key must be removed before any real usage.
- Many screens are UI-only; wiring data will require additional controllers/services.

---

## Changed Files (Milestone 1)
- .env
- .env.example
- .gitignore
- lib/app.dart
- lib/controller/dashboard_controller.dart
- lib/controller/day_record_controller.dart
- lib/database/app_database.dart
- lib/database/app_database.g.dart
- lib/database/dao/day_record_dao.dart
- lib/database/dao/ingredient_dao.dart
- lib/database/dao/meal_dao.dart
- lib/database/entities/day_record_entity.dart
- lib/database/entities/ingredient_entity.dart
- lib/database/entities/meal_entity.dart
- lib/database/migrations.dart
- lib/locator.dart
- lib/main.dart
- lib/model/day_record.dart
- lib/model/ingredient.dart
- lib/model/meal.dart
- lib/model/type_converters.dart
- lib/network/gemini_rest_client.dart
- lib/network/openai_rest_client.dart
- lib/screens/edit_ingredient_screen.dart
- lib/screens/edit_meal_screen.dart
- lib/screens/log_meal/select_meal/select_meal_screen.dart
- lib/screens/onboarding/onboarding_flow_screen.dart
- lib/services/day_record_repository.dart
- lib/services/session_manager.dart
- lib/services/shared_preferences_manager.dart
- pubspec.lock
- pubspec.yaml

---

## Changed Files (Milestone 2)
- lib/controller/dashboard_controller.dart
- lib/locator.dart
- lib/network/gemini_rest_client.dart
- lib/network/openai_rest_client.dart
- lib/screens/scan/scan_preview/scan_preview_screen.dart
- lib/services/ai_feature/ai_pipeline_service.dart
- lib/services/ai_feature/ai_service.dart
- lib/services/ai_feature/ai_service_manager.dart
- lib/services/ai_feature/gemini_service.dart
- lib/services/ai_feature/openai_service.dart

## Changed Files (Fix Result / Re-analyze Wiring)
- lib/controller/dashboard_controller.dart
- lib/database/app_database.dart
- lib/database/app_database.g.dart
- lib/database/entities/meal_entity.dart
- lib/database/migrations.dart
- lib/locator.dart
- lib/model/meal.dart
- lib/screens/edit_meal_screen.dart
- lib/screens/meals/fix_result/fix_result_screen.dart
- lib/screens/scan/scan_preview/scan_preview_screen.dart
- lib/services/day_record_repository.dart

## Changed Files (Onboarding Once)
- lib/screens/main_screen.dart
- lib/screens/log_meal/select_meal/select_meal_screen.dart
- lib/screens/scan/scan_onboarding/scan_onboarding_screen.dart
- lib/services/session_manager.dart
- lib/services/shared_preferences_manager.dart
