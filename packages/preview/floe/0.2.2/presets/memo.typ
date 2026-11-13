// ============================================================================
// FLOE DESIGN SYSTEM — MEMO PRESET (presets/memo.typ)
// Executive Decision Memo, Engineering Whitepaper & Technical Briefing Layout
// ============================================================================
#import "../core/lib.typ": *
#import "../mixins/lib.typ": *

/// Executive memo / technical decision brief layout
#let memo(
  title: "Engineering Decision Memo",
  to: "Systems & Control Board",
  from: "Chief Architect",
  date: "November 2026",
  subject: "Optimization Architecture",
  summary: none,
  ..sink,
  body,
) = {
  set document(title: title, author: from)

  set page(
    paper: "a4",
    margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )

  set text(font: fonts.sans, size: 9.8pt, fill: slate-900)
  set par(justify: true, leading: 0.65em, spacing: 1em)

  show: with-code-theme
  show: with-heading-theme.with(numbering: none)
  show: with-math-theme
  show: with-table-theme
  show: with-running-chrome.with(
    header-left: title,
    header-right: date,
    suppress-pages: 1,
  )

  // Memo Header Plaque
  block(
    width: 100%,
    fill: slate-50,
    stroke: strokes.border + slate-200,
    radius: radii.md,
    inset: 12pt,
    below: 1.4em,
  )[
    #heading(level: 1)[#title]
    #v(4pt)
    #line(length: 100%, stroke: 1.2pt + floe-cyan)
    #v(6pt)
    #grid(
      columns: (60pt, 1fr, 50pt, 1fr),
      gutter: 6pt,
      text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[TO:],
      text(size: 8.8pt)[#to],
      text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[DATE:],
      text(size: 8.8pt)[#date],
      text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[FROM:],
      text(size: 8.8pt)[#from],
      text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[SUBJECT:],
      text(size: 8.8pt)[#subject],
    )
  ]

  // Executive Summary (if provided)
  if summary != none [
    #block(
      width: 100%,
      fill: rgb("#F0F9FF"),
      stroke: strokes.border + rgb("#BAE6FD"),
      radius: radii.md,
      inset: 10pt,
      below: 1.2em,
    )[
      #text(font: fonts.sans, size: 8pt, weight: "bold", fill: floe-cyan)[EXECUTIVE SUMMARY]
      #v(2pt)
      #summary
    ]
  ]

  body
}
