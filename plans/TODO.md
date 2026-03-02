# Foody - Feature TODO List

> Generated 2026-03-01 by analyzing the full codebase against thesis functional requirements (FR-01–FR-35) and scanning for mock data, stub implementations, empty handlers, and UI shells without backend logic.

---

## Legend

| Symbol | Meaning |
|--------|---------|
| :x: | Not implemented at all |
| :warning: | Partially implemented (has gaps) |
| :white_check_mark: | Done (listed for context only) |

---

## 1. Functional Requirements — Not Implemented

### FR-16: Portion Presets :x:
**Current state:** Four hardcoded labels in `edit_meal_screen.dart:63-68` ("portion 300g", "small portion 150g", "100g", "1g") — display only, not interactive.
**What's needed:**
- Database table for user-defined portion presets (per food type)
- Standard portion lookup (e.g. "1 medium apple = 182g")
- UI to create/edit/delete custom presets
- Quick-apply preset in ingredient edit screen

### FR-19: Duplicate Previous Meal Record :x:
**Current state:** Exercise duplication works (`exercise_log_home_screen.dart:34-65`). No meal duplication exists.
**What's needed:**
- "Duplicate to today" action on meal cards (dashboard + meal detail + select meal)
- Clone meal + all ingredients with new timestamp
- Date picker option for target day

### FR-20: Name Autocomplete from History :white_check_mark:
**Done:** Autocomplete suggestions implemented in `SelectMealScreen`. As the user types in the search bar, a floating dropdown shows up to 5 frequency-weighted suggestions derived from distinct meal and ingredient names in the user's history. Suggestions respect the active tab (Meals/Ingredients/All/Favorites). Tapping a suggestion fills the search field and filters results. Uses `FocusNode` to show/hide suggestions on focus changes.

### FR-21: Plan vs Actual for Cooking :x:
**Current state:** `RecipeService` has 8 hardcoded Czech recipes (`recipe_service.dart:7-89`) with placeholder images. No UI references the service.
**What's needed:**
- Meal planning interface (plan meals for upcoming days)
- Distinguish "planned" vs "logged" meals in DB
- Recipe → meal conversion flow
- Shopping list generation from planned meals

### FR-23: Dietary Violations in Calendar :x:
**Current state:** Calendar rings show calorie progress only (`calendar_day_ring_service.dart`). No violation tracking.
**What's needed:**
- Cross-reference logged ingredients against user's dietary restrictions (`SessionManager.dietType` + `customDietPreferences`)
- Visual markers on calendar days with violations
- Violation detail screen per day
- Aggregate violation report

### FR-25: Expenditure Integration Settings :x:
**Current state:** No health/fitness app integration code exists.
**What's needed:**
- Apple Health / Google Fit integration (read steps, active calories)
- Settings screen to enable/disable integrations
- Auto-import burned calories into daily expenditure
- Sync frequency configuration

### FR-27: Alerts on Limit Exceedance :x:
**Current state:** Dashboard shows progress rings but never alerts when goals are exceeded. `TrackingReminderService` handles only scheduled reminders.
**What's needed:**
- Check logged intake vs goals after each meal save
- In-app alert (snackbar/dialog) when daily calorie or macro goal exceeded
- Optional push notification for threshold exceedance
- Customizable thresholds (e.g. alert at 90%, 100%, 110%)

### FR-31: Natural-Language Queries (Ask AI) :x:
**Current state:** `ask_ai_response_screen.dart:205-246` returns entirely hardcoded mock strings for three variants (violations, achieved, tracked). No AI call is made.
**What's needed:**
- Build prompt from user query + relevant day records
- Call AI service with query context
- Parse and display AI-generated response
- Conversation history (optional)

### FR-32: Monthly Motivational Summary :x:
**Current state:** No code related to monthly summaries exists.
**What's needed:**
- Monthly data aggregation (avg calories, protein, weight change, streak, best day)
- Motivational messaging based on progress vs goals
- End-of-month push notification
- Summary screen accessible from progress tab

### FR-34: AI Accuracy Evaluation :x:
**Current state:** No feedback or accuracy tracking code exists.
**What's needed:**
- Post-edit comparison: original AI values vs user-corrected values
- Accuracy metrics stored per meal (% deviation)
- Dashboard or profile section showing AI accuracy stats
- Optional: thumbs up/down on AI result before editing

### FR-35: Show/Hide Advanced Features :x:
**Current state:** `preferences_screen.dart:49-64` has four toggles with hardcoded `isOn` values (`false`/`true`/`false`/`true`). Changes are not persisted or applied.
**What's needed:**
- Persist toggle states in SharedPreferences
- Controller to manage feature visibility
- Conditional rendering in UI based on toggle state
- Features to toggle: live activity, burned calories display, rollover calories, auto-adjust macros

---

## 2. Functional Requirements — Partially Implemented

### FR-05: Data Control & Deletion :warning:
**Works:** Meal deletion (cascade to ingredients), ingredient deletion, exercise deletion.
**Missing:**
- Account deletion flow (`profile_screen.dart:135` — snackbar stub)
- Logout flow (`profile_screen.dart:129` — snackbar stub)
- Bulk data deletion ("delete all my data")
- Export before delete option

### FR-08: Uncertainty Indication :warning:
**Works:** Confidence thresholds in `ai_pipeline_service.dart:16-17` (meal ≥ 0.45, exercise ≥ 0.35). Low-confidence snackbar shown.
**Missing:**
- Persistent visual indicator on meal/ingredient cards (badge, icon, color)
- Per-ingredient confidence display
- Confidence percentage visible to user
- Visual distinction between high/medium/low confidence results

### FR-09: Explain AI Limits :warning:
**Works:** Scan onboarding tips (`scan_onboarding_screen.dart:19-60`).
**Missing:**
- Detailed AI limitations explanation accessible from settings/help
- What AI can and cannot do
- When and why AI might be inaccurate
- Privacy/data handling explanation

### FR-10: AI Error vs App Error :warning:
**Works:** Pipeline internally distinguishes `success`, `lowConfidence`, `failure` (`ai_pipeline_service.dart:32-49`).
**Missing:**
- User-facing error categorization (network error vs AI error vs input error)
- Specific error messages per category
- Offline-specific error messaging
- Actionable error recovery suggestions in UI

### FR-15: Quantity Units :warning:
**Works:** Weight in grams stored and displayed. AI extracts quantity string from response.
**Missing:**
- Unit type field in Ingredient model (grams, pieces, cups, ml, etc.)
- Unit selector dropdown in `EditIngredientScreen`
- Unit conversion logic
- Localized unit names

### FR-18: Favorites :white_check_mark:
**Done:** Meal favorites fully functional (DB toggle, EditMealScreen bookmark, SelectMealScreen favorites tab with real DB data). Exercise favorites implemented: `isFavorite` field added to ExerciseEntity (migration v6→v7), bookmark buttons wired in ExerciseDetailScreen, AddExerciseScreen, and ExerciseLogHomeScreen. Mock data removed from SelectMealScreen and ExerciseLogHomeScreen — all listings use real DB data.

### FR-28: Data Export (CSV/PDF) :white_check_mark:
**Implemented:** Full PDF and CSV export with date range selection (last 7/30 days, all time, custom). `ExportService` generates styled PDF reports (daily summary table, meal details with ingredients, exercise log, weight progress, period averages) and CSV files. `ExportController` manages date range state and export flow. Files shared via native share sheet (`share_plus`). Email screen removed in favor of share sheet.

### FR-29: Offline Tolerance :warning:
**Works:** Floor DB fully functional offline. Past data viewable without connectivity.
**Missing:**
- Connectivity monitoring service
- Offline state indicator in UI
- Graceful degradation messaging when AI unavailable
- Operation queue for syncing when back online

---

## 3. Non-FR Features — Not Implemented or Incomplete

### Gemini AI Provider :warning:
**Current state:** `gemini_service.dart` and `gemini_rest_client.dart` exist. Endpoint uses `v1beta/openai/chat/completions` which is the OpenAI-compatible mode, not native Gemini API. TODO comment at `gemini_rest_client.dart:11` questions endpoint correctness.
**What's needed:**
- Verify/fix Gemini API endpoint and response format
- Test full analysis pipeline with Gemini
- Provider selection UI in settings (currently architecture supports it but UI doesn't expose it)

### Meal Report / Feedback :warning:
**Current state:** `report_meal_screen.dart` has full UI (text input, char counter, submit button) but `_handleReport()` at lines 95-107 is a stub — just delays and closes, sends nothing.
**What's needed:**
- Backend endpoint or local storage for reports
- Report data model (meal ID, user text, timestamp)
- Admin review mechanism (or at minimum, local persistence)

### Save Meal Image to Gallery :x:
**Current state:** `edit_meal_screen.dart:378-381` shows snackbar "Saving is not implemented yet."
**What's needed:**
- `image_gallery_saver` or equivalent package
- Permission handling for photo library access
- Save confirmation with gallery path

### Voice Log Tips / Help :x:
**Current state:** Help button in `voice_log_screen.dart:521-525` shows snackbar "Voice log tips coming soon."
**What's needed:**
- Tips content (e.g. "speak clearly", "describe one meal at a time", supported languages)
- Bottom sheet or dialog with tips

### Localization :white_check_mark:
**Done:** All user-facing strings extracted to `assets/translations/{en,cs}.json` (~380 flat keys). `locale_keys.g.dart` regenerated (564 lines). All 50+ screen/widget/controller/service files updated to use `tr(LocaleKeys.xxx)`. Full Czech translations provided. Unused `tr.json` (Turkish) removed. `as easy` aliases removed from language_screen and tracking_reminders_screen. Broken string-literal `tr()` calls in error.dart and base_controller.dart fixed.

### Dark Mode :warning:
**Current state:** Dark theme colors defined in `app_theme_data.dart:96-149`. No toggle or system detection.
**What's needed:**
- System brightness detection (`MediaQuery.platformBrightness`)
- Manual theme toggle in settings
- Reactive theme state (GetX observable)
- Verify dark theme contrast ratios

### Accessibility :x:
**Current state:** No `Semantics` widgets, no `semanticLabel` properties found in codebase.
**What's needed:**
- Semantic labels on all icon-only buttons
- Screen reader support for progress rings and charts
- Sufficient contrast on glass/translucent surfaces
- Focus management for keyboard navigation
- Minimum 48x48 tap targets audit

### Multiple Meals per Photo :x:
**Current state:** `answer.dart` model supports only a single meal name + ingredient list. A photo with multiple dishes is merged into one meal.
**What's needed:**
- Array of meals in AI response model
- Split detection flow (one photo → multiple meal entries)
- UI to confirm/split detected items

### Onboarding Skip Button :warning:
**Current state:** `onboarding_welcome_screen.dart:43` has button labeled "Skip onboarding (Dummy)".
**What's needed:**
- Remove "Dummy" label or remove skip button for production
- Ensure skipping properly initializes required defaults

---

## 4. Code Quality / Technical Debt

### Mock Data to Replace with Real Data
| Location | Mock Content |
|----------|-------------|
| ~~`select_meal_screen.dart:469-505`~~ | ~~3 mock meals + 2 mock ingredients~~ (removed — uses real DB data) |
| `recipe_service.dart:7-89` | 8 hardcoded Czech recipes with placeholder image IDs |
| `meal_detail_screen.dart:39-55` | `_stubMeal` fallback (Salmon & Vegetables) |
| `ingredient_detail_screen.dart:18-27` | `_stubIngredient` fallback (Apple, 125g) |
| `ask_ai_response_screen.dart:205-246` | 3 hardcoded AI response variants |

### Empty Event Handlers
| Location | Element |
|----------|---------|
| ~~`exercise_detail_screen.dart:40`~~ | ~~Bookmark icon~~ (wired to toggle favorite) |
| ~~`exercise_log_home_screen.dart:93`~~ | ~~Bookmark icon~~ (wired to toggle favorites filter) |
| ~~`add_exercise_screen.dart:125`~~ | ~~Bookmark icon~~ (wired to toggle favorite on new exercise) |
| `ask_ai_response_screen.dart:150` | Export CSV button — `onTap: () {}` |
| `select_meal_screen.dart:437` | Ingredient tap — shows snackbar only |

### Stub Methods
| Location | Method |
|----------|--------|
| `dashboard_controller.dart:116` | `onHidden()` — TODO stub |
| `day_record_controller.dart:188` | `onHidden()` — TODO stub |
| `weight_entry_controller.dart:41` | `onHidden()` — TODO stub |
| `streak_controller.dart:42` | `onHidden()` — TODO stub |
| `dashboard_screen.dart:255` | `onHidden()` — TODO stub |
| `main_screen.dart:92` | `onHidden()` — TODO stub |
| `report_meal_screen.dart:95-107` | `_handleReport()` — delays and closes, no actual reporting |

---

## 5. Priority Suggestions

### High Priority (Core thesis requirements)
1. **FR-31** — Ask AI (replace mock with real AI queries) // DONE
2. **FR-28** — Data Export (implement actual PDF/CSV generation) // DONE
3. **FR-05** — Account deletion & logout
4. **FR-18** — Fix favorites listing (remove mock data fallback) // DONE
5. **Localization** — Extract hardcoded strings to translation files // DONE

### Medium Priority (Important for completeness)
6. **FR-08** — Visual confidence indicators on meals
7. **FR-27** — Goal exceedance alerts
8. **FR-35** — Working feature toggles
9. **FR-15** — Unit types beyond grams
10. **FR-19** — Meal duplication
11. **FR-20** — Name autocomplete from history // DONE
12. **Meal Report** — Wire up report submission
13. **Dark Mode** — Theme toggle + system detection

### Lower Priority (Nice to have)
14. **FR-32** — Monthly motivational summary
15. **FR-34** — AI accuracy evaluation
16. **FR-23** — Dietary violations in calendar
17. **FR-25** — Health app integrations
18. **FR-16** — Customizable portion presets
19. **FR-21** — Meal planning / plan vs actual
20. **Accessibility** — Semantic labels, screen reader support
21. **Multiple meals per photo**
22. **Gemini provider** — Verify and test
23. **Save meal image** — Gallery save
24. **Voice log tips** — Help content
