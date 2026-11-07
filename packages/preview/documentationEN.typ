// na-corexamen — documentation (English)
// Compile from the package folder:  typst compile documentationEN.typ

// ======================================================================
// Colors: change only the values below
// ======================================================================
#let c-mod  = rgb("#1E4E8C")   // modules (top-level headings): blue
#let c-sub  = rgb("#0E8A7D")   // sub-modules: teal
#let c-warn = rgb("#B45309")   // callouts: orange
#let c-code = rgb("#9D174D")   // inline code

// ======================================================================
// Font settings: change only the values below
// ======================================================================
#let doc-font   = ("New Computer Modern", "Libertinus Serif")
#let code-font  = ("DejaVu Sans Mono", "Courier New")
#let doc-size   = 11pt
#let code-size  = 8.6pt     // code blocks
#let icode-size = 9pt       // inline code

#set document(title: "na-corexamen — documentation", author: "Naam Mohamed")
#set page(
  paper: "a4",
  margin: (x: 2cm, top: 2cm, bottom: 2.4cm),
  footer: context {
    line(length: 100%, stroke: 0.6pt + c-mod.lighten(55%))
    v(3pt)
    align(center, text(size: 9.5pt, fill: c-mod)[
      #counter(page).display() / #counter(page).final().first()
    ])
  },
)

#set text(font: doc-font, size: doc-size, lang: "en")
#set par(justify: true)
#set heading(numbering: "1.1")
#set list(marker: text(fill: c-sub)[•], body-indent: 0.6em)

#show raw: set text(font: code-font, size: code-size)
#show raw.where(block: false): it => box(
  fill: luma(240), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt,
  text(fill: c-code, size: icode-size, it),
)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(96%), stroke: 0.5pt + luma(85%), radius: 5pt,
  inset: 9pt, above: 1em, below: 1.2em, it,
)

// ----------------------------------------------------------------------
// Modules (level 1): colored number badge + title + underline
// ----------------------------------------------------------------------
#show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 0.9em, sticky: true)[
  #grid(
    columns: (auto, 1fr), column-gutter: 0.7em, align: horizon,
    box(fill: c-mod, radius: 5pt, inset: (x: 0.6em, y: 0.3em),
      text(fill: white, weight: "bold", counter(heading).display(it.numbering))),
    text(fill: c-mod, weight: "bold", size: 1.4em, it.body),
  )
  #v(0.15em)
  #line(length: 100%, stroke: 1.4pt + c-mod.lighten(50%))
]

// ----------------------------------------------------------------------
// Sub-modules (level 2): colored square + number + title
// ----------------------------------------------------------------------
#show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.6em, sticky: true)[
  #grid(
    columns: (auto, auto, 1fr), column-gutter: 0.5em, align: horizon,
    box(width: 0.55em, height: 0.55em, fill: c-sub, radius: 1.5pt),
    text(fill: c-sub, weight: "bold", counter(heading).display(it.numbering)),
    text(fill: c-sub.darken(15%), weight: "bold", size: 1.1em, it.body),
  )
]

// ----------------------------------------------------------------------
// Table of contents: modules bold blue, sub-modules teal, light dot leaders
// ----------------------------------------------------------------------
#set outline.entry(fill: repeat(gap: 0.35em)[#text(fill: luma(150))[.]])
#show outline.entry.where(level: 1): set text(fill: c-mod, weight: "bold")
#show outline.entry.where(level: 1): set block(above: 1.1em)
#show outline.entry.where(level: 2): set text(fill: c-sub, size: 0.92em)
#show outline.entry.where(level: 2): set block(above: 0.55em)

// ----------------------------------------------------------------------
// Formatting helpers
// ----------------------------------------------------------------------
// Table with a colored header row and zebra striping (the first cells are the header row)
#let tbl(columns, ..cells, color: c-sub) = block(width: 100%, above: 1em, below: 1.2em)[
  #show table.cell.where(y: 0): set text(fill: white, weight: "bold")
  #table(
    columns: columns, inset: 6pt, stroke: 0.5pt + luma(80%),
    fill: (_, y) => if y == 0 { color } else if calc.odd(y) { luma(96%) } else { white },
    ..cells,
  )
]

// Callout box with a colored side bar
#let note(title, body, color: c-warn) = block(
  width: 100%, breakable: false, above: 1em, below: 1em,
  fill: color.lighten(92%), stroke: (left: 3pt + color), radius: 3pt, inset: 10pt,
)[
  #text(fill: color, weight: "bold")[#title] \
  #body
]

// ======================================================================
// Cover
// ======================================================================
#block(
  width: 100%, radius: 10pt, inset: (x: 20pt, y: 26pt),
  fill: gradient.linear(c-mod, c-sub, angle: 20deg),
)[
  #set text(fill: white)
  #align(center)[
    #text(size: 30pt, weight: "bold")[na-corexamen] \
    #v(2pt)
    #text(size: 13pt)[Marking schemes (corrections) of exams and assignments for Typst — Arabic and Latin] \
    #v(8pt)
    #box(fill: rgb("#ffffff33"), radius: 20pt, inset: (x: 12pt, y: 4pt))[
      #text(size: 10pt)[version 0.1.0]
    ]
  ]
]

#v(1.2em)
#block(width: 100%, above: 1em, below: 0.4em)[
  #text(size: 16pt, weight: "bold", fill: c-mod)[Table of contents]
  #v(0.1em)
  #line(length: 100%, stroke: 1.6pt + c-mod)
]
#outline(title: none, indent: 1.6em)

#pagebreak(weak: true)

// ======================================================================
// Content
// ======================================================================
= Introduction

== The idea

`na-corexamen` is the companion of `na-examen`. It draws the *same header* (barcode, text under it, school, school year, level, term, subject, duration) and the same footer "page X of Y", with the title « Corrigé / Marking scheme / تصحيح … ». All the exercises are drawn in *one continuous table* with two columns, *Solution* and *Marks*, which can break across pages (the header row is repeated at the top of each page). Each exercise is a full-width title row, then the solution rows, then a « Total » row; the next exercise starts right below, in the same table, with no gap.

== What the package does for you

You write the solution *freely*: ordinary text and equations, with no brackets or cell syntax around each question. You only put the marks with `#mk(...)` at the end of each step. The package cuts your text at every `#mk`, puts each piece in a row of the table with its mark in front of it, and adds everything up:

- a « Total » row closes each exercise inside the table;
- the heading of the exercise takes the total too (« Exercise 1 (08 points) »);
- an optional summary table adds up all the exercises (« 20 / 20 »).

= Quick start

== Import and header

```typ
#import "@preview/na-corexamen:0.1.0": *

#show: correction.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "tashih-fard-1",          // text under the barcode
)
```

== Exercises and summary

```typ
#exercise[
  #section[I.]                    // sub-title row (optional)

  #q[1] Write the solution freely, with equations $x = 3$ #mk(0.5)

  #q[2] Another step of the solution
  $ f(x) = x^2 + 1 $ #mk(1)

  A step worth two marks in two parts #mk(1, 1)
]

#exercise[
  #part[ #q[1] ... #mk(1) ]       // « Part A (01 point) »
  #part[ #q[1] ... #mk(2) ]       // « Part B (02 points) »
]

#summary(total: 20)               // recap table and grand total
```

= How it works

== Reading and cutting the text

Inside `#exercise[ ... ]` the text is read from top to bottom:

- everything written *before* a `#mk(...)` (since the previous one) becomes one row of the table, and the value of the mark goes in the Marks column of the same row;
- `#mk(1, 0.5)` adds the numbers (here 1.5) and shows only the sum;
- numbers like `0.25`, `0.5`, `1.5` are fine; the display is cleaned (`2` not `2.0`, `0.3` not `0.30000000000000004`);
- text after the last `#mk` (a remark such as "any other correct method is accepted") becomes a last row without marks.

== Sub-titles and parts

- `#section[I.]` makes a full-width sub-title row;
- `#part[ ... ]` groups rows under a sub-title « Part A (03 points) » whose points are the sum of its own marks; parts are renumbered in each exercise.

Equations (inline `$ ... $` or display `$ ... $` with spaces) and paragraphs are all allowed inside a row.

== The three rules

#note("Three rules")[
  + Write `#exercise` at the top level of the document (not inside another command);
  + write `#mk`, `#section` and `#part` directly in the body of the exercise (not inside another command such as `#align[...]` or `#strong[...]`);
  + do not put `#set` or `#show` rules inside the body of an exercise or after `#show: correction` (put them before it).
]

Consecutive exercises are merged into one table; any other content between them (text or `#summary`) closes the table and a new one starts after it.

= Functions

== Template and exercise

#tbl((auto, 1fr),
  table.header[Function][Description],
  [`correction`], [the template: `#show: correction.with(...)`. Page, header, footer and information block.],
  [`exercise(points:, title:, gap:)[...]`], [an exercise: title row « Exercise 1 (08 points) » (points from the marks), the solution rows and the « Total » row, all inside the single table. `gap` is kept for compatibility and has no effect.],
)

== Marks and sub-titles

#tbl((auto, 1fr),
  table.header[Function][Description],
  [`mk(..marks)`], [a mark, written at the end of a step: `#mk(0.5)`, `#mk(0.5, 0.5)`.],
  [`section[...]`], [a full-width sub-title row inside the table.],
  [`part(title:)[...]`], [a part inside an exercise (« Part A (02 points) »); points = sum of its marks.],
)

== Helpers

#tbl((auto, 1fr),
  table.header[Function][Description],
  [`q[1]`], [boxed question number (`coB` is the same function).],
  [`summary(total:, title:, gap:)`], [recap table: one row per exercise and the grand total.],
  [`title-style[...]`], [bold underlined title.],
)

= Automatic checks

== Checking an exercise

`exercise(points: 8)`: if the sum of the marks is not 8, a red `⚠ stated: 8` appears in the « Total » row. Without `points`, the heading simply shows the computed sum.

== Checking the summary table

`summary(total: 20)`: the last cell shows `20 / 20` when the exercises add up to exactly 20; if they do not, it shows the computed sum with a red `⚠ stated: 20`. Without `total`, it just shows the grand total.

= Options of `correction`

== Header and barcode

#tbl((auto, auto, 1fr),
  table.header[Option][Default][Meaning],
  [`school`, `year`, `level`, `term`], [from the language], [header information],
  [`kind`], [`"فروض"` (Arabic)], [word before the term; `none` removes it],
  [`term-label`], [`auto`], [the whole term text, instead of `kind` + `term`],
  [`exam`, `subject`], [from the language], [type of exam and subject],
  [`title`], [`auto`], [the whole title line, instead of the automatic « Corrigé de … »],
  [`duration`], [from the language], [duration; `none` removes it],
  [`code`], [`"na-corexamen"`], [text under the barcode; `none` removes it],
  [`barcode`, `barcode-type`, `barcode-data`, `barcode-height`, `barcode-width`, `barcode-cut`], [`true`, `"Code128"`, `auto`, `0.64cm`, `5cm`, `0.25`], [the barcode (same as `na-examen`)],
)

== Appearance and tables

#tbl((auto, auto, 1fr),
  table.header[Option][Default][Meaning],
  [`decimal`], [`"."`], [decimal separator of all marks],
  [`head-fill`, `sub-fill`], [`luma(215)`, `luma(238)`], [colors of the header row, the sub-title rows and the « Total » row],
  [`table-stroke`, `table-inset`, `mark-width`], [`0.6pt + black`, `7pt`, `2.4cm`], [lines, padding and width of the Marks column],
  [`pad-points`], [`true`], [`8` gives `08`],
  [`paper`, `margin`], [`"a4"`, as in `na-examen`], [page],
)

== Fixed labels

#tbl((auto, auto, 1fr),
  table.header[Option][Default][Meaning],
  [`ex-label`, `ans-label`, `mark-label`, `total-label`, `summary-label`], [from the language], [fixed words of the tables],
  [`year-label`, `level-label`, `duration-label`, `page-label`, `of-label`], [from the language], [fixed words of the header and footer],
)

== Language and fonts

#tbl((auto, auto, 1fr),
  table.header[Option][Default][Meaning],
  [`lang`], [`"ar"`], [`"ar"`, `"fr"`, `"en"`, `"es"`, `"de"`],
  [`font`, `title-font`, `size`], [from the language], [fonts and size],
)

= Languages

== Choosing the language

`lang: "ar"` (default, right-to-left) or `lang: "fr"`, `"en"`, `"es"`, `"de"` (left-to-right). Shortcuts: `correction-fr`, `correction-en`, `correction-latin`. Every option left at `auto` is taken from the language.

== What the language changes

#tbl((auto, auto, auto, auto),
  table.header[Language][Title][Exercise][Total],
  [`ar`], [تصحيح الفرض المحروس في مادة …], [التمرين الأول (08 نقاط)], [المجموع],
  [`fr`], [Corrigé — Devoir surveillé de …], [Exercice 1 (08 points)], [Total],
  [`en`], [… Test — Marking scheme], [Exercise 1 (08 points)], [Total],
  [`es`], [Solucionario — Examen de …], [Ejercicio 1 (08 puntos)], [Total],
  [`de`], [Lösung — Klassenarbeit in …], [Aufgabe 1 (08 Punkte)], [Summe],
)

= Files

```
lib.typ  typst.toml  LICENSE  README.md
documentationEN.typ  documentationAR.typ     (compile them to get the PDFs)
examples/   basic.typ  latin-fr.typ  latin-en.typ
```

= License

MIT.
