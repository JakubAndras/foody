# FR-25: Health Integration — Burned Calories Sync (Apple Health + Health Connect)

## Overview

Add a health integration subscreen under Profile/Settings that allows users to sync **burned calories (active energy)** from the platform's native health provider:
- **iOS**: Apple Health (HealthKit)
- **Android**: Health Connect (Google's successor to Google Fit)

## Scope

- **Read-only**: We only **read** active energy burned — no writing back.
- **Both platforms**: Adaptive UI — shows "Apple Health" on iOS, "Health Connect" on Android.
- **Data synced**: Active energy burned — aggregated daily total.

---

## Package

**`health` (pub.dev)** — the most mature Flutter health data package. Supports both HealthKit (iOS) and Health Connect (Android).

```yaml
# pubspec.yaml
health: ^11.0.0  # Check latest version
```

Alternatives considered:
- `flutter_health_kit` — iOS-only, less maintained
- `apple_health` — iOS-only, smaller community
- `health_connect` — Android-only
- **`health`** wins because it's cross-platform, well-maintained, and handles both platforms with a single API.

---

## UI Design (from screenshot reference)

### Screen: `HealthIntegrationScreen` (new Profile subscreen)

The screen adapts its content based on platform.

**Layout:**
- `ProfileGradientScaffold` with `ProfileTopBar` (back button)
- Title: **"Sync to Apple Health"** (iOS) / **"Sync to Health Connect"** (Android)
- Subtitle: *"To manage which data Foody syncs to [platform], follow these steps:"*

**iOS instruction rows** (4 steps, each with icon + text):
1. Heart icon (Health app logo) — "Open the Health app."
2. Profile icon — "Tap your profile picture in the top right."
3. Hand/privacy icon — "Tap 'Apps' under Privacy."
4. App icon — "Tap 'Foody' and manage your preferences."

**Android instruction rows** (3 steps, each with icon + text):
1. Health Connect icon — "Open Health Connect app."
2. Apps icon — "Tap 'App permissions'."
3. App icon — "Tap 'Foody' and manage your preferences."

**Bottom CTA button:** **"Open Health App"** / **"Open Health Connect"** (dark/primary style, full-width, pinned)
  - iOS: Opens Apple Health app
  - Android: Opens Health Connect app (or Play Store if not installed)

**Additional UI elements (above the instructions):**
- A toggle row at the top: **"Sync Burned Calories"** with `ProfileToggle`
  - When enabled: requests health permission, starts syncing
  - When disabled: stops syncing, does not revoke permission (OS manages that)
- Last sync timestamp shown below the toggle (e.g., "Last synced: 2 min ago")

### Profile Screen Entry Point

Add a new row in the **"Goals & Tracking"** section of `profile_screen.dart`:
- Icon: Heart or Health-style icon
- Label: "Apple Health" (iOS) / "Health Connect" (Android) — localized
- Visible on both platforms

---

## Architecture

### New Files

| File | Purpose |
|------|---------|
| `lib/services/health_integration_service.dart` | GetxService — platform-agnostic health permission, data reading, sync logic |
| `lib/controller/health_integration_controller.dart` | GetxController — UI state for the health integration screen |
| `lib/screens/profile/subscreens/health_integration_screen.dart` | UI screen (adaptive per platform) |
| `lib/model/health_integration_setting.dart` | Model for sync preferences (enabled, lastSyncTimestamp) |

### Service: `HealthIntegrationService`

```
HealthIntegrationService extends GetxService
├── platformName: String       — "Apple Health" on iOS, "Health Connect" on Android
├── isEnabled: RxBool          — user toggle (persisted in SharedPreferences)
├── lastSyncTime: Rxn<DateTime> — last successful sync timestamp
├── hasPermission: RxBool      — health authorization status
│
├── requestPermission()        — Request read access for activeEnergyBurned
├── syncBurnedCalories(DateTime date) — Read daily burned calories from health provider
├── syncToday()                — Convenience: sync for today's date
├── getActiveEnergyBurned(DateTime date) → double?  — Raw read from health API
├── openHealthApp()            — Open native health app (Apple Health / Health Connect)
└── _persistSettings() / _loadSettings() — SharedPreferences read/write
```

**Under the hood**, the `health` package abstracts the platform differences:
```dart
// Same API on both platforms
final health = HealthFactory();
await health.requestAuthorization([HealthDataType.ACTIVE_ENERGY_BURNED]);
List<HealthDataPoint> data = await health.getHealthDataFromTypes(start, end, [HealthDataType.ACTIVE_ENERGY_BURNED]);
```

**Sync flow:**
1. User enables toggle → `requestPermission()` → if granted, `syncToday()`
2. On each app open (in `DashboardController.onInit` or `MainScreen`), if enabled → `syncToday()`
3. `syncBurnedCalories(date)`:
   - Reads `activeEnergyBurned` from health provider for the given date (00:00–23:59)
   - Sums all samples into a daily total
   - Updates the day's exercise data via `DayRecordRepository`
   - Stores as a special exercise entry with `source` = `"apple_health"` or `"health_connect"`

**Health data type (same on both platforms):**
```dart
HealthDataType.ACTIVE_ENERGY_BURNED  // from `health` package
```

### Controller: `HealthIntegrationController`

```
HealthIntegrationController extends GetxController
├── isEnabled: RxBool           — bound to HealthIntegrationService.isEnabled
├── lastSyncTime: Rxn<DateTime> — bound to HealthIntegrationService.lastSyncTime
├── isSyncing: RxBool           — loading state during sync
├── platformName: String        — from service
│
├── toggleSync(bool enabled)    — Enable/disable sync
├── openHealthApp()             — Launch native health app
└── manualSync()                — Trigger manual sync (optional)
```

### Model: `HealthIntegrationSetting`

```dart
class HealthIntegrationSetting {
  final bool enabled;
  final DateTime? lastSyncTimestamp;

  HealthIntegrationSetting({this.enabled = false, this.lastSyncTimestamp});
  HealthIntegrationSetting copyWith({bool? enabled, DateTime? lastSyncTimestamp});
}
```

---

## Storage

### SharedPreferences Keys

```dart
const String healthIntegrationEnabledKey = 'healthIntegration_enabled';
const String healthIntegrationLastSyncKey = 'healthIntegration_lastSync';  // ISO8601 string
```

Add getter/setter methods to `SharedPreferencesManager`.

### Exercise Entry for Synced Data

When syncing burned calories, create/update a special exercise entry:
- `name`: "Apple Health" (iOS) / "Health Connect" (Android)
- `caloriesBurned`: daily total from health provider
- `durationMinutes`: null (not tracked)
- `dayRecordId`: FK to current day's DayRecord
- `source`: `"apple_health"` (iOS) / `"health_connect"` (Android)

**Recommended approach**: Add a nullable `source` column to ExerciseEntity in a new migration (v8→v9):
```sql
ALTER TABLE ExerciseEntity ADD COLUMN source TEXT;
```
Values: `null` (manual), `"apple_health"`, `"health_connect"`.

---

## iOS Configuration

### Info.plist

Add to `ios/Runner/Info.plist`:
```xml
<key>NSHealthShareUsageDescription</key>
<string>Foody reads your active energy data to track burned calories alongside your meals.</string>
```

Note: We only need `NSHealthShareUsageDescription` (read), not `NSHealthUpdateUsageDescription` (write).

### Xcode Capabilities

Enable **HealthKit** capability in `ios/Runner.xcodeproj`:
- Open in Xcode → Runner target → Signing & Capabilities → + HealthKit
- This adds the `com.apple.developer.healthkit` entitlement

### Entitlements

In `ios/Runner/Runner.entitlements`:
```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
```

---

## Android Configuration

### AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Inside <manifest> -->
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED" />

<!-- Inside <application> -->
<activity
    android:name="androidx.health.connect.client.permission.platform.HealthConnectPermissionActivity"
    android:exported="true" />
```

### Health Connect Intent Filter

Add an intent filter so Foody appears in Health Connect's app list:
```xml
<intent-filter>
    <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
</intent-filter>
```

### Minimum SDK

Health Connect requires **minSdkVersion 26** (Android 8.0). Check `android/app/build.gradle` — if currently lower, bump it.

### Health Connect Availability

- Android 14+: Health Connect is built-in
- Android 8–13: Users may need to install the Health Connect app from Play Store
- The `health` package handles availability checks; we show an "Install Health Connect" prompt if needed

---

## Database Migration (v8 → v9)

```dart
final migration8to9 = Migration(8, 9, (database) async {
  await database.execute('ALTER TABLE ExerciseEntity ADD COLUMN source TEXT');
});
```

- Bump version to 9 in `app_database.dart`
- Add migration to `migrations.dart`
- Register in `locator.dart` migration chain
- Add `source` field to `ExerciseEntity` (nullable String)
- Run `build_runner`

---

## Localization

Add to `en.json` and `cs.json`:

```json
{
  "health_integration": "Health Integration",
  "apple_health": "Apple Health",
  "health_connect": "Health Connect",
  "sync_to_apple_health": "Sync to Apple Health",
  "sync_to_health_connect": "Sync to Health Connect",
  "apple_health_description": "To manage which data Foody syncs to Apple Health, follow these steps:",
  "health_connect_description": "To manage which data Foody syncs to Health Connect, follow these steps:",
  "apple_health_step1": "Open the Health app.",
  "apple_health_step2": "Tap your profile picture in the top right.",
  "apple_health_step3": "Tap 'Apps' under Privacy.",
  "apple_health_step4": "Tap 'Foody' and manage your preferences.",
  "health_connect_step1": "Open Health Connect app.",
  "health_connect_step2": "Tap 'App permissions'.",
  "health_connect_step3": "Tap 'Foody' and manage your preferences.",
  "open_health_app": "Open Health App",
  "open_health_connect": "Open Health Connect",
  "install_health_connect": "Install Health Connect",
  "sync_burned_calories": "Sync Burned Calories",
  "last_synced": "Last synced: {time}",
  "health_sync_error": "Could not sync with {platform}. Please check permissions.",
  "health_connect_not_installed": "Health Connect is not installed. Install it to sync your fitness data."
}
```

---

## Registration (locator.dart)

```dart
// Service — permanent, initialized early (after SharedPreferences)
Get.put(HealthIntegrationService(), permanent: true);

// Controller — lazy with fenix for subscreen
Get.lazyPut<HealthIntegrationController>(
  () => HealthIntegrationController(),
  fenix: true,
);
```

---

## Implementation Steps

### Phase 1: Foundation
1. Add `health` package to `pubspec.yaml`
2. Create `HealthIntegrationSetting` model
3. Add SharedPreferences keys/methods to `SharedPreferencesManager`
4. DB migration v8→v9: add `source` column to `ExerciseEntity`
5. Update `ExerciseEntity` + run `build_runner`
6. iOS config: Info.plist permission string, Xcode HealthKit capability, entitlements
7. Android config: AndroidManifest.xml permissions, Health Connect activity, min SDK check

### Phase 2: Service Layer
8. Create `HealthIntegrationService` — platform-aware permission request, data reading, sync logic
9. Register in `locator.dart`
10. Integrate sync trigger in `DashboardController` (on app open / date change)

### Phase 3: UI
11. Create `HealthIntegrationController`
12. Create `HealthIntegrationScreen` with platform-adaptive content (iOS instructions vs Android instructions)
13. Add health integration row to `profile_screen.dart` (adaptive label per platform)
14. Add localization strings to `en.json` and `cs.json`

### Phase 4: Polish
15. Handle edge cases: permission denied, health provider unavailable, no data
16. Android: handle Health Connect not installed (prompt to install from Play Store)
17. Avoid duplicate exercise entries on repeated syncs (upsert by source + date)
18. Test on physical iOS device + Android device

---

## Edge Cases & Notes

- **iOS Simulator**: HealthKit works on iOS simulator with synthetic data, but real device testing is preferred.
- **Android Emulator**: Health Connect can be installed on emulator but has limited test data.
- **Permission revocation**: Users can revoke permissions in OS settings. The service should handle `notDetermined` / `denied` gracefully and show a re-enable prompt.
- **Multiple syncs per day**: Use upsert logic — find existing exercise with matching `source` for the same date, update `caloriesBurned` rather than creating duplicates.
- **Historical sync**: On first enable, optionally sync the last 7 days of data to backfill.
- **Background sync**: Out of scope for now. Sync happens on app open only.
- **Health Connect not installed (Android 8–13)**: Show a card/dialog prompting the user to install Health Connect from Play Store. The `health` package provides `Health().isHealthConnectAvailable()` for this check.
- **Single service, dual platform**: One `HealthIntegrationService` handles both platforms. The `health` package abstracts HealthKit vs Health Connect internally. We only branch for UI text and the `source` field value.
