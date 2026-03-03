# FR: FAQ Screen — Implementation Plan

## Overview

Add a **FAQ (Frequently Asked Questions)** screen to the Profile section. The screen features an accordion-style list of expandable questions with answers. Some items expand inline (chevron down ↓), others navigate or simply expand (chevron right →).

**Reference**: CalZen-style FAQ screen (see input image). Adapt content to Foody app context.

---

## UI Spec (from reference image)

- **AppBar**: Back arrow (←) + centered title "FAQ"
- **Content**: Scrollable list of FAQ items on a light background
- **Expanded item**: Question text (bold, ~16sp) + chevron down icon; answer text below in a rounded card with left accent border (subtle gray), body text (~14sp, secondary color)
- **Collapsed item**: Question text (bold) + chevron right icon; no answer visible
- **No sections/grouping** — flat list of questions
- **Spacing**: ~16px vertical gap between items, ~16px horizontal padding

---

## FAQ Content (adapted for Foody)

Adapt from CalZen reference. Remove subscription-related questions (Foody has no subscriptions). Add Foody-specific ones.

| # | Question | Answer Summary |
|---|----------|---------------|
| 1 | How does Foody work? | Snap a photo or describe your meal. Foody uses AI to estimate calories, protein, fat, and carbs. Quick, effortless tracking in a couple of taps. |
| 2 | How accurate is the calorie calculation? | Foody uses AI to estimate calories and macros. Accuracy depends on photo quality — good lighting, a clear top-down shot, and no extra objects help. For best results, take photos in daylight, close-up, and include a familiar object for scale. |
| 3 | What if the calorie estimate seems off? | You can edit any meal after scanning. Tap the meal, adjust individual ingredients, quantities, or add missing items. Your corrections are saved immediately. |
| 4 | What is "per serving"? | "Per serving" means the nutritional values shown are for one portion as estimated by the AI. If your plate has multiple servings, you can adjust the quantity in the edit screen. |
| 5 | Can I track meals without a photo? | Yes. You can describe your meal using text or voice input. The AI will estimate nutritional values from your description. You can also add meals manually or scan a barcode. |
| 6 | How does barcode scanning work? | Point your camera at a product barcode. Foody looks up the product in the Open Food Facts database and fills in the nutritional information automatically. |
| 7 | How do I change my nutrition goals? | Go to Profile → Edit Nutrition Goals. You can set custom targets for calories, protein, fat, and carbs. Goals apply from the current day forward. |
| 8 | Is my data stored online? | No. All your data is stored locally on your device. Foody does not require an account or internet connection for viewing your history — only for AI analysis. |

> Note: Exact questions/answers can be refined later. The implementation should make it easy to add/remove/reorder items via translation keys.

---

## Architecture Decisions

- **No controller/service needed** — FAQ is static, read-only content
- **StatefulWidget** (not Stateless) — needs local `expandedIndex` state for accordion behavior
- **Translations** — all Q&A text lives in translation files, not hardcoded
- **Reusable widget** — create a generic `ExpandableFaqItem` widget for the accordion pattern

---

## Files to Create

| File | Purpose |
|------|---------|
| `lib/screens/profile/subscreens/faq_screen.dart` | FAQ screen with accordion list |

---

## Files to Modify

| File | Change |
|------|--------|
| `lib/screens/profile/profile_screen.dart` | Add FAQ navigation row in profile menu |
| `assets/translations/en.json` | Add FAQ translation keys (questions + answers) |
| `assets/translations/cs.json` | Add FAQ translation keys (Czech) |
| `lib/generated/locale_keys.g.dart` | Auto-regenerated after localization command |
| `lib/generated/codegen_loader.g.dart` | Auto-regenerated after localization command |

---

## Implementation Steps

### Phase 1: Translations

1. Add keys to `assets/translations/en.json`:
```json
"profile_faq": "FAQ",
"faq_q_how_does_foody_work": "How does Foody work?",
"faq_a_how_does_foody_work": "It's simple: just snap a photo of your meal or describe it in words. Foody analyzes the dish, estimates portion size and ingredients, and instantly shows you calories, protein, fat, and carbs. No manual calculations — just quick, effortless tracking in a couple of taps.",
"faq_q_how_accurate": "How accurate is the calorie calculation?",
"faq_a_how_accurate": "Foody uses AI to estimate calories and macros (protein, fat, carbs). Accuracy depends on photo quality: good lighting, a clear top-down shot, and no extra objects in the frame help a lot.\n\nFor best results, take photos in daylight, close-up, and include a familiar object for scale — like a fork or your hand. This helps the AI better estimate portion size.",
"faq_q_estimate_off": "What if the calorie estimate seems off?",
"faq_a_estimate_off": "You can edit any meal after scanning. Tap the meal, adjust individual ingredients, quantities, or add missing items. Your corrections are saved immediately.",
"faq_q_per_serving": "What is \"per serving\"?",
"faq_a_per_serving": "\"Per serving\" means the nutritional values shown are for one portion as estimated by the AI. If your plate has multiple servings, you can adjust the quantity in the edit screen.",
"faq_q_without_photo": "Can I track meals without a photo?",
"faq_a_without_photo": "Yes! You can describe your meal using text or voice input. The AI will estimate nutritional values from your description. You can also add meals manually or scan a barcode.",
"faq_q_barcode": "How does barcode scanning work?",
"faq_a_barcode": "Point your camera at a product barcode. Foody looks up the product in the Open Food Facts database and fills in the nutritional information automatically.",
"faq_q_nutrition_goals": "How do I change my nutrition goals?",
"faq_a_nutrition_goals": "Go to Profile → Edit Nutrition Goals. You can set custom targets for calories, protein, fat, and carbs. Goals apply from the current day forward.",
"faq_q_data_storage": "Is my data stored online?",
"faq_a_data_storage": "No. All your data is stored locally on your device. Foody does not require an account or internet connection for viewing your history — only for AI analysis of meals."
```

2. Add equivalent Czech translations to `cs.json`

3. Regenerate locale keys:
```bash
bash commands/generate_localization.command
```

### Phase 2: FAQ Screen

4. Create `lib/screens/profile/subscreens/faq_screen.dart`:
   - Use `ProfileGradientScaffold` with `scroll: true` as the container
   - Use `ProfileTopBar` with title from `LocaleKeys.profile_faq`
   - Build a `ListView` (or `Column`) of FAQ items
   - Each item is a custom expandable widget:
     - **Collapsed state**: Question text (bold, `AppTextStyles.body15` or `body16`, `FontWeight.w600`) + trailing chevron-down icon → tappable
     - **Expanded state**: Question text + chevron-down (rotated) + answer card below with left gray accent border, body text (`AppTextStyles.body14`, `AppColors.textSecondary`)
   - Track expanded index in local state (single-expand: only one open at a time, like the reference image)
   - Use `AnimatedCrossFade` or `AnimatedSize` for smooth expand/collapse animation

   **Widget structure per item:**
   ```
   GestureDetector
     Column
       Row [question text] [chevron icon with rotation animation]
       AnimatedSize
         Container (answer card with left border + rounded corners)
           Text (answer)
   ```

### Phase 3: Profile Screen Integration

5. Add FAQ row to `profile_screen.dart`:
   - Place in a new "Support" section or append to the "Progress Data" section (before "Account Actions")
   - Use the existing `_ProfileActionRow` pattern:
     ```dart
     _ProfileActionRow(
       title: tr(LocaleKeys.profile_faq),
       icon: Icons.help_outline_rounded,
       onTap: () => Get.to(() => const FaqScreen()),
     )
     ```

---

## Design Details

### Expanded answer card styling (from reference image):
- Background: `AppColors.surfaceCard` or slightly lighter than screen background
- Left border: 3-4px solid, subtle gray (`AppColors.outline` or `AppColors.surfaceSubtle`)
- Corner radius: `AppRadii.md` (~12px)
- Padding: 16px all sides
- Text: `AppTextStyles.body14` or `body14Relaxed`, color `AppColors.textSecondary`

### Chevron icon:
- Collapsed: `Icons.chevron_right` (or `Icons.expand_more` rotated -90deg)
- Expanded: `Icons.expand_more`
- Animate rotation between states with `AnimatedRotation`
- Size: `AppSizes.iconMd` (20px), color `AppColors.textSecondary`

### Question text:
- `AppTextStyles.body15` or `body16`, `FontWeight.w600`, `AppColors.textPrimary`

---

## Scope Summary

- **New files**: 1 (`faq_screen.dart`)
- **Modified files**: 3 (`profile_screen.dart`, `en.json`, `cs.json`) + 2 auto-generated
- **No new dependencies**
- **No new controllers/services**
- **Risk**: Very low — purely additive, static content, no state management complexity
- **Testing**: Verify accordion expand/collapse, verify all translations render, verify navigation from profile
