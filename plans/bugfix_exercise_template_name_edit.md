# Bugfix: Exercise Template Name Edit Not Saving

> **Summary**: Fix a bug where renaming an exercise template in the Exercise Log detail screen silently fails because the template lookup uses the new (changed) name instead of the original name.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement
When a user opens an exercise from the Exercise Log screen (template editing mode), changes the exercise name, and taps the Done (checkmark) button, the name change is not persisted. The user returns to the list and sees the old name, with no error message shown.

### 1.2 Solution Overview
The bug is a single-line lookup error in `ExerciseDetailScreen._handleDone()`. The code normalizes the **updated** name to find the template, but the template in the database still has the **original** normalized name. The fix is to look up the template by the original name (`widget.exercise.name`), then update it with the new values.

### 1.3 Scope: What This IS
- Fix the template lookup in the "opened from log screen" save path
- Ensure name, calories, and duration changes all persist correctly

### 1.4 Scope: What This IS NOT
- Not adding error handling / user-facing error messages for constraint violations
- Not changing the DAO, repository, or entity layer
- Not modifying the dashboard (non-log-screen) exercise save path

---

## 2. SUCCESS CRITERIA

Implementation is COMPLETE when ALL criteria are met:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | Renaming an exercise template and tapping Done persists the new name | Open Exercise Log → tap exercise → change name → tap ✓ → reopen → name matches |
| 2 | Changing calories/duration still saves correctly | Same flow, verify values persist |
| 3 | Static analysis passes | `flutter analyze` returns no new issues |

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture

```
ExerciseDetailScreen._handleDone()
  │
  ├── _buildExercise()  →  Exercise with NEW name from _nameController
  │
  ├── BUG: normalize(updated.name)  →  looks for template with NEW name  →  null  →  skip
  │
  └── FIX: normalize(widget.exercise.name)  →  finds template with ORIGINAL name  →  updates it
```

### 3.2 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Lookup key for template | `widget.exercise.name` (original) | The template in the DB has the original normalized name; `_exercise.name` could be modified by Fix Issue flow |
| Error handling | Not added | Out of scope; the fix ensures the happy path works; constraint violations are a separate concern |

---

## 4. IMPLEMENTATION STEPS

> Execute steps in order. Do not skip.

### Step 1: Fix template lookup in _handleDone

**Goal**: Use the original exercise name for template lookup instead of the updated name.
**Files**: `lib/screens/logs/exercise_detail_screen.dart`

Change line 73 from:
```dart
final normalized = ExerciseTemplate.normalize(updated.name);
```
to:
```dart
final normalized = ExerciseTemplate.normalize(widget.exercise.name);
```

**Done when**: The template is found by its original name and `updateTemplateValues` is called with the new name/values.

---

### Step 2: Verify with static analysis

**Goal**: Ensure no regressions.
**Files**: N/A

```bash
flutter analyze
```

**Done when**: No new analysis warnings or errors.

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| User changes name to one that already exists as another template | UNIQUE constraint on normalizedName causes silent failure | Out of scope — existing behavior, separate issue |
| User opens exercise from dashboard (not log screen) | Uses different save path (DayRecordController) — unaffected | No change needed |
| User uses Fix Issue then taps Done | Template still looked up by `widget.exercise.name` (original); works because Fix doesn't save template | Correct by design |

---

## 6. SECURITY CONSIDERATIONS

No security implications — this is a local SQLite update with no user-facing input validation changes.

---

## 7. ASSUMPTIONS & QUESTIONS

### Assumptions Made

1. **The template's normalizedName in DB always matches `widget.exercise.name`**: The screen is opened with an exercise whose name was derived from the template. If the user uses Fix Issue, the template is NOT updated until Done is tapped.

### Open Questions
- None — root cause is clear and fix is straightforward.

---

## 8. QUICK REFERENCE

### Files to Modify
- `lib/screens/logs/exercise_detail_screen.dart` — Fix template lookup key in `_handleDone()` (line 73)

### Files to Create
- None

### Dependencies
- None

### Commands
```bash
# Verify
flutter analyze
```

---

## 10. CORRECTIONS FROM CURRENT STATE

| What | Before (Wrong/Current) | After (Correct/Target) |
|------|------------------------|------------------------|
| Template lookup in `_handleDone()` | `ExerciseTemplate.normalize(updated.name)` — uses NEW name, template not found | `ExerciseTemplate.normalize(widget.exercise.name)` — uses ORIGINAL name, template found and updated |

---

## 11. CHANGELOG

| Date | Change |
|------|--------|
| 2026-05-11 | Initial plan created |
