# Implementacni plan: Voice Log pres `speech_to_text` (MVP)

## Kontext a cil
Cilem je dokoncit funkcionalitu `Voice Log` tak, aby uzivatel mohl:

- nadiktovat jidlo nebo cviceni,
- videt prepis v textovem poli,
- spustit AI analyzu,
- potvrdit vysledek.

MVP ma vyuzit Flutter package `speech_to_text` a maximalne znovupouzit existujici architekturu (GetX + `AiPipelineService` + soucasne UI flow).

## Rozhodnuti pro MVP
- Primarni STT vrstva: `speech_to_text`.
- Meal flow: napojit na existujici text-only AI analyzu.
- Exercise flow: AI parse textu do struktury a predvyplneni formulare.
- Platform hardening:
  - iOS: pridat `NSpeechRecognitionUsageDescription`.
  - Android: overit `RECORD_AUDIO` + pripadne doplnit `RecognitionService` query.
- Lokalizace STT:
  - preferovat `cs-CZ` a `en-US`,
  - fallback na locale zarizeni / system default.

## Scope
### In scope (MVP)
- Live speech-to-text do `VoiceLogScreen`.
- Stavy `listening / paused / error / permission denied`.
- Analyza jidla z prepisu (text prompt).
- Analyza cviceni z prepisu do struktury:
  - `name`,
  - `durationMinutes`,
  - `caloriesTotal` nebo `caloriesPerMinute`.
- Predvyplneni `AddExerciseScreen` a uzivatelske potvrzeni.

### Out of scope (MVP)
- Dlouhe asynchronni prepisy audio souboru pres cloud STT.
- Offline STT modely.
- Finalni perzistence exercise logu do DB (pokud nebude navazovat existujici datovy model).
- Pokrocila telemetry/analytics vrstva.

## Aktualni stav v projektu
- `VoiceLogScreen` uz umi:
  - request mikrofon permission,
  - start/stop/pause recording pres `record`,
  - manualni text input.
- Analyze tlacitko zatim nevola realnou AI pipeline.
- Meal AI pipeline uz umi text prompt (`AiPipelineService.analyzeMeal(description: ...)`).
- Exercise flow je zatim hlavne UI a bez robustniho datoveho napojeni.

## Navrh architektury

### 1) STT vrstva
Vytvorit lehkou servisni vrstvu nad `speech_to_text`, aby UI nebylo primo zavisle na plugin API.

Navrh odpovednosti:
- init pluginu a detekce supportu.
- start/stop/pause/listen lifecycle.
- stream partial + final transcriptu.
- mapovani chyb pluginu na app-level chyby.
- locale vyber podle app/device jazyka.

Doporucene soubory:
- `lib/services/voice/voice_transcription_service.dart`
- `lib/model/voice/voice_transcription_state.dart` (nebo enum + DTO)

### 2) VoiceLogScreen integrace
`VoiceLogScreen` zustane hlavni orchestrace UI:
- mikrofon button spousti/ukoncuje STT (ne pouze audio recording),
- text area se plni live prepisem,
- manualni edit textu zustava mozny,
- Analyze tlacitko podle rezimu:
  - Meals: vola meal AI pipeline,
  - Exercise: vola exercise AI parse pipeline.

Poznamka:
- `record` muzeme v MVP ponechat jako fallback nebo docasne odstranit z VoiceLog flow.
- V prve iteraci doporuceno drzet pouze jeden aktivni mechanismus (STT), aby se nemichaly stavy.

### 3) Meal analyze flow (text-only)
Znovupouzit existujici pipeline:
- vstup: `description = transcript`.
- volani: `AiPipelineService.analyzeMeal(description: description)`.
- pri success:
  - ulozit meal do vybraneho dne pres existujici controller flow,
  - zavrit VoiceLog / ukazat potvrzeni.
- pri low confidence:
  - zobrazit varovani, ale umoznit pokracovat.
- pri failure:
  - zobrazit retry/error message.

### 4) Exercise parse flow
Pridat oddeleny AI parse use-case, protoze stavajici schema je meal-specific.

Navrh:
- novy prompt `analyzeExerciseFromText`.
- novy response model pro cviceni.
- validace:
  - jmeno cviceni je povinne,
  - musi byt znamo bud `caloriesTotal`, nebo kombinace `caloriesPerMinute + durationMinutes`.

Doporucene schema vystupu:
- `valid: bool`
- `answer: { name, duration_minutes, calories_total, calories_per_minute, confidence }`

Vyuziti:
- po uspesnem parse otevrit `AddExerciseScreen` s predvyplnenim.
- uzivatel data upravi/potvrdi tlacitkem `Add Exercise`.

### 5) Predvyplneni AddExerciseScreen
Rozsirit konstruktor `AddExerciseScreen`:
- `initialName`
- `initialDurationMinutes`
- `initialCaloriesTotal`
- `initialCaloriesPerMinute`
- `initialTrackingMode` (`total` vs `perMinute`)

Pravidlo mapovani:
- pokud existuje `caloriesTotal` => mode `total`.
- pokud chybi `caloriesTotal`, ale existuje `caloriesPerMinute` a `durationMinutes` => mode `perMinute`.

## Platformni a permission hardening

### iOS
V `ios/Runner/Info.plist` doplnit:
- `NSpeechRecognitionUsageDescription`

`NSMicrophoneUsageDescription` uz v projektu je.

### Android
V `android/app/src/main/AndroidManifest.xml`:
- `RECORD_AUDIO` uz je pritomny.
- overit kompatibilitu s `speech_to_text`.
- podle potreby doplnit `<queries>` pro `android.speech.RecognitionService` kvuli kompatibilite nekterych zarizeni.

## Locale strategie

### Zdroj locale
- primarne app locale (EasyLocalization).
- fallback device locale.
- final fallback bez explicitniho locale (system default STT).

### Mapovani pro MVP
- `cs` -> `cs_CZ`
- `en` -> `en_US`
- ostatni -> prvni dostupny locale z pluginu nebo system default.

### UX pravidla
- pokud zvoleny locale neni podporovan, fallback probehne tise.
- v debug logu zaznamenat finalne pouzity locale.

## UX stavy a edge cases

### Stavovy model
- `idle`
- `initializing`
- `listening`
- `paused`
- `processingFinalResult`
- `permissionDenied`
- `error`

### Edge cases
- uzivatel odmitne permission.
- permission je permanentne denied.
- device nepodporuje speech recognition.
- timeout bez reci / prazdny transcript.
- prepnuti mezi Meals/Exercise uprostred aktivniho poslechu.
- odchod ze screenu pri aktivnim listen session.

## Implementacni kroky (sekvence)
1. Pridat dependency `speech_to_text` do `pubspec.yaml`.
2. Dopsat iOS permission string `NSpeechRecognitionUsageDescription`.
3. Overit/doplnit Android manifest pro speech recognition kompatibilitu.
4. Vytvorit `VoiceTranscriptionService` (init/start/stop/pause + error mapovani + locale resolver).
5. Napojit `VoiceLogScreen` na STT stavy a live transcript.
6. Napojit Analyze Meals na existujici AI meal flow.
7. Pridat exercise AI parse flow (prompt + model + pipeline metoda).
8. Rozsirit `AddExerciseScreen` o predvyplnene vstupy z voice parse.
9. Dodelat UX osetreni chyb, disabled states a retry.
10. Dopsat testy + manual QA checklist.

## Test plan

### Unit testy
- locale resolver (`cs/en/fallback`).
- mapovani STT chyb na app chyby.
- parser exercise AI response (valid/invalid kombinace poli).

### Widget testy
- `VoiceLogScreen`:
  - permission denied branch,
  - listening state,
  - Analyze button enable/disable podle textu.
- prechod exercise analyze -> otevreni `AddExerciseScreen` s predvyplnenim.

### Manual QA
- iOS + Android: prvni permission prompt.
- live prepis v cestine i anglictine.
- prepnuti Meals/Exercise pred analyzou.
- error flow: bez internetu, prazdny vstup, AI failure.
- overeni, ze meal se po analyze ulozi do spravneho dne.

## Rizika a mitigace
- Riziko: nizsi kvalita STT na nekterych zarizenich.
  - Mitigace: manual edit textu pred analyze, fallback locale.
- Riziko: exercise parse vraci nekonzistentni data.
  - Mitigace: strict schema + post-parse validace + fallback na manual edit.
- Riziko: zavody stavu pri rychlem tapani na mic.
  - Mitigace: centralni state guard (`isBusy`) a serializace start/stop operaci.

## Definition of Done (MVP)
- VoiceLog umi realny speech-to-text prepis v rezimu Meals i Exercise.
- Analyze Meals vola existujici text AI pipeline a uklada vysledek.
- Analyze Exercise vraci strukturu a predvyplni `AddExerciseScreen`.
- Permission a error flow jsou osetrene na iOS i Android.
- Locale fallback funguje pro `cs/en/ostatni`.
- Zakladni unit + widget testy pro voice flow prochazi.

## Rozhodnuti pred implementaci (potvrzeno)
- Pouzit `speech_to_text` jako MVP reseni.
- Meals: text-only analyze na stavajici pipeline.
- Exercise: AI parse + predvyplneni formularove obrazovky.
- Dodelat iOS/Android permission hardening a locale strategii.

## Dotcene soubory (predbezne)
- `pubspec.yaml`
- `ios/Runner/Info.plist`
- `android/app/src/main/AndroidManifest.xml`
- `lib/screens/logs/voice_log_screen.dart`
- `lib/screens/logs/add_exercise_screen.dart`
- `lib/services/ai_feature/ai_pipeline_service.dart`
- `lib/utils/prompt.dart`
- `lib/network/openai_rest_client.dart`
- nove soubory pod `lib/services/voice/` a pripadne `lib/model/voice/`
