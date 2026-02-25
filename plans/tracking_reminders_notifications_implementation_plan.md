# Implementacni plan: Tracking Reminders (lokalni notifikace)

## Kontext a cil
- Obrazovka `lib/screens/profile/subscreens/tracking_reminders_screen.dart` je ted staticka (hardcoded casy + on/off stav).
- Cilem je, aby si uzivatel mohl pro jednotlive reminder typy zapnout/vypnout notifikaci a nastavit cas.
- Notifikace maji fungovat jako denni "budik" (opakovana lokalni notifikace v konkretnim case).

## Doporucene reseni (Flutter package)
- Primarni package: `flutter_local_notifications`
- Doplnek pro casove zony: `timezone`
- Duvod:
  - stabilni cross-platform stack pro Android + iOS,
  - umi planovane opakovane notifikace,
  - funguje offline (neni potreba backend),
  - dobre sedi na aktualni architekturu (GetX services + SharedPreferences).

## MVP scope
- Reminder typy:
  - Breakfast
  - Lunch
  - Snack
  - Dinner
  - End of Day
- Funkce:
  - zapnout/vypnout reminder,
  - zmenit cas reminderu,
  - persistovat nastaveni lokalne,
  - po zmene ihned preschedulovat notifikaci,
  - obnovit scheduly po startu appky.
- Out of scope (pro prvni verzi):
  - server sync reminderu,
  - chytre adaptivni reminder logika,
  - A/B texty notifikaci,
  - pokrocile analytics eventy.

## Navrh architektury

### 1) Domenny model reminderu
Pridat model pro jednu reminder polozku (napr. `TrackingReminderSetting`):
- `type` (enum: breakfast/lunch/snack/dinner/endOfDay)
- `enabled` (bool)
- `hour` (int)
- `minute` (int)
- odvozene:
  - `notificationId` (stabilni int podle typu)
  - `title` a `body` notifikace (lokalizovatelne texty)

Doporucene `notificationId` mapovani:
- breakfast: `2001`
- lunch: `2002`
- snack: `2003`
- dinner: `2004`
- endOfDay: `2005`

### 2) Persistencni vrstva
Rozsirit `lib/services/shared_preferences_manager.dart` o nove keys + helpery:
- `trackingReminder_<type>_enabled`
- `trackingReminder_<type>_hour`
- `trackingReminder_<type>_minute`

Poznamka:
- Cas ukladat jako `hour/minute` (ne string), at je jednoducha migrace a schedule vypocet.

### 3) Notification service
Vytvorit novou sluzbu, napr. `lib/services/tracking_reminder_service.dart`:
- `initialize()`
  - init pluginu,
  - init timezone,
  - pripravit notification channels (Android).
- `requestPermissionIfNeeded()`
  - Android 13+ notifikacni permission,
  - iOS alert/sound/badge permission.
- `scheduleReminder(TrackingReminderSetting setting)`
  - denni schedule v lokalnim timezone,
  - pokud je cas dnes uz v minulosti, naplanovat na dalsi den.
- `cancelReminder(TrackingReminderType type)`
- `rescheduleAllFromStorage()`
  - pri startu appky nacist ulozena nastaveni a znovu je aplikovat.

### 4) Controller pro screen
Doporucene vytvorit `TrackingRemindersController` (GetX), aby UI nebylo stateful ad-hoc:
- drzi list reminderu jako `RxList<TrackingReminderSetting>`
- use-cases:
  - `toggleReminder(type, enabled)`
  - `changeReminderTime(type, timeOfDay)`
  - `loadInitialState()`
- Orchestrace:
  - update local state
  - persist do SharedPreferences
  - schedule/cancel v `TrackingReminderService`

### 5) UI integrace (`tracking_reminders_screen.dart`)
- Nahradit hardcoded data realnym stavem z controlleru.
- `_ReminderRow` doplnit callbacky:
  - `onToggle`
  - `onTimeTap`
- `ProfileTimeChip` otevira `showTimePicker`.
- Pokud uzivatel notifikace nepovoli:
  - zobrazit nenasilny inline hint (napr. text pod kartou),
  - nabidnout otevreni system settings (`permission_handler`).

### 6) App init a DI
- V `lib/locator.dart` zaregistrovat novou service + controller.
- V `lib/main.dart` po `setupServices()` zavolat init reminder service a `rescheduleAllFromStorage()`.
- Zachovat poradi:
  - plugin init
  - permission check
  - schedule restore

## Platformni pozadavky

### Android
- Overit/pridat:
  - `POST_NOTIFICATIONS` (Android 13+)
  - `RECEIVE_BOOT_COMPLETED` (pokud bude potreba explicitni reschedule po rebootu)
- Vytvorit kanal, napr.:
  - id: `tracking_reminders`
  - importance: high
- Rozhodnuti pro presnost:
  - MVP doporuceni: zacit bez specialniho exact alarm permission flow.
  - Pokud bude pozadavek na striktni "na minutu" chovani, pridat navazujici fazi s exact alarm strategii.

### iOS
- Pozadat o notification permission pri prvnim pouziti reminderu.
- Overit, ze initialization probiha vcas (pred prvnim schedulovanim).
- Neni potreba backend ani APNs, jde o local notifications.

## Lokalizace
- Pridat prekladove klice do `assets/translations/cs.json` a `assets/translations/en.json`:
  - nazvy reminderu,
  - title/body notifikaci,
  - permission/help texty na screen.
- Neponechavat natvrdo v kodu.

## Implementacni sekvence (doporuceno)
1. Pridat package dependency (`flutter_local_notifications`, `timezone`) a stahnout balicky.
2. Implementovat `TrackingReminderSetting` + enum + ID mapovani.
3. Rozsirit `SharedPreferencesService` o keys a helper metody pro reminder nastaveni.
4. Implementovat `TrackingReminderService` (init, permission, schedule/cancel, rescheduleAll).
5. Zalozit `TrackingRemindersController` a napojit use-cases.
6. Predelat `tracking_reminders_screen.dart` z hardcoded na reactive data.
7. Dopsat Android/iOS konfiguraci.
8. Dopsat lokalizace.
9. Otestovat edge-cases + manual QA.

## Test plan

### Unit testy
- mapovani `TrackingReminderType -> notificationId` je stabilni,
- vypocet dalsiho trigger casu (dnes/zitra),
- persist/load reminder nastaveni ze SharedPreferences.

### Widget testy
- toggle meni vizualni stav a vola controller,
- klik na cas otevre picker a ulozi novy cas,
- disabled reminder nevytvari schedule.

### Manual QA
- Android/iOS: prvni zapnuti reminderu vyzada permission,
- po zmene casu dorazi notifikace v nove nastavenem case,
- vypnuti reminderu zrusi notifikaci,
- restart appky zachova nastaveni,
- kombinace vice reminderu ve stejnem case funguje bez kolizi,
- odmitnuta permission -> UX fallback (hint + open settings).

## Rizika a mitigace
- Riziko: rozpad schedule po restartu/system update.
  - Mitigace: `rescheduleAllFromStorage()` pri app init + volitelne boot handling.
- Riziko: casove posuny (DST/timezone zmena).
  - Mitigace: schedule pres `timezone` a local location.
- Riziko: uzivatel odmitne permission.
  - Mitigace: graceful fallback + navod na zapnuti v system settings.

## Definition of Done (MVP)
- Tracking reminders screen pracuje s realnym stavem (ne hardcoded).
- Uzivatel umi pro kazdy reminder zapnout/vypnout notifikaci a nastavit cas.
- Nastaveni prezije restart aplikace.
- Aktivni reminders generuji denni lokalni notifikace.
- Zmeny stavu (toggle/time) se projevi okamzite v schedule.
- Zakladni unit/widget testy pro reminder flow prochazi.

## Dotcene soubory (predbezne)
- `pubspec.yaml`
- `lib/screens/profile/subscreens/tracking_reminders_screen.dart`
- `lib/services/shared_preferences_manager.dart`
- `lib/locator.dart`
- `lib/main.dart`
- `assets/translations/cs.json`
- `assets/translations/en.json`
- nove soubory:
  - `lib/model/tracking_reminder_setting.dart`
  - `lib/services/tracking_reminder_service.dart`
  - `lib/controller/tracking_reminders_controller.dart`
- platform config dle potreby:
  - `android/app/src/main/AndroidManifest.xml`
  - iOS init/config soubory (pokud budou vyzadovany pluginem)
