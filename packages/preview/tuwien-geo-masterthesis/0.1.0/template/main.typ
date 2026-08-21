/*
 * tuwien-geo-masterthesis
 */

#import "@preview/tuwien-geo-masterthesis:0.1.0": *
#import "@preview/rubber-article:0.5.2": ctable
#import "utils.typ": *

#let info = (
  ..default-info,
  lang: "de", // "de" | "en"
  title: "Master Thesis Title",
  author: "Martina Müller",
  student-id: "01234567",
  faculty: "Fakultät für Mathematik und Geoinformation",
  supervisor: "Title Dr. Name Surname",
  co-supervisor: "Univ.-Ass. Dr. Name Surname",
  cooperation: "(in Zusammenarbeit mit XYZ)",
  eq-numbering: "(1)",
  // degree: "Master",             // "Diplomarbeit" | "Master" | "Bachelor"
  // thesis-type-label: "CUSTOM",  // override computed degree label
)

#show: thesis.with(info: info)
#register-glossary(entry-list)
#show: make-glossary

// --- Front matter ---
#make-title-page(info)

#make-declaration(info)

#make-abstract(
  en: [Replace this with your English abstract.],
  de: [Ersetzen Sie diesen Text durch Ihre deutsche Kurzfassung.],
)

// Uncomment to add acknowledgements:
// #make-acknowledgements[I would like to thank ...]

// --- Table of contents ---
#outline()
#outline(target: figure.where(kind: image), title: [List of Figures])
#outline(target: figure.where(kind: table), title: [List of Tables])

// --- Chapters ---
= Introduction
Update your personal details and thesis info in the `info` dictionary at the top
of this file. Each chapter can be placed in its own `.typ` file and included via
`#include "1_introduction.typ"`.

== Examples
=== Citation
Citation in parenthesis @Doe2000 or #cite(<Doe2000>, form: "prose")

=== Abbreviation
At the first occurrence, @eop is expanded; in subsequent instances, only the
abbreviation is displayed automatically: @eop. All abbreviations must be defined
in the `entry-list` in `utils.typ`. Only those acronyms explicitly referenced in
the text will appear in the list of abbreviations.

=== Table
Reference to @tab-example. Tables are automatically positioned by Typst.

#figure(
  text(size: 0.85em, ctable(
    cols: "|c|ccccccc|ccc|c|",
    header-rows: 2,
    [*Example 1*],
    table.cell(colspan: 7, align: left)[*Example 2*],
    table.cell(colspan: 3, align: left)[*Example 3*],
    [*Example 4*],
    [],
    [A],
    [B],
    [C],
    [D],
    [E],
    [F],
    [G],
    [H],
    [I],
    [J],
    [K],
    [A],
    [8,42],
    [217,15],
    [0,64],
    [3,12],
    [42,09],
    [61,33],
    [14,25],
    [22,04],
    [28,17],
    [11,05],
    [31,44],
    [B],
    [3,15],
    [2,88],
    [0,41],
    [0,92],
    [3,56],
    [2,14],
    [11,80],
    [2,55],
    [4,21],
    [6,73],
    [14,02],
    [C],
    [0,85],
    [1,20],
    [1,58],
    [0,44],
    [1,92],
    [1,11],
    [8,45],
    [3,67],
    [6,02],
    [8,14],
    [19,25],
    table.hline(),
    [D],
    [0,67],
    [2,45],
    [0,91],
    [0,55],
    [1,38],
    [0,29],
    [5,12],
    [7,81],
    [4,03],
    [10,44],
    [13,20],
    [E],
    [1,12],
    [0,45],
    [2,03],
    [0,15],
    [0,25],
    [0,08],
    [3,54],
    [2,31],
    [3,44],
    [5,18],
    [8,62],
  )),
  caption: [Caption of the table.],
)<tab-example>

=== Figure
@fig-tu-logo shows the TU Wien logo. Figures are automatically positioned by
Typst.

#figure(
  rect(align([Image of the TU Wien Logo], horizon), width: 40%, height: 3cm),
  caption: [TU Wien logo.],
)<fig-tu-logo>

=== Mathematical formulas
Mathematical formulas may appear directly within a sentence, for example
$sum_(k=1)^(infinity) 1 / k^2 = pi/2$, or they can be displayed separately from
the surrounding text as
$
  sum_(k=1)^infinity 1/k^2 = pi / 2
$

Alternatively, the expression may be presented as a numbered equation:
#set math.equation(numbering: "(1)")
$
  sum_(k=1)^infinity 1/k^2 = pi / 6
$ <eq-basel>

=== Hyperlink
Webpage of #link("https://www.tuwien.at/", "TU Wien")

=== Bullet Lists

- Foo
- Bar
- Baz

+ Foo
+ Bar
+ Baz

= Literature review / Theoretical background
State of the art.

= Methodology
The methodology used.

= Results
The results of the thesis.

= Discussion
The discussion of the thesis.

= Conclusion and outlook
Conclusion and outlook.

// --- Back matter ---
#bibliography("refs.bib", style: "apa")

#heading([AI usage], numbering: none)
List all generative AI tools used, and specify where, how and when they were
applied.

#heading([Abbreviations], numbering: none)
#print-glossary(entry-list)

#counter(heading).update(0)
#heading([Appendix], numbering: "A.i.")
Additional material.
