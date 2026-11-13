// ============================================================================
// FLOE DESIGN SYSTEM — ADR PRESET (presets/adr.typ)
// Architecture Decision Record Layout (Dual-Mode: Document & Slide Deck)
// ============================================================================
#import "../core/lib.typ": *
#import "../mixins/lib.typ": *
#import "../primitives/badge.typ": badge

/// Architecture Decision Record Layout
/// Modes: "document" (A4 executive technical memo) or "slides" (16:9 presentation)
#let adr(
  title: "ADR: Architecture Decision Record",
  status: "accepted", // "proposed" | "accepted" | "rejected" | "deprecated" | "superseded"
  date: "2026-11",
  deciders: (),
  mode: "document", // "document" | "slides"
  summary: none,
  ..sink,
  body,
) = {
  let status-variants = (
    "accepted": "success",
    "proposed": "info",
    "rejected": "danger",
    "deprecated": "warning",
    "superseded": "neutral",
  )
  let status-badge-variant = status-variants.at(status, default: "info")

  if mode == "slides" {
    // 16:9 Architectural Briefing Deck
    set document(title: title)
    set page(
      paper: "presentation-16-9",
      margin: (x: 1.8cm, y: 1.4cm),
      fill: rgb("#0B0F19"),
      footer: context {
        set text(font: fonts.sans, size: 8.5pt, fill: slate-400)
        grid(
          columns: (1fr, auto),
          align(left)[#title #h(8pt) #badge(upper(status), variant: status-badge-variant)],
          align(right)[#counter(page).display()],
        )
      }
    )
    set text(font: fonts.sans, size: 13pt, fill: rgb("#F8FAFC"))
    show: with-code-theme
    show: with-math-theme
    show: with-table-theme

    // Slide Header Plaque
    block(
      width: 100%,
      fill: rgb("#111827"),
      stroke: strokes.border + rgb("#1F2937"),
      radius: radii.md,
      inset: (x: 16pt, y: 12pt),
      below: 1.4em,
    )[
      #grid(
        columns: (1fr, auto),
        align: (horizon, horizon),
        [
          #text(font: fonts.sans, size: 18pt, weight: "bold", fill: white)[#title]
          #v(3pt)
          #text(font: fonts.sans, size: 10pt, fill: slate-400)[
            Date: #date #if deciders.len() > 0 [ • Deciders: #deciders.join(", ") ]
          ]
        ],
        badge(upper(status), variant: status-badge-variant),
      )
    ]

    body
  } else {
    // Standard A4 Executive Technical Record
    set document(title: title)
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

    // ADR Header Plaque
    block(
      width: 100%,
      fill: slate-50,
      stroke: strokes.border + slate-200,
      radius: radii.md,
      inset: 12pt,
      below: 1.4em,
    )[
      #grid(
        columns: (1fr, auto),
        align: (horizon, horizon),
        [
          #text(font: fonts.sans, size: 8pt, weight: "bold", fill: slate-500, tracking: 0.08em)[ARCHITECTURE DECISION RECORD]
          #v(2pt)
          #heading(level: 1)[#title]
        ],
        badge(upper(status), variant: status-badge-variant)
      )
      #v(6pt)
      #line(length: 100%, stroke: 1.2pt + floe-cyan)
      #v(6pt)
      #grid(
        columns: (60pt, 1fr, 60pt, 1fr),
        gutter: 6pt,
        text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[STATUS:],
        text(size: 8.8pt, weight: "bold")[#upper(status)],
        text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[DATE:],
        text(size: 8.8pt)[#date],
        text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[DECIDERS:],
        text(size: 8.8pt)[#if deciders.len() > 0 { deciders.join(", ") } else { "Technical Steering Committee" }],
        text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-muted)[SCOPE:],
        text(size: 8.8pt)[Core Architecture],
      )
    ]

    // Context Summary (if provided)
    if summary != none [
      #block(
        width: 100%,
        fill: rgb("#F0F9FF"),
        stroke: strokes.border + rgb("#BAE6FD"),
        radius: radii.md,
        inset: 10pt,
        below: 1.2em,
      )[
        #text(font: fonts.sans, size: 8pt, weight: "bold", fill: floe-cyan)[CONTEXT SUMMARY]
        #v(2pt)
        #summary
      ]
    ]

    body
  }
}
