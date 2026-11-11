// ============================================================================
// FLOE DESIGN SYSTEM — TABLE THEME MIXIN (mixins/tables.typ)
// Composable Show Rule for Native Typst Tables (Crisp Sans-Serif & Bumped Zebra)
// ============================================================================
#import "../core/lib.typ": *

/// Opt-in show rule to style all native tables with crisp sans-serif text and high-contrast zebra striping
#let with-table-theme(body) = {
  set table(
    stroke: strokes.border + slate-200,
    inset: (x: 8.5pt, y: 6.5pt),
    fill: (_, y) => if y == 0 { slate-200 } else if calc.even(y) { slate-100 } else { white },
  )

  show table.cell: it => {
    set text(font: fonts.sans, size: 8.6pt, fill: slate-800)
    set par(justify: false, leading: 0.5em)
    it
  }
  show table.cell.where(y: 0): set text(font: fonts.sans, weight: "bold", size: 8.6pt, fill: floe-navy)

  body
}
