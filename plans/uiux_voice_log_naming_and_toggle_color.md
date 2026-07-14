# UI/UX: Voice Log Naming & Meal/Exercise Toggle Color

> **Summary**: Address two real-user findings from long-term testing on `lib/screens/logs/voice_log_screen.dart` — (1) rename and reframe the screen so users discover that it also accepts free-text input, not just voice, and (2) tint the Meal/Exercise toggle so the Exercise state uses the established orange exercise color, matching exercise record cards across the app.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement

Long-term testing surfaced two related discoverability/affordance bugs on the Voice Log screen:

1. **Naming**: the screen accepts both spoken dictation *and* typed free-text input (the same `TextField` in `VoiceLogTextArea` is editable with or without the microphone). The current label "Voice Log" / "Hlasový záznam" only signals voice; participants who wanted to *type* a meal description went into **Log Meal** (`SelectMealScreen`) instead and were confused when they did not find a free-text AI box there.
2. **Toggle color**: the Meal/Exercise switch (`VoiceLogToggle` → `GlassSwitch`) uses `AppColors.primary` for both `activeColor` and `inactiveColor`, so the track looks identical in both states. Users could not tell at a glance which mode they were in, which contradicts the rest of the app where exercise context is consistently rendered with the orange palette (`AppGradients.exerciseCalories`, `AppGradients.exerciseCaloriesAlt`).

### 1.2 Solution Overview

1. **Issue 1 — Discoverability (chosen approach: rename + supportive copy):**
   - Rename the user-facing label from **"Voice Log"** to **"Quick Log"** / **"Rychlý záznam"** in both the quick-action sheet entry point and (implicitly) the screen's mental model. "Quick Log" is mode-neutral, fits the existing FAB quick-action grid, and does not over-promise an AI brand.
   - Add a short subtitle/hint directly above the text area on the screen itself: *"Speak or type — AI handles the rest"* / *"Mluvte, nebo napište — AI se postará o zbytek"*. This kills the ambiguity at the point of use without renaming internal symbols.
   - Update the existing tips sheet (`_showVoiceTips`) to mention typing as a first-class input.
   - Keep internal Dart identifiers (`VoiceLogScreen`, `VoiceLogMode`, `voice_*` translation keys for in-screen copy) unchanged — only user-facing strings move. This avoids churn in the Floor DB, controllers, and tests that already reference these names, and keeps the diff small for the thesis release.

   **Why this beats the alternatives:**
   - *Rename to "AI Log"* — over-emphasizes AI, conflicts with the existing **Ask AI** screen brand and with FR-08 transparency goals (CLAUDE.md FR table).
   - *Add only a subtitle, keep "Voice Log"* — does not fix the root issue: users never enter the screen because the FAB tile still says "Voice Log". The subtitle is only seen post-entry.
   - *Move the entry into Log Meal itself* — large refactor, blurs the separation of input modalities documented in CLAUDE.md (Voice flow is its own subsystem).

2. **Issue 2 — Toggle color**: pass an exercise-tinted color into the existing `GlassSwitch`. The `liquid_glass_widgets` `GlassSwitch` API only accepts `Color` (not `Gradient`) — verified in `~/.pub-cache/hosted/pub.dev/liquid_glass_widgets-0.5.0/lib/widgets/interactive/glass_switch.dart` lines 64–98. Use the existing color token `AppColors.exerciseOrange` (already the start color of `AppGradients.exerciseCaloriesAlt`) for the active state, keep `AppColors.primary` for the inactive (Meals) state.

### 1.3 Scope: What This IS

- A copy change to the quick-action entry tile label (EN + CS).
- A new subtitle/hint shown inside `VoiceLogScreen` above the text area.
- A color change to the Meal/Exercise switch so the Exercise side adopts `AppColors.exerciseOrange`.
- A small copy addition to `voice_tips_*` so the tips sheet acknowledges typing.
- Translation key additions in `assets/translations/en.json` + `assets/translations/cs.json`, followed by the standard `bash commands/generate_localization.command` regeneration.

### 1.4 Scope: What This IS NOT

- Not renaming the Dart class `VoiceLogScreen`, the enum `VoiceLogMode`, the existing `voice_*` translation keys, the `quick_action_voice_log` key (only its value), or any file paths.
- Not redesigning the toggle widget (no replacement of `GlassSwitch`, no gradient track — the package only exposes `activeColor`/`inactiveColor`).
- Not redesigning the FAB grid layout — only the tile label changes.
- Not changing the AppBar title (the screen has no visible title text — `CustomGlassAppBar` only renders a back button and action group; nothing to rename there).
- Not touching the AI pipeline, voice service, or any business logic.
- Not adding new screens or routes.

---

## 2. SUCCESS CRITERIA

Implementation is COMPLETE when ALL criteria are met:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | The quick-action tile that opens `VoiceLogScreen` reads "Quick Log" (EN) / "Rychlý záznam" (CS). | Manual run: open the FAB on Dashboard, read the bottom-right of the two-up grid (icon `mic_fill`). |
| 2 | Opening the screen shows a one-line subtitle/hint between the Meal/Exercise toggle and the text area that explicitly mentions both "speak" and "type" (EN/CS). | Manual run: navigate FAB → Quick Log. The subtitle is visible without scrolling. |
| 3 | The Meal/Exercise toggle track is the app's primary dark color when Meals is selected and `AppColors.exerciseOrange` when Exercise is selected. | Manual run: tap the toggle and observe color change. Verify with the existing exercise record card — orange should match. |
| 4 | Toggle change is visually obvious on a phone screen in standard lighting (passes the "across-the-room" glance test). | Side-by-side device check vs. previous build. |
| 5 | Translations are added to both `en.json` and `cs.json`; `bash commands/generate_localization.command` runs cleanly and `lib/generated/locale_keys.g.dart` contains the new keys. | Grep `LocaleKeys.voice_subtitle_input_hint` in `locale_keys.g.dart`. |
| 6 | `flutter analyze` passes with zero new warnings; no hardcoded colors introduced (CLAUDE.md design-token rule). | Run `flutter analyze`; grep the diff for `Color(0xFF` or `Colors.` literals. |
| 7 | No regression in entry from `ExerciseLogHomeScreen` — entering with `initialMode: VoiceLogMode.exercise` still lands on the Exercise side with the new orange track. | Manual run: Exercise Log Home → mic icon in app bar group. |

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture

```
┌──────────────────────┐
│ QuickActionSheet     │  ← label changes: "Quick Log" / "Rychlý záznam"
│ (mic_fill tile)      │
└──────────┬───────────┘
           │ Get.to(() => const VoiceLogScreen())
           ▼
┌──────────────────────────────────────────────────────────────┐
│ VoiceLogScreen                                                │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ VoiceLogToggle                                            │ │
│ │   Meals  ⟷[GlassSwitch]⟷  Exercise                       │ │
│ │   activeColor = isExercise ? exerciseOrange : primary    │ │
│ │   inactiveColor = primary                                 │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                               │
│ [NEW] Subtitle hint: "Speak or type — AI handles the rest"   │
│                                                               │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ VoiceLogTextArea  (already editable — no change)          │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ VoiceLogAnalyzeButton                                     │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                               │
│ ... mic button ...                                            │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Rename target | "Quick Log" / "Rychlý záznam" (label only, value of `quick_action_voice_log`) | Mode-neutral, fits FAB grid, no class/key rename needed, no DB or controller churn. |
| Where to add the subtitle | Inside `VoiceLogScreen.build`, between `VoiceLogToggle` and the card containing `VoiceLogTextArea` | Visible immediately after entering, naturally framed as a caption to the input. |
| Keep `quick_action_voice_log` key, change value only | Yes | Minimizes diff in generated files; the key is referenced from `quick_action_sheet.dart:96`. Renaming the key would force changes in three generated files plus the call site. |
| Don't rename `VoiceLogScreen` / `VoiceLogMode` | Yes | Used by `MainScreenController.showQuickActions` (`main_screen.dart:148`) and `ExerciseLogHomeScreen` (`exercise_log_home_screen.dart:139`). Rename ripples beyond scope and risks breaking `SessionManager.voiceLogMode` persistence. |
| Toggle color source | `AppColors.exerciseOrange` (`app_theme.dart:211`) | This is the literal start color of `AppGradients.exerciseCaloriesAlt`, which renders exercise record cards. The `GlassSwitch` API does not accept a `Gradient`, so we pick the canonical single color from that gradient. |
| Inactive color | Stays `AppColors.primary` | Matches the rest of the app's neutral track. |
| Drop the dual mic gradient hint (`isExercise || _isListening ? AppGradients.askAiPrimary : AppGradients.primary`, line 760) | No — leave mic button alone | Out of scope; user only flagged the toggle. Revisit later if it ever conflicts with the new orange affordance. |

---

## 4. IMPLEMENTATION STEPS

> Execute steps in order. Do not skip.

### Step 1: Add new translation keys + update existing tile label
**Goal**: Add the subtitle hint and update the Voice Log → Quick Log tile label in both locales.
**Files**: `assets/translations/en.json`, `assets/translations/cs.json`

In `assets/translations/en.json`:

- **Change** line 104: `"quick_action_voice_log": "Voice Log"` → `"quick_action_voice_log": "Quick Log"`
- **Add** (near the other `voice_*` keys, around lines 522–523, after `voice_instruction_*`):
  ```json
  "voice_subtitle_input_hint": "Speak or type — AI handles the rest"
  ```
- **Optional polish** (recommended) — update `voice_tips_speak_clearly` to acknowledge typing. Replace `"voice_tips_edit_text": "You can edit the transcribed text before analyzing."` with `"voice_tips_edit_text": "You can also type the description directly — voice is optional."` to make the typing path explicit in the tips sheet too.

In `assets/translations/cs.json`:

- **Change** line 104: `"quick_action_voice_log": "Hlasový záznam"` → `"quick_action_voice_log": "Rychlý záznam"`
- **Add**:
  ```json
  "voice_subtitle_input_hint": "Mluvte, nebo napište — AI se postará o zbytek"
  ```
- **Optional polish**: replace `"voice_tips_edit_text": "Přepsaný text můžete před analýzou upravit."` with `"voice_tips_edit_text": "Popis můžete také rovnou napsat — hlas je volitelný."`

**Done when**: both JSON files contain the new `voice_subtitle_input_hint` key; both validate as JSON (`python3 -m json.tool < assets/translations/en.json > /dev/null` and same for cs).

---

### Step 2: Regenerate localization keys
**Goal**: Surface the new key as `LocaleKeys.voice_subtitle_input_hint`.
**Files**: `lib/generated/locale_keys.g.dart`, `lib/generated/codegen_loader.g.dart` (auto-generated, do not hand-edit)

```bash
bash commands/generate_localization.command
```

**Done when**: `grep voice_subtitle_input_hint lib/generated/locale_keys.g.dart` returns a match.

---

### Step 3: Render the subtitle hint inside `VoiceLogScreen`
**Goal**: Make the dual-input affordance visible at the point of use.
**Files**: `lib/screens/logs/voice_log_screen.dart` (around line 712–714, between the toggle and the input card)

Insert directly after the `VoiceLogToggle(...)` line and before `const SizedBox(height: AppSpacing.l)`:

```dart
const SizedBox(height: AppSpacing.s),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
  child: Text(
    tr(LocaleKeys.voice_subtitle_input_hint),
    textAlign: TextAlign.center,
    style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
  ),
),
```

Reasoning for the style choice: `body13` + `textTertiary` matches the existing language-sheet subtitle on line 586 (`AppTextStyles.body13.copyWith(color: AppColors.textTertiary)`), keeping caption typography consistent across the app.

**Done when**: hot-reload shows the new line directly under the Meal/Exercise toggle, both in EN and CS builds.

---

### Step 4: Tint the toggle's `activeColor` per mode
**Goal**: Make the Exercise state visually distinct using the existing exercise orange.
**Files**: `lib/screens/logs/voice_widgets.dart` (line 48)

Replace:
```dart
GlassSwitch(value: isExercise, onChanged: (_) => isExercise ? onSelectMeals() : onSelectExercise(), useOwnLayer: true, activeColor: AppColors.primary, inactiveColor: AppColors.primary),
```

with:
```dart
GlassSwitch(
  value: isExercise,
  onChanged: (_) => isExercise ? onSelectMeals() : onSelectExercise(),
  useOwnLayer: true,
  activeColor: AppColors.exerciseOrange,
  inactiveColor: AppColors.primary,
),
```

Notes:
- `GlassSwitch` (liquid_glass_widgets 0.5.0) does not accept a `Gradient`, only `Color` — confirmed in `glass_switch.dart:64–98`. Using `AppColors.exerciseOrange` (the start color of `AppGradients.exerciseCaloriesAlt`) keeps the orange identity consistent with exercise record cards without inventing a new token.
- Do NOT introduce a new color literal. Reuse the existing `AppColors.exerciseOrange` (`app_theme.dart:211`).

**Done when**: tapping the switch flips the track between dark primary and orange.

---

### Step 5: Verify entry points and run analyzer
**Goal**: Confirm nothing else needs updating.
**Files**: read-only verification.

```bash
# Entry points to VoiceLogScreen — should be exactly 2 production call sites
grep -rn "VoiceLogScreen(" lib/ --include="*.dart"
# Expected matches (besides the definition + state class):
#   lib/screens/main_screen.dart:148                 → const VoiceLogScreen()
#   lib/screens/logs/exercise_log_home_screen.dart:139 → const VoiceLogScreen(initialMode: VoiceLogMode.exercise)

flutter analyze
```

**Done when**: only the two expected call sites exist, analyzer is clean, and a manual run of both entry points shows the new label / subtitle / orange toggle.

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| User enters via `ExerciseLogHomeScreen` with `initialMode: VoiceLogMode.exercise`. | Screen opens already on Exercise side, toggle shows orange track. | No code change needed — `_mode` is initialized from `widget.initialMode` (line 69). |
| User on cs locale. | Tile reads "Rychlý záznam", subtitle reads "Mluvte, nebo napište — AI se postará o zbytek". | Covered by Step 1 cs.json edit. |
| Long-press on the toggle thumb. | Track color updates as `isExercise` flips; no other side effects. | `GlassSwitch.onChanged` already drives `_toggleMode` (line 345), which cancels listening and persists the mode via `SessionManager.setVoiceLogMode`. Unchanged. |
| Color-blind users (red-green) cannot rely on hue alone. | Toggle position (left/right) + bold side label already encode the state; orange vs. dark also differs in luminance, not only hue. | Acceptable. No extra change. |
| Subtitle line wraps on narrow devices (small phones, large fonts). | Text wraps to two lines with center alignment. | `textAlign: TextAlign.center` + the same horizontal padding as `voice_instruction_*` — already handled. |
| Quick action tile label "Quick Log" collides visually with another tile. | Existing tiles: "Log Meal", "Barcode Scan", "Quick Log", "Meal Scan", "Exercise". No collision; the leading icon `mic_fill` continues to disambiguate from "Log Meal". | Acceptable. |

---

## 6. SECURITY CONSIDERATIONS

Not applicable. This change touches only display strings and a single color token; no input validation, auth, persisted data, or network surface is affected.

---

## 7. ASSUMPTIONS & QUESTIONS

### Assumptions Made

1. **"Quick Log" reads naturally to ČVUT FEL diploma thesis users (cs primary)**. The Czech equivalent "Rychlý záznam" was chosen because "Rychlý" (quick) is already widely used in product UI and avoids the AI buzzword. If the supervisor prefers an alternative ("AI záznam", "Záznam"), only the value of `quick_action_voice_log` needs updating.
2. **The `GlassSwitch` API has not changed in the project's pinned `liquid_glass_widgets` version**. Verified against `0.5.0` in the user's pub-cache. If the project upgrades the package and an `activeGradient` parameter is later added, Step 4 can be revisited to pass `AppGradients.exerciseCaloriesAlt` directly.
3. **Style of the subtitle (`body13` + `textTertiary`) is the right register** — it mirrors the existing `language_settings_voice_language_subtitle` on line 586. If the supervisor wants stronger emphasis, switching to `AppTextStyles.body14.copyWith(color: AppColors.textSecondary)` is a one-line change.
4. **Tips sheet rewording is desirable**. Bundled with the same change because it removes a contradiction (the tips imply voice-only). If the supervisor objects, drop the optional polish in Step 1.

### Open Questions

- [ ] Confirm the cs label "Rychlý záznam" with the thesis supervisor / a second native reader.
- [ ] Should the screen's AppBar gain a visible title (currently it has none)? Out of scope for this plan; flagged for a future iteration if needed.

---

## 8. QUICK REFERENCE

### Files to Modify

- `assets/translations/en.json` — update `quick_action_voice_log`, add `voice_subtitle_input_hint`, optional reword of `voice_tips_edit_text`.
- `assets/translations/cs.json` — same in Czech.
- `lib/screens/logs/voice_log_screen.dart` — render the new subtitle between the toggle and the input card (after line 712).
- `lib/screens/logs/voice_widgets.dart` — change `GlassSwitch.activeColor` from `AppColors.primary` to `AppColors.exerciseOrange` (line 48).

### Files Auto-Regenerated (do not hand-edit)

- `lib/generated/locale_keys.g.dart`
- `lib/generated/codegen_loader.g.dart`

### Files to Create

- None.

### Theme Tokens Used (existing, no new tokens)

- `AppColors.exerciseOrange` — `lib/app_theme.dart:211` (`Color(0xFFF97316)`)
- `AppColors.primary` — already imported
- `AppColors.textTertiary` — already imported
- `AppTextStyles.body13` — already imported
- `AppSpacing.s`, `AppSpacing.xl` — already imported

### Commands

```bash
# Regenerate locale keys after editing JSON
bash commands/generate_localization.command

# Sanity checks
flutter analyze
grep -rn "VoiceLogScreen(" lib/ --include="*.dart"
grep -n "exerciseOrange\|voice_subtitle_input_hint" lib/screens/logs/voice_widgets.dart lib/screens/logs/voice_log_screen.dart

# Optional manual run
flutter run
```

---

## 9. DESIGN REFERENCE

### Visual Spec

No external design file. The spec is derived from two anchors already in the codebase:

1. The orange identity of exercise record cards rendered with `AppGradients.exerciseCaloriesAlt` (`app_theme.dart:456–460`), whose start color is `AppColors.exerciseOrange`.
2. The existing caption-style subtitle on the language sheet (`voice_log_screen.dart:586`), reused for the new input-hint line.

### Component/Screen Mapping

| Design element | Code anchor |
|---|---|
| FAB → Quick Log tile (mic icon) | `lib/widgets/quick_action_sheet.dart:94–101` (label key `LocaleKeys.quick_action_voice_log`) |
| Meal/Exercise toggle | `VoiceLogToggle` in `lib/screens/logs/voice_widgets.dart:31–57` |
| Toggle track (the part that changes color) | `GlassSwitch` from `package:liquid_glass_widgets` — `lib/screens/logs/voice_widgets.dart:48` |
| New subtitle hint location | `lib/screens/logs/voice_log_screen.dart:712–714` (between `VoiceLogToggle` and the `Padding` that wraps the input card) |

### Style Mapping

| Design aspect | Code equivalent | Value |
|---|---|---|
| Exercise active track color | `AppColors.exerciseOrange` | `Color(0xFFF97316)` (`app_theme.dart:211`) |
| Meal active / inactive track color | `AppColors.primary` | Existing — unchanged |
| Subtitle text style | `AppTextStyles.body13.copyWith(color: AppColors.textTertiary)` | Matches `voice_log_screen.dart:586` |
| Subtitle horizontal padding | `EdgeInsets.symmetric(horizontal: AppSpacing.xl)` | Matches the `voice_instruction_*` paragraph (line 745) |
| Subtitle vertical spacing | `SizedBox(height: AppSpacing.s)` above, then existing `SizedBox(height: AppSpacing.l)` below | Keeps the rhythm of the column |

---

## 10. CORRECTIONS FROM CURRENT STATE

| What | Before (current) | After (target) |
|---|---|---|
| FAB tile label EN | `"quick_action_voice_log": "Voice Log"` | `"quick_action_voice_log": "Quick Log"` |
| FAB tile label CS | `"quick_action_voice_log": "Hlasový záznam"` | `"quick_action_voice_log": "Rychlý záznam"` |
| Dual-input hint inside the screen | Absent — only `voice_instruction_meals` / `voice_instruction_exercise` shown lower on the screen, and those mention typing in long form well below the fold. | New short caption line directly under the toggle: *"Speak or type — AI handles the rest"* / *"Mluvte, nebo napište — AI se postará o zbytek"*. |
| `GlassSwitch.activeColor` | `AppColors.primary` (same as inactive — track looks identical in both states) | `AppColors.exerciseOrange` when active (Exercise side) |
| `GlassSwitch.inactiveColor` | `AppColors.primary` | `AppColors.primary` (unchanged) |
| Tips sheet (`voice_tips_edit_text`) | "You can edit the transcribed text before analyzing." | "You can also type the description directly — voice is optional." (optional polish) |

---

## 11. CHANGELOG

| Date | Change |
|---|---|
| 2026-05-11 | Initial plan created |
