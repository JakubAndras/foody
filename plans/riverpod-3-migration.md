# Migrace Foody z flutter_riverpod 2.6.1 na Riverpod 3.0

> **Summary**: Povýšit `flutter_riverpod` z 2.6.1 na 3.0.3 při zachování ruční deklarace providerů a moderního `Notifier`/`AsyncNotifier` přístupu, s adresováním všech 2.x → 3.0 breaking changes relevantních pro tento kód.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement
Aplikace Foody běží na `flutter_riverpod 2.6.1` (Riverpod 2.x). Vyšla stabilní řada 3.0 (aktuálně 3.0.3), která přináší sjednocené API, automatický retry, offline persistenci a pauzování providerů mimo obrazovku. Cílem je přejít na nejnovější 3.x bez rozbití stávající funkcionality a beze změny zvoleného přístupu (ruční deklarace, žádný code generation).

### 1.2 Solution Overview
Migrace je díky čistotě kódu z velké části mechanická. Hlavní práce je bump verze v `pubspec.yaml`, globální přejmenování `valueOrNull` → `value` (20 výskytů) a vědomé rozhodnutí o dvou nových výchozích chováních (automatický retry, pauzování mimo obrazovku). Většina 3.0 breaking changes se projektu netýká, protože nepoužívá legacy API, `.family`, `.autoDispose`, `Ref` type parametry ani `ProviderObserver`.

### 1.3 Scope: What This IS
- Bump `flutter_riverpod: 2.6.1` → `^3.0.0` (cíl 3.0.3).
- Přejmenování `valueOrNull` → `value` napříč `lib/` (20 `.dart` výskytů + dokumentace v `CONTRACT.md`).
- Audit a případná úprava chytání chyb kvůli `ProviderException` wrapping a `sealed AsyncValue`.
- Vědomé rozhodnutí o automatickém retry (výchozí zapnuto) a o pauzování providerů mimo obrazovku.
- Ověření kompatibility ručního `ProviderContainer` + `UncontrolledProviderScope` (`lib/main.dart`) a `ProviderScope.containerOf` (`dashboard_calendar_sheet.dart`).
- Volitelné přidání `riverpod_lint` (custom_lint už je přítomen).
- Ověření zeleného `flutter analyze` a `flutter test` po migraci.

### 1.4 Scope: What This IS NOT
- **Není** přechod na code generation (`@riverpod`). Zůstává ruční deklarace, jak si přeje autor.
- **Není** zavádění offline persistence ani nových 3.0 feature (mutations, `Ref.mounted` vzory) nad rámec toho, co je nutné pro funkční parity.
- **Není** převod dvou funkcionálních providerů (`networkStatusProvider`, `streakInfoProvider`) na Notifier třídy — v 3.0 zůstávají plně podporované a nic je nenutí měnit.
- **Není** refaktor architektury, přejmenování providerů ani změna `CONTRACT.md` konvencí.
- **Není** zavedení `hooks_riverpod` / `flutter_hooks` (projekt je nepoužívá).

---

## 2. SUCCESS CRITERIA

Implementace je HOTOVÁ, když jsou splněna VŠECHNA kritéria:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | `pubspec.lock` uvádí `flutter_riverpod` verzi 3.0.x a `flutter pub get` proběhne bez konfliktů | `grep -A6 "flutter_riverpod:" pubspec.lock` → version 3.0.3 |
| 2 | V `lib/` není žádný výskyt `valueOrNull` | `grep -rn "valueOrNull" lib/ --include="*.dart"` → 0 |
| 3 | `flutter analyze` je bez chyb (warnings z jiných zdrojů tolerovány, ale žádná riverpod-related chyba) | `flutter analyze` |
| 4 | `flutter test` projde ve stejném rozsahu jako před migrací | `flutter test` |
| 5 | Aplikace se spustí, dashboard načte den, váha/šablony se zobrazí, notifikační tap přepne tab (čtení z `rootContainer` funguje) | `flutter run` + manuální smoke test klíčových toků |
| 6 | Automatický retry je vědomě nakonfigurovaný (buď ponechán, nebo vypnut) a rozhodnutí je zdokumentováno v kódu i `CONTRACT.md` | Code review `lib/main.dart` `ProviderContainer(retry: ...)` |
| 7 | Chování `networkStatusProvider` (StreamProvider) je ověřeno kvůli `==` filtrování a pauzování mimo obrazovku | Manuální test offline/online indikátoru |

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture

Migrace nemění architekturu, jen povrch knihovny. Stávající tok zůstává:

```
┌──────────────┐   overrides    ┌─────────────────────┐   watch/read/listen   ┌──────────────┐
│   main.dart  │──────────────▶│  rootContainer       │◀─────────────────────│  ConsumerWidget │
│  (bootstrap) │  db, prefs     │  (ProviderContainer) │                       │  (UI)          │
└──────────────┘                └─────────────────────┘                       └──────────────┘
       │                                  ▲                                            │
       │ UncontrolledProviderScope        │ rootContainer.read(...)                    │ ref.watch
       ▼                                  │ (mimo widget tree:                         ▼
┌──────────────┐                          │  notifikace, home widget)          ┌──────────────┐
│  runApp(App) │                          └────────────────────────────────────│ Notifier/    │
└──────────────┘                                                                │ AsyncNotifier│
                                                                                └──────────────┘
```

Body dotyku s 3.0 (barevně označené v krocích níže): `pubspec` → `valueOrNull` → error handling → retry/pause defaults → `ProviderContainer`/`containerOf` ověření.

### 3.2 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Cílová verze | `^3.0.0` (3.0.3) | Nejnovější stabilní; vyžaduje Dart 3.7+, projekt má SDK `^3.9.0` → OK |
| Code generation | **Ne**, zůstat u ruční deklarace | Explicitní přání autora; 21 ručních Notifierů funguje v 3.0 beze změny |
| `valueOrNull` → `value` | Globální replace v `lib/` | 3.0 přejmenoval `valueOrNull` na `value`; staré throwing `.value` → `requireValue` (viz audit) |
| Funkcionální providery (`networkStatusProvider`, `streakInfoProvider`) | **Ponechat** | V 3.0 nejsou legacy, nepoužívají `ref.state`/`listenSelf`/`.future`, není důvod je převádět |
| Automatický retry | **Vypnout globálně** (doporučeno), pak selektivně povolit | Projekt sleduje náklady na OpenAI (telemetrie `costUsd`); nechtěný 10× retry na chybující AI/network provider by mohl znásobit náklady a zakrýt chyby. Bezpečnější je opt-in. |
| Pauzování mimo obrazovku | **Ponechat výchozí (zapnuto)**, ověřit `networkStatusProvider` | Šetří práci; jediné riziko je stream, který musí běžet i mimo obrazovku |
| `riverpod_lint` | Volitelně přidat | `custom_lint` už je přítomen; lint plugin pomůže odhalit zbytkové 2.x vzory |

---

## 4. IMPLEMENTATION STEPS

> Prováděj kroky v pořadí. Nepřeskakuj. Před začátkem: čistý git strom (branch `feat/riverpod-3`).

### Step 1: Vytvořit migrační větev a baseline
**Goal**: Bezpečný rollback a záznam výchozího stavu.
**Files**: —

```bash
git checkout -b feat/riverpod-3
flutter analyze > /tmp/analyze_before.txt 2>&1 || true
flutter test > /tmp/test_before.txt 2>&1 || true
```

**Done when**: Větev existuje, baseline výstupy uloženy pro pozdější srovnání.

---

### Step 2: Bump verze v pubspec.yaml
**Goal**: Přejít na Riverpod 3.0.3.
**Files**: `pubspec.yaml`

```yaml
dependencies:
  flutter_riverpod: ^3.0.0   # bylo: 2.6.1
```

```bash
flutter pub get
```

**Done when**: `flutter pub get` proběhne bez konfliktů a `grep -A6 "flutter_riverpod:" pubspec.lock` ukazuje version 3.0.3. (Pokud resolver stáhne novější 3.0.x, je to v pořádku.)

---

### Step 3: Globální přejmenování `valueOrNull` → `value`
**Goal**: Odstranit přejmenovaný člen `AsyncValue.valueOrNull`.
**Files**: 13 `.dart` souborů (20 výskytů), viz seznam níže + `lib/di/CONTRACT.md` (dokumentace).

Dotčené soubory: `lib/state/weight_entry_notifier.dart`, `lib/state/dashboard_notifier.dart`, `lib/screens/main_screen.dart`, `lib/screens/log_meal/select_meal_screen.dart`, `lib/screens/progress_screen.dart`, `lib/screens/logs/exercise_log_home_screen.dart`, `lib/screens/logs/exercise_detail_screen.dart`, `lib/screens/profile/ask_ai/ask_ai_screen.dart`, `lib/screens/profile/subscreens/personal_details_screen.dart`, `lib/screens/profile/subscreens/weight_history_screen.dart`, `lib/screens/meals/edit_meal_screen.dart`, `lib/screens/ingredients/edit_ingredient_screen.dart`.

```dart
// PŘED
ref.watch(weightEntriesProvider).valueOrNull?.firstOrNull
// PO
ref.watch(weightEntriesProvider).value?.firstOrNull
```

Bezpečný postup (celé slovo, jen `.dart`):
```bash
grep -rl "valueOrNull" lib/ --include="*.dart" | xargs sed -i '' 's/\bvalueOrNull\b/value/g'
```
Dokumentaci `lib/di/CONTRACT.md` uprav ručně (nahradit zmínky `valueOrNull` a doplnit poznámku o 3.0).

**Done when**: `grep -rn "valueOrNull" lib/ --include="*.dart"` vrací 0 a `flutter analyze` na těchto souborech nehlásí neznámý člen.

---

### Step 4: Audit throwing `.value` → `requireValue`
**Goal**: Ošetřit sémantickou změnu — v 2.x `AsyncValue.value` rethrow-ovalo chybu, v 3.0 `value` = starý `valueOrNull` (nikdy nevyhodí, vrací `null`).
**Files**: kandidáti přes grep (ručně posoudit každý).

```bash
# Najdi .value volané na AsyncValue, které mohlo spoléhat na rethrow
grep -rn "\.value\b" lib/ --include="*.dart" | grep -iE "async|provider|snapshot|state" 
```

Pro každý zásah rozhodni:
- Pokud kód spoléhal na to, že `.value` vyhodí chybu / vrátí ne-null v datovém stavu → nahraď `requireValue`.
- Pokud jde o nový (přejmenovaný) nullable přístup → ponech `value`.

Po Step 3 by většina byla už dřív psaná jako `valueOrNull` (autor byl explicitní), takže očekávaný počist zásahů je nízký až nulový.

**Done when**: Manuálně ověřeno, že žádné `.value` na `AsyncValue` neztratilo dřívější „throw on error" chování bez náhrady `requireValue`.

---

### Step 5: Konfigurovat automatický retry (vypnout globálně)
**Goal**: Zabránit nechtěnému 10× retry s backoffem u chybujících providerů (ochrana nákladů na AI + jasné chyby).
**Files**: `lib/main.dart`

```dart
// PŘED
rootContainer = ProviderContainer(
  overrides: [
    databaseProvider.overrideWithValue(db),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ],
);

// PO
rootContainer = ProviderContainer(
  retry: (retryCount, error) => null, // vypnuto globálně; opt-in per-provider dle potřeby
  overrides: [
    databaseProvider.overrideWithValue(db),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ],
);
```

Pozn.: `retry` parametr přijímá i `ProviderScope` — protože aplikace používá `ProviderContainer` + `UncontrolledProviderScope`, nastavuje se na containeru. Do `CONTRACT.md` doplň řádek o retry politice.

**Done when**: `rootContainer` má explicitní `retry` a rozhodnutí je zdokumentováno.

---

### Step 6: Ověřit `ProviderContainer` + `UncontrolledProviderScope` API
**Goal**: Potvrdit, že ruční bootstrap v `main.dart` je v 3.0 validní (3.0.3 opravil assertion u dvojího napojení containeru na scope).
**Files**: `lib/main.dart`, `lib/di/providers.dart`

- Ověř, že `ProviderContainer(...)` konstruktor a `UncontrolledProviderScope(container:, child:)` kompilují beze změny.
- Ověř `rootContainer.read(...)` volání (session init, language load, widget sync) a použití z `tracking_reminder_service.dart` / `widget_action_router.dart`.

**Done when**: `flutter analyze` na `main.dart` a `providers.dart` je bez chyb; aplikace nastartuje.

---

### Step 7: Ověřit `ProviderScope.containerOf`
**Goal**: Potvrdit signaturu helperu v 3.0.
**Files**: `lib/widgets/dashboard_calendar_sheet.dart:21`

```dart
final container = ProviderScope.containerOf(context, listen: false);
```

Pokud 3.0 změní signaturu/chování, uprav volání. Jinak ponech.

**Done when**: Řádek kompiluje a kalendářový sheet se otevře bez chyby.

---

### Step 8: Ověřit `networkStatusProvider` (== filtrování + pauza mimo obrazovku)
**Goal**: Potvrdit, že stream stavu sítě funguje s novým `==` filtrováním a s pauzováním mimo obrazovku.
**Files**: `lib/di/providers.dart:45`

- `==` na `bool` je bezpečné (dedupe stejných hodnot je žádoucí).
- Pauzování mimo obrazovku: ověř, že offline/online indikátor reaguje i po návratu na obrazovku. Pokud musí stream běžet nepřetržitě, zabal konzumující widget do `TickerMode(enabled: true)` nebo drž provider naživu čtením z `rootContainer`.

**Done when**: Přepnutí letadlového režimu se projeví v UI v očekávaném čase.

---

### Step 9: Full analyze + test + smoke test
**Goal**: Zelená pipeline a funkční parita.
**Files**: —

```bash
dart format --line-length 180 lib/
flutter analyze
flutter test
flutter run   # manuální smoke test
```

Smoke test checklist: dashboard načte den; přidání jídla (manuál + AI); váha + historie; šablony (meal/exercise/ingredient) se načtou (AsyncNotifiery); notifikační tap přepne tab; home widget akce.

**Done when**: Všechna kritéria ze Sekce 2 splněna.

---

### Step 10 (volitelný): Přidat `riverpod_lint`
**Goal**: Statická kontrola zbytkových 2.x vzorů.
**Files**: `pubspec.yaml`, `analysis_options.yaml`

```yaml
dev_dependencies:
  riverpod_lint: ^3.0.0   # custom_lint už je přítomen
```
```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

**Done when**: `dart run custom_lint` proběhne a nehlásí kritické riverpod nálezy.

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| `AsyncNotifier.build()` vyhodí chybu (např. DB read selže) | V 3.0 by se defaultně 10× retry-oval | Step 5 vypíná globálně; per-provider opt-in tam, kde retry dává smysl |
| Chytání konkrétní výjimky z `ref.read(x.future)` | 3.0 obalí chybu do `ProviderException` | Audit `try/catch` bloků; chytat `ProviderException` a číst `e.exception`, nebo použít `AsyncValue.guard` (už používáno v notifierech) |
| `.value` na AsyncValue dřív rethrow-oval | 3.0 `value` vrací null | Step 4: kde je potřeba non-null/throw, použít `requireValue` |
| StreamProvider emituje stejnou hodnotu opakovaně | 3.0 filtruje přes `==`, duplicity se zahodí | Pro `networkStatusProvider<bool>` žádoucí; u custom typů bez `==` override zvážit `updateShouldNotify` |
| Provider pauzuje mimo obrazovku a stream zmešká událost | Data se přepočítají při návratu | Kritické streamy držet naživu přes `rootContainer` nebo `TickerMode` |
| `flutter pub get` konflikt tranzitivních závislostí | Resolver selže | `flutter pub deps` diagnostika; případně bump závislé balíčky kompatibilní s riverpod 3 |
| `mealAnalysisProvider` / `activityAnalysisProvider` chybující AI analýza | Bez retenze retry chování | Ověřit, že vypnutý globální retry nezhorší UX (spíš zlepší — okamžitá chyba místo tichého retry) |

---

## 6. SECURITY CONSIDERATIONS

- **Input validation**: Beze změny; migrace nemění vstupní vrstvu.
- **Auth/Access control**: N/A (lokální app bez účtů).
- **Sensitive data**: OpenAI API klíč v `.env` — migrace se ho nedotýká. Automatický retry (Step 5) je vypnut mimo jiné proto, aby chybující AI volání nezpůsobila opakované placené requesty.
- **Logging**: `ProviderException` může v error logu obalit původní výjimku; ověřit, že se do logů nedostane citlivý obsah promptu/odpovědi navíc oproti dnešku (telemetrie `AiAttempt` zůstává beze změny).

---

## 7. ASSUMPTIONS

Odvozeno z analýzy kódu, ověřit:

1. **3.0.3 je cílová verze** — nejnovější stabilní k 2026-07. Pokud vyšla novější 3.0.x, `^3.0.0` ji stáhne; žádná akce.
2. **SDK `^3.9.0` splňuje Dart 3.7+ požadavek 3.0.3** — potvrzeno v pubspecu; nízké riziko.
3. **Žádný testovací kód nespoléhá na 2.x-specifické API** (`ProviderContainer` test konstruktor, `valueOrNull`) — `flutter test` v Step 9 to ověří; testů s riverpodem je málo.
4. **`overrideWithValue` na plain `Provider` zůstává v 3.0 kompatibilní** — dvě override v `main.dart`; nízké riziko.
5. **Vypnutí globálního retry je preferováno** — vychází z toho, že projekt sleduje AI náklady; pokud autor chce naopak retry využít pro odolnost DB/network, Step 5 se otočí na opt-out per provider.

> Otevřené otázky viz Sekce 12.

---

## 8. QUICK REFERENCE

### Files to Modify
- `pubspec.yaml` — bump `flutter_riverpod` na `^3.0.0`; volitelně `riverpod_lint`
- 13 `.dart` souborů — `valueOrNull` → `value` (viz Step 3)
- `lib/main.dart` — `ProviderContainer(retry: ...)`
- `lib/di/CONTRACT.md` — poznámka o 3.0, retry politice, `value`
- `lib/di/providers.dart` — ověření `networkStatusProvider`
- `lib/widgets/dashboard_calendar_sheet.dart` — ověření `containerOf`
- `analysis_options.yaml` — volitelně plugin `custom_lint`

### Files to Create
- žádné

### Dependencies
- `flutter_riverpod: ^3.0.0` (cíl 3.0.3) — jádro migrace
- `riverpod_lint: ^3.0.0` (dev, volitelné) — statická kontrola

### Commands
```bash
# Setup
git checkout -b feat/riverpod-3
# bump v pubspec.yaml, pak:
flutter pub get

# Mechanická náhrada
grep -rl "valueOrNull" lib/ --include="*.dart" | xargs sed -i '' 's/\bvalueOrNull\b/value/g'

# Verify
grep -rn "valueOrNull" lib/ --include="*.dart"   # → 0
flutter analyze
flutter test
flutter run
```

---

## 10. CORRECTIONS FROM CURRENT STATE

| What | Before (2.6.1) | After (3.0.3) |
|------|----------------|---------------|
| `pubspec.yaml` závislost | `flutter_riverpod: 2.6.1` | `flutter_riverpod: ^3.0.0` |
| `AsyncValue` non-throwing přístup | `.valueOrNull` (20×) | `.value` |
| `AsyncValue` throwing přístup (pokud existuje) | `.value` (rethrow) | `.requireValue` |
| Chování při chybě providera | žádný retry | 3.0 defaultně 10× retry → **explicitně vypnuto** v `main.dart` |
| Chytání chyb z `.future` | přímý typ výjimky | obaleno v `ProviderException` (audit `try/catch`) |
| Provider mimo obrazovku | běží dál | 3.0 defaultně pauzuje (ověřit `networkStatusProvider`) |
| `ProviderContainer` konstruktor | bez `retry` | s `retry:` parametrem |
| Dokumentace `CONTRACT.md` | zmiňuje `valueOrNull` | aktualizováno na `value` + retry politika |

---

## 11. CHANGELOG

| Date | Change |
|------|--------|
| 2026-07-14 | Initial plan created |

---

## 12. OPEN QUESTIONS & ALTERNATIVE APPROACHES

### 12.1 Alternative Approaches Considered

| Approach | Pros | Cons | Selected? |
|----------|------|------|-----------|
| **A. Ruční deklarace + bump na 3.0 (mechanická migrace)** | Minimální změny, žádný nový build krok, zachovává autorův styl, nízké riziko | Nevyužívá code-gen výhody | ✅ |
| **B. Bump na 3.0 + přechod na code generation (`@riverpod`)** | Méně boilerplate, autoDispose zdarma, family bez gymnastiky | Přepsat 21 Notifierů + 26 Provider, přidat `riverpod_generator`/`build_runner` krok pro riverpod, velké riziko těsně před dokončením diplomky | — |
| **C. Zůstat na 2.6.1** | Nulová práce, nulové riziko | Nesplní zadání (chce 3.0), zaostává za doporučeným API | — |

**Why the selected approach won**: Projekt je mimořádně čistý (0× legacy API, 0× `.family`/`.autoDispose`/`Ref` type param/`listenSelf`/`ProviderObserver`), takže bump je z 90 % mechanický. Přechod na code generation (B) je ortogonální rozhodnutí s vysokým rizikem a bez funkčního přínosu pro tuto lokální aplikaci, proto se odkládá.

### 12.2 Open Questions

- [ ] **Automatický retry: vypnout globálně, nebo selektivně povolit?** — Proposed direction: vypnout globálně (Step 5), protože projekt hlídá náklady na OpenAI a chce jasné chyby; retry zapnout jen tam, kde je idempotentní a levné (např. DB read). Rozhodnutí patří autorovi.
- [ ] **Existuje v kódu `.value` na `AsyncValue`, které spoléhalo na rethrow?** — Proposed direction: Step 4 audit; očekávaný počet nula (autor psal explicitně `valueOrNull`), ale potvrdit grepem a manuálně.
- [ ] **Pauzuje `networkStatusProvider` nevhodně mimo obrazovku?** — Proposed direction: Step 8 manuální test; pokud ano, držet naživu přes `rootContainer` (už dnes existuje) nebo `TickerMode`.
- [ ] **Mají existující testy 2.x-specifické API?** — Proposed direction: spustit `flutter test` (Step 9); testů s riverpodem je málo, případné úpravy `ProviderContainer` v testech dořešit ad hoc.

### 12.3 Suggestions & Follow-ups

- Po migraci aktualizovat sekci „State Management: Riverpod" v `CLAUDE.md` (dnes verzi ani volbu manual-vs-codegen neuvádí — právě to vede k opakovaným dotazům).
- Zvážit přidání `riverpod_lint` natrvalo (Step 10) — odhalí budoucí regrese k legacy vzorům.
- V diplomce lze migraci zmínit jako příklad „technického dluhu udržovaného pod kontrolou": čistá 2.x → 3.0 migrace byla možná díky konzistentnímu použití moderního `Notifier`/`AsyncNotifier` API bez legacy zbytků.
- Backendová větev (`foody-be` proxy) je nezávislá; migrace Riverpodu ji neovlivňuje.
