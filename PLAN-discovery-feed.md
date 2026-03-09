# Discovery Feed — Implementation Plan

## Overview

A personalized, vertically-scrollable card feed embedded in the dashboard (or accessible via a dedicated tab/section). The feed delivers short, engaging content — nutrition tips, motivational nudges, recipe ideas, and AI-generated insights — tailored to the user's profile, goals, and tracking history. The goal is to increase in-app time and engagement through a familiar "Reels-like" swipeable experience, without relying on any third-party social media content.

---

## Content Types

| Type | Source | Example |
|------|--------|---------|
| **Daily Insight** | AI-generated from user's tracked data | "You've been 200 kcal under your goal 3 days in a row — great consistency!" |
| **Nutrition Tip** | AI-generated based on diet type & goals | "As a vegetarian, try combining lentils with rice for complete protein." |
| **Recipe Suggestion** | AI-generated based on remaining macros | "You still need 30g protein today — try this quick Greek yogurt bowl." |
| **Streak & Motivation** | Computed from `StreakService` + AI | "5-day tracking streak! Keep it up." |
| **Weekly Summary** | Aggregated from `DayRecordRepository` | "This week: avg 1,850 kcal/day, protein target hit 5/7 days." |
| **Did You Know?** | Static + AI-curated nutrition facts | "100g of broccoli has more vitamin C than an orange." |
| **Goal Check-in** | Derived from goals vs actuals | "You're on track to reach 75 kg by mid-April at your current rate." |

---

## Architecture

### New Files

```
lib/
├── model/
│   └── discovery_card.dart              # DiscoveryCard data model
│
├── services/
│   └── discovery_feed_service.dart      # Content generation & caching logic
│
├── controller/
│   └── discovery_feed_controller.dart   # GetxController for feed state
│
├── screens/
│   └── dashboard/
│       └── discovery_feed_section.dart   # Feed widget (used on dashboard)
│
├── widgets/
│   └── discovery_card_widget.dart        # Individual card renderer
```

### Data Model

```dart
// lib/model/discovery_card.dart

enum DiscoveryCardType {
  dailyInsight,
  nutritionTip,
  recipeSuggestion,
  streakMotivation,
  weeklySummary,
  didYouKnow,
  goalCheckIn,
}

class DiscoveryCard {
  final String id;
  final DiscoveryCardType type;
  final String title;
  final String body;
  final String? emoji;        // Optional visual accent (e.g. "🔥" for streak)
  final String? ctaLabel;     // Optional call-to-action button text
  final String? ctaRoute;     // Optional navigation target
  final DateTime generatedAt;
  final DateTime? expiresAt;  // Null = no expiry
  final bool dismissed;
}
```

### Service Layer

```dart
// lib/services/discovery_feed_service.dart

class DiscoveryFeedService extends GetxService {
  static DiscoveryFeedService get to => Get.find();

  // Dependencies (injected via locator.dart)
  // - SessionManager (user profile, diet type, goals)
  // - DayRecordRepository (historical tracking data)
  // - AiServiceManager (OpenAI for content generation)
  // - StreakService (streak data)
  // - NutritionGoalsService (goal targets)

  /// Generate today's feed cards. Called once per day (or on pull-to-refresh).
  /// Returns a prioritized, deduplicated list of cards.
  Future<List<DiscoveryCard>> generateFeed() async { ... }

  /// Generate a single card type via AI.
  Future<DiscoveryCard?> _generateAiCard(DiscoveryCardType type, Map<String, dynamic> context) async { ... }

  /// Build cards from local data (streaks, weekly stats) without AI call.
  List<DiscoveryCard> _buildLocalCards() { ... }

  /// Persist dismissed card IDs to SharedPreferences.
  Future<void> dismissCard(String cardId) async { ... }

  /// Cache generated cards for the day to avoid redundant AI calls.
  /// Storage: SharedPreferences (JSON-serialized list).
  Future<void> _cacheCards(List<DiscoveryCard> cards) async { ... }
  Future<List<DiscoveryCard>?> _loadCachedCards() async { ... }
}
```

### Controller

```dart
// lib/controller/discovery_feed_controller.dart

class DiscoveryFeedController extends GetxController {
  static DiscoveryFeedController get to => Get.find();

  final cards = <DiscoveryCard>[].obs;
  final isLoading = false.obs;
  final currentIndex = 0.obs;  // For PageView tracking

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed() async { ... }
  void dismissCard(String cardId) { ... }
  void onPageChanged(int index) => currentIndex.value = index;
}
```

---

## UI Design

### Placement Options (choose one)

**Option A — Dashboard inline section (recommended)**
Insert the feed as a horizontal `PageView` card carousel between the macros row and the recently uploaded section. Height: ~180px. Auto-advances every 8 seconds with a subtle page indicator.

**Option B — Dedicated "Discover" tab**
Replace the 3-tab layout with a 4-tab layout (Dashboard / Discover / Progress / Profile). Full-screen vertical feed with swipeable cards.

**Option C — Dashboard expandable section**
A collapsed "Discover" card on the dashboard that expands into a bottom sheet with the full feed on tap.

> **Recommendation: Option A.** Minimal UI disruption, maximum visibility, and consistent with existing dashboard card patterns.

### Card Visual Design

```
┌─────────────────────────────────────────┐
│  ✨  Daily Insight                      │  ← type icon + label (caption12, textTertiary)
│                                         │
│  You hit your protein goal              │  ← title (h3, textPrimary)
│  4 out of 5 days this week!             │
│                                         │
│  Consistent protein intake helps        │  ← body (body14, textSecondary)
│  preserve muscle during weight loss.    │
│                                         │
│  ● ● ○ ○ ○                    [More →]  │  ← page dots + optional CTA
└─────────────────────────────────────────┘
```

**Styling:**
- Background: `AppColors.surface` with `AppShadows.cardSoft`
- Border radius: `AppRadii.lg` (24px)
- Padding: `AppSpacing.l` (24px)
- Height: fixed 180px (fits 4-5 lines of content comfortably)
- Page indicator: small dots using `AppColors.textTertiary` / `AppColors.primary`
- Card type accent: thin left border or small icon in corner, color-coded per type
- Swipe animation: `PageView` with `viewportFraction: 0.92` for peek effect

### Type-Specific Accent Colors

| Type | Color | Icon |
|------|-------|------|
| Daily Insight | `AppColors.primary` | sparkle / lightbulb |
| Nutrition Tip | `AppColors.macroProtein` | leaf |
| Recipe Suggestion | orange | utensils |
| Streak Motivation | `AppColors.success` | fire |
| Weekly Summary | `AppColors.info` | chart |
| Did You Know? | `AppColors.macroCarbs` | question mark |
| Goal Check-in | `AppColors.macroFats` | target |

---

## AI Prompt Strategy

### System Prompt for Content Generation

```
You are a friendly nutrition coach inside a calorie-tracking app called Foody.
Generate short, engaging tips and insights for the user.

Rules:
- Keep each response under 120 words
- Be encouraging, never judgmental
- Use concrete numbers from the user's data when provided
- Match the user's language (Czech or English based on locale)
- Do not give medical advice
- Output valid JSON: { "title": "...", "body": "...", "emoji": "..." }
```

### User Context Payload

```json
{
  "locale": "cs",
  "diet_type": "vegetarian",
  "custom_preferences": "no soy",
  "goal": "weight_loss",
  "weight_kg": 82,
  "goal_weight_kg": 75,
  "calorie_goal": 2000,
  "avg_calories_7d": 1850,
  "avg_protein_7d": 65,
  "protein_goal": 100,
  "streak_days": 5,
  "days_over_goal_7d": 1,
  "card_type": "nutrition_tip"
}
```

### Cost Management

- **Batch generation**: Generate all AI cards in a single API call (multi-card prompt) to reduce request overhead.
- **Daily cache**: Generate once per day, cache in SharedPreferences. Refresh only on pull-to-refresh or next day.
- **Fallback**: If AI call fails or user is offline, show only locally-computed cards (streak, weekly summary, goal check-in).
- **Token budget**: ~500 input + ~300 output tokens per batch ≈ $0.002/day with GPT-4o-mini.

---

## Implementation Steps

### Step 1: Data Model & Service Skeleton
1. Create `lib/model/discovery_card.dart` with `DiscoveryCard` and `DiscoveryCardType`.
2. Create `lib/services/discovery_feed_service.dart` with stub methods.
3. Register `DiscoveryFeedService` in `lib/locator.dart`.

### Step 2: Local Card Generators
1. Implement `_buildLocalCards()` in the service:
   - **Streak card**: Query `StreakService` for current streak length.
   - **Weekly summary card**: Query last 7 `DayRecord`s from repository, compute averages.
   - **Goal check-in card**: Compare current weight trend vs goal weight.
2. Add card deduplication and priority sorting logic.

### Step 3: AI Card Generation
1. Create the prompt template in `lib/utils/discovery_prompt.dart`.
2. Implement `_generateAiCard()` using `AiServiceManager` (reuse existing OpenAI client).
3. Implement batch generation: single prompt → multiple cards.
4. Add JSON parsing with error handling (malformed AI responses).

### Step 4: Caching & Dismissal
1. Implement SharedPreferences-based caching for generated cards (keyed by date).
2. Implement card dismissal persistence (set of dismissed card IDs).
3. Add cache expiry logic (clear previous day's cache on new day).

### Step 5: Controller
1. Create `DiscoveryFeedController` with reactive card list.
2. Wire up `loadFeed()` → service → cache-or-generate → update `cards.obs`.
3. Handle loading/error states.
4. Register controller in `locator.dart`.

### Step 6: Card Widget
1. Create `lib/widgets/discovery_card_widget.dart`.
2. Implement card rendering following the visual design spec above.
3. Add type-specific accent colors and icons.
4. Add dismiss gesture (swipe up or X button).
5. Add optional CTA button with navigation.

### Step 7: Dashboard Integration
1. Create `lib/screens/dashboard/discovery_feed_section.dart`.
2. Implement horizontal `PageView` carousel with:
   - `viewportFraction: 0.92` for peek effect
   - Page indicator dots
   - Auto-advance timer (8s)
   - Smooth page transitions
3. Insert the section into `dashboard_screen.dart` between macros and recently uploaded.
4. Show shimmer/skeleton loader while cards are loading.
5. Hide section entirely if no cards are available.

### Step 8: Localization
1. Add translation keys for static UI strings (section title, CTA labels, empty state).
2. Pass user locale to AI prompt so generated content matches app language.
3. Add keys to `en.json`, `cs.json`, and `tr.json`.
4. Regenerate locale keys.

### Step 9: Polish & Edge Cases
1. Handle offline state gracefully (show only local cards, no error).
2. Handle empty feed state (all cards dismissed → show "Check back tomorrow!" message).
3. Add subtle entrance animation for the feed section (fade + slide up).
4. Respect reduced motion accessibility settings.
5. Test with various user profiles (new user with no data, power user, different diet types).

---

## Dependencies

No new packages required. The feature uses:
- `GetX` — state management (already installed)
- `shared_preferences` — card caching (already installed)
- `easy_localization` — translations (already installed)
- Existing OpenAI REST client via `AiServiceManager`

---

## Testing Strategy

| Layer | What to Test |
|-------|-------------|
| **Model** | `DiscoveryCard` serialization/deserialization, equality |
| **Service** | Local card generation with mock data, cache read/write, dismissal logic |
| **AI** | Prompt construction, JSON response parsing, fallback on malformed response |
| **Controller** | Loading states, card list updates, dismissal flow |
| **Widget** | Card rendering for each type, page indicator, auto-advance, dismiss gesture |
| **Integration** | Feed appears on dashboard, respects user locale, handles offline |

---

## Future Extensions

- **Video cards**: Short auto-playing recipe videos (self-hosted or YouTube Shorts via API).
- **Interactive cards**: Quick polls ("Did you drink enough water today?"), rating prompts.
- **Social cards**: Anonymized community stats ("Users with similar goals average X kcal").
- **Seasonal content**: Holiday-themed tips, seasonal ingredient suggestions.
- **Smart scheduling**: Show recipe suggestions before typical meal times based on user patterns.
- **Card engagement tracking**: Track which card types get the most interaction to optimize feed.
