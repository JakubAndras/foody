# Liquid Glass — Architecture & Usage

This folder contains the app's custom liquid glass system built on top of two separate packages.

---

## Section 1: `liquid_glass_easy` (Low-level refraction engine)

**Package:** `liquid_glass_easy: 1.1.1`

Low-level shader-based glass refraction. Captures background content and renders it through configurable glass lenses with distortion, chromatic aberration, blur, and lighting effects. Requires manual `LiquidGlassView` + `LiquidGlass` widget tree setup.

### Custom wrappers (this folder)

| File | What it provides |
|------|-----------------|
| `liquid_glass_system.dart` | `AppLiquidGlassViewConfig` — view-level config (pixelRatio, refresh rate, sync). `AppLiquidGlassLensConfig` — lens-level config (distortion, shape, blur, chromatic aberration) with a `.build()` factory for `LiquidGlass`. `AppLiquidGlassPresets` — tuned presets: `mainTabView`, `mainTabBarLens`, `basicButtonLens`. `AppLiquidGlassLayer` — convenience `StatelessWidget` wrapping `LiquidGlassView`. |
| `liquid_glass_back_button.dart` | `LiquidGlassBackButton` — custom glass-morphic back/close button with press animation, glint sweep, ambient glow, and haptic feedback. Two named constructors: `.back()` and `.close()`. |
| `liquid_glass_tap_effect.dart` | `LiquidGlassTapAnimator` — drives scale-pop animation for glass lens configs (use inside GetxController with `GetTickerProviderStateMixin`). `LiquidGlassTapEffect` — drop-in replacement for `GestureDetector` that scales child 1.0 → peak → 1.0 on tap with haptics. |

### Where used

| Location | Usage |
|----------|-------|
| `lib/screens/main_screen.dart` | Main 3-tab shell — `AppLiquidGlassLayer` renders the bottom tab bar as glass lenses over the dashboard/progress/profile background. Uses `mainTabView` and `mainTabBarLens` presets. `LiquidGlassTapAnimator` drives tab-switch pop animation. |
| `lib/screens/meals/edit_meal_screen.dart` | `LiquidGlassBackButton` for navigation back. |
| `lib/screens/profile/subscreens/glass_test_screen.dart` | Debug test screen — raw `LiquidGlassView` with multiple draggable lens configurations and swappable network-image backgrounds. |

---

## Section 2: `liquid_glass_widgets` (High-level widget library)

**Package:** `liquid_glass_widgets: ^0.4.0-dev.4`

Apple iOS 26 Liquid Glass design system with 32 pre-built widgets across 6 categories (Containers, Interactive, Input, Feedback, Overlays, Surfaces). Shader-based glassmorphism, physics-driven jelly animations, and dynamic lighting. Two quality modes (`standard` / `premium`) and grouped/standalone rendering.

### Initialization

`LiquidGlassWidgets.initialize()` is called in `lib/main.dart` at app startup to precache shaders and prevent white flash.

### Where used

| Location | Usage |
|----------|-------|
| `lib/screens/profile/subscreens/liquid_glass_widgets_test_screen.dart` | Showcase/test screen demonstrating all widget categories: `GlassCard`, `GlassPanel`, `GlassContainer`, `GlassButton`, `GlassIconButton`, `GlassChip`, `GlassSwitch`, `GlassSlider`, `GlassSegmentedControl`, `GlassBadge`, `GlassProgressIndicator`, `GlassDialog`, `GlassSheet`, `GlassActionSheet`, `GlassAppBar`, `GlassTabBar`, `GlassToolbar`, `GlassTextField`, `GlassTextArea`, `GlassPasswordField`, `GlassSearchBar`, `GlassPicker`. Uses `LiquidGlassScope.stack` + `GlassBottomBar` for navigation. |

### Planned usage

- **Main bottom tab bar** — replace or enhance current `liquid_glass_easy`-based tab bar with `GlassBottomBar` from this package.
- Additional glass surfaces and overlays throughout the app as the package matures past dev pre-release.

### Key API notes

- `GlassButton` requires `icon` + `onTap`; for custom content use `GlassButton.custom(child: ..., onTap: ...)`.
- `GlassIconButton` uses `onPressed` (not `onTap`).
- Text fields use `placeholder` (not `hintText`).
- `GlassTabBar` tabs are `List<GlassTab>` objects, not strings.
- `GlassDialog` uses `GlassDialogAction(label:, onPressed:)` — prefer `GlassDialog.show()` static method.
- `GlassActionSheet` — use top-level `showGlassActionSheet()` function.
- `GlassBadge` wraps a child widget: `GlassBadge(count: 3, child: ...)`.
- `GlassPicker` is a display-trigger (shows selected value), not a scroll wheel.
