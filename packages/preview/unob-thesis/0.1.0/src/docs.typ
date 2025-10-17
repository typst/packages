#import "@preview/unob-thesis:0.1.0": *
#set text(lang: "cs")
#context if text.lang != "en" [
  // =============================
  // Globální nastavení dokumentu
  // =============================
  #set page(margin: 5%)
  #show raw: set text(
    font: "TeX Gyre Cursor",
    fallback: true,
    weight: "extrabold",
  )
  #show link: it => text(fill: blue, it)

  // =============================
  // Dokumentace šablon
  // =============================
  = Jak šablonu používat

  Existují tři možnosti, jak s šablonou pracovat:
  + *Offline* – instalace programu Typst a VSCode s rozšířením *Tinymist*
  + *Online (přes web Typst)* – Jednoduchý přístup odkudkoliv, není nutná instalace
  + *Online (UNOB)* – plánované řešení integrované do univerzitního prostředí (V současné době nefunkční)

  == Offline varianta (Typst a VSCode + Tinymist)
  Tento způsob doporučujeme, pokud chcete mít vše nainstalované a uložené přímo na svém počítači.
  Potřebujete k tomu program *Typst* a *Visual Studio Code (VSCode)* s rozšířením *Tinymist Typst*.

  #set enum(numbering: "(1.1)", body-indent: 1em, full: true)
  + *Instalace Typst*
    + Dle operačního systému. Doporučení: Windows přes winget, macOS přes homebrew, linux dle distribuce. → #link("https://typst.app/open-source/")[stáhnout zde]
  + *Instalace VSCode*
    + Windows (pokud máte práva správce) → #link("https://code.visualstudio.com/download")[stáhnout zde]
    + Windows (bez práv správce, vhodné pro služební přístroje) → #link("https://apps.microsoft.com/detail/xp9khm4bk9fz7q?hl=cs-CZ&gl=CZ")[Microsoft Store]
    + Linux → postupujte podle své distribuce →  #link("https://code.visualstudio.com/download")[stáhnout zde]
    + macOS → zvolte variantu podle procesoru (`Intel chip` nebo `Apple Silicon`) → #link("https://code.visualstudio.com/download")[stáhnout zde]

  + *Nastavení češtiny ve VSCode*
    + Zkratka `Ctrl+Shift+P` (Windows/Linux) nebo `Cmd+Shift+P` (Mac)
    + Zadejte `Configure Display Language` a vyberte *Čeština*
    + Program restartujte

  + *Instalace rozšíření Tinymist Typst*
    + V levém menu klikněte na ikonu „puzzle“ (*Rozšíření*)
    + Do vyhledávání napište `Tinymist Typst` a klikněte na *Instalovat*

  + *Instalace fontu TeXGyre (Moderní Times New Roman pro všechny systémy)*
    + Ve složce fonts se nachází soubory s třemi fonty:
      + *TeX Gyre Termes Math* pro sazbu matematiky.
      + *TeX Gyre Termes* pro sazbu textu.
      + *TeX Gyre Cursor* pro sazbu kódu.
    + Soubory nainstalujte dle operačního systému (Windows – Pravé tlačítko a nainstalovat, Linux – dle distribuce, MacOS – Přetáhnout do Kniha písem)
    + Fonty se projeví až po restartování *VSCode*.

  + *Jak otevřít a spustit šablonu*
    + Po zapnutí programu *VSCode* otevřete požadovanou složku (např. Dokumenty).
    + V záložce Terminál zvolte nový terminál, který otevře příkazový řádek.
    + Zde vložte příkaz `typst init @preview/unob-thesis-template:0.1.0`. (Významem "_Programe typst inicializuj šablonu se jménem unob-thesis-template ve verzi 0.1.0 z balíčku preview_". Vždy zkontrolujte aktuální verzi ze stránek šablony #link("https://typst.app/universe/package/unob-thesis-template")[unob-thesis-template])
    + Po spuštění automaticky vytvoří složku unob-thesis-template, která bude obsahovat všechny soubory šablony, vč zdroje.
    + Otevřete složku a v ní následně složku `template`, zbytek jsou zdrojové soubory, které v online verzi nejsou vidět a jsou pro běžného uživatele nepodstatné.
    + Otevřete `thesis.typ` v programu *VSCode*.
    + V horní liště zvolte *Typst Preview: Náhled otevřeného souboru* → zobrazí se náhled dokumentu
    + Každá změna se ihned projeví v dokumentu, je důležité nezapomenout dokument ukládat. (`Ctrl+S` / `Cmd+S`) ihned promítne do náhledu
  === Online (web Typst)
  Pokud nechcete nic instalovat, můžete využít webovou aplikaci *Typst*.

  + *Registrace a přihlášení*
    + Registrace: #link("https://typst.app/signup")[Typst.app/signup]
    + Přihlášení: #link("https://typst.app/signin")[Typst.app/signin]

  + *Jak nahrát šablonu*
    + Na hlavní stránce zvolte *Start from template* a pojmenujte projekt dle potřeby.
    + Zvolte soubor `thesis.typ` a pokud tomu tak není, tak jej aktivujte ikonou oka v pravé části.
    + Dokument se automaticky kompiluje a ukládá.

  === Online (UNOB – plánované)
  V budoucnu se plánuje spustit šablonu přímo přes univerzitní portál.
  //Předpokládaný postup:
  //+ Přihlášení do *Portálu osoby*
  //+ Kliknutí na službu *Typst*
  //+ Práce se šablonou stejná jako u webové verze

  #pagebreak(weak: true)

  // =============================
  // Dokumentace závěrečné práce
  // =============================
  = DOKUMENTACE

  Tento modul obsahuje popisy a nastavení šablony pro psaní bakalářských, diplomových i disertačních prací.

  #set text(lang: "cs")
  #import "@preview/tidy:0.4.3"

  #let thesis-docs = tidy.parse-module(read("../src/lib.typ"))
  #tidy.show-module(thesis-docs, style: tidy.styles.default)
]

// template
#let cheatsheet(
  title: [],
  authors: (),
  write-title: false,
  font-size: 5.5pt,
  line-skip: 5.5pt,
  x-margin: 30pt,
  y-margin: 0pt,
  num-columns: 5,
  column-gutter: 4pt,
  numbered-units: false,
  body,
) = {
  let color-index = (
    rgb("#239dad")
  )

  set page(
    paper: "a4",
    flipped: true,
    margin: (x: x-margin, y: y-margin),
  )

  set text(size: font-size)

  set heading(numbering: "1.1")

  show heading: it => {
    let index = counter(heading).at(it.location()).first()
    let color = color-index.darken(8% * (it.depth - 1))

    set text(white, size: 14pt)
    block(
      radius: 2.0mm,
      inset: 3.0mm,
      width: 100%,
      above: line-skip,
      below: line-skip,
      fill: color,
      it,
    )
  }

  let new-body = {
    if write-title {
      par[#title by #authors]
    }
    body
  }

  columns(
    num-columns,
    gutter: column-gutter,
    new-body,
  )
}

// ==========================================
// Importy
// ==========================================
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

// ==========================================
// Základní nastavení
// ==========================================
#set text(lang: "cs")
#show: codly-init.with()
#codly(languages: codly-languages)

// Písma (monospace pro `raw`, textové písmo pro běžný text)
#show raw: set text(font: "TeX Gyre Cursor", fallback: true, weight: "regular")
#set text(font: "TeX Gyre Termes")
#set par(justify: true)

// Odkazy: jen barevné zvýraznění (link zachová interaktivitu)
#show link: set text(fill: blue)

// Tabulky: nezarovnávat do bloku, ať se nevekslí „do šířky“
#show table: set par(justify: false)


// ==========================================
// Šablona „cheatsheet“
// ==========================================
#show: cheatsheet.with(
  title: "Návod na Typst",
  font-size: 10pt,
  line-skip: 5pt,
  x-margin: 1cm,
  y-margin: 1cm,
  num-columns: 2,
  column-gutter: 5mm,
)

= Základní syntaxe

Typst je značkovací jazyk. Jednoduchou syntaxí umožňuje běžné úkoly sazby textu. Lehká syntaxe je doplněna pravidly *`set`* a *`show`*, která usnadňují automatickou stylizaci dokumentu. Vše je podpořeno integrovaným a intuitivním skriptovacím jazykem s vestavěnými a uživatelsky definovanými funkcemi. Jedná se o moderní alternativu k sazebnímu programu LaTeX.

*Kapitola 'Základní syntaxe' slouží primárně jako tahák/pomůcka, není potřebné si její obsah pamatovat nazpaměť!*

== Režimy Syntaxe
Typst má tři syntaktické režimy:
+ *Značkování* (Markup), (podobné sytému markdown)
+ *Matematika* (Math)
+ *Kód* (Code).
Výchozí je režim značkování. Pamatujte, že Typst vždy udělá přesně to, co nastavíte!

#table(
  stroke: none,
  columns: (1fr, 1fr, 1fr),
  table.hline(),
  table.header([*Režim*], [*Syntaxe*], [*Příklad*]),
  table.hline(),
  [Kód], [Začněte znakem `#`], [Číslo:```typst #(1+2)```],
  [Matematika],
  [Obklopte vzorec ```typst $$```],
  [```typst $-x$``` je opak ```typst $x$```],
  [Značkování], [Obklopte kód `[]`], [```typst #let nazev = [*Typst!*]```],
  table.hline(),
)

Po vstupu do režimu kódu pomocí `#` již další `#` není potřeba, pokud mezitím nepřepnete zpět do režimu značkování nebo matematiky.

=== Režim značkování (Markup)
Typst poskytuje vestavěné značení pro nejběžnější prvky dokumentu. Většina syntaktických prvků jsou pouze zkratky pro odpovídající funkci. V následující tabulce jsou uvedeny všechny dostupné značky a odkazy na dokumentaci, kde se dozvíte více.

#table(
  stroke: none,
  columns: (1fr, 1fr, 1fr),
  table.hline(),
  table.header([*Název*], [*Příklad*], [*Odkaz*]),
  [Zalomení odstavce],
  [],
  [#link("https://typst.app/docs/reference/model/parbreak/")[parbreak]],
  [Silné zvýraznění],
  [\**tučné*\*],
  [#link("https://typst.app/docs/reference/model/strong/")[strong]],
  [Zvýraznění],
  [\__zvýrazněné_\_],
  [#link("https://typst.app/docs/reference/model/emph/")[emph]],
  [Nezformátovaný text],
  [\`print("Ahoj")\`],
  [#link("https://typst.app/docs/reference/text/raw/")[raw]],
  [Odkaz (url)],
  [https://typst.app/],
  [#link("https://typst.app/docs/reference/model/link/")[link]],
  [Štítek],
  [\<obr:nazev\>],
  [#link("https://typst.app/docs/reference/foundations/label/")[label]],
  [Reference],
  [\@obr:nazev],
  [#link("https://typst.app/docs/reference/model/ref/")[ref]],
  [Nadpis 1. úroveň (1.)],
  [\= Kapitola],
  [#link("https://typst.app/docs/reference/model/heading/")[heading]],
  [Nadpis 2. úroveň (1.1.)],
  [\== Podkapitola],
  [#link("https://typst.app/docs/reference/model/heading/")[heading]],
  [Nadpis 3. úroveň (1.1.1)],
  [\=== Oddíl],
  [#link("https://typst.app/docs/reference/model/heading/")[heading]],
  [Nadpis 4. (bez čísla)],
  [\==== Pododdíl],
  [#link("https://typst.app/docs/reference/model/heading/")[heading]],
  [Výčet nečíslovaný],
  [`- položka`],
  [#link("https://typst.app/docs/reference/model/list/")[list]],
  [Výčet číslovaný],
  [`+ položka`],
  [#link("https://typst.app/docs/reference/model/enum/")[enum]],
  [Výčet definiční],
  [\/ *Definice*: popis],
  [#link("https://typst.app/docs/reference/model/terms/")[terms]],
  [Matematika],
  [```typst $x^2$ ```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Zalomení řádku],
  [`\`],
  [#link(
    "https://typst.app/docs/reference/model/par/#parameters-linebreaks",
  )[linebreak]],
  [Chytré uvozovky],
  ["jedna 'dva' tři"],
  [#link("https://typst.app/docs/reference/text/smartquote/")[smartquote]],
  [Zkratky symbolů],
  [`~`, ---],
  [#link("https://typst.app/docs/reference/foundations/symbol/")[Symbols]],
  [Výraz kódu],
  [```typst #rect(width: 1cm)```],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Zamezení formátování], [Číslo `#25`], [],
  [Komentář],
  [ \/\* blok od -- do \*\/, \// na řádku],
  [#link("https://typst.app/docs/reference/syntax/#comments")[Comments]],
  table.hline(),
)
=== Matematický režim (Math)
Matematický režim je speciální značkovací režim, který se používá pro sazbu matematických vzorců a rovnic. Zadává se tak, že se rovnice obalí znaky `$` (dollarové znaménko). Funguje i ve značkovacím (markup) i kódovém (code) režimu.

Rovnice se napíše do vlastního bloku, pokud začíná a končí alespoň jednou mezerou (např. ```typst $ x^2 $```). Inline matematiku (tzv. linkový zápis) lze vytvořit vynecháním mezer (např. ```typst $x^2$```). Následuje přehled syntaxe specifické pro matematický režim:

#table(
  stroke: none,
  columns: (1fr, 1fr, 1fr),
  table.hline(),
  table.header([*Název*], [*Příklad*], [*Odkaz*]),
  table.hline(),
  [Matematika v řádku],
  [```typst $x^2$ ```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Matematika v bloku],
  [```typst $ x^2 $ ```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Dolní index],
  [```typst$x_1$ ```],
  [#link("https://typst.app/docs/reference/math/attach/")[attach]],
  [Horní index],
  [```typst $x^2$ ```],
  [#link("https://typst.app/docs/reference/math/attach/")[attach]],
  [Zlomek],
  [```typst $1 + (a+b)/5$ ```],
  [#link("https://typst.app/docs/reference/math/frac/")[frac]],
  [Zalomení řádku],
  [```typst $x  y$ ```],
  [#link(
    "https://typst.app/docs/reference/model/par/#parameters-linebreaks",
  )[linebreak]],
  [Zarovnávací bod],
  [```typst $x &= 2 \\ &= 3$ ```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Přístup k proměnné],
  [```typst $#vlastni_prikaz $, $pi$```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Přístup k poli (objektu)],
  [```typst $arrow.r.long$ ($arrow.r.long$)```],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Implicitní násobení],
  [```typst$x y$```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Zkratky symbolů],
  [```typst$->$, $!=$```],
  [#link("https://typst.app/docs/reference/symbols/")[Symbols]],
  [Text/řetězec],
  [```typst $a "je písmeno" $```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Volání matematické funkce],
  [```typst $floor(x)$```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Výraz kódu],
  [```typst $#rect(width: 1cm)$```],
  [#link("https://typst.app/docs/reference/model/scripting/")[Scripting]],
  [Escapování znaku], [```typst \$```], [],
  [Komentář],
  [```typst /* komentář */ ```],
  [#link("https://typst.app/docs/reference/syntax/#comments")[Comments]],
  table.hline(),
)

=== Režim kódu (Code)
V rámci bloků kódu a výrazů mohou nové výrazy začínat bez úvodního znaku \#. Mnoho syntaktických prvků je specifických pro výrazy. Níže je uvedena tabulka se seznamem všech syntaxí, které jsou k dispozici v režimu kódu:
#table(
  stroke: none,
  columns: (1fr, 1fr, 1fr),
  table.hline(),
  table.header([*Název*], [*Příklad*], [*Odkaz*]),
  table.hline(),
  [`none` (typ)],
  [`none`],
  [#link("https://typst.app/docs/reference/types/none/")[none]],
  [`auto` (typ)],
  [`auto`],
  [#link("https://typst.app/docs/reference/types/auto/")[auto]],
  [Logická hodnota (`bool`)],
  [`false, true`],
  [#link("https://typst.app/docs/reference/types/boolean/")[bool]],
  [Celé číslo (`int`)],
  [`10, 0xff`],
  [#link("https://typst.app/docs/reference/types/integer/")[int]],
  [Desetinné číslo (`float`)],
  [`3.14, 1e5`],
  [#link("https://typst.app/docs/reference/types/float/")[float]],
  [Délka (`length`)],
  [`2pt, 3mm, 1em, ..`],
  [#link("https://typst.app/docs/reference/types/length/")[length]],
  [Úhel (`angle`)],
  [`90deg, 1rad`],
  [#link("https://typst.app/docs/reference/types/angle/")[angle]],
  [Zlomek (`fraction`)],
  [`2fr`],
  [#link("https://typst.app/docs/reference/types/fraction/")[fraction]],
  [Poměr (`ratio`)],
  [`50%`],
  [#link("https://typst.app/docs/reference/types/ratio/")[`ratio`]],
  [Řetězec (`string`)],
  ["ahoj"],
  [#link("https://typst.app/docs/reference/types/string/")[`str`]],
  [Odkaz (`label`)],
  [`<predmluva>`],
  [#link("https://typst.app/docs/reference/types/label/")[label]],
  [Matematika (`math`)],
  [```typst $x^2$```],
  [#link("https://typst.app/docs/reference/math/")[Math]],
  [Nezformátovaný text (`raw`)],
  [\`print(1)\`],
  [#link("https://typst.app/docs/reference/text/raw")[raw]],
  // --- Skriptování a Výrazy ---
  [Přístup k proměnné],
  [`x`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Blok kódu],
  [```typst {let x = 1; x + 2 }```],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Blok obsahu],
  [```typst [*Ahoj*]```],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Výraz v závorkách],
  [`(1 + 2)`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Pole (`array`)],
  [`(1, 2, 3)`],
  [#link("https://typst.app/docs/reference/foundations/array/")[Array]],
  [Slovník (`dictionary`)],
  [`(a: "ahoj", b: 2)`],
  [#link("https://typst.app/docs/reference/types/dictionary/")[Dictionary]],
  [Unární operátor],
  [`-x`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Binární operátor],
  [`x + y`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Přiřazení],
  [`x = 1`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Přístup k poli (vlastnosti)],
  [`x.y`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  [Volání metody],
  [`x.flatten()`],
  [#link("https://typst.app/docs/reference/scripting/")[Scripting]],
  // --- Funkce ---
  [Volání funkce],
  [`min(x, y)`],
  [#link("https://typst.app/docs/reference/foundations/function/")[Function]],
  [Rozbalení argumentů],
  [`min(..nums)`],
  [#link("https://typst.app/docs/reference/foundations/arguments/")[Arguments]],
  [Anonymní funkce (lambda)],
  [`(x, y) => x + y`],
  [#link(
    "https://typst.app/docs/reference/foundations/function/#closures",
  )[Function]],
  [Vazba `let`],
  [`let x = 1`],
  [#link("https://typst.app/docs/reference/scripting/#bindings")[Scripting]],
  [Pojmenovaná funkce],
  [`let f(x) = 2 * x`],
  [#link("https://typst.app/docs/reference/foundations/function/")[Function]],
  [Návrat z funkce (`return`)],
  [`return x`],
  [#link("https://typst.app/docs/reference/foundations/function/")[Function]],
  // --- Stylování ---
  [Pravidlo `set`],
  [`set text(14pt)`],
  [#link("https://typst.app/docs/reference/styling/#set-rules")[Styling]],
  [Podmíněné pravidlo `set`],
  [`set text(..) if .`.],
  [#link("https://typst.app/docs/reference/styling/#set-rules")[Styling]],
  [Pravidlo `show` (+ `set`)],
  [`show heading: set block(..)`],
  [#link("https://typst.app/docs/reference/styling/#show-rules")[Styling]],
  [Pravidlo `show` (s funkcí)],
  [`show raw: it => {...}`],
  [#link("https://typst.app/docs/reference/styling/#show-rules")[Styling]],
  [Pravidlo `show` (vše)],
  [`show: template`],
  [#link("https://typst.app/docs/reference/styling/#show-rules")[Styling]],
  // --- Řízení Toku a Moduly ---
  [Kontextový výraz (`context`)],
  [`context text.lang`],
  [#link("https://typst.app/docs/reference/scripting/#context")[Context]],
  [Podmínka (`if`/`else`)],
  [`if x == 1 {..} else {..}`],
  [#link(
    "https://typst.app/docs/reference/scripting/#conditionals",
  )[Scripting]],
  [Cyklus `for`],
  [`for x in (1, 2, 3) {..}`],
  [#link("https://typst.app/docs/reference/scripting/#loops")[Scripting]],
  [Cyklus `while`],
  [`while x < 10 {..}`],
  [#link("https://typst.app/docs/reference/scripting/#loops")[Scripting]],
  [Řízení cyklu (`break`/`cont.`)],
  [`break, continue`],
  [#link("https://typst.app/docs/reference/scripting/#loops")[Scripting]],
  [Vložení modulu (`include`)],
  [`include "soubor.typ"`],
  [#link("https://typst.app/docs/reference/scripting/#modules")[Scripting]],
  [Import modulu (`import`)],
  [`import "soubor.typ"`],
  [#link("https://typst.app/docs/reference/scripting/#modules")[Scripting]],
  [Import položek (`import`)],
  [`import "soubor.typ": a, b, c`],
  [#link("https://typst.app/docs/reference/scripting/#modules")[Scripting]],
  table.hline(),
)

== Komentáře
Komentáře jsou programem Typst ignorovány a nebudou zahrnuty do výstupu (PDF). To je užitečné pro vyloučení starých verzí nebo pro přidání poznámek. Chcete-li zakomentovat jeden řádek, začněte jej znakem `//`:
```typst
// Hodnota $p > 0,05$ značí, že rozdíl není významný.
// Opraveno dle nových dat!
 Hodnota $p < 0,05$ značí, že rozdíl je významný.
```
*Výsledek:*
#rect([Hodnota $p < 0,05$ značí, že rozdíl je významný.], radius: 2mm)

Komentáře lze také zabalit mezi \/\* a \*\/. V tomto případě se komentář může rozprostírat přes více řádků:
```typst
/* Výsledek ještě ověřit!
Doplnit odkaz na hypotézy v kap.3 */
 Hodnota $p < 0,05$ značí, že rozdíl je významný.
```
Výsledek je stejný jako výše zmíněný.
== Únikové sekvence (Escape)
Escape sekvence slouží k vkládání speciálních znaků, které se v programu Typst obtížně píší nebo mají jiný zvláštní význam. Chcete-li znak "uniknout", předepište jej zpětným lomítkem. Chcete-li vložit libovolný kódový bod Unicode, můžete napsat hexadecimální escape sekvenci:
```typst
Koupil jsem zmrzlinu za \$1.50! \u{1f600}.
```
*Výsledek:*
#rect([Koupil jsem zmrzlinu za \$1.50! \u{1f600}.], radius: 2mm)

== Cesty k souborům
Typst má různé funkce, které vyžadují cestu k souboru pro odkaz na externí zdroje, jako jsou obrázky, soubory  Typst (`soubor.typ`) nebo datové soubory (soubory s příponou `.cbor/csv/json/read/toml/xml/yaml`). Cesty jsou reprezentovány jako řetězce. Existují dva druhy cest: *Relativní* a *Absolutní*.
=== Relativní cesta
Hledá od umístění souboru Typst, ve kterém je funkce vyvolána. Jedná se o výchozí nastavení:
```typst
#image("images/logo.png“)
```
=== Absolutní cesta
Absolutní cesta vyhledává z kořene projektu. Začíná počátečním znakem /:
```typst
#image("/assets/logo.png“)
```
= Jak psát odbornou práci v Typst (Návod pro studenty)

Již za sebou máte všechny potřebné základy! Dostali jste za úkol napsat diplomovou práci, seminárku nebo odbornou esej. Vaše práce bude potřebovat:

- Odborný text,
- Nadpisy pro strukturu,
- Citáty (z předpisů, knih, ...),
- Matematické a fyzikální rovnice,
- Možná chemické vzorce,
- Tabulky s daty,
- Obrázky (schémata, grafy),
- Citace zdrojů a seznam literatury.

Tento návod vám ukáže, jak toho jednoduše dosáhnout právě v Typstu.

== Založení projektu a první text

V aplikaci Typst si vytvořte nový projekt nebo použijte šablonu. Následně se otevře se editor:
- *Vlevo:* Panel se zdrojovým kódem (sem píšete vy).
- *Vpravo:* Panel s náhledem (zde vidíte výsledek v reálném čase).

Začněte psát úvod přímo do levého panelu. Text se okamžitě objeví vpravo.

```typst
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
```

*Výsledek:*
#rect([#lorem(10)], radius: 2mm)

== Struktura: Nadpisy a odstavce

Pro přehlednost použijte nadpisy. Úroveň nadpisu určíte počtem rovnítek `=`:
- `=` Hlavní kapitola (úroveň 1),
- `==` Podkapitola (úroveň 2),
- `===` Oddíl (úroveň 3),
- `====` Pododdíl (úroveň 4 [nezapisuje se do obsahu]).
Nový odstavec vytvoříte jednoduše vložením *prázdného řádku*.

// Příklad kódu pro strukturu:
```typst
#heading(numbering: none, level: 1, "Úvod") // Nadpis bez číslování
Text text text Text text text Text text text Text text text Text text text
= Teoretická část
Text text text Text text text Text text text Text text text Text text text
== Podkapitola
Text text text Text text text Text text text Text text text Text text text
```
*Výsledek:*
#{
  rect(radius: 2mm, [
    #text(size: 14pt, "Úvod", weight: "bold")\
    Text text text Text text text Text text text Text text text Text text text\
    #text(size: 14pt, "1 Teoretická část", weight: "bold")\
    Text text text Text text text Text text text Text text text Text text text\
    #text(size: 13pt, "1.1 Podkapitola", weight: "bold")\
    Text text text Text text text Text text text Text text text Text text text])
}

== Základní formátování a seznamy
- *Kurzíva:* Text uzavřete do `_podtržítek_`. Vhodné pro zvýraznění pojmů nebo cizích slov.
- *Tučné písmo:* Text uzavřete do `*hvězdiček*`. Používejte střídmě pro silné zdůraznění.
- *Číslovaný seznam:* Každou položku začněte znakem `+`.
- *Seznam s odrážkami:* Každou položku začněte znakem `-`.
- *Zanoření seznamu:* Další úroveň seznamu odsaďte (např. dvěma mezerami nebo tabulátorem).

// Příklad kódu pro seznamy:
```typst
/ Balistika:  Věda zabývající se pohybem a účinkem střely (projektilu, náboje).

Hlavní faktory ovlivňující dráhu střely:
+ Gravitace Země
+ Odpor vzduchu
  - _Hustota vzduchu_ (závislá na teplotě, tlaku, vlhkosti)
  - Tvar a *rychlost* střely (balistický koeficient $C_D$)
+ Rotace střely
  + Magnusův efekt
  + Stabilizace
+ Vítr
```

*Výsledek :*

#counter(heading).update(0)
#rect[
  / Balistika: Věda zabývající se pohybem a účinkem střely (projektilu, náboje).

  Hlavní faktory ovlivňující dráhu střely:
  1. Gravitace Země
  2. Odpor vzduchu
    - _Hustota vzduchu_ (závislá na teplotě, tlaku, vlhkosti)
    - Tvar a *rychlost* střely (balistický koeficient $C_D$)
  + Rotace střely
    + Magnusův efekt
    + Stabilizace
  + Vítr
]
#counter(heading).update(2)
#counter(heading).step(level: 2)
#counter(heading).step(level: 2)
#counter(heading).step(level: 2)

== Obrázky

Nejprve nahrajte obrázek (obrázek,jpg/png/svg/gif) do projektu přes panel souborů (ikona složky vlevo), nebo zkopírovaný obrázek vložit pomocí klávesové zkratky ctrl+v.

=== Jednoduché vložení (Image)
Funkce `#image` vloží obrázek. Argumentem je cesta k souboru v uvozovkách. Obrázek se přizpůsobí šířce textu.
```typst
#image("balisticka_krivka.jpg")
```

=== Obrázek s popiskem (Figure)

Pro očíslovaný popisek, nastavení velikosti a možnost odkazování použijte funkci `#figure`.

```typst
#figure(
  // Zde voláme funkci image() už bez #
  image(
    "balisticka_krivka.jpg", // Cesta k souboru
    width: 70% // Nastaví šířku na 70 % šířky textu (lze nahradit hodnotami velikosti (fr, mm, cm))
  ),
  // Popisek je blok obsahu v hranatých závorkách []
  caption: [
    Základní schéma balistické křivky ve vakuu.
  ]
) <obr:balisticka-krivka-schema> // Štítek přidán pro následné odkazování
Zdroj: Vlastní zpracování/citace // Vlastní příkaz, jenž přidá popisek "Zdroj: + text uvnitř hranatých závorek". Jedná se o příkaz vytvoření pro potřeby šablony, tudíž nebude fungovat.
// POZOR: Nezapomeňte na čárku mezi image() a caption!
// POZOR: Hlídejte si správné uzavření všech závorek () a [].
```
*Výsledek:*
// Zde by byl skutečný výsledek, pokud by obrázek existoval a byl vložen.
// Pro ukázku vložíme textový popis:
#figure(
  rect(
    radius: 2mm,
    width: 70%,
    height: 2cm,
    stroke: black,
    inset: 0pt,
  )[Obrázek],
  caption: [
    Základní schéma balistické křivky ve vakuu.
  ],
) <obr:balisticka-krivka-schema>
Zdroj: Vlastní zpracování/citace

*(Číslování obrázků je automatické.)*

== Odkazování (Labels & References)

Na očíslované prvky (obrázky, tabulky, rovnice, kapitoly) se můžete odkazovat v textu.

1. *Přidejte štítek (label):* Hned za definici prvku (např. za `#figure(...)`) přidejte unikátní název do lomených závorek `< >`.
  - *Doporučení:* Používejte prefixy pro přehlednost (např. `obr:`, `tab:`, `rov:`, `kap:`) a pište *bez mezer a diakritiky*.
2. *Odkaz v textu:* V místě, kde chcete odkazovat, použijte znak `@` následovaný názvem návěští.

// Příklad kódu pro odkazování:
```typst
Jak ukazuje @obr:balisticka-krivka-schema, trajektorie střely má parabolický tvar pouze ve vakuu. Vliv odporu vzduchu popisuje @kap:odpor-vzduchu.]
```

*Výsledek*
#rect[
  Jak ukazuje @obr:balisticka-krivka-schema, trajektorie střely má parabolický tvar pouze ve vakuu. Vliv odporu vzduchu popisuje @kap:odpor-vzduchu.]

== Citáty<kap:odpor-vzduchu>
Pro delší citace použijte funkci `#quote`. Pomocí ```typst #set quote(block: true)``` zajistíte, že citát bude jako samostatný blok. Argument `attribution` přidá zdroj/autora citátu.

```typst
// Nastavení pro blokové citace (obvykle se dává jednou na začátek dokumentu)
#set quote(block: true)

// Použití citátu
#quote(
  attribution: [Předpis Art-1–1, s. 15] // Zdroj citátu
)[
"_Přesnost střelby je základním předpokladem účinného boje. Znalost balistiky a pečlivá příprava střelby jsou nezbytné pro každého střelce._"
]
```
*Výsledek:*
#set quote(block: true)
#quote(
  attribution: [Předpis Art-1–1, s. 15],
)[
  _"Přesnost střelby je základním předpokladem účinného boje. Znalost balistiky a pečlivá příprava střelby jsou nezbytné pro každého střelce."_
]
#set quote(block: false) // Vrátíme nastavení pro inline citace

== Matematické a fyzikální rovnice
Matematiku sázejte mezi znaky dolaru `$`.
- *Inline matematika:* `$ E = m c^2 $` se sází přímo v textu ($E = m c^2$).
- *Bloková matematika (na samostatném řádku):* Použijte mezeru za/před dolary: `$ F_D = 1/2 rho v^2 C_D A $`.

// Příklad kódu pro matematiku:
```
// Inline
Newtonův druhý zákon $F = m a$ je základem.

// Bloková rovnice
Síla odporu vzduchu $ F_D $ je dána vztahem:
$ F_D = 1/2 rho v^2 C_D A $ <rov:sila-odporu>
// Můžeme přidat i návěští pro odkazování (@rov:sila-odporu)

// Další příklady:
Řecká písmena: $ alpha, beta, gamma, rho $
Zlomky: $ a / b $
Horní/dolní index: $ v_0^2 $
Indexy s více znaky: $ x_(i+1) = x_i + v_i Delta t $
Odmocnina: $ sqrt(b^2 - 4 a c) $
Suma: $ sum_(i=1)^n i = n(n+1)/2 $
Vektor: $ vec(a, b, c) $
```

*Výsledek v náhledu:*
#set math.equation(numbering: "(1)")
Newtonův druhý zákon $F = m a$ je základem.

Síla odporu vzduchu $ F_D $ je dána vztahem:
$ F_D = 1/2 rho v^2 C_D A $ <rov:sila-odporu>

Další příklady:

Řecká písmena: $ alpha, beta, gamma, rho $
Zlomky: $ a / b $
Horní/dolní index: $ v_0^2 $
Indexy s více znaky: $ x_(i+1) = x_i + v_i delta t $
Odmocnina: $ sqrt(b^2 - 4 a c) $
Suma: $ sum_(i=1)^n i = n(n+1)/2 $
Vektor: $ vec(a, b, c) $

*(Číslování rovnic je obvykle automatické, pokud je nastaveno v šabloně.)*

== Bibliografie a citace zdrojů

Každá odborná práce potřebuje seznam literatury a citace v textu. Typst používá nativně formát Hayagriva (`.yml`) a BibLaTeX (`.bib`). Oba formáty velmi usnadňují práci s citacemi, protože po zapsání zdroje do souboru jej lze vyvolat jako odkaz (pomocí `@název`) a dle nastaveného citačního stylu automaticky zapsán v seznamu literatury.

=== Vytvoření souboru s bibliografií (např. `literatura.yml`):

Vytvořte v projektu nový soubor (např. `literatura.yml`) a vložte do něj záznamy o zdrojích. Každý záznam má unikátní *klíč* (např. `Novak2023`).

// Příklad kódu pro soubor literatura.yml:
```yml
Novak2023: # Toto je klíč pro citování
  type: book # Typ zdroje (book, article, report, ...)
  author:
    - Novák, Jan # Příjmení, Jméno
  title: "Moderní balistika pro praxi" # Název díla
  publisher: "Univerzita obrany" # Vydavatel
  date: 2023 # Rok vydání
  location: "Brno" # Místo vydání

Art11:
  type: report
  author: "Ministerstvo obrany ČR"
  title: "Art-1-1: Dělostřelecká příprava"
  date: 2019
  # ... další údaje dle potřeby
```

=== Vložení seznamu literatury do dokumentu:

Na konec práce (obvykle do samostatné kapitoly) vložte funkci `#bibliography`. Argumentem je cesta k souboru a volitelně styl citování.

// Příklad kódu pro vložení bibliografie:
```
= Seznam použité literatury

#bibliography(
  "literatura.yml", // Cesta k vašemu souboru
  title: none, // Skryje nadpis "Bibliography" (pokud máte vlastní nadpis kapitoly)
  style: "iso-690-numeric" // Příklad citačního stylu
)
```

=== Citování v textu:

V textu použijte znak `@` následovaný *klíčem* ze souboru `.yml`. Pro odkaz na konkrétní stranu přidejte číslo strany do hranatých závorek `[]`.

// Příklad kódu pro citování v textu:
```
Jak uvádí Novák @Novak2023[s. 45-48], odpor vzduchu...
Základní postupy definuje předpis @Art11.
```

*Výsledek v náhledu:*
// Zde by byl skutečný výsledek, pokud by existoval soubor literatura.yml a byl správně načten.
// Ukázka textu:
Jak uvádí Novák (NOVÁK, s. 45-48), odpor vzduchu...
Základní postupy definuje předpis Art11.

// Ukázka seznamu literatury (musí být na konci dokumentu):
// = Seznam použité literatury
// #bibliography("literatura.yml", title: none, style: "iso-690-numeric")

*(Formát citací a seznamu literatury závisí na zvoleném stylu a obsahu .yml souboru.)*

== Tabulky

Pro přehledné zobrazení dat použijte funkci `#table`. Definujte sloupce, záhlaví a data.

// Příklad kódu pro tabulku:
```
#figure( // Vložíme do figure pro popisek a číslování
  table(
    columns: (auto, 1fr, 1fr), // Šířky sloupců (první auto, další dva stejné)
    stroke: 0.5pt, // Ohraničení buněk
    align: (center + horizon), // Zarovnání obsahu buněk (na střed horizontálně i vertikálně)

    // Záhlaví tabulky (zvýrazněné)
    [*Vzdálenost*], [*Pokles dráhy*], [*Energie*],

    // Data tabulky
    [100 m], [-0 cm], [3500 J],
    [300 m], [-28.5 cm], [2800 J],
    [500 m], [-125.2 cm], [2200 J],
  ),
  caption: [Orientační balistická data pro střelu 7.62x51mm NATO.]
) <tab:strelba-data> // Návěští pro odkazování @tab:strelba-data
```

*Výsledek v náhledu:*
#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: 0.5pt,
    align: (center + horizon),
    [*Vzdálenost*], [*Pokles dráhy*], [*Energie*],
    [100 m], [-0 cm], [3500 J],
    [300 m], [-28.5 cm], [2800 J],
    [500 m], [-125.2 cm], [2200 J],
  ),
  caption: [Orientační balistická data pro střelu 7.62x51mm NATO.],
) <tab:strelba-data>

*(Pro přidání číslovaného popisku k tabulce ji vložte do `#figure`, podobně jako obrázek.)*

== Shrnutí

Právě jste se naučili základy psaní odborné práce v Typstu: strukturování pomocí *nadpisů*, základní *formátování*, *seznamy*, vkládání *obrázků* a *tabulek* s popisky a *odkazováním*, sázení *matematiky*, správu *bibliografie* a *citací*.
//#bibliography("bibliography.yml")
Toto je jen začátek. Typst nabízí mnohem více možností pro pokročilé formátování, tvorbu vlastních šablon a automatizaci. Nebojte se experimentovat a prozkoumat oficiální dokumentaci Typstu: #link("https://typst.app/docs/")[https://typst.app/docs/]. Hodně štěstí při psaní!
