// ============================================================================
// FLOE DESIGN SYSTEM — SLIDES PRESET (presets/slides.typ)
// 16:9 Widescreen Keynote-Inspired Presentation Layout
// ============================================================================
#import "../core/lib.typ": *
#import "../mixins/lib.typ": *

/// 16:9 widescreen presentation slide layout
#let slides(
  title: "Presentation",
  theme: "dark",
  ..sink,
  body,
) = {
  let is-dark = theme == "dark"
  let bg = if is-dark { rgb("#0B0F19") } else { white }
  let fg = if is-dark { rgb("#F8FAFC") } else { slate-900 }

  set document(title: title)
  set page(
    paper: "presentation-16-9",
    margin: (x: 1.8cm, y: 1.4cm),
    fill: bg,
    footer: context {
      set text(font: fonts.sans, size: 8.5pt, fill: if is-dark { slate-400 } else { slate-500 })
      grid(
        columns: (1fr, auto),
        align(left)[#title],
        align(right)[#counter(page).display()],
      )
    }
  )

  set text(font: fonts.sans, size: 14pt, fill: fg)
  show: with-code-theme
  show: with-math-theme

  body
}
