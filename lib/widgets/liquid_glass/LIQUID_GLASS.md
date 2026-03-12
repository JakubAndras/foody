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
| `lib/screens/main_screen.dart` | `LiquidGlassTapEffect` wraps dashboard pills (streak + calendar) for pop animation on tap. |
| `lib/screens/meals/edit_meal_screen.dart` | `LiquidGlassBackButton` for navigation back. |
| `lib/screens/profile/subscreens/glass_test_screen.dart` | Debug test screen — raw `LiquidGlassView` with multiple draggable lens configurations and swappable network-image backgrounds. |

---

## Section 2: `liquid_glass_widgets` (High-level widget library)

**Package:** `liquid_glass_widgets: 0.4.0-dev.4`

Apple iOS 26 Liquid Glass design system with 32 pre-built widgets across 6 categories (Containers, Interactive, Input, Feedback, Overlays, Surfaces). Shader-based glassmorphism, physics-driven jelly animations, and dynamic lighting. Two quality modes (`standard` / `premium`) and grouped/standalone rendering.

### Initialization

`LiquidGlassWidgets.initialize()` is called in `lib/main.dart` at app startup to precache shaders and prevent white flash.

### Where used

| Location | Usage |
|----------|-------|
| `lib/screens/main_screen.dart` | **Main bottom tab bar.** `LiquidGlassScope` + `LiquidGlassBackground` wraps the active screen body so `GlassBottomBar` refracts live scrollable content. `GlassBottomBarExtraButton` replaces the old FAB glass lens. Dashboard pills use `GlassContainer` for their glass appearance. |
| `lib/screens/profile/subscreens/liquid_glass_widgets_test_screen.dart` | Showcase/test screen demonstrating all widget categories. Uses `LiquidGlassScope.stack` + `GlassBottomBar` for navigation. |

### Refraction pattern

The main screen uses `LiquidGlassScope` (manual mode) with `LiquidGlassBackground` wrapping the scaffold body. This allows `GlassBottomBar` to refract the actual live screen content (not a static gradient). The glass shader captures via `RepaintBoundary.toImage()` at ~10fps during interaction, full fps at rest.

```dart
LiquidGlassScope(
  child: Scaffold(
    body: LiquidGlassBackground(
      child: activeBody,  // scrollable, interactive
    ),
    bottomNavigationBar: GlassBottomBar(...),
  ),
)
```

### Customizing glass appearance (`LiquidGlassSettings`)

All glass widgets accept a `glassSettings` (or `settings`) parameter to control the glass look:

```dart
LiquidGlassSettings(
  thickness: 25,              // Material thickness (higher = more opaque glass)
  blur: 2,                    // Blur radius (lower = sharper, more transparent)
  glassColor: Colors.white.withValues(alpha: 0.6),  // Tint color + opacity
  lightIntensity: 1.5,        // Directional light strength
  refractiveIndex: 1.5,       // Light bending (1.0–2.0)
  lightAngle: 45.0,           // Light direction in degrees
  ambientStrength: 0.3,       // Ambient light contribution
  saturation: 1.2,            // Color saturation multiplier
  chromaticAberration: 0.002, // RGB separation for depth effect
)
```

**Current app tuning (main bottom bar):**
- `thickness: 25` — light glass material
- `blur: 2` — very subtle blur, content visible through
- `glassColor: white @ 60%` — strong white tint while staying transparent
- `lightIntensity: 1.5` — slightly elevated light for white appearance

**Tips for tuning:**
- More white/opaque → increase `glassColor` alpha and/or `thickness`
- More transparent → decrease `blur` and `glassColor` alpha
- Sharper content behind glass → lower `blur` (0–4 range)
- Softer frosted look → higher `blur` (8–18 range)
- `GlassQuality.premium` for static bars, `GlassQuality.standard` for scrollable content

### Key API notes

- `GlassButton` requires `icon` + `onTap`; for custom content use `GlassButton.custom(child: ..., onTap: ...)`.
- `GlassIconButton` uses `onPressed` (not `onTap`).
- Text fields use `placeholder` (not `hintText`).
- `GlassTabBar` tabs are `List<GlassTab>` objects, not strings.
- `GlassDialog` uses `GlassDialogAction(label:, onPressed:)` — prefer `GlassDialog.show()` static method.
- `GlassActionSheet` — use top-level `showGlassActionSheet()` function.
- `GlassBadge` wraps a child widget: `GlassBadge(count: 3, child: ...)`.
- `GlassPicker` is a display-trigger (shows selected value), not a scroll wheel.
