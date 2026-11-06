// Passive Editorial design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary. Editorial is the magazine voice of the bundled set: serif
// display type over a sans body, a kicker-masthead title under a strong
// opening rule, numeral sections with the ghost number bleeding off the
// corner, kicker rules under slide headings, and a ghost folio in the corner
// of every slide.
#import "../../component/api.typ" as components
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens
#import "../polarity.typ": is-dark-canvas, dark-code-theme
#import "../../deck-state.typ": slide-numbered

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  set text(
    font: options.font,
    size: base-size,
    fill: colors.text,
    fallback: true,
  )
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em, marker: text(fill: colors.accent, size: 0.62em)[▪])
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  set table(stroke: (x, y) => (bottom: 0.6pt + colors.line))
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  show heading: set text(font: options.font-display, weight: "semibold")
  show heading.where(level: 1): set text(size: base-size * 1.9)
  show heading.where(level: 2): set text(size: base-size * 1.35)
  show heading: set block(below: 0.6em)
  // The kicker rule: a short accent stroke under every slide heading, the
  // editorial counterpart of a standfirst rule.
  show heading.where(level: 2): it => block(width: 100%)[
    #it
    #v(0.24em)
    #line(length: 2.4em, stroke: 0.14em + colors.accent)
  ]
  show figure.caption: set text(
    font: options.font-display, style: "italic", size: 0.72em,
    fill: colors.muted,
  )
  show label("mosaic-title-display"): set text(
    font: options.font-display, size: 2.2em, weight: "semibold",
    tracking: -0.01em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.46em)
  show label("mosaic-cell-section"): set text(
    font: options.font-display, size: 2em, weight: "semibold",
  )
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}

#let definition = (
  name: "Editorial",
  colors: tokens.colors,
  defaults: (
    spacing: (inset: 42pt),
    // The folio: a ghost slide number in the corner of every numbered slide.
    // It reads its colors from the deck record, so a palette swap recolors it
    // too, and it quiets itself on unnumbered pages such as titles.
    foreground: context if slide-numbered.get() {
      place(bottom + right, block(
        inset: (right: 20pt, bottom: 14pt),
        text(
          size: 0.8em,
          components.progress(variant: "1", role: "neutral"),
        ),
      ))
    },
  ),
  options: (
    font: "Inter",
    font-display: "Source Serif 4",
    base-size: 20pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
