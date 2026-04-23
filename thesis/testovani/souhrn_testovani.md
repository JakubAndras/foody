# Souhrn výstupů z uživatelského testování aplikace Foody

---

## 1. Přehled participantů

| Údaj | P1 | P2 | P3 |
|------------------------------|----------------|----------------|----------------|
| Věk | 28 let | 25 let | 54 let |
| Pohlaví | žena | muž | žena |
| Primární cíl | hubnutí | hubnutí a nabírání | hubnutí |
| Zkušenosti s CT aplikacemi | střední (Kalorické tabulky) | střední (Kalorické tabulky) | malá (Kalorické tabulky) |
| Technologická zdatnost | střední | vysoká | střední |
| Datum testování | 21. 4. 2026 | 21. 4. 2026 | 20. 4. 2026 |
| Doba testování | 90 min | 85 min | 95 min |
| Zařízení | iPhone 16 Pro | iPhone 16 Pro | iPhone 16 Pro |

---

## 2. Plnění úloh

### 2.1 Dokončení a kritické chyby po úlohách

| Úloha | P1 dok. | P2 dok. | P3 dok. | P1 krit. | P2 krit. | P3 krit. |
|----------------------|----------|----------|----------|----------|----------|----------|
| T1: Onboarding | ano | ano | ano | 0 | 0 | 0 |
| T2: Foto jídla | ano | ano | ano | 0 | 0 | 0 |
| T3: Import z galerie | s pomocí | ano | s pomocí | 1 | 0 | 1 |
| T4: Oprava AI | ano | ano | ano | 0 | 0 | 0 |
| T5: Hlasový vstup | ano | ano | ano | 0 | 0 | 0 |
| T6: Čárový kód | ano | ano | ano | 0 | 0 | 0 |
| T7: Ruční přidání | ano | ano | ano | 0 | 0 | 0 |
| T8: Oblíbené | s pomocí | ano | s pomocí | 1 | 0 | 1 |
| T9: Duplikace | ano | s pomocí | ano | 0 | 1 | 0 |
| T10: Kalendář | ano | ano | ano | 0 | 0 | 0 |
| T11: Množství | ano | ano | ano | 0 | 0 | 0 |
| T12: Cvičení hlasem | ano | ano | ano | 0 | 0 | 0 |
| T13: Váha | ano | ano | ano | 0 | 0 | 0 |
| T14: Přehled a smazání | ano | ano | ano | 0 | 0 | 0 |
| T15: Ask AI | ano | s pomocí | ano | 0 | 1 | 0 |
| T16: Export | ano | ano | ano | 0 | 0 | 0 |

### 2.2 Souhrnné dokončení napříč participanty

| Metrika | Hodnota |
|----------------------------------------|-------------------------------|
| Celkový počet provedených úloh | 48 (16 úloh x 3 participanti) |
| Dokončeno samostatně (ano) | 42 / 48 (87,5 %) |
| Dokončeno s pomocí | 6 / 48 (12,5 %) |
| Nedokončeno | 0 / 48 (0 %) |
| Celková míra dokončení | 100 % |
| Celkový počet kritických chyb | 6 |
| Průměr kritických chyb na úlohu | 6 / 48 = 0,125 |

### 2.3 Úlohy s opakovanými problémy

| Úloha | Počet „s pomocí" | Počet krit. chyb | Poznámka |
|----------------------|---------|---------|-----------------------------------------------|
| T3: Import z galerie | 2/3 | 2 | Ikona pro výběr z galerie příliš schovaná |
| T8: Oblíbené | 2/3 | 2 | Funkce obtížně nalezitelná, neintuitivní ikona |
| T9: Duplikace | 1/3 | 1 | Nejasné zadání vs. přidání nového záznamu |
| T15: Ask AI | 1/3 | 1 | Nejasná formulace úlohy |

---

## 3. SEQ (Single Ease Question)

Škála 1 (velmi obtížná) až 7 (velmi snadná). Benchmark: průměr >= 5,5 = dobré hodnocení.

### 3.1 SEQ po úlohách

| Úloha | P1 | P2 | P3 | Průměr |
|----------------------|------|------|------|--------|
| T1: Onboarding | 6 | 7 | 7 | 6,67 |
| T2: Foto jídla | 6 | 7 | 7 | 6,67 |
| T3: Import z galerie | 5 | 5 | 4 | 4,67 |
| T4: Oprava AI | 7 | 5 | 7 | 6,33 |
| T5: Hlasový vstup | 6 | 7 | 7 | 6,67 |
| T6: Čárový kód | 7 | 7 | 7 | 7,00 |
| T7: Ruční přidání | 7 | 4 | 7 | 6,00 |
| T8: Oblíbené | 3 | 7 | 4 | 4,67 |
| T9: Duplikace | 7 | 4 | 7 | 6,00 |
| T10: Kalendář | 7 | 7 | 7 | 7,00 |
| T11: Množství | 6 | 6 | 7 | 6,33 |
| T12: Cvičení hlasem | 5 | 7 | 6 | 6,00 |
| T13: Váha | 6 | 7 | 7 | 6,67 |
| T14: Přehled a smazání | 7 | 7 | 7 | 7,00 |
| T15: Ask AI | 7 | 2 | 7 | 5,33 |
| T16: Export | 7 | 7 | 7 | 7,00 |

### 3.2 SEQ souhrnně

| Metrika | P1 | P2 | P3 | Celkový průměr |
|------------|--------|--------|--------|----------------|
| SEQ průměr | 6,1875 | 6,00 | 6,5625 | 6,25 |

Celkový průměr SEQ = (99 + 96 + 105) / 48 = 300 / 48 = **6,25** (nad benchmarkem 5,5).

Úlohy pod benchmarkem 5,5: T3 (4,67) a T8 (4,67).

---

## 4. NFR metriky

### 4.1 Latence AI rozpoznávání (T2, limit 20 s)

| Participant | Hodnota |
|-------------|------------|
| P1 | 6 s |
| P2 | 9 s |
| P3 | 8 s |
| **Průměr** | **7,67 s** |

Splněno u všech participantů.

### 4.2 Počet kroků pro zápis

| Úloha | P1 | P2 | P3 | Průměr | Limit | Splněno |
|----------------------|------|------|------|--------|-------|----------------|
| T2: Foto jídla | 5 | 5 | 4 | 4,67 | 6 | ano |
| T5: Hlasový vstup | 4 | 4 | 6 | 4,67 | 6 | ano |
| T6: Čárový kód | 2 | 2 | 2 | 2,00 | 6 | ano |
| T7: Ruční přidání | 9 | 14 | 10 | 11,00 | 12 | **ne (P2: 14)** |

### 4.3 Čas zápisu nového záznamu (T2, limit 5 min)

| Participant | Hodnota |
|-------------|------------|
| P1 | 24 s |
| P2 | 26 s |
| P3 | 16 s |
| **Průměr** | **22 s** |

Splněno u všech participantů.

### 4.4 Čas opakovaného záznamu (T8, limit 1 min)

| Participant | Hodnota |
|-------------|------------|
| P1 | 36 s |
| P2 | 27 s |
| P3 | 56 s |
| **Průměr** | **39,67 s** |

Splněno u všech participantů.

---

## 5. SUS (System Usability Scale)

### 5.1 Odpovědi po položkách

| # | Tvrzení | P1 | P2 | P3 |
|---|---------------------------------------------|------|------|------|
| 1 | Rád/a bych aplikaci používal/a pravidelně | 5 | 4 | 5 |
| 2 | Zbytečně složitá | 1 | 2 | 2 |
| 3 | Snadno se používá | 4 | 5 | 4 |
| 4 | Potřeboval/a bych pomoc technické osoby | 1 | 1 | 1 |
| 5 | Funkce jsou dobře provázané | 4 | 4 | 4 |
| 6 | Příliš mnoho nekonzistentností | 2 | 2 | 1 |
| 7 | Většina lidí by se naučila rychle | 4 | 5 | 5 |
| 8 | Těžkopádná na používání | 1 | 1 | 1 |
| 9 | Cítil/a jsem se sebejistě | 5 | 4 | 4 |
| 10 | Musel/a jsem se naučit mnoho věcí | 1 | 5 | 1 |

### 5.2 SUS skóre

| Participant | S_L (liché) | S_S (sudé) | SUS skóre | Interpretace |
|-------------|-------------|------------|-----------|-----------------|
| P1 | 22 | 6 | 90 | top 10 % |
| P2 | 22 | 11 | 77,5 | nadprůměrné |
| P3 | 22 | 6 | 90 | top 10 % |
| **Průměr** | | | **85,83** | **top 10 %** |

Průměr SUS = (90 + 77,5 + 90) / 3 = 257,5 / 3 = **85,83**.

Interpretace: 0-50 = neakceptovatelné, 51-68 = podprůměrné, 68 = průměr, 68-80,3 = nadprůměrné, >80,3 = top 10 %.

---

## 6. UEQ-S (User Experience Questionnaire Short)

### 6.1 Odpovědi po položkách (škála -3 až +3)

| # | Dimenze | Pól (-3 / +3) | P1 | P2 | P3 |
|---|-------------|---------------------------|------|------|------|
| 1 | Pragmatická | bránící / podporující | +2 | 0 | +3 |
| 2 | Pragmatická | složitý / jednoduchý | +2 | +2 | +2 |
| 3 | Pragmatická | neefektivní / efektivní | +2 | 0 | +3 |
| 4 | Pragmatická | matoucí / jasný | +1 | +1 | +2 |
| 5 | Hedonická | nudný / vzrušující | +2 | +3 | +1 |
| 6 | Hedonická | nezajímavý / zajímavý | +1 | +3 | +3 |
| 7 | Hedonická | obvyklý / vynalézavý | +1 | +1 | +2 |
| 8 | Hedonická | tradiční / moderní | +3 | +3 | +3 |

### 6.2 UEQ-S skóre

| Metrika | P1 | P2 | P3 | Průměr | Interpretace |
|----------------------|--------|--------|--------|--------|--------------|
| Pragmatická kvalita | 1,75 | 0,75 | 2,50 | 1,667 | pozitivní |
| Hedonická kvalita | 1,75 | 2,50 | 2,25 | 2,167 | pozitivní |
| Celkové skóre | 1,75 | 1,625 | 2,375 | 1,917 | pozitivní |

Průměry: pragmatická = (1,75 + 0,75 + 2,50) / 3 = 5,00 / 3 = 1,667; hedonická = (1,75 + 2,50 + 2,25) / 3 = 6,50 / 3 = 2,167; celkové = (1,75 + 1,625 + 2,375) / 3 = 5,75 / 3 = 1,917.

Interpretace: <-0,8 = negativní, -0,8 až 0,8 = neutrální, >0,8 = pozitivní.

Poznámka: P2 hodnotil pragmatickou kvalitu jako neutrální (0,75), zatímco hedonickou kvalitu jako výrazně pozitivní (2,50). To naznačuje, že aplikace zapůsobila designem a inovativností, ale P2 (technicky zdatný uživatel) měl výhrady k efektivitě některých pracovních postupů.

---

## 7. Debriefing: klíčová zjištění

### 7.1 Celkový dojem

Všichni tři participanti hodnotili aplikaci pozitivně. Opakovaně zmiňovali přehlednost, minimalistický design a jednoduchost, zejména ve srovnání oproti konkurenční aplikaci Kalorické tabulky.

### 7.2 Co se nejvíce líbilo

| Participant | Odpověď |
|-------------|----------------------------------------------------------|
| P1 | Vizuál dashboardu (kalorie, makra), minimalistický design |
| P2 | Hlasové zadávání |
| P3 | Hlasové zadávání |

### 7.3 Co dělalo největší potíže

| Participant | Odpověď                                                  |
|-------------|----------------------------------------------------------|
| P1 | Komplikace s permissions, ikona záložky Personal Details |
| P2 | Nefungující grafy na Dashboardu (extrémní hodnoty)       |
| P3 | Některé texty málo čitelné, malé fonty                   |

### 7.4 Porovnání s jinými aplikacemi

Všichni tři participanti měli zkušenost s aplikací Kalorické tabulky a shodně hodnotili testovanou aplikaci Foody jako lepší variantu. Důvody: méně chaotické, přehlednější, jednodušší, vizuálně hezčí.

### 7.5 Pravidelné používání

Všichni tři participanti by aplikaci používali pravidelně.

### 7.6 Důvěra v AI odhady

| Participant | Odpověď                                                           |
|-------------|-------------------------------------------------------------------|
| P1 | Kontrolovala by u jídel, která zná; confidence badge hodně pomohl |
| P2 | Důvěřoval, nekontroloval by                                       |
| P3 | Spíše důvěřovala, u pro ni neznámých jídel by si ověřila          |

---

## 8. Zjištěné problémy a návrhy na zlepšení

### 8.1 Nalezené bugy

| # | Bug | Úloha    | Parti. | Popis |
|---|------------------------------|---------|--------|--------------------------------------------|
| 1 | Částečný přístup do galerie rozbije import | T3       | P1 | Při částečném přístupu do galerie (iOS permission) nelze přidat fotografii. |
| 2 | Pád aplikace při extrémních hodnotách | T12      | P2 | Kopírování záznamu s extrémně velkými hodnotami do více dnů způsobí pád Dashboard grafů. |
| 3 | Bug v Fix Issue feature | T4       | P2 | Fix Issue vytvoří jakoby další Edit Meal screen (duplikace obrazovky). |
| 4 | Bug v amount funkci u jídla bez ingrediencí | T11      | P2 | Změna Amount hodnoty nemění kalorie a makra u jídel bez ingrediencí. |
| 5 | Exercise edit a save nefunguje | T12      | P2 | Nelze uložit upravené cvičení. |
| 6 | Dlouhé hlasové vstupy se useknou | T5, T12  | P3 | Nahrávání se v půlce přestane zaznamenávat u delších promluv. |
| 7 | Klávesnice zůstává vysunutá | T1       | P1, P2, P3 | Na obrazovce custom diety v onboardingu zůstane klávesnice vysunutá po odeslání. |
| 8 | Notifikace o dokončení rozpoznání nepřišla | T3       | P1 | Loading karta zmiňuje notifikaci po dokončení, ale žádná nedorazí. |
| 9 | Návrat na Dashboard místo Voice Log | T5       | P1 | Po udělení systémového oprávnění se uživatel vrátí na Dashboard místo zpět na Voice Log obrazovku. |
| 10 | Editace gramáže vynuluje makra přes auto sync | —        | notes | Při editaci gramáže se auto syncem vynuluje macro hodnota. |
| 11 | Edit Meal: edit názvu používá starý bottomSheet | —        | notes | Obrazovka Edit Meal při editaci názvu jídla používá zastaralý bottomSheet. |

### 8.2 UI/UX problémy

| # | Problém | Úloha   | Parti. | Doporučení |
|---|------------------------------|---------|--------|--------------------------------------------|
| 1 | Ikona pro import z galerie příliš schovaná | T3      | P1, P2, P3 | Dva ze tří participantů potřebovali pomoc. Tlačítko pro výběr fotografie z galerie není dostatečně viditelné. |
| 2 | Funkce oblíbených obtížně nalezitelná | T8      | P1, P3 | Dva ze tří participantů potřebovali pomoc. Neintuitivní ikona, segment tab „Oblíbené" špatně čitelný, chybí onboarding/nápověda. |
| 3 | Ikona oblíbených neintuitivní | T8      | P1, P2, P3 | Všichni participanti navrhovali srdíčko nebo hvězdičku místo aktuální ikony. |
| 4 | Ikona Personal Details | T13     | P1, P2 | Změnit ikonu na profil/človíčka místo aktuální karty. |
| 5 | Zlomky u množství matoucí | T11     | P1, P2 | 5/8 je lehce matoucí; malý font; zvážit řazení od nejpoužívanějších zlomků. |
| 6 | Malé/nečitelné texty | obecně  | P3 | Font příliš malý, participantka překlikávala texty bez čtení. |
| 7 | „Back to today" špatně čitelné | T10     | P3 | Malá písmena, špatně se čte. |
| 8 | Chybějící Check button v bottomSheet | T2, T6  | P1, P3 | Mealtime bottomSheet nemá potvrzovací tlačítko, participanti ho intuitivně očekávali. |
| 9 | Chybějící potvrzení před AI rozpoznáním | T2      | P2 | Nelíbí se chybějící krok potvrzení před spuštěním rozpoznání. |
| 10 | Název „Fix issue" nejasný | T4      | P2 | Tlačítko přijde schované a název zvláštní. |
| 11 | Barcode databáze nedostatečná | T6      | P1, P2 | Testované balené produkty nebyly správně rozpoznány. |
| 12 | Dva vertikální scrolly na jedné obrazovce | T1      | P2 | Obrazovka nastavení rychlosti hubnutí/nabírání má dva scrollovatelné elementy. |
| 13 | Onboarding step „poskakuje" | T1      | P1 | Volba „Maintain" u váhy způsobí poskakující onboarding krok. |
| 14 | Snackbar při přidání do oblíbených chybí | T8      | P3 | Chybí zpětná vazba (snackbar) při přidání jídla do oblíbených. |
| 15 | Signalizace ukončení nahrávání | T5      | P2 | Lépe signalizovat ukončení nahrávání a potřebu kliknout na tlačítko analyzovat. |
| 16 | Toggle hlasového vstupu si nepamatuje stav | T12     | P3 | Při návratu na obrazovku se toggle vždy nastaví na „jídlo" místo posledního nastavení. |

### 8.3 Návrhy na nové funkce a vylepšení

| # | Návrh | Parti. | Popis |
|---|------------------------------|--------|----------------------------------------------|
| 1 | Hlasové zadávání i v Exercise a Fix Issue | P1, P2, P3 | Participanti intuitivně očekávali hlasové zadávání i v dalších částech aplikace. |
| 2 | Zvýraznění dnů s logy v kalendáři | P2, P3 | V měsíčním přehledu zvýraznit dny, kde jsou zaznamenány údaje (barvou, hvězdičkou, kruhy). |
| 3 | Ask AI: podpora hlasového vstupu | P3 | Umožnit hlasové zadávání dotazů v Ask AI. |
| 4 | Ask AI: přesun do Progress obrazovky | P3 | Participantka by funkci očekávala v Progress, ne v Profilu. |
| 5 | Ask AI: disable button při prázdném vstupu | P1 | Tlačítko by mělo být neaktivní, pokud je textfield prázdné. |
| 6 | Nastavení velikosti písma | P3 | Přidat do nastavení možnost velikosti písma. |
| 7 | Longpress pro nahrání vlastní fotky | P1 | Na placeholder obrázek v detailu jídla přidat longpress pro nahrání vlastní fotografie. |
| 8 | Zadat váhu z klávesnice | P2 | Umožnit zadat váhu jako číslo z klávesnice, ne jen posuvníkem. |
| 9 | Omezit rozsah let v kalendáři | P2 | Omezit budoucí (a vzdálené minulé) roky v kalendáři. |
| 10 | Help dialog pro oblíbené | P1 | Zobrazit nápovědu při prvním přidání jídla do oblíbených. |
| 11 | Share z Ask AI | P2 | Sdílení výstupu z Ask AI by mohlo posílat otázku + screenshot. |
| 12 | Po exportu návrat na profil + snackbar | P3 | Po exportu uživatel zůstane zanořen v obrazovce, lepší by byl návrat + potvrzení. |
| 13 | Recommended obrazovka v onboardingu | P1 | Zvážit automatické nastavení recommended hodnot bez extra obrazovky. |
| 14 | Custom dieta: příklady klíčových slov | P1 | V příkladu u textového pole dát i stručná klíčová slova (nejen celé věty). |
| 15 | Tvorba receptu z hlasového vstupu | P3 | Návrh na budoucí funkci. |

---

## 9. Souhrnná tabulka výsledků

| Metrika | P1 | P2 | P3 | Průměr |
|----------------------------------|--------|--------|--------|--------|
| SEQ průměr (1-7) | 6,1875 | 6,00 | 6,5625 | 6,25 |
| SUS (0-100) | 90 | 77,5 | 90 | 85,83 |
| UEQ-S pragmatická (-3 až +3) | 1,75 | 0,75 | 2,50 | 1,667 |
| UEQ-S hedonická (-3 až +3) | 1,75 | 2,50 | 2,25 | 2,167 |
| UEQ-S celkové (-3 až +3) | 1,75 | 1,625 | 2,375 | 1,917 |
| Dokončení (ano / s pomocí) | 14/2 | 14/2 | 14/2 | 14/2 |
| Kritické chyby (celkem) | 2 | 2 | 2 | 2 |
| Kritické chyby (průměr na úlohu) | 0,125 | 0,125 | 0,125 | 0,125 |

---

## 10. Celkové zhodnocení testování

Uživatelské testování proběhlo se třemi participanty odlišného věku (25, 28, 54 let), pohlaví a úrovně technologické zdatnosti. Testování pokrývalo 16 úloh mapovaných na funkční požadavky aplikace.

**Použitelnost:** Průměrné SUS skóre 85,83 řadí aplikaci do kategorie „nadprůměrné" a potvrzuje vysokou míru použitelnosti. Všechny úlohy byly dokončeny (100% míra dokončení), z toho 87,5 % samostatně a 12,5 % s drobnou nápovědou moderátora. Průměrné SEQ skóre 6,25 (z maxima 7) překračuje benchmark 5,5 pro dobré hodnocení.

**Uživatelský zážitek:** UEQ-S celkové skóre 1,917 spadá do pozitivního pásma (>0,8). Hedonická kvalita (2,167) byla hodnocena výše než pragmatická (1,667), což naznačuje, že aplikace uživatele zaujme designem a inovativností, zatímco v efektivitě pracovních postupů je prostor pro zlepšení.

**Hlavní silné stránky:** Minimalistický a přehledný design (opakovaně chválený všemi participanty), hlasové zadávání (nejchválenější funkce), rozpoznávání jídla z fotografie, confidence badge (pochopen a oceněn všemi), snadná navigace v kalendáři, export dat a skenování čárových kódů.

**Hlavní slabiny:** Dvě úlohy konzistentně selhávaly: import fotografie z galerie (T3, průměrné SEQ 4,67) a funkce oblíbených (T8, průměrné SEQ 4,67). V obou případech byl problém v nedostatečné viditelnosti příslušných UI prvků. Dále bylo identifikováno 10 bugů (pád při extrémních hodnotách, useknutí dlouhých hlasových vstupů, vysunutá klávesnice v onboardingu aj.) a 15 návrhů na vylepšení.

**Porovnání s konkurencí:** Všichni participanti měli zkušenost s aplikací Kalorické tabulky a shodně hodnotili Foody jako přehlednější, vizuálně hezčí a jednodušší na používání. Všichni tři by aplikaci používali pravidelně.

**NFR metriky:**

| NFR metrika | Úloha | Průměr | Limit | Splněno |
|------------------------------|-------|----------|-------|---------|
| Latence AI rozpoznávání | T2 | 7,67 s | 20 s | ano     |
| Čas zápisu nového záznamu | T2 | 22 s | 5 min | ano     |
| Čas záznamu přes oblíbené | T8 | 39,67 s | 1 min | ano     |
| Počet kroků: foto jídla | T2 | 4,67 | 6 | ano     |
| Počet kroků: hlasový vstup | T5 | 4,67 | 6 | ano     |
| Počet kroků: čárový kód | T6 | 2,00 | 6 | ano     |
| Počet kroků: ruční přidání | T7 | 11,00 | 12 | ano     |

---

## 11. Použité dotazníky a jejich zdroje

**SEQ (Single Ease Question)** je jednopoložkový dotazník administrovaný bezprostředně po dokončení každé úlohy. Participant hodnotí vnímanou obtížnost úlohy na sedmibodové Likertově škále (1 = velmi obtížná, 7 = velmi snadná). Benchmark pro dobré hodnocení je průměr >= 5,5.

- Sauro, J. a Dumas, J. S. (2009). Comparison of Three One-Question, Post-Task Usability Questionnaires. *Proceedings of the SIGCHI Conference on Human Factors in Computing Systems (CHI '09)*, 1599–1608. ACM.
- Web: https://measuringu.com/evolution-of-seq/

**SUS (System Usability Scale)** je standardizovaný dotazník o deseti položkách měřící celkovou vnímanou použitelnost systému. Každá položka se hodnotí na pětibodové Likertově škále. Výsledné skóre se přepočítává na rozsah 0 až 100. Interpretační pásma: 0-50 neakceptovatelné, 51-68 podprůměrné, 68 průměr, 68-80,3 nadprůměrné, nad 80,3 odpovídá horním 10 % hodnocených systémů.

- Brooke, J. (1996). SUS: A "Quick and Dirty" Usability Scale. V Jordan, P. W., Thomas, B., Weerdmeester, B. A. a McClelland, I. L. (Eds.), *Usability Evaluation in Industry* (s. 189–194). Taylor & Francis.
- Bangor, A., Kortum, P. T. a Miller, J. T. (2009). Determining What Individual SUS Scores Mean: Adding an Adjective Rating Scale. *Journal of Usability Studies*, 4(3), 114–123.
- Web: https://measuringu.com/sus/

**UEQ-S (User Experience Questionnaire – Short)** je zkrácená verze dotazníku UEQ obsahující osm položek ve formě sémantického diferenciálu (škála -3 až +3). Měří dvě dimenze: pragmatickou kvalitu (položky 1-4, zaměřené na efektivitu a srozumitelnost) a hedonickou kvalitu (položky 5-8, zaměřené na originalitu a atraktivitu). Interpretace: pod -0,8 negativní hodnocení, -0,8 až 0,8 neutrální, nad 0,8 pozitivní.

- Schrepp, M., Hinderks, A. a Thomaschewski, J. (2017). Design and Evaluation of a Short Version of the User Experience Questionnaire (UEQ-S). *International Journal of Interactive Multimedia and Artificial Intelligence*, 4(6), 103–108.
- Web: https://www.ueq-online.org
