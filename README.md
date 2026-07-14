# Foody

**AI-powered calorie tracking mobile app.** Photograph a meal, describe it by voice or text, or scan a barcode, and Foody estimates its nutritional values using a large language model.

Built with Flutter as the practical part of a master's thesis at the **Faculty of Electrical Engineering, Czech Technical University in Prague (ČVUT FEL)**.

![Flutter](https://img.shields.io/badge/Flutter-3.35-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/state-Riverpod-4c53c4)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)

## Overview

Foody simplifies meal logging. Instead of searching databases and weighing portions by hand, the user captures the meal (photo, spoken description, free text, or barcode) and the app returns an estimated dish name, ingredient breakdown, portion weight, and macronutrients. Everything is stored locally in an on-device database, so the app works offline for everything except the AI analysis itself.

The app is provider-agnostic on the AI side: **OpenAI is the primary provider**, with **Google Gemini** supported as an interchangeable alternative.

## Platform support

Foody was developed and tested primarily on **iOS**. It also runs on **Android**, but was validated on only a small number of Android devices, so platform-specific issues on Android are possible.

## Features

**Meal logging**
- Photo-based recognition using a multimodal LLM
- Text description recognition
- Voice input (locale-aware, cs/en) via speech-to-text
- Barcode scanning (EAN) with lookup against Open Food Facts
- Manual entry with gram/piece units
- Confidence indication on AI results (color-coded)
- Re-run recognition and "improve with AI" from the edit screen
- Favorites and a personal library of reusable meals, ingredients, and exercises

**Tracking and insight**
- Daily dashboard: intake vs. goal for calories and macros
- Weekly and monthly overviews, history, and charts
- Exercise tracking (manual, AI, voice, templates)
- Weight tracking with history and BMI
- Streaks and rollover calories
- Dietary restrictions with per-meal violation warnings
- Ask AI: natural-language questions over the user's own data

**Platform integration**
- Apple Health / Health Connect sync
- Home-screen widget for quick actions
- Configurable local reminders and motivational summaries
- Data export to PDF and CSV
- Localization (English, Czech)
- Offline-first local storage

## Tech stack

| Area | Choice |
|------|--------|
| UI & logic | Flutter / Dart |
| State management | Riverpod (`flutter_riverpod`) with `Notifier` / `AsyncNotifier`, co-located providers |
| Local database | Floor (SQLite ORM), normalized FK schema |
| Networking | Dio |
| AI | OpenAI (primary), Google Gemini (supported), provider-agnostic pipeline |
| Barcode data | Open Food Facts API |
| Voice | `speech_to_text` |
| Health | `health` (Apple Health / Health Connect) |
| Localization | `easy_localization` |

### Architecture at a glance

- **State**: reactive state and business logic live in `Notifier` / `AsyncNotifier` classes exposed via providers; plain services are exposed via `Provider`. Providers are co-located in the file of their class. Notifiers never navigate or show UI; the UI reacts via `ref.watch` / `ref.listen`.
- **Data**: Floor entities and DAOs, with a `DayRecordRepository` that assembles domain aggregates (day record + meals + ingredients + exercises) for the UI.
- **AI pipeline**: `Input → AiPipelineService → AiServiceManager (OpenAI | Gemini) → REST client → structured JSON → confidence gate → result`.

## Getting started

### Prerequisites

- Flutter SDK **3.35+** (Dart **3.9+**)
- Android Studio or VS Code with the Flutter/Dart plugins
- An API key for at least one AI provider (OpenAI, optionally Gemini)

### Setup

```bash
# 1. Clone
git clone https://github.com/JakubAndras/foody.git
cd foody

# 2. Create the environment file (git-ignored) in the project root
#    .env
#    OPENAI_API_KEY=sk-...
#    GEMINI_API_KEY=...      # optional

# 3. Install dependencies
flutter pub get

# 4. Generate database and model code
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

> The `.env` file is never committed. Without a valid API key the AI features will fail, but manual entry, barcode lookup, and tracking still work.

## Useful commands

```bash
flutter run                                                      # run the app
flutter build apk --release                                      # Android release
flutter build ipa --release                                      # iOS release
flutter pub run build_runner build --delete-conflicting-outputs  # regenerate DB / models
bash commands/generate_localization.command                      # regenerate localization keys
flutter analyze                                                  # static analysis
flutter test                                                     # unit / widget tests
dart format --line-length 180 lib/                               # format
```

## Project structure

```
lib/
├── main.dart          # entry point, DI bootstrap, runApp
├── app.dart           # MaterialApp, onboarding gate
├── di/                # shared providers + provider contract
├── state/             # Riverpod notifiers (UI state + business logic)
├── services/          # app-scoped services
├── database/          # Floor entities, DAOs, migrations
├── network/           # REST clients
├── model/             # data models
├── screens/           # UI screens
├── widgets/           # reusable UI components
└── utils/             # helpers
```

## Localization

Supported locales: English (`en`) and Czech (`cs`). Translation files live in `assets/translations/`. After editing them, regenerate the localization keys with `bash commands/generate_localization.command`.

## License

Developed for academic purposes as part of a master's thesis at ČVUT FEL. Not licensed for production or commercial use.

## Contact

Created by **Jakub Andras**.
