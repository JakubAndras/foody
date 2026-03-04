# FR-21: Meal Planning / Plan vs Actual — UI/UX Design

> Navrzeno 2026-03-04 pro projekt Foody (diplomova prace).
> Cilem je doplnit funkcionalitu planovani jidel a porovnani planu se skutecnosti,
> ktera dava smysl v kontextu AI-based calorie trackingu.

---

## 1. Koncept a Filozofie

### Proc meal planning v calorie trackeru?

Foody je primarne **retrospektivni** nastroj — uzivatel jidlo zanalyzuje az po/pri konzumaci.
Meal planning pridava **proaktivni vrstvu**: uzivatel si naplánuje, co chce jist, a pak sleduje,
jak se jeho skutecny prijem lisi od planu.

### Klicove principy:
1. **Jednoduchost** — planovani nesmi byt slozitejsi nez samotne logovani
2. **Navaznost na existujici data** — planovani z historie a oblíbenych jidel (ne od nuly)
3. **AI synergie** — po naservírovani jidla muze uzivatel vyfotit skutecny talic a AI porovna s planem
4. **Bez stresu** — plan je doporuceni, ne závazek. Odchylky nejsou "selhani"

---

## 2. Datovy Model

### 2.1 Nova DB entita: `PlannedMeal`

```
PlannedMeal
├── id: int (PK, autoincrement)
├── date: int (normalized date — midnight epoch, jako DayRecord)
├── name: String
├── mealSlot: String (breakfast | lunch | dinner | snack)
├── totalCalories: double
├── totalProteins: double
├── totalCarbs: double
├── totalFats: double
├── sourceMealId: int? (odkaz na puvodni Meal z historie, pokud byl klonovany)
├── actualMealId: int? (odkaz na skutecne zalogovane Meal — null dokud neni splneno)
├── notes: String?
├── createdAt: int (timestamp vytvoreni planu)
└── status: String (planned | logged | skipped)
```

### 2.2 Nova DB entita: `PlannedIngredient`

```
PlannedIngredient
├── id: int (PK, autoincrement)
├── plannedMealId: int (FK → PlannedMeal, CASCADE)
├── name: String
├── weight: double
├── calories: double
├── proteins: double
├── carbs: double
└── fats: double
```

### 2.3 Domain model: `MealComparison`

```dart
class MealComparison {
  final PlannedMeal planned;
  final Meal? actual; // null pokud jeste neni zalogovano

  double get calorieDeviation => ...  // procentualni odchylka
  double get proteinDeviation => ...
  bool get isLogged => actual != null;
  bool get isSkipped => planned.status == 'skipped';
}
```

### 2.4 Migrace

- DB verze 8 → 9: `CREATE TABLE PlannedMeal (...)` + `CREATE TABLE PlannedIngredient (...)`
- FK constraint: `PlannedIngredient.plannedMealId → PlannedMeal.id ON DELETE CASCADE`
- Index: `CREATE INDEX idx_planned_meal_date ON PlannedMeal(date)`

---

## 3. Obrazovky a Navigace

### 3.1 Prehled navigace

```
MainScreen (3 taby)
├── Dashboard
│   ├── [existujici] DateSelector, CaloriesCard, RecentlyUploadedCard
│   └── [NOVE] PlanComparisonBanner (pokud existuji plany pro dany den)
│         └── tap → MealPlanScreen (pro dany den)
│
├── Progress
│   └── [NOVE] PlanAdherenceCard (tydeni statistika dodrzovani planu)
│
└── Profile
    └── [NOVE] "Meal Planning" polozka v menu
          └── MealPlanScreen

FAB QuickActions
└── [NOVE] "Plan a Meal" akce → AddPlannedMealFlow
```

### 3.2 MealPlanScreen (hlavni obrazovka planovani)

**Pristup:** Z Dashboard banneru, z Profile menu, nebo z FAB.

```
┌─────────────────────────────────┐
│  ← Meal Plan          [+ Add]  │
├─────────────────────────────────┤
│  ◄ Mon Tue [Wed] Thu Fri ►     │  ← DateSelector (reuse)
├─────────────────────────────────┤
│                                 │
│  📊 Day Summary                │
│  Plan: 1850 kcal               │
│  Actual: 1420 kcal (77%)       │
│  ░░░░░░░░░░░░░░▓▓▓░░          │  ← progress bar
│                                 │
├─────────────────────────────────┤
│  ☀️ Breakfast                   │
│  ┌─────────────────────────┐   │
│  │ Ovsena kase s ovocem    │   │
│  │ 380 kcal · 15P 52C 12F │   │
│  │ [✓ Logged]              │   │  ← zeleny badge = splneno
│  └─────────────────────────┘   │
│                                 │
│  🌤️ Lunch                      │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   │
│  │ Kuřecí salát            │   │  ← daskovany border = planned
│  │ 520 kcal · 42P 28C 22F │   │
│  │ [Log This]  [Skip]      │   │  ← akce
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘   │
│                                 │
│  🌙 Dinner                     │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   │
│  │ Losos s rýží            │   │
│  │ 620 kcal · 38P 55C 24F │   │
│  │ [Log This]  [Skip]      │   │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘   │
│                                 │
│  🍎 Snack                      │
│  + Add snack to plan            │
│                                 │
└─────────────────────────────────┘
```

**Interakce:**
- **Tap na planned meal** → detail s porovnanim (pokud logged) nebo moznost editace
- **"Log This"** → otevre LogPlannedMealSheet (viz 3.4)
- **"Skip"** → oznaci jako preskoceno (sedy badge)
- **"+ Add"** → AddPlannedMealFlow (viz 3.3)
- **Swipe left** na planned meal → smazat z planu
- **Long press** → presunout do jineho dne (drag-to-date)

### 3.3 AddPlannedMealFlow (pridani planovaneho jidla)

**Spusteni:** FAB "Plan a Meal", "+" tlacitko na MealPlanScreen, nebo z meal detail "Plan again".

**Krok 1: Vyber zdroj** (BottomSheet)

```
┌─────────────────────────────────┐
│  Plan a Meal                    │
├─────────────────────────────────┤
│                                 │
│  🕐  From History               │
│  Pick from your past meals      │
│                                 │
│  ⭐  From Favorites             │
│  Your saved favorite meals      │
│                                 │
│  📖  From Recipes               │
│  Browse recipe suggestions      │
│                                 │
│  ✏️  Manual Entry               │
│  Set name and expected macros   │
│                                 │
└─────────────────────────────────┘
```

**Krok 2a: Z historie/oblibenych** → Reuse `SelectMealScreen` s modem "plan"
- Misto `saveMealForDate()` vytvori `PlannedMeal` z vybraneho jidla
- Kopiruje nazev, ingredience (jako `PlannedIngredient`), makra

**Krok 2b: Z receptu** → `RecipeListScreen` (nova, ale jednoducha)
- Seznam receptu z `RecipeService` (rozsirit o dalsi, pripadne AI-generovane)
- Tap na recept → zobrazi detail s makry → "Add to Plan"

**Krok 2c: Manual** → `AddPlannedMealScreen`
- Pole: nazev, meal slot (dropdown), odhadovane makra
- Volitelne: ingredience (rucne zadat)

**Krok 3: Vyber dne a slotu**

```
┌─────────────────────────────────┐
│  When do you plan to eat this?  │
├─────────────────────────────────┤
│  Date: [Wed, Mar 5 ▼]          │
│  Meal: [Lunch ▼]               │
├─────────────────────────────────┤
│  Summary:                       │
│  Kuřecí salát                   │
│  520 kcal · 42P 28C 22F        │
├─────────────────────────────────┤
│  [     Add to Plan     ]        │
└─────────────────────────────────┘
```

### 3.4 LogPlannedMealSheet (zalogovani planovaneho jidla)

**Spusteni:** "Log This" na planned meal karte.

```
┌─────────────────────────────────┐
│  Log: Kuřecí salát              │
│  Planned: 520 kcal              │
├─────────────────────────────────┤
│                                 │
│  📸  Scan Actual Meal           │
│  Take a photo of what you ate   │
│  → AI porovna s planem          │
│                                 │
│  ✅  Log As Planned              │
│  Confirm you ate exactly this   │
│  → Vytvori Meal s planned hodnotami │
│                                 │
│  ✏️  Edit & Log                  │
│  Adjust portions or ingredients │
│  → Pre-fills z planu, uzivatel upravi │
│                                 │
└─────────────────────────────────┘
```

**Flow po zalogovani:**
1. Vytvori se skutecny `Meal` (standardni flow)
2. `PlannedMeal.actualMealId` se nastavi na ID noveho Meal
3. `PlannedMeal.status` se zmeni na `logged`
4. Dashboard i MealPlanScreen se aktualizuji

### 3.5 PlanComparisonBanner (na Dashboard)

Zobrazuje se na Dashboard, pokud pro vybrany den existuji planovana jidla.

```
┌─────────────────────────────────┐
│  📋 Today's Plan: 2/3 meals     │
│  ░░░░░░░░░░░▓▓▓▓▓▓▓░░░░░░     │
│  Plan: 1850 kcal → Actual: 1420 │
│  [View Plan →]                  │
└─────────────────────────────────┘
```

- Kompaktni karta pod DateSelector
- Tap → otevre MealPlanScreen pro dany den
- Skryje se pokud nejsou zadne plany

### 3.6 PlanAdherenceCard (na Progress screenu)

Tydeni/mesicni statistika dodrzovani planu.

```
┌─────────────────────────────────┐
│  📊 Plan Adherence              │
│  This week: 85% · 17/20 meals  │
│                                 │
│  Mon ██████████ 100%            │
│  Tue ████████░░  80%            │
│  Wed ██████░░░░  60%            │
│  Thu ██████████ 100%            │
│  Fri ████████░░  80%            │
│  Sat (no plan)                  │
│  Sun (no plan)                  │
│                                 │
│  Avg deviation: +8% kcal       │
│  Most skipped slot: Snack       │
└─────────────────────────────────┘
```

### 3.7 MealComparisonSheet (detail porovnani)

Otevre se tapnutim na logged planned meal.

```
┌─────────────────────────────────┐
│  Kuřecí salát — Comparison      │
├─────────────────────────────────┤
│            Planned    Actual    │
│  Calories   520       580 (+12%)│
│  Protein    42g       38g (-10%)│
│  Carbs      28g       35g (+25%)│
│  Fat        22g       24g (+9%) │
├─────────────────────────────────┤
│  📷 [Planned photo] [Actual]    │
│                                 │
│  Overall match: 87%             │
│  (zeleny/zluty/cerveny badge)   │
└─────────────────────────────────┘
```

---

## 4. Akce a Gesta

| Misto | Akce | Vysledek |
|-------|------|----------|
| Dashboard | Tap PlanBanner | Otevre MealPlanScreen |
| MealPlanScreen | Tap "Log This" | LogPlannedMealSheet |
| MealPlanScreen | Tap "Skip" | Oznaci jako skipped |
| MealPlanScreen | Tap logged meal | MealComparisonSheet |
| MealPlanScreen | Swipe left | Smazat planned meal |
| MealPlanScreen | Tap "+" | AddPlannedMealFlow |
| FAB | "Plan a Meal" | AddPlannedMealFlow |
| EditMealScreen | "Plan Again" (3-dot menu) | Vytvori plan z tohoto jidla |
| SelectMealScreen | "Plan" mode | Vybere jidlo pro plan misto logu |
| Dashboard meal card | Long press → "Plan for tomorrow" | Rychle naplanovani |

---

## 5. Vizualni Jazyk

### Rozliseni planned vs actual:

| Stav | Vizual |
|------|--------|
| **Planned** (ceka) | Daskovany border, muted barvy, ikona 📋 |
| **Logged** (splneno) | Plny border, zeleny checkmark badge |
| **Skipped** | Sedy preskrtnuty text, ikona ⏭️ |
| **Overdue** (den proshel bez logu) | Oranzovy warning badge |

### Barevne kodovani odchylky:
- **< 10% odchylka** → zelena (skvele dodrzeno)
- **10-25% odchylka** → zluta (mirna odchylka)
- **> 25% odchylka** → cervena (vyrazna odchylka)

---

## 6. Integrace s Existujicimi Featurami

### 6.1 AI Pipeline
- **"Scan Actual Meal"** v LogPlannedMealSheet pouzije standardni `AiPipelineService`
- Po AI analyze se vysledek automaticky spoji s planem
- Moznost: do AI promptu pridat kontext planu ("User planned to eat chicken salad, 520kcal")
  → AI muze lepe odhadnout porce pokud vi co uzivatel zamyslel

### 6.2 Favorites & History
- Oblibena jidla jsou idealni zdroj pro planovani
- `SelectMealScreen` dostane novy mod `SelectionMode.plan`
- Historia se reusne 1:1, jen output jde do `PlannedMeal` misto `Meal`

### 6.3 Nutrition Goals
- MealPlanScreen ukazuje soucet planovanych jidel vs denni cil
- Uzivatel vidi jeste pred zacatkem dne, jestli plan odpovidá cilum
- Warning pokud plan presahuje/nedosahuje cilu

### 6.4 Recipes (RecipeService)
- Rozsirit `RecipeService` o nacitani z DB (uzivatelske recepty)
- Moznost ulozit jakykoli Meal jako recept
- Recepty se zobrazuji v AddPlannedMealFlow

### 6.5 Notifications
- Nova moznost reminderu: "Time to cook your planned lunch: Kuřecí salát"
- Vyuzit existujici `TrackingReminderService`, pridat novy typ

### 6.6 Export (FR-28)
- Pridat sekci "Meal Plans" do PDF/CSV exportu
- Plan vs actual tabulka pro zvolene obdobi

---

## 7. Scope a Prioritizace

### MVP (Minimální implementace pro diplomku):
1. **DB:** `PlannedMeal` + `PlannedIngredient` entity a migrace
2. **MealPlanScreen:** zakladni zobrazeni planu po dnech
3. **AddPlannedMealFlow:** pridani z historie/oblibenych + manual
4. **LogPlannedMealSheet:** "Log As Planned" + "Edit & Log"
5. **PlanComparisonBanner:** jednoduchy banner na Dashboard
6. **Lokalizace:** EN + CS

### Rozsireni (pokud zbyde cas):
7. "Scan Actual Meal" s AI porovnanim
8. PlanAdherenceCard na Progress screenu
9. MealComparisonSheet s detailnim porovnanim
10. Notifikace pro planovana jidla
11. Kopírování planu na dalsi tyden
12. Shopping list generovani z planovanych jidel

### Mimo scope:
- Sdileni planu s jinymi uzivateli
- AI-generovane tydeni plany
- Integrace s externimi recipe API

---

## 8. Technicka Architektura (high-level)

### Nove soubory:

```
lib/
├── database/entities/
│   ├── planned_meal_entity.dart          # Floor entity
│   └── planned_ingredient_entity.dart    # Floor entity
├── database/dao/
│   └── planned_meal_dao.dart             # DAO s CRUD
├── model/
│   ├── planned_meal.dart                 # Domain model
│   ├── planned_ingredient.dart           # Domain model
│   └── meal_comparison.dart              # Porovnavaci model
├── services/
│   └── meal_plan_repository.dart         # Aggregate repo (jako DayRecordRepository)
├── controller/
│   └── meal_plan_controller.dart         # GetxController pro UI state
├── screens/
│   └── meal_plan/
│       ├── meal_plan_screen.dart          # Hlavni obrazovka
│       ├── add_planned_meal_screen.dart   # Pridani planu
│       └── meal_plan_widgets.dart         # Sdilene widgety (karta, banner, comparison)
└── widgets/
    ├── plan_comparison_banner.dart        # Dashboard banner
    └── plan_adherence_card.dart           # Progress card
```

### Registrace:
- `MealPlanRepository` → `Get.lazyPut()` v `locator.dart`
- `MealPlanController` → `Get.lazyPut()` v `locator.dart`
- DAO registrace v `AppDatabase`

### Reaktivita:
- `MealPlanController` posloucha `SelectedDateService.selectedDate`
- Pri zmene data nacte planovana jidla pro dany den
- Dashboard naslouchá `MealPlanController` pro zobrazeni banneru

---

## 9. User Stories (pro validaci)

1. **Jako uzivatel chci naplánovat obed na zitra z mych oblibenych jidel,**
   abych vedel co nakoupit a kolik kalorii ocekavat.

2. **Jako uzivatel chci ráno videt prehled dnesniho planu na dashboardu,**
   abych vedel co me ceka a jak to odpovida mym cilum.

3. **Jako uzivatel chci po obede potvrdit "jedl jsem podle planu",**
   abych nemusel znovu zadavat vsechny ingredience.

4. **Jako uzivatel chci vyfotit skutecny talic a porovnat s planem,**
   abych videl jak moc se lisil od zameru.

5. **Jako uzivatel chci videt tydeni statistiku dodrzovani planu,**
   abych mohl zlepsit svou disciplinu.

6. **Jako uzivatel chci preskocit planovane jidlo bez pocitu viny,**
   protoze plan je doporuceni, ne povinnost.
