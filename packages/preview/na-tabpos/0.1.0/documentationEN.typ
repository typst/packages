// na-tabpos — documentation (English)
// Compile from the package folder:  typst compile documentationEN.typ
#import "@preview/na-tabpos:0.1.0": *

#set page(paper: "a4", margin: (x: 2cm, y: 2cm), numbering: "1 / 1")
#set text(font: ("New Computer Modern", "Amiri"), size: 11pt, lang: "en")
#set par(justify: true)
#set heading(numbering: "1.1 –")
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em)[#it]
#show raw: set text(font: ("DejaVu Sans Mono", "Courier New"), size: 8.6pt)
#show link: it => underline(stroke: blue, it)

// ---- helper: shows the code and the rendered result -------------------------
#let scope = (tabpos: tabpos, tabpos-names: tabpos-names, tabvar: tabvar, hatch: hatch, grille: grille)
#let demo(code, size: 13pt) = {
  let src = code.text
  block(breakable: false, width: 100%, above: 1em, below: 1.2em)[
    #rect(fill: luma(96%), radius: 5pt, width: 100%, inset: 9pt, code)
    #v(-0.3em)
    #align(center)[
      #set text(font: ("Amiri", "New Computer Modern"), size: size, lang: "ar")
      #eval(src, mode: "markup", scope: scope)
    ]
  ]
}

#align(center)[
  #text(24pt, weight: "bold")[na-tabpos] \
  #v(2pt)
  #text(13pt)[Sign, variation and *relative-position* tables for Typst] \
  #v(2pt)
  version 1.0.0 · built on #link("https://typst.app/universe/package/vartable")[vartable] and #link("https://github.com/cetz-package/cetz")[CeTZ]
]

#v(0.5em)
#outline(indent: 1.5em, title: [Table of contents])
#pagebreak()

= Introduction

`na-tabpos` is a Typst package for Arabic (and any other) math documents. It is built on *vartable* and adds one thing: a *relative-position* row — curve against a line, or curve against curve — with the two arcs drawn at every intersection, like `\tkzTabPos` in LaTeX.

Everything else is exactly vartable: sign rows, variation rows, hatched undefined areas, `"||"` and `"0"` bars, added values, styles… The syntax of vartable is unchanged.

*Main features*
- The *difference row* `f(x) - g(x)` — a sign row placed right before a `"p"` row — is *1 cm* high by default (option `diff-height`).
- The words of the `"p"` row (above / below / crosses / at the point) *follow the language of the document* (`#set text(lang: ...)`): Arabic, French, English, Spanish, German, Italian, Portuguese, Dutch, Turkish, Russian. Any other language uses English. You can always give your own words.
- A height written in a `label` (for example `([title], 2cm, "s")`) is exactly that many centimetres.

= Installation and import

From the Typst Universe (when published):

```typ
#import "@preview/na-tabpos:1.0.0": *
```

Or copy the package folder next to your document and write:

```typ
#import "lib.typ": *
```

The package needs Typst ≥ 0.13 and loads CeTZ automatically. For Arabic text use an Arabic font (for instance *Amiri*) and `lang: "ar"`.

= Row types

Each element of `label` is an array `(title, type)` or `(title, height, type)`.

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*Type*], [*Meaning*],
  [`"s"`], [Sign row. The *difference row* `f(x) - g(x)` is just a sign row.],
  [`"v"`], [Variation row.],
  [`"p"`], [*Relative-position row* (new).],
)

The function is called `tabpos` (the name `tabvar` is also exported and is the same function).

= The difference row and its height

The difference row is written as a normal sign row. When it is placed *immediately before* a `"p"` row, its height is `diff-height`, *1 cm* by default:

#demo(```typ
#tabpos(
  variable: $x$,
  label: (
    ([$f(x) - y$], "s"),     // difference row: 1 cm
    ([Relative position], "p"),
  ),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```)

== Changing the heights

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*How*], [*Effect*],
  [`diff-height: 1cm`], [Default. Height of every difference row (a `"s"` row followed by a `"p"` row).],
  [`diff-height: 2cm`], [Another height for all difference rows of the table.],
  [`diff-height: none`], [Automatic height (the old behaviour of vartable, about 2.75 cm).],
  [`([title], 1.5cm, "s")`], [Height written in the row: it has priority over `diff-height`.],
  [`pos-height: 3cm`], [Default height of the `"p"` rows (3 cm).],
  [`([title], 3cm, "p")`], [Height of one particular `"p"` row.],
)

#demo(```typ
#tabpos(
  variable: $x$,
  diff-height: 2cm,        // taller difference row
  pos-height: 2cm,         // shorter position row
  label: (([$f(x) - y$], "s"), ([Relative position], "p")),
  domain: ($-oo$, $0$, $+oo$),
  contents: (($-$, ("0", $+$)), ("-", ("0", "+"))),
)
```)

= The `"p"` row

It is written exactly like a sign row, with these differences:

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*Entry*], [*Result*],
  [`"+"`], [*above*: the text `(C_f) / above / (C_g)`.],
  [`"-"`], [*below*: the text `(C_f) / below / (C_g)`.],
  [`("0", "+")`], [The two arcs at the left end of the interval, then *above*.],
  [`(content, "-")`], [The two arcs with the content (for example the point `$A(-1 ; 0)$`) under the text, then *below*.],
  [`"|h|"`, `"h"`, `"h|"`, `"|h"`, `("||", "+")`…], [Same as vartable: hatched areas and bars.],
)

Use the strings `"+"` and `"-"` (not `$+$`) in a `"p"` row.

= Options of `tabpos`

#table(
  columns: (auto, auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*Option*], [*Default*], [*Meaning*],
  [`diff-height`], [`1cm`], [Height of the difference row (`"s"` row right before a `"p"` row); `none` = automatic.],
  [`pos-height`], [`3cm`], [Default height of a `"p"` row, or per row: `([title], 3cm, "p")`.],
  [`first`], [`auto` = `$(C_f)$`], [Name of the first curve. See #link(<names>)[Naming the curves and the line].],
  [`second`], [`auto` = `$(C_g)$`], [Name of the second curve or of the line, e.g. `$(Delta)$`.],
  [`above`, `below`], [`auto`], [Words for the two positions. `auto` = word in the language of the document.],
  [`cross`], [`auto`], [Word between the two curves at an intersection.],
  [`at-point`], [`auto`], [Word before the point note.],
  [`arc-width`], [`0.94`], [Half-distance between the two arcs (CeTZ units, 1 = 1 cm).],
)

All the options of vartable (`hatching-style`, `values`, `table-style`, `first-line-height`, …) still work.

Words in English:

#demo(```typ
#tabpos(
  variable: $x$,
  second: $(Delta)$,
  above: [above], below: [below], cross: [crosses], at-point: [at],
  label: (([$f(x) - y$], "s"), ([Position], "p")),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```)

= Naming the curves and the line <names>

By default the two names are $(C_f)$ and $(C_g)$: `first` renames $(C_f)$, and `second` renames $(C_g)$ (or names the line, e.g. $(Delta)$). Change them *once for the whole document* with `tabpos-names`; every table that follows uses the new names. For example, a curve and a line $(Delta)$:

#demo(```typ
#tabpos-names(first: $(C_f)$, second: $(Delta)$)
#tabpos(
  variable: $x$,
  label: (([$f(x) - y$], "s"), ([Position], "p")),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```)

#tabpos-names(first: $(C_f)$, second: $(C_g)$)

A single table can override the names with its own `first` and `second` options, without changing the others:

```typ
#tabpos(first: $(C_1)$, second: $(C_2)$, ...)
```

Call `tabpos-names` again anywhere in the document to change the names for the tables that come after it. Write `auto` (or leave the argument out) to keep one of the two names unchanged, e.g. `#tabpos-names(second: $(Delta)$)`.

= Language of the words

The default words of the `"p"` row follow the language set with `#set text(lang: ...)` — exactly like any other text of the document:

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 6pt,
  stroke: 0.5pt + luma(60%),
  [*lang*], [*above*], [*below*], [*cross*], [*at-point*],
  [`ar`], [فوق], [تحت], [يقطع], [في النقطة],
  [`fr`], [au-dessus], [au-dessous], [coupe], [au point],
  [`en`], [above], [below], [crosses], [at the point],
  [`es`], [encima], [debajo], [corta], [en el punto],
  [`de`], [oberhalb], [unterhalb], [schneidet], [im Punkt],
  [`it`], [sopra], [sotto], [interseca], [nel punto],
  [`pt`], [acima], [abaixo], [corta], [no ponto],
  [`nl`], [boven], [onder], [snijdt], [in het punt],
  [`tr`], [üstünde], [altında], [keser], [noktasında],
  [`ru`], [выше], [ниже], [пересекает], [в точке],
)

```typ
#set text(lang: "fr")      // => "au-dessus", "au-dessous", "coupe", "au point"
#tabpos(/* ... */)
```

For another language, or other wording, write the words yourself: `above: [oberhalb], below: [unterhalb]`.

= More examples

== Two curves

#demo(```typ
#tabpos(
  variable: $x$,
  second: $(C_g)$,
  label: (([$f(x) - g(x)$], "s"), ([Position], "p")),
  domain: ($-oo$, $0$, $+oo$),
  contents: (($-$, ("0", $+$)), ("-", ("0", "+"))),
)
```)

== Forbidden value, $D_f = RR without {1}$

#demo(```typ
#tabpos(
  variable: $x$,
  label: (([$f(x) - y$], "s"), ([Position], "p")),
  domain: ($-oo$, $1$, $+oo$),
  contents: (($-$, ("||", $+$)), ("-", ("||", "+"))),
)
```)

== Hatched gap, $D_f = ]-oo ; -2[ union ]2 ; +oo[$

#demo(```typ
#tabpos(
  variable: $x$,
  hatching-style: hatch,
  label: (([$f(x) - y$], "s"), ([Position], "p")),
  domain: ($-oo$, $-2$, $2$, $+oo$),
  contents: (($-$, "|h|", $+$), ("-", "|h|", "+")),
)
```)

== Signs, variations, difference and position in one table

#demo(```typ
#tabpos(
  variable: $x$,
  label: (
    ([$f'(x)$], "s"),
    ([$f(x)$], "v"),
    ([$f(x) - y$], "s"),
    ([Position], "p"),
  ),
  domain: ($-oo$, $0$, $+oo$),
  contents: (
    ($-$, ("||", $-$)),
    ((center, $0$), (bottom, top, "||", $-oo$, $+oo$), (center, $0$)),
    ($+$, ("||", $-$)),
    ("+", ("||", "-")),
  ),
)
```)

= Files of the package

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [`lib.typ`], [The whole package in one file (code derived from vartable 0.2.5, plus the `"p"` row, `diff-height` and the language-aware words). Exports `tabpos`, `tabvar`, `hatch`, `grille`, …],
  [`typst.toml`, `LICENSE`], [Package manifest and licences.],
  [`README.md`], [Short presentation (English and Arabic in one file).],
  [`documentationEN.typ` / `.pdf`], [This documentation.],
  [`documentationAR.typ` / `.pdf`], [The same documentation in Arabic.],
  [`examples/`], [Ready-to-compile examples (`.typ`, `.pdf`).],
  [`fichier_de_test/`], [Test files: heights, `"p"` options, hatching.],
)

= Troubleshooting

- *The words of a `"p"` row are not in my language:* they follow `#set text(lang: ...)`; or give `above`, `below`, `cross`, `at-point` yourself.
- *`+` or `-` do not give the words:* in a `"p"` row write the strings `"+"` and `"-"`, not `$+$`.
- *Arabic letters are disconnected or missing:* set an Arabic font, e.g. `#set text(font: "Amiri", lang: "ar")`.
- *I want the old automatic height of the difference row:* write `diff-height: none`.

= Credits and licence

`na-tabpos` is © Naam Mohamed (MIT). The code of `lib.typ` is derived from *vartable* © Le_Foucheur (MIT) — the `LICENSE` file carries both copyrights.
