# Bugfix: Meal-Time Reminder Notifications Show Raw Locale Keys

## Overview

Meal-time tracking reminders (breakfast / lunch / snack / dinner / end-of-day) fire with the **raw translation key name** (e.g. `tracking_reminders_body_breakfast`) instead of the translated string. Reported in `thesis/testovani/dlouhodoby_text_notes.md`:

> bug, meal time notifikace texty se neprekladaji, zobrazi se jmena promennych (summary notifications jsou ok, zkontrolovat vsechny pro jistotu).

The user observed it on the **tracking reminders** path. Motivational summary notifications appear correct in their case, but the audit below shows both services suffer from the **same root cause**; the difference is which scheduling event has fired since the app was reinstalled with the bug present. All scheduled notification text construction must be fixed.

---

## Root Cause

`tr()` from `easy_localization` resolves keys against the **translations dictionary owned by the `EasyLocalization` widget**. If the widget has not yet been mounted (and its asset loader has not finished parsing the JSON), `tr(key)` falls back to returning the **key string itself**.

In `lib/main.dart` the bootstrap sequence is:

```
14  Future<void> main() async {
15    WidgetsFlutterBinding.ensureInitialized();
16    await EasyLocalization.ensureInitialized();   // initializes shared prefs cache only
...
24    await TrackingReminderService.to.initialize();
25    await TrackingReminderService.to.rescheduleAllFromStorage();   // <-- tr() called here
26    await MotivationalSummaryService.to.initialize();
27    await MotivationalSummaryService.to.rescheduleAllFromStorage(); // <-- tr() called here
...
37    runApp(
38      EasyLocalization(                                            // <-- dictionary loaded here
...
43        child: App(),
44      ),
45    );
```

`EasyLocalization.ensureInitialized()` only prepares the SharedPreferences cache (last-known locale); it does **not** load translation assets. The actual JSON loading happens in `_EasyLocalizationState.initState()`, which only runs after `runApp()` mounts the widget tree. Every `tr()` call between lines 16 and 37 returns the raw key.

That is exactly the window in which:

- `TrackingReminderService.scheduleReminder()` (`lib/services/tracking_reminder_service.dart:159-169`) calls `_notificationTitle()` (line 162) and `_notificationBody(type)` (line 163) — both wrapping `tr(LocaleKeys.*)`.
- `MotivationalSummaryService.scheduleNotification()` (`lib/services/motivational_summary_service.dart:68-78`) does the same on line 70 / 71.

Because `zonedSchedule()` persists the rendered title/body into the OS scheduler (Android `AlarmManager` / iOS `UNUserNotificationCenter`), **the raw key is stored once and reused on every subsequent firing** until the notification is rescheduled. Reinstalling the app, changing the system language, or letting the device reboot does not refresh the cached payload — only an in-app reschedule does.

### Why motivational summaries "look fine" to the tester

- `endOfDay` tracking reminder is **enabled by default** (`TrackingReminderType.defaultEnabled` returns true only for `endOfDay`) — it is therefore scheduled on every cold start from `main()`, **before** `runApp()`. The tester sees its raw-key body every day.
- `weekly` motivational summary is also enabled by default and is also scheduled from `main()`. It is **equally broken** but fires only once a week (Sunday 10:00), so the tester may not have observed a firing yet, or may have re-saved the setting in the meantime (which re-schedules from the settings screen, where `tr()` works).
- Daily / monthly motivational and all non-default tracking reminders are scheduled exclusively from the settings screens (`TrackingRemindersController.toggleReminder`, etc.), so their payload is built with the `EasyLocalization` widget already mounted and renders correctly.

### Why the dashboard "AI done" notification looks fine

The instant `notificationsPlugin.show()` call at `lib/controller/dashboard_controller.dart:721-736` runs from a user-triggered AI completion, deep into the app lifecycle. The widget tree is mounted and `tr(LocaleKeys.common_app_name)` resolves correctly.

---

## Notification Site Inventory

Every place in the codebase that constructs notification user-visible text.

| # | File:Line | API | Title / body source | Triggered from | Status | Fix needed |
|---|-----------|-----|---------------------|----------------|--------|------------|
| 1 | `lib/services/tracking_reminder_service.dart:159` | `zonedSchedule` | `_notificationTitle()` / `_notificationBody(type)` — both call `tr(LocaleKeys.*)` | `rescheduleAllFromStorage()` in `main.dart:25` (cold start, pre-`runApp`) **and** `TrackingRemindersController.toggleReminder/changeReminderTime` (settings screen) | **Broken** when scheduled from `main()` | Yes |
| 2 | `lib/services/tracking_reminder_service.dart:60-66` | `createNotificationChannel` (Android channel name + description) | `tr(LocaleKeys.tracking_reminders_channel_name/_desc)` | `initialize()` from `main.dart:24` | **Broken** (channel name stored once by Android until app reinstall) | Yes |
| 3 | `lib/services/tracking_reminder_service.dart:144-150` | `AndroidNotificationDetails.channelName / channelDescription` (inside the schedule payload) | `tr(LocaleKeys.tracking_reminders_channel_name/_desc)` | same as #1 | **Broken** when scheduled from `main()` | Yes |
| 4 | `lib/services/motivational_summary_service.dart:68` | `zonedSchedule` | `tr(LocaleKeys.motivational_summary_notification_title)` / `_notificationBody(type)` | `rescheduleAllFromStorage()` in `main.dart:27` (cold start) **and** `MotivationalSummaryController` (settings screen) | **Broken** for the weekly default; correct for entries re-saved via settings | Yes |
| 5 | `lib/services/motivational_summary_service.dart:21-27` | `createNotificationChannel` | `tr(LocaleKeys.motivational_summary_channel_name/_desc)` | `initialize()` from `main.dart:26` | **Broken** | Yes |
| 6 | `lib/services/motivational_summary_service.dart:54-60` | `AndroidNotificationDetails.channelName / channelDescription` | `tr(LocaleKeys.motivational_summary_channel_name/_desc)` | same as #4 | **Broken** when scheduled from `main()` | Yes |
| 7 | `lib/controller/dashboard_controller.dart:721-736` | `notificationsPlugin.show()` (instant) | `tr(LocaleKeys.common_app_name)` + caller-provided localized `message` | AI recognition completion while the app is alive | Correct (widget tree is mounted; `tr()` resolves) | No |

> Confirmed by `grep -rn "notificationsPlugin\.\(show\|zonedSchedule\|periodicallyShow\)\|_plugin\.\(show\|zonedSchedule\)"` — these are the only notification call sites.

---

## Fix Strategy

Two complementary changes:

### A. Defer reminder rescheduling until after `runApp()` mounts `EasyLocalization`

Move the four "bootstrap" calls out of `main()` so they no longer run before the widget tree exists. Trigger them from the first frame of `App` (or a small init service invoked from `App.initState`) once `easy_localization` has loaded translations.

### B. Make every notification text builder resilient to a not-yet-mounted dictionary

Even after fix A, the channel name / description should not silently fall through to raw keys if the order of operations regresses. Two acceptable approaches; the plan uses (1):

1. **Guard with `EasyLocalization.of(context)?.currentLocale != null`** check inside the services and fall back to the English JSON map loaded directly. *Simplest is to pre-load the translation maps into a tiny `NotificationTextProvider` that reads `assets/translations/{locale}.json` once via `rootBundle` and exposes synchronous lookups, independent of `easy_localization`'s widget lifecycle.*
2. Alternatively, gate `tr()` calls behind a `Completer<void>` exposed by `App` that completes once `EasyLocalization` has loaded. The bootstrap awaits the completer before calling `rescheduleAllFromStorage()`.

The plan prefers approach **(2) via a single Completer**, because it is the smallest change and keeps `tr()` as the single source of truth for strings (no JSON re-parsing, no duplicated lookup paths).

---

## Files to Modify

| File | Change |
|------|--------|
| `lib/main.dart` | Remove the four notification reschedule/initialize calls (lines 24-27) from the pre-`runApp` block. Keep the timezone init only if it doesn't depend on `tr()`. |
| `lib/app.dart` | After `EasyLocalization` has mounted and translations are loaded, run the notification bootstrap once. Easiest hook: `WidgetsBinding.instance.addPostFrameCallback` in `App.initState` plus a `bool _bootstrapped` guard. The post-frame callback awaits a short delay or directly calls a new `NotificationBootstrap.run()` helper. |
| `lib/services/tracking_reminder_service.dart` | No code change required if A is sufficient. Optionally: add a one-shot `assert(EasyLocalization.of(...) != null \|\| !kDebugMode)` in `_notificationBody` to catch regressions. |
| `lib/services/motivational_summary_service.dart` | Same as above. |
| (new) `lib/services/notification_bootstrap.dart` | Small helper that calls, in order: `TrackingReminderService.to.initialize()`, `TrackingReminderService.to.rescheduleAllFromStorage()`, `MotivationalSummaryService.to.initialize()`, `MotivationalSummaryService.to.rescheduleAllFromStorage()`, `WidgetSyncService.to.initialize()`, optional permission request. |

> Note: `WidgetSyncService.to.initialize()` currently sits at `main.dart:28`. Audit whether it also calls `tr()`; if yes, move it together with the others.

---

## Implementation Steps

### Phase 1 — Decouple bootstrap from `main()`

1. Create `lib/services/notification_bootstrap.dart`:

   ```dart
   class NotificationBootstrap {
     static bool _done = false;

     static Future<void> run() async {
       if (_done) return;
       _done = true;

       await TrackingReminderService.to.initialize();
       await TrackingReminderService.to.rescheduleAllFromStorage();
       await MotivationalSummaryService.to.initialize();
       await MotivationalSummaryService.to.rescheduleAllFromStorage();

       if (SessionManager.to.onboardingComplete.value) {
         await TrackingReminderService.to.ensureNotificationPermission();
       }
     }
   }
   ```

2. Remove the corresponding lines from `lib/main.dart` (the block currently between lines 24 and 35). Keep `setupServices`, `SessionManager.onAppInit`, `LanguageSettingsService.load`, `WidgetSyncService.to.initialize()` (verify it doesn't call `tr()` — if it does, move it too).

3. In `lib/app.dart`, on the `StatefulWidget` that hosts the navigator, schedule the bootstrap on the first frame:

   ```dart
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       // At this point EasyLocalization has loaded translations.
       NotificationBootstrap.run();
     });
   }
   ```

   If `App` is currently a `StatelessWidget`, promote it to `StatefulWidget` (the existing onboarding `Obx` gate stays as a child). Do **not** make this call synchronous — leave the future un-awaited so the UI is not blocked.

### Phase 2 — Force a one-time rescheduling for already-installed devices

The bug means existing testers' devices have raw keys cached inside the OS scheduler. Even after Phase 1 ships, a tester upgrading the app will not see correct text until something triggers a re-schedule.

4. Inside `NotificationBootstrap.run()`, **always** call `rescheduleAllFromStorage()` (don't gate on a "first run" flag). The two services already cancel-and-reschedule for each enabled reminder, so this is idempotent and refreshes the cached payload on every cold start. (This is what the current code already does — the only thing that changes is *when* it runs.)

5. Sanity-check `cancelReminder` is called before `scheduleReminder` for previously-enabled reminders. Looking at `rescheduleAllFromStorage` in `tracking_reminder_service.dart:127-137`, it calls `cancelReminder` only when `setting.enabled == false`. For enabled reminders it relies on `zonedSchedule` to overwrite the same `notificationId`. Verify on Android that overwriting an existing scheduled notification with the same ID does refresh the title/body — `flutter_local_notifications` documents this as a replace. If in doubt, change `rescheduleAllFromStorage` to always cancel first:

   ```dart
   for (final setting in settings) {
     await cancelReminder(setting.type);
     if (setting.enabled) await scheduleReminder(setting);
   }
   ```

### Phase 3 — Defensive logging

6. In `_notificationBody` / `_notificationTitle` (both services), add a debug-only assertion:

   ```dart
   assert(() {
     final resolved = tr(key);
     if (resolved == key) {
       // ignore: avoid_print
       print('[Notifications] WARNING: tr() returned the raw key "$key" — EasyLocalization not ready.');
     }
     return true;
   }());
   ```

   This catches future regressions during development without affecting release builds.

### Phase 4 — Verify channel name handling

7. Android caches the channel display name from the **first** `createNotificationChannel` call. Once the bug fix lands, the existing channel on the tester's device may still show the raw key as channel name in the system notification settings. Two options:

   - Bump the channel ID (e.g. `tracking_reminders` → `tracking_reminders_v2`) so Android creates a fresh channel with the correct localized name. Cancel the old channel via `deleteNotificationChannel('tracking_reminders')` once during bootstrap to clean up.
   - Or document that testers must clear app data / reinstall.

   For the thesis user-study population this is small, so **delete-then-recreate** is the cleanest path. Add to `NotificationBootstrap.run()` (only run once, gated by a SharedPreferences flag):

   ```dart
   final prefs = SharedPreferencesService.to;
   if (await prefs.getBool(key: 'notification_channels_migrated_v2') != true) {
     final android = TrackingReminderService.to.notificationsPlugin
         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
     await android?.deleteNotificationChannel('tracking_reminders');
     await android?.deleteNotificationChannel('motivational_summary');
     await prefs.setBool(key: 'notification_channels_migrated_v2', value: true);
   }
   ```

   The next `initialize()` call (which is part of the same bootstrap) recreates the channels with the now-correctly-translated names.

---

## Notes on Background Isolate Caveats

`flutter_local_notifications` uses two execution contexts:

- **Scheduling** runs on the main isolate, in foreground, with the full Flutter engine. `tr()` works **iff** `EasyLocalization` is mounted. The fix above ensures this.
- **Tap handling** in a terminated app dispatches `onDidReceiveBackgroundNotificationResponse` on a **separate background isolate** with no widget tree and no `EasyLocalization` state. Any localization done inside that callback would fail similarly.

Current code (`_onNotificationTap` in `tracking_reminder_service.dart:211`) only routes navigation — it does not call `tr()` — so no fix is needed there. If future tap handlers ever need to render localized strings (e.g. a Snackbar), they must either:

- Use the foreground (`onDidReceiveNotificationResponse`) variant, which runs on the main isolate after the app warms up, or
- Pass the localized text as part of the `payload` at schedule time.

The body/title we are scheduling now is stored by the OS as plain UTF-8 — once `tr()` resolves correctly at schedule time, the OS displays the translated text without ever re-entering Flutter.

### Live locale changes

If the user changes the app language at runtime (`context.setLocale(...)`), already-scheduled notifications will still show the previously-baked text until the next reschedule. Mitigation: hook into `EasyLocalization`'s locale change callback (`App.onLocaleChanged` or by listening to `context.locale`) and call `NotificationBootstrap.run()` again — it is idempotent. Out of scope for this bugfix but worth adding a TODO comment near the bootstrap.

---

## Verification Steps

For each verification path: install a build with the fix, set the system+app language to **Czech**, then to **English**, and confirm strings are translated in both.

1. **Default `endOfDay` tracking reminder (cold start path):**
   - Fresh install of the app on a test device.
   - Complete onboarding.
   - In the device settings, advance the system clock to 20:59 (or use `adb shell date` on Android).
   - Verify the 21:00 `endOfDay` notification body reads "Nezapomeňte zapsat jídlo za celý den." (cs) / "Do not forget to log all meals for today." (en) — **not** `tracking_reminders_body_end_of_day`.

2. **Per-type tracking reminders (settings-screen path):**
   - For each of breakfast / lunch / snack / dinner / endOfDay, enable from `Profile → Tracking Reminders`, set the time to `now + 2 min`, lock the device, wait.
   - Verify each body and the common title `tracking_reminders_notification_title` render translated.

3. **Motivational summaries:**
   - Enable each of daily / weekly / monthly with a near-future time.
   - For weekly/monthly, optionally set the system clock to the next Sunday 10:00 / 1st-of-month 10:00.
   - Verify all three bodies and the common title render translated.

4. **Channel names (Android):**
   - Open *System Settings → Apps → Foody → Notifications*.
   - Confirm channel names display "Připomínky sledování" / "Motivační shrnutí" (cs) instead of `tracking_reminders_channel_name`.
   - On a device that had the old (buggy) build installed, confirm that after upgrade the Phase 4 migration deletes the old channels and the new ones appear correctly named.

5. **Locale switch round-trip:**
   - Schedule a reminder in Czech.
   - Switch app language to English via Profile.
   - Trigger the `App.onLocaleChanged` re-bootstrap (see TODO above) — confirm the next firing is in English. If the re-bootstrap is not implemented in this PR, document the limitation in a code comment.

6. **Smoke-test the AI-completion notification (dashboard):**
   - Background the app, kick off a photo analysis, wait for completion.
   - Confirm the title "Foody" (`common_app_name`) and the caller-provided body are translated — this path was always correct, but verify the fix did not regress it.

---

## Scope Summary

- **New files:** 1 (`lib/services/notification_bootstrap.dart`)
- **Modified files:** 2 required (`lib/main.dart`, `lib/app.dart`) + optional defensive edits to the two notification services.
- **No new dependencies, no DB migrations, no translation key changes.**
- **One-time channel-migration SharedPreferences flag** to recover already-deployed testers (Phase 4).
- **Risk:** Low. The change moves four `await` calls from `main()` into a post-frame callback. The only behavioural change for users is that, on cold start, notification rescheduling happens ~1 frame later than before. No notification could fire in that millisecond window anyway.
- **Testing:** Manual verification of every reminder type in both locales (see Verification Steps).
