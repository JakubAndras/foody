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

> Testování bude probíhat tak, že vám postupně zadám několik úloh. U každé úlohy dostanete krátké zadání a pokusíte se ho splnit v aplikaci. Po každé úloze vám položím jednu krátkou otázku o tom, jak snadná pro vás úloha byla. Na závěr vyplníme dva krátké dotazníky a položím vám několik otevřených otázek k celkovému dojmu z aplikace. Celé testování zabere přibližně 75 až 90 minut.

### 5. Záznam a soukromí

> Během testování si budu dělat písemné poznámky. [Pokud nahráváte: Testování budu také nahrávat na obrazovce/zvuk, abych mohl/a zpětně analyzovat průběh.] Veškerá data budou anonymizována a použita výhradně pro účely diplomové práce. Kdykoliv můžete testování ukončit bez udání důvodu.

### 6. Pravidla interakce

> Během plnění úloh se pokusím do vašeho postupu nezasahovat, abych neovlivnil/a vaše přirozené chování. Pokud se zaseknete, zkuste nejprve sami najít cestu. Pokud to opravdu nepůjde, pomohu vám, abyste mohl/a pokračovat dál. Klidně se ptejte, ale některé otázky si nechám na konec, abych neovlivnil/a vaši interakci s aplikací.

### 7. Souhlas a dotazy

> Máte nějaké dotazy, než začneme? [Počkejte na odpověď.] Pokud je vše jasné, můžeme začít první úlohou.

---

## Informace o participantovi

| Údaj                                              | Hodnota                                       |
|---------------------------------------------------|-----------------------------------------------|
| Označení                                          | P1                                            |
| Věk                                               | 28 let                                        |
| Pohlaví                                           | žena                                          |
| Primární cíl (proč by aplikaci používal/a)        | trackování kalorií -> hubnutí                 |
| Zkušenosti s calorie tracking aplikacemi          | střední, opakovaně používal Kalorické tabulky |
| Technologická zdatnost (nízká / střední / vysoká) | střední                                       |
| Datum testování                                   | 21.4.2026                                     |
| Doba testování                                    | 90 minut                                      |
| Zařízení                                          | iPhone 16 Pro                                 |

---

## Úvodní checklist

- [ ] Čistá instalace aplikace (bez předchozích dat)
- [ ] Fotografie jídel nahrány do galerie (pro T3)
- [ ] Reálné jídlo připraveno na stole (pro T2)
- [ ] Balený produkt s čárovým kódem připraven (pro T6)
- [ ] Participant informován o průběhu a přínosu testování
- [ ] Participant instruován k metodě think aloud

---

## Definice metrik

**Kritická chyba** = participant nedokáže pokračovat v úloze bez pomoci moderátora.

**Dokončení s pomocí** = moderátor napoví pomocnou informaci k úloze (např. „zkuste se podívat do nastavení" nebo „hledejte v detailu záznamu"), ale nesmí doslovně navigovat participanta (např. „klikněte sem") ani manipulovat s testovacím zařízením přímo.

---

## Testovací úlohy

---

### T1: Onboarding a nastavení profilu

**Pokryté FR/UC:** FR-03, FR-04, FR-20, UC06

**Zadání pro participanta:** Spusťte aplikaci a projděte úvodním nastavením. Zadejte své údaje (váha, výška, věk), nastavte kalorický cíl a zvolte případné dietní preference.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 6       |

**Poznámky (think aloud, pozorování, problémy):**

```
"This will be used to calibrate your custom plan" na vicero obrazovkach.
Maintain ve vaze udela poskakujici onboarding step.
Recommended -> asi celou obrazovku zahodit a nechat recommended automaticky
custom deita, zustala vysunuta klavesnice
custom dieta, v example dat jako priklad i jen strucne klicova slova
"Estimating your metabolic age..." nahradit nejakou jinou vetou
Congratulations, .. pridat "," za to


```

---

### T2: Záznam jídla z fotografie

**Pokryté FR/UC:** FR-06, FR-07, FR-08, FR-09, UC01

**Zadání pro participanta:** Vyfoťte připravené jídlo na stole a zaznamenejte ho jako oběd.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 6       |

**NFR metriky:**

| NFR metrika | Hodnota   | Limit |
|-------------|-----------|-------|
| Latence AI rozpoznávání (NFR-02) | __6___ s  | 20 s |
| Počet kroků pro zápis (NFR-03) | __5___    | 6 kroků |
| Čas zápisu nového záznamu (NFR-04) | __24___ s | 5 min |

**Poznámky (think aloud, pozorování, problémy):**

```
Mealtime bottomSheet at ma i Check icon nebo at nema krizek tj zadnou ikonu/tlacitko


```

- [ ] Participant si všiml confidence badge .. ano
- [ ] Participant pochopil význam confidence badge .. ano

---

### T3: Import fotografie z galerie

**Pokryté FR/UC:** FR-12

**Zadání pro participanta:** Zaznamenejte jídlo pomocí fotografie z galerie zařízení (vyberte jednu z připravených fotografií).

| Metrika | Hodnota  |
|---------|----------|
| Dokončení (ano / ne / s pomocí) | s pomoci |
| Kritické chyby (počet) | 1        |
| SEQ skóre (1-7) | 5        |

**Poznámky (think aloud, pozorování, problémy):**

```
ikonu fotaku galerie
castecny pristup do galerie rozbil moznost pridat fotografii
v loading karte pisu o notifikaci co prijde po dokonceni rozpoznani jidla, ale zadna neprisla


```

---

### T4: Oprava výsledku AI a re-analýza

**Pokryté FR/UC:** FR-11, FR-13, UC02

**Zadání pro participanta:** Představte si, že AI špatně rozpoznalo vaše poslední jídlo. Použijte funkci na AI opravu výsledku jídla a opravte tak jeho název a množství.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```


```

---

### T5: Záznam jídla hlasem

**Pokryté FR/UC:** FR-14

**Zadání pro participanta:** Zaznamenejte jídlo pomocí hlasového vstupu. Popište, co jste měl/a k snídani (nebo vymyslete příklad).

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 6       |

**NFR metriky:**

| NFR metrika | Hodnota | Limit |
|-------------|---------|-------|
| Počet kroků pro zápis (NFR-03) | __4___  | 6 kroků |

**Poznámky (think aloud, pozorování, problémy):**

```
Hlasove zadavani by mohlo byt vsude (Fix issue atd.)
Z nativni obrazovky pro udeleni permission ji to vratilo na Dashboard a ne na Voice Log obrazovku

```

---

### T6: Skenování čárového kódu

**Pokryté FR/UC:** FR-16, UC04

**Zadání pro participanta:** Naskenujte čárový kód připraveného baleného produktu a uložte ho jako svačinu.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**NFR metriky:**

| NFR metrika | Hodnota | Limit |
|-------------|---------|-------|
| Počet kroků pro zápis (NFR-03) | __2___  | 6 kroků |

**Poznámky (think aloud, pozorování, problémy):**

```
DB na barcode neobsahuje testovany predmet (random kukurice z lidlu), znamejsi produkt to uz rozpoznalo.


```

---

### T7: Ruční přidání záznamu

**Pokryté FR/UC:** FR-01, FR-15, UC03

**Zadání pro participanta:** Přidejte jídlo ručně bez použití fotografie, hlasu nebo čárového kódu. Zadejte název jídla, jeho množství a nutriční hodnoty (kalorie, bílkoviny, sacharidy, tuky).

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**NFR metriky:**

| NFR metrika | Hodnota | Limit   |
|-------------|---------|---------|
| Počet kroků pro zápis (NFR-03) | __9___  | 12 kroků |

**Poznámky (think aloud, pozorování, problémy):**

```
bez zavahani, spravne
chtela by nahrat foto pro sve jidlo longpressem na placeholder v detailu


```

---

### T8: Funkce oblíbené

**Pokryté FR/UC:** FR-17, FR-18, UC05

**Zadání pro participanta:** Představte si, že máte jídlo, které jíte pravidelně. Najděte v aplikaci způsob, jak si jeho opakované zaznamenávání zjednodušit, a následně ho tímto způsobem zaznamenejte jako nový záznam.

| Metrika | Hodnota  |
|---------|----------|
| Dokončení (ano / ne / s pomocí) | s pomoci |
| Kritické chyby (počet) | 1        |
| SEQ skóre (1-7) | 3        |

**NFR metriky:**

| NFR metrika | Hodnota   | Limit |
|-------------|-----------|-------|
| Čas opakovaného záznamu (NFR-04) | __36___ s | 1 min |

**Poznámky (think aloud, pozorování, problémy):**

```
Oblibene ikona proste bude hvezdicka nebo srdicko, spis srdicko.
Hledala vsude mozne v aplikaci, nakonec nasla v Meal Log
Co zobrazit nejaky help dialog kdyz user poprve prida nejake jidlo do favorites


```

---

### T9: Duplikace jídla

**Pokryté FR/UC:** FR-18

**Zadání pro participanta:** Vyberte jedno ze svých jídel a zkopírujte ho do 3 dnů v minulém týdnu.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
_


```

---

### T10: Kalendář na dashboardu

**Pokryté FR/UC:** FR-02

**Zadání pro participanta:** Prozkoumejte kalendář na hlavní obrazovce. Přejděte na jiný měsíc a poté se vraťte na dnešek. Přejděte na o 3 roky zpět a poté se vraťte na dnešek.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```



```

---

### T11: Nastavení množství jídla

**Pokryté FR/UC:** FR-15

**Zadání pro participanta:** U jednoho ze zaznamenaných jídel upravte množství. Řekněme, že jste snědl/a pouze polovinu zvoleného jídla.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 6       |

**Poznámky (think aloud, pozorování, problémy):**

```
dobry, pet osmin lehce matouci, mozna vetsi font
zlomky seradit od nejpouzivanejsich a ne podle velikosti

```

---

### T12: Záznam cvičení hlasem

**Pokryté FR/UC:** (rozšíření nad rámec FR)

**Zadání pro participanta:** Zaznamenejte cvičení pomocí hlasového vstupu. Řekněte například, že jste běžel/a 30 minut.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 5       |

**Poznámky (think aloud, pozorování, problémy):**

```
Sla do exercise a ne do Voice Log. Pridani hlasem dat i primo do exercise.
Nazvy exercise AI nenazve uplne spravne (Tezky intezivni beh nazve jako beh)


```

---

### T13: Zaznamenání váhy

**Pokryté FR/UC:** (rozšíření nad rámec FR)

**Zadání pro participanta:** Zaznamenejte svou aktuální váhu do aplikace.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 6       |

**Poznámky (think aloud, pozorování, problémy):**

```
Personal Details zmenit ikonu na profile/clovicka


```

---

### T14: Denní přehled a smazání záznamu

**Pokryté FR/UC:** FR-02, FR-05, FR-22

**Zadání pro participanta:** Prohlédněte si denní přehled a poté smažte jeden ze zaznamenaných jídel z předchozího týdne (jeden z těch, které jsme vytvořili v dřívějším úkolu).

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```



```

---

### T15: Ask AI

**Pokryté FR/UC:** FR-24, FR-27, UC07

**Zadání pro participanta:** Aplikace disponuje funkcí Ask AI, pomocí které se můžete zeptat AI na cokoliv ohledně svých stravovacích návyků a zaznamenaných dat. Zeptejte se na něco.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```
Ask AI button bz mel bzt disabled pokud je textfield prazdne


```

---

### T16: Export dat

**Pokryté FR/UC:** FR-25

**Zadání pro participanta:** Exportujte svá data z aplikace do souboru pomocí funkce k tomu určené. Formát souboru vyberte podle Vaší preference.

| Metrika | Hodnota |
|---------|---------|
| Dokončení (ano / ne / s pomocí) | ano     |
| Kritické chyby (počet) | 0       |
| SEQ skóre (1-7) | 7       |

**Poznámky (think aloud, pozorování, problémy):**

```



```

---

## Souhrnná tabulka úloh

| Úloha | Dokončení | Krit. chyby | SEQ (1-7) |
|-------|-----------|-------------|-----------|
| T1 | ano | 0 | 6 |
| T2 | ano | 0 | 6 |
| T3 | s pomocí | 1 | 5 |
| T4 | ano | 0 | 7 |
| T5 | ano | 0 | 6 |
| T6 | ano | 0 | 7 |
| T7 | ano | 0 | 7 |
| T8 | s pomocí | 1 | 3 |
| T9 | ano | 0 | 7 |
| T10 | ano | 0 | 7 |
| T11 | ano | 0 | 6 |
| T12 | ano | 0 | 5 |
| T13 | ano | 0 | 6 |
| T14 | ano | 0 | 7 |
| T15 | ano | 0 | 7 |
| T16 | ano | 0 | 7 |
| **Průměr** | 14/16 ano, 2/16 s pomocí | 0,125 | 6,1875 |

---

## SEQ: Single Ease Question

**Otázka po každé úloze:** "Jak snadné bylo pro vás splnit tuto úlohu?"

Škála: 1 = velmi obtížná, 7 = velmi snadná. Benchmark: průměr >= 5,5 = dobré hodnocení.

| Úloha | Skóre (1-7) |
|-------|-------------|
| T1 | 6 |
| T2 | 6 |
| T3 | 5 |
| T4 | 7 |
| T5 | 6 |
| T6 | 7 |
| T7 | 7 |
| T8 | 3 |
| T9 | 7 |
| T10 | 7 |
| T11 | 6 |
| T12 | 5 |
| T13 | 6 |
| T14 | 7 |
| T15 | 7 |
| T16 | 7 |
| **Průměr** | 6,1875 |

---

## SUS: System Usability Scale

**Instrukce pro participanta:** U každého tvrzení označte na škále 1-5, do jaké míry souhlasíte (1 = rozhodně nesouhlasím, 5 = rozhodně souhlasím).

| # | Tvrzení | Skóre (1-5) |
|---|---------|-------------|
| 1 | Myslím, že bych tuto aplikaci rád/a používal/a pravidelně. | 5           |
| 2 | Aplikaci jsem shledal/a zbytečně složitou. | 1           |
| 3 | Myslím, že se aplikace snadno používá. | 4           |
| 4 | Myslím, že bych potřeboval/a pomoc technicky zdatné osoby, abych mohl/a aplikaci používat. | 1           |
| 5 | Jednotlivé funkce aplikace jsou dobře provázané. | 4           |
| 6 | V aplikaci je příliš mnoho nekonzistentností. | 2           |
| 7 | Myslím, že většina lidí by se naučila aplikaci používat velmi rychle. | 4           |
| 8 | Aplikace je velmi těžkopádná na používání. | 1           |
| 9 | Při používání aplikace jsem se cítil/a velmi sebejistě. | 5           |
| 10 | Musel/a jsem se naučit mnoho věcí, než jsem mohl/a aplikaci začít používat. | 1           |

### Výpočet SUS

| Krok | Hodnota |
|------|---------|
| Součet lichých položek (1, 3, 5, 7, 9) = S_L | 5 + 4 + 4 + 4 + 5 = 22 |
| Součet sudých položek (2, 4, 6, 8, 10) = S_S | 1 + 1 + 2 + 1 + 1 = 6 |
| SUS = ((S_L - 5) + (25 - S_S)) * 2,5 | ((22 - 5) + (25 - 6)) * 2,5 = 90 |

**SUS skóre tohoto participanta:** 90 (top 10 %)

Interpretace: 0-50 = neakceptovatelné, 51-68 = podprůměrné, 68 = průměr, 68-80,3 = nadprůměrné, >80,3 = top 10 %

---

## UEQ-S: User Experience Questionnaire Short

**Instrukce pro participanta:** U každé dvojice pojmů označte na škále -3 až +3 pozici, která nejlépe vystihuje váš dojem z aplikace. Záporný pól je vždy vlevo.

### Pragmatická kvalita (položky 1-4)

| # | Levý pól (-3) | -3 | -2 | -1 | 0 | +1 | +2 | +3 | Pravý pól (+3) | Hodnota |
|---|---------------|----|----|----|----|----|----|-----|-----------------|---------|
| 1 | bránící | | | | | | | | podporující | | +2
| 2 | složitý | | | | | | | | jednoduchý | | +2
| 3 | neefektivní | | | | | | | | efektivní | | +2
| 4 | matoucí | | | | | | | | jasný | | +1

### Hedonická kvalita (položky 5-8)

| # | Levý pól (-3) | -3 | -2 | -1 | 0 | +1 | +2 | +3 | Pravý pól (+3) | Hodnota |
|---|---------------|----|----|----|----|----|----|-----|-----------------|---------|
| 5 | nudný | | | | | | | | vzrušující | | +2
| 6 | nezajímavý | | | | | | | | zajímavý | | +1
| 7 | obvyklý | | | | | | | | vynalézavý | | +1
| 8 | tradiční | | | | | | | | moderní | | +3

### Výpočet UEQ-S

| Metrika | Výpočet | Hodnota |
|---------|---------|---------|
| Pragmatická kvalita | průměr položek 1-4 | (2 + 2 + 2 + 1) / 4 = 1,75 |
| Hedonická kvalita | průměr položek 5-8 | (2 + 1 + 1 + 3) / 4 = 1,75 |
| Celkové skóre | průměr položek 1-8 | (2 + 2 + 2 + 1 + 2 + 1 + 1 + 3) / 8 = 1,75 |

Interpretace: <-0,8 = negativní, -0,8 až 0,8 = neutrální, >0,8 = pozitivní

---

## Debriefing: otevřené otázky

**1. Jaký je váš celkový dojem z aplikace?**

```
hezka, minimalisticka, jednoduche barvy, je to prehledny.


```

**2. Co vás na aplikaci nejvíce zaujalo nebo co se vám líbilo?**

```
vizual dashboardu (kalorie, macra), libi se ji minimalisticky design - srovnani oproti Karolickym tabulkam.
vyzenovana aplikace, nevadi ji v ni travit cas


```

**3. Co vám dělalo největší potíže nebo co vás frustrovalo?**

```
komplikace s permissions, ikona zalozky Personal Details v Profilu


```

**4. Máte zkušenosti s jinými aplikacemi pro sledování stravy? Jak byste je porovnal/a s Foody?**

```
Kaloricke tabulky, ktere jsou ale prilis chaoticke, moc prebarvene, zbytecne slozite.


```

**5. Představte si, že by aplikace byla dostupná ke stažení. Používal/a byste ji pravidelně? Proč ano/ne?**

```
ano, je to v jejim zajmu, jelikoz to vypada jako lepsi varianta ke Kalorickym tabulkam. Je to v jejim aktualnim zivotnim zajmu si hlidat kalorie.


```

**6. Jak moc jste důvěřoval/a odhadům aplikace (nutriční hodnoty, rozpoznání jídla)? Kontroloval/a byste si hodnoty ještě jinde?**

```
Kontrolovala by si to u jidel, ktere uz zna, kde ma nejake povedomy. U jidel ktere nezna spise ne. Confidence bagde v Meal Detail hodne pomohl v duvere.


```

**7. Je něco, co byste v aplikaci změnil/a nebo přidal/a?**

```
uz vime z feedbacku behem


```

---

## Další poznámky moderátora

```
_



```

---

## Souhrn výsledků P1

| Metrika | Hodnota | Hodnocení |
|---------|---------|-----------|
| **SEQ průměr** | 6,1875 / 7 | >= 5,5 (dobré) |
| **SUS** | 90 | top 10 % (> 80,3) |
| **UEQ-S pragmatická kvalita** | 1,75 | pozitivní (> 0,8) |
| **UEQ-S hedonická kvalita** | 1,75 | pozitivní (> 0,8) |
| **UEQ-S celkové skóre** | 1,75 | pozitivní (> 0,8) |
| **Dokončení úloh** | 14/16 ano, 2/16 s pomocí | 100 % dokončení |
| **Kritické chyby** | 2 celkem (T3, T8) | průměr 0,125 |
