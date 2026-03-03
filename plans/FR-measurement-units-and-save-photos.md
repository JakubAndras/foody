# FR: Measurement Units & Save Photos — Implementation Plan

## Status Summary

| Feature | Status | Action Needed |
|---------|--------|---------------|
| Save Photos to Gallery | ~90% done | Minor polish only |
| Measurement Units (Imperial/Metric) | ~50% done | Significant work needed |

---

## 1. Save Photos to Gallery (Minor Polish)

### What Already Works
- UI toggle in `preferences_screen.dart` (reactive via `Obx`)
- Persistent state: `SessionManager.savePhotosToGallery` ↔ `SharedPreferencesService`
- Auto-save after camera meal analysis (`dashboard_controller.dart:240-241`)
- Auto-save after barcode meal analysis (`dashboard_controller.dart:277-278`)
- Manual "Save Image" button in `edit_meal_screen.dart` action sheet
- `MediaStorage.saveToGallery()` using `image_gallery_saver` package
- Translations (EN & CS) complete
- iOS `NSPhotoLibraryAddUsageDescription` set

### Remaining Items (Optional Polish)
1. **Android 13+ permissions** — verify `AndroidManifest.xml` has `READ_MEDIA_IMAGES` for API 33+; `image_gallery_saver` plugin may handle this, but explicit declaration is safer
2. **Auto-save error feedback** — currently fire-and-forget; consider logging or showing a subtle toast on failure

---

## 2. Measurement Units — Imperial/Metric (Main Work)

### What Already Works
- `SharedPreferencesService` key: `profilePrefersMetricKey`
- `SessionManager.prefersMetric` (`RxBool`, default `true`), loaded on app init
- `SessionManager.setPrefersMetric(bool)` setter
- Onboarding height/weight screen has full Imperial/Metric toggle with conversion functions
- Onboarding goal-weight screen reads preference and converts display values
- Internal storage is always metric (kg/cm) — no data migration needed

### What's Missing

#### A. Preferences Screen — Add Toggle
**File**: `lib/screens/profile/subscreens/preferences_screen.dart`

Add a "Measurement units" row with an Imperial/Metric segmented toggle (like in the Figma image) to the "App settings" section. Wire it to `SessionManager.to.setPrefersMetric()`.

**UI spec** (from image):
- Label: "Measurement units"
- Toggle type: segmented control (two options: "Imperial" / "Metric")
- Current selection indicated by filled/dark segment

#### B. Translation Keys
Add to `assets/translations/en.json` and `cs.json`:
```json
"preferences_measurement_units": "Measurement units",
"preferences_imperial": "Imperial",
"preferences_metric": "Metric",
"common_kg": "kg",
"common_lb": "lb",
"common_cm": "cm",
"common_ft": "ft",
"common_in": "in"
```
Then regenerate locale keys.

#### C. Conversion Utility
Create a utility (or add to an existing utils file) with display conversion helpers:
```dart
// kg → lb for display, lb → kg for storage
double kgToLb(double kg) => kg * 2.20462;
double lbToKg(double lb) => lb / 2.20462;

// cm → feet+inches for display, feet+inches → cm for storage
double cmToInches(double cm) => cm / 2.54;
double inchesToCm(double inches) => inches * 2.54;

// Format weight with unit label
String formatWeight(double kg, bool prefersMetric) =>
    prefersMetric ? '${kg.toStringAsFixed(1)} kg' : '${kgToLb(kg).toStringAsFixed(1)} lb';

// Format height with unit label
String formatHeight(double cm, bool prefersMetric) => ...;
```

Note: onboarding screens already have `_cmToInches`, `_kgToPounds` etc. as private methods — extract and centralize.

#### D. Update Display Screens
All the following screens currently hardcode `kg`/`cm` and need to check `SessionManager.to.prefersMetric.value` and convert before display:

| Screen / Widget | File | What to Convert |
|----------------|------|-----------------|
| Personal Details | `lib/screens/profile/subscreens/personal_details_screen.dart` | Weight (kg→lb), Height (cm→ft/in) |
| Weight Log Sheet | `lib/screens/logs/weight_log_sheet.dart` | Weight input/display (kg↔lb) |
| Progress Screen | `lib/screens/progress_screen.dart` | Weight chart labels, BMI display |
| Weight Progress Card | `lib/widgets/weight_progress_card.dart` | Weight values on chart |
| Weight History Screen | `lib/screens/profile/subscreens/weight_history_screen.dart` | All weight entries |
| Export Service | `lib/services/export/export_service.dart` | CSV/PDF weight/height values |
| Dashboard Screen | `lib/screens/dashboard_screen.dart` | Any weight references |
| Onboarding Screens | Already done | No changes needed |

#### E. Input Conversion
Screens where the user **enters** weight/height values need to:
1. Display the input in the user's preferred unit
2. Convert back to metric (kg/cm) before saving

Key input screens:
- `weight_log_sheet.dart` — weight entry
- `personal_details_screen.dart` — height/weight editing

---

## Implementation Order

### Phase 1: Foundation
1. Add translation keys to `en.json` and `cs.json`
2. Regenerate locale keys
3. Create centralized conversion utility

### Phase 2: Preferences UI
4. Add Imperial/Metric segmented toggle to `preferences_screen.dart`

### Phase 3: Display Conversion
5. Update `personal_details_screen.dart` (height & weight display)
6. Update `weight_log_sheet.dart` (input + display)
7. Update `progress_screen.dart` (chart labels)
8. Update `weight_progress_card.dart` (chart values)
9. Update `weight_history_screen.dart` (history list)

### Phase 4: Export & Polish
10. Update export service to respect unit preference
11. (Optional) Save Photos polish — Android 13+ permissions, error feedback

---

## Estimated Scope
- **Files to modify**: ~10-12
- **New files**: 1 (conversion utility, unless added to existing utils)
- **Risk**: Low — internal storage stays metric, only display/input layer changes
- **Testing**: Verify toggle persists, all screens update reactively, input→save→display round-trips correctly in both unit systems
