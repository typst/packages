// ============================================================================
// FLOE DESIGN SYSTEM — COMPACT / DENSE MIXIN (mixins/compact.typ)
// High-Density Theme for Closed-Book Exam Cheatsheets & Formula Summaries
// ============================================================================
#import "../core/lib.typ": *

/// Opt-in show rule to apply compact typography and dense element spacing
#let with-compact-theme(body) = {
  set text(size: 8.5pt)
  set par(leading: 0.48em, spacing: 0.65em)
  set block(above: 0.55em, below: 0.55em)

  body
}
