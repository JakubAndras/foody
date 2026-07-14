A mobile application for calorie tracking using AI, developed as part of a diploma thesis.

## Overview

This project is a cross-platform mobile application built with the Flutter framework. Its main purpose is to simplify the process of logging meals by allowing users to take a photo of their food, which is then analyzed by a publicly available artificial intelligence (e.g., Google Gemini) to return estimated nutritional values. The application serves as the practical part of a diploma thesis.

## Platform support

The application was developed and tested primarily on iOS. It also runs on Android, but was validated on only a small number of Android devices, so platform-specific issues on Android are possible.

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
 - Dio package for network communication with the API.
 - GetX package for application state management.

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

## License

This project is being developed for the purposes of a diploma thesis.

## Contact

Created by Jakub Andras.

## Useful commands

 - generate db -> flutter pub run build_runner build --delete-conflicting-outputs

