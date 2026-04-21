# Podklady pro uživatelské testování aplikace Foody

---

## Úvodní poznámky pro moderátora (co říct participantovi)

Před zahájením testování sdělte participantovi následující body svými slovy. Cílem je, aby se participant cítil pohodlně, rozuměl průběhu a věděl, co se od něj očekává.

### 1. Poděkování a představení

> Děkuji, že jste si udělal/a čas na toto testování. Jmenuji se [jméno] a pracuji na diplomové práci, jejíž součástí je mobilní aplikace pro sledování kalorického příjmu s využitím umělé inteligence. Vaše zpětná vazba mi pomůže identifikovat, co v aplikaci funguje dobře a co je potřeba zlepšit.

### 2. Cíl testování

> Cílem dnešního testování je ověřit použitelnost aplikace. Testujeme aplikaci, ne vás. Neexistují správné ani špatné odpovědi. Pokud se vám něco nepodaří nebo vám něco nebude jasné, je to cenná informace pro mě, protože to ukazuje na problém v návrhu aplikace.

### 3. Metoda think aloud (myšlení nahlas)

> Během testování vás poprosím, abyste nahlas komentoval/a, co děláte, co vidíte na obrazovce, nad čím přemýšlíte a co očekáváte. Říkejte jednoduše, co vás napadá, například: „Teď hledám, kde bych přidal jídlo...", „Tohle tlačítko mi přijde nejasné...", „Čekal/a bych, že se stane tohle...". Nemusíte se snažit o elegantní formulace. Jde o spontánní komentování vašeho myšlenkového procesu.

*Pokud participant během úlohy přestane komentovat, jemně ho pobídněte: „Co teď vidíte?" nebo „Nad čím přemýšlíte?"*

### 4. Průběh testování

> Testování bude probíhat tak, že vám postupně zadám několik úloh. U každé úlohy dostanete krátké zadání a pokusíte se ho splnit v aplikaci. Po každé úloze vám položím jednu krátkou otázku o tom, jak snadná pro vás úloha byla. Na závěr vyplníme dva krátké dotazníky a položím vám několik otevřených otázek k celkovému dojmu z aplikace. Celé testování zabere přibližně 30 minut.

### 5. Záznam a soukromí

> Během testování si budu dělat písemné poznámky. [Pokud nahráváte: Testování budu také nahrávat na obrazovce/zvuk, abych mohl/a zpětně analyzovat průběh.] Veškerá data budou anonymizována a použita výhradně pro účely diplomové práce. Kdykoliv můžete testování ukončit bez udání důvodu.

### 6. Pravidla interakce

> Během plnění úloh se pokusím do vašeho postupu nezasahovat, abych neovlivnil/a vaše přirozené chování. Pokud se zaseknete, zkuste nejprve sami najít cestu. Pokud to opravdu nepůjde, pomohu vám, abyste mohl/a pokračovat dál. Klidně se ptejte, ale některé otázky si nechám na konec, abych neovlivnil/a vaši interakci s aplikací.

### 7. Souhlas a dotazy

> Máte nějaké dotazy, než začneme? [Počkejte na odpověď.] Pokud je vše jasné, můžeme začít první úlohou.

---

## Informace o participantovi

| Údaj                                              | Hodnota                                   |
|---------------------------------------------------|-------------------------------------------|
| Označení                                          | P3                                        |
| Věk                                               | 54 let                                    |
| Pohlaví                                           | žena                                      |
| Primární cíl (proč by aplikaci používal/a)        | dlouhodobě se snaží zhubnout, bez úspěchu |
| Zkušenosti s calorie tracking aplikacemi          | malá, krátce používala Kalorické tabulky  |
| Technologická zdatnost (nízká / střední / vysoká) | střední                                   |
| Datum testování                                   | 20.4.2026 -                               |
| Doba testování                                    | 90 minut                                  |
| Zařízení                                          | iPhone 16 Pro                             |

---

## Úvodní checklist

- [ ] Čistá instalace aplikace (bez předchozích dat)
- [ ] Fotografie jídel nahrány do galerie (pro T3)
- [ ] Reálné jídlo připraveno na stole (pro T2)
- [ ] Balený produkt s čárovým kódem připraven (pro T6)
- [ ] Participant informován o průběhu a přínosu testování
- [ ] Participant instruován k metodě think aloud

---

## Testovací úlohy

---

### T1: Onboarding a nastavení profilu

**Pokryté FR/UC:** FR-03, FR-04, FR-20, UC06

**Zadání pro participanta:** Spusťte aplikaci a projděte úvodním nastavením. Zadejte své údaje (váha, výška, věk), nastavte kalorický cíl a zvolte případné dietní preference.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) |         |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
rekla ze nevi jakou si ma dat rycholost hubnuti na tyden.. po 10 vterinach a zamysleni se si nastavila 0.8kg a je s tim v pohode.
dala vlastni dieta - hned strucne pise alergie a intorelance, idealni pruchod
na 100% screen zustala vysunuta klavesnice .. 
je trosku zmatena z vygenerovaneho planu, necekala ze ma jist vic sacharidu nez bilkovin


```

---

### T2: Záznam jídla z fotografie

**Pokryté FR/UC:** FR-06, FR-07, FR-08, FR-09, UC01

**Zadání pro participanta:** Vyfoťte připravené jídlo na stole a zaznamenejte ho jako oběd.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) |         |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**NFR metriky:**

| NFR metrika | Hodnota              | Limit |
|-------------|----------------------|-------|
| Latence AI rozpoznávání (NFR-02) | __8s___ s            | 20 s |
| Počet kroků pro zápis (NFR-03) | __minimalni mozny___ | 6 kroků |
| Čas zápisu nového záznamu (NFR-04) | __20s___ s           | 5 min |

**Poznámky (think aloud, pozorování, problémy):**

```
sla hned pres plusku, akorat dala Log meal, db mela prazdnou, tak se vratila a az pak dala skenovani fotak. Z mini onboarding necetla, preskakala ho. potom uz v pohode, byla rychla.
meal o tycince ma xy ingredienci

```

- [x] Participant si všiml confidence badge .. nevsimla, je hodne extremne rychla az sbesila
- [x] Participant pochopil význam confidence badge .. ano

---

### T3: Import fotografie z galerie

**Pokryté FR/UC:** FR-12

**Zadání pro participanta:** Zaznamenejte jídlo pomocí fotografie z galerie zařízení (vyberte jednu z připravených fotografií).

| Metrika | Hodnota  |
|---------|----------|
| Dokončení (ano / ne / s pomocí) | s pomoci |
| Kritické chyby (počet) |          |
| SEQ skóre (1-7) | 4        |

**Poznámky (think aloud, pozorování, problémy):**

```
necte texty tlacitek, sbesile klika na main tlacitka jak ji jdou pod ruku
ikona pro vybec fotografie je hodne schovana

```

---

### T4: Oprava výsledku AI a re-analýza

**Pokryté FR/UC:** FR-11, FR-13, UC02

**Zadání pro participanta:** U posledního zaznamenaného jídla upravte název nebo množství jedné položky a poté spusťte opětovnou analýzu pomocí funkce "Fix with AI".

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
_


```

---

### T5: Záznam jídla hlasem

**Pokryté FR/UC:** FR-14

**Zadání pro participanta:** Zaznamenejte jídlo pomocí hlasového vstupu. Popište, co jste měl/a k snídani (nebo vymyslete příklad).

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**NFR metriky:**

| NFR metrika | Hodnota                                                  | Limit |
|-------------|----------------------------------------------------------|-------|
| Počet kroků pro zápis (NFR-03) | __minimalni mozny + dvakrat zapnula/vypnuta nahravani___ | 6 kroků |

**Poznámky (think aloud, pozorování, problémy):**

```



```

---

### T6: Skenování čárového kódu

**Pokryté FR/UC:** FR-16, UC04

**Zadání pro participanta:** Naskenujte čárový kód připraveného baleného produktu a uložte ho jako svačinu.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**NFR metriky:**

| NFR metrika | Hodnota              | Limit |
|-------------|----------------------|-------|
| Počet kroků pro zápis (NFR-03) | __minimalni mozny___ | 6 kroků |

**Poznámky (think aloud, pozorování, problémy):**

```
mealtime v Edit Meal bottomSheet chybi Check button


```

---

### T7: Ruční přidání záznamu

**Pokryté FR/UC:** FR-01, FR-15, UC03

**Zadání pro participanta:** PREFORMULOVAT - Přidejte jídlo ručně bez použití AI. Zadejte název, množství (v gramech i kusech) a nutriční hodnoty.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**NFR metriky:**

| NFR metrika | Hodnota | Limit |
|-------------|-------|-------|
| Počet kroků pro zápis (NFR-03) | _____ | 6 kroků |

**Poznámky (think aloud, pozorování, problémy):**

```
Obrazovku nasla pomerne rychle, sla spravnym smerem. Par sekund ji tvralo nez se zorientovala na Manual Add meal screen.


```

---

### T8: Oblíbené

**Pokryté FR/UC:** FR-17, FR-18, UC05

**Zadání pro participanta:** Označte jedno z dříve zaznamenaných jídel jako oblíbené. Poté toto jídlo zkopírujte na jiný den.

| Metrika | Hodnota  |
|---------|----------|
| Dokončení (ano / ne / s pomocí) | s pomoci |
| Kritické chyby (počet) |          |
| SEQ skóre (1-7) |          |

**NFR metriky:**

| NFR metrika | Hodnota | Limit |
|-------------|---------|-------|
| Čas opakovaného záznamu (NFR-04) | _____ s | 1 min |

**Poznámky (think aloud, pozorování, problémy):**

```
Oblibeny nasla, chtela by srdicko, mel bych na aktivaci zobrazit snackbar ze jidlo je v oblibenych
Nemuze najit oblibena jidla. Jidlo jako oblibene pridala v pohode, ale nevi, kde ty oblibeny jidla jsou.
Zaznamenat jidlo label je nedostatecne jasny. 
Meal Log -> segmentTab Vse, Oblibene .. spatne citelne, jak participant hure vidi, tak si to vubec nevsimnul

```

---

### TA: Duplikace jídla
Vyber jedno ze svych jidel a zkopiruj ho do 3 dnu v minulem tydnu.
Ano
skore 7
okamzite pochopila multicopy funkci



### TB: Calendar na dashboard
navigace v nem, vsechno v pohode, jenom Back to today male pismena
Ano
7
vsechno hned pochopila


### TC: Edit Meal Amount nastaveni
pochopila, ale mala pismena a zbytecne moc moznosti. Ale 1/8 se taky muze hodit rika.
Ano
7


### T9: Záznam cvičení hlasem

**Pokryté FR/UC:** (rozšíření nad rámec FR)

**Zadání pro participanta:** Zaznamenejte cvičení pomocí hlasového vstupu. Řekněte například, že jste běžel/a 30 minut.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 6       |

**Poznámky (think aloud, pozorování, problémy):**

```
Sla na cviceni, tam to nenasla, tak sla na hlasovi zaznam a tam to nasla, toggle spravne prepnula
Dlouhe vstupy to jakoby v pulce usekne (prestane zaznamenavat)
Toggle si nepamatuje posledni moznost, vzdy se nastavi na jidlo

```

---

### T10: Zaznamenání váhy

**Pokryté FR/UC:** (rozšíření nad rámec FR)

**Zadání pro participanta:** Zaznamenejte svou aktuální váhu do aplikace.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
V progressu to hned nasla


```

---

### T11: Denní přehled a smazání záznamu

**Pokryté FR/UC:** FR-02, FR-05, FR-22

**Zadání pro participanta:** Prohlédněte si denní přehled a poté smažte jeden ze zaznamenaných záznamů z predchoziho tydne (jeden z tech, ktere jsme vytvorili v drivejsim kroku).

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
Napad na zlepseni od participanta: Dashboard kalendar by mel zobrazovat nejak ve kterych dnech uz bylo logovano, Bud to hvezdickou, nebo temi kruhy, podobne jako v Progressu
Tapnuti na meal record je intuitivni, participantovi v drivejsich ukolech fungoval, ale participant najednou zacal delat longpress a ten nefunguje.

```

---

### T12: Týdenní přehled a Ask AI

**Pokryté FR/UC:** FR-24, FR-27, UC07

**Zadání pro participanta:** Přejděte na týdenní přehled a poté položte aplikaci otázku v přirozeném jazyce pomocí funkce Ask AI (např. "Kolik kalorií jsem průměrně snědl/a tento týden?").

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
Napad na zlepseni od participanta: Dat Ask AI do Progress obrazovky na konec stranky, v Profilu by to necekala
Napad na zlepseni od participanta: Aby Ask AI podporovala hlasove zadavani vstupu

```

---

### T13: Export dat

**Pokryté FR/UC:** FR-25

**Zadání pro participanta:** Exportujte svá data z aplikace (CSV nebo PDF).

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) |         |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
Po exportu zustala zanorena v export obrazovce, mohla by se vratit na profile + zobrazit snackbar
Participantka necte pomocne texty, kolikrat necte ani texty tlacitek a hned klika -> navrhuje do nasteveni pridat moznost velikosti pisma v aplikaci

```

Pro T12 a T13 coz jsou prvni ukoly z profile participantka nejdrive klikla na Plus FAB, pote se divala v Progress a az na konec to nasla v Profilu

---

## Souhrnná tabulka úloh

| Úloha | Dokončení | Krit. chyby | SEQ (1-7) |
|-------|-----------|-------------|-----------|
| T1 | | | |
| T2 | | | |
| T3 | | | |
| T4 | | | |
| T5 | | | |
| T6 | | | |
| T7 | | | |
| T8 | | | |
| T9 | | | |
| T10 | | | |
| T11 | | | |
| T12 | | | |
| T13 | | | |
| **Průměr** | | | |

---

## SEQ: Single Ease Question

**Otázka po každé úloze:** "Jak snadné bylo pro vás splnit tuto úlohu?"

Škála: 1 = velmi obtížná, 7 = velmi snadná. Benchmark: průměr >= 5,5 = dobré hodnocení.

| Úloha | Skóre (1-7) |
|-------|-------------|
| T1 | |
| T2 | |
| T3 | |
| T4 | |
| T5 | |
| T6 | |
| T7 | |
| T8 | |
| T9 | |
| T10 | |
| T11 | |
| T12 | |
| T13 | |
| **Průměr** | |

---

## SUS: System Usability Scale

**Instrukce pro participanta:** U každého tvrzení označte na škále 1-5, do jaké míry souhlasíte (1 = rozhodně nesouhlasím, 5 = rozhodně souhlasím).

| # | Tvrzení | Skóre (1-5) |
|---|---------|-------------|
| 1 | Myslím, že bych tuto aplikaci rád/a používal/a pravidelně. | 5           |
| 2 | Aplikaci jsem shledal/a zbytečně složitou. | 2           |
| 3 | Myslím, že se aplikace snadno používá. | 4           |
| 4 | Myslím, že bych potřeboval/a pomoc technicky zdatné osoby, abych mohl/a aplikaci používat. | 1           |
| 5 | Jednotlivé funkce aplikace jsou dobře provázané. | 4           |
| 6 | V aplikaci je příliš mnoho nekonzistentností. | 1           |
| 7 | Myslím, že většina lidí by se naučila aplikaci používat velmi rychle. | 5           |
| 8 | Aplikace je velmi těžkopádná na používání. | 1           |
| 9 | Při používání aplikace jsem se cítil/a velmi sebejistě. | 4           |
| 10 | Musel/a jsem se naučit mnoho věcí, než jsem mohl/a aplikaci začít používat. | 1           |

### Výpočet SUS

| Krok | Hodnota |
|------|---------|
| Součet lichých položek (1, 3, 5, 7, 9) = S_L | |
| Součet sudých položek (2, 4, 6, 8, 10) = S_S | |
| SUS = ((S_L - 5) + (25 - S_S)) * 2,5 | |

**SUS skóre tohoto participanta:** ______

Interpretace: 0-50 = neakceptovatelné, 51-68 = podprůměrné, 68 = průměr, 68-80,3 = nadprůměrné, >80,3 = top 10 %

---

## UEQ-S: User Experience Questionnaire Short

**Instrukce pro participanta:** U každé dvojice pojmů označte na škále -3 až +3 pozici, která nejlépe vystihuje váš dojem z aplikace. Záporný pól je vždy vlevo.

### Pragmatická kvalita (položky 1-4)

| # | Levý pól (-3) | -3 | -2 | -1 | 0 | +1 | +2 | +3 | Pravý pól (+3) | Hodnota |
|---|---------------|----|----|----|----|----|----|-----|-----------------|---------|
| 1 | bránící | | | | | | | | podporující | | +3
| 2 | složitý | | | | | | | | jednoduchý | | +2
| 3 | neefektivní | | | | | | | | efektivní | | +3
| 4 | matoucí | | | | | | | | jasný | | +2

### Hedonická kvalita (položky 5-8)

| # | Levý pól (-3) | -3 | -2 | -1 | 0 | +1 | +2 | +3 | Pravý pól (+3) | Hodnota |
|---|---------------|----|----|----|----|----|----|-----|-----------------|---------|
| 5 | nudný | | | | | | | | vzrušující | | +1
| 6 | nezajímavý | | | | | | | | zajímavý | | +3
| 7 | obvyklý | | | | | | | | vynalézavý | | +2
| 8 | tradiční | | | | | | | | moderní | | +3

### Výpočet UEQ-S

| Metrika | Výpočet | Hodnota |
|---------|---------|---------|
| Pragmatická kvalita | průměr položek 1-4 | |
| Hedonická kvalita | průměr položek 5-8 | |
| Celkové skóre | průměr položek 1-8 | |

Interpretace: <-0,8 = negativní, -0,8 až 0,8 = neutrální, >0,8 = pozitivní

---

## Debriefing: otevřené otázky

**1. Jaký je váš celkový dojem z aplikace?**

```
Pekna prace, veri ze uz zhubne. Pry bude furt fotit. Pry uz bude jak influenceri. Pry bude fotit vsechno jidlo.

Napad na zlepseni od participanta: Tvorba receptu na zaklade hlasoveho vstupu.


```

**2. Co vás na aplikaci nejvíce zaujalo nebo co se vám líbilo?**

```
Libilo se ji nejvic hlasove diktovani.


```

**3. Co vám dělalo největší potíže nebo co vás frustrovalo?**

```
Nekdy texty malo citelne, maly font, nektere texty proste prekliknula aniz by je cetla, pak ji ty informace chybely.


```

**4. Máte zkušenosti s jinými aplikacemi pro sledování stravy? Jak byste je porovnal/a s Foody?**

```
Zkusenost s kalorickymi tabulkami, testovana aplikace se ji libi mnohem vic. Hlavne diky rozpoznani jidla z fotografie a diky hlasoveho vstupu.


```

**5. Představte si, že by aplikace byla dostupná ke stažení. Používal/a byste ji pravidelně? Proč ano/ne?**

```
ano, pry lepsi nez kaloricke tabulky


```

**6. Je něco, co byste v aplikaci změnil/a nebo přidal/a?**

```
Nastaveni velikosti pisma, recepty pres hlasovy vstup a toggle v obrazovce hlasoveho vstupu je matouci, nehezky.


```

---

## Další poznámky moderátora

```
_



```
