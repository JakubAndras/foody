# Plan: Home Screen Widgets pro Flutter aplikaci `diplomka`

## Kontext
- V projektu už existuje vizuální preview widgetů v profilu (`_WidgetSection` v `/Users/jakubandras/StudioProjects/diplomka/lib/screens/profile/profile_screen.dart`), ale je zatím statické (dummy data).
- Cíl je doplnit skutečnou Home Screen Widgets funkcionalitu pro iOS + Android, ideálně přes Flutter package.
- Tento dokument je pouze návrh řešení a plán. Neobsahuje implementaci.

## Krátké shrnutí doporučení
- Doporučená varianta: `home_widget` jako hlavní cross-platform package.
- Důvod: aktivně udržovaný, podporuje Android i iOS, řeší data bridge mezi Flutter a nativní widget vrstvou, podporuje i deep-link akce po kliknutí na widget.
- Důležité: i s package je nutné vytvořit nativní část widgetu (iOS Widget Extension, Android AppWidget provider/layout).
- Praktické rozhodnutí pro tento projekt: Flutter je zdroj dat a logiky, nativní widget vrstva je renderer.

## Diplomková argumentace (kritéria výběru)
- Řešení hodnotit podle kritérií:
  - vývojové náklady,
  - udržovatelnost,
  - UX kvalita,
  - limity OS (refresh a background policy),
  - konzistence mezi platformami.
- Pro obhajobu explicitně porovnat:
  - `home_widget` jako pragmatický kompromis,
  - čistě nativní přístup jako overkill pro scope,
  - snapshot-only přístup jako kompromis s omezenou interaktivitou.
- Doporučené metriky do výsledků práce:
  - latence od změny dat v appce do zobrazení ve widgetu,
  - konzistence dat app vs widget,
  - objem nativního kódu vs Flutter kódu.

## Analýza možností

### Varianta A: `home_widget` (doporučeno)
**Co to řeší**
- Sdílení dat mezi Flutter app a widgetem.
- Trigger aktualizace widgetu z Flutteru.
- Routing kliknutí z widgetu zpět do aplikace.

**Plusy**
- Jeden hlavní package pro obě platformy.
- Nejlepší poměr rychlost implementace vs. kvalita.
- Aktivní vývoj (latest `0.8.1`, publikováno 2026-01-09).

**Mínusy**
- Pořád je potřeba nativní UI widgetu.
- iOS vyžaduje App Group + Widget Extension.
- Android vyžaduje AppWidget provider a receiver.

### Varianta B: `home_widget` + render Flutter widgetu do bitmapy (pro rychlé vizuální MVP)
**Co to řeší**
- Umí vykreslit Flutter widget do obrázku a ten použít v nativním widgetu.

**Plusy**
- Rychlé dosažení vizuální parity s preview.
- Menší komplexita nativního layoutu v první fázi.

**Mínusy**
- Spíš statický snapshot model.
- Omezená interaktivita a potenciálně horší škálování/čitelnost.
- Stále nutná nativní obálka widgetu.

### Varianta C: `widgetkit` package (iOS-only) + vlastní Android stack
**Plusy**
- Na iOS přímá orientace na WidgetKit.

**Mínusy**
- Není cross-platform.
- Rozdělená implementace (vyšší maintenance).
- Verze je méně čerstvá (`1.1.0`, publikováno 2025-04-09).

### Varianta D: čistě nativně bez Flutter package
**Plusy**
- Maximální kontrola.

**Mínusy**
- Nejvyšší náklady a pomalejší delivery.
- Dva odlišné nativní implementační proudy.

## Platformní limity a důsledky návrhu

### Android
- Periodické update přes `updatePeriodMillis` má minimálně 30 minut.
- Praktický důsledek: časté změny (např. po každém logu jídla) je lepší pushovat okamžitě z appky, ne čekat na periodický refresh.

### iOS
- Aktualizace widgetu přes WidgetKit timeline/background nejsou striktně garantované v přesném čase.
- Praktický důsledek: návrh musí počítat s eventual consistency (data mohou být krátce zpožděná).

## Návrh cílové architektury (MVP)

### 1) Widget Data Contract (verzovaný)
- Zavést jednotný, verzovaný kontrakt dat (JSON), který čte widget.
- Doporučené pole:
  - `schemaVersion`
  - `caloriesToday`, `caloriesGoal`
  - `proteinToday`, `proteinGoal`
  - `carbsToday`, `carbsGoal`
  - `fatToday`, `fatGoal`
  - `progress` (0..1)
  - `lastUpdatedAt`
  - `quickActions` (seznam deep-link akcí)
- Datový zápis dělat atomicky jako jednu JSON hodnotu (ne rozděleně přes více klíčů), aby se minimalizoval nesoulad dat.
- Kontrakt popsat i s migračním pravidlem mezi verzemi (`schemaVersion`), což je důležité pro robustnost.

### 2) Widget Sync Service
- Jedno místo, které:
  - načte/transformuje data z domény,
  - uloží data do storage přes `home_widget` jako atomický JSON payload,
  - zavolá refresh konkrétních widget providerů.

### 3) Update strategie (event-driven default)
- Primární strategie: event-driven refresh.
- Trigger body synchronizace:
  - po uložení jídla,
  - po editaci/smazání jídla,
  - po změně denního cíle,
  - po synchronizaci dat (pokud je dostupná),
  - při startu appky / návratu do foreground.
- Background periodický refresh je volitelná optimalizace (např. `workmanager`), ne základní mechanismus.
- Dokumentovat, že refresh je požadavek na OS, ne garantovaný okamžitý příkaz.

### 4) Widget Action Router (deep-link akce)
- Zavést jednotný router pro widget akce, aby byla logika centralizovaná.
- Definovat konzistentní URI schéma, např.:
  - `diplomka://widget/open_dashboard`
  - `diplomka://widget/scan_food`
  - `diplomka://widget/scan_barcode`
- V app routeru mapovat URI na existující flow (`ScanCameraScreen`, dashboard).

### 5) MVP UX scope
- `1x` velký Nutrition widget:
  - kalorie progress + makra,
  - text `Updated X min ago` podle `lastUpdatedAt`.
- `2x` small shortcut widget:
  - `Scan Food`,
  - `Barcode`.
- Layout držet na jasných breakpointech (small/medium/large), nepřidávat zbytečnou variabilitu v MVP.

## Doporučený postup (fázovaný)

### Fáze 0: rozhodnutí a scope freeze
- Potvrdit cílové widget family (small/medium/large) pro iOS i Android.
- Potvrdit datový rozsah pro MVP (jen dnešní agregace vs. i další metriky).

### Fáze 1: technický základ (`home_widget`)
- Přidat package a minimální bridge.
- Připravit iOS App Group a Widget Extension.
- Připravit Android AppWidget provider + základní layout.

### Fáze 2: datová pipeline
- Implementovat verzovaný `Widget Data Contract` + `WidgetSyncService`.
- Napojit synchronizaci na klíčové business eventy.
- Zavést atomický zápis JSON payloadu.

### Fáze 3: interakce
- Přidat deep-link handling po kliknutí na widget.
- Zavést jednotný `Widget Action Router`.
- Napojit quick actions na existující obrazovky.

### Fáze 4: kvalita
- Ověřit update chování na reálných zařízeních.
- Otestovat edge cases (offline, prázdná data, cold start).

## Rizika
- iOS update cadence není plně deterministická.
- Android OEM launchery mohou mít specifika v refresh chování.
- Duplicita logiky mezi widget UI a in-app preview bez sdíleného mapping layeru.
- Nesoulad dat mezi app a widgetem při dílčích updatech více klíčů.
- Rozpad navigace, pokud budou deep-link akce roztroušené po kódu.

## Mitigace rizik
- Ukládat data atomicky jako jeden JSON payload + `lastUpdatedAt`.
- Widget refresh vždy považovat za best-effort (request), ne hard-garantovaný update.
- Držet omezený počet layout breakpointů (small/medium/large).
- Použít centrální `Widget Action Router` pro všechny akce z widgetu.

## Co doporučuji potvrdit před implementací
1. MVP widget set: `1x nutrition summary + 2x shortcut` (scan/barcode)?
2. Má widget vždy zobrazovat dnešní den, nebo aktuálně vybraný den v appce?
3. Chceme už v MVP background periodic refresh (např. přes `workmanager`), nebo jen event-driven refresh z appky?
4. Priorita interaktivity: jen tap-to-open, nebo i pokročilé interaktivní prvky (hlavně iOS 17+)?

## Poznámka ke stavu repozitáře
- `mobile_scanner` už je v projektu přítomný, ale Home Screen Widgets infrastruktura v `ios`/`android` zatím chybí.

## Finální pragmatické doporučení
- Jít cestou `home_widget` jako základ.
- Postavit verzovaný data contract (`JSON + schemaVersion`).
- Začít event-driven refresh, background řešit až jako optimalizaci.
- MVP scope držet úzký: `1x` velký nutrition widget + `2x` small shortcut widgety.

## Zdroje
- `home_widget` package: https://pub.dev/packages/home_widget
- `home_widget` docs (setup/advanced/interactive): https://docs.page/ABausG/home_widget
- `home_widget` API metadata (latest version/published): https://pub.dev/api/packages/home_widget
- Android App Widgets overview (update constraints): https://developer.android.com/develop/ui/views/appwidgets/overview
- `widgetkit` package (alternativa): https://pub.dev/packages/widgetkit
- `widgetkit` API metadata: https://pub.dev/api/packages/widgetkit
- `flutter_widgetkit` package (starší alternativa): https://pub.dev/packages/flutter_widgetkit
- `flutter_widgetkit` API metadata: https://pub.dev/api/packages/flutter_widgetkit
- `workmanager` package (volitelně pro background refresh): https://pub.dev/packages/workmanager
- `workmanager` API metadata: https://pub.dev/api/packages/workmanager
