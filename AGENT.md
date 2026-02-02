A mobile application for calorie tracking using AI, developed as part of a diploma thesis.

## Overview

This project is a cross-platform mobile application built with the Flutter framework. Its main purpose is to simplify the process of logging meals by allowing users to take a photo of their food, which is then analyzed by a publicly available artificial intelligence (e.g., Google Gemini) to return estimated nutritional values. The application serves as the practical part of a diploma thesis.

The base Flutter app template and directory structure already exist (e.g., `lib/`, `main.dart`, app locator), and the UI is currently work-in-progress. The final UI will be pulled from Figma via MCP, which is important for upcoming implementation work.

## Features

- Automatic food analysis from a photograph using an external AI.
- Automatic food analysis based on text description using an external AI.
- Display of estimated calories, macronutrients, and ingredients.
- Barcode scanning for quick product entry.
- Tracking of daily calorie intake and goals.
- Display of statistics and intake history.
- Simple and cross-platform user interface thanks to Flutter.

## Requirements

- Flutter SDK 3.0+ (3.24.1)
- Dart SDK 3.0+ (3.5.1)
- Visual Studio Code or Android Studio
- A valid API key for a public AI service (e.g., Google Gemini API)

## Development

This project uses the following technologies:
- Flutter for the user interface and application logic.
- Dart as the programming language.
- Publicly Available AI (Google Gemini) for image analysis.
- Dio for network communication with the API.
- Riverpod for application state management.

## Core Functionality

1. AI Food Analysis
    1. The user takes a photo of the food directly in the app OR he writes a description of the food in the app.
    2. The image is sent to the multimodal artificial intelligence API (e.g., Gemini API).
    3. The AI analyzes the image and returns structured data in JSON format.
    4. The JSON contains the estimated dish name, a list of ingredients, weight, and nutritional values (calories, proteins, carbohydrates, fats).
    5. The app processes the data and displays it to the user for confirmation and logging into the daily summary and stored it in the user database.
2. Barcode Logging
    1. The application allows barcode scanning (EAN) for quick searching of commercial foods in an external database Open Food Facts (OFF).
    2. After successful code recognition, the nutritional values for the product are automatically retrieved and stored in the user database.
3. Dashboard and Statistics
    1. The main screen (dashboard) displays a daily summary of calories and nutritional values consumed versus the set goal.
    2. The user has access to history and charts that visualize their eating habits over time.

## Functional Requirements (FR)

FR-01 – Manual meal entry (no AI)  
The system must allow creating a meal record without AI recognition.  
Verification: Create a manual record and confirm it is saved and shown in the daily overview.

FR-02 – Daily overview (“daily card”)  
The system must display a daily summary for calories and macronutrients.  
Verification: For a selected day, totals and meal list match the input.

FR-03 – Target goals  
The system must allow setting daily goals (at least calories; optionally macros).  
Verification: Change a goal and confirm the daily indicators recalculate.

FR-04 – User profile management  
The system must allow creating and editing a user profile (basic parameters relevant to tracking).  
Verification: Edit profile and confirm it is saved and reflected in calculations/overviews.

FR-05 – Data control and deletion  
The user must be able to delete individual records and all records when deleting the account.  
Verification: Delete a record / delete account and confirm it is absent from overviews and exports.

FR-06 – Photo-based meal entry  
The system must allow taking a photo of a meal as input for recognition.  
Verification: Take a photo and confirm recognition starts and a proposal is shown.

FR-07 – AI suggestions for items and portions  
From a photo, the system must propose one or more items and estimate portion/amount.  
Verification: The system returns items with prefilled quantities.

FR-08 – Uncertainty indication  
The system must show an understandable AI uncertainty indicator (e.g., icon or percentage).  
Verification: The indicator is shown for AI-based entries and can be toggled in settings (advanced).

FR-09 – Explain AI limits  
The system must inform users about AI limitations (what it can/cannot do, how to improve input).  
Verification: A screen/tooltip exists and can be opened during recognition.

FR-10 – Distinguish “AI error” vs “app error”  
The system must distinguish AI uncertainty from technical failure and offer appropriate next steps.  
Verification: Technical failures show a fallback; uncertainty shows alternatives for user adjustment.

FR-11 – Text fallback after photo failure  
If photo recognition fails, the system must allow a text description to create the record.  
Verification: Force failure and confirm text fallback works and can be saved.

FR-12 – Import photo from gallery  
The system must allow adding a meal from a gallery photo.  
Verification: Select a photo and confirm a proposed record is created.

FR-13 – Re-run recognition from edit screen  
The system must allow invoking AI recognition again from the edit screen.  
Verification: Trigger re-recognition and confirm the proposal updates.

FR-14 – Entry without photo  
The system must allow creating a meal record without a photo.  
Verification: Save a record without photo and confirm it appears in the daily overview.

FR-15 – Quantity units: grams and pieces  
The system must allow quantities in grams and piece-based units (e.g., 1 pc, 1/2 pc).  
Verification: Change unit and confirm correct nutrition recalculation.

FR-16 – Portion presets with estimated grams  
The system must offer quick portion presets (e.g., small/medium/large, 100 g, 1 serving).  
Verification: Select a preset and confirm quantity is set without manual input.

FR-17 – Barcode scanner  
The system must allow adding packaged food by scanning a barcode.  
Verification: Scan a code and confirm the item is offered and can be inserted.

FR-18 – Favorites  
The system must allow marking an item/meal as favorite and quickly re-adding it.  
Verification: Mark as favorite and confirm it appears in quick selection.

FR-19 – Duplicate previous record  
The system must allow duplicating a previous meal record (including quantity) to another day.  
Verification: Duplicate a record and confirm the copy exists and is editable.

FR-20 – Name autocomplete from history  
During name input, the system must offer suggestions based on user history.  
Verification: Start typing and confirm relevant suggestions appear.

FR-21 – Plan vs. actual for cooking  
The system must allow planned ingredients and easy post-cook adjustment of actual amounts.  
Verification: Enter a plan, edit actuals, and confirm nutrition totals recalculate.

FR-22 – Dietary restrictions and intolerances  
The system must allow recording dietary restrictions/intolerances (e.g., gluten-free, allergens).  
Verification: Save restrictions and confirm AI recognition flags them for the user.

FR-23 – Violations in calendar  
The system must show when and how often restrictions were violated, including calendar view.  
Verification: Set restrictions, log meals, and confirm days are marked in calendar.

FR-24 – Intake vs. expenditure in one view  
The system must show intake (food) and expenditure (activity) in a single daily overview.  
Verification: Daily view shows intake, expenditure, and balance.

FR-25 – Expenditure integration settings  
The system must allow configuring whether/how burned calories affect daily limits.  
Verification: Toggle the option and confirm daily limit/remaining calories change.

FR-26 – Weekly and monthly overviews  
The system must provide weekly summaries and monthly trend views.  
Verification: Switch period and confirm aggregations by day/week.

FR-27 – Alerts on limit exceedance  
The system must alert when calorie or macro limits are exceeded.  
Verification: Exceed a limit and confirm the alert appears in daily overview.

FR-28 – Data export (e.g., CSV)  
The system must allow exporting records and summaries to a tabular format.  
Verification: Run export and confirm file creation and contents (meals + daily summaries).

FR-29 – Offline tolerance  
The system must allow basic work offline (e.g., save draft record/photo to finish later).  
Verification: Offline, create a draft and complete it after reconnection.

FR-30 – Cloud storage and sync  
The system should support cloud storage and multi-device availability.  
Verification: Data survives reinstall or login on another device.

FR-31 – Natural-language queries over data  
The system must support natural-language questions over user history and show an answer.  
Verification: Ask a question and confirm an answer is shown without crashes.

FR-32 – Monthly motivational summary  
The system must generate a monthly summary (e.g., adherence days, total calories) via notification or email.  
Verification: Generate a summary for a period and confirm user access/notification where implemented.

FR-33 – Gentle, configurable notifications  
If notifications are enabled, they must be gentle and user-configurable (time, frequency).  
Verification: User sets times and notifications arrive accordingly.

FR-34 – Continuous AI accuracy evaluation  
The system must collect data for AI accuracy evaluation (AI proposal vs. user edits) and compute metrics.  
Verification: Generate a report with metrics (e.g., match rate, quantity deviation).

FR-35 – Show/hide advanced features  
The system must allow hiding or showing advanced UI features via settings toggles.  
Verification: Change a toggle and confirm UI elements appear/disappear accordingly.

## Non-Functional Requirements (NFR)

NFR-01 – Minimalist and clear UI  
The UI must be minimalist, clear, and non-distracting during search/entry.  
Verification: User testing and heuristic evaluation.

## Project Structure

This project has the following basic structure (subject to change and expansion).
1. lib
    1. controller (directory)
    2. database (directory)
    3. generated (directory)
    4. model (directory)
    5. screens (directory)
    6. services (directory)
    7. utils (directory)
    8. widgets (directory)
    9. app_theme.dart
    10. main.dart

## UI Reference

This project follows a design style inspired by existing calorie tracking applications.  
To ensure consistency, several screenshots are provided in the `assets/reference_ui/` directory as reference material.  
These screenshots are only for design inspiration and are not part of the functional application.

## UI Implementation Guide (MCP/Figma)

The final UI will be pulled from Figma via MCP. Start with the onboarding flow to validate the pipeline, then scale to the rest of the app.

### Figma MCP Integration Rules (Flutter)

These rules define how to translate Figma inputs into Flutter code for this project and must be followed for every Figma-driven change.

Required flow (do not skip):
1. Run `get_design_context` first to fetch the structured representation for the exact node(s).
2. If the response is too large or truncated, run `get_metadata` to get the high-level node map and then re-fetch only the required node(s) with `get_design_context`.
3. Run `get_screenshot` for a visual reference of the node variant being implemented.
4. Only after you have both `get_design_context` and `get_screenshot`, download any assets needed and start implementation.
5. Treat MCP output (often React + Tailwind) as a design/behavior representation only; translate it into Flutter and this repo's conventions.
6. Validate against the Figma screenshot for 1:1 look and behavior before marking complete.

Implementation rules:
- Reuse the project's color tokens, typography scale, and spacing tokens.
- Replace any Tailwind-like utility classes with Flutter tokens and styles.
- Reuse existing Flutter components (buttons, inputs, typography, icon wrappers) instead of duplicating.
- Respect existing routing, state management, and data patterns used in the repo.
- If conflicts arise, prefer design-system tokens and adjust spacing or sizes minimally to match visuals.

### MCP Import Plan (Phase 1: Onboarding)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components): 59:369 (Welcome), 83:78 (Sign-in modal), 59:414 & 60:465 (Gender), 61:516 (Workouts), 61:594 (Height/Weight), 61:1238 (DOB), 62:1725 (Goal), 62:1776/62:1778 (Desired weight), 62:2930 (Weight-loss speed), 65:3137 (Diet), 65:3243 (Custom diet), 63:3073 (Calories burned), 67:3293 (Rollover), 68:2 (Loading plan), 68:70 (Plan ready), 81:18 (Save progress).
- Screens included (order): Welcome → Sign-in modal → Gender → Workouts → Height/Weight → DOB → Goal → Desired weight → Weight-loss speed → Diet → Custom diet → Calories burned → Rollover → Loading plan → Plan ready → Save progress.
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart` (tokens + theme).
- Assets exported (format + locations): planned `assets/onboarding/icons/` (SVG for UI icons), `assets/onboarding/illustrations/` (PNG for cards/illustrations), `assets/onboarding/flags/` (PNG/SVG).
- Notes on any Figma inconsistencies: mixed 15/16px paddings; 23.992/31.997px rounding to 24/32; Figma uses Inter but app uses Ubuntu per project constraint; large ruler picker node exceeds MCP context (used metadata + partial sublayer fetch).

### Design System Snapshot (from Figma)

Fill this after the first MCP import and keep it updated.

- Color tokens:
  - Primary: #0A0A0A
  - PrimaryMuted (gradient end): #4D4D4D
  - OnPrimary: #FFFFFF
  - Background/Surface: #FFFFFF
  - SurfaceMuted: #F3F4F6
  - SurfaceSubtle: #F9FAFB
  - SurfacePill: #F0F0F0
  - SurfaceChip: #D9D9D9
  - Border/Outline: #E5E7EB
  - TextSecondary: #6A7282
  - TextTertiary/Placeholder: #99A1AF
  - TextMuted: #4A5565
  - Accent (link/cta): #4F39F6
  - Info: #2B7FFF
  - Error: #FF2C2F
  - ErrorContainer: #FFE5E5
  - NeutralDark: #2D2D3A
  - Overlays: rgba(0,0,0,0.2), rgba(255,255,255,0.9), rgba(238,238,238,0.9)
  - SliderTrack: rgba(120,120,120,0.2)
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, Bold 700).
  - DisplayXL: 80/80 Bold
  - DisplayL: 40/60 Bold
  - H1: 34/42.5 Bold
  - H2: 32/40 Bold
  - H3: 28/35 Bold
  - H4: 24/30 Bold
  - H5: 20/30 Bold
  - Title: 17/25.5 SemiBold
  - Body: 15/22.5 Regular
  - BodySmall: 13/19.5 Regular
  - Picker: 16/24 Medium
- Spacing scale (e.g., 4/8/12/16/24/32): 4, 8, 12, 16, 24, 32, 40, 48, 56 (outliers: 15, 57.5).
- Radius scale (e.g., 8/12/16/20/24): 8, 10 (picker highlight), 16, 24, 32, pill (999).
- Elevation/shadows:
  - Card: 0 2 4 rgba(0,0,0,0.1)
  - Sheet/Screen: 0 20 25 -5 rgba(0,0,0,0.1) + 0 8 10 -6 rgba(0,0,0,0.1)
  - Slider knob: 0 0.5 4 rgba(0,0,0,0.12) + 0 6 13 rgba(0,0,0,0.12)
- Icon sizes: 16, 20, 24, 40.
- Gradients/patterns (if any): Primary button gradient (#0A0A0A → #4D4D4D), loading progress gradient (#FF6B6B → #C084FC → #60A5FA).

### Figma -> Flutter Mapping

- Naming convention for screens: `Onboarding<Name>Screen` (e.g., OnboardingGoalScreen).
- Naming convention for components: `Onboarding<Name>Card`, `Onboarding<Name>Button`, `Onboarding<Name>Picker`.
- Node ID to widget mapping (onboarding): 59:369 Welcome, 83:78 SignInModal, 59:414/60:465 Gender (unselected/selected), 61:516 Workouts, 61:594 HeightWeight, 61:1238 DOB, 62:1725 Goal, 62:1776 DesiredWeight, 62:2930 WeightLossSpeed, 65:3137 Diet, 65:3243 CustomDiet, 63:3073 CaloriesBurned, 67:3293 Rollover, 68:2 LoadingPlan, 68:70 PlanReady, 81:18 SaveProgress.
- Any ignored nodes (why): RulerPicker tick marks and iOS picker item lists truncated in MCP due to size; will be recreated with Flutter widgets (CupertinoPicker/CustomPainter).

### Screen Map and Flows

- Onboarding flow screens: Welcome, Sign-in modal, Gender, Workouts, Height/Weight, DOB, Goal, Desired weight, Weight-loss speed, Diet, Custom diet, Calories burned, Rollover, Loading plan, Plan ready, Save progress.
- Entry/exit points: Entry = Welcome; Exit = Plan ready → main app.
- Primary actions per screen: Gradient pill button (Continue/Skip), segmented choice cards, yes/no buttons.
- Error/empty/loading variants (if defined in Figma): Loading plan screen (progress + recommendations).

### Component Inventory (Reusable UI)

List components derived from Figma (even if the Figma file lacks true components).

- Buttons (primary/secondary/ghost): primary gradient pill (Continue/Yes/No/Skip), outlined pill (Google), text link (Terms/Privacy).
- Inputs (text fields, selectors): list options (16px radius), iOS pickers, ruler picker, textarea.
- Cards/surfaces: stat cards (rollover), workout cards, glass language chip.
- Chips/tags: “Recommended”, “Rollover up to 500 cals”.
- Progress/step indicators: top progress bar (thin line), loading progress bar.
- App bars/navigation: circular back button + top step indicator.
- Other shared widgets: circular macro rings, slider with ticks + knob, icon circle.

### Asset Pipeline

- Source of truth (Figma pages/frames): Onboarding flow frames listed above.
- Export formats (SVG/PNG/WebP): SVG for icons/illustrations; PNG for complex charts/illustrations if needed.
- Naming convention: `onboarding_<screen>_<asset>.svg|png`.
- Asset location in repo: `assets/onboarding/`.
- `pubspec.yaml` assets list updated: Not yet (Phase 2).

### Theming Strategy (Flutter)

- Theme entry point (file): `lib/app_theme_data.dart` (ThemeData for light/dark).
- ColorScheme usage (light/dark): light scheme aligned to Figma; dark theme kept minimal and derived from existing setup.
- TextTheme mapping: Ubuntu-based text scale in `AppThemeData`, aligned to Figma sizes/weights.
- Spacing/radius tokens location: `lib/app_theme.dart` (AppSpacing, AppRadii, AppSizes).
- Custom extensions (ThemeExtension): none yet (not needed in Phase 1).

### Layout and Responsiveness

- Base layout rules (padding, grid): 16px page gutters, 24px section gaps, 12px list gaps.
- Small vs large screens handling: use flexible spacing and scroll when content overflows.
- SafeArea usage: required for all onboarding screens.
- Min tap target size: 48x48.

### MCP Import Quality Checklist

- Colors match Figma tokens (no hardcoded magic colors). ✅
- Spacing and typography match Figma. ✅ (tokens mapped; widget use in Phase 2)
- Reusable widgets extracted (no large duplicated blocks). ⏳ (Phase 2)
- Theme is centralized and used across onboarding screens. ✅ (theme/tokens added)
- Onboarding flow is complete and navigable. ⏳ (Phase 2)

### MCP Import Plan (Phase 1: Dashboard, Progress, Profile)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components): 15:1981 (Dashboard empty state), 101:1184 (Dashboard with meals), 122:711 (Recognising meal card), 22:3068 (Progress), 33:3800 (Profile).
- Screens included (order): Dashboard → Progress → Profile (bottom nav), plus Recognising meal card (shared).
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart`, `pubspec.yaml` (fonts/assets).
- Assets exported (format + locations): planned `assets/figma/dashboard/`, `assets/figma/progress/`, `assets/figma/profile/`, `assets/figma/shared/` (SVG for icons, PNG for photos/illustrations).
- Variable defs: only `blackLinear` returned empty value (no usable variable tokens).
- Notes on any Figma inconsistencies: mixed 20/21/25px insets; repeated card shadows with two variants (cardSoft vs cardSmall); dashboard has two variants (empty vs with meals).

### Design System Snapshot (Dashboard/Progress/Profile)

- Color tokens:
  - Primary (FAB/CTA): #0A0A0A → #4D4D4D (gradient).
  - PrimarySoft/Ink: #0F172B (main text).
  - Background/Surface: #FFFFFF.
  - SurfaceMuted: #F3F4F6.
  - SurfaceSubtle: #F9FAFB.
  - Border (card/divider): #F1F5F9.
  - Outline (progress bars/indicators): #E5E7EB.
  - TextSecondary: #6A7282.
  - TextTertiary/Placeholder: #99A1AF.
  - TextMuted: #4A5565.
  - TextEmphasis: #314158.
  - TextDisabled: #D1D5DC.
  - Info/Blue: #2B7FFF.
  - Warning: #FDC700.
  - WarningSoft: #FFD6A8.
  - Success: #05DF72.
  - Orange: #FF6900.
  - Error/Protein: #FB2C36.
  - MacroCarbs: #FE9A00.
  - AvatarPurple: #AD46FF.
  - Overlays: rgba(0,0,0,0.6) (recognising card), rgba(0,0,0,0.2) (general).
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, Bold 700).
  - H1: 34/51 Bold (screen titles).
  - H2: 28/35 Bold.
  - H3: 24/32 Bold (dashboard header).
  - Title: 18/27 Bold/SemiBold (section titles).
  - Body16: 16/24 Medium/SemiBold.
  - Body14: 14/20 Medium/Regular.
  - Body13: 13/19.5 Regular (time labels).
  - Caption12: 12/16–18 Regular/Medium.
  - Label11: 11/16.5 SemiBold (calendar days).
  - Label10: 10/15 Medium (bottom nav).
  - Label9: 9/13.5 Bold (profile nav, widget labels).
- Spacing scale: 4, 8, 12, 16, 20, 24, 32, 40, 48 (outliers: 21, 25).
- Radius scale: 8, 12, 14, 16, 18, 20, 24, 32, pill (999).
- Elevation/shadows:
  - Card soft: 0 2 20 rgba(0,0,0,0.04).
  - Card small: 0 1 3 rgba(0,0,0,0.1) + 0 1 2 rgba(0,0,0,0.1).
  - Bottom nav: 0 8 30 rgba(0,0,0,0.08).
  - FAB: 0 10 15 rgba(15,23,43,0.2) + 0 4 6 rgba(15,23,43,0.2).
  - Recognising overlay: 0 4 4 rgba(0,0,0,0.25).

### Figma -> Flutter Mapping (Dashboard/Progress/Profile)

- Background: use `AppGradients.background` (white → #F9FAFB) on root containers.
- Glass/blur: recognising meal card uses blurred image + dark overlay (0.6); implement with `ImageFiltered.blur` + `Container(color: AppColors.overlayDark60)` + `ClipRRect`.
- Rings: calorie/macros rings are vector; implement with `CustomPainter` or `CircularProgressIndicator` + token colors; keep 64/90/125 sizes from tokens.
- Bottom nav: pill container with `AppShadows.navBar`, active item background `AppColors.surfaceMuted`, label size 10.
- FAB: 64x64 circle, primary gradient, `AppShadows.fab`.
- BMI bar: gradient from blue → yellow → red (`AppGradients.bmi`) + marker line.

### Theming Strategy (Flutter)

- Theme entry point: `lib/app_theme_data.dart` (ThemeData for light/dark).
- Token source of truth: `lib/app_theme.dart` (AppColors, AppSpacing, AppRadii, AppSizes, AppShadows, AppGradients, AppTextStyles).
- TextTheme mapping: `AppThemeData` uses `AppTextStyles` for Figma-aligned sizes; weights adjusted via `copyWith`.
- Naming conventions: semantic tokens (surfaceMuted, border, warning, macroProtein) over raw hex.

### Screen Map and Flows (Dashboard/Progress/Profile)

- Bottom navigation: Home (Dashboard) → Progress → Profile, persistent FAB (+) for add-meal actions.
- Dashboard variants: empty state (no meals) and populated list.
- Recognising meal card appears in dashboard list while AI runs.

### Component Inventory (Reusable UI)

- Bottom nav pill with active item state.
- Calendar strip (weekday + date, selected day ring).
- Daily summary card with ring + stat list.
- Macro stat cards (protein/carbs/fat).
- Meal cards (image + title/time + kcal + macro dots).
- Recognising meal card (blurred thumbnail + progress bars).
- Progress cards: My Weight, Day Streak, Weight Progress chart + segmented control.
- Daily Average empty-state card.
- BMI card with gradient bar + legend chips.
- Profile header (avatar + user info) and settings groups.
- Widget card + quick action tiles (Scan Food/Barcode).

### Asset Pipeline

- Source of truth (Figma pages/frames): Dashboard (15:1981, 101:1184), Recognising card (122:711), Progress (22:3068), Profile (33:3800).
- Export formats: SVG for icons/vectors, PNG for photos and blurred thumbnails.
- Naming convention: `dashboard_<name>.svg/png`, `progress_<name>.svg/png`, `profile_<name>.svg/png`, `shared_<name>.svg/png`.
- Asset location in repo: `assets/figma/` with per-screen subfolders.
- `pubspec.yaml` assets list updated: `assets/figma/` added. Ubuntu font already bundled.

### Layout and Responsiveness

- Base layout rules: 24px horizontal gutters, 16–24px vertical spacing between sections, 12px intra-list gaps.
- Use `SafeArea` + vertical scroll for long screens (Progress/Profile).
- Keep cards full-width, cap to 430px design width on large devices.
- Maintain 48px minimum tap targets (bottom nav/FAB already 64).

### Accessibility Notes

- Small text sizes (9–10px) require good contrast and sufficient spacing; avoid lowering opacity further.
- Ensure icon-only buttons have semantic labels and 48px tap area.
- Dashboard empty state uses low-contrast text; consider contrast checks if background changes.

### MCP Import Quality Checklist (Phase 1: Dashboard/Progress/Profile)

- `get_variable_defs` called once (only `blackLinear` empty). ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

### MCP Import Plan (Phase 1: Profile Area)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components): 37:4183 (Confirm username), 88:315 (Save progress / add email), 41:4204 (Personal Details), 42:4269 (Preferences), 44:4436 (Edit nutrition goals), 48:4648 (Tracking reminders), 50:4708 (Weight history list), 51:4780 (Weight history + Edit Entry sheet), 54:2 (Ring colors explained), 56:104 (Export PDF intro), 56:207 (Export PDF date range), 56:229 (Export PDF email).
- Screens included (order): Confirm username → Save progress → Personal details → Preferences → Edit nutrition goals → Tracking reminders → Weight history (list) → Weight history (edit entry sheet) → Ring colors explained → Export PDF intro → Export PDF date range → Export PDF email.
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart`, `pubspec.yaml` (fonts/assets).
- Variable defs: only `blackLinear` returned empty value (no usable variable tokens).
- Notes on selection gaps: main Profile screen node (33:3800) is not in this selection; reuse the existing profile main screen from the prior import unless a new node is provided.

### Design System Snapshot (Profile Area)

- Color tokens:
  - Primary gradient: #0A0A0A → #4D4D4D.
  - Background/Surface: #FFFFFF.
  - SurfaceMuted: #F3F4F6.
  - SurfaceSubtle: #F9FAFB.
  - SurfaceCard: #F8F9FA.
  - SurfaceCardBorder: #F8FAFC.
  - Border/Outline: #E5E7EB.
  - BorderStrong: #D1D5DC.
  - TextPrimary: #0F172B.
  - TextSecondary: #6A7282 (alt: #6B7280 on appearance pill).
  - TextTertiary/Placeholder: #99A1AF.
  - SuccessStrong (ring): #00C950.
  - Warning: #FDC700.
  - Error: #FB2C36.
  - Danger: #E7000B.
  - DangerSoft: #FEF2F2.
  - OverlayDark40: rgba(0,0,0,0.4).
  - Report illustration: #EF4444, #8B5CF6, #3B82F6.
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, Bold 700).
  - H1 Tight: 34/42.5 Bold (Ring Colors Explained).
  - H1: 32/40 Bold (Confirm username, Tracking Reminders).
  - H2: 28/35 Bold (Export PDF heading).
  - H3: 20/30 Bold (Calories AI app).
  - Title17: 17/25.5 SemiBold/Bold (list titles, buttons).
  - Body16: 16/24 Medium (helper text).
  - Body15: 15/22.5 Regular/Medium (list labels).
  - Body14 Relaxed: 14/22.75 Regular (long paragraphs).
  - Caption13: 13/19.5 Regular/Medium (toggle descriptions, appearance helper).
  - LabelUpper: 13/19.5 Medium with tracking 0.2488 (Weight/Date labels).
  - Label11: 11/16.5 Medium (weekday labels).
- Spacing scale: 8, 12, 16, 20, 24, 32 (outliers: 21, 23.992, 67 row height).
- Radius scale: 16 (inputs), 18 (nutrition goal inputs), 20 (list cards), 24 (settings cards), 32 (modal sheet), pill (999).
- Elevation/shadows:
  - Card subtle: 0 2 20 rgba(0,0,0,0.02).
  - Card lite: 0 2 10 rgba(0,0,0,0.02).
  - Control (toggle knob/pills): 0 1 3 rgba(0,0,0,0.1) + 0 1 2 rgba(0,0,0,0.1).
  - Button: 0 10 15 rgba(0,0,0,0.1) + 0 4 6 rgba(0,0,0,0.1).
  - Modal sheet: 0 25 50 -12 rgba(0,0,0,0.25).

### Figma -> Flutter Mapping (Profile Area)

- Gradient buttons: use `AppGradients.primary` with pill radius and `AppTextStyles.title17`.
- Segmented appearance selector: `Container` with `AppShadows.control`, `AppRadii.pill`, active segment gradient.
- Toggles: custom `AnimatedContainer` (51x31 track, 27 knob), track colors `AppColors.primarySoft` (on), `AppColors.outline` or `AppColors.borderStrong` (off), knob with `AppShadows.control`.
- Weight history edit drawer: `Container(color: AppColors.overlayDark40)` + bottom sheet with `AppShadows.modal`.
- Inputs: use `AppColors.surfaceCard` background, `AppColors.borderStrong` outline, `AppRadii.md`/`md2` radii.
- Ring colors calendar: 40x40 circles with 3px border in success/warning/error; selected day fills with `AppColors.primarySoft`.
- PDF illustration: export as PNG from Figma; render with `Image.asset` inside a 320px circle container.
- Dotted ring style is approximated with a solid border until a custom painter/dash border is added.

### Theming Strategy (Flutter)

- Token source of truth: `lib/app_theme.dart` (AppColors, AppSpacing, AppRadii, AppSizes, AppShadows, AppTextStyles).
- Theme entry point: `lib/app_theme_data.dart` uses `AppTheme.fontFamily` (Ubuntu).
- Avoid magic numbers; map outlier dimensions to nearest token or add a specific token when repeated.

### Screen Map and Flows (Profile Area)

- Main Profile screen (node 33:3800 from prior import) links to:
  - Confirm username (37:4183).
  - Save progress / add email (88:315).
  - Personal details (41:4204).
  - Preferences (42:4269).
  - Edit nutrition goals (44:4436).
  - Tracking reminders (48:4648).
  - Weight history list (50:4708) → Edit entry sheet (51:4780).
  - Ring colors explained (54:2).
  - Export PDF flow: Intro (56:104) → Date range (56:207) → Email (56:229).
- Gaps: Profile main screen node not in current selection; keep using node 33:3800 unless updated.

### Component Inventory (Profile Area)

- Top back button (circular, bordered).
- Gradient pill buttons (primary, action).
- Segmented appearance selector.
- List cards (detail rows with dividers).
- Toggle rows with time chip.
- Weight history cards + add button.
- Modal sheet with primary/destructive actions.
- Ring legend items and mini calendar strip.
- Export PDF feature list rows with leading icons.

### Asset Pipeline (Profile Area)

- Export formats: SVG for icons, PNG for the PDF illustration.
- Naming convention: `profile_<screen>_<asset>.svg/png`.
- Asset location in repo: `assets/figma/profile/` and `assets/figma/profile/icons/`.
- Icons/assets needed: back chevron, edit pencil, Apple/Google logos, appearance icons (system/light/dark), nutrition goal icons, PDF feature icons, close icon for sheet, delete icon.
- Current implementation uses Material icons as placeholders; replace with exported assets once available.

### Layout and Responsiveness (Profile Area)

- Base layout: 20px horizontal gutters, 24px vertical section spacing, 16px intra-card spacing.
- Use `SafeArea` and `SingleChildScrollView` for long screens.
- Keep card widths full screen (max 430px) with consistent corner radii.

### Accessibility Notes (Profile Area)

- Small text (11–13px) requires sufficient contrast; avoid lowering opacity further.
- Ensure toggle rows and icon-only buttons meet 48x48 tap targets.
- Add semantic labels for back/close/delete icons.

### UI State and Data Integration Notes (Profile Area)

- Toggles map to user preferences (live activity, burned calories, rollover, auto-adjust macros).
- Weight history is dynamic; edit drawer reads/writes entries.
- Export flow steps should validate inputs (date range selection, email format).
- Save progress connects to auth providers (Apple/Google) or skips.

### MCP Import Quality Checklist (Phase 1: Profile Area)

- `get_variable_defs` called once (only `blackLinear` empty). ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

### MCP Import Plan (Phase 1: Ask AI Profile Sub-screens)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components):
  - 175:3147 (Ask AI main + example questions, empty state)
  - 175:3199 (Ask AI response + summary + affected days, red/violations)
  - 177:3617 (Ask AI response + summary + affected days, green/achieved)
  - 177:3791 (Ask AI response + summary + affected days, yellow/tracked)
- Screens included (order): Ask AI main (empty + example questions) → Ask AI response variants (red, green, yellow).
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart`.
- Assets exported (format + locations): planned `assets/figma/ask_ai/` (SVG icons), `assets/figma/ask_ai/illustrations/` (PNG if needed).
- Variable defs: `greyWhiteLinear` returned `#FFFFFF,` (value appears incomplete).
- Notes on process: user-specified MCP order used (get_variable_defs → get_metadata → get_design_context → get_screenshot), which differs from the default AGENT flow.

### Design System Snapshot (Ask AI)

- Color tokens:
  - Ask AI primary gradient: #6366F1 → #8B5CF6.
  - Danger gradient: #EF4444 → #DC2626; surface: #FEF2F2 → #FEE2E2.
  - Success gradient: #10B981 → #059669; surface: #D1FAE5 → #A7F3D0.
  - Warning gradient: #F59E0B → #D97706; surface: #FEF3C7 → #FDE68A.
  - Example icon gradient: #FBBF24 → #F59E0B.
  - Text: Primary #0F172B, Body #374151, Heading #101828, Secondary #6B7280, Placeholder #99A1AF.
  - Surfaces: Background #FFFFFF, Subtle #F9FAFB, Muted #F3F4F6, Outline #E5E7EB.
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, SemiBold 600, Bold 700).
  - Title: 17/25.5 SemiBold (Ask AI title, section headers).
  - Body: 15/22 Regular (AI response text).
  - BodySmall: 14/20 Regular (example questions, placeholder).
  - Label: 13/19.5 Medium (summary label, legend labels).
  - Month label: 18/28 SemiBold.
  - Summary number: 48/48 Bold (gradient fill).
- Spacing scale: 8, 12, 16, 20, 24 (outliers: 19.99, 23.998).
- Radius scale: 24 (cards), 16 (inputs/buttons), 12 (calendar chips/legend), 10 (month control), 8 (icon pill).
- Elevation/shadows:
  - Card subtle: 0 2 20 rgba(0,0,0,0.02) (existing token).
  - Calendar day highlight: 0 4 6 rgba(0,0,0,0.1) + 0 2 4 rgba(0,0,0,0.1).
  - Small control: 0 1 3 rgba(0,0,0,0.1) + 0 1 2 rgba(0,0,0,0.1) (existing token).
- Glass/translucent surfaces: not present in selected Ask AI nodes.

### Figma -> Flutter Mapping (Ask AI)

- Ask AI top bar: centered title + circular back button with outline.
- Prompt input: `Container` with `AppColors.surfaceMuted`, 16 radius, leading search icon + placeholder, trailing clear icon.
- Primary action: gradient button using `AppGradients.askAiPrimary`, height ~54.5, 16 radius.
- Example questions: list of muted cards with 16 radius, body14 regular text in `AppColors.textBody`.
- AI response card: title row with gradient icon + body text.
- Summary card: gradient panel, big number rendered with `ShaderMask`, label text `AppTextStyles.labelUpper`/`caption12`-style sizing.
- Affected days: custom calendar grid; affected days use gradient fill + `AppShadows.calendarDay`, normal days use `AppColors.surfaceSubtle`.
- Legend: gradient swatch for Affected; outlined swatch for Normal.
- Actions: Export CSV (surface + shadow) and Share (primary gradient).

### Theming Strategy (Ask AI)

- Token source of truth: `lib/app_theme.dart` (added Ask AI gradients, colors, sizes, calendar shadow).
- Theme entry point remains `lib/app_theme_data.dart`; no theme replacement.

### Screen Map and Flows (Ask AI)

- Entry: Profile → Ask AI entry row/button (not in current selection).
- Main: Ask AI main (empty state + example questions).
- Variants: Ask AI response states (red violations, green achieved, yellow tracked).
- Actions: Ask AI submit, Export CSV, Share.
- Gaps: Profile Ask AI entry row/button and any chat-like UI, history, settings, paywall, permissions, or suggestions beyond the example list are not present in the selection.

### Component Inventory (Ask AI)

- AskAiTopBar (back button + title).
- AskAiPromptCard (search icon, placeholder, clear icon).
- AskAiPrimaryButton.
- AskAiExampleQuestionCard.
- AskAiResponseCard.
- AskAiSummaryCard (gradient background + gradient number).
- AskAiCalendarGrid + MonthSelector + Legend.
- AskAiDualActionButtons (Export CSV + Share).

### Asset Pipeline (Ask AI)

- Export formats: SVG for icons, PNG if any illustration appears later.
- Naming convention: `ask_ai_<screen>_<asset>.svg|png`.
- Asset location in repo: `assets/figma/ask_ai/` and `assets/figma/ask_ai/icons/`.
- Icons/assets needed: back chevron, search, clear/close, sparkle/AI, example question icon, AI response icon, summary icons (red/green/yellow), calendar icon, month chevrons, download/export, share.

### Layout and Responsiveness (Ask AI)

- Base layout: 16px horizontal gutters, 24px vertical section spacing, 12px intra-list gaps.
- Use `SafeArea` and scroll for long content (response variants).
- Keep card widths full screen (max 430px); buttons align to full width.

### Accessibility Notes (Ask AI)

- Ensure 48x48 tap targets for back button and month controls.
- Maintain contrast for small labels (11–13px) against muted backgrounds.
- Provide semantic labels for icon-only buttons (back, clear, month arrows).

### UI State and Data Integration Notes (Ask AI)

- Implement UI with stubbed data; no real AI/network integration in Phase 2 unless existing service is wired.
- Provide placeholder response content matching the three Figma variants.

### MCP Import Quality Checklist (Phase 1: Ask AI)

- `get_variable_defs` called once (returned `greyWhiteLinear`). ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

### MCP Import Plan (Phase 1: Meal Detail Feature Set)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components):
  - 136:1194 (Meal Detail Screen)
  - 159:1059 (Meal Detail Screen variant with calories delta)
  - 142:2404 (Meal Detail variant with allergy alert + ingredient row highlight)
  - 163:1477 (Ingredient Detail Screen)
  - 156:202 (Fix Result Screen)
  - 159:931 (Report Meal Screen)
  - 151:3993 (Meal detail action sheet: Share/Report/Save/Delete)
  - 151:3957 (Portion picker sheet)
  - 150:3855 (Mealtime picker sheet)
  - 150:3704 (Date picker card)
  - 161:1306, 161:1277, 161:1292 (Sync cards)
  - 159:1056, 147:2800, 147:2808 (Match badge variants)
- Screens included (order): Meal Detail → Ingredient Detail → Fix Result → Report Meal (+ modal sheets and pickers).
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart`, `lib/screens/meals/...`, `lib/widgets/...`.
- Assets exported (format + locations): planned `assets/figma/meals/` (PNG for meal photo placeholder, SVG for icons).
- Variable defs: `blackLinear` empty, `Number 3` = `-1` (no usable variable tokens).
- Notes on process: user-required MCP order used (get_variable_defs → get_metadata → get_design_context → get_screenshot), which differs from AGENT default ordering.

### Design System Snapshot (Meal Detail Feature Set)

- Color tokens:
  - BackgroundAlt: #FAFAFA (screen base on Meal Detail).
  - Card/Surface: #FFFFFF.
  - Border/Outline: #E5E7EB (pill button), #F3F4F6 (card borders/dividers).
  - TextPrimary: #0A0A0A; TextHeading: #101828; TextSecondary: #6A7282; TextEmphasisAlt: #364153.
  - Match badge: Green bg #DCFCE7 / text #008236; Yellow bg #FEF9C2 / text #A65F00; Red bg #FFE2E2 / text #C10007.
  - Warning/Allergy: bg #FFF9E6; border/icon #FFB020; warning text #FF6900.
  - Macro dots: Protein #FB2C36; Carbs #FFB020; Fats #2B7FFF.
  - Action sheet glass: rgba(255,255,255,0.5) surface with blur.
  - Destructive: #FF0C15 (Delete).
  - Overlay on hero image: rgba(0,0,0,0.6) → transparent.
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, SemiBold 600, Bold 700).
  - Screen title: 32/48 Bold (Fix result, Report Meal).
  - Meal title: 24/36 Bold.
  - Ingredient name (Edit screen): 36/40 Bold.
  - Stat value: 48/48 Bold (calories).
  - Macro value: 24/32 Bold.
  - Section title: 16/24 SemiBold.
  - Body: 16/24 Regular/Medium; 14/21 SemiBold (ingredient names); 12/16 Regular (labels).
  - Badge text: 14/16.5 Medium.
- Spacing scale: 8, 12, 16, 20, 24, 32 (outliers: 15, 17.1).
- Radius scale: 10 (date cells), 16 (inputs), 24 (cards/sheets), 28 (sync cards), pill (999).
- Elevation/shadows:
  - Card small: 0 1 3 rgba(0,0,0,0.1) + 0 1 2 rgba(0,0,0,0.1).
  - Date selected: 0 4 6 rgba(0,0,0,0.1) + 0 2 4 rgba(0,0,0,0.1).
  - Sync cards: 0 10 15 rgba(0,0,0,0.1) + 0 4 6 rgba(0,0,0,0.1).
- Glass/translucent surfaces: action sheet uses semi-opaque white with blur; implement with `BackdropFilter` + `ClipRRect` + `Container(color: AppColors.glassSheet)`.

### Figma -> Flutter Mapping (Meal Detail Feature Set)

- Meal hero: image + top gradient overlay, time label (12/18), title (24/36), back + actions in translucent circles.
- Calories card: white 24 radius, 24px padding; large 48px value; match badge on right (green/yellow/red variants).
- Macro cards: 125x125, 24 radius, icon + label + value; use `AppShadows.cardSmall`.
- Meal record card: 24 radius, border #F3F4F6, 24px padding, 3 rows (Amount/Mealtime/Date); date chip uses 10 radius.
- Ingredient row: 80 height, 24 radius, left 16 padding, macro dots (5.99) + 11px labels, kcal on right.
- Allergy alert card: light yellow surface, #FFB020 border; use for top alert + highlighted ingredient row.
- Date picker: custom grid with 48px cells, 10 radius; selected day black circle + `AppShadows.calendarDay`.
- Mealtime/portion sheets: rounded 24, list items 28px height, trailing check icon.
- Action sheet: glass surface (0.5 white) with icons; Delete text in red.
- Fix/Report forms: 150px text area with 2px black border, example card, 0/500 counter; CTA uses gradient (report uses primary, fix uses violet/askAI gradient).
- Sync cards: 28 radius, stronger shadow, inline pill button + underlined text action.

### Theming Strategy (Flutter)

- Token source of truth: `lib/app_theme.dart` (AppColors/AppRadii/AppSizes/AppShadows/AppTextStyles).
- Theme entry point: `lib/app_theme_data.dart`; no replacement, only token additions.
- Map outlier 15px margins to 16px tokens; document deviations where required.

### Screen Map and Flows (Meal Detail Feature Set)

- Meal Detail: entry from Dashboard meal card; actions → Ingredient Detail, Fix Result, Report Meal.
- Ingredient Detail: back to Meal Detail; measurement chips + amount input; Done commits.
- Fix Result: text input + Update; optional sync cards shown after edits.
- Report Meal: text input + Report; return to Meal Detail.
- Modal sheets: action sheet (share/report/save/delete), portion picker, mealtime picker, date picker.

### Component Inventory (Meal Detail Feature Set)

- MealHeroHeader (image + gradient overlay + time + title + actions).
- CaloriesSummaryCard + MatchBadge (green/yellow/red).
- MacroMiniCard (Protein/Carbs/Fats).
- MealRecordCard (Amount/Mealtime/Date rows).
- IngredientRow + IngredientAlertRow.
- AllergyAlertCard.
- MeasurementChips (pill segmented).
- AmountInputField (rounded 16).
- BottomCTAButton (primary gradient + violet gradient variants).
- DatePickerCard.
- MealtimePickerSheet + PortionPickerSheet.
- ActionSheet (Share/Report/Save/Delete).
- SyncCard (two-action and always-sync variants).

### Asset Pipeline (Meal Detail Feature Set)

- Export formats: SVG for icons, PNG for meal photo placeholder if needed.
- Naming convention: `meals_<screen>_<asset>.svg|png`.
- Asset location in repo: `assets/figma/meals/` and `assets/figma/meals/icons/`.
- Icons/assets needed: back chevron, bookmark, share, sparkle/fix icon, report icon, save icon, delete icon, macro icons (protein/carbs/fats), warning/alert icon, checkmark, calendar chevrons, edit/trash.

### Layout and Responsiveness (Meal Detail Feature Set)

- Base layout: 16px gutters (map from 15px in Figma), 24px card padding, 12px row gaps.
- Use `SafeArea` and `SingleChildScrollView`/`CustomScrollView` with bottom CTA.
- Keep card widths full screen with max 430px; allow scroll for long ingredient lists.

### Accessibility Notes (Meal Detail Feature Set)

- Match badges and warning surfaces need sufficient contrast (green/yellow/red).
- Ensure 48x48 tap targets for top icons, chips, and row actions.
- Provide semantic labels for icon-only buttons (share/bookmark/delete).

### UI State and Data Integration Notes (Meal Detail Feature Set)

- Implement with stub data unless existing meal/ingredient models are wired.
- Provide variants for match badges and allergy alert rows.
- Sync cards appear only when calories/macros are edited.
- Gaps: no explicit loading/empty/error states or confirmation dialogs in the selected nodes.

### MCP Import Quality Checklist (Phase 1: Meal Detail Feature Set)

- `get_variable_defs` called once. ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

### MCP Import Plan (Phase 1: Scan + Add Meal / Record Flow)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components):
  - 125:750 (Scan onboarding 1: “Get the best scan”)
  - 126:922 (Scan onboarding 2: “AI analyzes your food”)
  - 126:967 (Scan onboarding 3: “Fix results, if necessary”)
  - 126:1012 (Scan onboarding 4: “For highest accuracy”)
  - 126:1057 (Scan onboarding 5: “For fastest process”)
  - 169:2290 (Scan camera: Scan Meal mode active)
  - 170:2380 (Scan camera: Barcode mode active + tip)
  - 170:2645 (Scan camera: Barcode mode + nutrition label tip card)
  - 171:2797 (Scan camera: Food label mode active)
  - 168:2148 (Scan preview + optional fields + Analyze button)
  - 119:159 (Dashboard Plus Button overlay; not part of scan flow but included in selection)
- Screens included (order): Onboarding 1 → 2 → 3 → 4 → 5 → Camera (Scan Meal / Barcode / Food label) → Preview (Retake/Help + optional fields) → Analyze CTA.
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart`, `AGENT.md`.
- Assets exported (format + locations): planned `assets/figma/scan/icons/` (SVG), `assets/figma/scan/illustrations/` (PNG for onboarding photo), `assets/figma/scan/placeholders/` (PNG for preview/nutrition label if needed).
- Variable defs: `Backgrounds/Primary` = `#FFFFFF` (only token returned).
- Notes on process: user-required MCP order used (get_variable_defs → get_metadata → get_design_context → get_screenshot), which differs from AGENT default ordering.
- Notes on inconsistencies: scanner frame stroke color varies (#0A0A0A vs #364153); mode selection state differs per screen (active mode background toggles between #0A0A0A and #101828); flash/gallery controls appear disabled with 0.25 opacity in some modes.

### Design System Snapshot (Scan + Add Meal)

- Color tokens:
  - Background/Surface: #FFFFFF, BackgroundAlt #F8F9FA, SurfaceMuted #F3F4F6, Outline #E5E7EB, BorderStrong #D1D5DC.
  - Primary text: #0A0A0A; Muted text: #4A5565; Secondary: #6A7282; Tertiary/Placeholder: #99A1AF; Status bar text: #1E2939.
  - Indicator inactive dot: #D1D1C8.
  - Scanner frame stroke: #0A0A0A (Scan Meal), #364153 (Barcode/Food label variants).
  - CTA gradients: #0A0A0A → #4D4D4D (onboarding), #6366F1 → #8B5CF6 (Analyze Meal).
  - Camera surface gradient: #F3F4F6 → #E5E7EB.
  - Disabled opacity: 0.25 for inactive controls.
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, SemiBold 600, Bold 700).
  - Onboarding title: 28/34 Medium.
  - Onboarding bullets: 17/24 Regular.
  - CTA buttons: 17/25.5 SemiBold (onboarding), 18/28 SemiBold (Analyze Meal).
  - Mode labels: 12/16 Medium.
  - Zoom labels: 14/20 Medium.
  - Tip headings: 20/28 Bold; tip body: 14/20 Regular.
  - Input placeholders: 16/24 Regular.
- Spacing scale: 6 (indicator dots), 12, 16, 20, 24, 28, 32.
- Radius scale: 8 (nutrition label), 16 (tiles/inputs), 24 (frame corners + preview image), 32 (onboarding image), pill (999).
- Elevation/shadows:
  - Camera controls: 0 4 6 rgba(0,0,0,0.1) + 0 2 4 rgba(0,0,0,0.1).
  - Bottom sheet/CTA: 0 10 15 rgba(0,0,0,0.1) + 0 4 6 rgba(0,0,0,0.1).
  - Preview image: 0 10 15 -3 rgba(0,0,0,0.1) + 0 4 6 -4 rgba(0,0,0,0.1).
  - Inputs/cards: 0 1 3 rgba(0,0,0,0.1) + 0 1 2 rgba(0,0,0,0.1).

### Figma -> Flutter Mapping (Scan + Add Meal)

- Onboarding template: image header (32 radius bottom), title + bullet list + dot indicator + primary gradient CTA.
- Camera screen: gradient surface background; top bar with circular icon buttons; center scan frame corners; zoom pill; bottom mode selector (Scan/Barcode/Food label); shutter cluster (flash + shutter + gallery).
- Tip overlays: centered heading + body + “Got it” button; optional nutrition label card overlay.
- Preview screen: top bar (close + Retake/Help capsule), preview image card, optional text input + text area, Analyze CTA with sparkle icon.
- Use tokens for all colors, radii, shadows, spacing; map camera button shadows to `AppShadows.cameraControl`.

### Theming Strategy (Scan + Add Meal)

- Token source of truth: `lib/app_theme.dart` (added scan colors, gradients, shadows, sizes, text styles).
- Theme entry point: `lib/app_theme_data.dart` (no replacement; use existing ThemeData).
- Map Figma blacks to `AppColors.primary` (#0A0A0A); use `AppColors.textEmphasisAlt` for frame stroke variants.

### Screen Map and Flows (Scan + Add Meal)

- Flow: Onboarding 1 → 2 → 3 → 4 → 5 → Camera (Scan Meal default) → Capture → Preview → Analyze → next Record step (not in selection).
- Mode variants: Scan Meal / Barcode / Food label (with tip overlays).
- Entry: Dashboard “Meal Scan” quick action (node 119:159 shows the entry sheet; scan screen itself is separate).

### Component Inventory (Scan + Add Meal)

- ScanOnboardingPage (image header + bullets + dots + CTA).
- BulletRow (icon + text).
- PageIndicatorDots (5 dots with active/inactive styles).
- CameraTopBar (close/help buttons).
- ScanFrameCorners (four corner strokes).
- ZoomPillToggle (.5x / 1x).
- ScanModeSelector (Scan/Barcode/Food label tiles).
- ShutterCluster (flash, shutter, gallery).
- TipOverlayCard (title + body + CTA).
- NutritionLabelCard (small card overlay).
- PreviewTopBar (close + Retake/Help).
- PreviewImageCard.
- OptionalTextField + OptionalTextArea.
- AnalyzeMealCTA (gradient + sparkle icon).

### Asset Pipeline (Scan + Add Meal)

- Export formats: SVG for icons, PNG for photos/illustrations.
- Naming convention: `scan_<screen>_<asset>.svg|png`.
- Asset location in repo: `assets/figma/scan/`.
- Icons/assets needed:
  - Onboarding bullet icons (camera, sun/light, eye/visibility, sparkle/check variants).
  - Camera: close, help, scan-target, barcode, food label, flash, gallery/photo.
  - Preview: sparkle/analyze icon.
  - Illustrations: onboarding photo, preview image placeholder (banana), nutrition label mock.

### Layout and Responsiveness (Scan + Add Meal)

- Base layout: 24px horizontal gutters on onboarding; 20px gutters on preview; bottom bar pinned with SafeArea.
- Camera UI: center frame with fixed corner size; adapt frame to available height; keep shutter cluster anchored.
- Use scroll for preview screen when keyboard or small device height causes overflow.

### Accessibility Notes (Scan + Add Meal)

- Ensure 48x48 tap targets for circular buttons and shutter controls.
- Maintain contrast for labels over camera feed; use scrim if needed.
- Provide semantic labels for icon-only controls (close, help, flash, gallery).

### UI State and Data Integration Notes (Scan + Add Meal)

- Use `permission_handler` for camera permissions (not shown in selection).
- Use `image_picker` or `camera` for capture (decision in Phase 2).
- Preview screen accepts optional name/notes; Analyze button triggers stubbed async (actual analysis wiring TBD).

### Gaps / Missing in Selection (Scan + Add Meal)

- Permission prompts (pre-permission, denied, denied-permanently).
- Capture confirmation / retake overlay states beyond preview.
- Loading/analyzing/progress screen and results entry point into the record flow.

### MCP Import Quality Checklist (Phase 1: Scan + Add Meal)

- `get_variable_defs` called once. ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

## Phase 2 Implementation Notes (Scan + Add Meal)

- Implemented screens and widgets under `lib/screens/scan/` (onboarding, camera, permissions, preview).
- Camera uses the `camera` package for a real preview and capture; gallery uses `image_picker`.
- Entry point wired via MainScreen add button bottom sheet (“Scan Meal”).
- Tip overlays are toggled via mode change/help button (Barcode + Nutrition Label variants).
- Placeholders used for onboarding images and icons (Material icons); replace with exported assets from Figma when available.
- Analyze action is stubbed (2s delay + snackbar) per requirement; wire to real AI service later if needed.

### Phase 2 Deviations / TODOs (Scan + Add Meal)

- Onboarding and preview images use gradient placeholders (no exported assets yet).
- Nutrition label card is a lightweight text mock; replace with asset or refined layout when assets are available.
- Permission screens are custom (not in Figma); designed to be minimal and consistent with tokens.

## License

This project is being developed for the purposes of a diploma thesis.

## Contact

Created by Jakub Andras.

### MCP Import Plan (Phase 1: Voice Log + Exercise Log)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components):
  - 202:7759 (Voice Log: Meals toggle + idle state)
  - 202:7819 (Voice Log: Exercise toggle + idle state)
  - 181:6053 (Voice Log: listening/recording state with placeholder)
  - 182:6096 (Voice Log: listening/recording with transcribed text)
  - 189:6505 (Exercise Log home list)
  - 190:7146 (Exercise Detail)
  - 197:7395 (Exercise Detail options sheet)
  - 189:6782 (Add Exercise: Total Calories variant)
  - 189:6845 (Add Exercise: Per Minute variant)
- Screens included (order): Voice Log (Meals) → Voice Log (Exercise) → Voice Log (Listening, empty) → Voice Log (Listening, transcribed) → Exercise Log Home → Exercise Detail → Exercise Detail Options → Add Exercise (Total) → Add Exercise (Per Minute).
- Output paths (Flutter): `lib/app_theme.dart`, `AGENT.md`.
- Variable defs: `blackLinear` returned empty value (no usable variable tokens).
- Notes on process: user-required MCP order used (get_variable_defs → get_metadata → get_design_context → get_screenshot), which differs from AGENT default ordering.

### Design System Snapshot (Voice Log + Exercise Log)

- Color tokens:
  - Primary/OnPrimary: #0A0A0A / #FFFFFF (existing).
  - Background/Surface: #FFFFFF; BackgroundAlt: #F8F9FA; SurfaceMuted: #F3F4F6.
  - Outline/Border: #E5E7EB.
  - TextPrimary: #0A0A0A; TextSecondary/Placeholder: #99A1AF; Toggle inactive label: #9CA3AF.
  - Voice accent: #7C3AED (mic + listening label).
  - Voice analyze gradient: #6366F1 → #8B5CF6 (50% opacity in idle/disabled state).
  - Primary gradient: #0A0A0A → #4D4D4D (pill buttons, toggle track).
  - Exercise icon gradients: #F97316 → #EF4444 (calories), #F97316 → #EA580C (kcal/min), #06B6D4 → #0891B2 (duration).
  - Frosted surface gradient: rgba(243,244,246,0.5) → rgba(229,231,235,0.5) (voice log container).
  - Glass sheet: rgba(255,255,255,0.5) (exercise detail options sheet).
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu (Regular 400, Medium 500, SemiBold 600, Bold 700).
  - Titles/Top bars: 18/27 SemiBold.
  - Card headings: 18/27 SemiBold.
  - Section labels: 14/21 Medium.
  - Body/helper text: 14/22.75 Regular; placeholder 14/20 Regular.
  - CTA buttons: 18/22.5 SemiBold.
  - Stat values: 24/36 SemiBold (cards), 36/54 SemiBold (total calories burn card).
- Spacing scale: 8, 12, 16, 20, 24, 32 (Figma values 11.99, 23.998 mapped to 12/24).
- Radius scale: 12 (icon tiles), 16 (inputs), 24 (cards/sheets), 32 (top sheet corners), pill (999).
- Elevation/shadows:
  - Card: 0 1 3 rgba(0,0,0,0.1) + 0 1 2 rgba(0,0,0,0.1).
  - Voice input card: 0 2 20 rgba(0,0,0,0.02).
  - Floating mic button: 0 10 15 rgba(0,0,0,0.1) + 0 4 6 rgba(0,0,0,0.1).
  - Top icon buttons: 0 4 6 rgba(0,0,0,0.1) + 0 2 4 rgba(0,0,0,0.1).
- Glass/translucent surfaces: voice log container uses a frosted gradient; options sheet uses semi-opaque white. Implement via `BackdropFilter` + `ClipRRect` + `Container` with gradient/color.

### Figma -> Flutter Mapping (Voice Log)

- Base layout: top handle (48x4), centered toggle (Meals/Exercise), frosted container with text area + CTA, helper copy, floating mic button.
- Text area: `Container` with `AppColors.surfaceMuted`, radius 16, 16px padding, placeholder text.
- Analyze CTA: gradient `AppGradients.voiceAnalyze` with 0.5 opacity when disabled; sparkle icon on left.
- Toggle switch: gradient track (primary) + white knob, labels use active/disabled colors.
- Mic control: circular 80x80; Meals uses primary gradient; Exercise/listening uses solid #7C3AED; label “Listening...” in same violet.
- No waveform/timer UI in selection; record cluster is just mic button + state label.

### Figma -> Flutter Mapping (Exercise Log)

- Exercise list cards: white surface, 24 radius, 20px padding, left content with title + two icon/value rows (kcal + min), trailing add button (47.995, black fill).
- Search bar: outlined pill, 24 radius, left search icon, placeholder text.
- Filter chips: “All” filled black, “Favorites” outline with icon.
- Exercise detail: dark gradient hero card (activity + title), stat cards (2-up), single-row info card, calculation card with divider and two rows.
- Add Exercise form:
  - Input rows: label + rounded text input (24 radius).
  - Tracking method cards: two option tiles; selected uses `surfaceSelected` fill + primary border; unselected uses white + outline.
  - Total calories input card: icon tile + large numeric input + unit suffix.
  - Per-minute variant: two input cards (kcal/min, duration) plus total calories summary card (primary gradient).
- Bottom action bars: pill primary gradient buttons with 56 height; secondary action uses outline + gradient text.
- Options sheet: glass panel, 24 radius, two rows (Report, Delete) with icons; Delete in red.

### Theming Strategy (Voice Log + Exercise Log)

- Token source of truth: `lib/app_theme.dart` (added frost colors, violet accent, exercise gradients, new sizes and text styles).
- Theme entry point: `lib/app_theme_data.dart` unchanged (no replacement); use existing `ColorScheme` + new tokens for widgets.
- Map fractional Figma values (e.g., 23.998, 11.99, 1.078) to 24/12/1 px tokens.

### Screen Map and Flows (Voice Log + Exercise Log)

- Voice Log flow: Toggle Meals (idle) → Toggle Exercise (idle) → Listening (empty) → Listening (transcribed).
- Exercise Log flow: Exercise Log Home → Exercise Detail → Detail Options sheet → Add Exercise (Total) / Add Exercise (Per Minute).
- Entry points: Voice Log entry from log creation; Exercise Log entry from main log list (not in selection).

### Component Inventory (Voice Log + Exercise Log)

- VoiceLogTopBar (back + info buttons).
- VoiceLogToggleSwitch (Meals/Exercise).
- VoiceLogTextAreaCard + HelperCopy.
- VoiceLogAnalyzeButton (gradient + sparkle icon).
- VoiceLogMicButton + ListeningLabel.
- ExerciseSearchBar.
- ExerciseFilterChips.
- ExerciseCardRow (title + kcal/min rows + add button).
- ExerciseDetailHeroCard.
- ExerciseStatCard (kcal, duration).
- ExerciseInfoRowCard (kcal/min).
- ExerciseCalculationCard.
- ExerciseTrackingModeCard (selected/unselected).
- ExerciseInputCard (icon + number + unit).
- ExerciseTotalBurnedSummary (gradient numeric card).
- ExerciseBottomActionBar (primary + secondary).
- ExerciseOptionsSheet.

### Asset Pipeline (Voice Log + Exercise Log)

- Export formats: SVG for icons, PNG only if a raster asset appears later.
- Naming convention: `voice_log_<screen>_<asset>.svg`, `exercise_log_<screen>_<asset>.svg`.
- Asset locations: `assets/figma/voice_log/` and `assets/figma/exercise_log/`.
- Icons/assets needed:
  - Voice Log: back chevron, info/help, mic, sparkle/analyze.
  - Exercise Log: search, favorites, add/plus, bookmark, more/ellipsis, back chevron.
  - Exercise Detail: calories flame, duration clock, kcal/min arrow, report, delete.

### Layout and Responsiveness (Voice Log + Exercise Log)

- Base layout: 24px horizontal gutters, 16px card padding, 12px intra-row gaps.
- Use `SafeArea` for top controls and bottom action bars.
- Cards should stretch to full width with max 430px; allow scrolling for long forms.

### Accessibility Notes (Voice Log + Exercise Log)

- Ensure 48x48 tap targets for top buttons, mic control, add buttons, and action bar CTAs.
- Maintain contrast for labels over gradients (voice CTA, summary card).
- Provide semantic labels for icon-only buttons (back, info, add, options).

### UI State and Data Integration Notes (Voice Log + Exercise Log)

- Voice Log: implement mic permission gating and recording states in Phase 2; waveform/timer not defined in selection (placeholder if required).
- Exercise Log: use simple local state for form inputs; validate required fields only for CTA enable.

### Gaps / Missing in Selection (Voice Log + Exercise Log)

- Voice Log: permission prompt screens, paused state, playback/review, confirm/save, error/empty states, waveform/timer/progress UI, transcript card, and playback controls are not present in selection.
- Exercise Log: date/time pickers, intensity selectors, notes fields, confirmation screen, and empty/error states are not present in selection.

### MCP Import Quality Checklist (Phase 1: Voice Log + Exercise Log)

- `get_variable_defs` called once (returned empty `blackLinear`). ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

## Phase 2 Implementation Notes (Voice Log + Exercise Log)

- Implemented Voice Log under `lib/screens/logs/voice_log/` with permission gating, recording start/stop, and pause/resume (long-press) using the `record` package.
- Recording output is saved to a temp file path; transcription is stubbed with sample text until a real STT service is wired.
- Analyze action is stubbed with a snackbar; no backend integration.
- Exercise Log implemented under `lib/screens/logs/exercise_log/` (home, detail, add form, options sheet) with local state and placeholder data.
- Options sheet uses glass blur + translucent background to match Figma.

### Phase 2 Deviations / TODOs (Voice Log + Exercise Log)

- Waveform/timer UI and playback/review/confirm screens are not present in the Figma selection and are not implemented.
- Voice permission screens are custom (not in Figma) but follow existing token styling.
- Exercise pickers/date-time/intensity/notes screens are not present in selection and are not implemented.

## MCP Import Plan (Phase 1: Select a Meal Flow)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components):
  - 161:1320 (Select a Meal screen)
  - 164:1840 (MealCard variant with inline macro string)
  - 178:4437 (Mealtime Picker sheet)
- Screens included (order): Select a Meal → Mealtime Picker sheet (modal) + MealCard component variant.
- Output paths (Flutter): `lib/app_theme.dart`, `AGENT.md`.
- Assets exported (format + locations): planned `assets/figma/select_meal/icons/` (SVG), `assets/figma/select_meal/images/` (PNG for meal image placeholder).
- Variable defs: empty (no usable variable tokens).
- Notes on process: user-required MCP order used (get_variable_defs → get_metadata → get_design_context → get_screenshot), which differs from AGENT default ordering.
- Notes on any Figma inconsistencies: Meal card appears in two variants (macro dots row vs inline macro string). Default to macro-dot row from 161:1320; document inline variant as alternate.

## Design System Snapshot (Select a Meal)

- Color tokens:
  - Background: #F8F8F8 (screen), Surface: #FFFFFF, Search surface: #F3F3F5.
  - Outline/Divider: #E5E7EB; Card border: #F1F5F9.
  - Text: Primary #0A0A0A, Heading #0F172B, Secondary #6A7282, Tertiary/Placeholder #99A1AF.
  - Macros: Protein #FB2C36, Carbs #FE9A00, Fats #2B7FFF (dots ~0.7 opacity, inline text ~0.75–0.8).
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu.
  - Screen title: 16/24 SemiBold (letterSpacing -0.3125).
  - Section header: 18/27 SemiBold (letterSpacing -0.4395).
  - Tab labels: 14/21 Medium (letterSpacing -0.1504).
  - Meal title: 16/24 SemiBold.
  - Macro values: 12/18 Medium; kcal value: 16/24 Bold; kcal label: 12/18 Regular.
  - Ingredient title: 15/22.5 SemiBold; subtitle: 13/19.5 Regular.
  - Quick action label: 11/13.75 Medium (letterSpacing 0.0645).
  - Mealtime picker items: 16/28 SemiBold (letterSpacing -0.4492).
- Spacing scale: 8, 12, 16, 24 (gutters), 48 (search left inset).
- Radius scale: 16 (cards/tiles), 24 (sheet), pill (search bar).
- Elevation/shadows:
  - Action tiles / ingredient rows: 0 1 3 + 0 1 2 rgba(0,0,0,0.1).
  - Meal cards: 0 2 20 rgba(0,0,0,0.04).

## Figma -> Flutter Mapping (Select a Meal)

- Top bar: back icon + centered title with chevron (mealtime picker trigger).
- Search bar: pill surface with search icon; use `AppColors.surfaceSearch`, height 48, left inset 48.
- Segmented tabs: “All / Favorites / Meals / Ingredients” with underline for active; inactive text uses `AppColors.textTertiary`.
- Quick actions: four 86.5x75 tiles (meal scan, barcode scan, voice log, manual log) using `AppShadows.cardSmall`.
- Meals section: header + “Most Recent” button (sort) with icon; list of `MealCard` rows.
- Meal card: image 90x90, title, macro dots row + kcal; alternate inline macro string variant (node 164:1840).
- Ingredients section: compact rows with title/subtitle and trailing add button (32x32 black).
- Mealtime Picker: sheet with 24 radius, 12/16 padding; 28px rows with 24px check icon.

## Theming Strategy (Select a Meal)

- Token source of truth: `lib/app_theme.dart` (added select meal colors/sizes/text styles).
- Theme entry point: `lib/app_theme_data.dart` unchanged; use new tokens in widgets.
- Map Figma blacks to `AppColors.primary` (#0A0A0A) and headings to `AppColors.textPrimary` (#0F172B).

## Screen Map and Flows (Select a Meal)

- Flow: Log meal → Select a Meal → (choose meal/ingredient or quick action) → next step (edit/confirm).
- Mealtime picker opens from title dropdown (Breakfast/Lunch/Dinner/Snack).
- Tabs switch dataset scope (All/Favorites/Meals/Ingredients).

## Component Inventory (Select a Meal)

- SelectMealSearchBar
- SelectMealTabs (segmented)
- SelectMealQuickActionTile
- SelectMealSectionHeader (with sort action)
- MealCard (macro dots + kcal)
- MealCardInlineMacro (variant)
- IngredientRowCompact (with add button)
- MealtimePickerSheet

## Asset Pipeline (Select a Meal)

- Export formats: SVG for icons; PNG for meal image placeholder.
- Naming convention: `select_meal_<screen>_<asset>.svg|png`.
- Asset location in repo: `assets/figma/select_meal/`.
- Icons/assets needed:
  - Top bar: back/close, chevron.
  - Search, sort/filter.
  - Quick actions: meal scan, barcode scan, voice log, manual log.
  - Plus/add icon, check icon.
  - Meal photo placeholder (round thumbnail).

## Layout and Responsiveness (Select a Meal)

- Base layout: 24px horizontal gutters; 16px section gaps; 8px list row gaps.
- Use `SafeArea` and scroll for list content; quick actions stay near top.
- Keep cards full width with max 430px; handle small screens via scroll.

## Accessibility Notes (Select a Meal)

- 48x48 tap targets for top bar buttons, quick actions, add buttons, and sort control.
- Provide semantic labels for icon-only buttons (back, search, add, sort).
- Ensure sufficient contrast for placeholder text and macro colors.

## UI State and Data Integration Notes (Select a Meal)

- Use existing `Meal` and `Ingredient` models; source from Floor DAOs or DayRecordController history.
- “Most Recent” sort should map to `Meal.timestamp`.
- Search filters should debounce locally (if using local list); favorites flag not present in model (needs mapping or extension).

## Gaps / Missing in Selection (Select a Meal)

- Empty, loading, error, and no-results states not present in selection.
- No explicit “search active” variant, multi-select state, or bottom confirmation bar shown.
- No ingredients-only screen variant or favorites filled state shown.
- No ingredient detail peek/sheet in selection.

## MCP Import Quality Checklist (Phase 1: Select a Meal Flow)

- `get_variable_defs` called once (empty). ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅

## Phase 2 Implementation Notes (Select a Meal)

- Implemented Select Meal flow under `lib/screens/log_meal/select_meal/` with search, segmented tabs, quick actions, meals/ingredients sections, and mealtime/sort sheets.
- Wired Log Meal quick action to open `SelectMealScreen` from `lib/screens/main_screen.dart`.
- Data uses DayRecordController if present; falls back to mock meals/ingredients to match Figma layout.
- Search is debounced (250ms) and filters meals/ingredients; sort toggles via a picker sheet.

### Phase 2 Deviations / TODOs (Select a Meal)

- No Figma-defined empty/loading/error states; implemented minimal placeholders using existing tokens.
- Figma meal thumbnail image is mocked as a gray placeholder; export real asset when available.
- Favorites state is mocked (no data model support yet).

## MCP Import Plan (Phase 1: Edit Meal + Edit Ingredient)

- Figma file or URL: https://www.figma.com/design/rrhjcqMf3or0uisF2fkI3U/Diplomka?m=dev
- Node IDs (screens and key components):
  - 136:1194 (Edit Meal default state)
  - 159:1059 (Edit Meal with calories delta)
  - 142:2404 (Edit Meal with allergy alert + highlighted ingredient row)
  - 151:3993 (Action sheet: Share / Report / Save Image / Delete)
  - 151:3957 (Portion picker)
  - 150:3855 (Mealtime picker)
  - 150:3704 (Date picker)
  - 159:1056 / 147:2800 / 147:2808 (Match badge variants: green/yellow/red)
  - 161:1306 / 161:1277 / 161:1292 (Sync cards)
  - 163:1477 (Edit Ingredient screen)
  - 159:931 (Report Meal screen)
- Screens included (order): Edit Meal → Mealtime picker → Portion picker → Date picker → Report Meal → Edit Ingredient (via ingredient row) → Sync cards (optional prompt stack).
- Output paths (Flutter): `lib/app_theme.dart`, `lib/app_theme_data.dart`, `AGENT.md`.
- Variable defs: `purpleLinear` empty value (no usable tokens).
- Notes on process: user-required MCP order used (get_variable_defs → get_metadata → get_design_context → get_screenshot).
- Notes on any Figma inconsistencies:
  - Macro carbs dot uses #FFB020 here vs #FE9A00 elsewhere; created `AppColors.macroCarbsStrong` and default to this flow’s hue.
  - Horizontal padding appears as 15px; preserved as `AppSpacing.edge`.
  - Meal record card height varies (176 vs 192 across nodes); use padding-driven layout.
  - “Meal Detail Screen” label appears to be the editable meal flow (Fix Issue + Done), not a read-only detail screen.
  - Measurement chips row overflows width in Figma (5 chips); implement as horizontal scroll.

## Design System Snapshot (Edit Meal + Edit Ingredient)

- Color tokens:
  - BackgroundAlt: #FAFAFA (screen), Surface: #FFFFFF (cards).
  - SurfaceMuted/Separator: #F3F4F6 (dividers, date pill, chip base), SurfaceSubtle: #F9FAFB (example card).
  - Outline: #E5E7EB; Secondary text: #6A7282; Tertiary/placeholder: #99A1AF; Heading text: #101828.
  - Hero overlay: rgba(0,0,0,0.6); Glass buttons/sheet: rgba(255,255,255,0.5).
  - Match badges: green #DCFCE7 / #008236; yellow #FEF9C2 / #A65F00; red #FFE2E2 / #C10007.
  - Alert: background #FFF9E6; border #FFB020; warning text #FF6900.
  - Keyboard surface (iOS mock in Figma): #D1D5DB.
  - Macros: Protein #FB2C36, Carbs #FFB020, Fats #2B7FFF.
  - Destructive text: #FF0C15 (action sheet Delete).
- Typography tokens (font family + sizes/weights):
  - Family: Inter in Figma; implemented with Ubuntu.
  - Nav title: 18/27 Medium (letterSpacing -0.4395) → `AppTextStyles.navTitle18`.
  - Section header: 16/24 SemiBold (letterSpacing -0.3125) → `AppTextStyles.sectionHeader16`.
  - Form label/value: 16/24 Medium (letterSpacing -0.3125) → `AppTextStyles.formLabel16` / `formValue16`.
  - Body 16 Regular → `AppTextStyles.body16Regular`; input placeholder 16 Regular (letterSpacing -0.4316) → `AppTextStyles.inputPlaceholder16`.
  - Macro dot labels: 11/16.5 Medium (letterSpacing 0.0645) → `AppTextStyles.macroDotLabel11`.
  - Calories value: 48/48 Bold; macro values: 24/32 Bold; macro labels: 12/16 Regular.
  - Ingredient row title: 14/21 SemiBold; kcal value: 18/27 Bold; kcal label: 12/18 Regular.
  - Report title: 32/48 Bold; input placeholder/body: 16 Regular.
- Spacing scale: 8, 12, 15, 16, 24, 32.
- Radius scale: 10 (date pill), 16 (inputs), 24 (cards/sheets), 28 (sync cards), pill (999).
- Elevation/shadows:
  - Cards: 0 1 3 + 0 1 2 rgba(0,0,0,0.1).
  - Sync cards: 0 10 15 + 0 4 6 rgba(0,0,0,0.1).
  - Selected date: 0 4 6 + 0 2 4 rgba(0,0,0,0.1).

## Figma -> Flutter Mapping (Edit Meal + Edit Ingredient)

- Hero header: image + gradient scrim + time label + title (reuse `MealHeroHeader`, adjust text color).
- Match badge: pill with three variants (green/yellow/red) using `MatchBadge` + new colors.
- Calories card + macro cards: reuse `CaloriesSummaryCard` + `MacroStatCard` with updated tokens.
- Meal record card: 3 form rows (Amount, Mealtime, Date) with chevron/value styling.
- Ingredient rows: default + alert variant (orange border/background + warning text).
- Bottom action bar: outline “Fix Issue” + gradient “Done”.
- Action sheet: glass panel with 4 rows (Share/Report/Save Image/Delete).
- Pickers: Portion picker + Mealtime picker (simple list sheet with checkmark); Date picker (calendar grid).
- Edit Ingredient: top bar (back + delete), title, measurement chip row, amount input pill, calories + macros, bottom Done CTA.
- Report Meal: title + text input, 0/500 counter, example card, bottom Report CTA.
- Sync cards: small glass cards with CTA pair (Sync + underlined secondary).

## Theming Strategy (Edit Meal + Edit Ingredient)

- Token source of truth: `lib/app_theme.dart` (added `AppSpacing.edge`, `AppColors.separator`, `AppColors.keyboardSurface`, `AppRadii.xxl`, `AppSizes.editTopBarHeight`, `AppTextStyles.body16Regular`, `AppTextStyles.inputPlaceholder16`).
- Theme entry point: `lib/app_theme_data.dart` updated with `bottomSheetTheme` (24px top radius, white surface).
- Map fractional Figma values (e.g., 23.998, 47.703) to nearest tokens (24/48).

## Screen Map and Flows (Edit Meal + Edit Ingredient)

- Entry points:
  - Edit Meal from `SelectMealScreen`, `ScanPreviewScreen`, or `FixResultScreen`.
  - Edit Ingredient from ingredient row within Edit Meal.
- Exit points:
  - Done → back to previous screen.
  - Report Meal → submit → back.
  - Delete meal/ingredient → confirm → return to previous list.
- Optional prompts: Sync cards appear after AI fix/edit conflicts.

## Component Inventory (Reusable Edit Components)

- EditMealTopBar (glass icon buttons).
- MatchBadge (green/yellow/red).
- MealRecordCard (form rows).
- EditFormRow (label + tappable value + chevron).
- IngredientRow (default + alert variant).
- MeasurementChips, AmountInputField.
- BottomActionBar (outline + gradient).
- ActionSheet (glass, 4 rows).
- PickerSheet (mealtime/portion) and DatePickerCard.
- SyncCard (3 variants).
- ReportMealInput (textarea + counter + example card).

## Asset Pipeline (Edit Meal + Edit Ingredient)

- Export formats: SVG for icons; PNG for meal photo placeholder if needed.
- Naming convention: `edit_meal_<screen>_<asset>.svg|png`, `edit_ingredient_<screen>_<asset>.svg|png`.
- Asset locations: `assets/figma/edit_meal/`, `assets/figma/edit_ingredient/`.
- Icons/assets needed:
  - Top bar: back chevron, share, more, bookmark, delete.
  - Action sheet: share, report, save image, delete.
  - Alerts: warning/triangle icon.
  - Form: chevron, add/plus, check.
  - Macros: protein, carbs, fats icons (or use Material icons).

## Layout and Responsiveness (Edit Meal + Edit Ingredient)

- Base layout: 15px horizontal gutters (`AppSpacing.edge`), 16–24px section gaps, cards full-width up to 430px.
- Use `SafeArea` for top controls and bottom CTA bar; scroll for long ingredient lists.
- Keep button row pinned with keyboard-safe padding when editing report textarea.

## Accessibility (Edit Meal + Edit Ingredient)

- 48x48 tap targets for top bar buttons, add buttons, and CTA bar.
- Provide semantic labels for icon-only controls (back, share, delete, add).
- Preserve contrast on glass surfaces and alert cards.

## UI State and Data Integration Notes (Edit Meal + Edit Ingredient)

- Use `Meal` and `Ingredient` models; persist via `DayRecordController.saveMealForDate` and `deleteMeal`.
- Validation: meal name required if editable; numeric fields must be > 0; disable Done when invalid.
- For ingredient edits, update `Ingredient` list in-memory and resave meal on Done.
- Delete flows: confirm dialog/sheet for meal and ingredient deletion.

## Gaps / Missing in Selection (Edit Meal + Edit Ingredient)

- No explicit empty/error/loading states for edit forms.
- No explicit “add ingredient” flow or ingredient search/select screen.
- No explicit validation error messages or disabled CTA variants.
- No explicit delete confirmation dialog for meal/ingredient.

## MCP Import Quality Checklist (Phase 1: Edit Meal + Edit Ingredient)

- `get_variable_defs` called once (empty token). ✅
- `get_metadata` called for all nodes. ✅
- `get_design_context` called for all nodes. ✅
- `get_screenshot` called for all nodes. ✅
- Tokens/theme updated with extracted values. ✅
- AGENT.md updated with snapshot/mapping/plan. ✅
- UI implementation deferred until Phase 2. ✅
