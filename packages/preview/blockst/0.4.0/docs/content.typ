#import "@schule/schuldocs:0.3.0": doc-target, info, show-code, show-example, show-module, tip, warning
#import "../lib.typ": scratch, blockly, makecode, nepo
#import "catalog.typ": catalog-entries

// Gesetzte Blöcke brauchen im HTML-Export einen Rahmen: ohne ihn verwirft
// Typst den Zustand, den die Renderer über `hide` mitführen, und warnt
// („hide was ignored during HTML export"). Im Handbuch bleibt alles, wie es ist.
#let framed(body) = context if doc-target() == "web" { html.frame(body) } else { body }

// Verweis auf ein Kapitel: die Website ist geteilt, jedes Kapitel eine Seite
// (`<slug>.html`, die Einleitung `index.html`); im Handbuch bleibt der Text.
#let goto(page, body, anchor: "") = context if doc-target() == "web" {
  link((if page == "index" { "index.html" } else { page + ".html" }) + anchor, body)
} else { body }

= Introduction

== About blockst

*blockst* renders block-based programs in Typst documents, each drawn the way its editor draws it:

- *Scratch 3* — `scratch()`, the Scratch look in 26 languages, including right-to-left scripts, with an execution engine for turtle graphics and helpers for importing `.sb3` project files.
- *Blockly* — `blockly()`, today's flat Blockly and the pre-2019 look, with profiles for the Jugendwettbewerb Informatik (jwinf.de) and its robot and turtle blocks.
- *MakeCode* — `makecode()`, the micro:bit and Calliope mini editors' blocks in all 36 of their languages.
- *NEPO (Open Roberta)* — `nepo()`, the Calliope mini and micro:bit blocks of Open Roberta Lab.

All four share one text notation: a block per line, `(…)` for a value, `[… v]` for a dropdown, `<…>` for a condition, indentation and an end marker for the body of a loop. Typst hands the text to a bundled WASM plugin, the plugin parses it and returns SVG, Typst embeds the SVG. Nothing has to be installed beyond the package.

#info(title: "Core Design")[
  - Fully text-based: write blocks as plain text, get rendered blocks. The same notation for every editor.
  - Each editor's own geometry, palette and vocabulary — jwinf's classic Blockly measured on jwinf.de, MakeCode's zelos renderer as the editors run it.
  - Localized: Scratch's official translations, Blockly's message files, the MakeCode editors' own strings.
  - Themes for print (`print`, `grayscale`, `high-contrast`) and the document's own category colours over any palette.
  - Line numbers and line labels for worksheets that talk about single lines.
]

#warning(title: "Breaking Change since 0.2.0")[
  The old pre-0.2.0 native-Typst renderer syntax is *removed*. From 0.2.0 onward, blockst uses only the text-to-WASM pipeline. Documents that still rely on the previous syntax must be migrated.
]

== Quick start

#show-code(```typ
#import "@preview/blockst:0.4.0": scratch, blockly, makecode, nepo

#scratch("
when green flag clicked
move (10) steps
turn cw (15) degrees
")
```)

#image("../examples/example-quickstart.svg")

The same document can hold the other editors' blocks. A jwinf task:

#show-code(```typ
#blockly("
Roboter-Programm
wiederhole (4) mal:
  gehe nach rechts
  falls <auf Kiste>
    hebe Murmel auf ::aktionen
  ende
ende
", profile: "jwinf")
```)

A micro:bit program:

#show-code(```typ
#makecode("
beim Start
  zeige Symbol [Herz v]
ende
wenn Knopf [A v] geklickt
  zeige Zahl ((1) + (2))
  pausiere (ms) (100)
ende
")
```)

== Which function for which editor

#table(
  columns: (auto, auto, auto, auto, auto),
  align: left + top,
  table.header([*Editor*], [*Function*], [*Profiles*], [*Default language*], [*Code fences*]),
  [Scratch 3], [`scratch()`], [—], [`"en"`, 26 languages], [`scratch` via `raw-scratch()`],
  [Blockly, jwinf], [`blockly()`], [`blockly` (default), `blockly-klassisch`, `jwinf`, `jwinf-turtle`], [`"de"`, 24 languages], [`blockly`, `jwinf`, `jwinf-turtle` via `raw-blockly()`],
  [MakeCode], [`makecode()`], [`makecode` (micro:bit, default), `makecode-calliope`], [`"de"`, 36 languages], [`makecode`, `microbit`, `calliope` via `raw-makecode()`],
  [Open Roberta], [`nepo()`], [platforms `calliope` (default), `calliopev3`, `microbit`], [`"de"`], [`nepo` via `raw-nepo()`],
)

Every function takes the same rendering options — theme, scale, font, line numbers, colours — and all of them read the defaults set with `set-blockst()`. The chapters #goto("scratch")[Scratch], #goto("blockly-and-jwinf")[Blockly and jwinf], #goto("makecode")[MakeCode] and #goto("nepo-open-roberta")[NEPO] describe what is particular to each editor.

== Package information

- *Version:* 0.4.0
- *License:* MIT
- *Repository:* #link("https://github.com/Loewe1000/blockst")[github.com/Loewe1000/blockst]
- *Compiler requirement:* Typst 0.15.0+
- *Font requirement:* Scratch and Blockly labels are designed for Helvetica Neue. On Linux/Windows install a compatible font (e.g. Nimbus Sans) or set another one with `set-blockst(font: …)`. MakeCode labels use a monospace face — Menlo, Consolas or DejaVu Sans Mono, whichever is installed.

= The notation

Blocks are written one per line, the way they read in the editor. Inputs are marked by their brackets, a body is indented and closed by an end marker. The vocabulary is the editor's own in the chosen language — the parser matches against Scratch's translations, Blockly's message files or the MakeCode editors' strings, and a line it does not recognise is drawn as written in a neutral grey (or in the colour of a category you name, see below).

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  table.header([*Pattern*], [*Example*], [*Description*]),
  [Stack block], [`move (10) steps`], [A command; blocks on consecutive lines snap together],
  [Hat block], [`when green flag clicked`], [An event; starts a new script],
  [Reporter], [`(x position)`], [A value with round ends],
  [Boolean], [`<mouse down?>`], [A condition with pointed ends],
  [Input: number], [`(10)`], [Numeric input field],
  [Input: string], [`[hello]`], [String input field],
  [Input: dropdown], [`[random position v]`], [Dropdown selector — the `v` marks it],
  [Empty input], [`()`, `[]`, `<>`], [An empty slot],
  [C-block], [`repeat (4)` … `end`], [A block with a body: indent the body, close it with the end marker],
  [C-block with else], [`if <…> then` … `else` … `end`], [A second body after the else marker],
  [Icon], [`@greenFlag`, `@turnRight`, `@turnLeft`], [The flag and the turn arrows],
  [Line label], [`move (10) steps #step`], [Names the line, see #goto("labels-and-line-numbers")[Labels and line numbers]],
)

What differs between the editors is small and follows the editor:

- *End and else markers* follow the language: `end`/`else` in English, `ende`/`sonst` in German Blockly, `ende`/`ansonsten` in German MakeCode, `fin`/`sinon` in French. `end`, `ende` and `else` are understood in every Blockly and MakeCode language.
- *Booleans.* Scratch and MakeCode draw a condition as a hexagon, so `<…>` and `(…)` are different shapes. Blockly has no hexagonal boolean: there `<…>` equals `(…)`.
- *Unknown labels.* Scratch names a category with a prefix, `@motion free text` (see #goto("scratch", anchor: "#category-quick-color-defaults")[\@category]). Blockly and MakeCode use a suffix, `hebe Murmel auf ::aktionen` — on jwinf the normal case, because the same block reads differently from task to task.
- *Units.* MakeCode shows some units in parentheses; they are typed like a value and drawn as the label: `pausiere (ms) (100)`, `Temperatur (°C)`.
- *Editors.* MakeCode's LED matrix and melody editor have a notation of their own, see #goto("makecode")[MakeCode].

= Options for every editor

`scratch()`, `blockly()`, `makecode()` and `nepo()` accept the same rendering options. Given on the call, they apply to that block group; set with `set-blockst()`, they become the document's defaults; wrapped in `blockst[…]`, they apply to everything inside.

== set-blockst() — Global Defaults

#show-code(```typ
#set-blockst(
  theme: none,            // "normal", "high-contrast", "print", "grayscale"
  profile: none,          // default profile for blockly() and makecode()
  colors: none,           // (category: colour, …) over any palette
  scale: none,            // 80%, 0.8 — overall size
  inset-scale: none,      // 60% thin, 125% thick blocks; text size unchanged
  stroke-width: none,
  font: none,             // "Nimbus Sans"
  language: none,         // default language for every editor
  line-numbers: none,
  line-number-start: none,
  line-number-first-block: none,
  line-number-gutter: none,
)
```)

All parameters are optional. Only provided values override the current defaults; a later `set-blockst()` changes only what it names.

== blockst() — Group Override Container

#show-code(```typ
#blockst(theme: "high-contrast", scale: 80%)[
  #scratch("when green flag clicked\nmove (10) steps")
  #blockly("wiederhole (4) mal:\n  gehe nach rechts\nende", profile: "jwinf")
]
```)

All parameters match `set-blockst()` but apply only within the body; `spacing` (default `1.5em`) sets the gap between the blocks inside.

== Themes

#table(
  columns: (auto, auto),
  align: left + top,
  table.header([*Theme*], [*Description*]),
  [`"normal"`], [Default — the editor's full colours.],
  [`"high-contrast"`], [Lighter, high-contrast variant for accessibility.],
  [`"print"`], [Every block white with a black outline. The lightest on ink, but all categories look alike.],
  [`"grayscale"`], [One distinct grey per category, so a control block still reads differently from an operator on a monochrome page.],
)

The derived themes are computed from the palette in use, so `grayscale` on a jwinf profile is jwinf's categories in grey, and a colour set with `colors` carries its own bevel, stroke, high-contrast and grey shades.

#show-code(```typ
#let script = "when green flag clicked
go to (random position v)
turn cw (30) degrees"

#blockst(inset-scale: 50%)[#scratch(script)]
#blockst(theme: "high-contrast")[#scratch(script)]
#blockst(theme: "print")[#scratch(script)]
```)

#image("../examples/example-theme.svg")

== Colours

`colors` lays the document's own category colours over any palette — for the document with `set-blockst()`, for a single block or group on the rendering function or on `blockst()`. A hex string or a Typst colour per category; the category names are the ones the editor uses (`motion`, `looks`, … for Scratch, `aktionen`, `schleifen`, `logik`, … for jwinf, `basic`, `input`, `loops`, … for MakeCode).

#show-code(```typ
#set-blockst(colors: (logik: "#73cc47"))
#blockly(programm, profile: "jwinf", colors: (aktionen: "#cc7347", schleifen: rgb("#5ba55b")))
```)

jwinf colours its categories per task family; `colors` is the way to match a task that deviates from both jwinf profiles.

== Fonts

#show-code(```typ
#set-blockst(font: "Nimbus Sans")
```)

Scratch and Blockly labels default to Helvetica Neue, MakeCode labels to Menlo, Consolas or DejaVu Sans Mono. Set the font here rather than with `set text(font: …)`: the renderer measures each label and writes the font into the SVG, so a document-level `set text` changes what is drawn but not what was measured, and the labels overlap.

== Scale and inset scale

`scale` multiplies the whole drawing (`80%`, `0.8`). `inset-scale` changes the thickness of the blocks without touching the text: `60%` gives compact, `125%` generous blocks.

#show-code(```typ
#set-blockst(scale: 80%)
#set-blockst(inset-scale: 60%)   // compact blocks
```)

== Line numbers

#show-code(```typ
#set-blockst(line-numbers: true, line-number-start: 1, line-number-gutter: 24)
```)

`line-number-start` is the first number, `line-number-gutter` the width of the gutter in points. Numbering continues from one block group to the next; `line-number-first-block` says with which group it starts. The three can also be given as one dictionary, `line-numbering: (enabled: true, start: 1, first-block: 1)`.

#image("../examples/example-labels.svg")

= Scratch

== scratch() — Render Scratch Blocks

Parses Scratch text and renders the blocks the way Scratch 3 draws them.

#show-example(
  rendered: context scratch("when green flag clicked\nmove (10) steps"),
  source: ```typ
#scratch("when green flag clicked\nmove (10) steps")
```,
  side-by-side: true,
)

#show-code(```typ
#scratch(
  text,
  language: "en",
  theme: auto,
  scale: auto,
  font: auto,
  colors: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-gutter: auto,
  inset-scale: auto,
)
```)

`text` is the Scratch block text in the chosen language; the other parameters are the #goto("options-for-every-editor")[options every editor shares], `auto` meaning the document's default. The parser knows the full Scratch 3 vocabulary in all 26 locales, including the pen extension.

== raw-scratch — Code fences

The `raw-scratch()` show rule renders `scratch` code fences as blocks:

#show-code(```typ
#show: raw-scratch(language: "en")
```)

#show-code(```scratch
when green flag clicked
repeat (4)
  move (30) steps
  turn cw (90) degrees
end
```)

#image("../examples/example-raw-scratch.svg")

== Languages

Scratch blocks come in *26 languages*, from Scratch's official translations. Set the language on the call or with `set-blockst(language: …)`; block text must match the chosen locale's vocabulary.

#table(
  columns: (auto, auto, auto, auto),
  align: (left, left, left, left),
  table.header([*Code*], [*Language*], [*Code*], [*Language*]),
  [`"en"`], [English], [`"de"`], [German],
  [`"fr"`], [French], [`"es"`], [Spanish],
  [`"it"`], [Italian], [`"nl"`], [Dutch],
  [`"pt"`], [Portuguese], [`"pl"`], [Polish],
  [`"ru"`], [Russian], [`"ja"`], [Japanese],
  [`"ca"`], [Catalan], [`"cs"`], [Czech],
  [`"cy"`], [Welsh], [`"el"`], [Greek],
  [`"fa"`], [Persian], [`"gd"`], [Scottish Gaelic],
  [`"he"`], [Hebrew], [`"hi"`], [Hindi],
  [`"hr"`], [Croatian], [`"hu"`], [Hungarian],
  [`"id"`], [Indonesian], [`"nb"`], [Norwegian (Bokmål)],
  [`"ro"`], [Romanian], [`"sl"`], [Slovenian],
  [`"tr"`], [Turkish], [`"ar"`], [Arabic],
)

#show-code(```typ
#set-blockst(scale: 67.5%)
#scratch("
Wenn die grüne Flagge angeklickt
wiederhole (4) mal
  gehe (30) er Schritt
  drehe dich nach rechts um (90) Grad
end
", language: "de")
```)

#image("../examples/example-de.svg")

=== Right-to-left languages

Arabic (`"ar"`), Hebrew (`"he"`) and Persian (`"fa"`) render right-to-left. Nothing has to be switched on: each locale declares its own direction, and the renderer mirrors the layout — the notch, the hat dome, the C-block mouth, the loop arrow, the pen badge, the `define` hat and the order of the labels all move to the reading edge.

#show-code(```typ
#scratch("
عند نقر @greenFlag
تحرك (10) خطوة
كرِّر (4) مرة
استدر @turnRight (90) درجة
نهاية
", language: "ar")
```)

#image("../examples/example-rtl.svg")

#info(title: "What is mirrored, and what is not")[
  Layout is mirrored; meaning is not. The loop arrow points back to the top of the loop, which is a claim about the drawing, so it flips with the drawing. `@turnRight` and `@turnLeft` are never mirrored — their direction is what the sprite is being told to do, and a mirrored `@turnRight` would tell the reader to turn the other way.
]

Arabic short vowels are optional and their order is not canonical, so blocks match whether or not you type the harakat: `كرِّر` and `كرر` both find the repeat block.

== `@category` — Quick Color Defaults

A `@category` prefix forces a block's category colour, even without matching the full localized syntax.

#show-code(```typ
@motion         // → default motion block
@motion free text  // → unrecognized block in motion color
```)

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  table.header([*Token*], [*Normalized*], [*Default Block*]),
  [`@motion`], [motion], [`move (10) steps`],
  [`@looks`], [looks], [`say [Hello!]`],
  [`@sound`], [sound], [`play sound [pop v]`],
  [`@events`], [events], [`when green flag clicked`],
  [`@control`], [control], [`repeat (10)`],
  [`@sensing`], [sensing], [`ask [What's your name?] and wait`],
  [`@operators`], [operators], [`(() + ())`],
  [`@variable`], [variables], [`set [var v] to (0)`],
  [`@list`], [lists], [`add (thing) to [list v]`],
  [`@pen`], [pen], [`clear`],
  [`@event`], [events], [(alias for `events`)],
  [`@operator`], [operators], [(alias for `operators`)],
)

When `@category` is followed by text that matches a known block in that category, the actual block is rendered; otherwise the fallback is an `unrecognized` block in the forced colour.

#show-code(```typ
@list add (12) to [my list v]    // → DATA_ADDTOLIST
@variable change [score v] by (1) // → DATA_CHANGEVARIABLEBY
```)

== scratch-parse() — Parse to AST

Parses Scratch text to an abstract syntax tree for programmatic use — a nested structure of blocks, inputs and bodies.

#show-code(```typ
#scratch-parse(text, language: "en")
```)

The complete list of Scratch blocks, rendered live, is the #goto("scratch-block-catalog")[Scratch block catalog] at the end of this manual. Running Scratch programs as turtle graphics and importing `.sb3` files have chapters of their own.

= Blockly and jwinf

== blockly() — Render Blockly Blocks

`blockly()` renders Blockly blocks from the shared notation, drawn with Blockly's shapes — notch, puzzle tab, boxed fields, the mutator gear on an if block, the warning sign on a loop-control block outside a loop.

#show-code(```typ
#blockly(
  text,
  profile: auto,      // "blockly", "blockly-klassisch", "jwinf", "jwinf-turtle"
  language: auto,     // "de" by default
  theme: auto,
  scale: auto,
  font: auto,
  colors: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-gutter: auto,
  inset-scale: auto,
)
```)

== Profiles

A profile chooses look and vocabulary. `set-blockst(profile: …)` sets the default for `blockly()`.

#table(
  columns: (auto, auto, auto),
  align: left + top,
  table.header([*Profile*], [*Look*], [*Vocabulary*]),
  [`"blockly"` (default)], [today's flat Blockly (thrasos)], [Blockly's standard blocks],
  [`"blockly-klassisch"`], [Blockly before 2019, with the bevel highlight], [same],
  [`"jwinf"`], [jwinf.de — the classic geometry measured on the site, the palette of the robot training tasks], [robot and turtle world blocks, plus the standard blocks in the old wording],
  [`"jwinf-turtle"`], [the same, with the colours of the Freie Turtle-Umgebung], [same],
)

#show-code(```typ
#blockly("
Roboter-Programm
wiederhole (4) mal:
  gehe nach rechts
  falls <auf Kiste>
    hebe Murmel auf ::aktionen
  ende
ende
", profile: "jwinf")
```)

#image("../examples/example-blockly.svg")

== Writing jwinf tasks

On jwinf the same block reads differently from task to task — „hebe Murmel auf", „nimm Fisch", „Holzstapel einsammeln" — so there is no fixed vocabulary to match against. Write the label as it appears and name the category with a `::` suffix: `aktionen`, `schildkroete`, `sensoren`, `schleifen`, `logik`, `mathe`, `variablen`, `funktionen`, `text`, `listen`, `ausgeben`, `einlesen`. Blocks the profile knows — loops, conditions, variables, the robot and turtle commands — are recognised without a suffix.

`ende` closes a C-block, `sonst` opens its else branch, and `<…>` equals `(…)`: Blockly has no hexagonal boolean. Where a task's colours deviate from both profiles, `colors` lays the document's own over the palette (see #goto("options-for-every-editor", anchor: "#colours")[Colours]).

== Languages

The standard blocks come in 24 languages, from Blockly's own message files: `language: "de"` (the default), `"en"`, `"fr"` (`répéter (10) fois`), `"ja"` (`(10) 回繰り返す`), and ar, ca, cs, el, es, fa, he, hi, hr, hu, id, it, nb, nl, pl, pt, ro, ru, sl, tr. The jwinf world blocks exist in German only. Each language closes a C-block with the marker its Scratch locale uses (`ende`, `end`, `fin`, …) and opens the else branch with Blockly's word (`sonst`, `else`, `sinon`, …); `ende`, `end` and `else` work in every language.

== Code fences and parsing

`raw-blockly()` renders `blockly` fences with the default profile, `jwinf` fences with the jwinf profile and `jwinf-turtle` fences with the turtle colours, whatever the arguments say. `blockly-parse()` returns the AST.

#show-code(```typ
#show: raw-blockly()
#blockly-parse(text, language: "de", profile: "blockly")
```)

Themes apply as for Scratch, with `grayscale` derived from the profile's palette.

= MakeCode

== makecode() — Render MakeCode Blocks

`makecode()` renders the blocks of the MakeCode editors for the micro:bit and the Calliope mini. The look is Blockly's zelos renderer as the editors run it — pills and hexagons as tall as their block, white literal pills, the − and + buttons of an if block, MakeCode's monospace labels — and the block texts are the editors' own.

#show-code(```typ
#makecode(
  text,
  profile: auto,      // "makecode" (micro:bit), "makecode-calliope"
  language: auto,     // "de" by default
  theme: auto,
  scale: auto,
  font: auto,
  colors: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-gutter: auto,
  inset-scale: auto,
)
```)

#show-code(```typ
#makecode("
beim Start
  zeige Symbol [Herz v]
ende
wenn Knopf [A v] geklickt
  zeige Zahl ((1) + (2))
  pausiere (ms) (100)
ende
")
```)

#image("../examples/example-makecode.svg")

== Profiles

`"makecode"` (the default) is the micro:bit editor, `"makecode-calliope"` the Calliope mini's: the same blocks plus the Calliope's own (motors, the RGB LED), in the Calliope palette. `set-blockst(profile: "makecode-calliope")` sets the default for `makecode()`; `colors:` overrides single categories.

== Writing MakeCode programs

- *Units.* A unit the editor shows in parentheses is typed like a value and drawn as the label: `pausiere (ms) (100)`, `Temperatur (°C)`.
- *Operators* take the editor's glyph or a spelling: `×` or `*`, `÷` or `/`, `≥` or `>=`, `≤` or `<=`, `≠` or `!=`.
- *LED matrix.* 25 cells, `#` lit and `.` dark, in any grouping: `zeige LEDs [#...#|.#.#.|..#..|.#.#.|#...#]`.
- *Melody editor.* Eight notes or rests: `spiele (Melodie [C D E F - - - -] mit Tempo (120) (bpm)) [bis zum Ende v]`.
- *Else.* `ansonsten`/`else` opens the else branch, which gets the editor's − and + buttons.
- *Unknown labels* are drawn as written with the category from a `::kategorie` suffix: `basic`, `input`, `music`, `led`, `radio`, `loops`, `logic`, `variables`, `math`, `functions`, `arrays`, `text`, `game`, `images`, `pins`, `serial`, `control`.

== Languages

The block texts are the editors' own in every language the editors offer: German (`language: "de"`, the default) and English read off the running editors, the other 34 — `"fr"`, `"es"`, `"ja"`, `"zh-cn"`, … — from the translation service the editors load at run time (approved strings only; an untranslated block keeps its English text, as in the editor). A bare code picks the regional variant the editor ships (`"es"` → es-ES, `"pt"` → pt-BR). The end and else markers follow the language (`fin`/`sinon`, `終わり`/`でなければ`, …); `ende`, `end` and `else` work everywhere.

== Code fences and parsing

`raw-makecode()` renders `makecode` and `microbit` fences with the micro:bit profile and `calliope` fences with the Calliope mini profile. `makecode-parse()` returns the AST.

#show-code(```typ
#show: raw-makecode()
#makecode-parse(text, language: "de", profile: "makecode")
```)

= NEPO (Open Roberta)

`nepo()` renders the blocks of Open Roberta Lab for the Calliope mini and the micro:bit — a renderer of its own, contributed by #link("https://github.com/lkoehl")[lkoehl]. Block text prints in Open Roberta's own wording even when the source used a colloquial alias.

#show-code(```typ
#nepo(
  code,
  language: "de",
  platform: "calliope",   // "calliope", "calliopev3", "microbit"
  theme: auto,
  scale: auto,
  font: auto,
)
```)

#show-example(
  rendered: context framed(nepo("
Start
  Zeige Text \"Hallo\"
  Wiederhole unendlich oft
    Schalte RGB LED an (#ff0000)
  Ende
")),
  source: ```typ
#nepo("
Start
  Zeige Text \"Hallo\"
  Wiederhole unendlich oft
    Schalte RGB LED an (#ff0000)
  Ende
")
```,
  side-by-side: true,
)

`raw-nepo()` renders `nepo` fences, `nepo-parse()` returns the block tree. The renderer is a prototype: the set of blocks is the beginner set of the three platforms, and `examples/nepo` in the repository holds the programme collection and the comparison sheet against Open Roberta's own drawings.

= Labels and line numbers

A line that ends in `#name` is labelled. Labels are collected from every rendered block group — Scratch, Blockly, MakeCode — and can be queried later, so a worksheet can say "the loop in line 3" and be right after the program changes.

== blockst-labels() — Query Labels

#show-code(```typ
#blockst-labels("loop")   // → line number or "NaN"
#blockst-labels()         // → full label → line dictionary
```)

== scratch-labels() — Extract Labels

Parses Scratch text and returns a dictionary mapping label names to line numbers, without rendering.

#show-code(```typ
#let labels = scratch-labels("
repeat (4) #loop
  move (20) steps #step
  turn cw (90) degrees
end
")
// labels = ("loop": 1, "step": 2)
```)

== blockst-register-labels() — Pre-register Labels

Registers labels globally without rendering blocks — for labels that are needed before the first block output.

#show-code(```typ
#blockst-register-labels("
repeat (4) #loop
  move (20) steps #step
end
")
```)

#image("../examples/example-labels.svg")

= Running Scratch programs

blockst includes an execution engine that runs Scratch programs visually — for demonstrating program flow and pen drawing. It runs Scratch text only.

== scratch-run Module

#show-code(```typ
#import "@preview/blockst:0.4.0": scratch-run, set-scratch-run

#scratch-run.stage("...", scale: 2)
#scratch-run.grid("...", grid: true)
```)

=== scratch-run.stage() — Stage Canvas

Renders pen drawing on a stage canvas, like the Scratch stage.

#show-code(```typ
#scratch-run.stage(
  program,
  language: "en",      // locale for block text
  size: auto,          // (width, height) in pixels (default 480×360)
  scale: auto,         // drawing scale multiplier
  start: auto,         // (x: 0, y: 0, angle: 90)
  pen: auto,           // (down: false, color: ..., size: ...)
  background: auto,    // background color (e.g. white, black)
  cursor: auto,        // show/hide turtle cursor (default: true)
  border: auto,        // show/hide stage border (default: true)
)
```)

=== scratch-run.grid() — Coordinate Grid

Renders the drawing on a Cartesian coordinate grid with optional axes and grid lines.

#show-code(```typ
#scratch-run.grid(
  program,
  language: "en",      // locale for block text
  x: auto,             // view bounds (tuple, e.g. (-10, 10))
  y: auto,             // view bounds (tuple)
  step: auto,          // grid step size
  scale: auto,         // drawing scale multiplier
  start: auto,         // (x: 0, y: 0, angle: 90)
  pen: auto,           // (down: false, color: ..., size: ...)
  background: auto,    // background color
  axes: auto,          // show axis lines (default: false)
  grid: auto,          // show grid lines (default: false)
  grid-style: auto,    // grid line stroke (default: 0.5pt + gray)
  cursor: auto,        // show/hide turtle cursor (default: true)
  fit: auto,           // auto-fit view to drawing bounds
)
```)

=== set-scratch-run() — Run Global Defaults

#show-code(```typ
#set-scratch-run(
  scale: none,         // default scale for all runs
  start: none,         // (x: 0, y: 0, angle: 90)
  pen: none,           // (down: false, color: ..., size: ...)
  background: none,    // default background color
  cursor: none,        // show/hide turtle cursor (default: true)
  stage: none,         // (size: (480, 360), border: true)
  grid: none,          // (visible: false, axes: false, step: auto, style: auto)
)
```)

=== Supported Execution Commands

#table(
  columns: (auto, auto),
  align: left + top,
  table.header([*Category*], [*Commands*]),
  [Motion], [`move`, `turn-right`, `turn-left`, `set-direction`, `go-to`, `set-x`, `set-y`, `change-x`, `change-y`],
  [Pen], [`pen-down`, `pen-up`, `set-pen-color`, `set-pen-size`, `change-pen-size`, `erase-all`, `stamp`, `set-pen-param`, `change-pen-param`],
  [Variables], [`set-variable`, `change-variable`, `variable`],
  [Operators], [`plus`, `minus`, `multiply`, `divide`, `modulo`, `random`, `round`, `greater`, `less`, `equals`, `op-and`, `op-or`, `op-not`],
  [Control], [`repeat`, `repeat-until`, `if-then`, `if-else`, `wait`],
  [Looks], [`say`, `think`],
  [Shapes], [`square`, `triangle`, `circle`, `star`, `spiral`],
  [German], [`gehe`, `drehe-rechts`, `drehe-links`, `setze-richtung`, `gehe-zu`, `stift-ein`, `stift-aus`, `setze-stiftfarbe-auf`, `setze-stiftdicke`, `setze-variable`, `aendere-variable`, `groesser`, `kleiner`, `gleich`, `und`, `oder`, `nicht`, `mal`, `geteilt`, `zufallszahl`],
)

=== Complete Example

#image("../examples/example-executable.svg")

#show-code(```typ
#let square-program = "
go to x: (-45) y: (45)
pen down
set pen [color v] to (0)
set pen size to (45)
repeat (4)
  move (90) steps
  turn cw (90) degrees
  change pen [color v] by (25)
end"

#set-scratch-run(
  stage: (size: (300, 240)),
  start: (x: 0, y: 0, angle: 90),
)

#grid(
  columns: (auto, auto),
  gutter: 6mm,
  [#scratch(square-program)],
  [#scratch-run.stage(square-program, scale: 2)],
)
```)

= Importing Scratch projects (SB3)

blockst can read real Scratch 3 project files (`.sb3`) and extract scripts, variables, lists, images, and screen previews.

== Basic Workflow

#show-code(```typ
#let project = read("my-project.sb3", encoding: none)

#sb3.render-sb3-scripts(project, language: "en", target: "Sprite1")
```)

The `.sb3` file must be read as raw bytes (`encoding: none`).

== render-sb3-scripts()

#show-code(```typ
#sb3.render-sb3-scripts(
  sb3-bytes,                   // raw .sb3 file bytes (read with encoding: none)
  script-number: auto,         // global script index (1-based)
  target-script-number: auto,  // script index within selected target
  target: auto,                // filter by target name ("Stage", sprite name, or auto for all)
  sb3-plugin: auto,            // WASM plugin path (auto = bundled plugin)
  language: "en",              // locale for block text
  show-headers: auto,          // show target name header
  header-gap: 1.5mm,           // spacing between target name and scripts
  script-gap: 3mm,             // spacing between individual scripts
)
```)

#image("../examples/example-sb3-import.svg")

== render-sb3-variables()

#show-code(```typ
#sb3.render-sb3-variables(
  sb3-bytes,                   // raw .sb3 file bytes
  target: auto,                // filter by target name
  target-variable-name: auto,  // filter by variable name
  target-variable-number: auto,// variable index within target (1-based)
  sb3-plugin: auto,            // WASM plugin path
  language: "en",              // locale for display text
  show-target-headers: auto,   // show target name header
  target-gap: 2mm,             // spacing between targets
  item-gap: 0.8mm,             // spacing between variable items
)
```)

== render-sb3-lists()

#show-code(```typ
#sb3.render-sb3-lists(
  sb3-bytes,                   // raw .sb3 file bytes
  target: auto,                // filter by target name
  target-list-name: auto,      // filter by list name
  target-list-number: auto,    // list index within target (1-based)
  sb3-plugin: auto,            // WASM plugin path
  language: "en",              // locale for display text
  show-target-headers: auto,   // show target name header
  target-gap: 2mm,             // spacing between targets
  item-gap: 0.8mm,             // spacing between list items
)
```)

== Standalone Monitors

=== list-monitor()

#show-code(```typ
#list-monitor(
  name: "List",      // display name shown in header
  items: (),         // array of values to display
  width: 5.2cm,      // monitor width
  height: auto,      // auto-grows to fit content
  length-label: auto,// show length indicator (e.g. "length: 3")
)
```)

=== variable-monitor()

#show-code(```typ
#variable-monitor(
  name: "Variable",  // display name shown in header
  value: 0,          // current value to display
)
```)

#image("../examples/example-monitors.svg")

== screen-preview()

#show-code(```typ
#sb3.sb3-screen-preview(
  sb3-bytes,           // raw .sb3 file bytes
  width: 480,          // stage rendering width in pixels
  height: 360,         // stage rendering height in pixels
  unit: 1,             // size multiplier (2 = double size)
  background: none,    // override background color
  show-border: true,   // show stage border
  show-backdrop: true, // show costume/backdrop image
  monitor-scale: 1.5,  // scale factor for variable/list overlays
  language: auto,      // locale for monitor text
)
```)

Renders a static Scratch stage preview with sprites, backdrop, and monitors.

== Image Helpers

#show-code(```typ
// List all image assets in the project
#sb3.sb3-image-assets-catalog(sb3-bytes, target: auto)

// Render a single image asset
#sb3.sb3-image(
  sb3-bytes,          // raw .sb3 file bytes
  target: auto,       // filter by sprite/stage name
  image-number: auto, // global image index (1-based)
  target-image-number: auto, // image index within target (1-based)
  image-name: auto,   // filter by image name (e.g. "costume1")
  width: auto,        // output width (auto = original size)
  height: auto,       // output height
)
```)

== Catalog Helpers

#show-code(```typ
// Grouped script metadata (targets, scripts, blocks count)
#sb3.sb3-scripts-catalog(sb3-bytes)

// Target states (variables, lists, and sprite properties)
#sb3.sb3-state-catalog(sb3-bytes)

// Convert a specific SB3 script to Scratch text
#sb3.sb3-bytes-to-scratch-text(
  sb3-bytes,          // raw .sb3 file bytes
  script-number: auto,// global script index (1-based)
  language: "en",     // locale for output text
)
```)

= Scratch block catalog

Every block of each Scratch 3 category, rendered live, next to the text that produces it. The #goto("blockly-block-catalog")[Blockly] and #goto("makecode-block-catalog")[MakeCode] catalogs follow.

#let _catalog-table(blocks, render: scratch) = table(
  columns: (auto, auto),
  align: (left, left),
  table.header([*Block*], [*Code*]),
  ..blocks.map(block => (table.cell[#framed(render(block))], table.cell[#raw(block)])).flatten(),
)

== Motion

#_catalog-table("move (10) steps
turn cw (15) degrees
turn ccw (15) degrees
point in direction (90)
point towards [mouse-pointer v]
go to x: (0) y: (0)
go to [mouse-pointer v]
glide (1) secs to x: (0) y: (0)
glide (1) secs to [mouse-pointer v]
change x by (10)
set x to (0)
change y by (10)
set y to (0)
if on edge, bounce
set rotation style [left-right v]
(x position)
(y position)
(direction)".split("\n"))

== Looks

#_catalog-table("say [Hello!] for (2) seconds
say [Hello!]
think [Hmm...] for (2) seconds
think [Hmm...]
show
hide
switch costume to [costume1 v]
next costume
switch backdrop to [backdrop1 v]
next backdrop
change [color v] effect by (25)
set [color v] effect to (0)
clear graphic effects
change size by (10)
set size to (100) %
go to [front v] layer
go [forward v] (1) layers
(costume [number v])
(backdrop [number v])
(size)".split("\n"))

== Sound

#_catalog-table("play sound [pop v] until done
start sound [pop v]
stop all sounds
change [pitch v] effect by (10)
set [pitch v] effect to (100)
clear sound effects
change volume by (-10)
set volume to (100) %
(volume)".split("\n"))

== Pen

#_catalog-table("erase all
stamp
pen down
pen up
set pen color to [#ff0000]
change pen color by (10)
set pen color to (50)
change pen shade by (10)
set pen shade to (50)
change pen size by (1)
set pen size to (1)".split("\n"))

== Variables

#_catalog-table("set [my variable v] to (0)
change [my variable v] by (1)
show variable [my variable v]
hide variable [my variable v]
(my variable)".split("\n"))

== Lists

#_catalog-table("add [thing] to [my list v]
delete (1) of [my list v]
delete all of [my list v]
insert [thing] at (1) of [my list v]
replace item (1) of [my list v] with [thing]
(item (1) of [my list v])
(item # of [thing] in [my list v])
(length of [my list v])
<[my list v] contains [thing]?>
show list [my list v]
hide list [my list v]".split("\n"))

== Events

#_catalog-table("when green flag clicked
when [space v] key pressed
when this sprite clicked
when backdrop switches to [backdrop1 v]
when [loudness v] > (10)
when I receive [message1 v]
broadcast [message1 v]
broadcast [message1 v] and wait".split("\n"))

== Control

#_catalog-table("wait (1) seconds
repeat (10)
end
forever
end
if <> then
end
if <> then
else
end
wait until <>
repeat until <>
end
stop [all v]
when I start as a clone
create clone of [myself v]
delete this clone".split("\n"))

== Sensing

#_catalog-table("<touching [mouse-pointer v]?>
<touching color [#ff0000]?>
<color [#ff0000] is touching [#00ff00]?>
(distance to [mouse-pointer v])
ask [What's your name?] and wait
(answer)
<key [space v] pressed?>
<mouse down?>
(mouse x)
(mouse y)
(loudness)
(timer)
reset timer
([x position v] of [Sprite1 v])
(current [year v])
(days since 2000)
(username)".split("\n"))

== Operators

#_catalog-table("(() + ())
(() - ())
(() * ())
(() / ())
(pick random (1) to (10))
<() > ()>
<() < ()>
<() = ()>
<> and <>
<> or <>
not <>
(join [apple] [banana])
(letter (1) of [apple])
(length of [apple])
([apple] contains [a]?)
(() mod ())
(round ())
([sqrt v] of (9))".split("\n"))

#let _locales = "../scripts/scratchblocks-wasm/data/dialects/locales/"
#let _titled(name) = upper(name.first()) + name.slice(1)
// Every block of a dialect locale, a table per category. `skip` leaves out
// the mutator containers, which are no blocks of their own.
#let _dialect-catalog(file, render, skip: (), order: (), level: 3, end: "end") = {
  let groups = catalog-entries(toml(_locales + file), end: end)
  // In the order of the editor's palette; what the palette does not name
  // follows in the order of the file.
  let names = order.filter(n => n in groups) + groups.keys().filter(n => n not in order)
  for category in names {
    let texts = groups.at(category).filter(e => e.id not in skip).map(e => e.text)
    if texts.len() == 0 { continue }
    // `depth`, nicht `level`: schuldocs teilt die Website an Überschriften der
    // Tiefe 1, und `heading(level: …)` ließe die Tiefe auf 1 stehen.
    heading(depth: level, _titled(category))
    _catalog-table(texts, render: render)
  }
}

= Blockly block catalog

Every block the Blockly dialect knows, built from the locale files the parser reads (`scripts/scratchblocks-wasm/data/dialects/locales/`). Empty slots stand for a value `()` or a dropdown `[ v]`; write the content in your own document. The standard blocks are shown in English (`language: "en"`); the same blocks exist in 24 languages, German being the default, see the languages of #goto("blockly-and-jwinf")[Blockly and jwinf].

== Standard blocks

The `blockly` profile: Blockly's standard blocks in today's wording.

#let _blockly-order = ("schleifen", "logik", "mathe", "text", "listen", "variablen", "funktionen")
#_dialect-catalog("blockly-en.toml", blockly.with(language: "en"), skip: ("text_create_join_container", "text_join"), order: _blockly-order)

== jwinf

The `jwinf` profile: the robot and turtle world blocks of jwinf.de, plus the standard blocks whose wording differs there. jwinf is a German competition, its world blocks exist in German only.

#_dialect-catalog("jwinf-de.toml", blockly.with(profile: "jwinf"), skip: ("text_create_join_container", "colourRGB"), order: ("start", "aktionen", "schildkroete", "turtleInput", "sensoren") + _blockly-order, end: "ende")

= MakeCode block catalog

Every block of the MakeCode editors, built from the locale files the parser reads, shown in English (`language: "en"`). The same blocks exist in all 36 editor languages, German being the default, see the languages of #goto("makecode")[MakeCode].

== micro:bit

The `makecode` profile: the blocks of makecode.microbit.org.

#let _makecode-order = ("basic", "input", "music", "led", "radio", "loops", "logic", "variables", "math", "functions", "arrays", "text", "game", "images", "pins", "serial", "control", "motors")
#_dialect-catalog("makecode-en.toml", makecode.with(language: "en"), order: _makecode-order)

== Calliope mini

The `makecode-calliope` profile adds the Calliope mini's own blocks and recolours the shared ones; listed here are only the blocks the Calliope editor adds or words differently.

#_dialect-catalog("makecode-calliope-en.toml", makecode.with(profile: "makecode-calliope", language: "en"), order: _makecode-order)

= Contributing

Contributions are welcome: bug reports, missing blocks, parser improvements, rendering polish, docs, and new localizations.

- *Repository:* #link("https://github.com/Loewe1000/blockst")[github.com/Loewe1000/blockst]
- *License:* MIT

= API Reference

The reference is generated from the `///` comments in the source. It covers the
public rendering API in `libs/scratch/api.typ`, which `lib.typ` and
`package.typ` re-export unchanged.

#show-module(read("../libs/scratch/api.typ"), name: "blockst")
