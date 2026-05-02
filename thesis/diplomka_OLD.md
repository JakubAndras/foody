

*PODĚKOVÁNÍ*

*PROHLÁŠENÍ*

Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v souladu s Metodickým pokynem o dodržování etických principů při přípravě vysokoškolských závěrečných prací.

V Praze dne

........................................

Jakub Sebastian Andráš

Abstrakt

Cílem této práce je

Výsledkem této práce je

Klíčová slova

Obsah

*ZKRATKY*

Definice použitých zkratek a pojmů.

AIUmělá inteligence(Artificial Intelligence)

OCROptické rozpoznávání znaků(Optical Character Recognition)

EANEvropské číslo výrobku(European Article Number)

TEE

BMR

TEF

## ÚVOD

Udržování zdravého životního stylu a optimální tělesné kondice představuje klíčový aspekt moderního pojetí kvality života. Tento význam je zdůrazněn nejen individuálními cíli, jako je zvýšení energie či osobní spokojenosti, ale také aktuálními zdravotními trendy populace. Podle dostupných dat se Češi umisťují na čtvrtém místě v žebříčku evropských zemí z hlediska výskytu nadváhy a obezity. Celkem 55,4 % české populace má tělesnou hmotnost vyšší než doporučené normy. Horší jsou pouze Řecko, Chorvatsko a Malta, kde tento podíl dosahuje až 59,6 % [1].

Motivace k osvojování udržitelných stravovacích a pohybových návyků je proto více než aktuální a různorodá, a to od prevence civilizačních chorob až po snahu o zlepšení celkové fyzické kondice a životní pohody. Dosažení těchto cílů však vyžaduje systematický a informovaný přístup, který přesahuje pouhé počáteční odhodlání a opírá se o vědecké poznatky o výživě, energetickém příjmu a výdeji, stejně jako o praktické nástroje pro monitorování a optimalizaci životního stylu.

Základním principem regulace tělesné hmotnosti je energetická bilance. Tento koncept definuje vztah mezi kaloriemi přijatými ve stravě a energií, kterou tělo spotřebuje na svůj provoz a veškerou fyzickou aktivitu. Ačkoliv je tato myšlenka ve své podstatě jednoduchá, její praktická aplikace naráží na řadu překážek. Mnoho lidí své úsilí vzdává, protože manuální zaznamenávání stravy je vnímáno jako zdlouhavé a nepraktické pro každodenní použití. Bez systematického přehledu se pak snadno uchylují k neefektivním dietním zkratkám, které nevedou k dlouhodobým výsledkům.

Moderní technologie nabízejí jedno z možných řešení těchto problémů. Zejména mobilní aplikace se staly rozšířeným nástrojem, který dokáže uživatele provázet jejich snahou, poskytovat jim okamžitou zpětnou vazbu a uchovávat data potřebná pro kvalifikovaná rozhodnutí o jídelníčku a pohybové aktivitě. Současně se rozvíjí oblast umělé inteligence a počítačového vidění, která umožňuje částečně automatizovat dosud manuální úlohy, například odhad složení jídla z fotografie.

Náplní této práce je prozkoumat potenciál nejnovějších pokroků v oblasti umělé inteligence pro zjednodušení sledování kalorického příjmu. Hlavním cílem je navrhnout a částečně realizovat aplikaci, která využívá schopností pokročilých AI modelů k automatické analýze jídla z fotografie, čímž odstraňuje část bariér spojených s ručním zapisováním a činí proces správy jídelníčku efektivnější a uživatelsky přijatelnější.

Dílčími cíli práce jsou provedení rešerše současné odborné literatury v oblasti digitálních nástrojů pro výživu a využití AI v této doméně, dále analýza stávajících řešení na trhu, která umožní identifikovat silné a slabé stránky konkurence a definovat prostor pro inovaci. Na tuto analýzu navazuje výběr vhodných technologií a nástrojů, které budou pro potřeby implementace dostatečně výkonné a zároveň prakticky použitelné. Neméně důležitou fází práce je návrh softwarové architektury pro zajištění spolehlivého chodu a efektivní komunikace mezi jednotlivými komponentami systému a vytvoření přehledného a intuitivního uživatelského rozhraní.

Na úvodní kapitolu proto navazuje část věnovaná rešerši odborných zdrojů a existujících mobilních aplikací pro sledování stravy. Ta vytváří kontext pro návrh vlastního řešení a umožňuje zasadit diskutovanou aplikaci do širšího rámce digitálního zdraví a výzkumu v oblasti výživy.

## ANALÝZA

### **Obezita, nadváha a význam sledování stravy**

Obezita a nadváha patří mezi klíčové determinanty morbidity a mortality v rozvinutých i rozvojových zemích. Dlouhodobě zvýšená tělesná hmotnost je spojena se zvýšeným rizikem kardiovaskulárních onemocnění, diabetu 2. typu, některých nádorových onemocnění a zhoršenou kvalitou života. Epidemiologická data ukazují, že Česká republika patří v rámci Evropské unie k zemím s nejvyšším podílem osob s nadváhou a obezitou. Podle analýzy Evropa v datech má nadváhu nebo obezitu přibližně 55,4 % české populace, což Českou republiku řadí na čtvrté místo v Evropě [1]. Tato čísla podtrhují potřebu účinných strategií prevence a léčby.

#### **Index tělesné hmotnosti a jeho interpretace**

Základním orientačním ukazatelem pro posouzení tělesné hmotnosti je index tělesné hmotnosti (Body Mass Index, BMI). BMI se vypočítá jako podíl tělesné hmotnosti v kilogramech a druhé mocniny tělesné výšky v metrech:

Na základě hodnoty BMI se rozlišují jednotlivé kategorie výživového stavu, které jsou shrnuty v tabulce 2.1.

**Tab. 2.1 ***Hodnoty BMI a jejich interpretace*

BMI je pro populační studie a rychlé screeningové hodnocení velmi užitečné, protože umožňuje jednoduché srovnání mezi jedinci i populacemi. Současně má však významná omezení. Nezohledňuje rozložení tuku v těle, podíl svalové hmoty ani individuální rozdíly v tělesném složení. U sportovců nebo lidí s vysokým podílem svalové hmoty může proto docházet k systematické klasifikaci do nadváhy či obezity, ačkoli jejich zdravotní riziko tomu neodpovídá [13]. BMI by tak měl být v klinické i praktické práci vnímán jako orientační ukazatel, který je vhodné doplnit dalšími měřeními (obvod pasu, složení těla, laboratorní ukazatele).

#### **Životní styl, energetická bilance a rozvoj obezity**

Současné konceptuální modely chápou obezitu jako dlouhodobý důsledek pozitivní energetické bilance, kdy energetický příjem převyšuje energetický výdej. Theodorakis a Nikolaou popisují, že do energetické bilance vstupuje řada vzájemně provázaných proměnných, například bazální metabolismus, termický efekt potravy, spontánní pohyb, strukturovaná fyzická aktivita a adaptivní metabolické změny [13]. To znamená, že dvě osoby se stejným kalorickým příjmem a podobnou tělesnou hmotností mohou mít odlišný dlouhodobý vývoj hmotnosti v závislosti na rozdílech v energetickém výdeji a hormonální regulaci.

Drenowatz a Greier zdůrazňují, že efektivní řízení tělesné hmotnosti vyžaduje současnou práci se stravou i fyzickou aktivitou. Izolované intervence zaměřené pouze na dietní omezení nebo pouze na cvičení dosahují obvykle menšího a hůře udržitelného efektu než integrované přístupy, které systematicky pracují s oběma složkami energetické bilance [14]. Z hlediska návrhu digitálních nástrojů je proto důležité uvažovat tělesnou hmotnost v širším kontextu životního stylu, nikoli jen jako mechanický výsledek krátkodobého kalorického deficitu.

### **Self monitoring jako nástroj řízení hmotnosti**

Jedním z klíčových behaviorálních principů používaných v programech redukce hmotnosti je self monitoring, tedy systematické sledování vlastního chování. V oblasti výživy se self monitoring nejčastěji projevuje jako pravidelný záznam konzumovaných jídel, sledování tělesné hmotnosti a zaznamenávání fyzické aktivity. Cílem je zvýšit povědomí o vlastních návycích a umožnit uživateli, aby své chování průběžně upravoval v souladu s doporučeními.

Systematické přehledy ukazují, že pravidelný self monitoring příjmu potravy a tělesné hmotnosti je spojen s větším úbytkem hmotnosti a lepším udržením dosažených změn než situace, kdy je sledování nepravidelné nebo zcela chybí. Zároveň se ukazuje, že self monitoring lze realizovat různými způsoby od papírových deníků až po digitální nástroje a mobilní aplikace, přičemž forma záznamu ovlivňuje jak přesnost dat, tak dlouhodobou udržitelnost celého procesu. Detailní přehled digitálních nástrojů pro sledování výživy a jejich charakteristik je proto věnován samostatné podkapitole 2.4 [18,19].

Souhrnně lze říci, že obezita a nadváha představují významný zdravotní problém v České republice i celosvětově a že self monitoring patří mezi hlavní behaviorální nástroje pro redukci a udržení tělesné hmotnosti. Jeho dlouhodobá účinnost je však omezená tím, že pravidelné zaznamenávání jídel a souvisejících údajů je časově i kognitivně náročné, což vede u řady uživatelů k postupnému poklesu frekvence záznamů a k oslabení efektu jinak dobře nastavených intervencí. Tento kontext vytváří přímou motivaci pro hledání nástrojů, které sníží zátěž spojenou se sledováním stravy a tím zvýší pravděpodobnost, že uživatelé budou nástroj využívat konzistentně i v delším časovém horizontu [11,12,13].

### Energetická bilance a nutriční základy

Pochopení principu energetické bilance je zásadní pro interpretaci výstupů z každé aplikace, která pracuje s kalorickým příjmem a výdejem. Tato podkapitola shrnuje základní pojmy z oblasti energetického metabolismu a nutričních základů, na nichž bude dále stavět návrh a implementace aplikace.

#### **Kalorie a energetická hodnota potravin**

V nutriční praxi se jako jednotka energie používá kilokalorie (kcal), případně kilojoule (kJ). Jedna kilokalorie odpovídá množství energie potřebné ke zvýšení teploty jednoho kilogramu vody o jeden stupeň Celsia. V běžné komunikaci se pojem „kalorie“ používá téměř vždy ve významu kilokalorie. Energetická hodnota potravin vyjadřuje množství energie, které organismus může z dané potraviny získat. Základní makroživiny se liší i svou energetickou hodnotou. Sacharidy a bílkoviny poskytují přibližně 4 kcal na gram, zatímco tuky zhruba 9 kcal na gram, tedy více než dvojnásobek [13].

Pro udržení tělesné hmotnosti v rovnováze musí být dlouhodobě energetický příjem z potravin v rovnováze s energetickým výdejem. Systematické odchylky v podobě chronického kalorického deficitu nebo nadbytku vedou k postupné změně tělesné hmotnosti [13].

#### **Složky energetického výdeje**

Celkový denní energetický výdej (TEE) se obvykle rozděluje na několik složek:

bazální metabolismus (BMR),

termický efekt potravy (TEF),

energetický výdej na fyzickou aktivitu, který zahrnuje jak strukturované cvičení, tak běžný denní pohyb.

Theodorakis a Nikolaou uvádějí, že u většiny dospělé populace tvoří bazální metabolismus přibližně 60 až 75 % celkového energetického výdeje. Zbývající část připadá na termický efekt potravy a fyzickou aktivitu, přičemž jejich relativní význam se může výrazně lišit v závislosti na životním stylu [13].

Bazální metabolismus představuje množství energie, které organismus potřebuje v klidových podmínkách pro udržení základních životních funkcí, jako je činnost srdce a plic, udržování tělesné teploty a syntéza tkání. Je ovlivněn především:

množstvím a složením tělesné hmoty (zejména podílem beztukové hmoty),

věkem,

pohlavím,

genetickými faktory a hormonálním stavem.

#### **Prediktivní rovnice pro odhad bazálního metabolismu**

Přímé měření energetického výdeje prostřednictvím nepřímé kalorimetrie není v běžné praxi ani v uživatelských aplikacích reálně dostupné. Proto se využívají empirické prediktivní rovnice, které odhadují BMR na základě snadno měřitelných parametrů, jako jsou hmotnost, výška, věk a pohlaví. Mezi nejpoužívanější patří Harris-Benedictova a Mifflin-St Jeorova rovnice.

Harris-Benedictova rovnice byla publikována již v roce 1919 a patří k historicky nejpoužívanějším metodám odhadu bazálního metabolismu. V revidované podobě má následující tvar:

*𝐵𝑀𝑅 𝑚𝑢ž𝑖 = 66 + (13,7 × ℎ𝑚𝑜𝑡𝑛𝑜𝑠𝑡 𝑘𝑔) + (5 × 𝑣ýš𝑘𝑎 𝑐𝑚) − (6,8 × 𝑣ě𝑘 𝑣 𝑙𝑒𝑡𝑒𝑐ℎ)*

*𝐵𝑀𝑅 ž𝑒𝑛𝑦 = 655 + (9,6 × ℎ𝑚𝑜𝑡𝑛𝑜𝑠𝑡 𝑘𝑔) + (1,8 × 𝑣ýš𝑘𝑎 𝑐𝑚) − (4,7 × 𝑣ě𝑘 𝑣 𝑙𝑒𝑡𝑒𝑐ℎ)*

Mifflin-St Jeorova rovnice byla navržena v roce 1990 a řada novějších studií ji hodnotí jako přesnější pro běžnou dospělou populaci. Její tvar je [15]:

*𝐵𝑀𝑅 𝑚𝑢ž𝑖 = (10 × ℎ𝑚𝑜𝑡𝑛𝑜𝑠𝑡 𝑘𝑔) + (6,25 × 𝑣ýš𝑘𝑎 𝑐𝑚)− (5 × 𝑣ě𝑘 𝑣 𝑙𝑒𝑡𝑒𝑐ℎ) + 5*

*𝐵𝑀𝑅 ž𝑒𝑛𝑦 = (10 × ℎ𝑚𝑜𝑡𝑛𝑜𝑠𝑡 𝑘𝑔) + (6,25 × 𝑣ýš𝑘𝑎 𝑚)− (5 × 𝑣ě𝑘 𝑣 𝑙𝑒𝑡𝑒𝑐ℎ)− 161*

Pro ilustraci lze uvést třicetiletého muže s hmotností 80 kg a výškou 180 cm. Harris-Benedictova rovnice odhadne jeho BMR přibližně na 1 858 kcal za den, zatímco Mifflin-St Jeorova na zhruba 1 780 kcal. Rozdíl mezi rovnicemi ukazuje, že i relativně malé odchylky v odhadu BMR mohou při dlouhodobém použití vést k významným rozdílům v odhadované energetické bilanci. Novější systematické přehledy navíc ukazují, že přesnost prediktivních rovnic se liší mezi populacemi a že u některých skupin mohou běžně používané rovnice BMR systematicky podhodnocovat nebo nadhodnocovat. Typickým příkladem takové skupiny jsou sportovci nebo obecně lidé s nadprůměrným množstvím svalové hmoty [15].

V uživatelských aplikacích je přesto použití těchto rovnic praktickým kompromisem mezi dostupností dat a požadavkem na rychlý odhad energetického výdeje. Pro návrh aplikace je důležité nejen vybrat vhodnou rovnici, ale také uživateli srozumitelně sdělit, že jde pouze o odhad s určitou nejistotou.

#### **Energetická bilance a energetická nerovnováha**

Energetickou bilanci lze zjednodušeně vyjádřit rovnicí:

*Zásoby energie = energetický příjem - energetický výdej*

Pokud je energetický příjem dlouhodobě nižší než energetický výdej, organismus čerpá chybějící energii z uložených zásob, především z tukové tkáně. Tento stav se označuje jako kalorický deficit a vede k postupnému snižování tělesné hmotnosti. Příliš výrazný a dlouhodobý deficit však může kromě tukové tkáně ohrožovat i svalovou hmotu a vést k nedostatku živin, únavě a zhoršení zdravotního stavu [13,14].

Naopak při chronickém kalorickém nadbytku převyšuje energetický příjem výdej. Přebytečná energie se ukládá ve formě tukových zásob a dochází k postupnému zvyšování tělesné hmotnosti a rizika metabolických onemocnění. Drenowatz a Greier zdůrazňují, že významnou roli hraje nejen absolutní množství energie, ale také struktura stravy, rozložení příjmu během dne a míra fyzické aktivity. Účinné strategie řízení hmotnosti proto kombinují dietní úpravy s podporou pohybové aktivity [14].

#### **Zdroje chyb v odhadu příjmu a výdeje energie**

Praktické využití energetické bilance v každodenním životě naráží na zásadní problém, kterým je nepřesnost odhadů jak na straně příjmu, tak na straně výdeje. Uživatelé běžně podhodnocují množství a energetickou hodnotu zkonzumovaných potravin, zapomínají zaznamenávat některá jídla nebo špatně odhadují velikost porcí. Li a kol. například prokázali, že výstupy nutričních aplikací se mohou významně lišit od referenčních metod, a to jak při manuálním zapisování, tak při využití rozpoznávání obrazu [5].

Na straně energetického výdeje může docházet k nadhodnocování spálené energie, zejména pokud uživatel spoléhá na obecné tabulky nebo méně přesná zařízení. Theodorakis a Nikolaou upozorňují, že organismus navíc na energetický deficit adaptivně reaguje snížením bazálního metabolismu a spontánního pohybu, což dále komplikuje přesnou predikci změn tělesné hmotnosti [13].

Pro návrh digitálního nástroje to znamená, že:

nelze spoléhat na absolutní přesnost jednoho konkrétního čísla energetického příjmu nebo výdeje

je vhodné pracovat s konceptem odhadu s nejistotou

design rozhraní by měl uživatele motivovat ke konzistentnímu zapisování a zároveň usilovat o minimalizaci zátěže

Právě tato snaha o snížení uživatelské zátěže při zachování dostatečné přesnosti odhadu energetické bilance je jedním z hlavních důvodů, proč tato práce zkoumá možnosti využití umělé inteligence a rozpoznávání potravin z fotografie.

### **Makroživiny a mikroživiny ve výživě**

Při hodnocení kvality stravy je vedle celkového energetického příjmu zásadní také její složení. To určují především makroživiny, které dodávají energii a stavební materiál, a mikroživiny, jež umožňují správný průběh metabolických a regulačních procesů. Přehledové studie ukazují, že jak poměr makroživin, tak dostatečný příjem klíčových mikroživin mají významný vliv na tělesné zdraví, riziko chronických onemocnění i subjektivní pohodu [16,17].

#### **Makroživiny**

Makroživiny jsou živiny přijímané ve větším množství, které tvoří hlavní zdroj energie ve stravě. Mezi ně patří sacharidy, tuky a bílkoviny.

Sacharidy představují primární zdroj energie pro většinu buněk, zejména pro centrální nervový systém a pracující sval. Zahrnují jednoduché cukry (glukóza, fruktóza), škrob a vlákninu. Strava s dostatečným zastoupením komplexních sacharidů a vlákniny je spojována s lepší kontrolou glykemie, nižším rizikem kardiometabolických onemocnění a vyšším pocitem sytosti. Naopak vysoký příjem přidaných cukrů zvyšuje energetický příjem bez odpovídající nutriční hodnoty.

Tuky slouží jako koncentrovaný zdroj energie, jsou nezbytné pro vstřebávání lipofilních vitamínů (A, D, E, K) a jako součást buněčných membrán a signálních molekul. Významnou roli hraje kvalitativní složení tuků. Vyšší podíl nenasycených mastných kyselin (například z rostlinných olejů, ryb a ořechů) je spojován s příznivým vlivem na kardiovaskulární zdraví, zatímco nadměrný příjem nasycených a transmastných kyselin naopak zvyšuje kardiometabolické riziko [16].

Bílkoviny jsou základním stavebním materiálem tkání, enzymů a hormonů. Dostatečný příjem bílkovin je klíčový pro udržení svalové hmoty, zejména při redukci tělesné hmotnosti, a může zvyšovat pocit sytosti. Seol a kol. například ukazují, že vyšší příjem bílkovin a vlákniny souvisí s příznivějšími parametry životního stylu, včetně lepší kvality spánku [18].

Venn shrnuje, že hlavním energetickým zdrojem stravy jsou typicky sacharidy a tuky, zatímco bílkoviny vedle energetické funkce zajišťují především stavební a regulační úlohu v organismu. Z praktického hlediska je důležité nejen celkové množství energie, ale také kvalita jednotlivých makroživin, například:

Upřednostnění komplexních sacharidů a vyššího příjmu vlákniny před jednoduchými cukry.

Vyšší zastoupení nenasycených mastných kyselin v porovnání s nasycenými.

Dostatečný příjem bílkovin pro udržení svalové hmoty, zejména při redukci hmotnosti.

Současná literatura upozorňuje, že různé dietní přístupy (například s vyšším podílem sacharidů nebo tuků) mohou vést ke srovnatelným změnám tělesné hmotnosti, pokud je zachován celkový energetický deficit. Pro běžného uživatele je proto vedle poměru makroživin zásadní především dlouhodobá udržitelnost zvoleného stravovacího režimu [16].

#### **Mikroživiny**

Mikroživiny zahrnují vitaminy a minerální látky. Na rozdíl od makroživin nepřinášejí významné množství energie, ale podílejí se na mnoha enzymatických a regulačních procesech v organismu. Farag a kol. zdůrazňují, že adekvátní příjem mikroživin je důležitý v průběhu celého životního cyklu a že jejich nedostatek či nadbytek může ovlivnit vývoj, imunitu, kognitivní funkce i riziko chronických onemocnění [17].

Z hlediska funkce a vlastností lze mikroživiny přehledně rozdělit do několika skupin:

**Vitamíny rozpustné ve vodě** (například vitaminy skupiny B, vitamin C)

**Vitaminy rozpustné v tucích** (A, D, E, K)

**Makrominerály** (například vápník, hořčík, sodík, draslík, fosfor)

**Mikrominerály a stopové prvky** (například železo, zinek, selen, jód, měď)

Farag a kol. uvádějí, že v populaci se často vyskytuje kombinace vysokého energetického příjmu a současného nedostatečného příjmu některých mikroživin. Tento stav bývá označován jako „skrytá malnutrice“ a zdůrazňuje potřebu sledovat vedle energie také kvalitu stravy [17].

### **Digitální nástroje pro sledování výživy a tělesné hmotnosti**

Digitální nástroje pro podporu změny životního stylu dnes obvykle netvoří izolované aplikace, ale propojený ekosystém. Jádrem tohoto ekosystému bývá chytrý telefon, který slouží jako centrální uzel pro sběr a vizualizaci dat, k němuž se připojují nositelná zařízení a chytré domácí přístroje. Tato zařízení automaticky zaznamenávají různé aspekty chování a tělesného stavu uživatele, včetně fyzické aktivity, srdeční frekvence, spánku, tělesné hmotnosti a složení těla. V kontextu řízení hmotnosti tak mohou výrazně snížit potřebu manuálního zadávání údajů a zvýšit frekvenci i přesnost self monitoringu [20].

#### Chytré hodinky a náramky

Chytré hodinky a fitness náramky kontinuálně zaznamenávají počet kroků, objem a intenzitu fyzické aktivity, srdeční frekvenci a často také délku a strukturu spánku. Tato data jsou obvykle v téměř reálném čase synchronizována s mobilní aplikací, která uživateli poskytuje zpětnou vazbu a motivační prvky, jako jsou denní cíle, notifikace nebo gamifikace.

Systematická review a metaanalýza Wang a kol. zahrnula 12 randomizovaných studií s celkem 3227 dětmi a adolescenty, u nichž byly wearables použity jako nástroj k podpoře fyzické aktivity v prevenci a léčbě obezity. V porovnání s kontrolními skupinami vedly intervence založené na nositelných zařízeních k malému, ale statisticky významnému snížení tělesné hmotnosti (průměrný rozdíl −1,08 kg) a BMI (průměrný rozdíl −0,23 bodu BMI), stejně jako k poklesu tělesného tuku (průměrný rozdíl −0,72 procentního bodu tělesného tuku). Tyto efekty ukazují, že samotné zavedení kontinuálního monitoringu pohybové aktivity a jednoduché zpětné vazby může mít měřitelný dopad na antropometrické ukazatele, i když nejde o dramatické změny [21].

Konkrétně u dospělých s nadváhou a obezitou hodnotila studie EVIDENT 3 přínos kombinace mobilní aplikace a chytrého náramku (Mi Band 2) oproti samotnému dietnímu a pohybovému poradenství. Do randomizované multicentrické studie bylo zařazeno 440 sedavých dospělých, z nichž 231 bylo v intervenční skupině s aplikací a náramkem a 209 v kontrolní skupině. Po třech měsících trvání intervence dosáhla intervenční skupina průměrného poklesu tělesné hmotnosti o 1,97 kg, zatímco kontrolní skupina zhubla v průměru o 1,13 kg. Rozdíl mezi skupinami tedy činil 0,84 kg ve prospěch kombinace aplikace a nositelného zařízení. Současně došlo v intervenční skupině ke snížení tukové hmoty o 1,84 kg a poklesu procenta tělesného tuku o 1,22 procentního bodu, zatímco v kontrolní skupině se tyto parametry významně neměnily. Efekt byl nejvýraznější u žen s BMI pod 30 kg/m² a u osob s alespoň střední úrovní fyzické aktivity, což ukazuje, že přínos nositelných zařízení může být závislý na charakteristikách uživatele a jeho počátečním chování [20].

Z pohledu návrhu ekosystému je důležité, že v těchto studiích se data z chytrých náramků nevyužívají izolovaně, ale jako vstup pro mobilní aplikaci, která kombinuje self monitoring, automaticky měřenou aktivitu a behaviorální doporučení. Tato integrace umožňuje zjednodušit sběr dat a zároveň zvyšovat frekvenci a pravidelnost monitoringu bez zásadního zvýšení kognitivní zátěže uživatele.

#### **Chytré váhy a analyzátory složení těla**

Chytré osobní váhy a komerční analyzátory složení těla využívají nejčastěji bioelektrickou impedanční analýzu a dokáží kromě tělesné hmotnosti odhadovat parametr jako procento tělesného tuku, množství beztukové hmoty nebo segmentové rozložení svalové hmoty. Naměřené hodnoty jsou prostřednictvím Bluetooth nebo Wi-Fi automaticky přenášeny do mobilní aplikace a často i do cloudového úložiště, což odstraňuje potřebu ručního zapisování hmotnosti a umožňuje velmi časté vážení.

Huang a kol. analyzovali data více než 46 tisíc čínských uživatelů chytrých tělesných vah, kteří byli v době pandemie COVID-19 sledováni po dobu nejméně jednoho roku. Mezi obézními účastníky (podle BMI) vedlo samostatně řízené používání chytré váhy a navázané aplikace k průměrnému ročnímu poklesu hmotnosti o 3,90 kg u mužů a 4,74 kg u žen, což odpovídalo snížení BMI o 1,42 a 1,80 bodu. Autoři zároveň rozdělili uživatele podle četnosti měření a zjistili, že skupina s nejvyšší frekvencí vážení (medián přibližně 130 měření za rok) dosahovala významně větších změn hmotnosti, BMI i procenta tělesného tuku než skupiny s nízkou a střední frekvencí. Multivariační logistická regrese potvrdila, že vysoká frekvence měření byla nejsilnějším nezávislým prediktorem úspěšného úbytku hmotnosti, s odds ratio přibližně 2,1 pro dosažení alespoň 5% redukce hmotnosti oproti výchozímu stavu [22].

Výsledky této studie ukazují dva podstatné aspekty. Zaprvé, chytré váhy umožňují prakticky denní self monitoring hmotnosti bez dodatečné práce uživatele, což by v klasickém režimu ručního zapisování bylo jen obtížně udržitelné. Zadruhé, vysoká frekvence měření souvisí nejen s větší pravděpodobností dosažení významného úbytku hmotnosti, ale také s příznivými změnami složení těla, včetně většího poklesu procenta tělesného tuku a nárůstu svalové hmoty [22].

## NÁVRH APLIKACE

//TODO: úvodní odstavec, který stručně nastíní nadcházející kapitoly v Návrhu aplikace, což bude Existující řešení, Uzivatelska studie (strukturované rozhovory), z nich vyplynou Use cases, FR/NFR, případy užití, a na jejichž základě bude zkonstruován HiFi prototyp aplikace.

### Existující řešení

Mobilní aplikace pro sledování stravy a tělesné hmotnosti patří v současnosti k nejčastěji používaným nástrojům v oblasti digitálního zdraví. Přehledové studie ukazují, že nutriční a dietní aplikace jsou běžnou součástí změny životního stylu a mohou přispět k lepší kontrole stravovacích návyků a k mírné redukci hmotnosti [2].

Současné analýzy trhu s digitálními nástroji pro výživu potvrzují, že v hlavních mobilních obchodech existují desítky až stovky aplikací zaměřených na sledování příjmu potravy, plánování jídelníčku a takzvanou precision nutrition. Abeltino a kol. ve svém přehledu shrnují, že pro běžné uživatele i odborníky je k dispozici široké spektrum aplikací pro monitorování stravy a tvorbu jídelních plánů [3]. Samad a kol. při systematickém průzkumu tří velkých obchodů s aplikacemi identifikovali 473 aplikací souvisejících se sledováním příjmu potravy a doporučováním jídel, z nichž 80 podrobně analyzovali [4]. To dokládá, že i v jedné poměrně úzce vymezené kategorii existují desítky až stovky vzájemně konkurujících aplikací.

Přehledy výživových aplikací ukazují, že většina z nich staví na velmi podobném jádru a liší se spíše v uživatelském rozhraní a doplňkových funkcích než v samotné logice sledování stravy [2,3]. Typická aplikace pro sledování stravy nabízí zejména:

potravinový deník pro každodenní záznam jídel,

databázi potravin s nutričními hodnotami a fulltextovým vyhledáváním,

možnost ukládat vlastní recepty a oblíbená jídla,

nastavení cílového energetického příjmu a sledování makroživin,

základní zpětnou vazbu ve formě grafů a statistik [7].

Z hlediska interakce s uživatelem je klíčové zadávání dat. Většina komerčních aplikací stále vyžaduje manuální zapisování jídel prostřednictvím vyhledávání v databázi nebo zadávání receptů. Částečnou automatizaci přinášejí:

skenování čárových kódů balených potravin,

předvyplněné šablony jídel a možnost kopírovat dříve zapsaná jídla,

notifikace připomínající záznam jednotlivých jídel [3].

Systematické studie zároveň upozorňují, že ruční zapisování je časově náročné a v praxi často vede k nekompletním či zkresleným záznamům. Li a kol. ukazují, že výstupy nutričních aplikací se mohou od referenčních metod významně lišit, a to jak u manuálního zapisování, tak u řešení s podporou rozpoznání obrazu. Energetický příjem bývá v závislosti na typu stravy nadhodnocen nebo podhodnocen o stovky kilodžaulů až kilokalorií denně [5].

V reakci na omezení manuálního sběru dat se začíná prosazovat využití umělé inteligence a počítačového vidění. Samad a kol. ukazují, že pouze malá část komerčních aplikací nabízí pokročilé funkce automatického rozpoznávání jídel z fotografie a odhadu porce a že v souboru 80 hodnocených aplikací byla jen jedna, která dokázala z fotografie automaticky určit druh jídla i velikost porce [4]. Aburub a kol. ve svém přehledu food scanning aplikací shrnují, že skenování čárových kódů je dnes běžnou funkcí, zatímco plně automatické rozpoznávání talíře zůstává výjimkou a typicky vyžaduje potvrzení a korekci ze strany uživatele [6].

Nogueira-Rio a kol. zdůrazňují, že současná generace výživových aplikací stojí na kombinaci tradičního self monitoringu a nových AI nástrojů, přičemž zásadní výzvou je skloubit vyšší míru automatizace s přijatelnou přesností a použitelností v každodenním životě [2].

Pro tuto práci jsou reprezentativní zejména dvě aplikace, které pokrývají globální i lokální kontext. První je mezinárodní aplikace MyFitnessPal a druhou jsou československé Kalorické Tabulky (Dine4Fit). Následující podkapitoly je stručně představují a vymezují jejich silné a slabé stránky ve vztahu k cíli této diplomové práce.

#### MyFitnessPal

MyFitnessPal patří mezi nejznámější a nejrozšířenější aplikace pro sledování stravy a tělesné hmotnosti na světě. Je dostupná pro Android, iOS i webové rozhraní a dlouhodobě se pohybuje na předních příčkách kategorií Health & Fitness v hlavních mobilních obchodech [8].

#### **Hlavní funkcionalita**

Základem MyFitnessPal je potravinový deník navázaný na rozsáhlou databázi potravin. Oficiální materiály uvádějí databázi s miliony položek včetně běžných potravin, značkových výrobků i restaurací. Uživatel může zapisovat jídelníček několika způsoby:

vyhledáváním v databázi podle názvu potraviny

výběrem z historie a často používaných jídel

skenováním čárového kódu u balených potravin

zadáváním vlastních receptů a pokrmů

Aplikace průběžně počítá celkový denní energetický příjem a zobrazuje rozložení makroživin, jako jsou sacharidy, tuky a bílkoviny. V placené verzi umožňuje sledovat i další nutriční parametry, například vlákninu, cukr, sůl nebo vybrané mikronutrienty. Součástí systému je také záznam fyzických aktivit, sledování tělesné hmotnosti a integrace s externími zařízeními a službami, jako jsou Apple Health nebo fitness náramky [8].

Obchodní model aplikace odpovídá freemium přístupu. Základní funkce potravinového deníku a databáze potravin jsou dostupné zdarma, rozšířené analytické nástroje, pokročilé nastavení cílů, detailnější nutriční přehledy a některé zrychlené způsoby zadávání jídel jsou součástí placeného předplatného MyFitnessPal Premium [8].

#### **Rozpoznávání jídel z fotografie**

MyFitnessPal je jedním z prvních velkých komerčních produktů, které nasadili ve větším měřítku foto rozpoznávání jídel. Funkce Meal Scan umožňuje uživateli namířit fotoaparát na talíř a aplikace na základě obrazu navrhne odpovídající položky z databáze. Podle oficiální dokumentace jde o funkci dostupnou v rámci předplatného Premium a aktuálně podporovanou pro vybrané verze iOS a Androidu [8].

Výrobce uvádí, že Meal Scan využívá metody počítačového vidění a strojového učení k identifikaci více položek na jednom talíři a jejich propojení s interní databází. V praxi funguje Meal Scan jako asistovaná funkce: uživatel dostane seznam odpovídajících jídel, zvolí nejbližší položku a případně upraví velikost porce [8].

#### **Silné stránky a omezení**

Z hlediska této práce jsou klíčové následující výhody MyFitnessPal:

rozsáhlá databáze potravin pokrývající globální trh, včetně restaurací a značkových výrobků [8]

kombinace více vstupních metod (vyhledávání, historie, čárový kód, foto rozpoznávání) [8]

dlouhodobá přítomnost na trhu, díky níž existuje řada nezávislých hodnocení této kategorie nástrojů, včetně studií zaměřených na kvalitu a funkce aplikací pro sledování stravy [4]

Současná literatura i uživatelské zkušenosti ale upozorňují na několik omezení:

část databáze tvoří uživateli přidané položky, což může vést k chybám v nutričních údajích a nutnosti ruční korekce, například po skenování čárového kódu [5]

i přes použití foto rozpoznávání zůstává nutnost ruční kontroly a úprav, zejména u složitějších jídel a kombinovaných receptů [5]

aplikace je navržena primárně pro globální trh, a proto nemusí dostatečně pokrývat některé lokální produkty nebo značky, zejména ve středoevropském kontextu

Pro návrh vlastního řešení je MyFitnessPal důležitým referenčním příkladem robustního ekosystému, který kombinuje manuální self monitoring s prvky umělé inteligence. Současně ukazuje, že i jedna z nejrozšířenějších aplikací využívá AI primárně jako doplněk, nikoli jako plnou náhradu manuálního zadávání.

#### Kalorické Tabulky

Kalorické Tabulky, vyvíjené společností Dine4Fit a.s., představují nejpoužívanější aplikaci pro sledování stravy v českém a slovenském prostředí. Podle oficiálních informací firmy se stala nejpopulárnější aplikací na hlídání stravy v Česku i na Slovensku a měsíčně ji používá více než jeden milion uživatelů [9]. Tyto údaje potvrzuje také nezávislá reportáž na serveru CzechCrunch, která uvádí více než 1,5 milionu aktivních uživatelů a několik milionů registrací [10].

Aplikace je dostupná na webu i jako mobilní aplikace pro Android a iOS a podporuje také vybrané chytré hodinky, například Garmin nebo Apple Watch [9].

#### **Hlavní funkcionalita**

Základní princip Kalorických Tabulek se podobá globálním aplikacím pro sledování stravy, je však výrazně přizpůsoben specifikům českého a slovenského trhu. Klíčové funkce jsou:

databáze potravin zaměřená na produkty dostupné v Česku a na Slovensku, včetně značkových výrobků, restaurací a uživatelských receptů [9]

potravinový deník s možností zapisovat jednotlivá jídla v průběhu dne a sledovat energetický příjem v kcal nebo kJ

přehled denního příjmu a výdeje energie, sledování pitného režimu a tělesné hmotnosti [9]

podpora záznamu fyzických aktivit a jejich vlivu na energetickou bilanci

Významnou součástí ekosystému je i kalorická kalkulačka, která odvozuje doporučený energetický příjem z tělesných parametrů a cílů uživatele. Dine4Fit uvádí, že nastavení poměru makroživin vychází z odborných doporučení a umožňuje zvolit různé cíle, jako je udržení hmotnosti, hubnutí nebo nárůst svalové hmoty [9].

Aplikace používá freemium model. Základní funkcionalita, tedy deník, výpočet energie a základní nutriční hodnoty, je dostupná zdarma, zatímco detailnější analýzy, rozšířené sledování mikronutrientů, speciální jídelníčky a pokročilé statistiky jsou součástí placeného předplatného Premium [9,10].

#### **Rozpoznávání jídel z fotografie**

Novější verze Kalorických Tabulek integrují funkci AI rozpoznávání jídel z fotografie. Podle popisu aplikace v Google Play může uživatel jídlo vyfotit a aplikace navrhne odpovídající potraviny a jejich přibližnou gramáž, čímž automaticky spočítá kalorie a živiny [9]. Dine4Fit tuto funkci dále popisuje na svém webu a blogu jako prémiovou novinku využívající umělou inteligenci pro rozpoznání jídel a odhad hmotnosti na základě fotografie [9].

Technologické detaily implementace nejsou veřejně detailně popsány, nicméně mediální články zmiňují, že aplikace využívá AI detekci potravin ve velkém objemu zaznamenaných jídel a že funkce je nasazována postupně s důrazem na praktické využití v běžném hubnutí [10].

Stejně jako u MyFitnessPal nejde o plně autonomní systém. Uživatelé musí výsledek zkontrolovat, případně upravit typ jídla nebo velikost porce. Odborná literatura zatím neobsahuje nezávislou kvantitativní studii přesnosti této konkrétní funkce, což odpovídá obecnějšímu trendu, kdy detailní vědecká validace komerčních AI funkcí obvykle následuje s časovým odstupem za jejich praktickým nasazením [4,5,6].

#### **Silné stránky a omezení**

V českém a slovenském kontextu mají Kalorické Tabulky několik výrazných výhod:

silná lokalizace databáze potravin na regionální produkty, včetně běžných značek a lokálních jídel [9]

dostupnost webového rozhraní i mobilních aplikací, což usnadňuje zapisování v různých situacích [9]

velká uživatelská základna, která přispívá k rozšiřování databáze a komunitním receptům [10]

Současně však z uživatelských recenzí a odborných diskusí vyplývá několik slabších míst relevantních pro návrh této práce:

práce se složitějšími recepty může být časově náročná a vyžaduje manuální sestavování položek,

podobně jako u jiných komunitně rozšiřovaných databází se mohou vyskytnout chyby v nutričních údajích, pokud uživatelé zadávají data nepřesně [5],

funkce AI rozpoznávání jídel je relativně nová a dostupné informace ji popisují jako doplněk k tradičnímu zadávání, nikoli jako plnou náhradu manuálního zápisu [9,10].

Pro navrhovanou aplikaci jsou Kalorické Tabulky cenným vzorem z hlediska lokalizace, práce s regionálně specifickou databází a integrace AI funkcí do jinak klasického stravovacího deníku.

#### Shrnutí aplikací na trhu

Odborná literatura a analýzy komerčního trhu ukazují, že výživové a dietní aplikace tvoří velmi početnou a relativně homogenní kategorii digitálních nástrojů. Přehledy trhu a app store analýzy naznačují, že v globálním měřítku existují desítky až stovky aplikací zaměřených na sledování stravy, které si vzájemně konkurují v rámci několika málo funkčních podkategorií, například calorie tracker, nutrition tracker, diet planner nebo food scanning aplikace [3,4].

Samad a kol. identifikovali 473 aplikací souvisejících s příjmem potravy a doporučováním jídel a 80 z nich podrobili detailnímu hodnocení [4]. Gioia a kol. pak ve svém přehledu vybrali reprezentativní soubor dietních aplikací a analyzovali jejich funkcionalitu a vhodnost pro výzkum stravovacích návyků [7]. Přestože se metodiky liší, obě práce ukazují, že ve sledované kategorii se vyskytují desítky až stovky aplikací, které sdílejí velmi podobnou základní funkcionalitu.

Napříč těmito aplikacemi se opakují zejména tyto prvky:

potravinový deník pro každodenní záznam jídel,

databáze potravin s nutričními hodnotami,

ruční nebo poloautomatické zadávání pomocí čárového kódu a šablon,

přehledy o denním příjmu energie a makroživin, někdy doplněné o motivační prvky a připomenutí,

napojení na sledování tělesné hmotnosti a často i na fyzickou aktivitu [3,7].

Rozdíly mezi jednotlivými aplikacemi se proto často týkají spíše míry propracovanosti uživatelského rozhraní a motivace, kvality a lokalizace potravinové databáze, míry integrace s nositelnou elektronikou a rozsahu využití AI pro automatizaci záznamu [2,3].

Studie zaměřené na přesnost a uživatelskou zátěž potvrzují, že ruční zapisování stravy je pro mnoho lidí dlouhodobě obtížné a že dietní aplikace mohou energetický příjem podhodnocovat nebo nadhodnocovat, někdy i o stovky kilokalorií denně [5]. To vytváří prostor pro inovace v oblasti automatizace sběru dat, především prostřednictvím obrazového rozpoznávání a dalších AI metod. Současně však scoping a systematické review upozorňují, že plně automatické foto rozpoznávání je zatím spíše výjimkou a že i pokročilé funkce vyžadují aktivní roli uživatele [4,6].

MyFitnessPal a Kalorické Tabulky představují dva výrazné příklady této situace. Na jedné straně ukazují vyspělost trhu, tedy rozsáhlé databáze, škálu vstupních metod, robustní ekosystém a milionové uživatelské základny [8,9,10]. Na straně druhé potvrzují, že základní model zůstává obdobný jako v počátcích mobilních dietních aplikací. Uživatel stále primárně ručně zapisuje jídla do deníku a AI funkce foto rozpoznávání slouží jako doplněk, nikoli jako plná náhrada manuálního sběru dat [5,6].

Pro návrh aplikace v této diplomové práci z toho vyplývají tři hlavní závěry:

Trh již nabízí velké množství aplikací se srovnatelnou základní funkcionalitou, takže inovace by měla cílit na konkrétní slabá místa, například uživatelskou zátěž při zadávání nebo kvalitu a lokalizaci databáze.

Zvýšení míry automatizace pomocí počítačového vidění a AI je slibnou cestou, ale vyžaduje pečlivé řešení otázky přesnosti a transparentní komunikaci nejistot vůči uživateli.

Lokální kontext a kvalita potravinové databáze mohou být v českém prostředí stejně důležité jako samotná technická vyspělost modelu rozpoznávání.

### Uživatelská studie

*Uživatelská studie představuje soubor metod, jejichž cílem je porozumět potřebám, motivacím a kontextu cílových uživatelů a tyto poznatky následně převést do návrhu systému. V oblasti mobilního zdraví je uživatelsky orientovaný přístup považován za důležitý, protože ovlivňuje použitelnost, důvěru, dlouhodobou adherenci a tím i reálný dopad aplikace [23].*

*V této práci byla uživatelská studie *použita* jako hlavní vstup pro návrh aplikace pro rozpoznávání potravin pomocí umělé inteligence a pro sledování kalorického příjmu. Cílem bylo identifikovat situace, ve kterých je ruční zapisování pro uživatele překážkou, jaká míra nepřesnosti je akceptovatelná, jak uživatelé vnímají selhání AI a jaké podpůrné funkce zvyšují pravděpodobnost dlouhodobého používání.*

#### Metodika

*Jako metoda sběru dat byly zvoleny strukturované rozhovory s uživateli z cílové skupiny. Rozhovory byly vedeny tak, aby pokryly* *současnou praxi zapisování jídel,* *očekávání od AI rozpoznávání a také preference v oblasti přehledů, motivace, práce s daty a integrací. Tento postup odpovídá doporučením v literatuře, kde jsou kvalitativní techniky typu rozhovorů nebo skupinových diskusí uváděny jako vhodný zdroj požadavků pro návrh aplikací v oblasti zdraví [24].*

*Rozhovory byly zpracovány do samostatných reportů a dále analyzovány tematickým způsobem. V této kapitole jsou výsledky shrnuty do hlavních témat a následně formalizovány do scénářů případů užití a do sady funkčních a nefunkčních požadavků. *Reporty v plném znění jsou součástí příloh této práce.

#### Charakteristika participantů

*Pro rozhovory byli vybráni čtyři participanti, kteří reprezentují rozdílné cíle a kontext používání. V textu jsou uváděni anonymizovaně jako P1 až P4*:

*P1 je muž ve věku 27 let, jeho cílem je nabírání svalové hmoty, cvičí přibližně třikrát týdně a preferuje sledování makroživin. V minulosti aplikaci pro zapisování využíval, ale přestal, když dosáhl cíle. Je ochoten tolerovat *nějakou míru* nepřesnosti, pokud mu aplikace ušetří práci.*

*P2 je muž ve věku 24 let, intenzivně cvičí a cíleně udržuje kalorický nadbytek. U zapisování klade důraz na přesnost a důvěryhodnost, preferuje rychlé metody zadávání u balených potravin, typicky čárové kódy*.* *U* jídel z restaurace *akceptuje typicky vyšší nepřenost při zápisu, než u jiných pokrmů*.*

*P3 je žena ve věku 54 let, dlouhodobě se snaží zhubnout a zohledňuje zdravotní souvislosti. Zkoušela existující aplikac*e*, ale odradila ji časová náročnost, časté chybění položek v databázi a nutnost odhadovat gramáž, zejména u domácího vaření.*

*P4 je žena ve věku *28 let*, která dříve *své jídlo pravidelně vážila*, nyní častěji zapisuje odhadem a upřednostňuje jednoduché předvolby porcí. Má jasnou preferenci, aby fotografie byla primární vstup, ale současně požaduje kvalitní záložní cestu při selhání. Zásadní je pro ni transparentnost AI a rozlišení běžných limitů modelu od technické chyby aplikace.*

#### Výsledky rozhovorů

**Rychlost zápisu a dlouhodobá udržitelnost: **Opakovaným tématem napříč rozhovory je, že dlouhodobé používání je přímo podmíněno rychlostí a jednoduchostí. P1 zmiňuje cílový stav rychlého zápisu jednoduché položky přibližně do šesti kliknutí bez dodatečné editace. P2 uvádí podobnou hranici pro rychlé položky. P4 toleruje pomalejší zpracování zejména na začátku, ale očekává postupné zrychlení a udržení zápisu v přiměřeném čase. Zcela klíčové je to pro P3, která z důvodů pomalosti procesu zápisu pokaždé přestala aplikaci používat, a to ještě před dosažením jejích zdravotních cílů.

**Akceptovatelná nepřesnost a důvěra v AI: **Participanti se liší v toleranci nepřesnosti, což je klíčové pro definici cílových metrik přesnosti. P1 je ochoten tolerovat přibližnou odchylku do dvaceti procent, pokud mu aplikace výrazně zjednoduší proces. Naopak P2 požaduje nepřesnost pouze v řádu jednotek procent a bez důvěryhodného výsledku považuje funkci za málo užitečnou. P3 chápe omezení vysoké přesnosti, nicméně požaduje, aby výstup byl srozumitelný a kontrolovatelný, zejména u domácích jídel.

**Selhání rozpoznání: **Pro praktickou použitelnost AI funkce je kritické eliminovat situace, kdy se uživatel ocitne ve slepé uličce. P4 požaduje, aby při selhání fotografie bylo možné plynule přejít na textový popis a aby bylo možné AI znovu vyvolat z rozpracovaného záznamu bez zakládání nového záznamu. P1 zároveň navrhuje možnost doplnit k fotografii krátkou doplňující informaci pro lepší výsledek. Důležitým aspektem je také rozlišení, zda jde o limit rozpoznání, nebo o technickou chybu aplikace, a nabídnutí vhodného dalšího kroku.

**Oblíbená jídla, historie a zkratky: **Všichni participanti popisují situace, kdy jedí opakovaně podobná jídla, případně používají stejné ingredience. P2 označuje oblíbené položky, historii a čtečku kódů za zásadní funkce. P4 uvádí, že využívá oblíbené a duplikaci předešlého záznamu a ocení našeptávání dříve zadaných názvů. P1 doplňuje potřebu rychlých zkratek, které umožní udržet zápis v nízkém počtu kroků.

**Domácí vaření, odhad množství: **Domácí vaření se ukazuje jako jeden z možných důvodů, proč uživatelé zapisování opouštějí. P3 popisuje, že vaření od oka ztěžuje odhad gramáže a že největší bariéra nastává, když položka chybí v databázi a je nutné ji vytvořit manuálně. P2 zdůrazňuje potřebu práce s plánovanými ingrediencemi a následnou jednoduchou úpravou skutečně použitých množství, včetně drobných ingrediencí typu olej nebo koření. To vede k požadavku na funkcionalitu, která podporuje plánování a následné rychlé dorovnání skutečně použitých množství surovin.

**Kategorie jídel a práce se zpětným zápisem: **Participanti se liší v tom, zda zapisují před jídlem nebo zpětně. P2 u jídel z restaurace preferuje doplnění až doma mimo sociální situaci. P3 uvádí, že zapisovala i večer, případně plánovala dopředu, ale nedodržení plánů vedlo ke zdvojení práce. Z toho vyplývá potřeba podporovat jak okamžitý zápis, tak zpětný zápis z galerie, a zároveň nevnucovat automatické zařazování kategorií podle času zadání.

**Přehledy, motivace a dotazování nad daty: **Základem je pro všechny denní přehled, tedy rychlá kontrola kalorií a makroživin. P1 požaduje jednoduché přehledy po dnech, týdnech a měsících a možnost pokládat dotazy typu porovnání období podle makroživin. P4 vnímá týdenní souhrn jako užitečné doplnění a navrhuje dotazování přirozeným jazykem s personalizovanými doporučeními. P2 uvádí, že motivační měsíční souhrny formou notifikace nebo e-mailu by mu pomohly udržet rutinu. P3 klade důraz na dietní omezení a schopnost odpovědět, kolikrát došlo k porušení diety s proklikem na konkrétní dny.

**Soukromí, ukládání dat a kontrola: **Otázka soukromí se objevuje ve smyslu kontroly nad daty a transparentností práce s nimi. P1 požaduje jasné funkce pro mazání a informace o tom, co se s daty děje. P4 je ochotna akceptovat automatické promazávání nejstarších záznamů mimo oblíbené položky. P3 považuje za důležité mít možnost smazat jednotlivé záznamy, i když je pro ni umístění dat méně podstatné.

**Integrace aktivity: **Integrace se sportovními službami a hodinkami se opakuje u všech participantů, byť s rozdílnou hloubkou. P1 chce jednoduché propojení a zobrazení příjmu versus výdeje. P2 očekává přebírání spálených kalorií s možností nastavit, zda a jak se výdej promítne do denního limitu. P4 zmiňuje zájem o integraci s Garmin a zdůrazňuje, že ji zajímá zejména promítnutí spálených kalorií do denního přehledu.

#### Scénáře případů užití

*V návrhu aplikací se používají jak narativní popisy situací z praxe, tak případy užití jako formální popis interakce aktéra se systémem. V této práci byly narativní situace využity při analýze rozhovorů, ale pro formální popis systému je dále uvedena pouze sada scénářů případů užití, aby nedocházelo k duplicitě a aby byl výstup přímo použitelný pro návrh prototypu a testování.*

| Název: Záznam jídla z fotografie |  |  |
| --- | --- | --- |
| ID: UC01 |  |  |
| Charakteristika: Uživatel chce rychle zapsat jídlo pomocí fotografie a následně výsledek zkontrolovat. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře funkci pro záznam jídla a pořídí fotografii. |
| 2 | Systém | Spustí rozpoznání, zobrazí návrh položek a odhad množství, případně indikaci nejistoty. |
| 3 | Uživatel | Zkontroluje návrh, upraví položky a množství, případně doplní chybějící položky. |
| 4 | Uživatel | Potvrdí uložení záznamu. |
| 5 | Systém | Uloží záznam a aktualizuje denní přehled. |

**UC01 ***- Záznam jídla z fotografie*

| Název: Oprava výsledku rozpoznání a opakování rozpoznání |  |  |
| --- | --- | --- |
| ID: UC02 |  |  |
| Charakteristika: Uživatel chce opravit rozpoznané položky a v případě potřeby vyvolat rozpoznání znovu bez zakládání nového záznamu. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře detail rozpoznaného jídla v editační obrazovce. |
| 2 | Systém | Zobrazí seznam položek, množství, jednotky a souhrn živin. |
| 3 | Uživatel | Upraví názvy, množství, odstraní nebo přidá položky. |
| 4 | Uživatel | Zvolí možnost znovu rozpoznat, například po úpravě vstupu nebo doplnění informace. |
| 5 | Systém | Provede nové rozpoznání a aktualizuje návrh položek, zachová možnost ruční kontroly. |
| 6 | Uživatel | Potvrdí finální stav a uloží záznam. |

**UC02** *- Oprava výsledku rozpoznání a opakování rozpoznání*

| Název: Ruční přidání záznamu jídla |  |  |
| --- | --- | --- |
| ID: UC03 |  |  |
| Charakteristika: Uživatel chce vytvořit záznam bez použití fotografie nebo AI. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře ruční zápis jídla. |
| 2 | Uživatel | Vyhledá položku v databázi nebo zvolí položku z historie. |
| 3 | Uživatel | Zadá množství a jednotku, gramy nebo kusy, případně předvolbu porce. |
| 4 | Uživatel | Potvrdí uložení záznamu. |
| 5 | Systém | Uloží záznam a aktualizuje denní přehled. |

**UC03** *- Ruční přidání záznamu jídla*

| Název: Přidání balené potraviny pomocí čárového kódu |  |  |
| --- | --- | --- |
| ID: UC04 |  |  |
| Charakteristika: Uživatel chce rychle přidat balenou potravinu načtením kódu. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře čtečku kódů a naskenuje čárový kód produktu. |
| 2 | Systém | Vyhledá produkt v databázi a zobrazí nalezenou položku. |
| 3 | Uživatel | Zvolí množství a jednotku nebo předvolbu porce. |
| 4 | Uživatel | Potvrdí vložení do denního záznamu. |
| 5 | Systém | Uloží záznam a aktualizuje denní přehled. |

**UC04*** - Přidání balené potraviny pomocí čárového kódu*

| Název: Přidání opakovaného jídla z oblíbených nebo duplikací |  |  |
| --- | --- | --- |
| ID: UC05 |  |  |
| Charakteristika: Uživatel chce co nejrychleji přidat jídlo, které se často opakuje. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře seznam oblíbených nebo historii záznamů. |
| 2 | Systém | Nabídne oblíbené položky, nedávné záznamy a našeptávání podle historie. |
| 3 | Uživatel | Vybere položku nebo duplikuje celý záznam jídla. |
| 4 | Uživatel | Případně upraví množství a potvrdí uložení. |
| 5 | Systém | Uloží nový záznam a aktualizuje denní přehled. |

**UC05** *- Přidání opakovaného jídla z oblíbených nebo duplikací*

| Název: Vaření s režimem plán versus realita |  |  |
| --- | --- | --- |
| ID: UC06 |  |  |
| Charakteristika: Uživatel chce při vaření zadat plánované ingredience a po dokončení upravit skutečně použité množství. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Vytvoří záznam receptu nebo vaření a zadá plánované ingredience. |
| 2 | Systém | Průběžně počítá plánované souhrnné živiny receptu. |
| 3 | Uživatel | Po uvaření upraví skutečně použité množství, včetně drobných ingrediencí. |
| 4 | Systém | Přepočítá souhrny a nabídne uložení finální verze. |
| 5 | Uživatel | Uloží jídlo do denního záznamu a případně do vlastních receptů pro opakování. |

**UC06*** - Vaření s režimem plán versus realita*

| Název: Nastavení profilu, cílů a dietních omezení |  |  |
| --- | --- | --- |
| ID: UC07 |  |  |
| Charakteristika: Uživatel chce nastavit cíle, profil a kontext, který ovlivní interpretaci a doporučení. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře nastavení profilu. |
| 2 | Uživatel | Vyplní nebo upraví základní parametry a nastaví cílové hodnoty. |
| 3 | Uživatel | Nastaví dietní omezení nebo intolerance. |
| 4 | Systém | Uloží nastavení a promítne je do přehledů a upozornění. |

**UC07** *- Nastavení profilu, cílů a dietních omezení*

| Název: Přehledy, dotazy nad daty a export |  |  |
| --- | --- | --- |
| ID: UC08 |  |  |
| Charakteristika: Uživatel chce vyhodnotit svůj progres a získat odpovědi nad historií, případně data sdílet. |  |  |
| Primární aktér: Uživatel |  |  |
| Hlavní scénář: |  |  |
| Krok | Aktér | Popis |
| 1 | Uživatel | Otevře přehledy a zvolí období, týden nebo měsíc. |
| 2 | Systém | Zobrazí souhrny a trendy, případně upozorní na překročení limitů. |
| 3 | Uživatel | Položí dotaz nad daty, například porovnání období nebo dotaz na makroživiny. |
| 4 | Systém | Zobrazí odpověď a nabídne proklik na relevantní dny. |
| 5 | Uživatel | Volitelně spustí export dat do tabulkového formátu. |

**UC08** *- Přehledy, dotazy nad daty a export*

#### Funkční a nefunkční požadavky

*Z rozhovorů a ze zadání práce byla sestavena sada funkčních a nefunkčních požadavků. Požadavky jsou v této kapitole uvedeny ve zkrácené podobě, aby byly použitelné jako přehledný podklad pro návrh prototypu a následnou implementaci. Plné znění, včetně racionále a metody ověření, je uvedeno v samostatném dokumentu specifikace, který je součást*í příloh této práce*. Funkční požadavk*y na aplikaci jsou následující:

**Základní evidence a denní přehled**

*FR-02: Denní přehled pro kalorie a makroživiny*

*FR-03: Nastavení cílových hodnot, minimálně kalorie, volitelně makra*

*FR-04: Správa profilu uživatele*

*FR-05: Kontrola nad daty a mazání, jednotlivé záznamy, případně účet*

**Vstupy pro záznam jídla**

*FR-01: Ruční přidání záznamu jídla bez použití AI*

*FR-06: Pořízení fotografie jako vstup pro rozpoznání*

*FR-12: Import fotografie z galerie*

*FR-14: Záznam jídla bez fotografie, například hlasem nebo textovým popisem*

**AI rozpoznávání a práce s nejistotou**

*FR-07: AI návrh položek a porcí*

*FR-08: Indikace nejistoty výstupu*

*FR-09: Vysvětlení limitů AI a doporučení pro zlepšení vstupu*

*FR-10: Rozlišení limitu AI a technické chyby aplikace*

*FR-11: Textový fallback při selhání rozpoznání*

*FR-13: Opakování rozpoznání z editační obrazovky*

**Množství a jednotky**

*FR-15: Jednotky množství v gramech i kusech, včetně předvoleb porcí*

**Rychlé zkratky a práce s historií**

*FR-16: Čtečka čárových kódů pro balené potraviny*

*FR-17: Oblíbené položky*

*FR-18: Duplikace předchozího záznamu*

*FR-19: Našeptávání názvů podle historie*

**Dietní kontext**

*FR-20: Dietní omezení a intolerance*

*FR-21: Zobrazení porušení dietních omezení v kalendáři*

**Aktivita, přehledy a motivace**

*FR-22: Příjem versus výdej v jednom pohledu*

*FR-23: Nastavení integrace výdeje energie a jeho vlivu na limit*

*FR-24: Týdenní a měsíční přehledy*

*FR-27: Dotazy v přirozeném jazyce nad daty*

*FR-28: Měsíční motivační souhrn, notifikace nebo e-mail*

*FR-29: Nastavitelné notifikace*

**Data a provozní vlastnosti**

*FR-25: Export dat, například CSV*

*FR-26: Offline tolerance, koncept záznamu, dokončení později*

*FR-30: Skrytí nebo zobrazení pokročilých funkcí v uživatelském rozhraní*

**Nefunkční požadavky**

*NFR-01: *Akceptovatelná* nepřesnost odhadu energie a makroživin* *nejvýše 10 %*

*NFR-02: Latence AI rozpoznání, výsledek nejvýše do 20 vteřin za běžných podmínek*

*NFR-03: Počet kroků pro* *zápis jednoduché položky, nejvýše 6 kroků bez dodatečné editace*

*NFR-04: Časová náročnost zápisu, opakované jídlo do 1 minuty, nové jídlo do 5 minut*

*NFR-05: Minimalistické a přehledné uživatelské rozhraní bez rušivých prvků*

#### Shrnutí kapitoly

*Uživatelská studie ukázala, že hlavní bariérou dlouhodobého zapisování je kombinace časové náročnosti, nejistoty výsledků a slabé podpory pro opakované situace, zejména opakovaná jídla, balené produkty, domácí vaření a pokrm*y z *restaurac*í*. AI rozpoznávání je vnímáno jako přínosné, ale pouze za předpokladu, že uživatel má kontrolu nad výsledkem* a* rozumí nejistotě spojené s AI v*yhodnocením*. Výstupy rozhovorů byly *formulovány* do scénářů případů užití a do sady požadavků, které tvoří přímý podklad pro návrh a realizaci prototypu.*

### Prototyp aplikace

Prototyp představuje zjednodušenou reprezentaci budoucího systému, která umožňuje ověřovat návrhová rozhodnutí dříve, než dojde k nákladné implementaci. V praxi jde o iterativní artefakt, jehož míra detailu se postupně zvyšuje a který slouží jak k interní validaci návrhu, tak k získání zpětné vazby od uživatelů [25,26].

#### Prototyp a související pojmy

Pojem prototyp v kontextu návrhu uživatelského rozhraní zahrnuje různé formy reprezentace, od statických náčrtů a wireframů až po interaktivní prototypy. Společným cílem je simulovat očekávané chování systému v takovém rozsahu, aby bylo možné posoudit srozumitelnost toku obrazovek a kvalitu interakce [25,26].

Fidelita (fidelity) vyjadřuje míru podobnosti prototypu s finálním produktem, zejména z hlediska vizuálního zpracování, interakčních detailů a kontextu použití. Nízká fidelita typicky podporuje rychlé hledání směru a levné iterace, vysoká fidelita naopak umožňuje realistické testování, protože se blíží skutečné zkušenosti uživatele [25,26].

LoFi prototyp v této práci označuje ranou variantu návrhu s omezenými vizuálními detaily, často založenou na jednoduchých rozvrženích a základní navigaci. HiFi prototyp odpovídá pokročilejší variantě s definovanými komponentami, typografií a chováním prvků, čímž se stává vhodným podkladem pro ověřování použitelnosti i pro navazující implementaci [25,26].

#### Cíl prototypu v kontextu práce

Cílem HiFi prototypu bylo převést výstupy uživatelské studie, scénáře případů užití a sadu požadavků do konzistentního návrhu mobilní aplikace. Prototyp měl ověřit, zda navržené způsoby zapisování jídel, práce s rozpoznáním a následná úprava výsledku odpovídají očekáváním uživatelů, a současně vytvořit jednoznačný podklad pro implementační část práce [23,24].

#### Rozsah a obsah HiFi prototypu

HiFi prototyp byl vytvořen jako graficky plnohodnotný model mobilní aplikace a pokrývá jak klíčové toky pro zaznamenávání jídel, správu uživatelských dat a nutriční přehledy, tak i pokročilé funkce jako dotazování v přirozeném jazyce nad daty a personalizované nastavení dietních omezení a intolerancí. V kapitole implementace jsou následně prezentovány konkrétní obrazovky, zatímco tato kapitola shrnuje záměr a rozsah prototypu jako výstupu návrhové fáze.

#### Testování prototypu

Testování prototypu je v této práci pojato jako formativní ověřování použitelnosti, jehož cílem je odhalit problémy v toku úloh, ve srozumitelnosti ovládání a v porozumění výsledkům rozpoznání. Formativní přístup je vhodný zejména v rané fázi, protože umožňuje cíleně upravovat návrh ještě před implementací a tím snížit riziko nákladných změn v pozdějších fázích [29].

Pro realizaci testování je vhodná úlohová metoda doplněná o verbalizaci postupu typu think aloud, která poskytuje detailní vhled do mentálního modelu uživatele a do důvodů jednotlivých rozhodnutí během práce s prototypem. V literatuře je think aloud běžně využíván při hodnocení mobilních zdravotních aplikací a umožňuje zachytit konkrétní bariéry v interakci. [28,29].

Testovací úlohy byly sestaveny jako zjednodušené varianty již definovaných scénářů případů užití. Tím se eliminuje duplicitní popis funkcionalit a současně se zachovává přímá návaznost mezi analýzou potřeb, návrhem prototypu a ověřením použitelnosti. [29].

T1:

T2:

T3:

T4:

T5:

T6:

T7:

Hodnocení lze opřít o kombinaci kvalitativních pozorování a jednoduchých kvantitativních ukazatelů, například úspěšnost dokončení úlohy, počet chyb nebo potřebu nápovědy. Pro subjektivní hodnocení použitelnosti lze využít standardizovaný dotazník System Usability Scale, který je v mHealth studiích běžně používán pro rychlé srovnání vnímané použitelnosti [29,30].

Výstupem testování je seznam identifikovaných problémů a doporučení pro úpravy prototypu, ideálně seřazený podle závažnosti a dopadu na klíčové toky. Tato struktura umožňuje transparentně propojit výsledky ověřování s následnými designovými úpravami a s implementační prioritami.

### Shrnutí návrhu aplikace

//TODO preformulovat, odstranit vyznamove duplicity

Tato práce se zaměřuje na návrh mobilní aplikace pro rozpoznávání potravin pomocí umělé inteligence a pro sledování kalorického příjmu. Volba tématu vychází z potřeby zjednodušit a zrychlit zapisování jídel, které je v existujících řešeních často časově náročné a dlouhodobě náročně udržitelné. V rámci semestrálního projektu je práce cíleně zaměřena na analytickou a návrhovou část, implementace bude řešena v navazující etapě.

Zásadním vstupem byla uživatelská studie realizovaná strukturovanými rozhovory. Získaná zpětná vazba byla pro návrh aplikace i pro mě osobně jakožto softwarového vývojáře velmi přínosná, protože přinesla nové pohledy na problematiku, vyvrátila některé předpoklady a jiné naopak potvrdila.

Na základě rozhovorů byly vytvořeny scénáře případů užití, které formulují klíčové interakce uživatele se systémem a propojují kvalitativní zjištění s návrhem aplikace. Současně byly zpracovány funkční a nefunkční požadavky, které vymezují rozsah návrhu a cílové charakteristiky.

HiFi prototyp slouží jako konsolidovaný výstup návrhové fáze, který propojuje zjištění z uživatelského výzkumu, formalizované scénáře případů užití a specifikované požadavky. V další části práce je prototyp využit jako reference pro implementaci a pro ověřování, zda výsledná aplikace naplňuje zamýšlené toky a očekávanou použitelnost.

Výstupem návrhové části je HiFi prototyp, který převádí případy užití a požadavky do konkrétní podoby uživatelského rozhraní. Prototyp slouží jako ověřitelný podklad pro implementaci a pro testování navázané na definované případy užití. V další fázi práce bude cílem navázat implementací vybraných funkcí, které ověří, do jaké míry návrh naplňuje cíle definované uživatelskou studií.

## IMPLEMENTACE

Tato kapitola popisuje realizaci mobilní aplikace Foody, která navazuje na analytickou a návrhovou fázi představenou v kapitolách 2 a 3. Na základě HiFi prototypu a funkčních požadavků definovaných v sekci 3.2.3 byla provedena implementace vybraných funkcí aplikace s cílem ověřit, do jaké míry je navržený koncept technicky realizovatelný. V úvodu kapitoly je provedena rešerše přístupů k vývoji mobilních aplikací a srovnání relevantních technologických frameworků, na jejímž základě byly zvoleny konkrétní technologie popsané v sekci 4.2. Následuje popis softwarové architektury, datového modelu a integrace AI modelu pro rozpoznávání potravin. Dále jsou představeny vstupní modality, klíčové implementované funkce a vybrané obrazovky aplikace. Kapitola je uzavřena přehledem stavu implementace funkčních požadavků a diskusí omezení výsledného řešení.

### 4.1 Přístupy k Vývoji Mobilních Aplikací

Před volbou konkrétních technologií pro implementaci aplikace je nezbytné analyzovat dostupné přístupy k vývoji mobilních aplikací. V rámci této sekce jsou porovnány dva základní přístupy: nativní vývoj, při kterém je aplikace vytvořena samostatně pro každou cílovou platformu, a multiplatformní vývoj, který umožňuje sdílení kódu napříč platformami z jednoho zdrojového základu. Následně jsou srovnány tři hlavní multiplatformní frameworky, přičemž výsledky tohoto srovnání tvoří analytický podklad pro rozhodnutí o vývojové platformě popsané v sekci 4.2.

#### 4.1.1 Nativní vs. Multiplatformní Vývoj

Nativní vývoj mobilních aplikací představuje přístup, při kterém je aplikace implementována samostatně pro každou cílovou platformu s využitím jejích nativních nástrojů a programovacích jazyků. V případě platformy iOS se jedná o jazyk Swift s frameworkem SwiftUI, zatímco pro platformu Android je standardním jazykem Kotlin s knihovnou Jetpack Compose. Nativní aplikace mají přímý přístup ke všem platformním API, čímž je zajištěn optimální výkon a plná kompatibilita s nejnovějšími funkcemi operačního systému [31, 32].

Z hlediska výhod nativního přístupu lze uvést maximální výkon vykreslování a odezvy uživatelského rozhraní, okamžitou podporu nových verzí operačního systému a nativních API bez nutnosti čekat na aktualizaci třetí strany a přirozený vzhled a chování odpovídající platformním konvencím. Na druhou stranu je hlavní nevýhodou nutnost udržovat dva oddělené kódové základy, což přináší dvojnásobné náklady na vývoj a údržbu. Kromě toho existuje riziko divergence funkčnosti mezi platformami, kdy některé funkce mohou být implementovány pouze na jedné z nich nebo se v průběhu času liší v chování [31, 32].

Multiplatformní vývoj představuje alternativní přístup, jehož podstatou je sdílení zdrojového kódu mezi cílovými platformami. Přehledová studie Biørn-Hansena a kol. identifikuje znovupoužitelnost kódu jako jeden z klíčových konceptů multiplatformního vývoje, přičemž v závislosti na zvoleném frameworku a typu aplikace je typicky sdíleno 70 až 95 % kódového základu, zatímco platformně specifické části jsou implementovány pomocí nativních modulů nebo pluginů [34]. Výhodou tohoto přístupu je výrazné snížení nákladů na vývoj a údržbu, rychlejší iterační cyklus díky jednotnému kódovému základu a konzistentní uživatelská zkušenost napříč platformami. Nevýhody zahrnují závislost na frameworku třetí strany, potenciální kompromisy ve výkonu oproti nativním aplikacím a v některých případech omezený přístup k nejnovějším platformním funkcím.

V kontextu této práce, kde je aplikace vyvíjena jedním vývojářem s cílem pokrýt obě hlavní mobilní platformy (Android i iOS), se multiplatformní přístup jeví jako vhodnější volba. Udržování dvou oddělených kódových základů by při daných časových a personálních omezeních diplomové práce vedlo k neúměrně vysoké režii vývoje. Multiplatformní framework naopak umožňuje soustředit veškeré úsilí na jedinou implementaci a zajistit konzistentní chování aplikace na obou platformách, což je v souladu s požadavkem na efektivní využití dostupných zdrojů.

#### 4.1.2 Srovnání Multiplatformních Frameworků

Na základě rozhodnutí pro multiplatformní přístup je v této podsekci provedeno srovnání tří hlavních frameworků, které jsou v současnosti nejčastěji využívány pro vývoj mobilních aplikací: Flutter, React Native a Kotlin Multiplatform. Cílem srovnání je identifikovat framework, který nejlépe odpovídá požadavkům tohoto projektu, zejména s ohledem na vývoj jedním vývojářem, potřebu rychlého prototypování a integraci s externími AI službami prostřednictvím REST API.

Flutter je multiplatformní framework vyvinutý společností Google, který využívá programovací jazyk Dart. Klíčovou architektonickou vlastností je použití vlastního renderovacího enginu (Skia, nověji Impeller), díky kterému Flutter nevyužívá nativní UI komponenty platformy, ale vykresluje veškeré prvky rozhraní přímo na grafickém plátně. Tento přístup zajišťuje konzistentní vizuální výstup na všech podporovaných platformách bez ohledu na verzi operačního systému. Dart je kompilován přímo do nativního strojového kódu prostřednictvím AOT (*Ahead-of-Time*) kompilace, což přispívá k vysokému výkonu za běhu aplikace. V průběhu vývoje je naopak využívána JIT (*Just-in-Time*) kompilace umožňující funkci *hot reload*, která výrazně urychluje iterační cyklus. Ekosystém balíčků dostupných prostřednictvím registru pub.dev pokrývá širokou škálu funkcionalit včetně práce s kamerou, lokálními notifikacemi, databázemi a zdravotními daty [31].

React Native je framework vyvinutý společností Meta, který umožňuje vývoj mobilních aplikací v jazyce JavaScript, případně TypeScript. Na rozdíl od Flutteru React Native využívá nativní UI komponenty cílové platformy, k nimž přistupuje prostřednictvím komunikační vrstvy. Původní architektura založená na asynchronním *bridge* byla postupně nahrazena novější architekturou JSI (*JavaScript Interface*) a systémem Fabric, které snižují režii komunikace mezi JavaScriptovým vláknem a nativní vrstvou. Silnou stránkou React Native je možnost využít znalosti z webového vývoje v ekosystému React a rozsáhlá komunita vývojářů sdílející balíčky prostřednictvím registru npm. Omezením je historicky nižší výkon v graficky náročných scénářích oproti nativním řešením a složitější ladění při práci s nativními moduly [32].

Kotlin Multiplatform je technologie vyvíjená společností JetBrains, která umožňuje sdílení business logiky napsané v jazyce Kotlin mezi platformami Android, iOS a dalšími cílovými prostředími. V základním režimu zůstává uživatelské rozhraní nativní (Jetpack Compose pro Android, SwiftUI pro iOS), přičemž sdílena je pouze doménová a síťová vrstva. Experimentální rozšíření Compose Multiplatform umožňuje sdílení i prezentační vrstvy, avšak podpora pro iOS se v době psaní této práce nachází ve fázi beta. Výhodou Kotlin Multiplatform je přirozená integrace s ekosystémem jazyka Kotlin a možnost sdílet logiku bez kompromisů v uživatelském rozhraní. Omezením je relativní novost technologie a menší ekosystém multiplatformních knihoven ve srovnání s Flutter a React Native [33].

Srovnání klíčových vlastností uvedených frameworků je shrnuto v Tab. 4.1. Kritéria zahrnují použitý programovací jazyk, architekturu vykreslování, přibližnou míru sdílení kódu, podporu hot reload, velikost ekosystému a zralost platformy.

**Tab. 4.1** Srovnání multiplatformních frameworků pro mobilní vývoj — Flutter, React Native a Kotlin Multiplatform

| Kritérium | Flutter | React Native | Kotlin Multiplatform |
|---|---|---|---|
| Jazyk | Dart | JavaScript / TypeScript | Kotlin |
| Vykreslování | Vlastní engine (Skia / Impeller) | Nativní UI komponenty | Nativní UI / Compose Multiplatform |
| Kompilace | AOT do nativního kódu | JIT (Hermes engine) | AOT (Kotlin/Native) |
| Sdílení kódu | 90–95 % (UI + logika) | 80–90 % (logika + UI) | 50–70 % (logika) / 80–90 % (s Compose MP) |
| Hot reload | Ano | Ano (Fast Refresh) | Částečně (Compose preview) |
| Ekosystém balíčků | pub.dev | npm (sdílený s webem) | Maven / Gradle (menší MP ekosystém) |
| Zralost platformy | Stabilní (od 2018) | Stabilní (od 2015) | Stabilní logika; UI sdílení v beta |

Z provedeného srovnání vyplývá, že pro potřeby tohoto projektu se jako nejvhodnější jeví framework Flutter. Rozhodujícími faktory jsou nejvyšší míra sdílení kódu včetně prezentační vrstvy, což je klíčové pro vývoj realizovaný jedním vývojářem, konzistentní vykreslování na obou platformách bez závislosti na nativních komponentách a zralý ekosystém balíčků pokrývající všechny požadované funkcionality aplikace (práce s kamerou, řečový vstup, lokální databáze, notifikace, zdravotní data). Funkce *hot reload* navíc výrazně urychluje iterační cyklus, což je při vývoji v rámci diplomové práce s omezenými časovými zdroji podstatnou výhodou. Konkrétní zdůvodnění volby frameworku Flutter a dalších technologií je podrobněji rozvedeno v navazující sekci 4.2.

### 4.2 Výběr Technologií

Na základě analytického srovnání přístupů k vývoji mobilních aplikací provedeného v sekci 4.1 byly pro implementaci aplikace Foody zvoleny konkrétní technologie a knihovny. Tato sekce zdůvodňuje výběr jednotlivých technologických komponent s ohledem na specifické požadavky projektu definované funkčními a nefunkčními požadavky v sekci 3.2.3. Nejprve je v podsekci 4.2.1 popsána zvolená vývojová platforma, následuje volba databázové vrstvy a mechanismu perzistence dat (4.2.2), integrace AI modelu a komunikace s externím API (4.2.3) a přehled dalších klíčových knihoven třetích stran (4.2.4).

#### 4.2.1 Vývojová Platforma

V návaznosti na srovnání multiplatformních frameworků provedené v sekci 4.1 byl pro implementaci aplikace Foody zvolen framework Flutter s programovacím jazykem Dart. Rozhodujícími faktory identifikovanými v rámci srovnání byly nejvyšší míra sdílení kódu včetně prezentační vrstvy, konzistentní vykreslování nezávislé na nativních komponentách a zralý ekosystém balíčků. Tato podsekce doplňuje analytické srovnání o konkrétní vlastnosti jazyka Dart a platformy Flutter, které se ukázaly jako podstatné v průběhu samotné implementace.

Jednou z klíčových vlastností jazyka Dart, která se v kontextu tohoto projektu projevila jako přínosná, je podpora *null safety* na úrovni typového systému. Aplikace pro sledování kalorického příjmu pracuje s rozsáhlými datovými strukturami získávanými z různých zdrojů, včetně strukturovaných JSON odpovědí z AI modelu, dat z databáze Open Food Facts a uživatelských vstupů. Striktní rozlišování nullable a non-nullable typů umožňuje zachytit řadu potenciálních chyb již v době kompilace, což přispívá k vyšší robustnosti kódu při zpracování neúplných nebo neočekávaných dat [31]. Dalším přínosem je nativní podpora asynchronního programování prostřednictvím konstrukcí `async`/`await` a třídy `Future`, která zjednodušuje implementaci paralelních operací, jako jsou současné dotazy na AI API a lokální databázi.

Z hlediska architektury uživatelského rozhraní využívá Flutter deklarativní přístup založený na kompozici widgetů. Každý vizuální prvek aplikace, od jednoduchého textového popisku až po komplexní obrazovku denního přehledu, je reprezentován jako widget, přičemž výsledné rozhraní vzniká hierarchickým skládáním těchto komponent. Pro aplikaci zaměřenou na sledování kalorického příjmu, která obsahuje datově orientované obrazovky s grafy, tabulkami, formuláři a dynamicky generovanými seznamy ingrediencí, se tento přístup jeví jako vhodný, protože umožňuje opakované využití jednou definovaných komponent napříč různými obrazovkami. V projektu Foody bylo na tomto principu postaveno přibližně 60 obrazovek organizovaných do tematických skupin (onboarding, skenování, jídla, cvičení, profil), přičemž sdílené widgety, jako jsou karty nutričních hodnot, vstupní pole pro ingredience nebo grafové komponenty, jsou definovány v adresáři `lib/widgets/` a využívány napříč celou aplikací [31].

V rámci ekosystému balíčků dostupných prostřednictvím registru pub.dev bylo pro tento projekt identifikováno a integrováno více než 30 knihoven třetích stran pokrývajících klíčové funkcionality definované funkčními požadavky. Mezi ně patří zejména balíčky pro práci s kamerou a fotografiemi (`camera`, `image_picker`), hlasovou transkripci (`speech_to_text`), skenování čárových kódů (`mobile_scanner`), lokální notifikace (`flutter_local_notifications`), integraci se zdravotními platformami (`health`) a lokalizaci (`easy_localization`). Dostupnost těchto knihoven v rámci jednoho ekosystému umožnila soustředit implementační úsilí na doménovou logiku aplikace namísto vývoje nízkoúrovňových platformně specifických řešení. Podrobný přehled jednotlivých knihoven a jejich role v projektu je uveden v podsekci 4.2.4.

Aplikace je primárně vyvíjena a testována pro operační systém iOS, přičemž díky multiplatformní povaze frameworku Flutter je zároveň funkční na platformě Android. Projekt využívá Flutter ve verzi 3.35 s jazykem Dart ve verzi 3.9, přičemž minimální požadovaná verze Dart SDK je stanovena na 3.9.0. Pro vizuální styl aplikace byl zvolen Material Design jako výchozí designový systém, doplněný o vlastní návrhové tokeny definované v souboru `lib/app_theme.dart`, které zajišťují konzistentní vzhled napříč všemi obrazovkami aplikace. Funkce *hot reload*, umožňující okamžitou aplikaci změn v kódu bez nutnosti restartu aplikace, výrazně urychlila iterační cyklus v průběhu vývoje a ladění uživatelského rozhraní [31].

Celkově lze konstatovat, že volba frameworku Flutter a jazyka Dart umožnila realizovat implementaci pokrývající obě hlavní mobilní platformy z jednoho kódového základu při zachování dostatečného výkonu a přístupu k platformním funkcím. Tato volba se v průběhu implementace potvrdila jako vhodná zejména díky kombinaci typové bezpečnosti jazyka Dart, zralého ekosystému balíčků a rychlého iteračního cyklu umožněného funkcí hot reload. Konkrétní technologická rozhodnutí navazující na tuto platformní volbu, zejména výběr databázové vrstvy a mechanismu komunikace s AI modelem, jsou popsána v následujících podsekcích.

#### 4.2.2 Databáze a Perzistence Dat

Pro ukládání strukturovaných dat aplikace Foody bylo nezbytné zvolit databázový systém, který umožní efektivní správu relačních entit a zároveň bude kompatibilní s platformou Flutter a jazykem Dart. Vedle relační databáze bylo třeba zajistit perzistenci jednoduchých uživatelských nastavení a bezpečné načítání konfiguračních údajů, jako jsou klíče k externím API. Tato podsekce popisuje zvolenou databázovou vrstvu, mechanismus klíč-hodnota úložiště a správu konfigurace prostředí.

Jako primární databázová vrstva byl zvolen framework Floor, který představuje objektově-relační mapování (ORM) nad databází SQLite pro jazyk Dart. Floor využívá anotacemi řízené generování kódu prostřednictvím nástroje `build_runner`, čímž automaticky vytváří implementace datových přístupových objektů (DAO) a databázových tříd na základě deklarativních definic entit a dotazů. V projektu Foody je definováno 9 databázových entit s odpovídajícími 9 DAO třídami, přičemž veškerý přístup k datům probíhá prostřednictvím typově bezpečného rozhraní v jazyce Dart. Typová bezpečnost v kombinaci s generováním kódu eliminuje celou kategorii chyb, které by při přímém použití SQL dotazů mohly vzniknout v důsledku nesprávných názvů sloupců, chybějících parametrů nebo neočekávaných datových typů [35].

Z hlediska porovnání s alternativními řešeními byly v průběhu technologického výběru zváženy knihovny Hive, Isar a drift (dříve moor). Hive nabízí rychlé klíč-hodnota úložiště s podporou binární serializace, avšak postrádá podporu relačních vazeb mezi entitami, které jsou pro datový model aplikace Foody s normalizovaným schématem a kaskádovým mazáním záznamů nezbytné. Isar v době zahájení implementace představoval novější řešení s omezenější dokumentací a menší komunitní podporou ve srovnání s Floor. Drift nabízí srovnatelnou funkcionalitu jako Floor, včetně typově bezpečných SQL dotazů a generování kódu, avšak Floor byl zvolen na základě jeho jednoduššího anotačního modelu a přímočařejší integrace se vzorem DAO, který umožňuje deklarativní definici dotazů přímo v abstraktních třídách pomocí anotace `@Query`.

Dalším klíčovým prvkem databázové vrstvy je podpora reaktivních streamů. Floor umožňuje definovat dotazy vracející typ `Stream<List<Entity>>`, což zajišťuje automatickou notifikaci prezentační vrstvy při jakékoliv změně dat v příslušné tabulce. V kontextu aplikace pro sledování kalorického příjmu, kde uživatel průběžně přidává a upravuje záznamy o jídlech a cvičení, je tato vlastnost podstatná, protože eliminuje nutnost manuální synchronizace mezi stavem databáze a stavem uživatelského rozhraní. Repozitářová vrstva, která z databázových entit sestavuje doménové agregáty, je podrobně popsána v sekci 4.4.

Pro perzistenci jednoduchých uživatelských nastavení, jako jsou údaje profilu (hmotnost, výška, datum narození, pohlaví), preference aplikace (metrické jednotky, povolení notifikací, zapnutí sledování spálených kalorií) a stav onboardingu, byl zvolen balíček `shared_preferences`. Tento mechanismus poskytuje klíč-hodnota úložiště s podporou základních datových typů (`bool`, `int`, `double`, `String`) a je v projektu zapouzdřen do služby `SharedPreferencesService`, která centralizuje veškerý přístup k uloženým preferencím. Na rozdíl od relačních dat spravovaných prostřednictvím Floor se jedná o jednoduché konfigurační hodnoty, u nichž není zapotřebí relačních vazeb ani komplexních dotazů.

Bezpečné načítání konfiguračních údajů prostředí, zejména API klíčů pro komunikaci s externími službami OpenAI a Google Gemini, je realizováno prostřednictvím balíčku `flutter_dotenv`. Klíče jsou uloženy v souboru `.env` v kořenovém adresáři projektu, který je vyloučen z verzovacího systému prostřednictvím souboru `.gitignore`, čímž je zamezeno neúmyslnému zveřejnění citlivých údajů. Při spuštění aplikace jsou hodnoty ze souboru `.env` načteny do paměti a zpřístupněny prostřednictvím rozhraní `dotenv.env`, odkud je využívají síťoví klienti pro autorizaci API požadavků. Podrobný popis datového modelu a schématu databáze je uveden v sekci 4.4.

#### 4.2.3 AI Model a Komunikace s API

V rámci návrhu aplikace Foody bylo jako klíčová technologická komponenta identifikováno propojení s externím AI modelem, který zajišťuje automatické rozpoznávání jídel z fotografií, analýzu cvičení z textových popisů a generování nutričních doporučení. Tato podsekce popisuje výběr konkrétního AI poskytovatele, zdůvodnění přístupu založeného na vzdáleném cloudovém API a základní komunikační vzor mezi mobilním klientem a API koncovým bodem.

Jako primární AI poskytovatel byl zvolen multimodální jazykový model od společnosti OpenAI, přístupný prostřednictvím rozhraní Chat Completions API. Tento model podporuje vstup kombinující textové instrukce s obrazovými daty kódovanými ve formátu Base64, což umožňuje předat mu fotografii jídla společně se strukturovaným promptem a kontextem uživatelského profilu v rámci jediného API požadavku. Odpověď modelu je strukturována ve formátu JSON definovaném v rámci systémového promptu, přičemž obsahuje identifikaci jídla, odhad nutričních hodnot jednotlivých ingrediencí, numerickou míru nejistoty a celkový výsledek analýzy. Pro implementaci HTTP komunikace s API koncovým bodem je využita knihovna Dio, která poskytuje podporu pro konfiguraci hlaviček, nastavení časových limitů a strukturované zpracování chybových odpovědí [36].

Z hlediska alternativních přístupů byl při technologickém výběru zvážen rovněž přístup založený na modelu běžícím přímo na zařízení (*on-device inference*). Cloudový přístup byl upřednostněn z několika důvodů. Multimodální modely provozované v cloudové infrastruktuře poskytují podstatně vyšší kvalitu rozpoznávání u složitějších vizuálních scénářů, jako jsou kombinovaná jídla s více ingrediencemi na jednom talíři, než modely komprimované pro běh na mobilním zařízení. Aktualizace modelu na straně poskytovatele se projeví okamžitě bez nutnosti vydání nové verze aplikace, což zjednodušuje údržbu a umožňuje těžit z průběžného zlepšování schopností modelu. Podpora strukturovaného JSON výstupu, kterou cloudové API nabízí prostřednictvím systémových promptů, umožňuje přímé mapování odpovědi na typované datové modely v jazyce Dart bez nutnosti implementace vlastního parseru.

Jako alternativní AI poskytovatel byl do architektury aplikace integrován model Google Gemini, přístupný prostřednictvím rozhraní Generative Language API. Architektura komunikační vrstvy je navržena jako providerově agnostická s využitím abstraktního rozhraní `AiService`, které definuje jednotný kontrakt pro generování odpovědí bez ohledu na konkrétního poskytovatele. Třída `AiServiceManager` spravuje aktuálně zvoleného poskytovatele a umožňuje za běhu přepínat mezi implementacemi `OpenAiService` a `GeminiService`, přičemž obě třídy implementují totéž rozhraní. Tento návrh umožňuje rozšíření o další poskytovatele bez zásahu do vyšších vrstev aplikace [37].

Na straně bezpečnosti komunikace je vstup uživatele před odesláním do API ošetřen prostřednictvím třídy `PromptSanitizer`, která provádí sanitizaci vstupního textu (odstranění řídících znaků, ořez na maximální povolenou délku), detekci podezřelých vzorů naznačujících pokus o *prompt injection* a obalení uživatelského textu do XML delimitérů (`<user_input>...</user_input>`) pro strukturální izolaci od systémových instrukcí. Systémové prompty obsahují explicitní direktivu zakazující modelu interpretovat obsah uživatelského vstupu jako instrukce. Tato vícevrstvá ochrana snižuje riziko manipulace chování modelu prostřednictvím záměrně formulovaných vstupů.

Přístup založený na cloudovém API s sebou nese rovněž omezení, která je třeba zohlednit. Aplikace vyžaduje pro funkci AI rozpoznávání aktivní internetové připojení, přičemž zbývající funkcionality (manuální záznam, prohlížení historie, export dat) jsou plně dostupné v režimu offline. Latence API požadavku se v závislosti na velikosti odesílaného obrázku a vytížení poskytovatele pohybuje řádově v jednotkách sekund, což vyžaduje vhodný návrh uživatelského rozhraní s indikací probíhajícího zpracování. V neposlední řadě je každý API požadavek zpoplatněn dle cenového modelu poskytovatele, což představuje provozní náklad, jehož výše je úměrná frekvenci používání AI funkcí. Podrobný popis architektury AI pipeline, struktury promptů a mechanismu práce s nejistotou výstupu je uveden v sekci 4.5.

#### 4.2.4 Další Klíčové Knihovny

Kromě vývojové platformy Flutter, databázové vrstvy Floor a integrace s AI modely využívá aplikace Foody řadu dalších knihoven třetích stran, které pokrývají specifické funkcionality definované funkčními požadavky. V průběhu implementace bylo z registru pub.dev integrováno více než 30 balíčků, z nichž nejvýznamnější jsou shrnuty v Tab. 4.2 spolu s jejich účelem a zdůvodněním volby [38].

**Tab. 4.2** Přehled klíčových knihoven třetích stran použitých v aplikaci — název, účel a zdůvodnění volby

| Knihovna | Účel | Zdůvodnění volby |
|---|---|---|
| `speech_to_text` | Hlasová transkripce vstupů (cs/en) | Podpora českého jazyka, integrace s nativními rozpoznávači iOS a Android |
| `mobile_scanner` | Skenování čárových kódů (EAN) | Vysoká rychlost detekce, podpora formátů EAN-8 a EAN-13 |
| `flutter_local_notifications` | Plánování lokálních notifikací | Podpora časově plánovaných notifikací s respektováním časových zón |
| `easy_localization` | Lokalizace aplikace (en, cs) | Generování typově bezpečných klíčů, podpora JSON překladových souborů |
| `health` | Integrace s Apple Health / Health Connect | Jednotné API pro čtení a zápis zdravotních dat napříč platformami |
| `image_picker` | Výběr fotografií z galerie a kamery | Standardní Flutter plugin s podporou obou mobilních platforem |
| `camera` | Přímý přístup ke kameře zařízení | Vlastní skenovací rozhraní pro fotografický vstup a skenování etiket |
| `json_serializable` | Serializace a deserializace datových modelů | Generování `fromJson`/`toJson` metod prostřednictvím `build_runner` |
| `home_widget` | Widgety na domovskou obrazovku zařízení | Zobrazení denního souhrnu kalorií bez nutnosti otevření aplikace |
| `dio` | HTTP klient pro síťovou komunikaci | Podpora interceptorů, časových limitů a strukturovaného zpracování chyb |
| `connectivity_plus` | Detekce stavu internetového připojení | Rozlišení online a offline režimu pro podmíněné spouštění AI funkcí |
| `pdf` a `csv` | Export dat do formátů PDF a CSV | Generování strukturovaných dokumentů pro sdílení nutričních záznamů |
| `share_plus` | Sdílení obsahu prostřednictvím systémového dialogu | Distribuce exportovaných souborů a snímků uživateli |
| `timezone` | Práce s časovými zónami | Korektní plánování notifikací a zobrazování časových údajů |

Z hlediska správy závislostí je většina uvedených knihoven deklarována v souboru `pubspec.yaml` s fixními verzemi, což zajišťuje reprodukovatelnost sestavení projektu. Knihovny vyžadující generování kódu (`floor`, `json_serializable`) jsou doplněny o odpovídající generátory v sekci `dev_dependencies` a jejich výstupní soubory jsou regenerovány příkazem `flutter pub run build_runner build --delete-conflicting-outputs` po každé změně dotčených entit nebo datových modelů.

Celkově lze konstatovat, že dostupnost zralých a aktivně udržovaných knihoven v ekosystému Flutter umožnila soustředit implementační úsilí na doménovou logiku aplikace, konkrétně na AI pipeline, správu nutričních dat a uživatelské interakční toky, namísto vývoje nízkoúrovňových komponent od základu. Konkrétní způsob, jakým jsou tyto knihovny provázány v rámci softwarové architektury aplikace, je popsán v sekci 4.3.

### 4.3 Softwarová Architektura

Na základě technologií zvolených v sekci 4.2 byla navržena softwarová architektura aplikace Foody optimalizovaná pro lokální zpracování dat s komunikací s externími AI službami prostřednictvím REST API. Architektura vychází z návrhového vzoru *Model-View-ViewModel* (MVVM) adaptovaného pro prostředí frameworku Flutter s využitím reaktivních rozšíření knihovny GetX a doplněného o další etablované vzory, jako jsou *Repository*, *Strategy* a *Service Locator*. Tato sekce popisuje celkovou architekturu systému včetně použitých architektonických vzorů, zvolené přístupy ke správě reaktivního stavu a registraci závislostí a navigační model s organizací obrazovek. V podsekci 4.3.1 je představena celková architektura klientské aplikace bez vlastního backendu, včetně vrstveného uspořádání komponent, použitých návrhových vzorů a struktury projektu. Podsekce 4.3.2 se zaměřuje na správu reaktivního stavu prostřednictvím frameworku GetX a centralizovanou registraci závislostí. V závěrečné podsekci 4.3.3 je popsán navigační model aplikace, struktura hlavní obrazovky a organizace přibližně 60 obrazovek do tematických skupin.

#### 4.3.1 Celková Architektura Systému

V rámci návrhu architektury aplikace Foody bylo základním rozhodnutím zvolení přístupu bez vlastního backendového serveru. Aplikace je koncipována jako samostatný mobilní klient, který veškerá uživatelská data ukládá lokálně na zařízení v databázi SQLite a s externími službami komunikuje přímo prostřednictvím REST API. Tento architektonický přístup byl zvolen na základě čtyř klíčových faktorů: zachování maximální jednoduchosti řešení přiměřené rozsahu diplomové práce, podpora plné funkčnosti v režimu offline s výjimkou AI rozpoznávání vyžadujícího cloudové zpracování, ochrana soukromí uživatelských dat, která neopouštějí zařízení, a eliminace provozních nákladů spojených s údržbou serverové infrastruktury.

Z hlediska komunikace s externími službami aplikace využívá tři vzdálená API. Primárním poskytovatelem AI analýzy je rozhraní OpenAI Chat Completions API, prostřednictvím kterého jsou zpracovávány fotografické a textové vstupy pro rozpoznávání jídel, analýzu cvičení a generování nutričních doporučení. Jako alternativní AI poskytovatel je integrováno rozhraní Google Gemini Generative Language API, přičemž architektura umožňuje za běhu přepínat mezi oběma poskytovateli, jak bylo popsáno v sekci 4.2.3. Pro vyhledávání nutričních údajů produktů na základě čárového kódu je využíváno veřejné API služby Open Food Facts. Veškerá síťová komunikace probíhá prostřednictvím HTTP klienta Dio, který zajišťuje jednotné zpracování časových limitů, chybových odpovědí a autorizačních hlaviček. Schéma celkové architektury zahrnující mobilního klienta, lokální databázi a externí služby je znázorněno na Obr. 4.1.

[FIGURE PLACEHOLDER: Schéma celkové architektury aplikace Foody — mobilní klient s vrstvami (UI, Controllers, Services, Network, Database), lokální SQLite databáze a tři externí API (OpenAI Chat Completions, Google Gemini, Open Food Facts) s naznačenými směry komunikace a typem přenášených dat (Base64 obrázky, JSON prompty, JSON odpovědi, HTTP GET požadavky na barcode endpoint)]

**Obr. 4.1** Schéma celkové architektury aplikace Foody — vrstvený mobilní klient, lokální SQLite databáze a komunikace s externími službami (OpenAI, Google Gemini, Open Food Facts)

Z hlediska architektonického vzoru je vnitřní organizace klientské aplikace založena na vzoru *Model-View-ViewModel* (MVVM), který odděluje prezentační vrstvu od doménové a datové logiky prostřednictvím mezilehlé vrstvy ViewModelů spravujících stav uživatelského rozhraní [39]. V klasické definici MVVM komunikuje vrstva View s vrstvou ViewModel prostřednictvím obousměrného *data binding*, přičemž ViewModel vystavuje pozorovatelné vlastnosti, na jejichž změny se View automaticky naváže. V kontextu frameworku Flutter a knihovny GetX je tento mechanismus realizován prostřednictvím reaktivních typů (`Rx<T>`, `RxList<T>`, `RxBool`) deklarovaných v třídách kontrolerů a widgetů `Obx()`, které se na tyto proměnné naváží a automaticky překreslí příslušnou část rozhraní při změně hodnoty. Oproti klasickému MVVM s obousměrným *data binding* se jedná o jednosměrnou reaktivní vazbu, čímž se tato implementace blíží variantě MVVM s reaktivními rozšířeními, obdobně jako architektura Android Jetpack s komponentou LiveData. Kromě vzoru MVVM jsou v architektuře aplikace uplatněny další etablované návrhové vzory: vzor *Repository* pro abstrakci přístupu k datům za jednotným rozhraním, vzor *Strategy* pro zaměnitelné implementace AI poskytovatelů umožňující přepínání za běhu a vzor *Service Locator* pro centralizovanou správu závislostí mezi komponentami.

V souladu se vzorem MVVM je vnitřní architektura mobilního klienta organizována do pěti logických vrstev, které lze mapovat na tři základní role tohoto vzoru. Nejvyšší vrstvou je prezentační vrstva (View), tvořená obrazovkami (adresář `lib/screens/`) a sdílenými widgety (`lib/widgets/`), která definuje uživatelské rozhraní aplikace prostřednictvím deklarativní kompozice Flutter widgetů. Pod ní se nachází vrstva kontrolerů (ViewModel, adresář `lib/controller/`), jejíž komponenty rozšiřují třídu `GetxController` a zapouzdřují prezentační logiku jednotlivých obrazovek včetně reakcí na uživatelské akce a správy reaktivního stavu zobrazených dat prostřednictvím pozorovatelných proměnných. Zbývající tři vrstvy společně tvoří vrstvu Model vzoru MVVM: vrstva služeb a repozitářů (`lib/services/`) implementuje doménovou logiku aplikace včetně AI pipeline pro zpracování vstupů, správy uživatelského profilu, plánování notifikací a sestavování doménových agregátů z databázových entit.

Přístup k datům zajišťují dvě oddělené vrstvy odpovídající dvěma typům datových zdrojů aplikace, přičemž abstrakci nad těmito zdroji poskytuje vzor *Repository*. Lokální datová vrstva (`lib/database/`) obsahuje definice databázových entit, datových přístupových objektů (DAO) a migračních skriptů frameworku Floor, přičemž zajišťuje typově bezpečný přístup k relačním datům uloženým v SQLite. Síťová vrstva (`lib/network/`) zapouzdřuje REST klienty pro komunikaci s externími API a poskytuje vyšším vrstvám typované odpovědi bez nutnosti pracovat přímo s HTTP protokolem. Repozitáře (například `DayRecordRepository`) fungují jako fasáda nad těmito datovými zdroji: koordinují přístup k příslušným DAO, transformují databázové entity na doménové modely a vystavují výsledky prostřednictvím reaktivních streamů, čímž kontrolery a služby nejsou vázány na konkrétní implementaci úložiště. Na nejnižší úrovni stojí vrstva modelů (`lib/model/`), která definuje datové třídy s podporou serializace prostřednictvím knihovny `json_serializable` a slouží jako společný jazyk pro výměnu dat mezi ostatními vrstvami.

Na úrovni adresářové struktury projektu odpovídá každá architektonická vrstva samostatnému adresáři v rámci kořenového adresáře `lib/`. Kromě výše popsaných vrstev projekt obsahuje adresář `lib/utils/` se sdílenými pomocnými funkcemi, jako jsou definice promptů pro AI model, validační logika a formátovací utility, a adresář `lib/generated/` s automaticky generovanými soubory pro lokalizaci a databázový kód, které nejsou editovány ručně. Konfigurační soubor `lib/app_theme.dart` centralizuje veškeré návrhové tokeny aplikace (barvy, rozestupy, typografie, stíny), čímž zajišťuje konzistentní vizuální styl napříč všemi obrazovkami. Vstupním bodem aplikace je soubor `lib/main.dart`, který řídí inicializační sekvenci zahrnující načtení konfigurace prostředí, registraci závislostí, obnovení uživatelské relace a spuštění plánovaných notifikací, přičemž samotná konfigurace `MaterialApp` je definována v souboru `lib/app.dart` [31].

Komunikace mezi vrstvami probíhá prostřednictvím vzoru *Service Locator*, který je realizován pomocí registru závislostí frameworku GetX [39]. Kontrolery a služby nezískávají své závislosti přímým vytvářením instancí, ale prostřednictvím centralizovaného registru, do kterého jsou veškeré komponenty zaregistrovány při spuštění aplikace v souboru `lib/locator.dart`. Na rozdíl od vzoru *Dependency Injection*, kde jsou závislosti předávány prostřednictvím konstruktoru, vzor Service Locator umožňuje komponentám aktivně vyhledávat požadované závislosti za běhu voláním `Get.find<T>()`. Tento přístup zároveň umožňuje nahrazovat implementace za běhu, čehož je využito při realizaci vzoru *Strategy* v architektuře AI služeb, kde třída `AiServiceManager` dynamicky přepíná mezi konkrétními implementacemi rozhraní `AiService` (viz sekce 4.2.3). Podrobný popis správy stavu, reaktivních typů a mechanismu registrace závislostí je uveden v následující sekci 4.3.2.

#### 4.3.2 Správa Stavu a Dependency Injection

V podsekci 4.3.1 byl představen vzor Service Locator jako základní mechanismus komunikace mezi architektonickými vrstvami aplikace. Tato podsekce se zaměřuje na konkrétní realizaci správy stavu a registrace závislostí prostřednictvím frameworku GetX, který v projektu Foody slouží jako jednotné řešení pro tři vzájemně provázané oblasti: reaktivní správu stavu uživatelského rozhraní, správu životního cyklu komponent a centralizovanou registraci závislostí [39]. Na rozdíl od alternativních přístupů v ekosystému Flutter, jako jsou balíčky Provider, Riverpod nebo BLoC, které se typicky specializují na jednu z uvedených oblastí, GetX integruje všechny tři aspekty do jednoho frameworku, čímž snižuje počet externích závislostí projektu a umožňuje konzistentní přístup ke správě stavu napříč celou aplikací.

Z hlediska životního cyklu komponent rozlišuje GetX dva základní typy řízených objektů, které odpovídají odlišným rolím v architektuře aplikace. Prvním typem jsou služby s životním cyklem vázaným na celou dobu běhu aplikace, které jsou inicializovány při startu a zůstávají v paměti až do jejího ukončení. V projektu Foody do této kategorie spadají komponenty zodpovědné za správu uživatelského profilu, perzistenci preferencí, plánování notifikací, výpočet vizualizací kalendáře a všechny repozitáře zajišťující přístup k databázovým entitám. Druhým typem jsou kontrolery s životním cyklem typicky vázaným na konkrétní obrazovku nebo skupinu obrazovek, které spravují prezentační stav a reagují na uživatelské akce. Framework poskytuje kontrolerům sadu životních metod volaných při inicializaci, připravenosti a uzavření komponenty, čímž umožňuje strukturovanou správu zdrojů a asynchronních operací [39].

V rámci kontrolerové vrstvy je definována společná abstraktní bázová třída, která slouží jako předek pro většinu kontrolerů v aplikaci a poskytuje sdílenou funkcionalitu využívanou napříč celou prezentační vrstvou. Tato třída zapouzdřuje zejména logiku ověřování dostupnosti internetového připojení s volitelným zobrazením informačního dialogu a předdefinovaný indikátor průběhu. Zároveň umožňuje kontrolerům reagovat na změny stavu životního cyklu aplikace na úrovni operačního systému, jako je přechod do pozadí, návrat do popředí nebo neaktivita, čehož je využito například pro automatické obnovení dat při návratu uživatele do aplikace.

Registrace veškerých komponent do registru závislostí probíhá centralizovaně v jednom konfiguračním souboru, který je volán při spuštění aplikace ještě před vykreslením prvního snímku uživatelského rozhraní. Celkem je takto zaregistrováno 37 komponent prostřednictvím tří registračních strategií, které se liší okamžikem vytvoření instance a jejím chováním při uvolnění z paměti. Permanentní registrace vytváří instanci okamžitě a zajišťuje její dostupnost po celou dobu běhu aplikace, přičemž je využívána pro klíčové služby a repozitáře. Odložená registrace odkládá vytvoření instance až do okamžiku prvního vyžádání, čímž snižuje paměťovou náročnost při startu aplikace. Třetí strategií je odložená registrace s automatickou reinicializací, která zajišťuje, že pokud je instance uvolněna z paměti při opuštění obrazovky, framework ji při dalším vyžádání automaticky vytvoří znovu, čímž je garantováno korektní obnovení stavu při opakované navigaci [39].

Na úrovni přístupu k registrovaným komponentám je v celém projektu uplatněn standardizovaný vzor, kdy každá služba a kontroler vystavuje statický přístupový bod umožňující typově bezpečné vyhledání instance z jakéhokoliv místa v kódu bez nutnosti předávání referencí přes konstruktor nebo kontext widgetového stromu. Reaktivní stav je deklarován prostřednictvím rodiny pozorovatelných typů pokrývajících základní datové typy, kolekce i nullable hodnoty. Prezentační vrstva se na tyto pozorovatelné proměnné naváže prostřednictvím speciálních widgetů, které automaticky sledují všechny reaktivní proměnné přečtené v rámci svého builderu a překreslí příslušnou část uživatelského rozhraní při změně kterékoliv z nich, bez nutnosti explicitní registrace odběratele či manuální invalidace stavu.

Kromě přímé vazby mezi pozorovatelnými proměnnými a uživatelským rozhraním využívá aplikace pro pokročilejší scénáře reaktivní propagace mechanismy umožňující imperativní reakci na změnu hodnoty. Jedním z nich je pozorovatel reagující na každou změnu sledované kolekce, který je využíván například v kontroleru hlavní obrazovky, kde sleduje změny v seznamu denních záznamů a při každé aktualizaci automaticky přepočítává statistiky aktivní série. Dalším mechanismem je naslouchání změnám jednotlivých proměnných, které umožňuje spouštět asynchronní operace, jako je načtení dat pro nově vybrané datum v kalendáři. Celkově lze konstatovat, že kombinace centralizované registrace závislostí, dvoutypového komponentového modelu a reaktivního systému poskytuje konzistentní infrastrukturu pro správu stavu a komunikaci mezi vrstvami aplikace, přičemž podrobnosti navigačního modelu a organizace obrazovek jsou popsány v následující podsekci 4.3.3.

#### 4.3.3 Navigace a Struktura Obrazovek

Pro navigaci mezi obrazovkami využívá aplikace Foody imperativní navigační model frameworku GetX, který je založen na přímém volání navigačních metod bez použití pojmenované tabulky rout [39]. Tento přístup byl zvolen na základě dvou faktorů: eliminace nutnosti udržovat centrální registr názvů rout synchronizovaný s implementací obrazovek a možnosti předávat typované parametry přímo prostřednictvím konstruktoru cílové obrazovky namísto serializace do textových argumentů. Základní navigační operace zahrnují přechod na novou obrazovku s přidáním na navigační zásobník, návrat na předchozí obrazovku a nahrazení aktuální obrazovky bez možnosti návratu, přičemž poslední varianta je využívána například při přechodu z onboardingového toku na hlavní rozhraní po dokončení prvotní konfigurace.

Kořenovou komponentou navigační hierarchie je hlavní obrazovka, která implementuje třízáložkový shell tvořící primární rozhraní aplikace po dokončení onboardingu. Jednotlivé záložky odpovídají třem hlavním funkčním oblastem: záložka Dashboard zobrazuje denní přehled kalorického příjmu, seznam zaznamenaných jídel a cvičení a kalorický souhrn dne; záložka Progress poskytuje týdenní a měsíční vizualizace, trendy hmotnosti a přehled plnění cílů; záložka Profile zpřístupňuje správu osobních údajů, nutričních cílů, nastavení aplikace a doplňkových funkcí včetně exportu dat a integrace se zdravotními platformami. Přepínání mezi záložkami je řízeno prostřednictvím reaktivní proměnné a neprovádí navigaci na novou obrazovku, nýbrž přepíná zobrazený obsah v rámci téhož kontejneru, čímž je zachován stav jednotlivých záložek při přepínání mezi nimi.

Součástí spodní navigační lišty je plovoucí akční tlačítko, které otevírá panel rychlých akcí obsahující pět primárních vstupních bodů pro záznam dat: vyhledání a záznam jídla z historie, skenování jídla z fotografie (případně s předřazenou instruktáží při prvním použití), hlasový záznam jídla, skenování čárového kódu a záznam cvičení. Tento panel funguje jako centrální rozcestník pro všechny modality záznamu definované funkčními požadavky a je dostupný z libovolné záložky hlavní obrazovky, čímž minimalizuje počet kroků potřebných k zahájení záznamu nové položky. Výběrem konkrétní akce je uživatel navigován na příslušnou obrazovku, přičemž panel je automaticky uzavřen.

Z hlediska organizace zdrojového kódu je celkem přibližně 58 obrazovek a modálních listů uspořádáno do tematických skupin. Skupina onboarding obsahuje 15 obrazovek pokrývajících prvotní konfiguraci uživatelského profilu od zadání pohlaví a cílů po výpočet kalorického plánu. Skupina skenování zahrnuje 4 obrazovky pro fotografický vstup, náhled výsledku AI rozpoznání, správu oprávnění kamery a úvodní instruktáž. Skupina jídel a ingrediencí sdružuje 8 obrazovek a modálních listů pro editaci záznamů, detailní zobrazení ingrediencí, kopírování jídel mezi dny a hlášení chyb AI rozpoznání. Skupina logování obsahuje 7 obrazovek pro hlasový vstup, záznam a detail cvičení a evidenci hmotnosti. Skupina profilu je s 18 obrazovkami nejrozsáhlejší a pokrývá osobní údaje, nutriční cíle, historii hmotnosti, export dat, integraci se zdravotními platformami, nastavení notifikací a dotazy v přirozeném jazyce prostřednictvím funkce Ask AI.

Pro hlavní scénáře záznamu jídla prostřednictvím fotografie je typický vícekrokový navigační tok, který odpovídá případu užití UC01 definovanému v sekci 3.2.2. Uživatel zahájí tok aktivací akce skenování z panelu rychlých akcí, čímž je navigován na obrazovku kamery, kde pořídí fotografii jídla. Po odeslání fotografie k AI analýze je zobrazen náhled výsledku s barevnou indikací míry nejistoty rozpoznání v souladu s funkčním požadavkem FR-08. V případě potvrzení výsledku je záznam uložen a uživatel je vrácen na hlavní obrazovku; v případě potřeby korekce je navigován na editační obrazovku, kde může upravit jednotlivé ingredience, gramáže a nutriční hodnoty. Alternativní toky, jako je opakované AI rozpoznání z editační obrazovky (FR-13) nebo kopírování existujícího záznamu na jiný den (FR-18), rozšiřují základní tok o doplňkové kroky bez narušení celkové navigační struktury.

Vedle plnohodnotných obrazovek využívá aplikace modální listy pro doplňkové interakce, které nevyžadují opuštění aktuálního kontextu. V projektu pokrývají modální listy funkcionality jako výběr data pro kopírování jídla, záznam hmotnosti, výběr data v kalendáři a volbu akce u detailu cvičení. Tento přístup respektuje navigační konvence mobilních platforem, kde modální listy slouží k rychlým akcím s návratem do kontextu nadřazené obrazovky bez ztráty jejího stavu. Podrobný popis datového modelu, nad kterým operují výše uvedené obrazovky a navigační toky, je uveden v následující sekci 4.4.

### 4.4 Datový Model

V návaznosti na softwarovou architekturu představenou v sekci 4.3 popisuje tato sekce konkrétní podobu datové vrstvy aplikace Foody. Důraz je kladen na strukturu lokální relační databáze, vztahy mezi jednotlivými entitami a způsob, jakým je nad těmito entitami sestavena repozitářová vrstva poskytující doménové agregáty prezentační vrstvě. Nejprve je v podsekci 4.4.1 popsáno schéma databáze a vztahy mezi devíti hlavními entitami. Podsekce 4.4.2 dokumentuje samostatný subsystém šablon pro opakovaně zapisované položky, který adresuje funkční požadavky na zrychlení záznamu. Závěrečná podsekce 4.4.3 popisuje repozitářovou vrstvu, transformaci databázových entit na doménové modely a mechanismus reaktivního zpřístupnění dat uživatelskému rozhraní.

#### 4.4.1 Schéma Databáze a Vztahy Mezi Entitami

V rámci datového modelu aplikace Foody je definováno celkem devět entit, které lze rozdělit do dvou logických skupin podle účelu uložených dat. Transakční skupinu tvoří pět entit zachycujících konkrétní časově vázané záznamy uživatele (denní záznam, jídlo, ingredience, cvičení, hmotnost), zatímco šablonová skupina sdružuje čtyři entity pro opakovaně používané položky, jejichž role je podrobně rozebrána v podsekci 4.4.2. Přehled všech entit, jejich klíčových atributů a vztahu k nadřazené entitě je uveden v Tab. 4.3, vizuální znázornění schématu s naznačenými cizími klíči a kardinalitami je zachyceno na Obr. 4.2.

[FIGURE PLACEHOLDER: ER diagram databázového schématu aplikace Foody — devět entit rozdělených do dvou skupin (transakční: DayRecord, Meal, Ingredient, Exercise, WeightEntry; šablonové: MealTemplate, MealTemplateIngredient, IngredientTemplate, ExerciseTemplate) s vyznačenými cizími klíči (Meal.dayRecordId → DayRecord.id, Ingredient.mealId → Meal.id, Exercise.dayRecordId → DayRecord.id, MealTemplateIngredient.templateId → MealTemplate.id), kardinalitami vztahů 1:N a označením kaskádového mazání u cizích klíčů]

**Obr. 4.2** ER diagram databázového schématu aplikace Foody — transakční a šablonové entity s vyznačenými cizími klíči, kardinalitami a kaskádovým chováním při mazání

**Tab. 4.3** Přehled databázových entit aplikace Foody — název entity, vybrané klíčové atributy a vztah k nadřazené entitě

| Entita | Vybrané atributy | Vztah k nadřazené entitě |
|---|---|---|
| `DayRecord` | `id`, `date` (unique), `calorieGoal`, `proteinGoal`, `carbsGoal`, `fatGoal` | — (kořenová entita) |
| `Meal` | `id`, `dayRecordId`, `name`, `timestamp`, `photoPath`, `confidence`, `barcode`, `isFavorite` | `dayRecordId` → `DayRecord.id` (CASCADE) |
| `Ingredient` | `id`, `mealId`, `name`, `weight`, `amount`, `calories`, `proteins`, `carbs`, `fats` | `mealId` → `Meal.id` (CASCADE) |
| `Exercise` | `id`, `dayRecordId`, `name`, `timestamp`, `durationMinutes`, `caloriesBurned`, `source` | `dayRecordId` → `DayRecord.id` (CASCADE) |
| `WeightEntry` | `id`, `date`, `weight`, `photoPath` | — (samostatná entita) |
| `MealTemplate` | `id`, `name`, `normalizedName` (unique), `photoPath`, `isFavorite`, `lastUsedAt`, `usageCount` | — (samostatná entita) |
| `MealTemplateIngredient` | `id`, `templateId`, `name`, `weight`, `calories`, `proteins`, `carbs`, `fats` | `templateId` → `MealTemplate.id` (CASCADE) |
| `IngredientTemplate` | `id`, `name`, `normalizedName` (unique), `weight`, `amount`, makroživiny, `usageCount` | — (samostatná entita) |
| `ExerciseTemplate` | `id`, `name`, `normalizedName` (unique), `durationMinutes`, `caloriesBurned`, `usageCount` | — (samostatná entita) |

Z hlediska struktury vazeb tvoří transakční entity dvouúrovňovou hierarchii s entitou `DayRecord` v kořeni. Entita `Meal` je s denním záznamem propojena vztahem 1:N prostřednictvím cizího klíče `dayRecordId`, čímž je každé zaznamenané jídlo jednoznačně přiřazeno právě jednomu dni. Entita `Ingredient` je obdobně připojena k jídlu vztahem 1:N prostřednictvím cizího klíče `mealId`, což zachycuje skutečnost, že každé jídlo se skládá z jedné nebo více ingrediencí, přičemž každá ingredience nese vlastní hmotnost v gramech v atributu `weight` a volitelně i kusové množství v atributu `amount` pro položky zapisované po porcích. Cvičení je k dennímu záznamu připojeno přímo vztahem 1:N přes cizí klíč `dayRecordId`, neboť cvičení nejsou zanořena do jídel a tvoří paralelní podstrom pod denním záznamem. Záznamy hmotnosti jsou modelovány jako samostatná entita bez vazby na denní záznam, což odpovídá jejich povaze nezávislého časového zápisu odděleného od nutričního denního cyklu.

V rámci normalizovaného schématu jsou veškeré cizí klíče deklarovány s pravidlem kaskádového mazání. Při odstranění denního záznamu jsou tedy automaticky odstraněna i všechna jídla a cvičení daného dne, přičemž odstranění jídla automaticky odstraní i všechny jeho ingredience. Tento mechanismus zajišťuje referenční integritu na úrovni databázového stroje SQLite a eliminuje riziko vzniku osiřelých záznamů v důsledku neúplných transakcí v aplikační vrstvě. Atomicita kaskádového mazání je obzvláště významná pro funkce uživatelského smazání denního záznamu nebo přechodu mezi profily, kde by manuální mazání podřízených záznamů zvyšovalo složitost aplikační logiky a riziko nekonzistence.

V průběhu návrhu schématu byla zvažována alternativa v podobě denormalizovaného úložiště, ve kterém by každý denní záznam obsahoval vnořený seznam jídel a ingrediencí v jednom řádku, například formou serializovaného JSON dokumentu. Tato varianta by sice zjednodušila načítání celého denního záznamu jediným dotazem, znemožnila by však efektivní dotazování napříč jednotlivými dny, vyhodnocování statistik za delší časová období a indexaci podle atributů jednotlivých jídel nebo ingrediencí. Klíčové analytické scénáře aplikace, jako jsou týdenní a měsíční přehledy, vyhledávání oblíbených položek napříč historií a vyhodnocování porušení dietních omezení, vyžadují přístup ke konkrétním atributům jídel a ingrediencí bez nutnosti načítat a parsovat celé denní záznamy. Z těchto důvodů bylo zvoleno normalizované schéma s referenční integritou vynucenou na úrovni databáze, doplněné o repozitářovou vrstvu, která tyto rozdrobené entity skládá zpět do doménových agregátů popsaných v podsekci 4.4.3.

Z hlediska indexace jsou v schématu definovány dva typy unikátních indexů. Sloupec `date` v entitě `DayRecord` je opatřen unikátním indexem, který zajišťuje existenci nejvýše jednoho denního záznamu pro daný kalendářní den a zároveň urychluje vyhledávání podle data, jež je nejčastější dotazovací operací aplikace. Sloupec `normalizedName` ve všech třech šablonových entitách je rovněž unikátní, což vynucuje deduplikaci šablon na úrovni databáze a umožňuje rychlé vyhledávání existující šablony podle normalizovaného názvu při ukládání nového záznamu.

#### 4.4.2 Systém Šablon pro Opakovaně Používané Položky

Jednou z opakujících se úloh při dlouhodobém sledování stravy je opětovný zápis identických nebo téměř identických položek, ať už se jedná o pravidelně konzumovaná jídla, často používané ingredience nebo opakované cvičební aktivity. Pro adresování této potřeby, vyplývající z funkčních požadavků FR-17 (oblíbené položky), FR-18 (duplikace dřívějších záznamů) a FR-19 (našeptávání názvů z historie), zavádí datový model aplikace Foody samostatný subsystém šablon. Subsystém je tvořen třemi šablonovými entitami pro jídla, ingredience a cvičení, které paralelně k transakčním entitám uchovávají kanonické verze opakovaně používaných položek. Každá šablona slouží jako zdroj dat při vytváření nového transakčního záznamu, aniž by byla s tímto záznamem trvale relačně vázána, což umožňuje editovat pozdější výskyt bez vlivu na šablonu samotnou.

Společným rysem všech tří šablonových entit je dvojice atributů `name` a `normalizedName`. Atribut `name` uchovává název v podobě, ve které jej uživatel zapsal, včetně velkých písmen, diakritiky a případných mezer na okrajích, čímž je v uživatelském rozhraní zachována původní vizuální podoba zápisu. Atribut `normalizedName` obsahuje technickou variantu téhož názvu po aplikaci normalizační funkce, která provádí převod na malá písmena a odstranění bílých znaků na okrajích, a slouží jako klíč pro deduplikaci. Na sloupci `normalizedName` je v každé ze tří šablonových entit definován unikátní index, který na úrovni databázového stroje vynucuje existenci nejvýše jedné šablony s daným normalizovaným názvem. Při uložení nového záznamu je tak okamžitě rozpoznáno, zda obdobná položka již v šablonách existuje, bez nutnosti procházet celou tabulku.

Pro řazení šablon v uživatelských nabídkách a vyhodnocování jejich aktuálnosti uchovává každá šablona dvojici metrik používání. Atribut `usageCount` zaznamenává počet záznamů, při jejichž ukládání byla šablona vytvořena nebo aktualizována, a slouží jako odhad celkové popularity dané položky v historii uživatele. Atribut `lastUsedAt` zachycuje časovou značku posledního výskytu, podle které lze v nabídkách upřednostnit nedávno používané položky před položkami zapomenutými. Kombinace obou metrik umožňuje implementovat smíšené řazení reflektující jak dlouhodobou frekvenci, tak nedávnou aktivitu, čímž je zlepšena relevance položek nabízených uživateli při zápisu nového záznamu.

Specifickým prvkem entity `MealTemplate` je její vazba na podřízenou entitu `MealTemplateIngredient`, která uchovává konkrétní skladbu ingrediencí dané šablony jídla. Vazba je realizována cizím klíčem `templateId` s pravidlem kaskádového mazání, čímž je odstranění šablony jídla doprovázeno odstraněním všech příslušných šablonových ingrediencí. Tento návrh umožňuje uložit u šablony jídla nejen jeho název, ale i kompletní rozpis ingrediencí včetně hmotností a nutričních hodnot, takže opětovné použití šablony obnovuje celé jídlo včetně jeho podrobností bez nutnosti dotazu na AI model nebo manuálního zápisu. U šablon ingrediencí a cvičení analogická vazba na podřízené entity neexistuje, neboť tyto položky jsou modelovány jako atomární bez vnitřní hierarchie.

Mechanismus naplňování šablon je realizován v aplikační vrstvě v okamžiku ukládání nového transakčního záznamu. Při uložení záznamu jídla je v kontroleru denního záznamu vyvolána operace převzetí položky do šablon nad odpovídajícím repozitářem, která podle normalizovaného názvu vyhledá existující šablonu: pokud existuje, inkrementuje její `usageCount` a aktualizuje cestu k fotografii, pokud neexistuje, založí nový záznam včetně vložení skladby ingrediencí. Obdobně jsou při ukládání záznamu jídla automaticky aktualizovány šablony jednotlivých ingrediencí. Analogický mechanismus je aplikován i při ukládání cvičení, kde dochází k aktualizaci šablon cvičebních aktivit. Šablony jsou tímto způsobem udržovány v aktuálním stavu bez explicitní akce uživatele, který tedy nemusí oddělené šablony spravovat ručně. Volání těchto operací probíhá v asynchronním režimu, takže neblokuje dokončení primární transakce uložení záznamu, čímž je zachována odezva uživatelského rozhraní.

#### 4.4.3 Repozitářová Vrstva a Doménové Modely

V rámci architektonického vzoru *Repository* zavedeného v sekci 4.3.1 je v aplikaci Foody definováno pět konkrétních repozitářů, z nichž každý zapouzdřuje přístup k jedné věcné oblasti datového modelu. Přehled repozitářů, jejich věcné oblasti a typu vystaveného rozhraní je uveden v Tab. 4.4, přičemž schéma datového toku z databázových entit přes repozitářovou vrstvu na doménové modely je znázorněno na Obr. 4.3. Vyšší vrstvy aplikace, zejména kontrolery a doménové služby, přistupují k datům výhradně prostřednictvím těchto repozitářů a nikoli přímo přes datové přístupové objekty.

**Tab. 4.4** Přehled repozitářů aplikace Foody — věcná oblast, typ uchovávaných dat a charakter vystaveného rozhraní

| Repozitář | Věcná oblast | Vystavené rozhraní |
|---|---|---|
| `DayRecordRepository` | Denní záznam s vnořenými jídly, ingrediencemi a cvičeními | Jednorázové dotazy a reaktivní stream agregátů |
| `WeightEntryRepository` | Záznamy hmotnosti | Jednorázové dotazy a reaktivní stream záznamů |
| `MealTemplateRepository` | Šablony jídel se skladbou ingrediencí | Reaktivní paměťová cache typu `RxList` |
| `IngredientTemplateRepository` | Šablony jednotlivých ingrediencí | Reaktivní paměťová cache typu `RxList` |
| `ExerciseTemplateRepository` | Šablony cvičebních aktivit | Reaktivní paměťová cache typu `RxList` |

[FIGURE PLACEHOLDER: Schéma repozitářové vrstvy aplikace Foody — pět repozitářů (DayRecordRepository, WeightEntryRepository, MealTemplateRepository, IngredientTemplateRepository, ExerciseTemplateRepository) zobrazených jako fasáda nad odpovídajícími DAO (DayRecordDao, MealDao, IngredientDao, ExerciseDao, WeightEntryDao, MealTemplateDao, MealTemplateIngredientDao, IngredientTemplateDao, ExerciseTemplateDao) s vyznačenou transformací entita → doménový model (DayRecord agregát s vnořenými Meal[], Ingredient[], Exercise[]) a směrem reaktivních proudů ke kontrolerům uživatelského rozhraní]

**Obr. 4.3** Schéma repozitářové vrstvy aplikace Foody — pět repozitářů jako fasáda nad DAO, transformace databázových entit na doménové agregáty a reaktivní propagace dat do prezentační vrstvy

Klíčovou odpovědností repozitáře pro denní záznamy je sestavení doménového modelu z rozdrobených databázových entit. Při načtení denního záznamu repozitář postupně dotazuje příslušné DAO a kombinuje výstupy: nejprve načte záznam denního přehledu, následně načte všechna jídla pro daný den, ke každému jídlu načte odpovídající ingredience a paralelně načte všechna cvičení daného dne. Výsledný doménový agregát tak obsahuje plně sestavenou hierarchii v podobě seznamu jídel s vnořeným seznamem ingrediencí u každého z nich a paralelního seznamu cvičení, což je struktura, kterou prezentační vrstva přímo využívá pro zobrazení denního přehledu. Tato transformace mezi normalizovaným úložištěm a denormalizovaným doménovým agregátem je centralizována v repozitáři, čímž je odstíněna od kontrolerů a komponent uživatelského rozhraní.

V návaznosti na obecný popis reaktivních streamů uvedený v sekci 4.2.2 zpřístupňuje repozitář pro denní záznamy aktuální stav dat prostřednictvím reaktivního proudu, jehož specifikem je transformace každé emise na sestavený doménový agregát. Při každé změně podřízené tabulky je vyvolána asynchronní transformační funkce, která pro každou položku znovu sestaví vnořenou hierarchii jídel, ingrediencí a cvičení tak, jak byla popsána v předchozím odstavci. Repozitář pro váhové záznamy zveřejňuje obdobný proud nad samostatnou tabulkou hmotnosti, který nevyžaduje vnoření a omezuje se na lineární mapování entit na doménové modely. Tato vlastnost umožňuje vyšším vrstvám aplikace registrovat se k odběru dat bez nutnosti manuálního dotazování po každé změně, což je v souladu s reaktivní povahou uživatelského rozhraní popsaného v sekci 4.3.2.

Z hlediska normalizace časových údajů sjednocuje repozitář pro denní záznamy reprezentaci kalendářních dnů prostřednictvím privátní funkce, která ze zadaného časového razítka odvozuje pouze datovou složku v lokálním časovém pásmu zařízení (tzv. půlnoc lokálního dne). Tato normalizace je aplikována při všech operacích vyhledávání, vkládání a aktualizace denního záznamu, čímž je zajištěno, že dvě různá časová razítka v rámci téhož kalendářního dne odkazují na stejný denní záznam. Bez této normalizace by mohlo dojít k vytvoření vícero denních záznamů pro tentýž den, pokud by aplikace pracovala s časovými razítky generovanými v různých okamžicích dne. Volba lokálního časového pásma odpovídá perspektivě uživatele, který sleduje stravování v rámci svého denního cyklu, nikoli v koordinovaném světovém čase.

Šablonové repozitáře implementují odlišný vzorec přístupu k datům, než repozitáře transakční. Vzhledem k relativně malému počtu šablon a četnosti jejich čtení v rámci uživatelských nabídek je v každém z trojice šablonových repozitářů udržována reaktivní paměťová cache realizovaná prostřednictvím kolekce typu `RxList` poskytované frameworkem GetX [39], do které jsou při inicializaci načteny všechny šablony z databáze. Po každé operaci vkládání, aktualizace nebo mazání je cache obnovena z databáze a aktuální stav je automaticky propagován prostřednictvím reaktivního mechanismu téhož frameworku. Komponenty uživatelského rozhraní se na tuto kolekci naváží a získávají tak přímý přístup k aktuálnímu seznamu šablon bez nutnosti vlastní synchronizace. Tento návrh je vhodný pro datové sady, jejichž velikost se pohybuje v řádu desítek až stovek položek a u nichž převažuje četnost čtení nad četností zápisu.

Celkově lze konstatovat, že repozitářová vrstva uzavírá datovou architekturu aplikace tím, že odděluje fyzické úložiště od doménového pohledu, centralizuje transformaci entit na agregáty a poskytuje vyšším vrstvám reaktivní rozhraní pro odběr aktuálních dat. Konkrétní způsob, jakým je tato datová vrstva využívána při integraci s AI modelem pro rozpoznávání jídel a cvičení, je popsán v následující sekci 4.5.

### 4.5 Integrace AI Modelu

[CONTENT TO BE FILLED: Scope paragraph. Uvést, že sekce detailně popisuje implementaci AI pipeline pro rozpoznávání jídel a cvičení, včetně struktury promptů, mechanismu práce s nejistotou, zabezpečení vstupu a podpory více poskytovatelů. Odkaz na FR-06, FR-07, FR-08, FR-10, FR-11.]

#### 4.5.1 Architektura AI Pipeline

[CONTENT TO BE FILLED: Popis toku dat v AI pipeline: vstup (fotografie + textový popis / samotný text) → PromptSanitizer (sanitizace, detekce injekce) → AiService (OpenAI nebo Gemini) → REST klient → strukturovaná JSON odpověď → parsování → confidence gate → AiAnalysisResult (success / lowConfidence / failure). Samostatný tok pro cvičení: textový popis → sanitizace → OpenAI → JSON → multi-level validace → AiExerciseAnalysisResult. Tok pro nutriční cíle: profil uživatele → Mifflin-St Jeor výpočet přes prompt.]

[FIGURE PLACEHOLDER: Sekvenční diagram AI pipeline — tok dat od vstupu uživatele přes sanitizaci, volání AI služby, parsování odpovědi a confidence gate až k zobrazení výsledku]

**Obr. 4.3** Sekvenční diagram AI pipeline pro rozpoznání jídla z fotografie — od vstupu po zobrazení výsledku s indikací nejistoty

#### 4.5.2 Struktura Promptů a Formát Odpovědí

[CONTENT TO BE FILLED: Popis struktury JSON promptu (prompt.dart): pole task (instrukce pro AI), expected_output (schéma JSON odpovědi), schema.rules (omezení: amount je COUNT nikoliv hmotnost, confidence 0–1). Injekce uživatelského kontextu: dietní typ (SessionManager.dietType), customDietPreferences, jazykové preference. Formát odpovědi pro jídlo: valid, answer (name, confidence, amount, nutritional_values, ingredients[]). Formát odpovědi pro cvičení: name, duration, caloriesPerMinute, confidence. XML wrapping uživatelského vstupu (<user_input>) pro oddělení dat od instrukcí.]

#### 4.5.3 Práce s Nejistotou a Confidence Gate

[CONTENT TO BE FILLED: Implementace FR-08. Confidence thresholds: jídlo ≥ 0,50, cvičení ≥ 0,50 (definované v AiPipelineService). Tříúrovňová indikace nejistoty v UI: zelená (≥ 75 %), žlutá (≥ 50 %), červená (< 50 %). Logika rozhodování: pokud confidence < threshold → lowConfidence status (data se zobrazí uživateli, ale s varováním). isSuccess flag: success i lowConfidence jsou považovány za použitelné (uživatel může potvrdit/opravit). Víceúrovňová validace cvičení: hard failure (valid=false + prázdný název + confidence < 0,50) vs. low confidence.]

#### 4.5.4 Zabezpečení Vstupu a Ochrana Proti Prompt Injection

[CONTENT TO BE FILLED: Implementace PromptSanitizer pipeline: trim whitespace → strip control characters (\x00-\x1F, \x7F) → odstranění literálních <user_input> tagů → truncation (descriptions 500 znaků, preferences 200 znaků, queries 500 znaků). Regex-based pre-screening (6 vzorů pro detekci injection pokusů). Volitelný LLM-based pre-screening (GPT-4o-mini pro detekci injekcí). Anti-injection direktiva v systémových promptech: instrukce pro AI model, aby obsah v <user_input> tazích zpracovával jako surová data. Důvody pro vícevrstvý přístup k zabezpečení.]

#### 4.5.5 Podpora Více AI Poskytovatelů

[CONTENT TO BE FILLED: Abstrakce AiService (abstraktní rozhraní). Dvě implementace: OpenAiService a GeminiService. AiServiceManager pro přepínání mezi poskytovateli (switchService). OpenAI jako výchozí poskytovatel. Gemini: využívá OpenAI-kompatibilní endpoint (generativelanguage.googleapis.com/v1beta/openai/). Architektonické rozhodnutí: provider-agnostic design umožňuje přidání dalších poskytovatelů bez změny pipeline. Omezení: cvičení a nutriční cíle jsou vázány přímo na OpenAI (nejsou přepínatelné). Model: GPT-4o pro analýzu jídel/cvičení, GPT-4o-mini pro detekci injekcí.]

### 4.6 Vstupní Modality pro Záznam Stravy

[CONTENT TO BE FILLED: Scope paragraph. Uvést, že aplikace implementuje šest různých vstupních modalit pro záznam jídla, od plně automatizovaného AI rozpoznávání z fotografie přes hlasový a textový vstup s AI analýzou, čtečku čárových kódů až po plně manuální zadání bez AI. Odkaz na FR-01, FR-06, FR-11, FR-12, FR-14, FR-16. Tato diverzita vstupů vychází z uživatelské studie (kap. 3.2), která identifikovala potřebu rychlého zápisu pro různé situace (restaurace, domácí vaření, balené potraviny, situace bez možnosti fotografovat).]

#### 4.6.1 Fotografický Vstup a Rozpoznání Jídla

[CONTENT TO BE FILLED: Implementace FR-06 a FR-12. Dva zdroje fotografie: kamera (ScanCameraScreen) a galerie (image_picker). ScanMode.scanMeal: fotografický vstup → volitelný textový popis → AI pipeline → ScanPreviewScreen s výsledkem. Scan onboarding (ScanOnboardingScreen): 5 stránek s tipy pro lepší rozpoznání (FR-09). Podpora crop a úpravy fotografie. Flow: pořízení/výběr → náhled → odeslání do AI → zobrazení výsledku → editace → uložení.]

#### 4.6.2 Hlasový Vstup

[CONTENT TO BE FILLED: Implementace FR-14 (voice variant). VoiceTranscriptionService: integrace speech_to_text s locale-aware přepínáním (čeština/angličtina). VoiceLogScreen: UI pro nahrávání hlasového popisu jídla. Tok: zahájení nahrávání → real-time transkripce → uživatel potvrdí text → text jako vstup do AI pipeline → rozpoznání a uložení. Podpora pro jídla i cvičení.]

#### 4.6.3 Textový Vstup s Podporou AI

[CONTENT TO BE FILLED: Implementace FR-14 (text variant) a FR-11 (fallback po selhání foto rozpoznání). Uživatel napíše volný textový popis jídla (např. „kuřecí prsa s rýží a brokolicí") → vstup do AI pipeline → strukturované rozpoznání ingrediencí a nutričních hodnot → ScanPreviewScreen s výsledkem → editace → uložení. Textový vstup slouží také jako fallback, pokud fotografické rozpoznání selže nebo vrátí nízkou confidence (FR-11). Přístup přes QuickActionSheet z hlavní obrazovky.]

#### 4.6.4 Manuální Zadání Bez AI

[CONTENT TO BE FILLED: Implementace FR-01. Plně manuální záznam jídla bez jakékoliv AI asistence. Uživatel ručně vyplní název jídla, přidá ingredience a zadá nutriční hodnoty (kalorie, bílkoviny, sacharidy, tuky) a gramáž nebo počet kusů. EditMealScreen a EditIngredientScreen jako hlavní obrazovky pro manuální vstup. SelectMealScreen: výběr z historie, šablon a oblíbených položek pro urychlení manuálního zápisu. Tento vstupní režim je klíčový pro situace, kdy uživatel přesně zná složení jídla (domácí vaření s váhou, balené potraviny s etiketou) nebo kdy AI rozpoznání není dostupné (offline režim). Propojení s FR-15 (podpora jednotek: 1 g, 100 g, vlastní jednotky, zobrazení zlomků).]

#### 4.6.5 Čtečka Čárových Kódů

[CONTENT TO BE FILLED: Implementace FR-16. mobile_scanner pro rozpoznávání čárových kódů (EAN-8, EAN-13, UPC-A, UPC-E, Code128). BarcodeLookupService → OpenFoodFactsClient: vyhledání produktu v databázi Open Food Facts. BarcodeScanController: koordinace skenování, vyhledávání a zobrazení výsledku. BarcodeLookupResult: nutriční hodnoty z databáze. 6 typů chyb pro barcode flow (FR-10). Omezení: závislost na kompletnosti databáze Open Food Facts, ne všechny produkty nalezeny.]

#### 4.6.6 Skenování Nutričních Etiket

[CONTENT TO BE FILLED: ScanMode.foodLabel: skenování nutričních tabulek na obalech potravin. Architektonický přístup: využití multimodálního AI modelu pro extrakci nutričních hodnot z fotografie etikety. Aktuální stav implementace a případná omezení.]

### 4.7 Implementace Klíčových Funkcí

[CONTENT TO BE FILLED: Scope paragraph. Uvést, že sekce popisuje implementaci hlavních funkčních celků aplikace nad rámec vstupních modalit popsaných v sekci 4.6. Každá podsekce odkazuje na příslušné funkční požadavky z kapitoly 3.2.]

#### 4.7.1 Denní Přehled a Správa Nutričních Cílů

[CONTENT TO BE FILLED: Implementace FR-02 a FR-03. DashboardScreen: přehled aktuálního dne (kalorický příjem vs. cíl, makroživiny, seznam jídel a cvičení). DashboardController a DayRecordController: správa stavu denního záznamu. NutritionGoalsService: nastavení a propagace cílů (kalorie, bílkoviny, sacharidy, tuky) prostřednictvím DayRecordRepository.upsertDayRecord(). Rollover calories systém: přenos nevyčerpaných kalorií do dalšího dne (max 500 kcal). CalendarDayRingService: vizualizace plnění cílů v kalendáři (CalendarDayRingPainter). Scrollable calendar na dashboard obrazovce.]

#### 4.7.2 Správa Jídel a Ingrediencí

[CONTENT TO BE FILLED: Implementace FR-01, FR-13, FR-15. EditMealScreen: editace rozpoznaného nebo manuálně vytvořeného jídla (název, ingredience, fotografie). IngredientDetailScreen a EditIngredientScreen: editace jednotlivých ingrediencí (gramáž, kusy, nutriční hodnoty). FR-15: podpora jednotek (1 g, 100 g, vlastní jednotky, zobrazení zlomků). FR-13: funkce „Fix with AI" v EditMealScreen → FixResultScreen (opakované rozpoznání z editační obrazovky). MealCopyToSheet: duplikace záznamu s výběrem data (FR-18). MealDatePickerSheet pro výběr cílového data.]

#### 4.7.3 Sledování Cvičení

[CONTENT TO BE FILLED: Implementace FR-22 (částečně FR-23). ExerciseLogHomeScreen: přehled typů zadání cvičení (AI, voice, manuální, šablony). AddExerciseScreen: manuální přidání cvičení. AI rozpoznávání cvičení: textový/hlasový popis → AiPipelineService.analyzeExercise(). ExerciseTemplate systém: uložení a opakované použití cvičení. ExerciseDetailScreen a ExerciseDetailOptionsSheet: detail a editace záznamu. Vizualizace výdeje energie na dashboard (FR-22: příjem vs. výdej v jednom pohledu).]

#### 4.7.4 Sledování Hmotnosti

[CONTENT TO BE FILLED: WeightLogSheet: záznam hmotnosti s volitelnou fotografií. WeightHistoryScreen a WeightHistoryEditEntryScreen: historie a editace záznamů. WeightEntryRepository: perzistence a reaktivní aktualizace. BmiCard: výpočet a zobrazení BMI na základě aktuální hmotnosti a výšky z profilu. WeightProgressCard: vizualizace trendu hmotnosti. Propojení s onboarding flow (cílová hmotnost, rychlost hubnutí).]

#### 4.7.5 Oblíbené Položky, Šablony a Historie

[CONTENT TO BE FILLED: Implementace FR-17, FR-18, FR-19. isFavorite příznak na entitách Meal, Ingredient, Exercise: uživatel může označit položku jako oblíbenou. SelectMealScreen s kartou Favorites: rychlý přístup k oblíbeným jídlům a ingrediencím. Systém šablon (viz 4.4.2): MealTemplate, IngredientTemplate, ExerciseTemplate s automatickou tvorbou a vyhledáváním podle normalizovaného názvu. FR-18: MealCopyToSheet s výběrem data pro duplikaci. FR-19: vyhledávání s debounce v SelectMealScreen (fulltextové hledání v historii a šablonách). Řazení podle frekvence použití (usageCount).]

#### 4.7.6 Dietní Omezení a Vizualizace Porušení

[CONTENT TO BE FILLED: Implementace FR-20 a FR-21. SessionManager.dietType a customDietPreferences: uživatelská konfigurace diet (vegetariánská, veganská, bezlepková, vlastní). PersonalDetailsDietScreen a PersonalDetailsCustomDietScreen: nastavení dietních preferencí. Injekce dietního kontextu do AI promptů přes _buildMealUserAttributes(): AI zohledňuje dietní omezení při analýze. DietaryViolationService: detekce porušení dietních omezení v záznamech. DietaryViolationsCalendarCard: měsíční kalendářní mřížka s vizualizací dnů s porušením (FR-21).]

#### 4.7.7 Dotazy v Přirozeném Jazyce

[CONTENT TO BE FILLED: Implementace FR-27. AskAiController a AskAiScreen: rozhraní pro dotazy nad nutričními daty. Two-pass systém: 1. pass — AI určí relevantní časový rozsah z dotazu uživatele, 2. pass — AI analyzuje data za určené období a generuje odpověď. Typy dotazů: trendy, srovnání, doporučení, analýza vzorců stravování. Integrace s historickými daty z DayRecordRepository.]

#### 4.7.8 Notifikace a Motivační Souhrny

[CONTENT TO BE FILLED: Implementace FR-28 a FR-29. TrackingReminderService: plánování lokálních notifikací pomocí flutter_local_notifications s timezone-aware zonedSchedule(). 5 typů připomínek: snídaně, oběd, svačina, večeře, konec dne. Perzistence nastavení přes SharedPreferences. TrackingRemindersController: UI pro konfiguraci (FR-29). MotivationalSummaryService: generování motivačních souhrnů (denní, týdenní, měsíční) s využitím AI. MotivationalSummaryController a MotivationalSummaryScreen: zobrazení a správa souhrnů.]

#### 4.7.9 Export Dat a Sdílení

[CONTENT TO BE FILLED: Implementace FR-25. ExportService a ExportController: generování exportů. CSV export: tabulkový formát nutričních dat za zvolené období. PDF export: formátovaný report s grafy (ExportPdfIntroScreen, ExportPdfDateRangeScreen pro výběr období). MealShareBuilder a AppShareService: sdílení jednotlivých jídel (screenshot, textový formát). FR-25: uživatel může exportovat data ve formátu CSV nebo PDF.]

#### 4.7.10 Integrace se Zdravotními Platformami

[CONTENT TO BE FILLED: Částečná implementace FR-23. HealthIntegrationService: synchronizace dat s Apple Health (iOS) a Health Connect (Android). HealthIntegrationController a HealthIntegrationScreen: konfigurace integrace. Exercise.source: rozlišení manuálně zadaných cvičení a importovaných ze zdravotních platforem. Přepínače burnedCaloriesEnabled a rolloverCaloriesEnabled v nastavení profilu. Omezení: bez granulárních multiplikátorů pro různé typy aktivit.]

#### 4.7.11 Lokalizace, Onboarding a Profil Uživatele

[CONTENT TO BE FILLED: Implementace FR-04, FR-09 (částečně FR-30). easy_localization: podpora jazyků en a cs, generované klíče v locale_keys.g.dart, překlady v assets/translations/. Onboarding flow: 12+ obrazovek (OnboardingFlowScreen → welcome → DOB → height/weight → gender → goal → desired weight → weight loss speed → calorie burn → workouts → rollover → save progress → loading plan → plan ready). FR-04: PersonalDetailsScreen pro správu profilu (hmotnost, výška, datum narození, pohlaví, metrické preference). SessionManager → SharedPreferencesService: perzistence profilových dat. FR-09: ScanOnboardingScreen (5 stránek s tipy pro AI rozpoznávání). FR-30: individuální přepínače pro pokročilé funkce (burnedCalories, rollover, autoAdjust).]

#### 4.7.12 Další Implementované Funkce

[CONTENT TO BE FILLED: Doplňkové funkce nad rámec původních FR. StreakService a StreakController: sledování série po sobě jdoucích dnů se záznamy (aktuální a nejdelší streak, týdenní aktivita, StreakDialog). Home widget (WidgetSyncService, WidgetActionRouter, WidgetConstants): widget na domovskou obrazovku s přehledem denního příjmu. CalendarDayRingService a CalendarDayRingPainter: barevné kroužky v kalendáři vizualizující plnění kalorických a makro cílů. ReportMealScreen: funkce pro nahlášení nesprávně rozpoznaného jídla (zpětná vazba pro zlepšení AI). Auto-adjust makroživin: proporcionální přepočet makroživin při změně kalorického cíle. FR-05: mazání jednotlivých jídel a cvičení (částečně implementováno, bez mazání účtu). FR-26: offline tolerance (SQLite local-first, AI vyžaduje připojení).]

### 4.8 Klíčové Obrazovky Aplikace

[CONTENT TO BE FILLED: Scope paragraph. Uvést, že sekce představuje vybrané obrazovky aplikace, které ilustrují klíčové interakční toky definované případy užití z kapitoly 3.2. Každá obrazovka je doprovozena snímkem a stručným popisem funkčnosti. Celkem 8–10 snímků (Obr. 4.4 až 4.13).]

[FIGURE PLACEHOLDER: Snímek hlavní obrazovky (Dashboard) — denní přehled kalorií, makroživin, seznam jídel a cvičení, kalendář]

**Obr. 4.4** Hlavní obrazovka aplikace (Dashboard) — denní přehled kalorického příjmu, makroživin a seznamu zaznamenaných jídel

[FIGURE PLACEHOLDER: Snímek obrazovky skenování — kamera s možností pořízení fotografie jídla a výběru režimu skenování]

**Obr. 4.5** Obrazovka skenování (ScanCameraScreen) — pořízení fotografie jídla pro AI rozpoznání

[FIGURE PLACEHOLDER: Snímek náhledu výsledku rozpoznání — rozpoznané jídlo s indikací confidence, ingredience a nutriční hodnoty]

**Obr. 4.6** Náhled výsledku AI rozpoznání (ScanPreviewScreen) — rozpoznané jídlo s barevnou indikací nejistoty a možností editace

[FIGURE PLACEHOLDER: Snímek editace jídla — formulář pro úpravu názvu, ingrediencí, gramáže a nutričních hodnot]

**Obr. 4.7** Editace záznamu jídla (EditMealScreen) — úprava ingrediencí, gramáže a nutričních hodnot s možností opakovaného AI rozpoznání

[FIGURE PLACEHOLDER: Snímek výběru jídla z historie — vyhledávání, oblíbené, šablony, nedávné položky]

**Obr. 4.8** Výběr jídla z historie a šablon (SelectMealScreen) — fulltextové vyhledávání, záložka oblíbených a řazení podle frekvence

[FIGURE PLACEHOLDER: Snímek hlasového vstupu — mikrofon, real-time transkripce, potvrzení textu]

**Obr. 4.9** Hlasový vstup pro záznam jídla (VoiceLogScreen) — real-time transkripce hlasového popisu s možností korekce

[FIGURE PLACEHOLDER: Snímek sledování cvičení — typy zadání (AI, hlas, manuální, šablony)]

**Obr. 4.10** Přehled zadání cvičení (ExerciseLogHomeScreen) — výběr vstupní modality pro záznam fyzické aktivity

[FIGURE PLACEHOLDER: Snímek profilu a nastavení — osobní údaje, cíle, dietní preference, notifikace]

**Obr. 4.11** Obrazovka profilu (ProfileScreen) — správa osobních údajů, nutričních cílů a nastavení aplikace

[FIGURE PLACEHOLDER: Snímek Ask AI — dotaz v přirozeném jazyce nad nutričními daty, odpověď AI]

**Obr. 4.12** Dotazy v přirozeném jazyce (AskAiScreen) — uživatelský dotaz a odpověď AI analýzy nad historickými nutričními daty

[FIGURE PLACEHOLDER: Snímek týdenního/měsíčního přehledu — grafy, trendy, statistiky]

**Obr. 4.13** Přehled pokroku (ProgressScreen) — týdenní a měsíční vizualizace kalorického příjmu, hmotnosti a plnění cílů

### 4.9 Přehled Implementovaných Funkčních Požadavků

[CONTENT TO BE FILLED: Scope paragraph. Uvést, že tabulka shrnuje stav implementace všech funkčních požadavků definovaných v kapitole 3.2 (FR-01 až FR-30). Každý požadavek je klasifikován jako Implementováno, Částečně implementováno, nebo Neimplementováno s krátkým zdůvodněním.]

**Tab. 4.4** Přehled stavu implementace funkčních požadavků FR-01 až FR-30 — klasifikace stavu a stručné zdůvodnění

| FR | Název | Stav | Poznámka |
|----|-------|------|----------|
| FR-01 | Ruční přidání záznamu jídla bez AI | Implementováno | EditMealScreen, manuální vstup ingrediencí |
| FR-02 | Denní přehled kalorií a makroživin | Implementováno | DashboardScreen, DayRecordController |
| FR-03 | Nastavení cílových hodnot | Implementováno | NutritionGoalsService, EditNutritionGoalsScreen |
| FR-04 | Správa profilu uživatele | Implementováno | PersonalDetailsScreen, SessionManager |
| FR-05 | Kontrola nad daty a mazání | Částečně implementováno | Mazání jídel/cvičení funkční, mazání účtu chybí |
| FR-06 | Fotografie jako vstup pro rozpoznání | Implementováno | ScanCameraScreen, AI pipeline |
| FR-07 | AI návrh položek a porcí | Implementováno | AiPipelineService, strukturovaný JSON prompt |
| FR-08 | Indikace nejistoty výstupu | Implementováno | Barevný badge (zelená ≥ 75 %, žlutá ≥ 50 %, červená < 50 %) |
| FR-09 | Vysvětlení limitů AI | Implementováno | ScanOnboardingScreen (5 stránek s tipy) |
| FR-10 | Rozlišení limitu AI a technické chyby | Částečně implementováno | Barcode: 6 typů chyb, AI pipeline: generické selhání |
| FR-11 | Textový fallback po selhání rozpoznání | Implementováno | Textový popis → AI pipeline |
| FR-12 | Import fotografie z galerie | Implementováno | image_picker integrace |
| FR-13 | Opakování rozpoznání z editace | Implementováno | „Fix with AI" → FixResultScreen |
| FR-14 | Záznam bez fotografie (hlas, text) | Implementováno | VoiceLogScreen, textový popis, manuální vstup |
| FR-15 | Jednotky množství (gramy, kusy) | Implementováno | 1 g, 100 g, vlastní jednotky, zlomky |
| FR-16 | Čtečka čárových kódů | Implementováno | mobile_scanner, OpenFoodFactsClient |
| FR-17 | Oblíbené položky | Implementováno | isFavorite na jídlech/ingrediencích/cvičeních |
| FR-18 | Duplikace předchozího záznamu | Implementováno | MealCopyToSheet s výběrem data |
| FR-19 | Našeptávání podle historie | Částečně implementováno | Fulltextové vyhledávání s debounce, bez klasického dropdown |
| FR-20 | Dietní omezení a intolerance | Implementováno | SessionManager.dietType, customDietPreferences |
| FR-21 | Porušení dietních omezení v kalendáři | Implementováno | DietaryViolationsCalendarCard |
| FR-22 | Příjem vs. výdej v jednom pohledu | Implementováno | Dashboard: kalorický příjem a spálené kalorie |
| FR-23 | Nastavení integrace výdeje | Částečně implementováno | Přepínače burnedCalories/rollover, bez granulárních multiplikátorů |
| FR-24 | Týdenní a měsíční přehledy | Implementováno | ProgressScreen, WeeklyEnergyCard |
| FR-25 | Export dat (CSV/PDF) | Implementováno | ExportService, výběr období |
| FR-26 | Offline tolerance | Implementováno | SQLite local-first, AI vyžaduje připojení |
| FR-27 | Dotazy v přirozeném jazyce | Implementováno | AskAiScreen, two-pass systém |
| FR-28 | Měsíční motivační souhrn | Implementováno | MotivationalSummaryService (denní/týdenní/měsíční) |
| FR-29 | Nastavitelné notifikace | Implementováno | TrackingReminderService, 5 typů připomínek |
| FR-30 | Skrytí/zobrazení pokročilých funkcí | Částečně implementováno | Individuální přepínače, bez režimu basic/advanced |

### 4.10 Omezení Implementace

[CONTENT TO BE FILLED: Scope paragraph. Uvést, že každá implementace má svá omezení a tato sekce transparentně identifikuje oblasti, kde aktuální verze aplikace nedosahuje plného potenciálu návrhu nebo kde existují známá technická omezení. Strukturovat do tematických odstavců:]

[CONTENT TO BE FILLED: Odstavce pokrývající následující omezení:

1. **Omezení AI rozpoznávání**: přesnost klesá u složených/kombinovaných jídel a u regionálních pokrmů; rozpoznávání závisí na kvalitě fotografie; latence API volání (NFR-02); energetický odhad je aproximace, ne přesné měření.

2. **Závislost na externích službách**: OpenAI API vyžaduje internetové připojení (omezení offline režimu pro AI funkce); Open Food Facts databáze neobsahuje všechny produkty (zejména lokální české značky); náklady na API volání.

3. **Neimplementované nebo částečně implementované požadavky**: FR-05 bez mazání účtu; FR-10 bez granulárního rozlišení typů AI chyb; FR-19 bez klasického autocomplete dropdown; FR-23 bez granulárních multiplikátorů; FR-30 bez explicitního režimu basic/advanced.

4. **Technická omezení**: foodLabel scan mode není plně implementován; cvičení a nutriční cíle jsou vázány na OpenAI (nepřepínatelné na Gemini); absence automatického fallbacku mezi AI poskytovateli; absence cloudové synchronizace a zálohování dat (local-only).

5. **Omezení uživatelského testování**: aplikace nebyla testována na velkém vzorku uživatelů v produkčním prostředí; dlouhodobá retence a udržitelnost používání nebyla ověřena.

Každý bod formulovat jako konkrétní omezení s vysvětlením dopadu. Kapitolu uzavřít forward bridge na kapitolu 5 (Testování).]

## TESTOVÁNÍ

Tato kapitola popisuje průběh a výsledky uživatelského testování aplikace Foody. Cílem testování bylo ověřit použitelnost implementované aplikace na reálných uživatelích a identifikovat případné problémy v uživatelském rozhraní a interakčních tocích. V první části kapitoly je popsána zvolená metodika, výběr participantů, sada testovacích úloh a použité dotazníky. Následně jsou prezentovány výsledky plnění jednotlivých úloh, výstupy standardizovaných dotazníků a identifikované problémy s doporučeními pro další iteraci vývoje.

### 5.1 Metodika Testování

V rámci testování aplikace Foody byla zvolena kombinace metody *think aloud* a úlohového testování (*task-based usability testing*). Tato kombinace umožňuje získat jak kvantitativní data o úspěšnosti a rychlosti plnění úloh, tak kvalitativní poznatky o kognitivních procesech participantů při interakci s aplikací. Následující podkapitoly popisují výběr participantů, prostředí testování, sadu testovacích úloh a použité dotazníky a metriky.

#### 5.1.1 Výběr a Charakteristika Participantů

Pro uživatelské testování byli vybráni celkem čtyři participanti, kteří představují různé uživatelské profily z hlediska zkušeností se sledováním stravy a technologické zdatnosti. Tento počet je v souladu s doporučeními Nielsena, podle kterých pět participantů odhalí přibližně 80 % problémů použitelnosti, přičemž již čtyři participanti pokrývají většinu kritických nedostatků [CITATION NEEDED]. Participanti byli vybráni s ohledem na variabilitu věku, pohlaví a předchozích zkušeností s aplikacemi pro sledování kalorického příjmu, čímž bylo zajištěno pokrytí rozdílných uživatelských perspektiv.

[CONTENT TO BE FILLED: Profily participantů ve formátu P1–P4, každý 2–4 věty. (Jedná se o stejné participanty jako v uživatelské studii) Uvést primární cíl, zkušenosti s calorie tracking aplikacemi, technologickou zdatnost. Příklad formátu:

„P1 (žena, 28 let) se aktivně věnuje fitness a sledování stravy. Dříve používala aplikaci MyFitnessPal po dobu šesti měsíců, kterou opustila kvůli časové náročnosti manuálního zápisu. Od testované aplikace očekává rychlejší záznam díky AI rozpoznávání."

„P2 (muž, 35 let) nemá předchozí zkušenosti se sledováním kalorického příjmu. O aplikaci projevil zájem z důvodu doporučení lékaře ke snížení hmotnosti. Jako méně technicky zdatný uživatel představuje perspektivu začátečníka."]

#### 5.1.2 Prostředí a Průběh Testovací Relace

Testování probíhalo formou individuálních relací v kontrolovaném prostředí, kdy každý participant pracoval s aplikací na reálném mobilním zařízení. V průběhu testování byla použita metoda souběžného *think aloud* protokolu, při které participanti verbalizovali své myšlenky, dojmy a pochybnosti během plnění úloh [CITATION NEEDED]. Na začátku každé relace byl participant seznámen s účelem testování, podepsal informovaný souhlas a obdržel instrukce k verbalizaci myšlenek.

Každá testovací relace měla odhadovanou délku 75 až 90 minut a sestávala ze čtyř fází, jejichž přehled je uveden v Tab. 5.1. V úvodní fázi (přibližně 5 minut) byl participant seznámen s průběhem testu a instrukcemi k metodě *think aloud*. Hlavní fáze testování (60 až 70 minut) zahrnovala plnění třinácti testovacích úloh, přičemž po dokončení každé úlohy participant vyplnil dotazník SEQ. Třetí fáze (přibližně 10 minut) byla věnována vyplnění standardizovaných dotazníků SUS a UEQ-S hodnotících celkovou zkušenost s aplikací. Závěrečná fáze (5 až 10 minut) sestávala z polo-strukturovaného debriefingu s šesti otevřenými otázkami zaměřenými na celkový dojem, pozitivní a negativní aspekty aplikace, srovnání s konkurenčními řešeními a ochotu k pravidelnému používání.

**Tab. 5.1** Struktura testovací relace

| Fáze | Délka | Obsah |
|------|-------|-------|
| Úvod | 5 min | Představení, souhlas, instrukce k *think aloud* |
| Testovací úlohy | 60–70 min | Plnění úloh T1–T13 s SEQ po každé úloze |
| Dotazníky | 10 min | SUS + UEQ-S |
| Debriefing | 5–10 min | Otevřené otázky, celkový dojem |

Na základě přípravy testovacího prostředí byla na zařízení nainstalována čistá verze aplikace bez předchozích dat, čímž byl simulován stav prvního spuštění. Do galerie zařízení byly nahrány připravené fotografie jídel pro úlohu T3, na stůl bylo připraveno reálné jídlo pro úlohu T2 a balený produkt s čárovým kódem pro úlohu T6. Průběh testování byl zaznamenáván formou záznamu obrazovky a zvukového záznamu pro následnou analýzu verbalizací.

#### 5.1.3 Testovací Úlohy

Testovací úlohy byly navrženy tak, aby pokrývaly klíčové funkční požadavky a případy užití definované v kapitole 3 (viz kap. 3.2). Úlohy jsou seřazeny v pořadí, které simuluje přirozený průchod aplikací od prvního spuštění přes různé způsoby záznamu jídla až po přehledy a export dat. Celkem bylo definováno třináct testovacích úloh, jejichž přehled včetně vazby na funkční požadavky a případy užití je uveden v Tab. 5.2.

**Tab. 5.2** Přehled testovacích úloh s vazbou na funkční požadavky a případy užití

| Úloha | Název | Pokryté FR / UC |
|-------|-------|-----------------|
| T1 | Onboarding a nastavení profilu | FR-03, FR-04, FR-20, UC06 |
| T2 | Záznam jídla z fotografie | FR-06, FR-07, FR-08, FR-09, UC01 |
| T3 | Import fotografie z galerie | FR-12 |
| T4 | Oprava výsledku AI a re-analýza | FR-11, FR-13, UC02 |
| T5 | Záznam jídla hlasem | FR-14 |
| T6 | Skenování čárového kódu | FR-16, UC04 |
| T7 | Ruční přidání záznamu | FR-01, FR-15, UC03 |
| T8 | Oblíbené a duplikace jídla | FR-17, FR-18, UC05 |
| T9 | Záznam cvičení hlasem | — |
| T10 | Zaznamenání váhy | — |
| T11 | Denní přehled a smazání záznamu | FR-02, FR-05, FR-22 |
| T12 | Týdenní přehled a Ask AI | FR-24, FR-27, UC07 |
| T13 | Export dat | FR-25 |

Úloha T1 zahrnovala kompletní onboarding flow aplikace, v rámci kterého participant zadal základní údaje (váha, výška, věk), nastavil kalorický cíl a zvolil případné dietní preference. Úlohy T2 až T6 pokrývaly jednotlivé vstupní modality pro záznam jídla, konkrétně fotografii z kamery (T2), import z galerie (T3), opravu a re-analýzu AI výsledku (T4), hlasový vstup (T5) a skenování čárového kódu (T6). Úloha T7 testovala ruční přidání záznamu bez využití AI, zatímco úloha T8 ověřovala práci s oblíbenými položkami a funkcí kopírování jídla na jiný den.

V rámci úloh T9 a T10 bylo testováno rozšíření aplikace nad rámec původní specifikace, konkrétně záznam cvičení hlasovým vstupem a zaznamenání tělesné váhy. Úlohy T11 až T13 se zaměřovaly na přehledové a analytické funkce aplikace, včetně denního přehledu se smazáním záznamu (T11), týdenního přehledu s funkcí Ask AI pro dotazy v přirozeném jazyce (T12) a exportu dat (T13).

Z celkového počtu třiceti funkčních požadavků definovaných v kapitole 3 je testovacími úlohami přímo pokryto dvacet dva požadavků, což představuje 73 % specifikace. Všech sedm případů užití (UC01 až UC07) je pokryto alespoň jednou úlohou. Zbývajících osm funkčních požadavků nebylo zahrnuto do testování z důvodů, které jsou shrnuty v Tab. 5.3.

**Tab. 5.3** Funkční požadavky nepokryté testovacími úlohami s uvedením důvodu

| FR | Název | Důvod vynechání |
|----|-------|-----------------|
| FR-10 | Rozlišení chyb AI a aplikace | Nelze spolehlivě vyvolat v kontrolovaném prostředí |
| FR-19 | Našeptávání názvů | Implicitně pokryto vyhledáváním v úlohách T7 a T8 |
| FR-21 | Porušení diet v kalendáři | Vyžaduje historická data s porušeními, obtížné simulovat |
| FR-23 | Nastavení integrace výdeje | Pouze přepínač v nastavení, nízká interakční hodnota |
| FR-26 | Offline tolerance | Vyžaduje odpojení od sítě během testu |
| FR-28 | Motivační souhrn | Vyžaduje dlouhodobý cyklus (denní, týdenní, měsíční) |
| FR-29 | Konfigurovatelné notifikace | Efekt vyžaduje časový odstup |
| FR-30 | Zobrazení/skrytí pokročilých funkcí | Pouze přepínače v nastavení, nízká interakční hodnota |

Během plnění vybraných úloh bylo současně pozorováním ověřováno plnění nefunkčních požadavků. V rámci úlohy T2 byla měřena latence AI rozpoznávání (NFR-02, limit 20 s) časem od odeslání fotografie do zobrazení výsledku. Počet kroků potřebných pro zápis jídla (NFR-03, limit 6 kroků) byl zaznamenáván při úlohách T2, T5, T6 a T7. Čas zápisu (NFR-04) byl měřen pro nový záznam v úloze T2 (limit 5 minut) a pro opakovaný záznam v úloze T8 (limit 1 minuta).

#### 5.1.4 Použité Dotazníky a Metriky

Pro kvantitativní hodnocení použitelnosti a uživatelské zkušenosti byly v rámci testování použity tři standardizované dotazníky. Výběr nástrojů pokrývá hodnocení na úrovni jednotlivých úloh (SEQ), celkovou použitelnost systému (SUS) a uživatelskou zkušenost v pragmatické i hedonické dimenzi (UEQ-S). Společné použití těchto tří dotazníků umožňuje triangulaci výsledků a poskytuje komplexní pohled na kvalitu interakce uživatele s aplikací.

Bezprostředně po dokončení každé testovací úlohy participant vyplnil dotazník *Single Ease Question* (SEQ), který sestává z jediné otázky hodnotící subjektivní obtížnost úlohy na sedmibodové škále, kde 1 znamená „velmi obtížná" a 7 „velmi snadná" [CITATION NEEDED]. Výhodou SEQ je minimální zatížení participanta a možnost okamžitého zachycení dojmu z právě dokončené úlohy, aniž by byl narušen průběh testování. Na základě dostupných benchmarků je za dobré hodnocení považován průměr SEQ skóre 5,5 a vyšší.

Po dokončení všech testovacích úloh participant vyplnil dotazník *System Usability Scale* (SUS), který představuje standardizovaný nástroj pro hodnocení celkové použitelnosti systému [CITATION NEEDED]. Dotazník SUS sestává z deseti položek hodnocených na pětibodové Likertově škále (1 = rozhodně nesouhlasím, 5 = rozhodně souhlasím), přičemž liché položky jsou formulovány pozitivně a sudé negativně. Výsledné skóre se pohybuje v rozsahu 0 až 100 bodů a vypočítá se podle vzorce (5.1). V kontextu dostupných benchmarků odpovídá průměrné SUS skóre napříč studiemi přibližně 68 bodům, přičemž skóre nad 80,3 bodu řadí systém mezi horních 10 % hodnocených aplikací [CITATION NEEDED].

$$SUS = \left((S_L - 5) + (25 - S_S)\right) \times 2{,}5 \quad (5.1)$$

$S_L$ − součet odpovědí na lichých položkách (1, 3, 5, 7, 9) [–]
$S_S$ − součet odpovědí na sudých položkách (2, 4, 6, 8, 10) [–]

Jako doplňkový nástroj pro hodnocení uživatelské zkušenosti byl použit dotazník *User Experience Questionnaire Short* (UEQ-S), který měří pragmatickou a hedonickou kvalitu systému prostřednictvím osmi položek [CITATION NEEDED]. Každá položka má formu sémantického diferenciálu na sedmibodové škále (−3 až +3), přičemž záporný pól je vždy umístěn na levé straně. Položky 1 až 4 (bránící/podporující, složitý/jednoduchý, neefektivní/efektivní, matoucí/jasný) měří pragmatickou kvalitu a položky 5 až 8 (nudný/vzrušující, nezajímavý/zajímavý, obvyklý/vynalézavý, tradiční/moderní) měří hedonickou kvalitu. Pragmatická kvalita se vypočítá jako průměr položek 1 až 4, hedonická kvalita jako průměr položek 5 až 8 a celkové skóre jako průměr všech osmi položek. Byla použita oficiální česká verze dotazníku validovaná a dostupná na stránkách projektu UEQ.

### 5.2 Výsledky Testování

Následující podkapitoly prezentují výsledky uživatelského testování v členění na kvantitativní údaje o plnění jednotlivých úloh, hodnocení SEQ a výstupy standardizovaných dotazníků SUS a UEQ-S. Výsledky jsou doplněny o kvalitativní poznatky získané analýzou verbalizací participantů v průběhu metody *think aloud* a z odpovědí debriefingových rozhovorů.

#### 5.2.1 Plnění Úloh a Hodnocení SEQ

[CONTENT TO BE FILLED: Pro každou úlohu T1–T13 uvést v průvodním textu:
— Míra dokončení (kolik ze 4 participantů úlohu úspěšně dokončilo)
— Průměrný čas plnění úlohy
— Počet kritických chyb (participant nedokázal pokračovat bez pomoci moderátora)
— Průměrné SEQ skóre
— Reprezentativní pozorování z *think aloud* (parafráze, nikoliv přímé citáty)

Vzor odstavce pro jednu úlohu:

„V rámci úlohy T2 (záznam jídla z fotografie) všichni čtyři participanti úspěšně dokončili zadaný úkol s průměrným časem X sekund. Průměrné SEQ skóre činilo X,X bodu. P1 a P3 intuitivně nalezli ikonu fotoaparátu na hlavní obrazovce, zatímco P2 nejprve hledal funkci v menu profilu. Dva participanti si všimli indikátoru spolehlivosti AI výsledku (confidence badge), zbývající dva jej přehlédli. Z hlediska NFR-02 byla průměrná latence AI rozpoznávání X sekund, což splňuje/nesplňuje stanovený limit 20 sekund."

Doporučený rozsah: 1–2 odstavce na úlohu; úlohy s výrazným nálezem rozepsat podrobněji (T2, T4, T5, T8), úlohy bez problémů lze sloučit do souhrnného odstavce.]

**Tab. 5.4** Výsledky plnění testovacích úloh a hodnocení SEQ

[CONTENT TO BE FILLED: Tabulka s daty z testování]

| Úloha | Dokončení (n/4) | Ø čas (s) | Kritické chyby | Ø SEQ (1–7) |
|-------|-----------------|-----------|----------------|-------------|
| T1 | | | | |
| T2 | | | | |
| T3 | | | | |
| T4 | | | | |
| T5 | | | | |
| T6 | | | | |
| T7 | | | | |
| T8 | | | | |
| T9 | | | | |
| T10 | | | | |
| T11 | | | | |
| T12 | | | | |
| T13 | | | | |

[CONTENT TO BE FILLED: Souhrnná interpretace výsledků z Tab. 5.4. Uvést:
— Které úlohy měly nejvyšší a nejnižší SEQ skóre
— Kde se vyskytly kritické chyby a co je způsobilo
— Celkový průměr SEQ napříč všemi úlohami a srovnání s benchmarkem 5,5
— Výsledky ověření NFR-02 (latence AI), NFR-03 (počet kroků) a NFR-04 (čas zápisu)
— Odstavec uzavřít shrnutím, které interakční toky fungují dobře a které vyžadují pozornost.]

#### 5.2.2 Výsledky System Usability Scale

[CONTENT TO BE FILLED: Interpretace SUS výsledků. Vzor:

„Průměrné SUS skóre aplikace Foody činilo X,X bodu (SD = X,X), což ji řadí do kategorie X podle adjektivní stupnice Bangor a kol. Výsledky jednotlivých participantů jsou uvedeny v Tab. 5.5. Nejvyšší hodnocení získala položka č. X (průměr X,X), která se týká Y. Naopak nejnižší hodnocení obdržela položka č. X (průměr X,X), což naznačuje, že participanti vnímali Z jako problematický aspekt. Celkově lze konstatovat, že dosažené skóre X,X odpovídá hodnocení ‚X' a řadí aplikaci nad/pod průměr SUS benchmarku 68 bodů."]

**Tab. 5.5** Výsledky dotazníku SUS pro jednotlivé participanty

[CONTENT TO BE FILLED]

| Participant | SUS skóre |
|-------------|-----------|
| P1 | |
| P2 | |
| P3 | |
| P4 | |
| **Průměr** | |
| **SD** | |

#### 5.2.3 Výsledky User Experience Questionnaire Short

[CONTENT TO BE FILLED: Interpretace UEQ-S výsledků. Vzor:

„Pragmatická kvalita aplikace dosáhla průměrného skóre X,X, což podle benchmarků UEQ odpovídá hodnocení ‚X'. Hedonická kvalita dosáhla skóre X,X, což odpovídá hodnocení ‚X'. Z jednotlivých položek získalo nejvyšší hodnocení sémantické páry X/X (průměr X,X), zatímco nejnižší hodnocení obdržely páry X/X (průměr X,X). Výsledky naznačují, že participanti vnímají aplikaci jako pragmaticky X, avšak v hedonické dimenzi existuje prostor pro zlepšení v oblasti Y."]

**Tab. 5.6** Výsledky dotazníku UEQ-S

[CONTENT TO BE FILLED]

| # | Položka | Průměr |
|---|---------|--------|
| 1 | bránící / podporující | |
| 2 | složitý / jednoduchý | |
| 3 | neefektivní / efektivní | |
| 4 | matoucí / jasný | |
| 5 | nudný / vzrušující | |
| 6 | nezajímavý / zajímavý | |
| 7 | obvyklý / vynalézavý | |
| 8 | tradiční / moderní | |
| — | **Pragmatická kvalita** | |
| — | **Hedonická kvalita** | |
| — | **Celkové skóre** | |

### 5.3 Identifikované Problémy

Na základě analýzy pozorování z metody *think aloud*, výsledků dotazníků a debriefingových rozhovorů bylo identifikováno celkem N problémů použitelnosti. Každý problém je klasifikován podle závažnosti na jedné ze tří úrovní: kritický (participant nebyl schopen úlohu dokončit bez pomoci moderátora), závažný (participant úlohu dokončil, ale s výrazným zdržením nebo zmateností) a kosmetický (participant si všiml nedostatku, avšak ten neovlivnil plnění úlohy). Přehled identifikovaných problémů je uveden v Tab. 5.7.

**Tab. 5.7** Identifikované problémy použitelnosti s klasifikací závažnosti

[CONTENT TO BE FILLED: Tabulka identifikovaných problémů. Pro každý problém uvést:
— Číslo problému (P1, P2, …)
— Název problému (stručný popis)
— Závažnost (Kritický / Závažný / Kosmetický)
— Dotčená úloha (T1–T13)
— Dotčený FR/NFR (pokud existuje vazba)

Za tabulkou následuje průvodní text, kde je každý problém popsán 2–3 větami. Vzor:

| # | Problém | Závažnost | Úloha | FR/NFR |
|---|---------|-----------|-------|--------|
| P1 | Nízká viditelnost indikátoru spolehlivosti AI | Závažný | T2 | FR-08 |
| P2 | Obtížná nalezitelnost funkce kopírování jídla | Závažný | T8 | FR-18 |
| P3 | … | … | … | … |

„V rámci úlohy T2 dva ze čtyř participantů nepovšimli barevného indikátoru spolehlivosti AI výsledku (confidence badge). Participanti tak neměli povědomí o míře spolehlivosti rozpoznání, což snižuje efektivitu funkčního požadavku FR-08. Problém se pravděpodobně týká vizuálního návrhu badge, který splývá s okolním rozhraním."

Doporučený počet problémů: 5–12 v závislosti na skutečných nálezech.]

### 5.4 Doporučení pro Další Iteraci

Na základě identifikovaných problémů a výsledků standardizovaných dotazníků lze formulovat doporučení pro další vývojovou iteraci aplikace. Doporučení jsou řazena podle priority, která vychází ze závažnosti příslušného problému a počtu dotčených participantů. Každé doporučení se váže ke konkrétnímu identifikovanému problému z kapitoly 5.3.

[CONTENT TO BE FILLED: Doporučení organizovaná do odstavců. Každé doporučení obsahuje:
— Odkaz na číslo problému z kapitoly 5.3
— Konkrétní návrh řešení
— Dotčené FR/NFR
— Očekávaný dopad na použitelnost

Vzor:

„V návaznosti na problém P1 (nízká viditelnost indikátoru spolehlivosti) je doporučeno zvýšit vizuální prominenci confidence badge zvětšením jeho rozměrů a přidáním textového popisku vedle barevného indikátoru. Tato úprava by měla zvýšit povědomí uživatelů o míře spolehlivosti AI výsledku v souladu s požadavkem FR-08. Současně je navrženo přidat krátkou animaci nebo zvýraznění při prvním zobrazení badge, aby byl uživatel na tento prvek aktivně upozorněn."

„Na základě problému P2 (nalezitelnost funkce kopírování) je navrženo přidat explicitní tlačítko ‚Kopírovat na jiný den' do detailu jídla, které bude viditelné bez nutnosti otevírat kontextové menu. Současně je doporučeno zvážit přidání této možnosti do akčního menu na hlavní obrazovce denního přehledu, čímž by se snížil počet kroků potřebných pro opakovaný záznam v souladu s požadavkem NFR-04."

Doporučený počet doporučení: 4–8, odpovídající počtu závažných a kritických problémů.]

Z výsledků testování vyplývá, že aplikace Foody dosáhla [CONTENT TO BE FILLED: SUS skóre] bodů v dotazníku SUS a průměrného SEQ skóre [CONTENT TO BE FILLED: hodnota] napříč všemi úlohami. Pragmatická kvalita dle UEQ-S byla hodnocena jako [CONTENT TO BE FILLED: hodnocení], což naznačuje, že základní interakční toky aplikace jsou pro uživatele srozumitelné a efektivní. Identifikované problémy se soustředí především na [CONTENT TO BE FILLED: hlavní oblast problémů], přičemž navržená doporučení jsou realizovatelná v rámci další vývojové iterace bez zásadních architektonických změn. Celkově lze konstatovat, že výsledky testování potvrzují životaschopnost zvoleného přístupu k AI rozpoznávání potravin s transparentní indikací nejistoty, avšak poukazují na konkrétní oblasti, kde je třeba zlepšit viditelnost klíčových prvků rozhraní a nalezitelnost sekundárních funkcí.

ZÁVĚR

PŘÍLOHY

ZDROJOVÝ KÓD

Projekt je dostupný prostřednictvím gitlab repozitáře:LITERATURA

[1] Evropská mapa obezity [online]. Evropa v datech, 19. 12. 2019 [cit. 2025-12-02]. Dostupné z: .

[2] NOGUEIRA-RIO, Nerea; Lucia VARELA VAZQUEZ; Aroa LOPEZ-SANTAMARINA aj. Mobile Applications and Artificial Intelligence for Nutrition Education: A Narrative Review. online. Dietetics, roč. 3 (2024), č. 4, s. 483-503. Dostupné z: .

[3] ABELTINO, Alessio; Alessia RIENTE; Giada BIANCHETTI aj. Digital applications for diet monitoring, planning, and precision nutrition for citizens and professionals: A state of the art. online. Nutrition Reviews, roč. 83 (2025), č. 2, s. e574-e601. Dostupné z: .

[4] SAMAD, Sabiha; Fahmida AHMED; Samsun NAHER aj. Smartphone Apps for Tracking Food Consumption and Recommendations: Evaluating Artificial Intelligence-based Functionalities, Features and Quality of Current Apps. online. Intelligent Systems with Applications, roč. 15 (2022), s. 200103. Dostupné z: https://doi.org/10.1016/j.iswa.2022.200103.

[5] LI, Xinyi; Annabelle YIN; Ha Young CHOI aj. Evaluating the Quality and Comparative Validity of Manual Food Logging and Artificial Intelligence Enabled Food Image Recognition in Apps for Nutrition Care. online. Nutrients, roč. 16 (2024), č. 15, s. 2573. Dostupné z: https://doi.org/10.3390/nu16152573.

[6] ABURUB, Aseel; Mohammad Z. DARABSEH; Rahaf BADRAN aj. The Use of Food Scanning Mobile Applications in Weight Loss: A Systematic Review of Longitudinal Interventional Studies. online. Physical Activity and Health, roč. 9 (2025), č. 1, s. 161-175. Dostupné z: https://doi.org/10.5334/paah.467.

[7] GIOIA, Siena; Irma M. VLASAC; Demsina BABAZADEH aj. Mobile Apps for Dietary and Food Timing Assessment: Evaluation for Use in Clinical Research. online. JMIR Formative Research, roč. 7 (2023), s. e35858. Dostupné z: .

[8] MYFITNESSPAL, Inc. MyFitnessPal: Calorie Tracker, BMR Calculator and Meal Scan [online]. MyFitnessPal, 2025 [cit. 2025-12-02]. Dostupné z: .

[9] DINE4FIT, a.s. Kalorické Tabulky: oficiální web, kalorická kalkulačka a mobilní aplikace [online]. KalorickeTabulky.cz, 2023-2025 [cit. 2025-12-02]. Dostupné z: .

[10] HOUSKA, Filip. Češi se svými tabulkami pomáhají hubnout i Evropě. Používá je přes milion lidí. [online]. CzechCrunch, 22. 8. 2024 [cit. 2025-12-02]. Dostupné z: .

[11] PUJIA, Carmelo; Eliana MAZZA; Teresa MAUROTTI aj. The Role of Mobile Apps in Obesity Management: Systematic Review and Meta-Analysis. online. *Journal of Medical Internet Research*, roč. 27 (2025), e66887. Dostupné z: https://doi.org/10.2196/66887.

[12] CRANE, N.; C. CARPENTER; M. GORIN aj. Patterns and Predictors of Engagement With Digital Self-Monitoring During the Maintenance Phase of a Behavioral Weight Loss Program: Quantitative Study. online. *JMIR mHealth and uHealth*, roč. 11 (2023), e45057. Dostupné z: https://doi.org/10.2196/45057.

[13] THEODORAKIS, Nikolaos; Maria NIKOLAOU. The Human Energy Balance: Uncovering the Hidden Variables of Obesity. online. *Diseases*, roč. 13 (2025), 55. Dostupné z: https://doi.org/10.3390/diseases13020055.

[14] DRENOWATZ, Clemens; Klaus GREIER. Integrating Diet and Exercise for Effective Weight Management - Synergistic Strategies for a Complex Challenge. online. Nutrients, roč. 17 (2025), 3423. Dostupné z: https://doi.org/10.3390/nu17213423.

[15] FRANKENFIELD, David; Linda ROTH-YOUSEY; Colleen COMPHER. Comparison of Predictive Equations for Resting Metabolic Rate in Healthy Nonobese and Obese Adults: A Systematic Review. online. Journal of the American Dietetic Association, roč. 105 (2005), č. 5, s. 775-789. Dostupné z: https://doi.org/10.1016/j.jada.2005.02.005.

[16] VENN, Bernard J. Macronutrients and Human Health for the 21st Century. online. Nutrients, roč. 12 (2020), č. 8, 2363. Dostupné z: https://doi.org/10.3390/nu12082363.

[17] FARAG, Mohamed A.; Samia HAMOUDA; Suzan GOMAA aj. Dietary Micronutrients from Zygote to Senility: Updated Review of Minerals Role and Orchestration in Human Nutrition throughout Life Cycle with Sex Differences. online. Nutrients, roč. 13 (2021), č. 11, 3740. Dostupné z: .

[18] ANG, Siew Min; Juliana CHEN; Jia Huan LIEW aj. Efficacy of Interventions That Incorporate Mobile Apps in Facilitating Weight Loss and Health Behavior Change in the Asian Population: Systematic Review and Meta analysis. online. Journal of Medical Internet Research, roč. 23 (2021), č. 11, e28185. Dostupné z: https://doi.org/10.2196/28185.

[19] RABER, Margaret; Yue LIAO; Anne RARA aj. A Systematic Review of the Use of Dietary Self Monitoring in Behavioural Weight Loss Interventions: Delivery, Intensity and Effectiveness. online. Public Health Nutrition, roč. 24 (2021), č. 17, s. 5885 5913. Dostupné z: .

[20] LUGONES-SANCHEZ, Cristina; Maria Antonia SANCHEZ-CALAVERA; Irene REPISO-GENTO aj. Effectiveness of an mHealth Intervention Combining a Smartphone App and Smart Band on Body Composition in an Overweight and Obese Population: Randomized Controlled Trial (EVIDENT 3 Study). online. JMIR mHealth and UHealth, roč. 8 (2020), č. 11, e21771. Dostupné z: https://doi.org/10.2196/21771.

[21] WANG, W.; J. CHENG; W. SONG; Y. SHEN. The Effectiveness of Wearable Devices as Physical Activity Interventions for Preventing and Treating Obesity in Children and Adolescents: Systematic Review and Meta-analysis. online. JMIR mHealth and UHealth, roč. 10 (2022), č. 4, e32435. Dostupné z: https://doi.org/10.2196/32435.

[22] HUANG, Xinru; Mingjie LI; Yefei SHI aj. Self-managed Weight Loss by Smart Body Fat Scales Ameliorates Obesity-related Body Composition during the COVID-19 Pandemic: A Follow-up Study in Chinese Population. online. Frontiers in Endocrinology, roč. 13 (2022), 996814. Dostupné z: https://doi.org/10.3389/fendo.2022.996814.

[23] CORNET, Victor Philip; Tammy TOSCOS; Davide BOLCHINI; Romisa ROHANI GHAHARI; Ryan AHMED; Carly DALEY; Michael J. MIRRO; Richard J. HOLDEN. Untold Stories in User-Centered Design of Mobile Health: Practical Challenges and Strategies Learned From the Design and Evaluation of an App for Older Adults With Heart Failure. online. JMIR Mhealth and uHealth, roč. 8 (2020), č. 7, s. e17703. Dostupné z: https://doi.org/10.2196/17703.

[24] MOLINA-RECIO, Guillermo; Rocío MOLINA-LUQUE; Ana M. JIMÉNEZ-GARCÍA; Pedro E. VENTURA-PUERTOS; Antonio HERNÁNDEZ-REYES; Manuel ROMERO-SALDAÑA. Proposal for the User-Centered Design Approach for Health Apps Based on Successful Experiences: Integrative Review. online. JMIR Mhealth and uHealth, roč. 8 (2020), č. 4, s. e14376. Dostupné z: https://doi.org/10.2196/14376.

[25] JOYNER, J. S.; KONG, A.; ANGELO, J.; HE, W.; VAUGHN-COOKE, M. Development of Low-Fidelity Virtual Replicas of Products for Usability Testing. online. Applied Sciences, roč. 12 (2022), č. 14, s. 6937. Dostupné z: https://doi.org/10.3390/app12146937.

[26] FLOHR, L. A.; WALLACH, D. P. The Value of Context-Based Interface Prototyping for the Autonomous Vehicle Domain: A Method Overview. online. Multimodal Technologies and Interaction, roč. 7 (2023), č. 1, s. 4. Dostupné z: https://doi.org/10.3390/mti7010004.

[27] MUGISHA, A.; BABIC, A.; WAKHOLI, P.; TYLLESKÄR, T. High-Fidelity Prototyping for Mobile Electronic Data Collection Forms Through Design and User Evaluation. online. JMIR Human Factors, roč. 6 (2019), č. 1, s. e11852. Dostupné z: https://doi.org/10.2196/11852.

[28] LUNDE, P.; SKOGLUND, G.; OLSEN, C. F.; HILDE, G.; BONG, W. K.; NILSSON, B. B. Think Aloud Testing of a Smartphone App for Lifestyle Change Among Persons at Risk of Type 2 Diabetes: Usability Study. online. JMIR Human Factors, roč. 10 (2023), s. e48950. Dostupné z: https://doi.org/10.2196/48950.

[29] WEICHBROTH, P. Usability Testing of Mobile Applications: A Methodological Framework. online. Applied Sciences, roč. 14 (2024), č. 5, s. 1792. Dostupné z: https://doi.org/10.3390/app14051792.

[30] WANG, S.-W.; CHIOU, C.-C.; SU, C.-H.; WU, C.-C.; TSAI, S.-C.; LIN, T.-K.; HSU, C.-N. Measuring Mobile Phone Application Usability for Anticoagulation from the Perspective of Patients, Caregivers, and Healthcare Professionals. online. International Journal of Environmental Research and Public Health, roč. 19 (2022), č. 16, s. 10136. Dostupné z: https://doi.org/10.3390/ijerph191610136.

[31] GOOGLE. Flutter documentation [online]. 2024 [cit. 2025-04-10]. Dostupné z: https://docs.flutter.dev/.

[32] META. React Native documentation [online]. 2024 [cit. 2025-04-10]. Dostupné z: https://reactnative.dev/.

[33] JETBRAINS. Kotlin Multiplatform documentation [online]. 2024 [cit. 2025-04-10]. Dostupné z: https://kotlinlang.org/docs/multiplatform.html.

[34] BIØRN-HANSEN, Andreas; Tor-Morten GRØNLI; Gheorghita GHINEA. A Survey and Taxonomy of Core Concepts and Research Challenges in Cross-Platform Mobile Development. online. *ACM Computing Surveys*, roč. 51 (2018), č. 5, s. 1–34. Dostupné z: https://doi.org/10.1145/3241739.

[35] PINCH BV. Floor — The typesafe, reactive, and lightweight SQLite abstraction for Flutter [online]. 2024 [cit. 2025-04-10]. Dostupné z: https://pub.dev/packages/floor.

[36] OPENAI. API Reference — Chat Completions [online]. 2025 [cit. 2025-04-10]. Dostupné z: https://platform.openai.com/docs/api-reference.

[37] GOOGLE. Gemini API documentation [online]. 2025 [cit. 2025-04-10]. Dostupné z: https://ai.google.dev/gemini-api/docs.

[38] GOOGLE. pub.dev — The official package repository for Dart and Flutter [online]. 2025 [cit. 2025-04-10]. Dostupné z: https://pub.dev/.

[39] BORGES, Jonny. GetX — An extra-light and powerful solution for Flutter [online]. 2024 [cit. 2025-04-10]. Dostupné z: https://pub.dev/packages/get.
