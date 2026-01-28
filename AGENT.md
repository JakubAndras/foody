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

- Figma file or URL: TODO
- Node IDs (screens and key components): TODO
- Screens included (order): TODO
- Output paths (Flutter): TODO
- Assets exported (format + locations): TODO
- Notes on any Figma inconsistencies: TODO

### Design System Snapshot (from Figma)

Fill this after the first MCP import and keep it updated.

- Color tokens: TODO
- Typography tokens (font family + sizes/weights): TODO
- Spacing scale (e.g., 4/8/12/16/24/32): TODO
- Radius scale (e.g., 8/12/16/20/24): TODO
- Elevation/shadows: TODO
- Icon sizes: TODO
- Gradients/patterns (if any): TODO

### Figma -> Flutter Mapping

- Naming convention for screens: TODO
- Naming convention for components: TODO
- Node ID to widget mapping (onboarding): TODO
- Any ignored nodes (why): TODO

### Screen Map and Flows

- Onboarding flow screens: TODO
- Entry/exit points: TODO
- Primary actions per screen: TODO
- Error/empty/loading variants (if defined in Figma): TODO

### Component Inventory (Reusable UI)

List components derived from Figma (even if the Figma file lacks true components).

- Buttons (primary/secondary/ghost): TODO
- Inputs (text fields, selectors): TODO
- Cards/surfaces: TODO
- Chips/tags: TODO
- Progress/step indicators: TODO
- App bars/navigation: TODO
- Other shared widgets: TODO

### Asset Pipeline

- Source of truth (Figma pages/frames): TODO
- Export formats (SVG/PNG/WebP): TODO
- Naming convention: TODO
- Asset location in repo: TODO
- `pubspec.yaml` assets list updated: TODO

### Theming Strategy (Flutter)

- Theme entry point (file): TODO
- ColorScheme usage (light/dark): TODO
- TextTheme mapping: TODO
- Spacing/radius tokens location: TODO
- Custom extensions (ThemeExtension): TODO

### Layout and Responsiveness

- Base layout rules (padding, grid): TODO
- Small vs large screens handling: TODO
- SafeArea usage: TODO
- Min tap target size: TODO

### MCP Import Quality Checklist

- Colors match Figma tokens (no hardcoded magic colors).
- Spacing and typography match Figma.
- Reusable widgets extracted (no large duplicated blocks).
- Theme is centralized and used across onboarding screens.
- Onboarding flow is complete and navigable.

## License

This project is being developed for the purposes of a diploma thesis.

## Contact

Created by Jakub Andras.
