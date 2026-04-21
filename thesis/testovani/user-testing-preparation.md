# Plán uživatelského testování aplikace Foody

> **Summary**: Kompletní plán uživatelského testování s výběrem funkcí, metodikou, testovacími úlohami a dotazníky.

---

## 1. PŘEHLED TESTOVÁNÍ

### 1.1 Cíl

Ověřit použitelnost a uživatelskou zkušenost aplikace Foody na reálných uživatelích. Testování pokrývá klíčové funkční požadavky (FR) i funkce implementované nad rámec původní specifikace (voice, exercise, weight tracking).

### 1.2 Parametry

| Parametr | Hodnota |
|----------|---------|
| Počet participantů | 4 |
| Metodika | Think-aloud (concurrent) + task-based |
| Dotazníky | SUS + UEQ-S + SEQ (po každé úloze) |
| Zařízení | Reálné mobilní zařízení |
| Vstupní materiál | Reálné jídlo + připravené fotky v galerii |
| Odhadovaná délka session | 75-90 minut |

### 1.3 Struktura session

| Fáze | Délka | Obsah |
|------|-------|-------|
| Úvod | 5 min | Představení, souhlas, instrukce k think-aloud |
| Úlohy 1-13 | 60-70 min | Task-based testování s SEQ po každé úloze |
| Dotazníky | 10 min | SUS + UEQ-S |
| Debriefing | 5-10 min | Otevřené otázky, celkový dojem |

---

## 2. VÝBĚR FUNKCÍ K TESTOVÁNÍ

### 2.1 Kritéria výběru

Prioritně testujeme funkce, které:
1. Tvoří jádro aplikace (záznam jídla, AI rozpoznání)
2. Představují hlavní diferenciátor (AI, voice, barcode)
3. Jsou nové a netestované (extra features mimo původní FR)
4. Pokrývají UC scénáře z diplomové práce

### 2.2 FR pokryté testovacími úlohami

| FR | Název | Pokrytí úlohou | Priorita |
|----|-------|-----------------|----------|
| FR-01 | Ruční přidání záznamu jídla | Úloha 7 | Vysoká |
| FR-02 | Denní přehled | Úloha 11 | Vysoká |
| FR-03 | Cílové hodnoty | Úloha 1 | Vysoká |
| FR-04 | Správa profilu | Úloha 1 | Vysoká |
| FR-05 | Mazání záznamu | Úloha 11 (sub-task) | Střední |
| FR-06 | Fotografie jako vstup | Úloha 2 | Vysoká |
| FR-07 | AI návrh položek | Úloha 2 | Vysoká |
| FR-08 | Indikace nejistoty | Úloha 2 (pozorování) | Vysoká |
| FR-09 | Vysvětlení limitů AI | Úloha 2 (scan onboarding) | Střední |
| FR-11 | Textový fallback | Úloha 4 | Vysoká |
| FR-12 | Import z galerie | Úloha 3 | Vysoká |
| FR-13 | Re-run AI z editace | Úloha 4 | Vysoká |
| FR-14 | Zápis bez fotografie | Úloha 5 | Vysoká |
| FR-15 | Jednotky (gramy/kusy) | Úloha 7 (pozorování) | Střední |
| FR-16 | Čtečka čárových kódů | Úloha 6 | Vysoká |
| FR-17 | Oblíbené položky | Úloha 8 | Vysoká |
| FR-18 | Duplikace záznamu | Úloha 8 | Vysoká |
| FR-20 | Dietní omezení | Úloha 1 | Střední |
| FR-22 | Příjem vs. výdej | Úloha 11 | Střední |
| FR-24 | Týdenní/měsíční přehledy | Úloha 12 | Vysoká |
| FR-25 | Export dat | Úloha 13 | Střední |
| FR-27 | Ask AI (dotazy nad daty) | Úloha 12 | Vysoká |

### 2.3 Extra features pokryté testovacími úlohami

| # | Funkce | Pokrytí úlohou |
|---|--------|----------------|
| E1 | Hlasový vstup (meals) | Úloha 5 |
| E1 | Hlasový vstup (exercise) | Úloha 9 |
| E2 | Sledování cvičení | Úloha 9 |
| E3 | Sledování váhy + BMI | Úloha 10 |
| E14 | Scan onboarding | Úloha 2 (automaticky) |
| E15 | Fix/Re-analyze | Úloha 4 |
| E18 | Onboarding flow | Úloha 1 |

### 2.4 FR nepokryté přímo (a proč)

| FR | Název | Důvod vynechání |
|----|-------|-----------------|
| FR-10 | AI error vs. app error | Nelze spolehlivě vyvolat v kontrolovaném testu |
| FR-19 | Našeptávání názvů | Implicitně pokryto v úlohách 7-8 (vyhledávání) |
| FR-21 | Porušení diet v kalendáři | Vyžaduje historická data s porušeními, obtížné simulovat |
| FR-23 | Integrace výdeje (nastavení) | Pouze toggle, malá interakční hodnota |
| FR-26 | Offline tolerance | Vyžaduje odpojení od sítě v průběhu testu |
| FR-28 | Motivační souhrn | Vyžaduje čas (denní/týdenní/měsíční cyklus) |
| FR-29 | Notifikace | Nastavení viditelné v profilu, ale efekt vyžaduje čas |
| FR-30 | Skrytí/zobrazení funkcí | Pouze toggles v nastavení, malá interakční hodnota |

---

## 3. TESTOVACÍ ÚLOHY

Úlohy jsou seřazeny tak, aby tvořily přirozený flow prvního použití aplikace. Moderátor čte zadání participantovi. Každá úloha má success criteria pro vyhodnocení.

### Příprava před testem

- Nainstalovat čistou verzi aplikace (žádná předchozí data)
- Připravit na stůl reálné jídlo (např. talíř s obědem, ovoce, balený snack s čárovým kódem)
- Nahrát do galerie zařízení 2-3 připravené fotky jídel
- Mít po ruce balený produkt s čárovým kódem (EAN)
- Zajistit Wi-Fi připojení

---

### Úloha 1: Onboarding a nastavení profilu
**Zadání**: "Právě jste si nainstalovali novou aplikaci na sledování kalorií. Otevřete ji a projděte úvodním nastavením. Zadejte své údaje, nastavte si cíle a případné dietní preference."

**Pokrývá**: UC06, FR-03, FR-04, FR-20, E18

**Success criteria**:
- [ ] Participant dokončil onboarding flow
- [ ] Zadal základní údaje (váha, výška, cíl)
- [ ] Nastavil kalorický cíl (automaticky nebo ručně)

**Pozorování**: Rozumí participant jednotlivým krokům? Váhá u některých polí? Komentuje volby?

**SEQ po úloze** (1-7)

---

### Úloha 2: Záznam jídla z fotografie
**Zadání**: "Na stole máte jídlo. Vyfotografujte ho pomocí aplikace a zaznamenejte si ho jako oběd."

**Pokrývá**: UC01, FR-06, FR-07, FR-08, FR-09, E14

**Success criteria**:
- [ ] Participant našel funkci pro focení
- [ ] Pořídil fotografii
- [ ] Prohlédl si AI výsledek
- [ ] Uložil záznam

**Pozorování**: Všimne si confidence badge? Čte scan onboarding (pokud se zobrazí poprvé)? Překvapí ho výsledek AI? Upravuje množství/položky?

**SEQ po úloze** (1-7)

---

### Úloha 3: Import fotografie z galerie
**Zadání**: "Ve vaší galerii máte fotku jídla z včerejška. Přidejte ji do aplikace jako záznam."

**Pokrývá**: FR-12

**Success criteria**:
- [ ] Participant našel možnost importu z galerie
- [ ] Vybral fotku a nechal ji analyzovat
- [ ] Uložil výsledek

**Pozorování**: Najde rychle cestu ke galerii? Rozumí, že to projde stejnou AI analýzou jako kamera?

**SEQ po úloze** (1-7)

---

### Úloha 4: Oprava výsledku AI a re-analýza
**Zadání**: "Podívejte se na záznam, který jste právě přidali. Představte si, že AI nesprávně rozpoznalo jednu položku. Zkuste výsledek opravit nebo nechat znovu analyzovat."

**Pokrývá**: UC02, FR-13, FR-11, E15

**Success criteria**:
- [ ] Participant otevřel detail/editaci jídla
- [ ] Našel možnost opravy (ruční editace nebo "Fix with AI")
- [ ] Provedl opravu nebo re-analýzu

**Pozorování**: Najde tlačítko "Fix with AI"? Rozumí textovému vstupu pro korekci? Preferuje ruční editaci nebo re-analýzu?

**SEQ po úloze** (1-7)

---

### Úloha 5: Záznam jídla hlasem
**Zadání**: "Zkuste zaznamenat jídlo jiným způsobem. Řekněte aplikaci hlasem, co jste jedli, například: 'Dvě vajíčka na měkko s chlebem a máslem.'"

**Pokrývá**: FR-14, E1

**Success criteria**:
- [ ] Participant našel hlasový vstup
- [ ] Úspěšně nahrál hlasovou zprávu
- [ ] AI zpracovalo text a vrátilo výsledek
- [ ] Participant uložil záznam

**Pozorování**: Je hlasový vstup intuitivní? Funguje rozpoznávání řeči dobře v CZ? Překvapí participanta kvalita výsledku?

**SEQ po úloze** (1-7)

---

### Úloha 6: Skenování čárového kódu
**Zadání**: "Máte balený produkt (snack/nápoj). Přidejte ho do záznamu pomocí čárového kódu."

**Pokrývá**: UC04, FR-16

**Success criteria**:
- [ ] Participant našel funkci skenování
- [ ] Úspěšně naskenoval čárový kód
- [ ] Aplikace našla produkt a zobrazila nutriční hodnoty
- [ ] Participant uložil záznam

**Pozorování**: Najde barcode mód rychle? Jak reaguje, pokud produkt není v databázi?

**SEQ po úloze** (1-7)

---

### Úloha 7: Ruční přidání záznamu
**Zadání**: "Chcete si zapsat svačinu, ale nemáte u sebe jídlo ani fotku. Přidejte ručně záznam: jogurt s müsli."

**Pokrývá**: UC03, FR-01, FR-15

**Success criteria**:
- [ ] Participant našel ruční přidání
- [ ] Zadal název a nutriční hodnoty nebo ingredience
- [ ] Vybral jednotky (gramy/kusy)
- [ ] Uložil záznam

**Pozorování**: Je ruční přidání dostatečně přehledné? Rozumí participant jednotkám? Jak dlouho trvá zápis?

**SEQ po úloze** (1-7)

---

### Úloha 8: Oblíbené a duplikace jídla
**Zadání**: "Jedno z vašich dnešních jídel jíte pravidelně. Označte ho jako oblíbené. Potom ho zkopírujte na zítřejší den."

**Pokrývá**: UC05, FR-17, FR-18

**Success criteria**:
- [ ] Participant našel, jak označit jídlo jako oblíbené
- [ ] Úspěšně přidal do oblíbených
- [ ] Našel funkci kopírování/duplikace na jiný den
- [ ] Úspěšně zkopíroval jídlo

**Pozorování**: Je oblíbené intuitivní (ikona srdce/hvězda)? Najde funkci kopírování snadno?

**SEQ po úloze** (1-7)

---

### Úloha 9: Záznam cvičení hlasem
**Zadání**: "Dnes jste byli běhat 30 minut. Zaznamenejte si toto cvičení do aplikace, ideálně pomocí hlasu."

**Pokrývá**: E1, E2

**Success criteria**:
- [ ] Participant našel sekci pro cvičení
- [ ] Použil hlasový vstup pro popis cvičení
- [ ] AI odhadlo spálené kalorie
- [ ] Participant uložil záznam

**Pozorování**: Najde participant sekci cvičení? Funguje hlasový vstup pro cvičení stejně intuitivně jako pro jídlo?

**SEQ po úloze** (1-7)

---

### Úloha 10: Zaznamenání váhy
**Zadání**: "Právě jste se zvážili. Zaznamenejte si svou aktuální váhu do aplikace."

**Pokrývá**: E3

**Success criteria**:
- [ ] Participant našel, kde zadat váhu
- [ ] Zadal hodnotu a uložil
- [ ] Viděl BMI nebo váhový trend (pokud existují předchozí záznamy)

**Pozorování**: Je vstup váhy snadno dostupný? Rozumí participant zobrazeným informacím (BMI)?

**SEQ po úloze** (1-7)

---

### Úloha 11: Denní přehled a smazání záznamu
**Zadání**: "Podívejte se na svůj dnešní denní přehled. Kolik kalorií jste zatím přijali? Kolik vám zbývá? Potom smažte jeden ze záznamů, který jste přidali omylem."

**Pokrývá**: FR-02, FR-05, FR-22

**Success criteria**:
- [ ] Participant našel denní přehled (dashboard)
- [ ] Dokázal přečíst kalorie, makra, zbývající kalorie
- [ ] Rozumí zobrazení příjmu vs. výdeje
- [ ] Úspěšně smazal jeden záznam

**Pozorování**: Je dashboard přehledný? Rozumí participant všem zobrazeným číslům? Najde funkci mazání snadno?

**SEQ po úloze** (1-7)

---

### Úloha 12: Týdenní přehled a Ask AI
**Zadání**: "Podívejte se na svůj týdenní přehled. Potom se zeptejte aplikace otázkou v přirozeném jazyce, například: 'Kolik bílkovin jsem jedl tento týden?'"

**Pokrývá**: UC07, FR-24, FR-27

**Success criteria**:
- [ ] Participant našel týdenní/měsíční přehledy
- [ ] Prohlédl si grafy a souhrny
- [ ] Našel funkci Ask AI
- [ ] Položil dotaz a dostal odpověď

**Pozorování**: Jsou přehledy srozumitelné? Ví participant, že může klást otázky v přirozeném jazyce? Jak hodnotí kvalitu odpovědi?

**SEQ po úloze** (1-7)

---

### Úloha 13: Export dat
**Zadání**: "Chcete svá data sdílet s výživovým poradcem. Exportujte svá data za posledních 7 dní."

**Pokrývá**: FR-25

**Success criteria**:
- [ ] Participant našel funkci exportu
- [ ] Vybral časové období
- [ ] Vygeneroval export (CSV nebo PDF)
- [ ] Sdílel nebo uložil výstup

**Pozorování**: Najde export v nastavení/profilu? Rozumí volbám formátu a období?

**SEQ po úloze** (1-7)

---

## 4. DOTAZNÍKY

### 4.1 SEQ (Single Ease Question) po každé úloze

Bezprostředně po dokončení každé úlohy:

> "Jak snadná nebo obtížná pro vás byla právě dokončená úloha?"
>
> 1 = Velmi obtížná ... 7 = Velmi snadná

Zaznamenat: číslo úlohy + skóre. Benchmark: průměr >= 5.5 je dobrý.

### 4.2 SUS (System Usability Scale) po všech úlohách

10 položek, 5bodová Likertova škála (1 = rozhodně nesouhlasím, 5 = rozhodně souhlasím).

1. Myslím, že bych tuto aplikaci rád/a používal/a pravidelně.
2. Aplikace mi přišla zbytečně složitá.
3. Myslím, že se aplikace snadno používá.
4. Myslím, že bych potřeboval/a pomoc technické osoby, abych mohl/a aplikaci používat.
5. Různé funkce v aplikaci mi přišly dobře propojené.
6. Myslím, že je v aplikaci příliš mnoho nekonzistencí.
7. Dokážu si představit, že by se většina lidí naučila aplikaci používat velmi rychle.
8. Aplikace mi přišla velmi těžkopádná na ovládání.
9. Cítil/a jsem se při používání aplikace sebejistě.
10. Musel/a jsem se toho hodně naučit, než jsem mohl/a začít aplikaci používat.

**Vyhodnocení**: ((součet lichých - 5) + (25 - součet sudých)) * 2.5 = skóre 0-100. Průměr SUS ~68. Nad 80.3 = top 10 %.

### 4.3 UEQ-S (User Experience Questionnaire Short) po všech úlohách

8 položek, 7bodová sémantická diferenciální škála (-3 až +3).

Instrukce: "Ohodnoťte aplikaci na základě vašeho celkového dojmu."

| # | Pól 1 (záporný) | Škála | Pól 2 (kladný) | Škála |
|---|-----------------|-------|-----------------|-------|
| 1 | bránící | -3 -2 -1 0 +1 +2 +3 | podporující | Pragmatická |
| 2 | složitý | -3 -2 -1 0 +1 +2 +3 | jednoduchý | Pragmatická |
| 3 | neefektivní | -3 -2 -1 0 +1 +2 +3 | efektivní | Pragmatická |
| 4 | matoucí | -3 -2 -1 0 +1 +2 +3 | jasný | Pragmatická |
| 5 | nudný | -3 -2 -1 0 +1 +2 +3 | vzrušující | Hedonická |
| 6 | nezajímavý | -3 -2 -1 0 +1 +2 +3 | zajímavý | Hedonická |
| 7 | obvyklý | -3 -2 -1 0 +1 +2 +3 | vynalézavý | Hedonická |
| 8 | tradiční | -3 -2 -1 0 +1 +2 +3 | moderní | Hedonická |

**Vyhodnocení**: Záporný pól je vždy vlevo, žádné položky není třeba obracet. Pragmatická kvalita = průměr položek 1–4. Hedonická kvalita = průměr položek 5–8. Celkové skóre = průměr všech 8 položek. Benchmark k dispozici na ueq-online.org.

Pozn.: Jedná se o oficiální českou verzi UEQ-S validovanou a dostupnou na ueq-online.org.

---

## 5. DEBRIEFING (otevřené otázky)

Po vyplnění dotazníků, krátký rozhovor (5-10 min):

1. "Co bylo na aplikaci nejpříjemnější nebo nejužitečnější?"
2. "Co vás nejvíce frustrovalo nebo zmátlo?"
3. "Byla nějaká funkce, kterou jste neočekávali? Překvapila vás (pozitivně nebo negativně)?"
4. "Jak byste porovnali tuto aplikaci s jinými aplikacemi na sledování jídla, pokud nějakou znáte?"
5. "Je něco, co by vám v aplikaci chybělo?"
6. "Používali byste tuto aplikaci pravidelně? Proč ano/ne?"

---

## 6. PŘÍPRAVA MATERIÁLŮ (checklist)

### Pro moderátora
- [ ] Vytisknout formuláře: SEQ (13x per participant), SUS, UEQ-S
- [ ] Připravit záznamový arch (úlohy, časy, poznámky, chyby)
- [ ] Připravit informovaný souhlas
- [ ] Připravit krátký dotazník na demografii participanta (věk, zkušenosti s calorie tracking apps)
- [ ] Mít po ruce zadání úloh (vytisknout nebo na druhém zařízení)
- [ ] Připravit stopky / timer

### Pro testovací zařízení
- [ ] Čistá instalace aplikace (žádná data, první spuštění)
- [ ] Nahrát 2-3 fotky jídla do galerie zařízení
- [ ] Ověřit Wi-Fi připojení
- [ ] Ověřit funkčnost mikrofonu (pro voice)
- [ ] Ověřit funkčnost kamery

### Pro testovací prostředí
- [ ] Reálné jídlo na stole (talíř s obědem, ovoce, pečivo...)
- [ ] Balený produkt s čárovým kódem (snack, nápoj)
- [ ] Klidné prostředí pro think-aloud
- [ ] Nahrávací zařízení (screen recording + audio)

---

## 7. NFR OVĚŘENÍ BĚHEM TESTU

Nefunkční požadavky se ověřují pozorováním a měřením během testování:

| NFR | Název | Jak ověřit |
|-----|-------|------------|
| NFR-01 | Nepřesnost odhadu <= 10 % | Porovnat AI výsledek s reálnými hodnotami připraveného jídla |
| NFR-02 | Latence AI <= 20 s | Měřit stopkami čas od odeslání fotky do zobrazení výsledku |
| NFR-03 | Max 6 kroků pro zápis | Počítat tapy/kroky během úloh 2, 5, 6, 7 |
| NFR-04 | Opakované jídlo < 1 min, nové < 5 min | Měřit čas úloh 2 (nové) a 8 (opakované) |
| NFR-05 | Minimalistické UI | Subjektivně: SUS + UEQ-S + debriefing otázky |

---

## 8. REFERENČNÍ MATERIÁLY

### 8.1 UC scénáře (přečíslované)

| UC | Název | Stav |
|----|-------|------|
| UC01 | Záznam jídla z fotografie | IMPL |
| UC02 | Oprava výsledku a opakování rozpoznání | IMPL |
| UC03 | Ruční přidání záznamu jídla | IMPL |
| UC04 | Balená potravina pomocí čárového kódu | IMPL |
| UC05 | Opakované jídlo z oblíbených/duplikací | IMPL |
| UC06 | Nastavení profilu, cílů a dietních omezení | IMPL |
| UC07 | Přehledy, dotazy nad daty a export | IMPL |

### 8.2 Kompletní FR seznam (přečíslovaný, FR-01 až FR-30)

| FR | Název | Stav | Testováno úlohou |
|----|-------|------|------------------|
| FR-01 | Ruční přidání záznamu jídla | Done | 7 |
| FR-02 | Denní přehled | Done | 11 |
| FR-03 | Cílové hodnoty | Done | 1 |
| FR-04 | Správa profilu | Done | 1 |
| FR-05 | Kontrola nad daty a mazání | Partial | 11 |
| FR-06 | Fotografie jako vstup | Done | 2 |
| FR-07 | AI návrh položek | Done | 2 |
| FR-08 | Indikace nejistoty | Done | 2 |
| FR-09 | Vysvětlení limitů AI | Done | 2 |
| FR-10 | AI error vs. app error | Partial | - |
| FR-11 | Textový fallback | Done | 4 |
| FR-12 | Import z galerie | Done | 3 |
| FR-13 | Re-run AI z editace | Done | 4 |
| FR-14 | Zápis bez fotografie | Done | 5 |
| FR-15 | Jednotky (gramy/kusy) | Done | 7 |
| FR-16 | Čtečka čárových kódů | Done | 6 |
| FR-17 | Oblíbené položky | Done | 8 |
| FR-18 | Duplikace záznamu | Done | 8 |
| FR-19 | Našeptávání názvů | Partial | - |
| FR-20 | Dietní omezení | Done | 1 |
| FR-21 | Porušení diet v kalendáři | Done | - |
| FR-22 | Příjem vs. výdej | Done | 11 |
| FR-23 | Integrace výdeje | Partial | - |
| FR-24 | Týdenní/měsíční přehledy | Done | 12 |
| FR-25 | Export dat | Done | 13 |
| FR-26 | Offline tolerance | Done | - |
| FR-27 | Dotazy v přirozeném jazyce | Done | 12 |
| FR-28 | Motivační souhrn | Done | - |
| FR-29 | Notifikace | Done | - |
| FR-30 | Skrytí/zobrazení funkcí | Partial | - |

### 8.3 Pokrytí

- **FR pokryté přímo úlohami**: 22 / 30 (73 %)
- **FR nepokryté**: 8 (důvody viz sekce 2.4)
- **UC pokryté**: 7 / 7 (100 %)
- **Extra features pokryté**: 7 (voice meals, voice exercise, exercise tracking, weight, scan onboarding, fix/re-analyze, onboarding)

---

## 9. CHANGELOG

| Date | Change |
|------|--------|
| 2026-04-19 | Initial plan created |
| 2026-04-19 | FR/UC renumbered (FR-01-30, UC01-07). Testing plan added: 13 tasks, SUS + UEQ-S + SEQ, debriefing questions, NFR verification, preparation checklist |
