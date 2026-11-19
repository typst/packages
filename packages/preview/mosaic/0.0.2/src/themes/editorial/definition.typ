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

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  set text(
    font: options.font,
    size: base-size,
    fill: colors.text,
    fallback: true,
  )
  // Tight lists become wide. A list nested in an item is then a block that
  // would take the paragraph spacing above it, a gap wider than the item
  // rhythm, so each item body pins nested lists to the item spacing. The
  // rule lives in the body, not on the list, so the space above a top-level
  // list is left alone.
  let widen(item) = {
    let fields = item.fields()
    let body = fields.remove("body")
    (item.func())(..fields, {
      show selector(list).or(enum): set block(above: 0.9em)
      body
    })
  }
  show list.where(tight: true): it => list(tight: false, ..it.children.map(widen))
  show enum.where(tight: true): it => enum(tight: false, ..it.children.map(widen))
  set list(spacing: 0.9em, marker: text(fill: colors.accent, size: 0.62em)[▪])
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  set table(stroke: (x, y) => (bottom: 0.6pt + colors.line))
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  // The display face is named once for every element that wears it. Typst
  // warns per source span that names an unknown family, so repeating
  // `options.font-display` across these four rules would report the same
  // missing serif four times on a machine that lacks it. The rules below
  // carry only size and style.
  show selector(heading)
    .or(figure.caption)
    .or(label("mosaic-title-display"))
    .or(label("mosaic-cell-section")): set text(font: options.font-display)
  show heading: set text(weight: "semibold")
  show heading.where(level: 1): set text(size: base-size * 1.9)
  show heading.where(level: 2): set text(size: base-size * 1.35)
  show heading: set block(below: 1em)
  // The kicker rule: a short accent stroke under every slide heading, the
  // editorial counterpart of a standfirst rule.
  show heading.where(level: 2): it => block(width: 100%)[
    #it
    #v(0.24em)
    #line(length: 2.4em, stroke: 0.14em + colors.accent)
  ]
  show figure.caption: set text(
    style: "italic", size: 0.72em, fill: colors.muted,
  )
  show label("mosaic-title-display"): set text(
    size: 2.2em, weight: "semibold", tracking: -0.01em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.46em)
  show label("mosaic-cell-section"): set text(
    size: 2em, weight: "semibold",
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
    // too, and the component quiets itself on unnumbered pages such as titles.
    // Chrome, not content: the artifact wrapper keeps it out of the tagged
    // PDF's structure tree, so a screen reader never announces it.
    foreground: pdf.artifact(place(bottom + right, block(
      inset: (right: 20pt, bottom: 14pt),
      text(
        size: 0.8em,
        components.progress(variant: "1", role: "neutral"),
      ),
    ))),
  ),
  options: (
    // Designed face first, then the best slide sans each platform ships by
    // default, then the Linux workhorse, ending in Libertinus Serif. Typst
    // embeds no sans at all, so the terminal is a serif and some name here
    // is always unknown: it warns once per unknown family even when a later
    // one resolves, which is the price of rendering as designed anywhere.
    font: (
      "Inter",
      "Source Sans 3",
      "Avenir Next",
      "Segoe UI",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    font-display: (
      "Source Serif 4",
      "Charter",
      "Constantia",
      "Libertinus Serif",
    ),
    base-size: 20pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
