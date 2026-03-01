# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Foody** is a Flutter mobile app for AI-powered calorie tracking, built as a diploma thesis by Jakub Andras. Users can photograph food, describe it by voice/text, or scan a barcode, and the app uses OpenAI GPT-4o to estimate nutritional values. Package name: `diplomka`.

## Project Structure

```
lib/
├── main.dart                          # Entry point, locale setup, runApp
├── app.dart                           # MaterialApp, onboarding gate (Obx)
├── app_theme.dart                     # Design tokens: AppColors, AppSpacing, AppRadii, AppSizes,
│                                      #   AppTextStyles, AppGradients, AppShadows
├── app_theme_data.dart                # ThemeData builder
├── locator.dart                       # DI — registers all services/controllers via Get.put/lazyPut
│
├── controller/                        # GetxControllers (UI state + business logic)
│   ├── dashboard_controller.dart      #   Main dashboard state, meal/exercise analysis triggers
│   ├── day_record_controller.dart     #   CRUD for day records, meals, ingredients, exercises
│   ├── barcode_scan_controller.dart   #   Barcode scan flow state machine
│   ├── weight_entry_controller.dart   #   Weight log CRUD
│   ├── streak_controller.dart         #   Streak calculation
│   ├── tracking_reminders_controller.dart
│   ├── language_settings_controller.dart
│   ├── recipe_service.dart            #   Recipe suggestions
│   └── base_controller.dart           #   Shared loading/error state
│
├── services/                          # GetxServices (long-lived, app-scoped)
│   ├── day_record_repository.dart     #   Aggregate assembly (DayRecord+Meals+Ingredients+Exercises)
│   ├── weight_entry_repository.dart   #   Weight entry persistence
│   ├── session_manager.dart           #   User profile → SharedPreferences
│   ├── shared_preferences_manager.dart#   Low-level SharedPreferences wrapper
│   ├── nutrition_goals_service.dart   #   Goal persistence + propagation to future dates
│   ├── selected_date_service.dart     #   Currently selected date (reactive)
│   ├── streak_service.dart            #   Streak logic
│   ├── calendar_day_ring_service.dart #   Ring color computation per calendar day
│   ├── barcode_lookup_service.dart    #   Barcode → Open Food Facts lookup
│   ├── tracking_reminder_service.dart #   flutter_local_notifications scheduling
│   ├── language_settings_service.dart #   Voice recognition language preference
│   ├── ai_feature/                    #   AI pipeline
│   │   ├── ai_pipeline_service.dart   #     Orchestrator (photo/text/voice → AI → result)
│   │   ├── ai_service_manager.dart    #     Provider selection (OpenAI/Gemini)
│   │   ├── ai_service.dart            #     Abstract AI service interface
│   │   ├── openai_service.dart        #     OpenAI implementation
│   │   └── gemini_service.dart        #     Gemini implementation
│   ├── voice/
│   │   └── voice_transcription_service.dart  # speech_to_text wrapper
│   ├── share/                         #   Meal sharing (image builder + share sheet)
│   └── home_widget/                   #   iOS/Android home screen widget sync
│
├── database/                          # Floor ORM layer
│   ├── app_database.dart              #   @Database definition, version 6
│   ├── migrations.dart                #   migration1to2 … migration5to6
│   ├── entities/                      #   @Entity classes (DayRecord, Meal, Ingredient, WeightEntry, Exercise)
│   └── dao/                           #   @dao classes (one per entity)
│
├── network/                           # REST clients
│   ├── base_rest_client.dart          #   Shared HTTP logic
│   ├── openai_rest_client.dart        #   OpenAI GPT-4o requests
│   ├── gemini_rest_client.dart        #   Gemini requests
│   ├── open_food_facts_client.dart    #   Open Food Facts barcode API
│   └── rest_client.dart               #   Legacy/common interface
│
├── model/                             # Data models + json_serializable
│   ├── day_record.dart                #   Domain aggregate (DayRecord + meals + exercises)
│   ├── meal.dart, ingredient.dart     #   Meal/ingredient domain models
│   ├── exercise.dart                  #   Exercise domain model
│   ├── ai_response.dart (+.g.dart)    #   AI JSON response model
│   ├── nutrition_goals.dart           #   Goals model with DayRecord mapping
│   ├── user_profile.dart              #   Profile enums (gender, diet type, goal)
│   ├── barcode_lookup_result.dart     #   OFF API result
│   ├── tracking_reminder_setting.dart #   Reminder config
│   └── …                             #   (streak_info, weight_entry, recipe, etc.)
│
├── screens/                           # UI screens (one file or folder per feature)
│   ├── main_screen.dart               #   3-tab shell (Dashboard/Progress/Profile) + FAB
│   ├── dashboard_screen.dart          #   Daily overview with calories ring + meals + exercises
│   ├── progress_screen.dart           #   Weight chart, streaks, weekly averages, BMI
│   ├── onboarding/                    #   16 onboarding screens (welcome → plan ready)
│   ├── scan/                          #   Camera scan, barcode, preview, permissions
│   ├── meals/                         #   Meal detail, edit meal, fix result, report, ingredients
│   ├── ingredients/                   #   Edit ingredient screen
│   ├── logs/                          #   Voice log, exercise log/detail/add, weight log sheet
│   ├── log_meal/                      #   Select meal screen (history/favorites/search)
│   └── profile/                       #   Profile screen + subscreens + Ask AI
│       ├── profile_screen.dart
│       ├── ask_ai/                    #   Ask AI screens (currently mock)
│       └── subscreens/                #   Personal details, nutrition goals, reminders,
│                                      #     preferences, export, weight history, language, etc.
│
├── widgets/                           # Reusable UI components
│   ├── calories_card.dart, macros_card.dart, macros_row.dart
│   ├── progress_ring.dart             #   Circular progress painter
│   ├── date_selector.dart             #   Horizontal date picker
│   ├── recently_uploaded_card.dart    #   Dashboard meals+exercises card
│   ├── weight_progress_card.dart      #   Weight chart widget
│   ├── bottom_nav_bar.dart            #   Custom bottom navigation
│   ├── quick_action_sheet.dart        #   FAB action sheet
│   ├── streak_dialog.dart             #   Streak celebration dialog
│   ├── onboarding/                    #   Shared onboarding widgets
│   ├── edit_flow/                     #   Shared edit flow widgets
│   └── liquid_glass/                  #   Liquid glass visual effect
│
├── utils/                             # Helpers
│   ├── prompt.dart                    #   AI prompt templates
│   ├── media_storage.dart             #   Photo file management
│   ├── dialog_utils.dart              #   Common dialog helpers
│   └── error.dart                     #   Error handling utilities
│
└── generated/                         # Auto-generated (do not edit)
    ├── locale_keys.g.dart             #   easy_localization keys
    └── codegen_loader.g.dart          #   Translation loader
```

## Key Commands

```bash
# Run the app
flutter run

# Build release
flutter build apk --release
flutter build ipa --release

# Regenerate Floor DB code and json_serializable models (required after entity changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Regenerate localization keys
bash commands/generate_localization.command

# Static analysis
flutter analyze

# Run tests
flutter test

# Format code (line width 180 per analysis_options.yaml)
dart format --line-length 180 lib/
```

## Architecture

### State Management: GetX
All state management uses GetX. Services extend `GetxService`, controllers extend `GetxController` (or `BaseController`). Access pattern: `static FooService get to => Get.find();`. All services/controllers are registered in `lib/locator.dart` via `Get.put()` (permanent) or `Get.lazyPut()`.

### Database: Floor ORM
- Current DB version: **6** (`lib/database/app_database.dart`)
- Migrations in `lib/database/migrations.dart` (migration1to2 through migration5to6)
- Entities: `DayRecord`, `Meal`, `Ingredient`, `WeightEntry`, `Exercise` in `lib/database/entities/`
- DAOs in `lib/database/dao/`
- **Normalized FK schema**: `Meal.dayRecordId → DayRecord`, `Ingredient.mealId → Meal`, `Exercise.dayRecordId → DayRecord` — all CASCADE delete
- `DayRecordRepository` assembles domain aggregates (`DayRecord` + `Meal[]` + `Ingredient[]` + `Exercise[]`) for UI — always use the repository, not DAOs directly

**Adding DB fields/tables:** bump version in `app_database.dart`, add migration in `migrations.dart`, register in the `addMigrations()` chain in `locator.dart`, then run `build_runner`.

### AI Pipeline
```
Input (photo/text/voice) → AiPipelineService → AiServiceManager (OpenAI|Gemini)
  → REST client → structured JSON prompt (lib/utils/prompt.dart)
  → AiResponse (json_serializable) → confidence gate → result
```
Confidence thresholds: meal >= 0.45, exercise >= 0.35 (in `AiPipelineService`).

**Subsystem flows:**
- **Voice**: `speech_to_text` → `VoiceTranscriptionService` (locale-aware: cs/en) → transcribed text → `AiPipelineService` → save. UI in `lib/screens/logs/voice_log_screen.dart`.
- **Barcode**: `mobile_scanner` → `BarcodeLookupService` → `OpenFoodFactsClient` (Open Food Facts API) → `BarcodeLookupResult` with nutriments. Controller: `BarcodeScanController`.
- **Dietary context**: `SessionManager.dietType` + `customDietPreferences` are injected into AI prompts via `_buildMealUserAttributes()`.
- **Notifications**: `TrackingReminderService` uses `flutter_local_notifications` with timezone-aware `zonedSchedule()`. 5 reminder types (breakfast/lunch/snack/dinner/end-of-day), persisted via SharedPreferences.
- **Profile persistence**: `SessionManager` → `SharedPreferencesService` for weight, height, DOB, gender, goals, diet type, metric preference.
- **Nutrition goals**: `NutritionGoalsService` reads/writes goals through `DayRecordRepository.upsertDayRecord()`, propagated to current + future dates.

### Navigation
Direct GetX navigation: `Get.to(() => const SomeScreen())` — no named route table. Main shell is a 3-tab `MainScreen` (Dashboard/Progress/Profile) with a FAB for quick actions.

### Localization
- `easy_localization` with generated keys in `lib/generated/locale_keys.g.dart`
- Supported locales: `en`, `cs` (defined in `main.dart`)
- Translation files: `assets/translations/{en,cs,tr}.json`
- Add strings to all locale files, then regenerate keys

## Key Conventions

- **Design tokens**: All colors, spacing, radii, sizes, typography, gradients, and shadows come from `lib/app_theme.dart` (`AppColors`, `AppSpacing`, `AppRadii`, `AppSizes`, `AppTextStyles`, `AppGradients`, `AppShadows`). Never hardcode design values.
- **Line width**: 180 characters (set in `analysis_options.yaml` `formatter.page_width`)
- **Linting**: `flutter_lints` + `custom_lint` plugin
- **Environment**: API keys in `.env` (git-ignored) loaded via `flutter_dotenv`. Never commit `.env`.
- **New services/controllers**: Register in `lib/locator.dart`
- **File naming**: snake_case files, PascalCase classes

## Figma MCP Integration

Figma file: `https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev`

**Required workflow (do not skip):**
1. `get_design_context` — fetch structured representation for the exact node(s).
2. If truncated, `get_metadata` for the high-level node map, then re-fetch specific nodes.
3. `get_screenshot` — visual reference of the node variant.
4. Only after both context + screenshot, download assets and start implementation.

**Translation rules:**
- MCP output is often React + Tailwind — treat as design/behavior spec only, translate to Flutter.
- Reuse project color tokens, typography, spacing from `lib/app_theme.dart` — never duplicate.
- Reuse existing Flutter components (buttons, inputs, icon wrappers) instead of creating new ones.
- If conflicts arise, prefer design-system tokens and adjust minimally to match visuals.
- Validate against the Figma screenshot for 1:1 look before marking complete.

**Naming conventions:**
- Screens: `<Feature><Name>Screen` (e.g., `OnboardingGoalScreen`, `AskAiResponseScreen`)
- Components: `<Feature><Name>Card`, `<Feature><Name>Button`, `<Feature><Name>Picker`

## Layout & Accessibility Rules

**Layout:**
- Base horizontal gutters: 16–24px (use `AppSpacing.edge` or equivalent token)
- Vertical section spacing: 16–24px; intra-list gaps: 8–12px
- Cards: full-width, max 430px on large devices
- All screens: `SafeArea` + scroll (`SingleChildScrollView` or `CustomScrollView`) for overflow
- Bottom CTA bars: pinned with keyboard-safe padding

**Accessibility:**
- Minimum tap target: 48×48px
- Small text (9–13px) requires sufficient contrast — avoid lowering opacity further
- Icon-only buttons must have semantic labels
- Glass/translucent surfaces: preserve contrast for overlaid text

## Functional Requirements Status

Thesis requirements (FR-01 to FR-35). Status as of current codebase:

| FR | Name | Status |
|----|------|--------|
| FR-01 | Manual meal entry (no AI) | Done |
| FR-02 | Daily overview ("daily card") | Done |
| FR-03 | Target goals | Done |
| FR-04 | User profile management | Done |
| FR-05 | Data control and deletion | Partial — meal deletion works, no account deletion |
| FR-06 | Photo-based meal entry | Done |
| FR-07 | AI suggestions for items/portions | Done |
| FR-08 | Uncertainty indication | Partial — low-confidence snackbar, no visual indicator |
| FR-09 | Explain AI limits | Partial — scan onboarding tips only |
| FR-10 | AI error vs app error | Partial — pipeline distinguishes, UI limited |
| FR-11 | Text fallback after photo failure | Done |
| FR-12 | Import photo from gallery | Done |
| FR-13 | Re-run recognition from edit | Done |
| FR-14 | Entry without photo | Done |
| FR-15 | Quantity units (grams/pieces) | Partial |
| FR-16 | Portion presets | Not implemented |
| FR-17 | Barcode scanner | Done |
| FR-18 | Favorites | Partial — DB toggle works, listing uses mock data |
| FR-19 | Duplicate previous record | Not implemented |
| FR-20 | Name autocomplete from history | Not implemented |
| FR-21 | Plan vs actual for cooking | Not implemented |
| FR-22 | Dietary restrictions/intolerances | Done |
| FR-23 | Violations in calendar | Not implemented |
| FR-24 | Intake vs expenditure in one view | Done |
| FR-25 | Expenditure integration settings | Not implemented |
| FR-26 | Weekly and monthly overviews | Done |
| FR-27 | Alerts on limit exceedance | Not implemented |
| FR-28 | Data export (CSV/PDF) | Not implemented — UI shells only |
| FR-29 | Offline tolerance | Partial — local DB works offline, AI needs connectivity |
| FR-30 | Cloud storage and sync | Deferred (out of scope) |
| FR-31 | Natural-language queries (Ask AI) | Not implemented — hardcoded mock responses |
| FR-32 | Monthly motivational summary | Not implemented |
| FR-33 | Gentle, configurable notifications | Done |
| FR-34 | AI accuracy evaluation | Not implemented |
| FR-35 | Show/hide advanced features | Not implemented — toggles are static UI |

**Foundational decisions:**
- Normalized FK tables (no embedded lists) — `DayRecordRepository` assembles aggregates
- OpenAI primary provider, architecture provider-agnostic (Gemini ready)
- Local-only storage, no online sync/auth — architecture allows future cloud sync
- `mobile_scanner` + Open Food Facts for barcode flow
- `flutter_local_notifications` for reminder scheduling

## Environment Setup

1. Create `.env` in project root: `OPENAI_API_KEY=sk-...` (optionally `GEMINI_API_KEY=...`)
2. `flutter pub get`
3. `flutter pub run build_runner build --delete-conflicting-outputs` (if needed)
4. `flutter run`
