# Budoucí práce — kontrolovaná validační studie přesnosti AI rozpoznání

**Účel této poznámky:** Zaznamenat návrh kontrolované validační studie, která **nebyla** v rámci této diplomové práce realizována z kapacitních důvodů, ale kterou autor v textu práce uvádí jako **smysluplné rozšíření pro budoucí výzkum**. Slouží jako podklad pro kapitolu *Závěr* / *Budoucí práce*.

---

## Motivace

Dlouhodobé uživatelské testování poskytuje cenná data o akceptaci AI návrhů (kolikrát uživatel návrh přijal, kolikrát ho upravil, jaký byl rozdíl mezi původním a upraveným odhadem) a o subjektivní spokojenosti. **Co ale tato data neposkytují**, je **objektivní referenční pravda** (*ground truth*) o skutečném nutričním obsahu jídla, které tester fotil. Uživatelovy úpravy odhadu jsou totiž jen jeho vlastní *odhad odhadu* — bez kuchyňské váhy a etikety nelze odlišit, zda byl AI nebo uživatel blíže pravdě.

Pro objektivní kvantifikaci přesnosti AI nad reálnými fotkami z mobilního použití by bylo potřeba dataset trojic **(foto, AI odhad, ground truth)** sebraný v kontrolovaných podmínkách.

## Návrh studie

### Vzorek

- **5–10 účastníků**, ideálně podmnožina dlouhodobých testerů, kteří už znají aplikaci a naučili se ji používat.
- **Doba trvání:** 2 týdny souběžně s druhou částí dlouhodobého testu.

### Sběr dat

Každý účastník u **podmnožiny svých jídel** (cílově 3× týdně, tedy ≈ 6 jídel × 5 účastníků = **30 validovaných záznamů**, při 10 účastnících až 60) zaznamenává následující:

1. **Foto pokrmu** přímo v aplikaci (běžný flow).
2. **Zvážení každé komponenty na kuchyňské váze** před konzumací.
3. **Vyfocení etikety / obalu** balených komponent (pro referenční nutriční hodnoty na 100 g).
4. **U domácích pokrmů**: zaznamenání všech surovin a jejich gramáží (recept).

Účastník data dodá ve standardizované šabloně (`validation_template.csv`):

```
photo_id, ingredient, weight_g_measured, calories_per_100g_label, source_label
```

### Zpracování

Z těchto dat vyhodnotitel **ručně dopočítá referenční (ground-truth) hodnoty** (kalorie, B, S, T) pro celé jídlo a porovná je s AI odhadem uloženým v exportovaném CSV (sekce *Meal Details*, sloupce `meal_ai_original_*` zachycují AI odhad před případnou úpravou uživatelem).

### Výstupní metriky

Pro každou nutriční hodnotu (kalorie, bílkoviny, sacharidy, tuky):

- **MAPE** (*Mean Absolute Percentage Error*) — průměrná procentuální chyba.
- **Bland–Altmanův graf** — vizualizace systematického vychýlení AI vůči ground truth.
- **Pearsonův korelační koeficient** mezi AI confidence a velikostí skutečné chyby (kalibrace nejistoty).

Pro identifikaci pokrmu / ingrediencí:

- **Top-1 a Top-3 accuracy** názvu pokrmu (po normalizaci).
- **F1 score** identifikace ingrediencí (precision + recall párováním AI ingrediencí proti referenčnímu seznamu).

### Stratifikace

Výsledky doporučujeme stratifikovat podle:

- typ pokrmu (jednoduchý / smíšený / polévka / balené potraviny / domácí pečivo);
- vstupní modality (`photo_ai`, `voice_ai`, `barcode_ai_fallback`);
- AI provideru a modelu (`ai_provider`, `ai_model`).

## Proč to nebylo realizováno v této práci

- Vyžaduje **vyšší kognitivní zátěž testera** (vážení, focení etiket, dokumentace) než běžné použití aplikace, což by mohlo zkreslit chování uvnitř hlavní studie použitelnosti.
- Kapacitně přesahovalo časový rámec práce.
- Hlavní cíl práce — **použitelnost a životaschopnost konceptu AI tracking aplikace** — je validován i bez tohoto datasetu, kombinací (a) benchmarku AI modelů v kontrolovaných podmínkách, (b) automatické telemetrie z dlouhodobého testu (acceptance rate, distribuce confidence, edit magnitude) a (c) subjektivního hodnocení testerů.

## Přínos pro navazující výzkum

- Realistický referenční dataset z mobilního prostředí (nikoli kurátorovaný benchmark typu Nutrition5k, kde jsou fotky pořizovány v ideálních laboratorních podmínkách).
- Možnost **kalibrace confidence skóre** — ověření, zda AI sama odhaduje míru své jistoty rozumně, nebo je systematicky over-confident / under-confident.
- Podklad pro porovnání nových verzí modelů (např. budoucí GPT, Gemini) na identickém datasetu nad stejným použitím.
- Validace přesnosti **podle vstupní modality** (foto vs. hlasový popis vs. fallback z čárového kódu) — současný benchmark v této práci pokrývá pouze foto-modální vstup.

---

## Post-hoc kalibrace odhadu hmotnosti a kalorií

Analýza signed errors v benchmarku ukázala systematický vzorec chyby závislý na velikosti porce: u velmi malých porcí (pod 100 kcal) AI hodnoty průměrně **nadhodnocuje** (cal_err přibližně +55 %), zatímco u kalorických talířů (nad 400 kcal) je **podhodnocuje** (cal_err přibližně −20 % až −27 %). Hlavním zdrojem chyby je odhad hmotnosti z 2D fotografie pořízené z nadhledu — model defaultuje na typické porce a nedohlédne objem nebo výšku jídla.

Přirozenou otázkou je, zda lze tento bias kompenzovat **post-hoc kalibrací** ve tvaru `true ≈ f(AI_output)` (například izotonickou nebo lineární regresí), která by AI odhad přepočítala před uložením do databáze.

Implementace tohoto přístupu naráží v rámci této práce na několik překážek:

- **Nedostatečná velikost vzorku.** Použitý benchmark čítá 50 talířů, což na fitování spolehlivé kalibrační křivky napříč kalorickým spektrem nestačí. Variance uvnitř jednotlivých kalorických pásem je řádově srovnatelná s průměrným biasem, takže globální korekce by zhoršila případy, kde model náhodou trefil správně.
- **Doménová specifičnost trénovacího datasetu.** Nutrition5k obsahuje fotografie z robotického rigu nad bílým talířem s fixním úhlem a osvětlením. Bias naučený na takových snímcích nemusí stejným způsobem platit pro fotografie pořízené uživateli mobilní aplikace v reálných podmínkách (různé úhly, perspektivní zkreslení, odlesky, jídlo mimo standardní talíř).
- **Riziko overfittingu.** Bez nezávislé testovací sady by jakákoli kalibrace na 50 talířích byla akademicky problematická.

Pro budoucí práci je proto post-hoc kalibrace smysluplným směrem, ale vyžaduje **dataset řádově větší** (stovky až tisíce trojic foto–odhad–ground truth), ideálně sebraný v rámci validační studie popsané výše, tedy z reálného použití aplikace, nikoli z laboratorního benchmarku. Teprve takový dataset by umožnil odhadnout kalibrační funkci s rozumnou konfidencí a nezávisle ji ověřit na hold-out sadě.

---

**Poznámka pro autora:** Tuto poznámku zařadit do kapitoly *Závěr* (sekce *Limitace a budoucí práce*), případně rozšířit o odhad rozsahu (osobo-hodiny, finanční náklady, etika a souhlas s použitím dat).
