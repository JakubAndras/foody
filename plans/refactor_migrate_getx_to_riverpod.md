# Úplná migrace z GetX na Riverpod (bez stopy po GetX)

> **Summary**: Kompletně přepsat stavovou vrstvu, DI, navigaci, UI feedback a lifecycle z GetX na idiomatický Riverpod tak, aby ve výsledném kódu nezůstala žádná stopa po GetX ani žádná fasáda, která by GetX pouze napodobovala.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement
Aplikace Foody je dnes plně postavená na balíčku GetX, který v projektu zastává pět rolí najednou (dependency injection, reaktivní stav, navigace, UI feedback, app/lifecycle). GetX je runtime service-locator bez kompilační kontroly, mísí odpovědnosti a je hůře testovatelný. Cílem je závislost na GetX zcela odstranit.

### 1.2 Solution Overview
Provést **úplnou (big-bang) migraci na Riverpod** na samostatné větvi. Riverpod jako jediný nástroj pokryje dvě největší role GetX (dependency injection i reaktivní stav). Navigaci, kterou Riverpod neřeší, převzít **idiomatickým Navigator 1.0 řízeným z UI vrstvy** (`ref.listen` pro stavem řízené přechody) plus jediným aplikačním `navigatorKey` pro vnější vstupní body (notifikace, home widget). Výsledek musí být **formálně správný a idiomatický Riverpod** — žádný globální service-locator používaný jako náhrada `Get.find`, žádná statická navigační fasáda napodobující `Get.to`/`Get.back`.

### 1.3 Scope: What This IS
- Odstranění balíčku `get` z `pubspec.yaml` a ze všech 81 souborů, které jej importují.
- Náhrada DI (`Get.put`/`Get.find`/`.to` gettery) idiomatickými providery Riverpodu.
- Náhrada reaktivního stavu (`.obs`/`Obx`/`Rx`/`.value`) třídami `Notifier`/`AsyncNotifier`, immutable stavem a `ref.watch`/`Consumer`.
- Náhrada navigace (`Get.to`/`Get.back`/`GetMaterialApp`) navigací řízenou z UI vrstvy + `navigatorKey` pro vnější vstupní body.
- Náhrada drobných API (`Get.dialog`, `Get.theme`, `Get.locale`) standardními Flutter/easy_localization ekvivalenty.
- Náhrada lifecycle (`GetxService.onInit/onClose`, `FullLifeCycleController`).

### 1.4 Scope: What This IS NOT
- **Není** to změna chování ani UI. Žádná obrazovka nemění vzhled ani funkci.
- **Není** to koexistence GetX a Riverpodu. Žádný přechodný most, žádné souběžné DI. Migrace probíhá big-bang na větvi a mergeuje se až kompletní.
- **Není** to přípustné ponechat jakoukoli fasádu napodobující GetX (např. statické `NavigationService.to()/back()` mirrorující `Get.*`, ani globální `container.read()` používaný všude jako `Get.find`). Kód musí vypadat jako navržený pro Riverpod.
- **Není** to migrace databáze (Floor), sítě (Dio), lokalizace (easy_localization) ani AI pipeline — ty se dotýkají jen tam, kde dnes dědí z `GetxService`.
- **Není** to zavedení `go_router`/Navigator 2.0 (projekt nemá pojmenované routy; viz 12.1).
- **Není** to přepis na code-gen Riverpod (`riverpod_generator`) — providery se píší ručně.

---

## 2. SUCCESS CRITERIA

Implementace je HOTOVÁ, když jsou splněna VŠECHNA kritéria:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | Žádná stopa po GetX v kódu | `grep -rniE "get|obx|rx|getx" lib/` neobsahuje žádný odkaz na balíček GetX ani jeho API |
| 2 | Balíček `get` odstraněn z `pubspec.yaml` a lock | `grep -n "get:" pubspec.yaml` nic; `get` není v `pubspec.lock` |
| 3 | Žádná fasáda napodobující GetX | Code review: neexistuje statický navigační singleton ani globální `container.read` používaný jako service-locator napříč kódem |
| 4 | `flutter analyze` bez errorů | Výstup: `0 errors` |
| 5 | Aplikace projde smoke test klíčových toků | Ruční průchod: dashboard, add meal (foto/text/hlas/barcode), Ask AI, export, jazyk, notifikace, home widget, health |
| 6 | DI graf je kompilačně ověřený | Providery se resolvují staticky; žádné runtime „not found" |
| 7 | Testy procházejí | `flutter test` zelené (setup přepsán na `ProviderContainer`/`ProviderScope` overrides) |
| 8 | Idiomatičnost | Navigace řízena z UI (`ref.listen` + `Navigator.of(context)`); `navigatorKey` použit jen pro vnější vstupní body |

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture — cílový stav (bez GetX)

```
                    ┌───────────────────────────────┐
   main.dart  ───▶  │ build DB (await)               │
                    │ ProviderScope(overrides: [      │
                    │   databaseProvider = db ])      │
                    └───────────────┬───────────────┘
                                    │
          ┌─────────────────────────┼──────────────────────────┐
          ▼                          ▼                           ▼
   UI (ConsumerWidget)      Providery služeb            Notifier / AsyncNotifier
   ref.watch(provider)      Provider((ref) => Svc(ref))  build() → immutable state
   Consumer / ref.listen    ref.read(otherProvider)      state = new state
          │                          ▲                           ▲
          │  navigace řízená z UI    │  závislosti přes ref      │
          ▼                          └───────────────────────────┘
   Navigator.of(context).push(...)          (žádný globální locator)
          │
          └── vnější vstupní body (notifikace, home widget):
              navigatorKey.currentState?.push(...)   ← jediná výjimka mimo widget tree
```

**Zásady formální správnosti (aby nebyla znát stopa po GetX):**
- Závislosti tečou grafem providerů přes `ref`, ne přes globální lookup. Root `ProviderContainer` z `main()` se čte **výhradně ve vnějších vstupních bodech** (top-level callbacky notifikací, home widget), ne roztroušeně po kódu jako `Get.find`.
- Navigace se rozhoduje v UI vrstvě, kde existuje `BuildContext`. Controller/Notifier vystaví stav nebo jednorázovou událost, widget na ni reaguje přes `ref.listen` a zavolá `Navigator`.
- `navigatorKey` je standardní Flutter mechanismus (doporučený i v dokumentaci `flutter_local_notifications`), použitý jen tam, kde vstupní bod nemá kontext. Není z něj stavěna univerzální navigační služba.

### 3.2 Rozsah závislosti na GetX (výsledek analýzy)

| Kategorie | Metrika | Počet |
|-----------|---------|-------|
| Soubory s `import get` | celkem | **81** |
| DI | `Get.put` / `Get.putAsync` / `Get.find` | 26 / 1 / 39 |
| DI | `Get.lazyPut` (vč. `fenix:true`) / `Get.isRegistered` | ~10 / 21 |
| Stav | `GetxController` / `GetxService` | 8 / 22 |
| Stav | `Obx(` / `GetBuilder` / `GetView` | 39 / 1 / 3 |
| Stav | `.obs` / Rx deklarace / `.value` přístupy / `update()` | 50 / 77 / 468 / 8 |
| Stav | workery (`ever`/`debounce`) | 2 |
| Navigace | `Get.to` / `Get.back` / `Get.off(All)` | 46 / 40 / 2 |
| Navigace | `Get.context` / pojmenované routy | 3 / 0 |
| UI feedback | `Get.dialog` / `Get.isDialogOpen` / snackbar | 1 / 1 / 0 |
| Ostatní | `Get.theme` / `Get.locale*` | 6 / 5 |
| Root | `GetMaterialApp` | 1 (app.dart) |
| Lifecycle | `FullLifeCycleController` / služby s `onInit/onClose` | 1 / ~7 |

Největší jednotlivé soubory: `dashboard_controller.dart` (743 ř.), `ask_ai_controller.dart` (287 ř.), `day_record_controller.dart` (267 ř.).

### 3.3 Odhad pracnosti (orientační, ne měřená data)

| Vrstva | Rozsah | T-shirt | Hrubý odhad (1 vývojář) |
|--------|--------|---------|--------------------------|
| Fáze 0: příprava, test-baseline, provider skeleton | 3 soubory | S | 0,5–1 den |
| Fáze 1: DI služeb (22 služeb) | 22 souborů + `locator.dart` | L | 2–3 dny |
| Fáze 2: reaktivní stav (13 controllerů, 468 `.value`) | ~13 controllerů | XL | 3–5 dnů |
| Fáze 3: UI vrstva (39 `Obx`, 39 screenů) + navigace řízená z UI | ~39 screenů + 48 nav volání | XL | 3–5 dnů |
| Fáze 4: app root, lifecycle, UI feedback, theme, locale | app.dart + ~15 míst | M | 1–1,5 dne |
| Fáze 5: odstranění GetX, integrace, verifikace, testy | pubspec + testy + smoke | M | 1–2 dny |
| **Celkem** | **~81 souborů** | **XL** | **≈ 10–17 dnů** |

> Big-bang koncentruje riziko: strom se **nekompiluje průběžně**, integruje se až na konci. Proto je nutná dedikovaná větev a upfront testovací baseline. Odhad je orientační T-shirt sizing, ne naměřená veličina.

### 3.4 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Cílový state framework | **Riverpod** | Pokrývá DI + reaktivní stav jedním nástrojem (jako GetX) → mechaničtější migrace. Bloc řeší jen stav a vyžadoval by druhý DI balíček + event/state přepis. |
| Strategie | **Big-bang na větvi** | Uživatel nechce koexistenci. Žádný most; strom se dokončí a mergeuje jako celek. |
| Řešení navigace | Navigator 1.0 řízený z UI + `navigatorKey` pro vnější vstupy | Projekt nemá pojmenované routy. Navigace patří do UI vrstvy (`ref.listen`). `navigatorKey` jen pro notifikace/home widget. |
| Fasáda GetX | **Zakázána** | Žádné statické `NavigationService.to/back`, žádný globální `container.read` jako locator. Formální správnost = idiomatický Riverpod. |
| Bezkontextový přístup ke stavu | Root `ProviderContainer` jen ve vstupních bodech | Standardní Riverpod mimo widget tree; ne roztroušený locator. |
| Styl providerů | Ruční `Notifier`/`Provider` (bez code-genu) | `riverpod_generator` jsme odstranili; držíme build jednoduchý. |
| DB init | `ProviderScope(overrides:)` v `main()` | Nahrazuje `Get.putAsync`; DB připravená před prvním čtenářem. |
| Model provádění | **Kontrakt → fan-out → integrace** | Kontrakt (názvy providerů) zafixovaný předem odpojí soubory od sebe → ~77 souborů lze převádět paralelně (viz 4.1). |

---

## 4. IMPLEMENTATION STEPS (dekomponováno pro paralelní agenty)

### 4.1 Model provádění — 3 vrstvy s bariérami

```
  TIER A: KONTRAKT + SCAFFOLD        TIER B: FAN-OUT PŘEVODY            TIER C: INTEGRACE
  (SERIAL, 1 agent, BARIÉRA)   ──▶   (PARALELNÍ, ~77 agentů)     ──▶    (SERIAL, 1 agent)
  definuje názvy providerů           1 soubor = 1 úkol                  slepení, kompilace,
  → sdílený slovník                  disjunktní soubory                 testy, cleanup
```

**Proč to jde paralelizovat:** big-bang migrace se stejně **nezkompiluje až do integrace**. Jediná skutečná závislost mezi soubory je **shoda na názvech providerů a stavových tříd**. Když se ta zafixuje předem v Tieru A (kontrakt), pak každý z ~77 souborů referencuje ostatní **jen podle názvu z kontraktu**, ne podle implementace. Proto mohou služby, controllery i screeny běžet **současně**.

**Provozní pravidla pro agenty:**
- **Tier A je tvrdá bariéra.** Dokud kontrakt (`lib/di/providers.dart` se všemi názvy a signaturami) neexistuje, žádný fan-out úkol nesmí začít.
- **Uvnitř Tieru B žádné sdílené soubory.** Každý úkol vlastní právě jeden soubor. Soubory se nepřekrývají → bezpečné pro paralelní agenty bez konfliktů (worktree izolace není nutná, stačí disjunktní cesty).
- **Fan-out agent NEspouští `flutter analyze`** (strom se nekompiluje). Jeho „done when" je **mechanický, grep-based** (v jeho souboru nezůstal žádný GetX symbol + reference sedí na kontrakt). Kompilaci řeší až Tier C.
- **Sdílené soubory** (`providers.dart`, `main.dart`, `app.dart`, `pubspec.yaml`) upravuje jen Tier A / Tier C, nikdy fan-out agent.

**Definition of Done pro každý fan-out úkol (Tier B):**
1. V souboru neexistuje `package:get/get.dart` ani žádné `Get.*`, `.obs`, `Obx(`, `Rx*`, `GetxController/Service/View`.
2. Provider/Notifier přesně odpovídá názvu a signatuře z kontraktu (Tier A).
3. Závislosti se čtou přes `ref.read/watch(<názevProvideru>)`.
4. Navigace (jen u UI) přes `Navigator.of(context)` / `ref.listen`, nikdy z controlleru.

---

### 4.2 TIER A — Kontrakt & scaffold (SERIAL, blocking gate)

| ID | Úkol | Soubor(y) | Done when |
|----|------|-----------|-----------|
| A1 | Větev + přidat `flutter_riverpod: ^2.6.1`; zapsat baseline toků | `pubspec.yaml` | `flutter pub get` OK, větev `refactor/riverpod` |
| A2 | **KONTRAKT**: v `lib/di/providers.dart` deklarovat pro všech 24 služeb + 13 controllerů: název provideru, typ stavové třídy, veřejné metody (jako stuby/podpisy). Rozpad `dashboard` na sub-providery zde. | `lib/di/providers.dart` (nový) | Každý downstream soubor má na co odkázat; dokument je autoritativní slovník |
| A3 | Bootstrap: build DB v `main()`, `ProviderScope(overrides:[databaseProvider])`, globální `navigatorKey`, `AppLifecycleListener` | `lib/main.dart` | App se nastartuje (i s dočasně nefunkčním UI) |
| A4 | Root shell: `GetMaterialApp` → `MaterialApp(navigatorKey:)`, převést vlastní `Obx` gate onboardingu | `lib/app.dart` | `grep GetMaterialApp lib/` prázdné |
| A5 | (Doporučeno) golden/widget testy klíčových obrazovek PŘED přepisem | `test/**` | Baseline testy zelené na starém kódu |

> A2 je nejcennější a nejrizikovější krok — kvalita kontraktu určuje, jak hladce proběhne celý fan-out. Věnuj mu péči.

---

### 4.3 TIER B — Fan-out převody (PARALELNÍ, 1 soubor = 1 úkol)

> Všechny tři skupiny (SVC/CTL/UI) mohou běžet **současně**. Řídí se sdíleným kontraktem (A2) a společnou Definition of Done (4.1). Vzory transformací viz 4.5.

**Skupina B-SVC — služby & síť (24 úkolů):** `GetxService` → `Provider`, `.to` getter smazat, `Get.find` → `ref.read`, `onInit/onClose` → konstruktor/`ref.onDispose`.

| ID | Soubor | ID | Soubor |
|----|--------|----|--------|
| S01 | `network/base_rest_client.dart` | S13 | `services/ingredient_template_repository.dart` |
| S02 | `network/rest_client.dart` | S14 | `services/language_settings_service.dart` |
| S03 | `network/open_food_facts_client.dart` | S15 | `services/meal_template_repository.dart` |
| S04 | `network/openai_rest_client.dart` | S16 | `services/motivational_summary_service.dart` |
| S05 | `services/ai_feature/ai_attempt_log_service.dart` | S17 | `services/nutrition_goals_service.dart` |
| S06 | `services/ai_feature/ai_pipeline_service.dart` | S18 | `services/selected_date_service.dart` |
| S07 | `services/ai_feature/ai_service_manager.dart` | S19 | `services/session_manager.dart` |
| S08 | `services/barcode_lookup_service.dart` | S20 | `services/shared_preferences_manager.dart` |
| S09 | `services/day_record_repository.dart` | S21 | `services/streak_service.dart` |
| S10 | `services/dietary_violation_service.dart` | S22 | `services/tracking_reminder_service.dart` |
| S11 | `services/exercise_template_repository.dart` | S23 | `services/weight_entry_repository.dart` |
| S12 | `services/health_integration_service.dart` | S24 | `services/home_widget/widget_sync_service.dart` + `widget_action_router.dart` |

> Ověř i `ai_feature/openai_service.dart` a `gemini_service.dart` (byly `lazyPut`) — pokud importují `get`, patří sem taky.

**Skupina B-CTL — controllery (13 úkolů):** `GetxController` + `.obs` → `Notifier`/`AsyncNotifier` + immutable stav. Navigaci NEdělat.

| ID | Soubor | Pozn. |
|----|--------|-------|
| C01 | `controller/streak_controller.dart` | malý |
| C02 | `controller/weight_entry_controller.dart` | malý |
| C03 | `controller/language_settings_controller.dart` | malý |
| C04 | `controller/health_integration_controller.dart` | malý |
| C05 | `controller/recipe_service.dart` | přesunout do `services/` |
| C06 | `controller/motivational_summary_controller.dart` | střední |
| C07 | `controller/tracking_reminders_controller.dart` | střední |
| C08 | `controller/barcode_scan_controller.dart` | střední |
| C09 | `controller/export_controller.dart` | střední |
| C10 | `controller/day_record_controller.dart` | `AsyncNotifier` |
| C11 | `controller/ask_ai_controller.dart` | `AsyncNotifier` |
| C12a-c | `controller/dashboard_controller.dart` (743 ř.) | **rozdělit** na 3 sub-providery (souhrn/cíle/jídla) dle kontraktu → lze 3 agenti |
| C13 | `controller/base_controller.dart` | cross-cutting → mixin/util bez GetX (`hasInternet`, `progressWidget`, lifecycle) |

**Skupina B-UI — screeny & widgety (40 úkolů):** `Obx`/`GetView` → `Consumer`/`ConsumerWidget`; `Get.to/back/off` → `Navigator.of(context)`; `Get.find` → `ref`; `Get.theme` → `Theme.of`. Každý soubor ze seznamu v 3.2 je jeden úkol (U01–U40), např. `screens/dashboard_screen.dart`, `screens/main_screen.dart`, `screens/meals/edit_meal_screen.dart`, … `widgets/weekly_energy_card.dart`. Úplný seznam 40 souborů je výstup gripu v analýze.

---

### 4.4 TIER C — Integrace & cleanup (SERIAL, 1 agent)

| ID | Úkol | Done when |
|----|------|-----------|
| I1 | Smazat `lib/locator.dart` | soubor neexistuje |
| I2 | Odstranit `get: 4.6.6` z `pubspec.yaml`, `flutter pub get` | `get` není v `pubspec.lock` |
| I3 | `flutter analyze` → iterativně opravit integrační chyby (chybějící napojení mezi zmigrovanými soubory) | 0 errors |
| I4 | Přepsat testy: `Get.put` setup → `ProviderContainer(overrides:)`, widgety obalit `ProviderScope`; `flutter test` | zelené |
| I5 | Ruční smoke test všech toků z baseline (A1) | vše funguje |
| I6 | Grep-audit stopy po GetX (kritéria 1, 3, 8) + aktualizovat `.claude/STACK.md` a `CLAUDE.md` | `grep` čistý, docs aktuální |

---

### 4.5 Referenční vzory transformací (pro fan-out agenty)

```dart
// --- SLUŽBA: GetxService → Provider ---
// Před:  class Foo extends GetxService { static Foo get to => Get.find(); }
// Po:
class Foo { Foo(this._ref); final Ref _ref; }
final fooProvider = Provider<Foo>((ref) => Foo(ref));      // název dle kontraktu
// závislost:  Get.find<Bar>()  →  ref.read(barProvider)

// --- CONTROLLER: GetxController(.obs) → Notifier ---
class DemoState { final int count; const DemoState(this.count); }
class DemoNotifier extends Notifier<DemoState> {
  @override DemoState build() => const DemoState(0);
  void inc() => state = DemoState(state.count + 1);        // místo count.value++
}
final demoProvider = NotifierProvider<DemoNotifier, DemoState>(DemoNotifier.new);

// --- UI: Obx → Consumer + navigace z UI ---
Consumer(builder: (_, ref, __) => Text('${ref.watch(demoProvider).count}'));
onTap: () => Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const NextScreen()));   // místo Get.to
// async přechod (náhrada Get.back po akci controlleru):
ref.listen(saveProvider, (p, n) {
  if (n.justSaved != null) Navigator.of(context).pop(n.justSaved);
});
```

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| Navigace po async akci v controlleru | Přechod až po dokončení, v UI | Controller vystaví stav/událost; UI reaguje přes `ref.listen` + `Navigator` |
| Vnější vstupní bod bez kontextu (notifikace tap, home widget) | Otevře správnou obrazovku | `navigatorKey.currentState?.push(...)` + root container čtený jen zde |
| `Get.putAsync` DB build před UI | DB připravená před prvním čtenářem | build v `main()` + `databaseProvider.overrideWithValue(db)` |
| `permanent: true` služby | Nesmí se disposovat | Root-level providery bez `autoDispose` |
| `fenix: true` lazy singletony | Znovu vytvoření po invalidaci | Riverpod recreatuje on-demand; pro trvalé drž v root scope |
| Cyklické závislosti mezi službami | Detekce, ne zamrznutí | Riverpod hlásí `CircularDependencyError` — přeorganizuj graf / líná injekce přes `ref` |
| Async loading stavy (dashboard, ask_ai) | Loading/error/data odlišeny | `AsyncNotifier` + `AsyncValue.when()` |
| Background isolate (notifikace na pozadí) | Nemá sdílený container | Top-level handler; minimální deps re-inicializovat, nesdílet UI container |
| Testy spoléhající na `Get.find` | Přepsané, zelené | `ProviderContainer(overrides:)` + `container.read(...)` |

---

## 6. SECURITY CONSIDERATIONS

- **Sensitive data**: Migrace se dotýká `SessionManager`/`SharedPreferencesService` (profil, cíle) a AI klíčů z `.env`. Chování ukládání se nemění. Ověř, že klíče stále tečou z `.env` přes provider a nikam se nelogují.
- **Logging**: Nezaváděj `ProviderObserver` logující obsah stavu s PII (váha, DOB) ani AI tokeny/cost. V release buildu žádné logování stavu providerů.
- **Input validation**: Beze změny.
- **Auth/Access control**: N/A (bez auth a online sync).

---

## 7. ASSUMPTIONS

Odvozeno z kontextu — ověř před implementací:

1. **Riverpod je preferován před Bloc**: uživatel delegoval rozhodnutí; zvoleno kvůli sjednocení DI+stavu (viz 3.4 a 12.1).
2. **Big-bang na větvi je akceptovatelný**: uživatel výslovně nechce koexistenci. Strom se dočasně nekompiluje; integruje se na konci.
3. **Navigator 1.0 řízený z UI stačí**: projekt nemá pojmenované routy ani deep-linky. Pokud přibude deep-linking/web, zvaž `go_router`.
4. **Ruční providery (bez code-genu)**: nezavádět zpět `riverpod_generator`.
5. **Existuje pokrytí testy nebo ochota ručně testovat**: bez toho hrozí regrese u 468 přístupů ke stavu.

> Otevřené otázky jsou v sekci 12.

---

## 8. QUICK REFERENCE

### Files to Modify
- `lib/main.dart` — build DB + `ProviderScope(overrides:)`
- `lib/app.dart` — `GetMaterialApp` → `MaterialApp` + `navigatorKey`
- `lib/locator.dart` — **smazat**
- `lib/controller/base_controller.dart` — odstranit `FullLifeCycle*`, GetX
- `lib/network/base_rest_client.dart` + REST klienti — `GetxService` → `Provider`
- 22 služeb v `lib/services/**` — `GetxService` → `Provider`
- ~13 controllerů v `lib/controller/**` — `GetxController` → `Notifier`/`AsyncNotifier`
- ~39 screenů — `Obx`/`Get.to`/`Get.find` → `Consumer`/`ref`/`Navigator`
- `.claude/STACK.md`, `CLAUDE.md` — aktualizovat dokumentaci

### Files to Create
- `lib/di/providers.dart` — `databaseProvider` a kořenové providery
- (volitelně) `lib/di/lifecycle.dart` — `AppLifecycleListener` wrapper

> Žádná statická navigační/DI fasáda se nevytváří (viz 1.4).

### Dependencies
- `flutter_riverpod: ^2.6.1` — DI + reaktivní stav (přidat)
- `get: 4.6.6` — odstranit na konci

### Commands
```bash
git switch -c refactor/riverpod
flutter pub get

# Průběžná verifikace API
grep -rnE "package:get/get.dart|\.obs|Obx\(|Getx(Controller|Service|View)|Get\.(to|back|find|put|dialog|theme|locale)" lib/

# Finální
flutter analyze && flutter test
```

---

## 10. CORRECTIONS FROM CURRENT STATE

| What | Before (GetX) | After (idiomatický Riverpod) |
|------|---------------|------------------------------|
| App root | `GetMaterialApp(...)` | `MaterialApp(navigatorKey:)` uvnitř `ProviderScope` |
| DI registrace | `Get.put/lazyPut` v `locator.dart` | `Provider`/`NotifierProvider` v modulech |
| Přístup ke službě | `static Foo get to => Get.find()` | `ref.read(fooProvider)` (mimo tree jen v root containeru) |
| Reaktivní pole | `final x = v.obs;` + `x.value` | `Notifier<State>` + `state` / `ref.watch(p).x` |
| Reaktivní widget | `Obx(() => W)` / `GetView` | `Consumer` / `ConsumerWidget` |
| Navigace | `Get.to`/`Get.back` z controlleru | `Navigator.of(context)` z UI; async přechod přes `ref.listen` |
| Vnější vstup bez kontextu | `Get.to` odkudkoli | `navigatorKey.currentState?.push(...)` jen ve vstupních bodech |
| DB init | `Get.putAsync(() => …build())` | build v `main()` + `databaseProvider` override |
| App lifecycle | `FullLifeCycleController` | `AppLifecycleListener` / `WidgetsBindingObserver` |
| Dialog | `Get.dialog` / `Get.isDialogOpen` | `showDialog(context:)` |
| Theme / locale | `Get.theme` / `Get.locale` | `Theme.of(context)` / `context.locale` |

---

## 11. CHANGELOG

| Date | Change |
|------|--------|
| 2026-07-06 | Initial plan created (inkrementální + bridge) |
| 2026-07-06 | Revize: úplná big-bang migrace bez koexistence; zákaz jakékoli fasády napodobující GetX; navigace řízená z UI vrstvy; zpřísněná success criteria (1, 3, 8) |
| 2026-07-06 | Revize: Section 4 dekomponována pro paralelní agenty — model kontrakt → fan-out (~77 souborově izolovaných úkolů S01–S24 / C01–C13 / U01–U40) → integrace; přidána Definition of Done pro fan-out a referenční vzory |

---

## 12. OPEN QUESTIONS & ALTERNATIVE APPROACHES

### 12.1 Alternative Approaches Considered

| Approach | Pros | Cons | Selected? |
|----------|------|------|-----------|
| **Riverpod, big-bang, idiomatický** | Jeden nástroj pro DI i stav; kompilačně bezpečné; jemné rebuildy; čistý výsledek bez stopy po GetX | Strom se nekompiluje průběžně; riziko koncentrované na konci; větší jednorázový integrační push | ✅ |
| **Riverpod inkrementálně s bridgem** | Nižší riziko, app spustitelná v každém kroku | Dočasná koexistence GetX+Riverpod a globální locator = přesně to, co uživatel nechce | — |
| **Bloc/Cubit + get_it** | Přísná separace event→state; skvělá testovatelnost | Řeší jen stav → druhý DI balíček; event/state přepis každého controlleru = víc boilerplate; horší fit pro `.obs` pole | — |

**Proč vyhrál idiomatický big-bang Riverpod**: uživatel explicitně nechce koexistenci ani stopu po GetX. Bridge i jakákoli statická fasáda jsou tím vyloučeny. Riverpod pokrývá DI i stav jedním nástrojem, takže výsledek lze udělat čistě „jako navržený pro Riverpod".

### 12.2 Open Questions

- [ ] **`go_router`, nebo Navigator 1.0?** — Navrhovaný směr: Navigator 1.0 (projekt nemá routovací tabulku). `go_router` zvaž jen pokud přibude deep-linking/web nebo se navigace stane komplexní.
- [ ] **Code-gen, nebo ruční providery?** — Navrhovaný směr: ruční (build jednoduchý). Přehodnotit nad ~40 providerů.
- [ ] **Rozdělení `dashboard_controller` (743 ř.)** — Navrhovaný směr: rozbít na providery po sekcích (souhrn/cíle/jídla) místo jednoho notifieru.
- [ ] **Přejmenovat `lib/controller/recipe_service.dart`?** — Je to služba v adresáři controllerů; při migraci přesuň do `lib/services/`.

### 12.3 Suggestions & Follow-ups

- **Zvaž náklad/přínos vůči diplomce**: ≈ 10–17 dnů velkého refaktoringu bez uživatelského přínosu. Pokud jde o obhajobu, může být hodnotnější GetX ponechat a v textu kriticky zhodnotit volbu state managementu; migrace dává smysl hlavně pro dlouhodobou údržbu produktu.
- **Přidej testy před migrací** (Step 0) — golden/widget testy klíčových obrazovek zachytí regrese.
- **Drž větev `refactor/riverpod` a PR po fázích** kvůli reviewovatelnosti, i když se mergeuje jako celek.
- **Po dokončení aktualizuj `RESEARCH_ONLY.md`** — AI telemetrie dnes teče přes GetX služby.
- **Zvaž feature-first strukturu** providerů místo dnešního controller/service dělení.
