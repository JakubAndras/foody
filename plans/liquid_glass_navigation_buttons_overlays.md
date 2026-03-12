# Liquid Glass Widgets Migration: Navigation, Buttons & Overlays

Nahrazení custom widgetů za `liquid_glass_widgets` package ekvivalenty v kategoriích: navigace (AppBar, BottomBar, SegmentedControl), tlačítka, top-right corner buttony a modální overlaye.

---

## Phase 1: Navigace (AppBar, BottomBar, SegmentedControl)

### 1.1 — GlassAppBar na všech obrazovkách s custom top barem

**Aktuální stav:** Většina obrazovek nepoužívá `Scaffold.appBar` — místo toho mají custom `SafeArea` + `Padding` + `Row` s back buttonem a title textem. `CustomAppBar` (`lib/widgets/app_bar.dart`) existuje ale není nikde importován.

**Akce:**
1. Smazat nepoužívaný `lib/widgets/app_bar.dart` (CustomAppBar).
2. Vytvořit reusable wrapper `FoodyGlassAppBar` v `lib/widgets/foody_glass_app_bar.dart`:
   ```dart
   class FoodyGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
     final String? title;
     final Widget? leading;
     final List<Widget>? actions;
     // ...
     // Interně: GlassAppBar(title: ..., leading: ..., actions: ...)
   }
   ```
3. Nahradit custom top bar rows na těchto obrazovkách:
   - `lib/screens/scan/scan_preview_screen.dart` — preview top bar
   - `lib/screens/logs/voice_log_screen.dart` — voice log top bar
   - `lib/screens/logs/exercise_log_home_screen.dart` — exercise selection top bar
   - `lib/screens/logs/exercise_detail_screen.dart` — exercise detail top bar
   - `lib/screens/log_meal/select_meal_screen.dart` — meal selection top bar
   - `lib/screens/profile/subscreens/` — všechny profile subscreeny (personal_details, preferences, diet, notifications, export, about, FAQ)
   - `lib/screens/profile/subscreens/liquid_glass_widgets_test_screen.dart` — test screen custom appbar

**Soubory k úpravě:** ~12 screen souborů + 1 nový widget + 1 smazání

---

### 1.2 — GlassBottomBar (již hotovo)

**Aktuální stav:** `MainScreen` již používá `GlassBottomBar` z package. ✅ Žádná akce.

---

### 1.3 — GlassSegmentedControl místo custom _SegmentedControl

**Aktuální stav:** 4 nezávislé implementace segmented controls:

| Místo | Soubor | Třída | Segmenty |
|-------|--------|-------|----------|
| Progress weekly | `lib/screens/progress_screen.dart` | `_SegmentedControl` | 4 (This Week / Last Week / ...) |
| Weight chart range | `lib/widgets/weight_progress_card.dart` | `_SegmentedControl` | 4 (90D / 6M / 1Y / ALL) |
| Theme picker | `lib/screens/profile/subscreens/preferences_screen.dart` | `_AppearanceSegmented` | 3 (System / Light / Dark) |
| Meal tabs | `lib/screens/log_meal/select_meal_widgets.dart` | `SelectMealSegmentedTabs` | 4 (All / Favorites / Meals / Ingredients) |

**Akce:**
1. **Progress weekly** → `GlassSegmentedControl(segments: labels, selectedIndex: idx, onSegmentSelected: cb)`
   - Soubor: `lib/screens/progress_screen.dart`
   - Smazat `_SegmentedControl` třídu (lines ~446-493)

2. **Weight chart range** → `GlassSegmentedControl(segments: ['90D', '6M', '1Y', 'ALL'], ...)`
   - Soubor: `lib/widgets/weight_progress_card.dart`
   - Smazat `_SegmentedControl` třídu (lines ~301-349)

3. **Theme picker** → `GlassSegmentedControl(segments: ['System', 'Light', 'Dark'], ...)`
   - Soubor: `lib/screens/profile/subscreens/preferences_screen.dart`
   - Smazat `_AppearanceSegmented` + `_SegmentItem` třídy (lines ~93-152)
   - Poznámka: Původní verze má ikony u segmentů — `GlassSegmentedControl` podporuje jen text. Alternativa: ponechat custom nebo požádat o feature request na package.

4. **Meal tabs** → `GlassTabBar` (ne SegmentedControl — má underline pattern)
   - Soubor: `lib/screens/log_meal/select_meal_widgets.dart`
   - `GlassTabBar(tabs: [GlassTab(label: 'All'), ...], selectedIndex: idx, onTabSelected: cb)`
   - Smazat `SelectMealSegmentedTabs` třídu (lines ~67-122)

**Soubory k úpravě:** 4 soubory, smazání 4 custom tříd

---

## Phase 2: Tlačítka

### 2.1 — LiquidGlassBackButton → GlassIconButton

**Aktuální stav:** Custom `LiquidGlassBackButton` v `lib/widgets/liquid_glass/liquid_glass_back_button.dart` — 300+ řádků s custom `_GlassButtonPainter`, glint animací, ambient glow, multi-layer bordery. Dva režimy: `.back()` a `.close()`.

**Akce:**
1. Nahradit všechny výskyty `LiquidGlassBackButton` za:
   ```dart
   GlassIconButton(
     icon: Icon(Icons.chevron_left),  // nebo Icons.close pro .close()
     onPressed: () => Get.back(),
     shape: GlassIconButtonShape.circle,
   )
   ```
2. Najít a nahradit importy ve všech souborech které používají `LiquidGlassBackButton`.
3. Smazat `lib/widgets/liquid_glass/liquid_glass_back_button.dart`.

**Dotčené soubory (hledat `LiquidGlassBackButton`):**
- `lib/screens/meals/edit_meal_screen.dart` — back button v `_EditMealTopBar`
- `lib/screens/ingredients/edit_ingredient_screen.dart` — back button
- `lib/screens/scan/scan_preview_screen.dart` — back/close button
- `lib/screens/logs/voice_log_screen.dart` — close button
- `lib/screens/logs/exercise_detail_screen.dart` — back button
- Případně další screeny — provést grep na `LiquidGlassBackButton`

**Soubory k úpravě:** ~6 screen souborů + 1 smazání

---

### 2.2 — ProfileBackButton → GlassIconButton

**Aktuální stav:** `ProfileBackButton` v `lib/screens/profile/profile_widgets.dart` (lines 67-92) — circular Container se surface color, outline border, chevron icon.

**Akce:**
1. Nahradit `ProfileBackButton(onPressed: cb)` za:
   ```dart
   GlassIconButton(
     icon: Icon(Icons.chevron_left),
     onPressed: cb,
     shape: GlassIconButtonShape.circle,
   )
   ```
2. Smazat třídu `ProfileBackButton` z `profile_widgets.dart`.
3. Aktualizovat všechny importy v profile subscreenech.

**Dotčené soubory:** `profile_widgets.dart` + všechny profile subscreeny které ho importují (~8 souborů)

---

### 2.3 — GradientPillButton → GlassButton

**Aktuální stav:** `GradientPillButton` v `lib/screens/meals/meal_components.dart` (lines 645-680) — pill tvar, gradient fill, text only.

**Akce:**
1. Nahradit `GradientPillButton(label:, gradient:, onTap:)` za:
   ```dart
   GlassButton.custom(
     onTap: onTap,
     child: Text(label, style: ...),
     // nebo s nastavením glassColor pro tint
   )
   ```
2. Alternativa: Vytvořit `FoodyGlassPrimaryButton` wrapper pokud chceme zachovat konzistentní API:
   ```dart
   class FoodyGlassPrimaryButton extends StatelessWidget {
     final String label;
     final VoidCallback? onTap;
     final IconData? icon;
     // Interně: GlassButton.custom(child: Row(icon, text))
   }
   ```

**Použití v kódu (hledat `GradientPillButton`):**
- `lib/screens/meals/edit_meal_screen.dart` — save/confirm akce
- `lib/widgets/edit_flow/edit_flow_widgets.dart` — EditBottomActionBar primary
- `lib/screens/meals/meal_components.dart` — SyncCard button
- Případně další

**Soubory k úpravě:** 3-5 souborů + smazání třídy z meal_components.dart

---

### 2.4 — OutlinePillButton → GlassButton (sekundární varianta)

**Aktuální stav:** `OutlinePillButton` v `lib/screens/meals/meal_components.dart` (lines 682-721) — pill tvar, surface bg, outline border, optional icon.

**Akce:**
1. Nahradit za `GlassButton.custom(child: Row(icon, text))` s nižším `thickness` pro subtilnější glass efekt.
2. Nebo vytvořit `FoodyGlassSecondaryButton` wrapper.

**Použití:** Sekundární akce v meal screenech, EditBottomActionBar secondary.

**Soubory k úpravě:** 2-4 soubory

---

### 2.5 — ProfilePrimaryButton / ProfileOutlineButton → GlassButton

**Aktuální stav:** Duplicitní button widgety v `lib/screens/profile/profile_widgets.dart`:
- `ProfilePrimaryButton` (lines 154-211) — gradient, pill, optional leading widget
- `ProfileOutlineButton` (lines 213-265) — surface bg, outline, optional leading widget

**Akce:**
1. Po vytvoření `FoodyGlassPrimaryButton` a `FoodyGlassSecondaryButton` (viz 2.3/2.4) nahradit oba profil buttony za tyto sdílené wrappery.
2. Smazat obě třídy z `profile_widgets.dart`.
3. Aktualizovat importy ve všech profile subscreenech.

**Dotčené soubory:** `profile_widgets.dart` + profile subscreeny (~8 souborů)

---

### 2.6 — ScanPrimaryButton → GlassButton

**Aktuální stav:** `ScanPrimaryButton` v `lib/screens/scan/scan_widgets.dart` (lines 9-58) — gradient pill s optional ikonou a stínem.

**Akce:**
1. Nahradit za `FoodyGlassPrimaryButton` (sdílený wrapper z 2.3).
2. Smazat `ScanPrimaryButton` ze `scan_widgets.dart`.

**Soubory k úpravě:** `scan_widgets.dart` + scan screeny které ho používají

---

### 2.7 — ScanCircleButton → GlassIconButton

**Aktuální stav:** `ScanCircleButton` v `lib/screens/scan/scan_widgets.dart` (lines 121-160) — circular Container s ikonou, custom bg/icon color, shadow.

**Akce:**
1. Nahradit za:
   ```dart
   GlassIconButton(
     icon: Icon(iconData),
     onPressed: cb,
     shape: GlassIconButtonShape.circle,
     size: AppSizes.scanTopButtonSize,
   )
   ```
2. Smazat `ScanCircleButton` ze `scan_widgets.dart`.

**Použití:** Torch, gallery, zoom buttony v scan_camera_screen.

**Soubory k úpravě:** `scan_widgets.dart` + `scan_camera_screen.dart`

---

### 2.8 — VoiceLogAnalyzeButton → GlassButton

**Aktuální stav:** `VoiceLogAnalyzeButton` v `lib/screens/logs/voice_widgets.dart` (lines 170-209) — gradient, md radius, auto_awesome ikona.

**Akce:**
1. Nahradit za `FoodyGlassPrimaryButton(label: label, icon: Icons.auto_awesome, onTap: cb)`.
2. Smazat třídu z `voice_widgets.dart`.

**Soubory k úpravě:** `voice_widgets.dart` + `voice_log_screen.dart`

---

### 2.9 — VoiceMicButton → GlassButton (circular)

**Aktuální stav:** `VoiceMicButton` v `lib/screens/logs/voice_widgets.dart` (lines 211-247) — kruhový, gradient/solid color, mic ikona.

**Akce:**
1. Nahradit za:
   ```dart
   GlassButton(
     icon: Icons.mic_rounded,
     onTap: cb,
     width: AppSizes.voiceMicSize,
     height: AppSizes.voiceMicSize,
     shape: LiquidOval(),
   )
   ```
2. Smazat třídu z `voice_widgets.dart`.

**Soubory k úpravě:** `voice_widgets.dart` + `voice_log_screen.dart`

---

### 2.10 — EditBottomActionBar → GlassToolbar + GlassButtonGroup

**Aktuální stav:** `EditBottomActionBar` v `lib/widgets/edit_flow/edit_flow_widgets.dart` (lines ~1-70) — Row se dvěma pill buttony (primary + optional secondary), pinned dole.

**Akce:**
1. Nahradit za:
   ```dart
   GlassToolbar(
     children: [
       Expanded(child: FoodyGlassSecondaryButton(label: cancelLabel, onTap: onCancel)),
       SizedBox(width: AppSpacing.s),
       Expanded(child: FoodyGlassPrimaryButton(label: confirmLabel, onTap: onConfirm)),
     ],
   )
   ```
2. Smazat `EditBottomActionBar` třídu.

**Soubory k úpravě:** `edit_flow_widgets.dart` + screeny které ho používají (edit_meal, edit_ingredient)

---

## Phase 3: Top-Right Corner Buttons

### 3.1 — Edit Meal Screen: Bookmark + Menu buttons → GlassIconButton

**Aktuální stav:** `_EditMealTopBar` v `lib/screens/meals/edit_meal_screen.dart` (lines ~1100-1120) používá `_GlassIconButton` (private class) — circular Container s glass sheet bg, outline border.

**Akce:**
1. Nahradit oba private `_GlassIconButton` widgety za package `GlassIconButton`:
   ```dart
   // Bookmark toggle
   GlassIconButton(
     icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
     onPressed: toggleFavorite,
     shape: GlassIconButtonShape.circle,
   ),
   // Menu
   GlassIconButton(
     icon: Icon(Icons.more_horiz),
     onPressed: openActionSheet,
     shape: GlassIconButtonShape.circle,
   ),
   ```
2. Smazat private `_GlassIconButton` třídu z edit_meal_screen.dart.

**Soubory k úpravě:** `lib/screens/meals/edit_meal_screen.dart`

---

### 3.2 — Exercise Log Home: Favorites Filter → GlassIconButton

**Aktuální stav:** `_CircleButton` v `lib/screens/logs/exercise_log_home_screen.dart` — circular Container se surface/backgroundAlt, outline border, conditional fill.

**Akce:**
1. Nahradit `_CircleButton` za `GlassIconButton`:
   ```dart
   GlassIconButton(
     icon: Icon(showFavorites ? Icons.bookmark : Icons.bookmark_border),
     onPressed: toggleFilter,
     shape: GlassIconButtonShape.circle,
   )
   ```
2. Nahradit i back chevron button na levé straně za `GlassIconButton`.
3. Smazat `_CircleButton` třídu.

**Soubory k úpravě:** `lib/screens/logs/exercise_log_home_screen.dart`

---

### 3.3 — Dashboard: Streak Pill + Calendar Pill

**Aktuální stav:** `_DashboardStreakPill` a `_DashboardCalendarPill` v `lib/screens/main_screen.dart` — `LiquidGlassTapEffect` wrapping `GlassContainer` s ikonou + textem.

**Akce:** Tyto již používají `GlassContainer` z package — **ponechat** nebo přepsat na `GlassChip`:
```dart
GlassChip(
  label: streakCount.toString(),
  icon: Icons.local_fire_department,
  onTap: openStreakDialog,
)
```

**Rozhodnutí:** Volitelné — závisí na tom jestli GlassChip vizuálně sedí. Pokud ne, ponechat stávající GlassContainer řešení.

**Soubory k úpravě:** `lib/screens/main_screen.dart` (volitelné)

---

### 3.4 — Scan Camera Screen: Top control buttons

**Aktuální stav:** Torch, gallery, zoom tlačítka — již řešeno v 2.7 (ScanCircleButton → GlassIconButton).

---

### 3.5 — Exercise Detail Screen: Options button (top-right)

**Aktuální stav:** Hledat v `lib/screens/logs/exercise_detail_screen.dart` — pravděpodobně `_CircleButton` nebo podobný pattern pro "more options".

**Akce:**
1. Nahradit za `GlassIconButton(icon: Icon(Icons.more_horiz), onPressed: showOptions)`.

**Soubory k úpravě:** `lib/screens/logs/exercise_detail_screen.dart`

---

## Phase 4: Modální Overlaye

### 4.1 — DashboardCalendarSheet → GlassSheet

**Aktuální stav:** `lib/widgets/dashboard_calendar_sheet.dart` — 370 řádků, custom `_GlassSheetPainter` s BackdropFilter, specular highlight, semi-transparent fill.

**Akce:**
1. Nahradit `showModalBottomSheet` za `GlassSheet.show()`:
   ```dart
   GlassSheet.show(
     context: context,
     isScrollControlled: true,
     child: _CalendarContent(...),  // extrahovat obsah bez glass painteru
   );
   ```
2. Přesunout kalendářní logiku (grid, month picker, navigation) do separátní `_CalendarContent` widget.
3. Smazat `_GlassSheetPainter`, `BackdropFilter` wrapping a manuální dekoraci.

**Soubory k úpravě:** `lib/widgets/dashboard_calendar_sheet.dart` + `lib/screens/main_screen.dart` (volání)

---

### 4.2 — QuickActionSheet → GlassSheet + GlassButton grid

**Aktuální stav:** `lib/widgets/quick_action_sheet.dart` — 207 řádků, Material surface, custom tile grid + list rows.

**Akce:**
1. Nahradit `showModalBottomSheet` za `GlassSheet.show()`.
2. Nahradit `_QuickActionTile` za `GlassButton`:
   ```dart
   GlassButton(
     icon: Icons.restaurant,
     label: tr(LocaleKeys.quick_log_meal),
     onTap: () => navigateToLogMeal(),
   )
   ```
3. Nahradit `_QuickActionRow` za `GlassButton.custom(child: ListTile(...))` nebo ponechat jako custom row uvnitř GlassSheet.
4. Smazat `_QuickActionTile` a `_QuickActionRow` třídy.

**Soubory k úpravě:** `lib/widgets/quick_action_sheet.dart` + `lib/screens/main_screen.dart`

---

### 4.3 — GlassActionSheet (custom) → showGlassActionSheet() z package

**Aktuální stav:** Custom `GlassActionSheet` v `lib/screens/meals/meal_components.dart` (lines 723-787) — BackdropFilter + glassSheet bg s `_GlassActionSheetItem` rows. Voláno přes `showGeneralDialog` s positioned overlay.

**Akce:**
1. Nahradit celý `showGeneralDialog` blok v `edit_meal_screen.dart` za:
   ```dart
   showGlassActionSheet(
     context: context,
     title: mealName,
     actions: [
       GlassActionSheetAction(label: 'Share', icon: Icons.share, onPressed: share),
       GlassActionSheetAction(label: 'Delete', icon: Icons.delete, isDestructive: true, onPressed: delete),
       // ...
     ],
   );
   ```
2. Smazat custom `GlassActionSheet` a `_GlassActionSheetItem` třídy z `meal_components.dart`.

**Poznámka:** Custom verze je positioned top-right (ne bottom sheet). Package `GlassActionSheet` je bottom sheet. Zvážit jestli je to OK UX change — pokud ne, ponechat custom positioning a jen nahradit content za package widgety.

**Soubory k úpravě:** `lib/screens/meals/meal_components.dart` + `lib/screens/meals/edit_meal_screen.dart`

---

### 4.4 — ExerciseDetailOptionsSheet → showGlassActionSheet()

**Aktuální stav:** `lib/screens/logs/exercise_detail_options_sheet.dart` — BackdropFilter + glassSheet bg, 2 option rows (report, delete).

**Akce:**
1. Nahradit celý sheet za:
   ```dart
   showGlassActionSheet(
     context: context,
     actions: [
       GlassActionSheetAction(label: tr(LocaleKeys.report), icon: Icons.flag_outlined, onPressed: onReport),
       GlassActionSheetAction(label: tr(LocaleKeys.delete), icon: Icons.delete_outline, isDestructive: true, onPressed: onDelete),
     ],
   );
   ```
2. Smazat `lib/screens/logs/exercise_detail_options_sheet.dart`.

**Soubory k úpravě:** smazat 1 soubor + upravit `exercise_detail_screen.dart`

---

### 4.5 — StreakDialog → GlassDialog

**Aktuální stav:** `lib/widgets/streak_dialog.dart` — Material `AlertDialog`, RoundedRectangleBorder, flame icon, week grid.

**Akce:**
1. Nahradit `showDialog(builder: (_) => StreakDialog())` za:
   ```dart
   GlassDialog.show(
     context: context,
     title: '$streakCount Day Streak!',
     content: _StreakWeekGrid(...),  // extrahovat grid widget
     actions: [
       GlassDialogAction(label: tr(LocaleKeys.ok), onPressed: () => Get.back()),
     ],
   );
   ```
2. Extrahovat week grid do standalone widgetu.
3. Smazat `StreakDialog` třídu nebo refaktorovat na content-only widget.

**Soubory k úpravě:** `lib/widgets/streak_dialog.dart` + `lib/screens/main_screen.dart`

---

### 4.6 — EditConfirmSheet → GlassDialog

**Aktuální stav:** `lib/widgets/edit_flow/edit_flow_widgets.dart` — Surface card s title, message, cancel + confirm buttons. Používán pro destruktivní potvrzení (delete meal/ingredient/weight).

**Akce:**
1. Nahradit za:
   ```dart
   GlassDialog.show(
     context: context,
     title: title,
     message: message,
     actions: [
       GlassDialogAction(label: cancelLabel, onPressed: onCancel),
       GlassDialogAction(label: confirmLabel, isDestructive: true, onPressed: onConfirm),
     ],
   );
   ```
2. Smazat `EditConfirmSheet` třídu.

**Použití:**
- `lib/screens/meals/edit_meal_screen.dart` — delete meal
- `lib/screens/ingredients/edit_ingredient_screen.dart` — delete ingredient
- `lib/screens/logs/weight_log_sheet.dart` — delete weight entry

**Soubory k úpravě:** `edit_flow_widgets.dart` + 3 screen soubory

---

### 4.7 — Voice Permission Dialog → GlassDialog

**Aktuální stav:** `lib/screens/logs/voice_log_screen.dart` (lines 124-150) — `showGeneralDialog` s BackdropFilter, semi-transparent white container, custom border.

**Akce:**
1. Nahradit za:
   ```dart
   GlassDialog.show(
     context: context,
     title: tr(LocaleKeys.voice_permission_title),
     message: tr(LocaleKeys.voice_permission_message),
     actions: [
       GlassDialogAction(label: tr(LocaleKeys.cancel), onPressed: () => Get.back()),
       GlassDialogAction(label: tr(LocaleKeys.settings), onPressed: openSettings),
     ],
   );
   ```

**Soubory k úpravě:** `lib/screens/logs/voice_log_screen.dart`

---

### 4.8 — PickerSheet → GlassSheet

**Aktuální stav:** `lib/screens/meals/meal_sheets.dart` (PickerSheet) — Material surface, border radius lg, checkmark selection.

**Akce:**
1. Wrappovat obsah do `GlassSheet.show()` místo raw `showModalBottomSheet`.
2. Ponechat selection logiku, jen změnit container.

**Soubory k úpravě:** `lib/screens/meals/meal_sheets.dart` + volání v `edit_meal_screen.dart`

---

### 4.9 — Scan Tips Sheet → GlassSheet

**Aktuální stav:** `lib/screens/scan/scan_preview_screen.dart` (lines 143-182) — Material surface, tip rows.

**Akce:**
1. Wrappovat do `GlassSheet.show()`.

**Soubory k úpravě:** `lib/screens/scan/scan_preview_screen.dart`

---

### 4.10 — Profile picker sheets (DOB, Gender) → GlassSheet

**Aktuální stav:** `lib/screens/profile/subscreens/personal_details_screen.dart` — Material surface s CupertinoDatePicker / radio selection.

**Akce:**
1. Wrappovat oba do `GlassSheet.show()` místo raw `showModalBottomSheet`.

**Soubory k úpravě:** `lib/screens/profile/subscreens/personal_details_screen.dart`

---

### 4.11 — Dialog Utils: showProgressHUD → GlassDialog s GlassProgressIndicator

**Aktuální stav:** `lib/utils/dialog_utils.dart` — `showProgressHUD()` zobrazuje Material dialog s CircularProgressIndicator.

**Akce:**
1. Nahradit za:
   ```dart
   GlassDialog.show(
     context: context,
     content: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         GlassProgressIndicator.circular(),
         if (text != null) Text(text),
       ],
     ),
   );
   ```

**Soubory k úpravě:** `lib/utils/dialog_utils.dart`

---

## Phase 5: Cleanup

### 5.1 — Smazat nepotřebné soubory

Po dokončení všech fází smazat:
- [x] `lib/widgets/app_bar.dart` (nepoužívaný CustomAppBar) ✅ SMAZÁNO
- [x] `lib/widgets/liquid_glass/liquid_glass_back_button.dart` (nahrazeno GlassIconButton) ✅ SMAZÁNO
- [ ] `lib/screens/logs/exercise_detail_options_sheet.dart` — PONECHÁNO (refaktorováno na static show() s showGlassActionSheet)

### 5.2 — Smazat nepotřebné třídy z existujících souborů

- [x] `_GlassIconButton` z `edit_meal_screen.dart` ✅
- [x] `_CircleButton` z `exercise_log_home_screen.dart` ✅
- [x] `_CircleButton` z `add_exercise_screen.dart` ✅
- [x] `_CircleButton` z `weight_log_sheet.dart` ✅
- [x] `_CircleButton` z `exercise_detail_screen.dart` ✅
- [x] `_CircleButton` z `edit_ingredient_screen.dart` ✅
- [x] `GlassActionSheet` + `_GlassActionSheetItem` z `meal_components.dart` ✅
- [x] `GradientPillButton` z `meal_components.dart` ✅
- [x] `OutlinePillButton` z `meal_components.dart` ✅
- [x] `_PermissionDialogButton` z `voice_log_screen.dart` ✅
- [x] `_SegmentItem` z `preferences_screen.dart` ✅
- [N/A] `ProfileBackButton`, `ProfilePrimaryButton`, `ProfileOutlineButton` — wrapper třídy PONECHÁNY, interně delegují na glass widgety (zachovány kvůli zpětné kompatibilitě importů v ~19 souborech)
- [N/A] `ScanPrimaryButton`, `ScanCircleButton` — wrapper třídy PONECHÁNY, interně delegují na glass widgety
- [N/A] `VoiceLogIconButton`, `VoiceLogAnalyzeButton`, `VoiceMicButton` — wrapper třídy PONECHÁNY, interně delegují na glass widgety
- [N/A] `EditBottomActionBar` — PONECHÁN, interně používá `FoodyGlassPrimaryButton`/`FoodyGlassSecondaryButton`
- [x] `EditConfirmSheet` — refaktorován na utility třídu se static `show()` metodou → `GlassDialog`
- [N/A] `_SegmentedControl` (progress, weight) — wrapper třídy PONECHÁNY, interně delegují na `GlassSegmentedControl`
- [N/A] `_AppearanceSegmented` — wrapper třída PONECHÁNA, interně deleguje na `GlassSegmentedControl`
- [N/A] `SelectMealSegmentedTabs` — wrapper třída PONECHÁNA, interně deleguje na `GlassTabBar`

### 5.3 — Nové shared wrappery

Vytvořit v `lib/widgets/`:
- [x] `foody_glass_app_bar.dart` — thin wrapper nad GlassAppBar s app defaults ✅ VYTVOŘENO
- [x] `foody_glass_buttons.dart` — `FoodyGlassPrimaryButton` + `FoodyGlassSecondaryButton` wrappery ✅ VYTVOŘENO

### 5.4 — Ověření

- [x] `flutter analyze` — 0 errors, 0 new warnings ✅
- [x] `dart format --line-length 180 lib/` — formátování OK ✅
- [ ] Manuální test všech dotčených obrazovek
- [ ] Zkontrolovat glass quality konzistenci (premium vs standard kde je to vhodné)

---

## Stav implementace (aktualizováno 2026-03-12)

### ✅ HOTOVO — Phase 1.2: GlassBottomBar
Již bylo implementováno před tímto plánem.

### ✅ HOTOVO — Phase 1.3: GlassSegmentedControl / GlassTabBar
4 soubory upraveny:
- `progress_screen.dart` — `_SegmentedControl` → `GlassSegmentedControl`
- `weight_progress_card.dart` — `_SegmentedControl` → `GlassSegmentedControl`
- `preferences_screen.dart` — `_AppearanceSegmented` → `GlassSegmentedControl`
- `select_meal_widgets.dart` — `SelectMealSegmentedTabs` → `GlassTabBar`

### ✅ HOTOVO — Phase 2: Tlačítka
Všechny custom buttony nahrazeny:
- `LiquidGlassBackButton` → `GlassIconButton` (soubor smazán, -319 řádků)
- `GradientPillButton` / `OutlinePillButton` → `FoodyGlassPrimaryButton` / `FoodyGlassSecondaryButton` (třídy smazány z `meal_components.dart`)
- `ProfileBackButton/PrimaryButton/OutlineButton` → interně delegují na glass widgety
- `ScanPrimaryButton/CircleButton` → interně delegují na glass widgety
- `VoiceLogIconButton/AnalyzeButton/MicButton` → interně delegují na glass widgety
- `EditBottomActionBar` → interně používá `FoodyGlassPrimaryButton`/`FoodyGlassSecondaryButton`

Dotčené soubory s přímou náhradou (ne přes wrappery):
- `edit_meal_screen.dart` — `OutlinePillButton`/`GradientPillButton` → `FoodyGlassSecondaryButton`/`FoodyGlassPrimaryButton`
- `edit_ingredient_screen.dart` — `GradientPillButton` → `FoodyGlassPrimaryButton`
- `report_meal_screen.dart` — `GradientPillButton` → `FoodyGlassPrimaryButton`
- `fix_result_screen.dart` — `GradientPillButton` → `FoodyGlassPrimaryButton`
- `meal_components.dart` SyncCard — `GradientPillButton` → `FoodyGlassPrimaryButton`

### ✅ HOTOVO — Phase 3: Top-Right Corner Buttons
Všechny `_CircleButton` / `_GlassIconButton` private třídy nahrazeny za `GlassIconButton`:
- `edit_meal_screen.dart` — back, bookmark, menu buttons
- `exercise_log_home_screen.dart` — back, favorites filter
- `add_exercise_screen.dart` — back, favorites filter
- `exercise_detail_screen.dart` — back, bookmark, options
- `weight_log_sheet.dart` — back button
- `edit_ingredient_screen.dart` — back, delete buttons

### ✅ HOTOVO — Phase 4: Modální Overlaye
Všechny custom overlaye nahrazeny:
- `dashboard_calendar_sheet.dart` — `showModalBottomSheet` → `GlassSheet.show()`, `_GlassSheetPainter` smazán
- `streak_dialog.dart` — `AlertDialog` → `GlassDialog.show()`
- `exercise_detail_options_sheet.dart` — custom sheet → `showGlassActionSheet()`
- `edit_meal_screen.dart` action sheet — `showGeneralDialog` → `showGlassActionSheet()`
- `edit_flow_widgets.dart` EditConfirmSheet — `Container` widget → `GlassDialog.show()` static method
- `quick_action_sheet.dart` — `showModalBottomSheet` → `GlassSheet.show()`
- `voice_log_screen.dart` permission dialog — `showGeneralDialog` + `BackdropFilter` → `GlassDialog.show()`
- `scan_preview_screen.dart` tips sheet — `showModalBottomSheet` → `GlassSheet.show()`
- `personal_details_screen.dart` — 3× `showModalBottomSheet` → `GlassSheet.show()`
- `edit_meal_screen.dart` PickerSheet/mealtime — 2× `showModalBottomSheet` → `GlassSheet.show()`
- `dialog_utils.dart` showProgressHUD — `material.showDialog` → `GlassDialog.show()`

### ✅ HOTOVO — Phase 1.1: GlassAppBar na všech obrazovkách
`FoodyGlassAppBar` wrapper vytvořen v `lib/widgets/foody_glass_app_bar.dart`. Custom `SafeArea` + `Padding` + `Row` top bary nahrazeny za `FoodyGlassAppBar` (buď jako `Scaffold.appBar` nebo inline).

Dotčené soubory:
- `foody_glass_app_bar.dart` — nový wrapper nad `GlassAppBar` s `useOwnLayer: true`, default back button, centred title
- `exercise_log_home_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar`
- `exercise_detail_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar`
- `add_exercise_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar`
- `weight_log_sheet.dart` — `Scaffold.appBar: FoodyGlassAppBar`
- `edit_ingredient_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar`
- `scan_preview_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar` s custom `titleWidget` (retake/help pill)
- `voice_log_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar` s close icon + help action
- `select_meal_screen.dart` — `Scaffold.appBar: FoodyGlassAppBar` s mealtime picker titleWidget
- `edit_meal_screen.dart` — `_EditMealTopBar` interně deleguje na `FoodyGlassAppBar`
- `profile_widgets.dart` — `ProfileTopBar` interně deleguje na `FoodyGlassAppBar` (cascades to all ~8 profile subscreens)

---

## Shrnutí dopadů (finální)

| Kategorie | Dotčených souborů | Smazaných tříd | Smazaných souborů | Nových souborů |
|-----------|-------------------|----------------|-------------------|----------------|
| Navigace (Segmented) | 4 | 1 (_SegmentItem) | 0 | 0 |
| Tlačítka | ~15 | 5 (GradientPill, OutlinePill, GlassActionSheet, GlassActionSheetItem, _PermissionDialogButton) | 2 (back_button, app_bar) | 1 (foody_glass_buttons) |
| Top-right corner buttons | 6 | 6 (_CircleButton ×5, _GlassIconButton ×1) | 0 | 0 |
| Overlaye | ~12 | 1 (_GlassSheetPainter) | 0 | 0 |
| GlassAppBar (navigace) | 11 | 0 | 0 | 1 (foody_glass_app_bar) |
| **Hotovo celkem** | **~40 unikátních souborů** | **13 tříd smazáno** | **2 soubory smazány** | **2 nové soubory** |

**Poznámka k přístupu:** Většina wrapper tříd (ProfileBackButton, ScanPrimaryButton, VoiceLogAnalyzeButton, _SegmentedControl atd.) byla PONECHÁNA s původními názvy/konstruktory — pouze jejich `build()` metody byly nahrazeny za glass widgety. Toto eliminovalo kaskádové změny importů v desítkách souborů.
