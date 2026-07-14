# Referenční posudky pro kalibraci oponenta

Tento adresář obsahuje reálné posudky vedoucích a oponentů z obhájených ČVUT prací.
Skill `diplomka-oponent` je čte jako kalibrační materiál pro hodnocení.

## Jak přidat posudek

1. Stáhni posudek z [ČVUT DSpace](https://dspace.cvut.cz/) (PDF)
2. Převeď text posudku do Markdown souboru
3. Pojmenuj soubor podle konvence níže
4. Vlož metadata do YAML frontmatter

## Konvence pojmenování

```
{ZNAMKA}_{PORADI}_{PRIJMENI}.md
```

Příklady:
- `A_1_novak.md` — posudek práce ohodnocené A
- `DE_1_dvorak.md` — posudek práce ohodnocené D nebo E

## Požadovaný formát souboru

```markdown
---
grade: A           # A / B / C / D / E
type: oponent      # oponent / vedouci
thesis_type: DP    # BP / DP
faculty: FEL       # FEL / FIT / jiná
year: 2024
thesis_title: "Název práce"
student: "Jméno Příjmení"
reviewer: "Jméno Příjmení"
source_url: "https://dspace.cvut.cz/handle/..."
---

[Plný text posudku přepsaný z PDF]
```

## Doporučené zdroje pro hledání prací

### A-grade práce (snadné najít)
- **Cena děkana FEL:** https://oi.fel.cvut.cz/cs/ocenene-prace
- **Cena děkana FIT:** https://fit.cvut.cz/cs/studium/pruvodce-studiem/bakalarske-a-magisterske-studium/cena-dekana
- Vyhledat jméno studenta na DSpace → stáhnout posudky

### D/E-grade práce (těžší najít)
- Procházet DSpace ručně: https://dspace.cvut.cz/handle/10467/3256 (katedra 13139)
- Otevřít práci → stáhnout posudek PDF → zkontrolovat navrhovanou známku
- Případně se zeptat vedoucího práce na příklady slabších prací

## Cílový stav

5 posudků prací s A + 5 posudků prací s D/E = 10 referenčních bodů.
Ideálně mix vedoucích i oponentských posudků, BP i DP, z FEL i FIT.
