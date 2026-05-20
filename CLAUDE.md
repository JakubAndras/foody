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
- Current DB version: **1** (`lib/database/app_database.dart`) — thesis release ships at v1 with all schema baked into `onCreate`. No migration file exists.
- Entities: `DayRecord`, `Meal`, `Ingredient`, `WeightEntry`, `Exercise`, `IngredientTemplate`, `ExerciseTemplate` in `lib/database/entities/`
- DAOs in `lib/database/dao/`
- **Normalized FK schema**: `Meal.dayRecordId → DayRecord`, `Ingredient.mealId → Meal`, `Exercise.dayRecordId → DayRecord` — all CASCADE delete
- `DayRecordRepository` assembles domain aggregates (`DayRecord` + `Meal[]` + `Ingredient[]` + `Exercise[]`) for UI — always use the repository, not DAOs directly
- `Meal` and `Ingredient` carry research-only telemetry columns (`inputSource`, `aiProvider`, `aiModel`, `aiOriginal*`, `wasEditedByUser`, `editedAtMs`) — see `RESEARCH_ONLY.md` for the removal plan before production.

**Adding DB fields/tables (dev workflow during testing phase):**
1. Modify entity, run `build_runner`.
2. **If no testers have the app yet** (or you can ask them to reinstall): keep version at 1, uninstall the app on your own dev device, and the new schema will be created fresh on next launch.
3. **If testers are already collecting data**: bump version to 2, create `lib/database/migrations.dart` with a `migration1to2` Migration object (ALTER TABLE …), register it via `.addMigrations(appMigrations)` in `lib/locator.dart`.

### AI Pipeline
```
Input (photo/text/voice) → AiPipelineService → AiServiceManager (OpenAI|Gemini)
  → REST client → structured JSON prompt (lib/utils/prompt.dart)
  → AiResponse (json_serializable) → confidence gate → result
```
Confidence thresholds: meal >= 0.50, exercise >= 0.50 (in `AiPipelineService`).

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

Thesis requirements (FR-01 to FR-30). Status as of current codebase:

| FR | Name | Status |
|----|------|--------|
| FR-01 | Manual meal entry (no AI) | Done |
| FR-02 | Daily overview ("daily card") | Done |
| FR-03 | Target goals | Done |
| FR-04 | User profile management | Done |
| FR-05 | Data control and deletion | Partial — meal/exercise deletion works, no account deletion |
| FR-06 | Photo-based meal entry | Done |
| FR-07 | AI suggestions for items/portions | Done |
| FR-08 | Uncertainty indication | Done — color-coded badge (green ≥75%, yellow ≥50%, red <50%) |
| FR-09 | Explain AI limits | Done — 5-page scan onboarding with tips |
| FR-10 | AI error vs app error | Partial — barcode errors typed (6 types), AI pipeline generic failure |
| FR-11 | Text fallback after photo failure | Done |
| FR-12 | Import photo from gallery | Done |
| FR-13 | Re-run recognition from edit | Done — "Improve with AI" in EditMealScreen → FixResultScreen |
| FR-14 | Entry without photo | Done — voice, text description, manual entry |
| FR-15 | Quantity units (grams/pieces) | Done — 1g, 100g, custom units, fraction display |
| FR-16 | Barcode scanner | Done |
| FR-17 | Favorites | Done — isFavorite on meals/ingredients/exercises, Favorites tab in SelectMealScreen |
| FR-18 | Duplicate previous record | Done — MealCopyToSheet with calendar date picker |
| FR-19 | Name autocomplete from history | Partial — search with debounce in SelectMealScreen, not classic autocomplete dropdown |
| FR-20 | Dietary restrictions/intolerances | Done |
| FR-21 | Violations in calendar | Done — per-meal "Dietary warning" banner + highlighted offending ingredients on EditMealScreen; monthly calendar (AskAiCalendarCard) rendered in Ask AI response when user queries about violations |
| FR-22 | Intake vs expenditure in one view | Done |
| FR-23 | Expenditure integration settings | Partial — burnedCaloriesEnabled/rolloverCaloriesEnabled toggles, no granular multipliers |
| FR-24 | Weekly and monthly overviews | Done |
| FR-25 | Data export (CSV/PDF) | Done |
| FR-26 | Offline tolerance | Done — SQLite local-first, AI needs connectivity |
| FR-27 | Natural-language queries (Ask AI) | Done — two-pass system (date range → analysis) |
| FR-28 | Monthly motivational summary | Done — MotivationalSummaryService: daily/weekly/monthly notifications |
| FR-29 | Gentle, configurable notifications | Done |
| FR-30 | Show/hide advanced features | Partial — individual toggles (burned cal, rollover, auto-adjust), no basic/advanced mode |

**Extra features (not in original FR list):**
- Voice input for meals and exercises (`VoiceTranscriptionService`, `VoiceLogScreen`)
- Exercise tracking: manual + AI + voice + templates + favorites (`ExerciseLogHomeScreen`, `AddExerciseScreen`)
- Weight tracking with photo, history, BMI (`WeightLogSheet`, `WeightHistoryScreen`, `BmiCard`)
- Rollover calories system (max 500 kcal carry-forward, toggle)
- Streak tracking (`StreakService`, current/longest streak, weekly activity)
- Home widget support (`lib/services/home_widget/`)
- Health data sync: Apple Health / Health Connect (`HealthIntegrationService`)
- Multi-model AI: OpenAI + Gemini with fallback (`lib/services/ai_feature/`)
- IngredientTemplate system for reusable ingredients with usage tracking
- ExerciseTemplate system for reusable exercises
- Report meal function for AI feedback (`ReportMealScreen`)
- Auto-adjust macros proportionally when changing calories
- Calendar day ring visualization (`CalendarDayRingService`)
- Food label scanning (`ScanMode.foodLabel`)
- Comprehensive onboarding flow (12+ screens)

**Foundational decisions:**
- Normalized FK tables (no embedded lists) — `DayRecordRepository` assembles aggregates
- OpenAI primary provider, architecture provider-agnostic (Gemini ready)
- Local-only storage, no online sync/auth
- `mobile_scanner` + Open Food Facts for barcode flow
- `flutter_local_notifications` for reminder scheduling

## Pravidla textu diplomové práce

Téma práce: „Aplikace pro rozpoznávání potravin pomocí AI a sledování kalorického příjmu" (ČVUT FEL).

### Role

Funguj jako kombinace odborného konzultanta, oponenta a spoluautora textu. Intelektuální obsah (tvrzení, data, závěry, rozhodnutí) je vždy autorův. Nikdy negeneruj vlastní tvrzení, data, citáty ani výsledky měření bez podkladů od autora.

### Jazyk a styl

- Odpovídej primárně česky.
- Piš akademickým, ale čitelným stylem: věcně, strukturovaně, bez zbytečné omáčky.
- Preferuj stručné, konkrétní odpovědi s podnadpisy a příklady.
- Detailní formátovací pravidla (třetí osoba, čísla, citace, struktura kapitol) definují `/diplomka-write` a `/diplomka-refactor` skilly ve svých SKILL.md.

### Co přesně potřebuji

- Pomáhej strukturovat kapitoly, psát a přepisovat části textu.
- U uživatelského výzkumu (strukturované rozhovory, uživatelské testy): navrhuj scénáře, otázky, strukturu rozhovorů a testovacích úloh; analyzuj odpovědi (témata, insighty, závěry) a pomoz je správně popsat v textu.
- Navrhuj formulace tak, aby zapadaly do diplomové práce (ne jako blogpost nebo próza).
- Když dostaneš existující text: navrhni úpravy formulací, struktury a návaznosti argumentů; upozorni na nelogičnosti, opakování nebo chybějící kroky v argumentaci; navrhni, co doplnit (příklady, odkazy na literaturu, metodiku).

### Akademická integrita

- Nepředstírej znalost konkrétních studií. Pokud si nejsi jistý, navrhni typ zdrojů a klíčová slova k dohledání.
- Nikdy nefabrikuj data, citáty participantů, výsledky měření ani SUS skóre.
- Když něco může být sporné nebo spekulativní, upozorni na to.

### Zdroje

- Pouze akademická/vědecká literatura, odborné internetové články nebo oficiální weby zabývající se danou problematikou.
- Zakázané zdroje: Wikipedia a obdobné nedůvěryhodné zdroje.
- Preferované databáze: https://www.mdpi.com, https://jmirpublications.com. Pokud tam relevantní zdroj neexistuje, hledej v IEEE, ACM, Springer, Elsevier a dalších peer-reviewed zdrojích.

### Typografie: pomlčky v textu

- Nikdy nepoužívej em-dash (`—`) ani en-dash (`–`) jako parentetickou vsuvku uprostřed věty (typ: "aplikace – která je nová – funguje"). Přeformuluj pomocí čárek, vedlejších vět nebo samostatných vět.
- En-dash (`–`) je povolený výhradně v číselných rozsazích (`200–500`, `18,5–24,9`).
- Toto pravidlo platí globálně napříč celou prací a všemi skilly.

## Environment Setup

1. Create `.env` in project root: `OPENAI_API_KEY=sk-...` (optionally `GEMINI_API_KEY=...`)
2. `flutter pub get`
3. `flutter pub run build_runner build --delete-conflicting-outputs` (if needed)
4. `flutter run`
