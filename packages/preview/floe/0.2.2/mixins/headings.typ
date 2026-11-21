// ============================================================================
// SNOWPACK DESIGN SYSTEM — HEADING THEME MIXIN (mixins/headings.typ)
// Composable Show Rule for Sticky Anti-Orphan Headings and Section Badges
// ============================================================================
#import "../core/lib.typ": *

/// Opt-in show rule to style headings with sticky anti-orphan behavior
#let with-heading-theme(
  numbering: "1.1",
  section-symbol: false,
  body,
) = {
  set heading(numbering: numbering)

  show heading.where(level: 1): it => {
    set text(font: fonts.sans, size: 17pt, weight: "bold", fill: floe-navy)
    block(above: 1.4em, below: 0.5em, sticky: true, it)
  }

  show heading.where(level: 2): it => {
    set text(font: fonts.sans, size: 12pt, weight: "bold", fill: floe-navy)
    block(above: 1.35em, below: 0.6em, sticky: true)[
      #if section-symbol [ #text(fill: floe-cyan)[§ ] ]#it
    ]
  }

  show heading.where(level: 3): it => {
    set text(font: fonts.sans, size: 10.5pt, weight: "bold", fill: floe-slate)
    block(above: 1.15em, below: 0.45em, sticky: true, it)
  }

  body
}
