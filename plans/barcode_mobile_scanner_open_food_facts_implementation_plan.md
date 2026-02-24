# Implementacni plan: Barcode skenovani pres kameru (Flutter)

## Kontext a cil
Tento plan navrhuje implementaci barcode rozpoznani v aplikaci `diplomka` v 2 fazich:

- Faze 1 (hlavni): on-device scanner (`mobile_scanner`) + lookup produktu pres free API (`Open Food Facts`).
- Faze 2 (volitelna): lokalni cache / lokalni DB pro rychle opakovane skeny a lepsi offline UX.

Plan je navrzen pro existujici stack v projektu: Flutter + GetX + Dio + Floor.

## Proc tato kombinace
- `mobile_scanner` poskytuje rychly a robustni barcode/QR scan primo v zariadeni (on-device), bez potreby backendu.
- Open Food Facts (OFF) je zdarma a ma dostupny public API pro lookup podle EAN/UPC/GTIN.
- Kombinace ma nizke naklady, rychly time-to-market a dostatecnou kvalitu pro MVP.

## Scope
### In scope (Faze 1)
- Skenovani barcodu z kamery.
- Detekce podporovanych kodu (EAN-13, EAN-8, UPC-A, UPC-E, pripadne Code-128).
- Lookup produktu pres OFF API.
- Zobrazeni vysledku + navrh predvyplneni jidla/ingredience.
- Error flow pro neznamy barcode, timeout, bez internetu.

### Out of scope (Faze 1)
- Persistovana lokalni cache produktu.
- Vlastni centralni produktova DB.
- Komercni barcode SDK.

### In scope (Faze 2, volitelne)
- Lokalni cache lookup vysledku podle barcodu.
- TTL, invalidace a fallback strategie.

## Technicky navrh (Faze 1)

### 1) Architektura vrstvy
Navrh modulu:

- UI:
  - `ScanCameraScreen` (existuje) rozsireny o realny barcode scan flow.
  - novy `BarcodeResultSheet` nebo `BarcodeProductPreviewScreen`.
- Controller:
  - novy `BarcodeScanController` (GetX) pro stav skenu a lookup pipeline.
- Services:
  - `OpenFoodFactsClient` (Dio klient pro OFF endpointy).
  - `BarcodeLookupService` (mapovani API modelu na app model).
- Modely:
  - `OffProductDto`, `OffNutrimentsDto`.
  - `BarcodeLookupResult` (domain model pro UI).

Dulezite: scanner vrstva a API vrstva budou oddelene, aby slo pozdeji OFF snadno nahradit jinym zdrojem.

### 2) Zavislosti
Do `pubspec.yaml`:

- pridat `mobile_scanner` (stabilni release kompatibilni s Flutter SDK projektu).
- `dio` uz je v projektu, pouzit pro OFF klienta.

Poznamka: novou knihovnu drzet izolovane v barcode feature; nepropagovat ji do cele appky.

### 3) Platformni setup (kamera)
Android:
- overit `CAMERA` permission v `AndroidManifest.xml`.
- overit minSdk/gradle kompatibilitu s verzi `mobile_scanner`.

iOS:
- overit `NSCameraUsageDescription` v `Info.plist`.
- text permission promptu musi jasne rict hodnotu pro uzivatele (napr. rychle nacitani nutri dat z obalu).

### 4) Scanner flow (UX + rychlost)
Cil: uzivatel namiri kod a bez klikani se provede lookup.

Navrh:
- V `ScanMode.barcode` renderovat `MobileScanner` preview misto capture flow z `camera`.
- Pri prvni validni detekci:
  - scanner kratce pozastavit (`isProcessing = true`),
  - hapticka odezva,
  - zobrazit loading stav "Hledam produkt...".
- Duplicity:
  - ignorovat stejny barcode po dobu napr. 2-3 sekund (debounce).
  - ignorovat dalsi eventy, dokud neskonci lookup.
- Pokud lookup skonci:
  - success: zobrazit produkt preview + CTA "Pouzit", "Skenovat znovu".
  - not found: nabidnout manualni zadani.
  - chyba site: nabidnout retry.

UX pravidla:
- max 1 tap pro navazujici akci po uspesnem scanu.
- jasna vizualni signalizace "skenuji" vs "nacitam data".
- zadne blokujici dialogy, pokud neni potreba.

### 5) OFF API integrace (free)
Doporuceny endpoint (lookup podle barcodu):
- `GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json`

Doporuceni pro request:
- timeout 5-8 s,
- User-Agent ve formatu app identifikace (nazev/verze/kontakt),
- optional `fields` parametr pro mensi payload (jen potrebna pole).

Minimalni pole pro MVP:
- `code`
- `product_name`
- `brands`
- `quantity`
- `image_front_url` nebo `image_url`
- `nutriments` (kcal/proteiny/sacharidy/tuky; idealne per 100g)

Mapovani do app:
- nazev produktu -> default nazev ingredience/meal item
- nutriments per 100g -> predvyplnit nutritional values
- pokud chybi nutriments -> oznacit jako "chybi vyzivova data", ale stale dovolit ulozeni

Poznamka k cenam/licenci:
- OFF API je free/public, ale muze byt omezeno fair-use.
- Pro appku je vhodne drzet requesty usporne (debounce, pozdeji cache).

### 6) Stavovy model (Controller)
Stavy:
- `idle`
- `scanning`
- `lookupLoading(barcode)`
- `lookupSuccess(result)`
- `lookupNotFound(barcode)`
- `lookupError(type)`

Error typy:
- `networkUnavailable`
- `timeout`
- `apiError`
- `invalidBarcode`
- `parseError`

Controller odpovednosti:
- barcode validation/sanitization (digits only, validni delky),
- anti-duplicate throttling,
- rizeni scanner pause/resume,
- volani lookup service,
- predani vysledku do existujiciho flow (Edit Meal / Ingredient).

### 7) Integrace do aktualniho kodu
Predbezne touchpointy:
- `/Users/jakubandras/StudioProjects/diplomka/lib/screens/scan/scan_camera_screen.dart`
- `/Users/jakubandras/StudioProjects/diplomka/lib/locator.dart`
- `/Users/jakubandras/StudioProjects/diplomka/lib/network/` (novy OFF klient)
- `/Users/jakubandras/StudioProjects/diplomka/lib/controller/` nebo `/lib/services/` (novy barcode controller/service)

Strategie integrace:
- zachovat stavajici `ScanMode` UX (Meal / Barcode / Food label),
- barcode mode prepnout na event-driven scan, ne na shutter fotku,
- meal/photo mode nechat bez zmen.

### 8) Bezpecnost a privacy
- Neposilat do OFF zadne osobni udaje.
- OFF dotaz obsahuje jen barcode.
- Logovani:
  - v produkci nelogovat plne response body,
  - logovat pouze technicke metadata (status, latence, typ chyby).
- Overit pouze HTTPS endpointy.
- Input hardening:
  - validovat barcode format pred requestem,
  - ochrana proti extrahovanym/invalidnim hodnotam z OCR/scanner noise.

### 9) Vykon a stabilita
- Lookup volat az po stabilni detekci (1 barcode, ne stream requestu).
- Pouzit request cancellation pri opusteni obrazovky.
- Osetrit lifecycle:
  - app background -> pause scanner,
  - resume -> obnovit scanner.
- Budget:
  - do 250 ms odezva UI po detekci kodu,
  - do 2 s median lookup (zavisle na siti),
  - graceful timeout do 8 s.

### 10) Test plan (Faze 1)
Unit testy:
- barcode validator (valid/invalid delky a znaky),
- mapovani OFF response -> `BarcodeLookupResult`,
- error mapping (404/not found vs timeout vs no internet).

Widget testy:
- prechod stavu scanning -> loading -> success,
- not found a retry flow,
- disabled action pri aktivnim lookupu.

Manual QA:
- ruzne typy kodu (EAN-13, UPC-A),
- slabe svetlo, odlesky, cast kodu mimo frame,
- offline/airplane mode,
- pomale pripojeni.

## Faze 1 - implementacni postup po krocich

1. Pridat `mobile_scanner` zavislost a platformni permission check.
2. Vytvorit `OpenFoodFactsClient` + DTO + parsing testy.
3. Vytvorit `BarcodeLookupService` + domain model.
4. Vytvorit `BarcodeScanController` (stavy, throttle, pause/resume).
5. Napojit `ScanMode.barcode` v `ScanCameraScreen` na live scanner.
6. Pridat result UI (sheet/screen) a navazani na meal/ingredient flow.
7. Dopsat error UX (not found, timeout, no internet).
8. Dopsat unit/widget testy a manual QA checklist.
9. Internal rollout + telemetry overeni.

## Faze 2 (volitelna): Lokalni cache / lokalni DB

### Cile
- Zrychlit opakovane lookupy.
- Omezit sitove volani na OFF.
- Zlepsit UX pri horsi konektivite.

### Varianty
Varianta A (rychla):
- In-memory LRU cache (jen behem behu appky).
- Plus: minimum prace.
- Minus: po restartu appky nulovy efekt.

Varianta B (doporucena):
- Persistovana cache ve Floor DB (`cached_products` tabulka).
- Plus: efekt i po restartu, lepsi offline experience.
- Minus: migration + sprava TTL.

### Doporuceny schema navrh (Floor)
Tabulka `cached_products`:
- `barcode` TEXT PRIMARY KEY
- `productName` TEXT
- `brand` TEXT
- `nutrimentsJson` TEXT
- `imageUrl` TEXT
- `source` TEXT (`off`)
- `updatedAt` INTEGER (epoch ms)
- `expiresAt` INTEGER (epoch ms)

### Cache strategie
- Read-through:
  - nejdriv cache,
  - pokud hit a neexpiruje -> vratit hned.
  - zaroven volitelne background refresh (stale-while-revalidate).
- TTL:
  - vychozi 7-30 dni (doporuceni: 14 dni).
- Miss/expired:
  - dotaz na OFF, ulozit vysledek do cache.

### UX ve fazi 2
- pri cache hitu zobrazit vysledek okamzite.
- pokud je offline a cache existuje -> zobrazit cached data + badge "offline data".
- pokud offline a cache neexistuje -> manual fallback flow.

### Kdy fazi 2 spustit
- po stabilizaci faze 1
- idealne kdyz telemetry ukaze:
  - vysoky pocet opakovanych scanu stejnych kodu,
  - casta sitova latence/timeout.

## Observabilita a metriky
Metriky pro rozhodovani:
- `barcode_scan_detected`
- `barcode_lookup_success`
- `barcode_lookup_not_found`
- `barcode_lookup_error`
- `barcode_time_to_result_ms`
- (Faze 2) `barcode_cache_hit_ratio`

Cile:
- success rate lookup > 85 % pro bezne produkty.
- median time-to-result < 2 s.

## Rizika a mitigace
- Riziko: OFF data nekompletni nebo chybejici nutriments.
  - Mitigace: robustni fallback + manual edit.
- Riziko: prilis requestu pri opakovane detekci.
  - Mitigace: throttle, scanner pause, pozdeji cache.
- Riziko: ruzne quality barcode ve spatnem svetle.
  - Mitigace: scan hinty, frame guidance, retry UX.

## Definition of Done

### DoD - Faze 1
- Barcode jde skenovat bez shutter tlacitka v `ScanMode.barcode`.
- Pri validnim barcode probehne OFF lookup.
- Success/not found/error maji oddelene a jasne UX.
- Uzivatel muze vysledek potvrdit a pokracovat do meal flow.
- Zakladni unit + widget testy pro scanner pipeline jsou zelene.

### DoD - Faze 2 (volitelne)
- Lookup nejdriv sahne do cache.
- Cache ma TTL a je pokryta testy.
- Opakovane skeny jsou citelne rychlejsi.
- Offline s cache funguje degradovane, ale pouzitelne.

## Rozhodnuti pred implementaci
- Potvrdit, ze MVP podporuje primarne EAN-13 + UPC-A.
- Potvrdit, zda result UI bude bottom sheet nebo full screen.
- Potvrdit, zda ve fazi 1 chceme rovnou telemetry eventy.
- Potvrdit TTL navrh pro fazi 2 (doporuceno 14 dni).

## Reference (official docs)
- mobile_scanner (Flutter): https://pub.dev/packages/mobile_scanner
- Open Food Facts Product API v2: https://openfoodfacts.github.io/openfoodfacts-server/api/ref-v2/#get-/api/v2/product/-barcode-
- Open Food Facts API tutorial: https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
