// na-examen — documentation (English)
// Compile from the package folder:  typst compile documentationEN.typ
 #import "@preview/na-examen:0.1.0": *

#set page(paper: "a4", margin: (x: 2cm, y: 2cm), numbering: "1 / 1")
// ======================================================================
// ⚙ Font settings: change only the values below (a font name or a fallback list)
// ======================================================================
#let doc-font  = ("New Computer Modern", "Libertinus Serif")          // body font of this guide
#let demo-font = ("Amiri", "Noto Naskh Arabic", "New Computer Modern") // font of the Arabic demo output
#let code-font = ("DejaVu Sans Mono", "Courier New")                   // code font
#let doc-size  = 11pt                                                  // body size
#let demo-size = 14pt                                                  // demo size
#let code-size = 8.6pt                                                 // code size

#set text(font: doc-font, size: doc-size, lang: "en")
#set par(justify: true)
#set heading(numbering: "1.1 –")
#show raw: set text(font: code-font, size: code-size)

#let scope = (exercise: exercise, part: part, q: q, title-style: title-style)
#let demo(code) = {
  let src = code.text
  block(breakable: false, width: 100%, above: 1em, below: 1.2em)[
    #rect(fill: luma(96%), radius: 5pt, width: 100%, inset: 9pt, code)
    #counter("na-examen-exercise").update(0)
    #rect(stroke: 0.5pt + luma(60%), width: 100%, inset: 9pt)[
      #set text(font: demo-font, size: demo-size, lang: "ar", dir: rtl)
      #eval(src, mode: "markup", scope: scope)
    ]
  ]
}

#align(center)[
  #text(24pt, weight: "bold")[na-examen] \
  #text(13pt)[Arabic and Latin exam and assignment template for Typst] \
  version 1.1.0
]

#outline(indent: 1.5em, title: [Table of contents])

= Introduction

`na-examen` makes writing an exam simple, in Arabic (right-to-left) or in a Latin-script language such as French or English (left-to-right): you write the exercises only. The package draws the header (barcode, text under it, school, school year, level, term, subject, duration), the footer "page X of Y", and numbers the exercises and parts automatically.

= Usage

```typ
#import "@preview/na-examen:1.1.0": *

#show: examen.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "fard 1 fasl awal-1AS-typst",
)

#exercise(points: 8)[ exercise text ... ]
```

Or copy the package folder next to your document and write `#import "lib.typ": *`. It needs Typst ≥ 0.13 and the fonts *Amiri* (text) and *Arial* (titles; a fallback font is used if it is missing).

= The template `examen`

All options are optional.

#table(
  columns: (auto, auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*Option*], [*Default*], [*Meaning*],
  [`school`], [from the language], [school (top right in Arabic, top left in Latin)],
  [`year`], [`"2026-2027"`], [school year, after `year-label`],
  [`level`], [level], [level, after `level-label`],
  [`term`], [first term], [term],
  [`kind`], [exams], [word before the term; `none` removes it],
  [`term-label`], [`auto`], [the whole term text instead of `kind` + `term`],
  [`exam`], [supervised test], [type of exam],
  [`subject`], [mathematics], [subject: "exam in the subject of ..."],
  [`title`], [`auto`], [the whole title line instead of `exam` + `subject`],
  [`duration`], [`"2 ســا"`], [duration; `none` removes it],
  [`code`], [`"na-examen"`], [text under the barcode; `none` removes it],
  [`barcode`], [`true`], [draw the barcode; `false` removes it],
  [`barcode-height`, `barcode-width`], [`0.64cm`, `5cm`], [barcode shape],
  [[`barcode-type`, `barcode-data`, `barcode-cut`], [`"Code128"`, `auto`, `0.25`], [barcode type, encoded value (`auto` = the `code` text), fraction cut from its bottom]],
  [`year-label`, `level-label`, `duration-label`, `page-label`, `of-label`], [from the language], [fixed words],
  [`lang`], [`"ar"`], [document language and preset: `"ar"`, `"fr"`, `"en"`, `"es"`, `"de"`],
  [`dir`], [`auto`], [`rtl` or `ltr`; `auto` follows the language],
  [`pad-points`], [`true`], [`8` gives "08"; `false` gives "8"],
  [`font`, `title-font`, `size`], [`auto`], [fonts and size; Arabic: Amiri, Arial, `16pt`; Latin: Libertinus Serif, Arial, `12pt`],
  [`paper`, `margin`], [`"a4"`], [page; margins as in the original file],
)

The options left at `auto` (school, level, term, subject, labels, fonts, size) are taken from the language preset. The document language is `lang` (`ar` by default), so packages that follow `#set text(lang: ...)` (such as `na-tabpos`) use Arabic words automatically.

= Exercises: `exercise`

`exercise(points: none, title: auto, gap: 1cm)[...]` — titled "التمرين الأول", "الثاني", ... automatically, with a space of `gap` before every exercise except the first.

#demo(```typ
#exercise(points: 8)[
  نص التمرين الأول.
  #q[1] السؤال الأول.

  #q[2] السؤال الثاني.
]
#exercise(points: 1)[نص التمرين الثاني.]
#exercise(points: "04 نقاط", title: [المسألة])[نص المسألة.]
```)

`points` is a number (`8` gives "(08 نقاط)", `1` gives "(01 نقطة)"), a string used as written in parentheses, or `none`.

= Latin template: French, English, ...

The same template works in Latin script. Give `lang`; the direction becomes left-to-right and the words, fonts and exercise names follow the language.

```typ
#show: examen.with(
  lang: "fr",                  // "fr", "en", "es" or "de"
  school: "Lycée Ibn Khaldoun",
  level: "1re année secondaire",
  term: "Premier trimestre",
  subject: "Mathématiques",
  duration: "2 h",
)

#exercise(points: 8)[ ... #q[1] ... ]    // "Exercice 1 (08 points)"
#exercise(points: 7)[
  #part(points: 3)[ ... ]                  // "Partie A (03 points)"
  #part(points: 4)[ ... ]
]
```

`examen-latin` is `examen.with(lang: "fr")`; `examen-fr` and `examen-en` are shortcuts too.

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*`lang`*], [*Exercise*], [*Part*], [*Points*], [*Footer*],
  [`ar`], [التمرين الأول], [الجزء الأول], [(08 نقاط)], [صفحة 1 من 3],
  [`fr`], [Exercice 1], [Partie A], [(08 points)], [Page 1 sur 3],
  [`en`], [Exercise 1], [Part A], [(08 points)], [Page 1 of 3],
  [`es`], [Ejercicio 1], [Parte A], [(08 puntos)], [Página 1 de 3],
  [`de`], [Aufgabe 1], [Teil A], [(08 Punkte)], [Seite 1 von 3],
)

For another language (for example `lang: "it"`) the English words are used; replace them with `year-label`, `level-label`, `duration-label`, `page-label`, `of-label`, `title`, `term-label` and `points: "..."`. To add a language for good, copy a preset (`_fr` for example) in `lib.typ` and add it to `_presets`.

= Changing the font

The font is an option you can change at any time, in the template itself:

```typ
#show: examen.with(
  font: "Cairo",                       // body font (or a fallback list)
  title-font: ("Tajawal", "Arial"),    // titles and header font
  size: 15pt,                          // size
)
```

`font` and `title-font` accept one font name or a list tried in order; the first font installed on your computer is used. At the top of this guide's source, the variables `doc-font`, `demo-font` and `code-font` control the fonts of the guide itself.

= Parts: `part`

#demo(```typ
#exercise(points: 7)[
  #part(points: 2)[نص الجزء الأول.]
  #part(points: 5)[
    نص الجزء الثاني.
    #q[1] السؤال.
  ]
]
```)

Part numbering restarts at every exercise.

= Question box: `q`

`#q[1]` draws the number in a box (`coB` is the same function). `title-style[...]` is a bold underlined title.

= Examples

Folder `examples/`: `basic.typ` (the original exam), `custom-header.typ` (every header field changed), `no-barcode.typ` (no barcode, no duration), `latin-fr.typ` (French devoir) and `latin-en.typ` (English test). Folder `fichier_de_test/`: `long-exam.typ` for multi-page tests.
