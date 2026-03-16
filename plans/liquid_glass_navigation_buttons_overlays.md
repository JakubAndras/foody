# Liquid Glass Widgets Migration: Navigation, Buttons & Overlays

Nahrazení custom widgetů za `liquid_glass_widgets` package ekvivalenty v kategoriích: navigace (AppBar, BottomBar, SegmentedControl), tlačítka, top-right corner buttony a modální overlaye.

---

## Postup implementace

1. **Krok 0** — Vytvořit shared wrappery ✅
2. **Krok 1** — Phase 2: Tlačítka ✅
3. **Krok 2** — Phase 3: Top-right corner buttons ✅
4. **Krok 3** — Phase 1.1: GlassAppBar ✅
5. **Krok 4** — Phase 1.3: Segmented controls ✅
6. **Krok 5** — Phase 4: Overlaye — **⏸ ODLOŽENO** (bude se dělat později, možná)
7. **Krok 6** — Phase 5: Cleanup ✅ (analyze + format OK)

> **Rozhodnutí 2026-03-12:** `FoodyPrimaryButton` / `FoodySecondaryButton` jsou prozatím NE-skleněné — sjednocený Material design (gradient pill / outline pill). Glass verze se přidá později. Krok 5 (overlaye) se přeskakuje.

---

## ✅ Krok 0: Shared Wrappery

- [x] `lib/widgets/foody_glass_app_bar.dart` — `FoodyGlassAppBar` wrapper nad `GlassAppBar`
- [x] `lib/widgets/foody_glass_buttons.dart` — `FoodyPrimaryButton` + `FoodySecondaryButton` (Material, ne-glass)

## ✅ Phase 1: Navigace

### ✅ 1.2 — GlassBottomBar (hotovo dříve)

### ✅ 1.1 — GlassAppBar na všech obrazovkách

| Soubor | Změna |
|--------|-------|
| `exercise_log_home_screen.dart` | SafeArea+Row → `Scaffold.appBar: FoodyGlassAppBar` |
| `exercise_detail_screen.dart` | SafeArea+Row → `FoodyGlassAppBar` s bookmark+options actions |
| `add_exercise_screen.dart` | SafeArea+Row → `FoodyGlassAppBar` s bookmark action |
| `weight_log_sheet.dart` | SafeArea+Row → `FoodyGlassAppBar` |
| `edit_ingredient_screen.dart` | Padding+Row → `FoodyGlassAppBar` s conditional delete action |
| `scan_preview_screen.dart` | `_buildTopBar()` → `FoodyGlassAppBar` s titleWidget (retake/help pill) |
| `voice_log_screen.dart` | Padding+Row → `FoodyGlassAppBar` s close icon + help action |
| `select_meal_screen.dart` | Container+Row → `FoodyGlassAppBar` s mealtime picker titleWidget |
| `edit_meal_screen.dart` | `_EditMealTopBar.build()` → `FoodyGlassAppBar` |
| `profile_widgets.dart` | `ProfileTopBar.build()` → `FoodyGlassAppBar` (cascades to ~8 subscreens) |
| `app_bar.dart` | SMAZÁN (nepoužívaný CustomAppBar) |

### ✅ 1.3 — GlassSegmentedControl / GlassTabBar

| Soubor | Třída | Nový widget |
|--------|-------|-------------|
| `progress_screen.dart` | `_SegmentedControl` wrapper → `GlassSegmentedControl` | ✅ |
| `weight_progress_card.dart` | `_SegmentedControl` wrapper → `GlassSegmentedControl` | ✅ |
| `preferences_screen.dart` | `_AppearanceSegmented` wrapper → `GlassSegmentedControl`, `_SegmentItem` smazán | ✅ |
| `select_meal_widgets.dart` | `SelectMealSegmentedTabs` wrapper → `GlassTabBar` | ✅ |

## ✅ Phase 2: Tlačítka

| Soubor | Změna |
|--------|-------|
| `meal_components.dart` | `GradientPillButton` + `OutlinePillButton` třídy SMAZÁNY, SyncCard → `FoodyPrimaryButton` |
| `edit_meal_screen.dart` | `GradientPillButton`/`OutlinePillButton` → `FoodyPrimaryButton`/`FoodySecondaryButton` |
| `edit_ingredient_screen.dart` | `GradientPillButton` → `FoodyPrimaryButton` |
| `report_meal_screen.dart` | `GradientPillButton` → `FoodyPrimaryButton`, `_BackButtonCircle` → `GlassIconButton` |
| `fix_result_screen.dart` | `GradientPillButton` → `FoodyPrimaryButton`, `_BackButtonCircle` → `GlassIconButton` |
| `edit_flow_widgets.dart` | `EditBottomActionBar` interně → `FoodyPrimaryButton`/`FoodySecondaryButton` |
| `profile_widgets.dart` | `ProfileBackButton` → `GlassIconButton`, `ProfilePrimaryButton` → `FoodyPrimaryButton`, `ProfileOutlineButton` → `FoodySecondaryButton` |
| `scan_widgets.dart` | `ScanPrimaryButton` → `FoodyPrimaryButton`, `ScanCircleButton` → `GlassIconButton` |
| `voice_widgets.dart` | `VoiceLogAnalyzeButton` → `FoodyPrimaryButton(icon: auto_awesome)` |
| `liquid_glass_back_button.dart` | SMAZÁN |

## ✅ Phase 3: Top-Right Corner Buttons

| Soubor | Stará třída → nová |
|--------|--------------------|
| `edit_meal_screen.dart` | `_GlassIconButton` → `GlassIconButton`, `LiquidGlassBackButton` → `GlassIconButton` |
| `exercise_log_home_screen.dart` | `_CircleButton` → `GlassIconButton` |
| `add_exercise_screen.dart` | `_CircleButton` → `GlassIconButton` |
| `exercise_detail_screen.dart` | `_CircleButton` → `GlassIconButton` |
| `weight_log_sheet.dart` | `_CircleButton` → `GlassIconButton` |
| `edit_ingredient_screen.dart` | `_CircleIconButton` → `GlassIconButton` |

## ⏸ Phase 4: Modální Overlaye — ODLOŽENO

Tyto změny se budou dělat později:

| Soubor | Aktuální stav | Cíl |
|--------|---------------|-----|
| `dashboard_calendar_sheet.dart` | Custom `_GlassSheetPainter` + `BackdropFilter` | `GlassSheet.show()` |
| `streak_dialog.dart` | Material `AlertDialog` | `GlassDialog.show()` |
| `exercise_detail_options_sheet.dart` | Custom `BackdropFilter` + `glassSheet` bg | `showGlassActionSheet()` |
| `meal_components.dart` | Custom `GlassActionSheet` + `BackdropFilter` | `showGlassActionSheet()` |
| `voice_log_screen.dart` | Custom `showGeneralDialog` + `BackdropFilter` | `GlassDialog.show()` |
| `quick_action_sheet.dart` | Material `Container` | `GlassSheet.show()` |
| `scan_preview_screen.dart` tips | Material `showModalBottomSheet` | `GlassSheet.show()` |
| `personal_details_screen.dart` ×3 | Material `showModalBottomSheet` | `GlassSheet.show()` |
| `dialog_utils.dart` | Material `PlatformAlertDialog` | `GlassDialog.show()` |
| `edit_flow_widgets.dart` EditConfirmSheet | Material `Container` | `GlassDialog.show()` |
| `meal_sheets.dart` | Material `showModalBottomSheet` | `GlassSheet.show()` |
| `edit_meal_screen.dart` ×3 | `showGeneralDialog` / `showModalBottomSheet` | `showGlassActionSheet()` / `GlassSheet.show()` |

## ✅ Phase 5: Cleanup

### Smazané soubory
- [x] `lib/widgets/app_bar.dart`
- [x] `lib/widgets/liquid_glass/liquid_glass_back_button.dart`

### Smazané private třídy
- [x] `_GlassIconButton` z `edit_meal_screen.dart`
- [x] `_CircleButton` z `exercise_log_home_screen.dart`
- [x] `_CircleButton` z `add_exercise_screen.dart`
- [x] `_CircleButton` z `weight_log_sheet.dart`
- [x] `_CircleButton` z `exercise_detail_screen.dart`
- [x] `_CircleIconButton` z `edit_ingredient_screen.dart`
- [x] `_BackButtonCircle` z `report_meal_screen.dart`
- [x] `_BackButtonCircle` z `fix_result_screen.dart`
- [x] `GradientPillButton` z `meal_components.dart`
- [x] `OutlinePillButton` z `meal_components.dart`
- [x] `_SegmentItem` z `preferences_screen.dart`

### Wrapper třídy PONECHÁNY (build() přepsán)
- `ProfileBackButton`, `ProfilePrimaryButton`, `ProfileOutlineButton`
- `ProfileTopBar`
- `ScanPrimaryButton`, `ScanCircleButton`
- `VoiceLogAnalyzeButton`
- `EditBottomActionBar`
- `_SegmentedControl` (progress, weight)
- `_AppearanceSegmented`
- `SelectMealSegmentedTabs`

### Nové soubory
- [x] `lib/widgets/foody_glass_app_bar.dart`
- [x] `lib/widgets/foody_glass_buttons.dart`

### Ověření
- [x] `flutter analyze` — 0 errors, 0 new warnings
- [x] `dart format --line-length 180 lib/` — 22 souborů formátováno
- [ ] Manuální test všech dotčených obrazovek
- [ ] Zkontrolovat glass quality konzistenci

---

## Shrnutí dopadů (finální)

| Kategorie | Souborů | Tříd smazáno | Souborů smazáno | Nových souborů |
|-----------|---------|--------------|-----------------|----------------|
| Shared wrappery (0) | 0 | 0 | 0 | 2 |
| Navigace — AppBar (1.1) | 10 | 0 | 1 | 0 |
| Navigace — Segmented (1.3) | 4 | 1 | 0 | 0 |
| Tlačítka (2) | ~10 | 4 | 1 | 0 |
| Corner buttons (3) | 6 | 8 | 0 | 0 |
| **Celkem** | **~22 unikátních** | **13** | **2** | **2** |
