# Šablona pro závěrečné práce (Univerzita obrany)

Tento dokument slouží jako komplexní manuál a průvodce pro používání šablony `unob-thesis` v prostředí Typst.

## Část I: Jak šablonu používat

Existují tři možnosti, jak s šablonou pracovat:

-   **Offline** – instalace programu Typst a VSCode s rozšířením *Tinymist*.
-   **Online (přes web Typst)** – Jednoduchý přístup odkudkoliv, není nutná instalace.
-   **Online (UNOB)** – plánované řešení integrované do univerzitního prostředí (v současné době nefunkční).

### Offline varianta (Typst a VSCode + Tinymist)

Tento způsob je doporučený, pokud chcete mít vše nainstalované a uložené přímo na svém počítači.

1.  **Instalace Typst**
    -   Postupujte dle svého operačního systému. Doporučení: Windows přes `winget`, macOS přes `homebrew`, linux dle distribuce.
    -   [Stáhnout zde](https://typst.app/open-source/)

2.  **Instalace VSCode**
    -   **Windows (s právy správce):** [Stáhnout zde](https://code.visualstudio.com/download)
    -   **Windows (bez práv správce):** [Microsoft Store](https://apps.microsoft.com/detail/xp9khm4bk9fz7q?hl=cs-CZ&gl=CZ)
    -   **Linux & macOS:** [Stáhnout zde](https://code.visualstudio.com/download) (zvolte variantu pro vaši distribuci nebo procesor).

3.  **Nastavení češtiny ve VSCode**
    -   Otevřete paletu příkazů (`Ctrl+Shift+P` nebo `Cmd+Shift+P`).
    -   Napište `Configure Display Language` a vyberte *Čeština*.
    -   Restartujte program.

4.  **Instalace rozšíření Tinymist Typst**
    -   V levém menu klikněte na ikonu rozšíření (puzzle).
    -   Vyhledejte `Tinymist Typst` a klikněte na *Instalovat*.

5.  **Instalace fontů TeXGyre**
    -   Ve složce `fonts` šablony najdete potřebné soubory:
        -   *TeX Gyre Termes Math* (pro matematiku)
        -   *TeX Gyre Termes* (pro text)
        -   *TeX Gyre Cursor* (pro kód)
    -   Nainstalujte je dle systému (Windows: pravé tlačítko -> Instalovat font; macOS: přetáhnout do Knihy písem, Linux: dle distribuce).
    -   Restartujte VSCode pro aktivaci fontu v programu.

6.  **Jak otevřít a spustit šablonu**
    -   Otevřete ve VSCode složku, kde chcete mít projekt.
    -   Otevřete nový terminál (`Terminál` > `Nový terminál`).
    -   Vložte příkaz: `typst init @preview/unob-thesis:0.1.0`. Vždy zkontrolujte [aktuální verzi šablony](https://typst.app/universe/package/unob-thesis).
    -   Otevřete nově vytvořenou složku a v ní podsložku `template`.
    -   Otevřete soubor `thesis.typ`.
    -   V horní liště zvolte *Typst Preview: Náhled otevřeného souboru* pro zobrazení náhledu.
    -   Každé uložení (`Ctrl+S` / `Cmd+S`) se okamžitě projeví v náhledu.

### Online (web Typst)

1.  **Registrace a přihlášení**
    -   Registrace: [typst.app/signup](https://typst.app/signup)
    -   Přihlášení: [typst.app/signin](https://typst.app/signin)

2.  **Jak nahrát šablonu**
    -   Na hlavní stránce zvolte *Start from template* a vyhledejte šablonu `unob-thesis`.
    -   Pojmenujte projekt a můžete začít psát.
    -   Dokument se automaticky kompiluje a ukládá.

---

## Část II: Dokumentace šablony

Tato část obsahuje kompletní popis všech parametrů a funkcí, které můžete v šabloně využít.

### Hlavní funkce `template()`

Základní funkce pro sazbu celé práce. Vkládá se do `#show` pravidla ve formátu `#show: template.with(parametry)`

#### `university`
-   **Popis:** Informace o univerzitě a studijním programu.
-   **Parametry:**
    -   `faculty` (řetězec): Zkratka fakulty. Možnosti: `"fvl"`, `"fvt"`, `"vlf"`, `"uo"`.
    -   `programme` (řetězec): Název studijního programu.
    -   `specialisation` (řetězec): Název studijní specializace (nepovinné).

#### `thesis`
-   **Popis:** Informace o závěrečné práci.
-   **Parametry:**
    -   `type` (řetězec): Druh práce. Možnosti: `"bc"`, `"ing"`, `"phd"`, `"teze"`.
    -   `title` (řetězec): Plný název práce.

#### `author`, `supervisor`, `first_advisor`, `second_advisor`
-   **Popis:** Informace o osobách. Struktura je pro všechny stejná.
-   **Parametry:**
    -   `prefix` (řetězec): Hodnost a tituly před jménem.
    -   `name` (řetězec): Křestní jméno.
    -   `surname` (řetězec): Příjmení.
    -   `suffix` (řetězec | `none`): Tituly za jménem.
    -   `sex` (řetězec): Pohlaví (`"M"` nebo `"F"`) pro správné skloňování.

#### `declaration`
-   **Popis:** Nastavení čestného prohlášení.
-   **Parametry:**
    -   `declaration` (boolean): Zobrazit čestné prohlášení (`true`/`false`).
    -   `ai_used` (boolean): Uvést použití nástrojů AI (`true`/`false`).

#### `assignment`
-   **Popis:** Vložení naskenovaného zadání práce. Očekává soubory `/front.png` a `/back.png` ve vaší složce.
-   **Parametry:**
    -   `front` (boolean): Zobrazit přední stranu (`true`/`false`).
    -   `back` (boolean): Zobrazit zadní stranu (`true`/`false`).

#### `acknowledgement`
-   **Popis:** Vložení poděkování.
-   **Hodnota:** Obsah poděkování `[...obsah...]` nebo `false` pro skrytí.

#### `outlines`
-   **Popis:** Řízení generování obsahů a seznamů.
-   **Parametry:**
    -   `headings` (boolean): Obsah.
    -   `acronyms` (boolean): Seznam zkratek.
    -   `figures` (boolean): Seznam obrázků.
    -   `tables` (boolean): Seznam tabulek.
    -   `equations` (boolean): Seznam rovnic.
    -   `listings` (boolean): Seznam výpisů kódu.

#### `acronyms`
-   **Popis:** Slovník zkratek pro automatický seznam.
-   **Hodnota:** Slovník ve formátu `"ZKRATKA": ("Vysvětlení")` nebo `false`.

#### `abstract` a `keywords`
-   **Popis:** Abstrakty a klíčová slova.
-   **Parametry:**
    -   `czech` (obsah/řetězec): Česká verze.
    -   `english` (obsah/řetězec): Anglická verze.

#### `introduction`
-   **Popis:** Obsah úvodu práce.
-   **Hodnota:** Vlastní obsah úvodu ve formátu `[...]`.

#### `guide` a `docs`
-   **Popis:** Zobrazení nápovědy.
-   **Parametry:**
    -   `guide` (boolean): Zobrazí stručnou příručku.
    -   `docs` (boolean): Zobrazí tuto rozšířenou dokumentaci.

### Funkce `annex()` pro přílohy

-   **Popis:** Funkce pro sazbu a správné číslování příloh.
-   **Použití:** `#show: annex` a poté pište obsah příloh, kde každá hlavní kapitola (`=`) je nová příloha.

---

## Část III: Návod na psaní v Typstu

--- 
### Základní syntaxe

Typst je moderní značkovací jazyk. Jeho síla je v jednoduchosti a skriptovatelnosti.

-   **Odstavce:** Oddělují se prázdným řádkem.
-   **Zvýraznění:** `*tučné*`, `_kurzíva_`.
-   **Nadpisy:** Začínají znakem `=` (`=` kapitola, `==` podkapitola atd.).
-   **Seznamy:** Nečíslované začínají `-`, číslované `+`.
-   **Odkazy:** `https://typst.app/` se automaticky převede na odkaz.
-   **Komentáře:** Jednořádkové `//` a blokové `/* ... */`.

### Režimy syntaxe

-   **Značkování (Markup):** Výchozí režim pro psaní textu.
-   **Kód (Code):** Aktivuje se znakem `#`. Umožňuje volat funkce a psát skripty (`#rect(width: 1cm)`).
-   **Matematika (Math):** Vkládá se mezi znaky dolaru `$`.

### Jak psát odbornou práci

#### Struktura: Nadpisy a odstavce
Pro přehlednost použijte nadpisy. Úroveň nadpisu určíte počtem rovnítek `=`. Nový odstavec vytvoříte vložením prázdného řádku.

#### Obrázky
Nejprve obrázek nahrajte do projektu. Pro vložení s popiskem a číslováním použijte funkci `#figure`.

```typst
#figure(
  image(
    "balisticka_krivka.jpg", // Cesta k souboru
    height: 80%, // Výška
    width: 70% // Šířka
    ),
  caption: [Základní schéma balistické křivky.] // Titulek
) <obr:krivka> // Štítek pro odkazování
```

### Odkazování

Na očíslované prvky (obrázky, tabulky, rovnice) se můžete odkazovat.

1.  **Přidejte štítek (label):** Za prvek přidejte název do lomených závorek, např. `<obr:krivka>`.
2.  **Odkaz v textu:** Použijte znak `@` následovaný názvem štítku, např. `Jak je vidět na @obr:krivka...`.


### Matematické rovnice

Matematiku sázejte mezi znaky dolaru `$`.

-   **V textu (inline):** `$E = m c^2$` se zobrazí jako $E = m c^2$.
-   **Na samostatném řádku (bloková):** Použijte mezery kolem výrazu: `$ E = m c^2 $`.
-  **Tip: Zarovnání vícero rovnítek/symbolů pod sebou:** Před jednotlivé části přidejte ampersand `&`: `$ 12345x &= x\ 25x &= y $ `

```typ
// Další příklady:
Řecká písmena: $alpha, beta, gamma$
Zlomky: $a / b$
Horní/dolní index: $v_0^2$
Odmocnina: $sqrt(b^2 - 4ac)$
Suma: $sum_(i=1)^n i$
```
