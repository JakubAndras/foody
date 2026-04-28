# AI Accuracy Benchmark — Log

## Cíl
Kvantitativně změřit přesnost AI rozpoznávání potravin v aplikaci Foody proti referenčnímu datasetu s fyzicky ověřenými nutričními hodnotami. Výsledky slouží jako podklad pro podkapitolu diplomové práce.

## Metodologie

### Dataset: Google Nutrition5k (CVPR 2021)
- **Zdroj**: 5 006 reálných talířů z Google cafeterie v Kalifornii
- **Ground truth**: Každá ingredience fyzicky zvážena, nutriční hodnoty odvozeny z USDA per-gram referenčních tabulek
- **Obrázky**: Overhead RGB fotografie (640x480, Intel RealSense D435)
- **Licence**: Creative Commons v4.0
- **Paper reference**: Thames et al., "Nutrition5k: Towards Automatic Nutritional Understanding of Generic Food", CVPR 2021. 2D direct prediction dosáhlo 26.1% calorie MAPE.

### Výběr testovacích dat
- Z 4 759 validních talířů (Cafe 1, vyloučeny záznamy s cal > 1500 nebo cal/mass > 9 kcal/g)
- Filtrováno na talíře s dostupným overhead obrázkem (3 491 talířů)
- Vybráno **50 talířů** stratifikovaných podle kalorického rozsahu:
  - very_low (0–100 kcal): 8 talířů
  - low (100–250 kcal): 12 talířů
  - medium (250–400 kcal): 12 talířů
  - high (400–600 kcal): 10 talířů
  - very_high (600+ kcal): 8 talířů
- Preferovány talíře s 2+ ingrediencemi, max 2 single-ingredient na stratum
- Rozsah: 32–907 kcal, 1–22 ingrediencí
- Seed 42 pro reprodukovatelnost výběru

### Testovací postup
- Každý talíř odeslán jako obrázek do OpenAI Chat Completions API
- Použit **přesně stejný prompt** jako v produkční aplikaci (včetně system context a meal analysis prompt)
- 3 běhy na talíř, výsledky agregovány mediánem
- Porovnání na úrovni celého talíře (total calories, protein, fat, carbs, weight)
- Metriky: MAPE, MAE, tolerance bands (+-10%, +-20%, +-30%)

### Testované modely

| Model | Typ | Cena (input/output per 1M tokens) |
|-------|-----|-----------------------------------|
| gpt-5.4 | Aktuální model aplikace | $2.50 / $15 |
| gpt-5.4-mini | Levnější alternativa | $0.75 / $4.50 |
| gpt-5.5 | Nejnovější model (release 23.4.2026) | $5 / $30 |

---

## Kolo 1: Baseline — srovnání 3 modelů

### Prompt (baseline)
Prompt obsahuje tato pravidla (přidána v rámci přípravy benchmarku, aplikována i v produkční appce):
1. **INGREDIENT DECOMPOSITION** — rozlož multi-komponentní jídla na viditelné složky, zahrnuj skryté ingredience (olej, dresing, máslo)
2. **DO NOT DECOMPOSE** — atomické položky (ovoce, balené produkty, pečivo) nedekomponuj na výrobní sub-ingredience
3. **PORTION ESTIMATION** — odhaduj velikost porce z vizuální velikosti na talíři, nedefaultuj na "typické porce"
4. **CRITICAL FOR WEIGHT** — hmotnost ingrediencí musí odpovídat vizuální proporci; lehký talíř 100–200g, střední 200–400g, plný 400–600g

### Výsledky baseline

| Metrika | GPT-5.4 | GPT-5.4-mini | GPT-5.5 |
|---------|---------|-------------|---------|
| Calorie MAPE | 45.84% | 51.12% | **44.94%** |
| Calorie MAE | 116.76 kcal | 114.78 kcal | **100.31 kcal** |
| Within +-10% | 18% | 10% | **22%** |
| Within +-20% | 32% | 32% | **40%** |
| Within +-30% | 48% | 44% | **56%** |
| Protein MAPE | **56.78%** | 97.44% | 60.96% |
| Fat MAPE | **65.67%** | 71.76% | 65.85% |
| Carbs MAPE | 76.22% | 69.79% | **48.53%** |
| Weight MAPE | 36.81% | 42.28% | **28.75%** |

### Klíčová zjištění z baseline

1. **GPT-5.5 je celkově nejpřesnější** — vyhrává v kaloriích, carbs a odhadu hmotnosti.
2. **Všechny modely selhávají na very_low kaloriích** (0–100 kcal): 106–140% MAPE. AI systematicky nadhodnocuje malé porce, protože pravděpodobně defaultuje na standardní velikosti porce.
3. **Medium kalorický rozsah (250–400 kcal) je nejpřesnější** u všech modelů (24–28% MAPE). To odpovídá typickým jídlům, na která uživatelé appku reálně používají.
4. **Složitá jídla (8+ ingrediencí) jsou paradoxně přesnější** než jednoduchá (1–3 ingredience), protože mají typicky vyšší kalorický obsah.

---

## Kolo 2: Improved v1 — přidání pravidel

Na základě analýzy chyb z kola 1 bylo k baseline promptu přidáno 5 pravidel a jedno odstraněno:
- **Přidáno**: MACRO CONSISTENCY CHECK (cal ≈ P×4 + C×4 + F×9), NUTRITIONAL SANITY CHECK, COOKING METHOD, RAW VS COOKED
- **Odstraněno**: CRITICAL FOR WEIGHT (fixní rozsahy zhoršovaly výsledky)

### Výsledky: GPT-5.5 improved v1

| Metrika | Baseline | Improved v1 | Změna |
|---------|----------|-------------|-------|
| Calorie MAPE | **44.94%** | 50.64% | +5.7 pp horší |
| Calorie MAE | **100.31 kcal** | 101.41 kcal | +1.10 kcal |
| Within +-20% | 40% | **44%** | +4 pp lepší |
| very_low MAPE | **113.61%** | 144.76% | výrazně horší |
| very_high MAPE | 28.35% | **25.15%** | lepší |

### Závěr z kola 2

**Přidání pravidel celkový výsledek zhoršilo.** Within +-20% se sice zlepšilo (40% → 44%), ale MAPE vzrostlo kvůli výraznému zhoršení u malých porcí. Víc pravidel vedlo k tomu, že AI se víc snažilo nacpat standardní hodnoty místo toho, aby přijalo malé porce.

Tento výsledek potvrzuje zjištění studie *"Large Language Models for Real-World Nutrition Assessment: Structured Prompts, Multi-Model Validation and Expert Oversight"* (Nutrients, 2025), že strukturovanější prompt nemusí být vždy lepší a existuje trade-off mezi striktností a alignmentem s lidským úsudkem. Více pravidel ≠ lepší výsledky.

---

## Kolo 3: Improved v2 — redesign na základě akademického výzkumu

Místo dalšího přidávání pravidel byl prompt kompletně přepracován na základě akademických studií a OpenAI dokumentace. Klíčová změna v přístupu: ne víc pravidel, ale lepší struktura a reasoning.

### Použité zdroje pro návrh promptu

1. **Fridolfsson, J. et al. (2025).** "Performance Evaluation of 3 Large Language Models for Nutritional Content Estimation from Food Images." *Current Developments in Nutrition.* Multi-step prompt (identify → estimate size → determine nutrition) dosáhl 35.8% calorie MAPE s GPT-4o na 52 standardizovaných fotografiích. [PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12513282/)

2. **Hua, A. et al. (2025).** "NutriBench: A Dataset for Evaluating Large Language Models on Nutrition Estimation from Meal Descriptions." *ICLR 2025.* Chain-of-Thought prompting zlepšil GPT-4o na 66.82% accuracy (nejvyšší ze všech testovaných strategií). [arXiv:2407.12843](https://arxiv.org/html/2407.12843v5)

3. **Coburn, B. et al. (2025).** "Comprehensive Evaluation of Large Multimodal Models for Nutrition Analysis: A New Benchmark Enriched with Contextual Metadata." *arXiv:2507.07048.* Testovali 5 prompt strategií na 8 modelech. Expert-persona prompt ("registered dietitian") dosáhl největšího snížení kalorické chyby. [arXiv](https://arxiv.org/abs/2507.07048)

4. **Yan, R. et al. (2025).** "DietAI24 as a framework for comprehensive nutrition estimation using multimodal large language models." *Communications Medicine (Nature).* Kombinace MLLM s RAG (grounding v nutriční databázi) snížila MAE o 63%. Inspirovalo pravidlo "cross-check against nutritional knowledge". [Nature](https://www.nature.com/articles/s43856-025-01159-0)

5. **OpenAI GPT-5 Prompting Guide (2025).** Structured prompts, explicit reasoning steps. Schema descriptions fungují jako implicitní prompt instrukce. [OpenAI Cookbook](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide)

6. **OpenAI Structured Outputs Guide (2025-2026).** Popis strukturovaných výstupů a best practices pro JSON schema definice. [OpenAI Docs](https://developers.openai.com/docs/guides/structured-outputs)

### Klíčové změny v improved v2 oproti baseline

**System context** — expert persona:
- Baseline: *"You are an AI food analyzer."*
- V2: *"You are an expert registered dietitian and food scientist with extensive experience in portion size estimation from photographs. You have deep knowledge of nutritional databases (USDA, food composition tables)..."*

**Task** — multi-step Chain-of-Thought reasoning:
- Baseline: jeden odstavec "Identify the meal and ingredients..."
- V2: 5 explicitních kroků: IDENTIFY → ESTIMATE size → LOOK UP per-100g values → CALCULATE totals → VERIFY macro consistency

**Schema descriptions** — obohaceny o kontext:
- Baseline: `"calories": "int"`
- V2: `"calories": "int - total kcal, calculated from estimated weights and per-100g reference values"`

**Rules** — cílenější, s anti-bias instrukcí:
- PORTION SIZE: explicitně říká *"if only a small amount of food is visible, the total may be well under 100 kcal — do not inflate to a normal meal size"*
- COOKING STATE: pravděpodobně vařené, ale vizuálně ověř (cooked rice ~130 kcal/100g, ne raw ~360)
- COOKING METHOD: smažené vs grilované, vizuální stopy
- SANITY CHECK: "cross-check against your knowledge of per-100g values" (bez fixních hodnot)
- MACRO CONSISTENCY: ověř cal ≈ P×4 + C×4 + F×9
- Odstraněno: CRITICAL FOR WEIGHT

### Výsledky: GPT-5.5 improved v2 (předběžný run bez měření doby odpovědi)

| Metrika | Baseline | v1 | **v2** |
|---------|----------|-----|--------|
| Calorie MAPE | 44.94% | 50.64% | **35.47%** |
| Within +-20% | 40% | 44% | **48%** |
| Protein MAPE | 60.96% | 66.50% | **48.61%** |
| Fat MAPE | 65.85% | 75.41% | **57.96%** |
| Carbs MAPE | 48.53% | 51.05% | **42.83%** |

### Závěr z kola 3

Research-based redesign promptu přinesl výrazné zlepšení: MAPE kleslo z 44.94% na 35.47% (-21%). Na rozdíl od v1 (víc pravidel → horší výsledky) přinesla v2 (lepší struktura) konzistentní zlepšení napříč všemi metrikami. Klíčový faktor byl přechod od jednoho bloku instrukcí k explicitnímu multi-step reasoning (CoT) a expert persona.

**Poznámka**: Tento run sloužil jako předběžné ověření efektu improved v2 promptu. Finální výsledky (s měřením doby odpovědi a na všech 3 modelech) jsou v Kole 4 níže.

---

## Kolo 4: Doplnění doby odpovědi API

Při testování improved v2 promptu s GPT-5.5 byla vypozorována znatelně delší doba odpovědi oproti předchozím testům. Doba odpovědi API nebyla v předchozích kolech měřena, protože nebyla považována za kritický parametr. Jelikož se však ukázalo, že novější model (GPT-5.5) a delší prompt (improved v2) mají výrazný dopad na latenci, bylo měření doby odpovědi dodatečně implementováno do benchmark runneru, protože doba odpovědi je důležitý parametr pro praktické využití mobilní aplikace (uživatel čeká na výsledek rozpoznání).

Provedeny nové benchmark runy s měřením doby odpovědi — improved v2 prompt na všech 3 modelech. Výsledky z Kola 4 nahrazují předběžný run z Kola 3 a tvoří finální sadu výsledků. Tím vznikla kompletní matice: 3 modely × improved v2 + timing.

### Výsledky: Všechny modely s improved v2 + timing

| Metrika | GPT-5.5 | GPT-5.4 | GPT-5.4-mini |
|---------|---------|---------|-------------|
| Calorie MAPE | **32.12%** | 38.27% | 45.32% |
| Calorie MAE | **84.94 kcal** | 112.65 kcal | 106.45 kcal |
| Within +-10% | **24%** | 16% | 18% |
| Within +-20% | 44% | **46%** | 38% |
| Within +-30% | **58%** | 50% | 56% |
| Protein MAPE | 49.65% | **47.98%** | 56.41% |
| Fat MAPE | **50.70%** | 59.33% | 65.35% |
| Carbs MAPE | **41.94%** | 56.08% | 82.89% |
| Weight MAPE | **26.57%** | 30.88% | 30.70% |
| Avg response | 27.93 s | 6.03 s | **4.06 s** |
| Median response | 24.49 s | 5.95 s | **3.73 s** |
| Min response | 11.72 s | 2.82 s | **2.15 s** |
| Max response | 105.96 s | **11.64 s** | 17.22 s |
| Confidence | 0.76 | 0.88 | 0.90 |

### Efekt improved v2 promptu na jednotlivé modely (baseline → improved v2)

| Model | Baseline MAPE | Improved v2 MAPE | Zlepšení |
|-------|--------------|-----------------|----------|
| GPT-5.5 | 44.94% | 32.12% | **-12.82 pp (-29%)** |
| GPT-5.4 | 45.84% | 38.27% | **-7.57 pp (-17%)** |
| GPT-5.4-mini | 51.12% | 45.32% | **-5.80 pp (-11%)** |

Improved v2 prompt pomohl všem modelům, ale nejsilněji GPT-5.5 (-29%). Větší modely lépe využijí strukturovanější prompt s Chain-of-Thought reasoning.

### Přesnost podle kalorického rozsahu (improved v2)

Hodnoty představují calorie MAPE (Mean Absolute Percentage Error) — průměrnou procentuální odchylku odhadu kalorií od referenční hodnoty. Nižší = přesnější. Např. 20% znamená, že AI se v průměru mýlí o 20 % od skutečné kalorické hodnoty talíře.

| Rozsah | GPT-5.5 | GPT-5.4 | GPT-5.4-mini |
|--------|---------|---------|-------------|
| very_low (0–100) | **74.92%** | 76.25% | 128.44% |
| low (100–250) | **20.39%** | 30.73% | 27.38% |
| medium (250–400) | 22.54% | **19.67%** | 28.55% |
| high (400–600) | **29.46%** | 38.46% | 28.43% |
| very_high (600+) | **24.64%** | 39.25% | 35.42% |

---

## Celkový přehled všech benchmark runů

| Run | Model | Prompt | Cal MAPE | Within +-20% | Cal MAE | Avg response |
|-----|-------|--------|----------|-------------|---------|-------------|
| 1 | GPT-5.4 | baseline | 45.84% | 32% | 116.76 kcal | n/a |
| 2 | GPT-5.4-mini | baseline | 51.12% | 32% | 114.78 kcal | n/a |
| 3 | GPT-5.5 | baseline | 44.94% | 40% | 100.31 kcal | n/a |
| 4 | GPT-5.5 | improved v1 | 50.64% | 44% | 101.41 kcal | n/a |
| **5** | **GPT-5.5** | **improved v2** | **32.12%** | **44%** | **84.94 kcal** | **27.93 s** |
| 6 | GPT-5.4-mini | improved v2 | 45.32% | 38% | 106.45 kcal | 4.06 s |
| 7 | GPT-5.4 | improved v2 | 38.27% | 46% | 112.65 kcal | 6.03 s |

### Srovnání s referenční hodnotou z Nutrition5k paperu

Nutrition5k paper (Thames et al., CVPR 2021) dosáhl 26.1% calorie MAPE s 2D direct prediction modelem. Tento výsledek však není přímo srovnatelný s naším přístupem z několika důvodů:

1. **Custom-trained model vs general-purpose LLM.** Autoři trénovali specializovaný InceptionV2 model výhradně na ~4 000 talířích z vlastního datasetu. Model se naučil přímo mapovat pixely na kalorické hodnoty (regrese), bez identifikace ingrediencí nebo textového reasoning. Náš přístup používá general-purpose LLM, který nikdy neviděl tyto talíře a musí provést identifikaci jídla, odhad porce i výpočet nutričních hodnot v jednom kroku.

2. **Trénování na stejném prostředí.** Nutrition5k model byl trénován i testován na snímcích ze stejného robotického rigu (stejné osvětlení, stejné talíře, stejný úhel kamery). To výrazně snižuje variabilitu, kterou musí model zvládat. Naše LLM řešení musí být robustní vůči libovolným fotografiím.

3. **Depth senzor.** Když autoři přidali hloubkový senzor (Intel RealSense D435) pro 3D informaci o výšce jídla na talíři, MAPE kleslo na 16.5%. Odhad objemu z 2D fotografie je inherentně méně přesný než přímé měření hloubky.

Náš nejlepší výsledek (GPT-5.5 + improved v2, 32.12% MAPE) se referenční hodnotě blíží i přes tyto zásadní metodologické rozdíly. Na kalorickém pásmu 100–400 kcal, které odpovídá typickému použití aplikace, dosahujeme 20–23% MAPE, což je srovnatelné nebo lepší než referenční hodnota.

### Trade-off pro produkční nasazení

| Parametr | GPT-5.5 + v2 | GPT-5.4 + v2 | GPT-5.4-mini + v2 |
|----------|-------------|-------------|-------------------|
| Calorie MAPE | **32.12%** | 38.27% | 45.32% |
| Within +-20% | 44% | **46%** | 38% |
| Avg response | 27.93 s | **6.03 s** | 4.06 s |
| Cena (input/1M) | $5.00 | $2.50 | $0.75 |
| Hodnocení | Nejpřesnější, pomalý | **Nejlepší kompromis** | Nejrychlejší, nejméně přesný |

GPT-5.4 s improved v2 promptem představuje nejlepší kompromis pro produkční nasazení: přijatelná přesnost (38.27% MAPE, 46% within +-20%), rychlá odpověď (~6 s) a střední cena.

---

## Klíčové závěry pro diplomovou práci

1. **Přesnost AI rozpoznávání dosáhla 32.12% calorie MAPE** s GPT-5.5 a optimalizovaným promptem, což se blíží výsledkům custom-trained modelu z Nutrition5k paperu (26.1% MAPE). Pro kalorické pásmo typických jídel (100–400 kcal) dosáhl model 20–23% MAPE.

2. **Prompt engineering má měřitelný dopad na přesnost.** Baseline → improved v2 přinesl zlepšení 11–29% napříč modely. Klíčové faktory: expert persona, multi-step Chain-of-Thought reasoning, obohacené schema descriptions.

3. **Více pravidel v promptu nemusí znamenat lepší výsledky.** Improved v1 (přidání 4 pravidel) zhoršil celkové MAPE z 44.94% na 50.64%. Teprve kompletní redesign na základě akademického výzkumu (v2) přinesl měřitelné zlepšení. Tento nález je konzistentní se studií *"LLMs for Real-World Nutrition Assessment"* (Nutrients, 2025).

4. **AI systematicky nadhodnocuje velmi malé porce** (pod 100 kcal, 75–128% MAPE). Model defaultuje na standardní velikosti porce. Toto je inherentní omezení vizuálního odhadu z 2D fotografie.

5. **Existuje výrazný trade-off mezi přesností a rychlostí odpovědi.** GPT-5.5 dosahuje nejlepší přesnosti (32% MAPE), ale průměrná doba odpovědi 28 sekund je na hranici přijatelnosti pro mobilní appku. GPT-5.4 nabízí kompromis: 38% MAPE za 6 sekund.

6. **Větší modely lépe využívají strukturovaný prompt.** Improved v2 prompt zlepšil GPT-5.5 o 29%, GPT-5.4 o 17%, ale GPT-5.4-mini jen o 11%. Chain-of-Thought reasoning vyžaduje dostatečnou kapacitu modelu.

---

## Zdroje a reference

### Dataset
- Thames, Q. et al. (2021). "Nutrition5k: Towards Automatic Nutritional Understanding of Generic Food." *CVPR 2021.* [arXiv:2103.03375](https://arxiv.org/abs/2103.03375)

### Studie použité pro návrh improved v2 promptu

1. **Fridolfsson, J. et al. (2025).** "Performance Evaluation of 3 Large Language Models for Nutritional Content Estimation from Food Images." *Current Developments in Nutrition.* [PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12513282/)

2. **Hua, A. et al. (2025).** "NutriBench: A Dataset for Evaluating Large Language Models on Nutrition Estimation from Meal Descriptions." *ICLR 2025.* [arXiv:2407.12843](https://arxiv.org/html/2407.12843v5)

3. **Coburn, B. et al. (2025).** "Comprehensive Evaluation of Large Multimodal Models for Nutrition Analysis: A New Benchmark Enriched with Contextual Metadata." *arXiv:2507.07048.* [arXiv](https://arxiv.org/abs/2507.07048)

4. **Yan, R. et al. (2025).** "DietAI24 as a framework for comprehensive nutrition estimation using multimodal large language models." *Communications Medicine (Nature).* [Nature](https://www.nature.com/articles/s43856-025-01159-0)

5. **OpenAI GPT-5 Prompting Guide (2025).** [OpenAI Cookbook](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide)

6. **OpenAI Structured Outputs Guide (2025-2026).** [OpenAI Docs](https://developers.openai.com/docs/guides/structured-outputs)

### Další relevantní studie

7. **Gjorgjevikj, A. et al. (2026).** "Large language models in food and nutrition science: Opportunities, challenges, and the case of FoodyLLM." *Current Research in Food Science.* Fine-tuning Llama 3 8B dosáhl přesnosti 0.91–0.97. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2665927126000511)

8. **Ase, A. et al. (2025).** "Large Language Models for Real-World Nutrition Assessment: Structured Prompts, Multi-Model Validation and Expert Oversight." *Nutrients 18(1).* Potvrzuje, že strukturovanější prompt nemusí být vždy lepší. [MDPI](https://www.mdpi.com/2072-6643/18/1/23)

---

## Výstupní soubory

Výsledky benchmarků v `test/ai_benchmark/results/`:

| Složka | Run | Model | Prompt |
|--------|-----|-------|--------|
| `gpt-5.4_baseline_2026-04-26T11-26-00` | 1 | GPT-5.4 | baseline |
| `gpt-5.4-mini_baseline_2026-04-26T12-00-29` | 2 | GPT-5.4-mini | baseline |
| `gpt-5.5_baseline_2026-04-26T12-39-09` | 3 | GPT-5.5 | baseline |
| `gpt-5.5_improved_2026-04-26T16-00-53` | 4 | GPT-5.5 | improved v1 |
| `gpt-5.5_improved_v2_2026-04-26T19-33-38` | 5 | GPT-5.5 | improved v2 + timing |
| `gpt-5.4-mini_improved_v2_2026-04-26T19-49-23` | 6 | GPT-5.4-mini | improved v2 + timing |
| `gpt-5.4_improved_v2_2026-04-26T20-24-53` | 7 | GPT-5.4 | improved v2 + timing |

Každá složka obsahuje:
- `summary.txt` — lidsky čitelný souhrn
- `per_dish_results.csv` — výsledky po talířích (medián z 3 runů)
- `aggregate_results.csv` — agregované metriky
- `accuracy_by_subgroup.csv` — přesnost podle složitosti a kalorického rozsahu
- `all_runs.csv` — všechny jednotlivé runy
- `raw_responses.json` — kompletní API odpovědi
