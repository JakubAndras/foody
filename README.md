# Foody

**A mobile application for calorie tracking using AI**, developed as the practical part of a diploma thesis. Photograph a meal or describe it in text, and the app estimates its nutritional values using a publicly available large language model.

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/state-GetX-8A2BE2)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)

## Overview

This project is a cross-platform mobile application built with the Flutter framework. Its main purpose is to simplify the process of logging meals by allowing users to take a photo of their food, which is then analyzed by a publicly available artificial intelligence (e.g., Google Gemini) to return estimated nutritional values. The application serves as the practical part of a diploma thesis.

## Platform support

The application was developed and tested primarily on iOS. It also runs on Android, but was validated on only a small number of Android devices, so platform-specific issues on Android are possible.

## Features

- Automatic food analysis from a photograph using an external AI
- Automatic food analysis based on a text description using an external AI
- Display of estimated calories, macronutrients, and ingredients
- Barcode scanning for quick product entry
- Tracking of daily calorie intake and goals
- Display of statistics and intake history
- Simple and cross-platform user interface thanks to Flutter

## Tech stack

| Area | Choice |
|------|--------|
| UI & logic | Flutter / Dart |
| State management | GetX |
| AI | Publicly available AI (Google Gemini) for image analysis |
| Networking | Dio |
| Barcode data | Open Food Facts API |

## Core functionality

1. **AI food analysis**
   - The user takes a photo of the food directly in the app, or writes a description of the food.
   - The image is sent to the multimodal artificial intelligence API (e.g., Gemini API).
   - The AI analyzes the input and returns structured data in JSON format.
   - The JSON contains the estimated dish name, a list of ingredients, weight, and nutritional values (calories, proteins, carbohydrates, fats).
   - The app processes the data and displays it to the user for confirmation and logging into the daily summary, then stores it in the user database.
2. **Barcode logging**
   - The application allows barcode scanning (EAN) for quick lookup of commercial foods in the external Open Food Facts (OFF) database.
   - After successful code recognition, the nutritional values for the product are automatically retrieved and stored in the user database.
3. **Dashboard and statistics**
   - The main screen (dashboard) displays a daily summary of calories and nutritional values consumed versus the set goal.
   - The user has access to history and charts that visualize their eating habits over time.

## Getting started

### Requirements

- Flutter SDK **3.0+** (developed on 3.24.1)
- Dart SDK **3.0+** (developed on 3.5.1)
- Visual Studio Code or Android Studio
- A valid API key for a public AI service (e.g., Google Gemini API)

### Useful commands

```bash
flutter pub get                                                  # install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # regenerate DB / models
flutter run                                                      # run the app
```

## Project structure

The project has the following basic structure (subject to change and expansion):

```
lib/
├── controller/    # GetX controllers (state + logic)
├── database/      # local database
├── generated/     # auto-generated code
├── model/         # data models
├── screens/       # UI screens
├── services/      # app services
├── utils/         # helpers
├── widgets/       # reusable UI components
├── app_theme.dart
└── main.dart
```

## UI reference

This project follows a design style inspired by existing calorie tracking applications. To ensure consistency, several screenshots are provided in the `assets/reference_ui/` directory as reference material. These screenshots are only for design inspiration and are not part of the functional application.

## License

Developed for the purposes of a diploma thesis. Not licensed for production or commercial use.

## Contact

Created by **Jakub Andras**.
