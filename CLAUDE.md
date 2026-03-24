# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Foody** is a Flutter mobile app for AI-powered calorie tracking, built as a diploma thesis by Jakub Andras. Users can photograph food, describe it by voice/text, or scan a barcode, and the app uses OpenAI to estimate nutritional values. Package name: `diplomka`.

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
│
├── services/                          # GetxServices (long-lived, app-scoped)
│
├── database/                          # Floor ORM layer
│
├── network/                           # REST clients
│
├── model/                             # Data models + json_serializable
│
├── screens/                           # UI screens (one file or folder per feature)
│
├── widgets/                           # Reusable UI components
│
├── utils/                             # Helpers
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
- Current DB version: **8** (`lib/database/app_database.dart`)
- Migrations in `lib/database/migrations.dart` (migration1to2 through migration7to8)
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

## Layout & Accessibility Rules

**Layout:**
- Base horizontal gutters: 16–24px (use `AppSpacing.edge` or equivalent token)
- Vertical section spacing: 16–24px; intra-list gaps: 8–12px
- Cards: full-width, max 430px on large devices
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
| FR-08 | Uncertainty indication | Done |
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
| FR-28 | Data export (CSV/PDF) | Done |
| FR-29 | Offline tolerance | Partial — local DB works offline, AI needs connectivity |
| FR-30 | Cloud storage and sync | Deferred (out of scope) |
| FR-31 | Natural-language queries (Ask AI) | Done |
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
