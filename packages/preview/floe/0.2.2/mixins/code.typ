// ============================================================================
// FLOE DESIGN SYSTEM — CODE THEME MIXIN (mixins/code.typ)
// Modern Windowed Code Blocks: macOS Terminal Dots, Language Tag, Crisp Syntax Highlighting
// ============================================================================
#import "../core/lib.typ": *

/// Opt-in show rule to apply Floe windowed code block styling (and native Mermaid rendering)
#let with-code-theme(body) = {
  show raw.where(block: true): it => {
    if it.lang == "mermaid" {
      return align(center)[
        #block(
          width: 100%,
          inset: (y: 4pt),
          mermaid(it.text, width: 88%, error-mode: "placeholder")
        )
      ]
    }
    let lang-tag = if it.lang != none { upper(it.lang) } else { "CODE" }

    block(
      width: 100%,
      breakable: true,
      fill: rgb("#0F172A"),
      stroke: strokes.border + rgb("#334155"),
      radius: radii.md,
      clip: true,
      above: 1.1em,
      below: 1.1em,
    )[
      // Terminal Header Bar
      #block(
        width: 100%,
        fill: rgb("#1E293B"),
        stroke: (bottom: strokes.hairline + rgb("#334155")),
        inset: (x: 10pt, y: 5.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #grid(
          columns: (auto, 1fr, auto),
          gutter: 6pt,
          align: (horizon, horizon, horizon),
          // Window Control Dots
          [
            #box(width: 6pt, height: 6pt, fill: rgb("#EF4444"), radius: radii.full)
            #h(3pt)
            #box(width: 6pt, height: 6pt, fill: rgb("#F59E0B"), radius: radii.full)
            #h(3pt)
            #box(width: 6pt, height: 6pt, fill: rgb("#10B981"), radius: radii.full)
          ],
          [],
          // Language Badge
          [
            #box(
              fill: rgb("#334155"),
              inset: (x: 4pt, y: 1.5pt),
              radius: radii.sm,
              text(font: fonts.mono, size: 6.8pt, weight: "bold", fill: slate-300)[#lang-tag]
            )
          ]
        )
      ]

      // Code Body
      #block(
        width: 100%,
        inset: (x: 12pt, y: 9pt),
        above: 0pt,
        below: 0pt,
      )[
        #set text(font: fonts.mono, size: 8.5pt, fill: rgb("#F8FAFC"))
        #it
      ]
    ]
  }

  show raw.where(block: false): it => box(
    fill: slate-100,
    stroke: strokes.hairline + slate-200,
    inset: (x: 3.5pt, y: 0.5pt),
    outset: (y: 1.2pt),
    radius: radii.sm,
    text(font: fonts.mono, size: 8.5pt, fill: rgb("#0F172A"))[#it],
  )

  body
}
