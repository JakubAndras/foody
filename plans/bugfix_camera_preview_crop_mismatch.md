# Bugfix: Camera Preview Frame Does Not Match Captured Photo

> **Summary**: The live camera preview is rendered with `BoxFit.cover`, cropping the sensor frame to the viewport, while `takePicture()` returns the full uncropped sensor frame. The user composes the shot in the cropped preview but the saved/analyzed image contains extra area (especially below the subject) that was never visible. This plan crops the captured JPEG to the same rectangle the user saw in the preview.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement

During long-term testing (`thesis/testovani/dlouhodoby_text_notes.md`) a participant reported:

> "Ramecek/oriznuti fotky v dynamickem preview pred vyfocenim neodpovida vyfocene fotce. Kdyz si jidlo v preview zaroven na vertikalni a horizontalni stred, tak mam jidla na vysledne fotce nehezky v horni casti fotky a zaroven mam vyfocen i spodni prostor pod jidlem, ktery jsem v preview vubec nevidel."

In plain English: the live preview rectangle and the saved photo do not show the same content. When the user centers food in the preview, the saved photo shows the food shifted toward the top edge with a strip of empty surface below that was never visible during framing. This breaks WYSIWYG, frustrates users, and feeds extra (often distracting) area into the AI meal-recognition prompt, hurting accuracy.

### 1.2 Solution Overview

Crop the captured image (returned by `CameraController.takePicture()`) to match the exact rectangle the user saw in the live preview, *before* navigating to `ScanPreviewScreen`. The crop is derived from the camera's preview size and the on-screen viewport aspect ratio, mirroring the existing `FittedBox(fit: BoxFit.cover)` math used by the live preview widget. This gives true WYSIWYG without introducing letterbox bars and without dropping into native camera surfaces.

### 1.3 Scope: What This IS

- Fix mismatch between live preview and captured photo for `ScanMode.scanMeal` and `ScanMode.foodLabel` (the two modes that call `_capturePhoto`).
- Post-capture image crop applied on a background isolate (so the UI stays responsive) before the file path is handed to `ScanPreviewScreen` and ultimately `AiPipelineService`.
- Optional EXIF-aware orientation handling so the crop happens against the visually-upright image, not the raw sensor orientation.

### 1.4 Scope: What This IS NOT

- Not a redesign of the scan UI or the in-preview frame (`ScanFrameCorners`); the corner frame stays where it is.
- Not a change to barcode scanning (uses `mobile_scanner`, no photo capture).
- Not a change to gallery-imported images (`_pickFromGallery`); user-chosen photos are kept as-is.
- Not a change to weight-log photos (`WeightLogSheet`) — uses `image_picker` only.
- No new dependency on `image_cropper` (which forces a native cropping UI). We do the crop silently.

---

## 2. SUCCESS CRITERIA

Implementation is COMPLETE when ALL criteria are met:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | The image passed to `ScanPreviewScreen` has the same aspect ratio as the camera viewport rectangle on the device. | On iPhone (portrait): place a small object exactly at the center of the live preview, capture, open `ScanPreviewScreen`, confirm the object is still centered. Repeat on an Android device with a different screen aspect. |
| 2 | The captured image contains no pixels that were not visible in the live preview. | Place a colored sticker at each corner of the live-preview viewport, capture, and confirm all four stickers are at (or just inside) the corners of the saved JPEG. |
| 3 | Capture latency increases by no more than ~150ms on a mid-range device (Pixel 6 / iPhone 12). | Measure time between shutter tap and `ScanPreviewScreen` first frame with a stopwatch overlay or `Stopwatch` log. Compare before/after. |
| 4 | EXIF orientation is respected; the cropped image always appears upright in `ScanPreviewScreen` and in the AI pipeline. | Capture in portrait, landscape-left, and landscape-right (if the screen rotates); confirm each preview is right-side-up. |
| 5 | The gallery-import path is unchanged. | Pick an existing photo from the gallery; the image arrives at `ScanPreviewScreen` with its original dimensions and aspect ratio. |
| 6 | Barcode mode still works exactly as before. | Scan an EAN-13 barcode end-to-end, confirm the lookup completes. |
| 7 | No regressions in `foodLabel` mode. | Capture a nutrition label; confirm the visible rectangle in preview matches the file passed downstream. |

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture

```
              ┌──────────────────────────────┐
              │  ScanCameraScreen            │
              │  (existing CameraPreview     │
              │   uses BoxFit.cover)         │
              └─────────────┬────────────────┘
                            │ shutter tap
                            ▼
              ┌──────────────────────────────┐
              │ _capturePhoto()              │
              │  - controller.takePicture()  │
              │  - compute viewport AR       │  ◀── NEW
              │  - call PhotoCropper         │  ◀── NEW
              └─────────────┬────────────────┘
                            │ cropped path
                            ▼
              ┌──────────────────────────────┐
              │ PhotoCropper.cropToAspect    │  ◀── NEW SERVICE/UTIL
              │  - decode JPEG (Isolate)     │
              │  - respect EXIF orientation  │
              │  - compute centered crop     │
              │    rect for target AR        │
              │  - re-encode JPEG (q=92)     │
              └─────────────┬────────────────┘
                            │
                            ▼
              ┌──────────────────────────────┐
              │  ScanPreviewScreen           │
              │  (unchanged)                 │
              └──────────────────────────────┘
```

The live preview already does the cropping math visually:

```dart
// lib/screens/scan/scan_camera_screen.dart:575-587
Widget _buildLiveCameraPreview(CameraController controller) {
  final previewSize = controller.value.previewSize ?? const Size(1, 1);
  return SizedBox.expand(
    child: FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,  // swapped because sensor is landscape, screen portrait
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    ),
  );
}
```

`BoxFit.cover` scales the sensor frame to fill the viewport and crops the overflow. The captured file, by contrast, contains the **entire** sensor frame. We replicate the exact same crop on the file.

**Crop math** (portrait phone, landscape sensor):

- Sensor: `Wsensor × Hsensor` (rotated to portrait: `Hsensor × Wsensor`).
- Viewport: `Wvp × Hvp` (the visible camera surface on screen — full screen below status bar, minus bottom bar).
- Sensor AR (portrait-rotated): `Asensor = Hsensor / Wsensor`.
- Viewport AR: `Avp = Hvp / Wvp`.

If `Avp > Asensor` (viewport taller than sensor): the preview is scaled to fit width, sensor overflow is cropped top/bottom equally. Conversely if `Avp < Asensor`: crop left/right equally.

Final crop rectangle is centered.

### 3.2 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Fix approach | **(B) Post-capture crop** | Keeps the immersive full-bleed preview the user already likes; matches what they see; no black letterbox bars. Option (A) letterbox would shrink the framing area and look unpolished; option (C) fixed square would waste sensor area and change the visual identity of the scan screen. |
| Crop library | `package:image` (Dart) | Already widely used in Flutter, MIT licensed, no native code, runs in `Isolate.run`. Avoids `image_cropper` which forces a UI step. |
| Where to compute viewport AR | Capture the camera-surface `Size` via a `LayoutBuilder`/`GlobalKey` at the moment the surface is laid out | The viewport differs from `MediaQuery.size` because the bottom bar reserves `AppSizes.scanBottomBarHeight`. Use the same `RenderBox` that hosts `_buildCameraSurface`. |
| Where to run heavy work | `Isolate.run` | Decoding/cropping/encoding a ~3000×4000 JPEG can block the UI for hundreds of ms on Android. Isolate keeps the shutter feeling instant. |
| Orientation handling | Apply EXIF orientation via `bakeOrientation` before cropping | The `camera` plugin writes EXIF orientation rather than rotating pixels; cropping the un-baked file would crop the wrong rectangle. |
| Output format/quality | JPEG quality 92 | Matches the typical `camera` plugin output quality; downstream AI pipeline already consumes JPEG. |
| Output filename | Reuse capture filename, append `_cropped.jpg` in the same temp dir | Easy to debug; original file is kept until the next session and overwritten by the next capture's `_cropped`. |
| Failure fallback | If cropping throws, log and pass the original `file.path` through | Never block the user from completing a meal entry over a cropping failure. |

---

## 4. IMPLEMENTATION STEPS

> Execute steps in order. Do not skip.

### Step 1: Add `image` Dependency

**Goal**: Provide a pure-Dart image codec for the crop step.
**Files**: `pubspec.yaml`

Add to `dependencies:` (alphabetical position):

```yaml
  image: 4.5.4
```

Run:

```bash
flutter pub get
```

**Done when**: `flutter pub get` succeeds and `import 'package:image/image.dart' as img;` resolves.

---

### Step 2: Create the `PhotoCropper` Utility

**Goal**: Centralize the decode/orient/crop/encode pipeline so the camera screen stays UI-focused.
**Files**: `lib/utils/photo_cropper.dart` (new)

```dart
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class PhotoCropper {
  /// Crops [sourcePath] to [targetAspectRatio] (= height / width, in the
  /// visually-upright orientation) using a centered cover-crop, mirroring
  /// `BoxFit.cover` from the live preview. Returns the path to the cropped
  /// JPEG, or [sourcePath] if cropping is not needed or fails.
  static Future<String> cropCenterCoverToAspect({
    required String sourcePath,
    required double targetAspectRatio,
    int jpegQuality = 92,
  }) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      final outBytes = await Isolate.run(() => _cropSync(bytes, targetAspectRatio, jpegQuality));
      if (outBytes == null) return sourcePath;
      final outPath = p.join(p.dirname(sourcePath), '${p.basenameWithoutExtension(sourcePath)}_cropped.jpg');
      await File(outPath).writeAsBytes(outBytes, flush: true);
      return outPath;
    } catch (_) {
      return sourcePath;
    }
  }

  static Uint8List? _cropSync(Uint8List bytes, double targetAspectRatio, int jpegQuality) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    // Bake EXIF orientation so width/height match what the user sees.
    final upright = img.bakeOrientation(decoded);

    final srcW = upright.width;
    final srcH = upright.height;
    final srcAspect = srcH / srcW;

    int cropW;
    int cropH;
    if ((srcAspect - targetAspectRatio).abs() < 0.001) {
      return img.encodeJpg(upright, quality: jpegQuality);
    } else if (targetAspectRatio > srcAspect) {
      // Viewport is taller — crop left/right.
      cropH = srcH;
      cropW = (srcH / targetAspectRatio).round();
    } else {
      // Viewport is wider — crop top/bottom.
      cropW = srcW;
      cropH = (srcW * targetAspectRatio).round();
    }

    final x = ((srcW - cropW) / 2).round();
    final y = ((srcH - cropH) / 2).round();

    final cropped = img.copyCrop(upright, x: x, y: y, width: cropW, height: cropH);
    return Uint8List.fromList(img.encodeJpg(cropped, quality: jpegQuality));
  }
}
```

**Done when**: File analyzes cleanly under `flutter analyze`.

---

### Step 3: Capture the Camera-Surface Size in `ScanCameraScreen`

**Goal**: Know the exact pixel rectangle of the live preview at the moment of capture so the crop matches.
**Files**: `lib/screens/scan/scan_camera_screen.dart`

Add a `GlobalKey` for the camera-surface `RenderBox`. The screen already has `_previewBoundaryKey` for freeze-frames; reuse it (it wraps the `RepaintBoundary` that contains `_buildLiveCameraPreview`, which is exactly the viewport rectangle we need).

In `_capturePhoto()` (currently lines 270-281), read the viewport size **before** awaiting `takePicture()` (the call is fast enough that the size won't change, but reading first avoids races with rotation):

```dart
Future<void> _capturePhoto() async {
  if (_mode == ScanMode.barcode) return;
  final controller = _cameraController;
  if (controller == null || !controller.value.isInitialized) return;

  final boundary = _previewBoundaryKey.currentContext?.findRenderObject() as RenderBox?;
  final viewportSize = boundary?.size;

  try {
    final file = await controller.takePicture();
    if (!mounted) return;

    String finalPath = file.path;
    if (viewportSize != null && viewportSize.width > 0 && viewportSize.height > 0) {
      final targetAspect = viewportSize.height / viewportSize.width;
      finalPath = await PhotoCropper.cropCenterCoverToAspect(
        sourcePath: file.path,
        targetAspectRatio: targetAspect,
      );
    }
    if (!mounted) return;
    Get.to(() => ScanPreviewScreen(imagePath: finalPath));
  } catch (_) {}
}
```

Add the import:

```dart
import 'package:diplomka/utils/photo_cropper.dart';
```

> Note: `_previewBoundaryKey` is currently attached to a `RepaintBoundary` whose child is the camera preview (line 515-518). Its `RenderBox.size` is the viewport. The key works only when the live preview is mounted, which is always true when `_capturePhoto` runs.

**Done when**: A test capture on a real device produces a `*_cropped.jpg` whose dimensions match the screen's viewport aspect ratio (verify by reading EXIF or measuring the file).

---

### Step 4: Make Aspect Ratio Robust for the foodLabel Frame (Optional Tightening)

**Goal**: Decide whether `foodLabel` mode should crop to the on-screen frame rectangle (288×458) rather than the full viewport.
**Files**: `lib/screens/scan/scan_camera_screen.dart`

Default plan: keep cropping to the full viewport for both `scanMeal` and `foodLabel`. The `ScanFrameCorners` overlay is a guidance hint, not a literal crop boundary — cropping to it would discard sensor area the user might have intentionally included.

If user testing later shows that label captures should crop tighter to the frame, change the call site to:

```dart
final targetAspect = ScanFrameDimensions.aspectFor(_mode);
```

Document as an open question for the testing round; do not implement now.

**Done when**: Plan-author confirms the viewport-AR default is the intended behavior for this release.

---

### Step 5: Verify `ScanPreviewImage` Display

**Goal**: Confirm the in-preview-screen thumbnail still renders correctly with the new (now-cropped) image.
**Files**: `lib/screens/scan/scan_widgets.dart` (line 401-419) — no changes expected.

`ScanPreviewImage` uses a fixed `width × height` box with `DecorationImage(fit: BoxFit.cover)`. The cropped JPEG passed in will be roughly viewport-AR (~ tall portrait), and the preview box has its own AR; `BoxFit.cover` handles the difference visually. No code change required.

**Done when**: A captured cropped image appears in `ScanPreviewScreen` without distortion or letterboxing.

---

### Step 6: Run, Test, Verify

**Goal**: Manual verification on real hardware.
**Files**: n/a

Run:

```bash
flutter analyze
flutter run -d <ios-or-android-device>
```

Execute the verification checklist from §2.

**Done when**: All seven success criteria in §2 are checked off on at least one iOS and one Android device.

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| `image` package fails to decode the JPEG. | Original (uncropped) path is forwarded; user can still complete the entry. | `PhotoCropper` returns `sourcePath` on any exception. |
| Captured image is already exactly the viewport aspect ratio (rare, but possible on some sensor configs). | Skip the crop, return the original encoded as-is. | Early return when `(srcAspect - targetAspectRatio).abs() < 0.001`. |
| Device is in landscape mid-capture (screen rotated). | The viewport AR read just before `takePicture()` reflects landscape; cropped image is landscape-shaped and matches preview. | `viewportSize` is read on-thread before the await; EXIF orientation is baked before cropping. |
| Sensor reports zero `previewSize`. | Live preview already falls back to `Size(1, 1)` (existing behavior, line 576). The crop still runs against the captured file's own dimensions, which are independent. | No change needed. |
| `RepaintBoundary` not yet mounted (e.g., shutter pressed during init). | Capture short-circuits via the `_isInitialized` guard, so `_capturePhoto` returns before reaching `takePicture`. | Existing guard is sufficient; the new code adds a null-check on `viewportSize`. |
| Image extremely large (e.g., 4032×3024) on a low-RAM device. | Isolate decodes in a background thread; main thread stays responsive. Total time stays under ~500ms even on older devices. | Use `Isolate.run`. If memory pressure becomes an issue, downsample with `img.copyResize` after cropping (defer until reported). |
| Cropping isolate throws `OutOfMemory`. | Fallback to original path. | `try/catch` in `cropCenterCoverToAspect`. |
| User picks from gallery instead of capturing. | No crop is applied. | `_pickFromGallery` is unchanged; only `_capturePhoto` invokes `PhotoCropper`. |
| EXIF orientation tag is missing. | `bakeOrientation` is a no-op; pixels are already upright. | No special handling needed. |

---

## 6. SECURITY CONSIDERATIONS

- **Input validation**: The cropper only ever reads files written by `CameraController.takePicture()` into the app's temp directory; no user-supplied paths cross the boundary. Still, the cropper catches all exceptions and falls back gracefully, so a malformed JPEG cannot crash the app.
- **Auth/Access control**: N/A — local-only operation.
- **Sensitive data**: Photos are written to the same temp directory the `camera` plugin already uses. The original (uncropped) file is left in place; clean it up if the AI pipeline does not already do so (verify in `AiPipelineService.analyzeMealFromImage`). Recommended: after a successful crop, delete the original to avoid leaking unintended scene content (e.g., faces in the periphery that the user did not see in preview).
- **Logging**: Do not log file contents or full paths to crash analytics. Logging the result of "cropped vs original size" is fine.

---

## 7. ASSUMPTIONS & QUESTIONS

### Assumptions Made

Inferred from incomplete input — verify these are correct:

1. **The captured file is a JPEG.** `camera` 0.11.x writes JPEG by default on both Android and iOS. If the plugin is later configured to use HEIC, the `image` package needs a different decoder; current code assumes JPEG and falls back gracefully if decode fails.
2. **The user's "preview frame" complaint is about the full viewport rectangle, not the corner-overlay frame (`ScanFrameCorners`).** The corner frame is widely understood across food-tracking apps as a hint, not a crop boundary, and shrinking the photo to that 340×400 rectangle would discard food area outside the corners. We crop to the viewport. Confirm with the participant if practical.
3. **The participant's device renders the preview portrait-up.** All sensor-to-viewport math assumes the sensor's native long axis maps to the screen's short axis (portrait phone, landscape sensor). The cropper bakes EXIF orientation, which neutralizes this assumption for the file itself.
4. **Capture latency budget of ~150ms is acceptable.** Diploma-thesis testing already exposes participants to ~1-2s AI analysis times; an extra 100-150ms before the preview screen appears is imperceptible relative to that.
5. **Adding `image: 4.5.4` does not bloat the IPA/APK meaningfully.** The package is pure Dart and adds < 1 MB to the release bundle.

### Open Questions

- [ ] Should `foodLabel` mode crop to the `ScanFrameCorners` rectangle instead of the full viewport? (Defer to next round of testing.)
- [ ] Should we delete the original (uncropped) capture file after a successful crop? (Recommended yes; verify it isn't referenced elsewhere first.)
- [ ] Do we want to thumbnail-downsample the cropped result before sending to the AI pipeline to save tokens? (Out of scope here; track separately.)

---

## 8. QUICK REFERENCE

### Files to Modify

- `lib/screens/scan/scan_camera_screen.dart` — Capture viewport size at shutter time, route the captured file through `PhotoCropper`, forward the cropped path to `ScanPreviewScreen`.
- `pubspec.yaml` — Add `image: 4.5.4`.

### Files to Create

- `lib/utils/photo_cropper.dart` — Pure-Dart isolate-based center-cover cropper.

### Files Reviewed but NOT Changed

- `lib/screens/scan/scan_preview_screen.dart` — Receives the new cropped path transparently; no edits.
- `lib/screens/scan/scan_widgets.dart` — `ScanPreviewImage` continues to render with `BoxFit.cover`; no edits.
- `lib/services/ai_feature/ai_pipeline_service.dart` — Consumes the path as-is.
- `lib/screens/logs/weight_log_sheet.dart` — Uses `image_picker` only; unaffected.

### Dependencies

- `image: 4.5.4` — Pure-Dart JPEG decode/encode, EXIF orientation, crop primitives.

### Commands

```bash
# Setup
flutter pub get

# Static analysis
flutter analyze

# Run on device
flutter run

# Release build sanity check
flutter build apk --release
```

---

## 9. DESIGN REFERENCE

> Included because this change has user-visible effects on the camera UX.

### Visual Spec

No design file. The target visual state is: the rectangle visible in the live camera preview is byte-for-byte the same rectangle that appears on `ScanPreviewScreen`.

### Component/Screen Mapping

- Live preview viewport rectangle (host: `RepaintBoundary` keyed by `_previewBoundaryKey`, `lib/screens/scan/scan_camera_screen.dart:515-518`) → cropped output rectangle written by `PhotoCropper`.
- `ScanFrameCorners` overlay (`lib/screens/scan/scan_widgets.dart`) → unchanged; remains a soft framing hint.

### Style Mapping

| Design Spec | Code Equivalent | Value |
|-------------|-----------------|-------|
| Preview fit | `FittedBox(fit: BoxFit.cover)` in `_buildLiveCameraPreview` | Unchanged |
| Frame overlay color | `AppColors.primary` | Unchanged |
| Bottom bar reserved height | `AppSizes.scanBottomBarHeight` | Unchanged (affects viewport AR implicitly) |

---

## 10. CORRECTIONS FROM CURRENT STATE

| What | Before (Wrong/Current) | After (Correct/Target) |
|------|------------------------|------------------------|
| File handed to `ScanPreviewScreen` after a capture. | Full sensor-resolution JPEG (e.g., 3000×4000). Aspect ratio differs from on-screen preview rectangle. | Centered, cover-cropped JPEG matching the viewport aspect ratio. |
| Where the cropping happens. | Visually-only, in the live preview, via `BoxFit.cover`. The pixel file is never cropped. | Visually in the preview *and* on the saved JPEG, using identical math. |
| What the AI pipeline receives. | Full sensor frame including content the user never saw. | Only the content the user composed in the viewport. |
| Behavior on cropping failure. | N/A (no cropping today). | Fall back to original file path so the user is never blocked. |
| EXIF orientation handling. | Implicit; `Image.file` rotates on display. | Baked into pixels before cropping so the saved file is unambiguously upright. |

---

## 11. CHANGELOG

| Date | Change |
|------|--------|
| 2026-05-11 | Initial plan created |
