// ============================================================================
// FLOE DESIGN SYSTEM — CHEATSHEET PRESET (presets/cheatsheet.typ)
// 2-Column / 3-Column High-Density Closed-Book Exam Formula Reference Layout
// ============================================================================
#import "../core/lib.typ": *
#import "../mixins/lib.typ": *

/// High-density multi-column formula cheatsheet / exam revision preset
#let cheatsheet(
  title: "Exam Cheatsheet",
  course-code: "SC42056",
  columns-num: 3,
  paper: "a4",
  orientation: "landscape",
  ..sink,
  body,
) = {
  set document(title: course-code + " — " + title)

  set page(
    paper: paper,
    flipped: orientation == "landscape",
    margin: (x: 1.0cm, top: 1.0cm, bottom: 1.0cm),
    header: [
      #grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        text(font: fonts.sans, size: 8pt, weight: "bold", fill: floe-navy)[
          #course-code — #title
        ],
        text(font: fonts.sans, size: 7.5pt, fill: slate-400)[
          Closed-Book Formula Reference Sheet
        ]
      )
      #v(2pt)
      #line(length: 100%, stroke: 0.8pt + floe-cyan)
    ],
    footer: context [
      #align(center)[
        #text(font: fonts.sans, size: 7pt, fill: slate-400)[
          Page #counter(page).display() • Built with Floe Design System
        ]
      ]
    ]
  )

  set text(font: fonts.sans, size: 8pt, fill: slate-900)
  set par(justify: true, leading: 0.45em, spacing: 0.6em)

  show: with-code-theme
  show: with-math-theme
  show: with-table-theme
  show: with-compact-theme

  // Tightly styled cheatsheet section titles
  show heading.where(level: 1): it => block(
    above: 0.8em,
    below: 0.4em,
    sticky: true,
  )[
    #text(font: fonts.sans, size: 9.2pt, weight: "bold", fill: floe-navy)[#it.body]
    #v(-0.35em)
    #line(length: 100%, stroke: 0.8pt + floe-cyan)
  ]

  show heading.where(level: 2): it => block(
    above: 0.55em,
    below: 0.25em,
    sticky: true,
    text(font: fonts.sans, size: 8.2pt, weight: "bold", fill: floe-slate)[#it.body],
  )

  columns(columns-num, gutter: 10pt)[
    #body
  ]
}
